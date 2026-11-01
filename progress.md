# Progress Log

## Phase 1: Architecture Mapping & Setup
- [x] Full timestamped directory backup created at `~/.config/quickshell/end4-pC-backup-20261006_160051`.
- [x] Dedicated git branch `integrate-vynx-features` created from `my-setup` with base backup tag `backup-pre-snatch`.
- [x] Initialized Manus-style planning files (`task_plan.md`, `findings.md`, `progress.md`).

## Phase 7: In-Sidebar Drag-to-Send Phone File Bridge
- [x] Implemented `scripts/phone/phone_file_bridge.py` backend helper for ADB directory listing, folder creation, fast pushing, and MediaScanner broadcast.
- [x] Implemented `services/PhoneFileBridgeService.qml` singleton managing ADB transfers, directory exploration, and KDE Connect fallback.
- [x] Implemented `modules/ii/sidebarPolicies/phone/PhoneFileBridge.qml` with 4 main drop zones, hover sub-zones (Direct Copy and + New Folder), Zone 5 internal storage traversal (single-click select, double-click navigate, Use button), and fluid animations.
- [x] Integrated `PhoneFileBridge` into `modules/ii/sidebarPolicies/phone/Phone.qml`.
- [x] Verified zero errors/warnings in QML logs and verified live push + media scanner on OnePlus Nord CE5.

## Phase 8: U03 Wallpaper Image Decode Optimization Experiment
- [x] Benchmarked baseline unbounded vs bounded decode across native (1920x1284), 4K, 8K, 8.2K (36.8MB), 9.6K (61MB), ultrawide (5000x2237), and portrait (2160x3840) wallpapers on NVIDIA RTX 5060 + OpenGL QRhi backend.
- [x] Measured 649 MB VRAM reduction (84.8%) and 286 MB RSS reduction (36.7%).
- [x] Eliminated transition frame drops on oversized wallpapers (from 18 dropped frames / 120ms freeze down to 0-1 dropped frames / 8-13ms delta).
- [x] Verified zero visual/crop/blur/shader regression across all 13 transition shaders, FastBlur, GaussianBlur, and dual visualizers.
- [x] Verified `CenteredWallpaper.qml` shares pixmap decode with `Background.qml`.
- [x] Recorded real 165Hz transition video (`screenshots/u03_eval/wallpaper_transition_demo.mp4`) and inspected extracted transition frames.
- [x] Kept experiment on isolated branch `u03-wallpaper-decode-experiment` in `/home/astro/repos/astroland-u03-experiment`; running shell untouched. Ready for review.
