#!/usr/bin/env python3
"""Contract and regression tests for Task U02: Atomic Thumbnail Generation in ThumbnailImage.qml."""

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WIDGET_PATH = ROOT / "modules/common/widgets/ThumbnailImage.qml"


class TestU02ThumbnailAtomicContract(unittest.TestCase):
    def setUp(self):
        self.code = WIDGET_PATH.read_text(encoding="utf-8")

    def test_positional_arguments_passed(self):
        # 1. Paths and sizes are passed as positional arguments to bash -c, not interpolated into script
        self.assertIn('"_", thumbPath, srcPath, `${maxSize}`', self.code)
        self.assertIn('thumb="$1"; src="$2"; max="$3"', self.code)
        self.assertNotIn("magick '${sourcePath}'", self.code)
        self.assertNotIn("ffmpeg -v error -y -i '${sourcePath}'", self.code)

    def test_cache_directory_creation_before_check(self):
        # 2. Directory is created before checking or writing
        self.assertIn('mkdir -p "\\${thumb%/*}"', self.code)

    def test_already_cached_exit_contract(self):
        # 3. If file already exists, exit code 0 is returned
        self.assertIn('[ -f "$thumb" ] && exit 0', self.code)

    def test_atomic_tempfile_in_final_cache_directory(self):
        # 4. Generates to unique PID-tagged tempfile in the destination cache directory
        self.assertIn('tmp="$thumb.$$.tmp.png"', self.code)
        self.assertIn('wait "$pid" && mv "$tmp" "$thumb" && exit 1', self.code)

    def test_cancellation_trap_and_cleanup(self):
        # 5. Trap cleans up background PID and temp file on exit/cancellation without touching completed target
        self.assertIn("trap 'kill \"$pid\" 2>/dev/null; rm -f \"$tmp\"' EXIT", self.code)
        self.assertNotIn('rm -f "$thumb"', self.code)

    def test_video_ffmpeg_branch(self):
        # 6. ffmpeg branch checks command, scales with force_original_aspect_ratio, and outputs PNG
        self.assertIn("command -v ffmpeg >/dev/null 2>&1 || exit 2", self.code)
        self.assertIn('scale=$max:$max:force_original_aspect_ratio=decrease', self.code)
        self.assertIn('-f image2 -c:v png "$tmp"', self.code)

    def test_imagemagick_branch(self):
        # 7. magick branch resizes into tempfile in background and saves PID
        self.assertIn('magick "$src" -resize "$max"x"$max" "$tmp" & pid=$!', self.code)

    def test_on_exited_reload_contract(self):
        # 8. onExited only triggers reloadThumbnail when exitCode === 1 (newly generated)
        self.assertIn("if (exitCode === 1)", self.code)
        self.assertIn("root.reloadThumbnail();", self.code)

    def test_lazy_and_service_contract_preserved(self):
        # 9. Service awareness, deduplication, and DPR properties remain intact
        self.assertIn("property bool generateThumbnail: true", self.code)
        self.assertIn("readonly property real thumbnailDevicePixelRatio", self.code)
        self.assertIn("property string attemptedThumbnailPath:", self.code)
        self.assertIn("readonly property bool serviceMayGenerate:", self.code)
        self.assertIn("onThumbnailGenerated(directory)", self.code)
        self.assertIn("onThumbnailGeneratedFile(filePath)", self.code)


if __name__ == "__main__":
    unittest.main()
