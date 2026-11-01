#!/usr/bin/env python3
import os
import sys
import subprocess
import json

SCREENSHOT_DIR = "/home/astro/repos/astroland-u03-experiment/screenshots/u03_eval"
os.makedirs(SCREENSHOT_DIR, exist_ok=True)

HARNESS_QML = "/home/astro/repos/astroland-u03-experiment/tests/VisualTestHarness.qml"

TEST_WALLPAPERS = {
    "native": "/home/astro/Pictures/Wallpapers/wallhaven-k8d7j7.jpg",
    "4k": "/home/astro/Pictures/Wallpapers/1378781.png",
    "8k": "/home/astro/Pictures/Wallpapers/wallpaperflare.com_wallpaper_upscayl_3x_digital-art-4x.png",
    "9.6k": "/home/astro/Pictures/Wallpapers/test_upscayl_4x_digital-art-4x.png",
    "ultrawide": "/home/astro/Pictures/Wallpapers/wallhaven-lydkg2.jpg",
    "portrait": "/home/astro/Pictures/Wallpapers/test_portrait_2160x3840.png"
}

def render_capture(mode, wallpaper, prev_wallpaper="", progress=1.0, shader="pixelate", effect="none", output_path="/tmp/out.png"):
    env = os.environ.copy()
    env["TEST_MODE"] = mode
    env["TEST_WALLPAPER"] = wallpaper
    env["PREV_WALLPAPER"] = prev_wallpaper
    env["TEST_PROGRESS"] = str(progress)
    env["TEST_SHADER"] = shader
    env["TEST_EFFECT"] = effect
    env["OUTPUT_PATH"] = output_path
    
    cmd = ["qs", "-p", HARNESS_QML]
    proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, env=env, timeout=10)
    if proc.returncode != 0:
        print(f"Error rendering {output_path}: {proc.stderr}")
        return False
    return os.path.exists(output_path)

def compare_images(img_a, img_b, diff_img):
    # Run ImageMagick compare with RMSE metric
    cmd = ["magick", "compare", "-metric", "RMSE", img_a, img_b, diff_img]
    proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    # Output is in stderr: e.g. "124.5 (0.0019)"
    output = proc.stderr.strip()
    rmse_val = 0.0
    rmse_norm = 0.0
    try:
        parts = output.split()
        rmse_val = float(parts[0])
        rmse_norm = float(parts[1].strip("()"))
    except Exception:
        pass
    return {"output": output, "rmse_val": rmse_val, "rmse_norm": rmse_norm}

def main():
    results = {}
    
    print("=== SCENARIO 1: STATIC WALLPAPER FIDELITY & CLARITY ===")
    for name, wp in TEST_WALLPAPERS.items():
        unbounded_png = os.path.join(SCREENSHOT_DIR, f"{name}_unbounded.png")
        bounded_png = os.path.join(SCREENSHOT_DIR, f"{name}_bounded.png")
        diff_png = os.path.join(SCREENSHOT_DIR, f"{name}_diff.png")
        
        print(f"Rendering {name} (Unbounded)...")
        render_capture("unbounded", wp, output_path=unbounded_png)
        print(f"Rendering {name} (Bounded)...")
        render_capture("bounded", wp, output_path=bounded_png)
        
        cmp_res = compare_images(unbounded_png, bounded_png, diff_png)
        results[f"static_{name}"] = cmp_res
        print(f"  {name}: RMSE = {cmp_res['rmse_val']} (normalized: {cmp_res['rmse_norm'] * 100:.3f}%)")

    print("\n=== SCENARIO 2: SHADER TRANSITION ALIGNMENT & SEAMS ===")
    shaders = ["pixelate", "dissolve", "ripple", "Doom", "circlePit"]
    wp_from = TEST_WALLPAPERS["ultrawide"]
    wp_to = TEST_WALLPAPERS["8k"]
    for shader in shaders:
        unbounded_png = os.path.join(SCREENSHOT_DIR, f"shader_{shader}_unbounded.png")
        bounded_png = os.path.join(SCREENSHOT_DIR, f"shader_{shader}_bounded.png")
        diff_png = os.path.join(SCREENSHOT_DIR, f"shader_{shader}_diff.png")
        
        print(f"Testing transition shader '{shader}' (mid-progress 0.5)...")
        render_capture("unbounded", wp_to, prev_wallpaper=wp_from, progress=0.5, shader=shader, output_path=unbounded_png)
        render_capture("bounded", wp_to, prev_wallpaper=wp_from, progress=0.5, shader=shader, output_path=bounded_png)
        
        cmp_res = compare_images(unbounded_png, bounded_png, diff_png)
        results[f"shader_{shader}"] = cmp_res
        print(f"  Shader {shader}: RMSE = {cmp_res['rmse_val']} (normalized: {cmp_res['rmse_norm'] * 100:.3f}%)")

    print("\n=== SCENARIO 3: BLUR SAMPLES (FASTBLUR & GAUSSIANBLUR) ===")
    for effect in ["fastblur", "gaussianblur"]:
        unbounded_png = os.path.join(SCREENSHOT_DIR, f"effect_{effect}_unbounded.png")
        bounded_png = os.path.join(SCREENSHOT_DIR, f"effect_{effect}_bounded.png")
        diff_png = os.path.join(SCREENSHOT_DIR, f"effect_{effect}_diff.png")
        
        print(f"Testing effect '{effect}' on 8K image...")
        render_capture("unbounded", TEST_WALLPAPERS["8k"], effect=effect, output_path=unbounded_png)
        render_capture("bounded", TEST_WALLPAPERS["8k"], effect=effect, output_path=bounded_png)
        
        cmp_res = compare_images(unbounded_png, bounded_png, diff_png)
        results[f"effect_{effect}"] = cmp_res
        print(f"  Effect {effect}: RMSE = {cmp_res['rmse_val']} (normalized: {cmp_res['rmse_norm'] * 100:.3f}%)")

    report_path = os.path.join(SCREENSHOT_DIR, "visual_comparison_report.json")
    with open(report_path, "w") as f:
        json.dump(results, f, indent=2)
    print(f"\nVisual verification complete. Report written to {report_path}")

if __name__ == "__main__":
    main()
