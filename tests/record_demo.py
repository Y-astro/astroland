#!/usr/bin/env python3
import os
import subprocess
import time
import signal

OUT_VIDEO = "/home/astro/repos/astroland-u03-experiment/screenshots/u03_eval/wallpaper_transition_demo.mp4"
HARNESS_QML = "/home/astro/repos/astroland-u03-experiment/tests/AnimatedDemoHarness.qml"

if os.path.exists(OUT_VIDEO):
    os.remove(OUT_VIDEO)

print("Starting video recording with wf-recorder...")
rec_cmd = ["wf-recorder", "-o", "eDP-1", "-f", OUT_VIDEO]
rec_proc = subprocess.Popen(rec_cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

time.sleep(1.0) # give recorder time to initialize

print("Launching AnimatedDemoHarness with Quickshell...")
qs_cmd = ["qs", "-p", HARNESS_QML]
qs_proc = subprocess.run(qs_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=20)

print("Animated demo finished. Stopping video recording...")
rec_proc.send_signal(signal.SIGINT)
rec_proc.wait(timeout=5)

if os.path.exists(OUT_VIDEO):
    size_mb = os.path.getsize(OUT_VIDEO) / (1024 * 1024)
    print(f"Video recorded successfully: {OUT_VIDEO} ({size_mb:.2f} MB)")
    
    # Extract 3 frames at 2s, 5s, 8s using ffmpeg
    for t, label in [(2, "frame_02s_transition.png"), (5, "frame_05s_transition.png"), (8, "frame_08s_transition.png")]:
        out_frame = f"/home/astro/repos/astroland-u03-experiment/screenshots/u03_eval/{label}"
        subprocess.run(["ffmpeg", "-y", "-ss", str(t), "-i", OUT_VIDEO, "-vframes", "1", out_frame], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if os.path.exists(out_frame):
            print(f"Extracted frame: {out_frame}")
else:
    print("Recording failed.")
