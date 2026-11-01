#!/usr/bin/env python3
import os
import sys
import json
import time
import subprocess

WALLPAPERS = [
    "/home/astro/Pictures/Wallpapers/wallhaven-k8d7j7.jpg",                                # 1920x1284 Native
    "/home/astro/Pictures/Wallpapers/1378781.png",                                         # 3840x2160 4K PNG (7.8MB)
    "/home/astro/Pictures/Wallpapers/wallhaven-lydkg2.jpg",                                # 5000x2237 Ultrawide
    "/home/astro/Pictures/Wallpapers/wallpaperflare.com_wallpaper_upscayl_3x_digital-art-4x.png", # 7680x4320 8K PNG (18.7MB)
    "/home/astro/Pictures/Wallpapers/naive-HM1siQ2bAAAJLVb_upscayl_2x_digital-art-4x.png", # 8192x4608 8.2K PNG (36.8MB)
    "/home/astro/Pictures/Wallpapers/test_upscayl_4x_digital-art-4x.png",                  # 9600x4800 9.6K PNG (61.0MB)
    "/home/astro/Pictures/Wallpapers/test_portrait_2160x3840.png"                          # 2160x3840 Portrait
]

def get_vram_mb():
    try:
        out = subprocess.check_output(["nvidia-smi", "--query-gpu=memory.used", "--format=csv,noheader,nounits"], stderr=subprocess.DEVNULL)
        return float(out.strip().split(b'\n')[0])
    except Exception:
        return 0.0

def run_benchmark(mode):
    env = os.environ.copy()
    env["TEST_MODE"] = mode
    env["WALLPAPER_LIST"] = json.dumps(WALLPAPERS)
    
    cmd = ["qs", "-p", "/home/astro/repos/astroland-u03-experiment/tests/BenchmarkHarness.qml"]
    
    vram_start = get_vram_mb()
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, env=env)
    
    peak_rss_kb = 0
    vram_peak = vram_start
    
    # Monitor process while running
    while proc.poll() is None:
        try:
            with open(f"/proc/{proc.pid}/status") as f:
                for line in f:
                    if line.startswith("VmRSS:"):
                        rss = int(line.split()[1])
                        if rss > peak_rss_kb:
                            peak_rss_kb = rss
                        break
        except Exception:
            pass
        cur_vram = get_vram_mb()
        if cur_vram > vram_peak:
            vram_peak = cur_vram
        time.sleep(0.05)
        
    stdout, stderr = proc.communicate()
    
    results = []
    for line in stdout.splitlines():
        if "BENCHMARK_RESULTS_JSON:" in line:
            json_str = line.split("BENCHMARK_RESULTS_JSON:", 1)[1].strip()
            results = json.loads(json_str)
            break
            
    return {
        "mode": mode,
        "results": results,
        "peak_rss_mb": peak_rss_kb / 1024.0,
        "vram_start_mb": vram_start,
        "vram_peak_mb": vram_peak,
        "vram_delta_mb": vram_peak - vram_start,
        "stderr": stderr
    }

if __name__ == "__main__":
    print(f"--- Running UNBOUNDED (Native / Baseline) Benchmark ---")
    unbounded = run_benchmark("unbounded")
    print(f"Unbounded Peak RSS: {unbounded['peak_rss_mb']:.1f} MB, VRAM Delta: {unbounded['vram_delta_mb']:.1f} MB")
    
    print(f"\n--- Running BOUNDED (sourceSize) Benchmark ---")
    bounded = run_benchmark("bounded")
    print(f"Bounded Peak RSS: {bounded['peak_rss_mb']:.1f} MB, VRAM Delta: {bounded['vram_delta_mb']:.1f} MB")
    
    out_file = "/home/astro/repos/astroland-u03-experiment/tests/benchmark_output.json"
    with open(out_file, "w") as f:
        json.dump({"unbounded": unbounded, "bounded": bounded}, f, indent=2)
    print(f"\nWrote full benchmark results to {out_file}")
