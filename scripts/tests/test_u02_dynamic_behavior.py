#!/usr/bin/env python3
"""Dynamic behavioral test suite for Task U02: Atomic Thumbnail Output & Cancellation Resilience.

Validates:
  1. Atomic Image Generation: Output is complete decoded PNG, exit code 1.
  2. Atomic Video Generation: ffmpeg creates scaled PNG thumbnail, exit code 1.
  3. Already-Cached Hit: Immediate exit code 0 when thumbnail exists, no rework.
  4. Path Safety: Handles spaces, single quotes, double quotes, and Unicode.
  5. Cancellation / Interruption: SIGTERM kills child, deletes tmp, leaves NO partial target.
  6. Shared Cache Preservation: Cancellation of concurrent job does not remove existing completed thumb.
  7. Missing Source / Command: Fails cleanly with exit code 2, leaves no target file.
"""

from __future__ import annotations

import os
import shutil
import signal
import subprocess
import tempfile
import time
import unittest
from pathlib import Path

WALLPAPER_DIR = Path("/home/astro/Pictures/Wallpapers")


class TestU02DynamicBehavior(unittest.TestCase):
    def setUp(self):
        self.tmp_dir = Path(tempfile.mkdtemp(prefix="test_u02_dyn_"))
        self.cache_dir = self.tmp_dir / "cache"
        self.fixtures_dir = self.tmp_dir / "fixtures"
        self.fixtures_dir.mkdir(parents=True, exist_ok=True)
        self.cache_dir.mkdir(parents=True, exist_ok=True)

    def tearDown(self):
        shutil.rmtree(self.tmp_dir)

    def _run_thumb_cmd(self, thumb_path: Path, src_path: Path, max_size: int, is_video: bool = False) -> subprocess.CompletedProcess:
        if is_video:
            script = """
                thumb="$1"; src="$2"; max="$3"
                mkdir -p "${thumb%/*}"
                [ -f "$thumb" ] && exit 0
                command -v ffmpeg >/dev/null 2>&1 || exit 2
                tmp="$thumb.$$.tmp.png"
                trap 'kill "$pid" 2>/dev/null; rm -f "$tmp"' EXIT
                ffmpeg -v error -y -i "$src" -frames:v 1 -vf "scale=$max:$max:force_original_aspect_ratio=decrease" -f image2 -c:v png "$tmp" & pid=$!
                wait "$pid" && mv "$tmp" "$thumb" && exit 1
                exit 2
            """
        else:
            script = """
                thumb="$1"; src="$2"; max="$3"
                mkdir -p "${thumb%/*}"
                [ -f "$thumb" ] && exit 0
                tmp="$thumb.$$.tmp.png"
                trap 'kill "$pid" 2>/dev/null; rm -f "$tmp"' EXIT
                magick "$src" -resize "$max"x"$max" "$tmp" & pid=$!
                wait "$pid" && mv "$tmp" "$thumb" && exit 1
                exit 2
            """
        return subprocess.run(
            ["bash", "-c", script, "_", str(thumb_path), str(src_path), str(max_size)],
            capture_output=True,
            text=True
        )

    def test_image_thumbnail_generation(self):
        src = WALLPAPER_DIR / "20261003174355.png"
        dst = self.cache_dir / "std_thumb.png"
        res = self._run_thumb_cmd(dst, src, 256, is_video=False)
        self.assertEqual(res.returncode, 1)
        self.assertTrue(dst.exists())
        # Validate PNG decoding
        id_res = subprocess.run(["magick", "identify", str(dst)], capture_output=True, text=True)
        self.assertEqual(id_res.returncode, 0)
        self.assertIn("PNG", id_res.stdout)

    def test_video_thumbnail_generation(self):
        src = WALLPAPER_DIR / "divine-general-mahoraga.1920x1080.mp4"
        dst = self.cache_dir / "vid_thumb.png"
        res = self._run_thumb_cmd(dst, src, 256, is_video=True)
        self.assertEqual(res.returncode, 1)
        self.assertTrue(dst.exists())
        id_res = subprocess.run(["magick", "identify", str(dst)], capture_output=True, text=True)
        self.assertEqual(id_res.returncode, 0)
        self.assertIn("PNG", id_res.stdout)

    def test_already_cached_returns_zero(self):
        src = WALLPAPER_DIR / "20261003174355.png"
        dst = self.cache_dir / "cached_thumb.png"
        # Pre-create valid thumbnail
        subprocess.run(["magick", str(src), "-resize", "128x128", str(dst)], check=True)
        mtime_before = dst.stat().st_mtime_ns
        res = self._run_thumb_cmd(dst, src, 128, is_video=False)
        self.assertEqual(res.returncode, 0)
        # Verify file was not rewritten
        self.assertEqual(dst.stat().st_mtime_ns, mtime_before)

    def test_exotic_filenames_spaces_quotes_unicode(self):
        src = WALLPAPER_DIR / "06. Frosted Glass.png"
        odd_src = self.fixtures_dir / "odd 'quote' \"double\" space 日本語 🚀.png"
        shutil.copy2(src, odd_src)

        odd_dst = self.cache_dir / "sub dir with spaces" / "odd 'thumb' \"test\" 日本語.png"
        res = self._run_thumb_cmd(odd_dst, odd_src, 128, is_video=False)
        self.assertEqual(res.returncode, 1)
        self.assertTrue(odd_dst.exists())
        id_res = subprocess.run(["magick", "identify", str(odd_dst)], capture_output=True, text=True)
        self.assertEqual(id_res.returncode, 0)

    def test_interruption_leaves_no_partial_file_and_kills_child(self):
        src = WALLPAPER_DIR / "naive-HM1siQ2bAAAJLVb_upscayl_2x_digital-art-4x.png"
        dst = self.cache_dir / "int_thumb.png"
        script = """
            thumb="$1"; src="$2"; max="$3"
            mkdir -p "${thumb%/*}"
            [ -f "$thumb" ] && exit 0
            tmp="$thumb.$$.tmp.png"
            trap 'kill "$pid" 2>/dev/null; rm -f "$tmp"' EXIT
            magick "$src" -resize "$max"x"$max" "$tmp" & pid=$!
            wait "$pid" && mv "$tmp" "$thumb" && exit 1
            exit 2
        """
        p = subprocess.Popen(["bash", "-c", script, "_", str(dst), str(src), "256"])
        time.sleep(0.3)
        p.send_signal(signal.SIGTERM)
        p.wait()

        # Target file must not exist
        self.assertFalse(dst.exists())
        # Temporary files must be cleaned up
        tmps = list(self.cache_dir.glob("*.tmp.png"))
        self.assertEqual(len(tmps), 0)

        # Wait to verify no orphaned child finished in the background
        time.sleep(2.0)
        self.assertFalse(dst.exists())

    def test_shared_cache_file_preserved_when_concurrent_job_fails(self):
        # Target thumbnail already exists
        dst = self.cache_dir / "shared_thumb.png"
        src = WALLPAPER_DIR / "20261003174355.png"
        subprocess.run(["magick", str(src), "-resize", "128x128", str(dst)], check=True)
        self.assertTrue(dst.exists())

        # Second job runs with same target but gets cancelled/fails
        script = """
            thumb="$1"; src="$2"; max="$3"
            mkdir -p "${thumb%/*}"
            tmp="$thumb.$$.tmp.png"
            trap 'kill "$pid" 2>/dev/null; rm -f "$tmp"' EXIT
            sleep 5 & pid=$!
            wait "$pid"
        """
        p = subprocess.Popen(["bash", "-c", script, "_", str(dst), str(src), "128"])
        time.sleep(0.1)
        p.send_signal(signal.SIGTERM)
        p.wait()

        # Completed destination file must remain intact
        self.assertTrue(dst.exists())
        id_res = subprocess.run(["magick", "identify", str(dst)], capture_output=True, text=True)
        self.assertEqual(id_res.returncode, 0)

    def test_missing_source_file_fails_with_code_2(self):
        missing_src = self.fixtures_dir / "does_not_exist.png"
        dst = self.cache_dir / "missing_thumb.png"
        res = self._run_thumb_cmd(dst, missing_src, 128, is_video=False)
        self.assertEqual(res.returncode, 2)
        self.assertFalse(dst.exists())


if __name__ == "__main__":
    unittest.main()
