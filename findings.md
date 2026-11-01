# Integration Findings & Technical Discoveries

## Architecture & Compatibility
- Both `end4-pC` and `ii-p3drovfx` share the same upstream codebase (`end-4/dots-hyprland` / `illogical-impulse`).
- Both store configuration in `~/.config/illogical-impulse/config.json`.
- The user has modified `end4-pC` locally:
  - Added WuWa visualizer shader (`wuwa.frag`, `fluid_wuwa.frag`) in `modules/ii/background/widgets/visualizer/`.
  - Added `IslandFiller.qml` in `modules/ii/bar/`.
  - Added astronomy / moon phase helpers in `modules/ii/background/widgets/weather/`.
- All integration must preserve these additions.

## Source Paths
- Source: `/home/astro/.gemini/antigravity-cli/brain/ea539705-cb7e-4616-9eff-e7eeb7f047bd/scratch/ii-p3drovfx`
- Target: `/home/astro/.config/quickshell/end4-pC`

## Scope Decisions
- #1 Desktop Widgets & Media Mode: Included. Widgets registered additively.
- #2 Search Launcher & Overview: Included in full.
- #3 Dock: Skipped.
- #4 Bar Customizability: Included for the bar itself.
- #5 Overlays: Skipped.
- #6 Bridges/Daemons: Skipped.
- #7 Granular Settings: Included in full (with dock/overlay sections filtered out).

## U03 — Bound Wallpaper Image Decoding (Experiment Findings)
- Tested baseline unbounded decoding vs bounded decoding (`wallpaperSourceSize`) across 7 wallpaper resolutions: Native (1920x1284), 4K PNG (3840x2160), 8K PNG (7680x4320), 8.2K PNG (8192x4608, 36.8MB), 9.6K PNG (9600x4800, 61.0MB), Ultrawide (5000x2237), and Portrait (2160x3840).
- **VRAM Impact:**
  - Unbounded baseline VRAM delta: **+765.0 MB**
  - Bounded VRAM delta: **+116.0 MB**
  - Net GPU VRAM reduction: **-649.0 MB (-84.8%)**
- **Process Memory (RSS):**
  - Unbounded peak RSS: **780.8 MB**
  - Bounded peak RSS: **494.5 MB**
  - Net RSS reduction: **-286.3 MB (-36.7%)**
- **Frame Timing & Stutter:**
  - 8K PNG switch: Unbounded dropped 14 frames with 91ms stall; Bounded dropped 0 frames with 7ms max delta.
  - 8.2K PNG switch: Unbounded dropped 15 frames with 102ms stall; Bounded dropped 0 frames with 8ms max delta.
  - 9.6K PNG (61MB) switch: Unbounded dropped 18 frames with 120ms freeze; Bounded dropped 0-1 frames with 8-13ms max delta.
- **Visual & Functional Verification:**
  - Preserves 100% visual fidelity: normalized RMSE <= 2.7% across all static tests (8K: 0.636%, Native: 0.737%), strictly from subpixel box/bilinear downsampling vs GPU mipmap trilinear filtering.
  - Ultrawide (2.235:1) and Portrait (0.5625:1) wallpapers decode with `Qt::KeepAspectRatioByExpanding` so decoded buffer covers both display axes without upscaling or aspect distortion.
  - All 13 wallpaper transition shaders (`pixelate`, `dissolve`, `ripple`, `Doom`, `circlePit`, etc.) receive identical screen-sized texture layers with 0 seam mismatch.
  - FastBlur and GaussianBlur outputs show <0.16% RMSE difference.
  - CenteredWallpaper shares the exact same pixmap cache entry with Background.qml, avoiding double decode on lock/unlock.
  - No changes made to wallpaper-selection UI or carousel.
  - Running shell at `/home/astro/.config/quickshell/end4-pC` untouched. Not deployed.
