# Live WuWa activation — 18 October 2026

The live personal configuration enables `appearance.wuwaTheme.enabled`, fixed Jinzhou palette, intensity 0.85 and Normal motion. Resource and concentric clock skins are `wuwa`. Only the enable flag and two skin values changed; existing palette/intensity/motion values were already correct. This personal configuration is deliberately outside Git. Backup: `~/.local/state/wuwa-resonance-20261018/activation/config-before.json`.

The user's report of low frame rate and intermittent/static Tacet was caused by phase 4's intentional power savings: ribbons slowed to 33ms with audio/83ms idle, and normal Tacet stopped without audio. The follow-up restores original 16ms/33ms ribbon cadence and continuous frame-driven Tacet with original bob, breath and aura loops in Normal mode. Ambient remains low rate; reduced/off/locked/hidden states stop animation. These safeguards remain in place. Earlier phase-4 performance observations describe the historical capped implementation.

Existing widget positions, instance IDs, dimensions, clock complications, wallpaper, desktop visualizer, media interactions, IslandFiller geometry/style and other settings remain unchanged. Pre-existing tracked dirty diffs and the untracked Android Tailscale widget were compared byte for byte with the original backup and match. Shader files and desktop visualizer source still match the original baseline.

Validation: production-source fixtures passed 10 theme assertions, 9 resource lifecycle/paint assertions, 12 clock rollover/pill/motion assertions and 31 bar lifecycle/mode/animation-target assertions. Qt6 parsed both changed QML files. Independent AGY review found no blocking issues or competing property drivers, and its separate 22-assertion runtime harness passed. Software/offscreen fixtures do not prove GPU appearance; separate live screenshots and recording assess actual rendering. No obvious clipping or opaque backgrounds appeared at the user's current 1920x1200, scale 1, clock size 110 and horizontal resource layout. The existing clock shadow anchor warning and tray DBus warnings are unrelated pre-existing diagnostics.

## Settings and remaining manual checks

- Settings → Colors & Themes → Resonance Theme (WuWa): enable, palette, intensity and motion.
- Settings → Desktop Widgets → Resource Styles → Resource Monitor (3-Card Array): WuWa skin.
- Settings → Desktop Widgets → Concentric Clock Options → Clock Skin: Chrono Resonator (WuWa).
- JSON: `~/.config/illogical-impulse/config.json`: `appearance.wuwaTheme`, `background.widgets.resources.style`, `background.widgets.concentric_clock.skin`.

Remaining manual checks: judge visual smoothness and gold/teal contrast on the physical display, exercise media clicks/scroll/seek and real music response, and check fullscreen/game, physical lock/unlock and any other monitors/scales. Synthetic motion gates and time rollovers passed; physical desktop interaction was avoided while the user was active. No claim of completely warning-free QML startup or controlled battery/GPU benchmarking is made.

## Live runtime and artifacts

Quickshell was safely restarted by targeting only the prior `end4-pC` instance. Fresh PID 199037 loaded successfully with one shell instance and one Cava reader. No new theme-related QML errors appeared during validation. Existing layout and all unrelated configuration values were retained. The theme and both skins remain enabled after all checks.

Private local artifacts, deliberately excluded from Git:

- `~/.local/state/wuwa-resonance-20261018/activation/desktop-wuwa-live.png`: full desktop captured briefly on empty workspace 99; original workspace restored.
- `~/.local/state/wuwa-resonance-20261018/activation/bar-wuwa-live.mp4`: approximately six seconds of the live bar at 60 capture fps, without audio. Tacet-region frame hashes differed in 354 of 355 frames, demonstrating actual rendered movement. This is not a physical-display frame-pacing benchmark.
- `~/.local/state/wuwa-resonance-20261018/activation/performance.json`: measurements below.

## Performance observations

Both profiles used the same freshly restarted shell with restored Normal motion, one 1920×1200 monitor at 165 Hz, existing applications and system audio. Each profile settled for five seconds, then ran for 60 seconds. Classic temporarily disabled the global theme and selected classic desktop skins; WuWa enabled all three. The script restored enabled WuWa settings in a `finally` block. No music playback, seeking or volume changes were made. NVIDIA utilization/power are whole-GPU readings sampled once per second, including other applications.

| Profile | Quickshell CPU, % of one core | Hyprland CPU, % of one core | GPU utilization average | GPU power average |
|---|---:|---:|---:|---:|
| Classic, restored Normal motion | 94.87 | 27.93 | 22.97% | 29.59 W |
| WuWa, restored Normal motion | 93.82 | 29.53 | 22.77% | 29.74 W |

No appreciable theme overhead was observed in these brief samples. This does **not** establish low idle consumption: smooth Normal motion is expensive on this 165 Hz desktop. The activated but still capped implementation sampled before restoration used 23.77% of one core for Quickshell. That pre-restoration sample had a different process age and was not a controlled isolated comparison, but the large increase is consistent with reinstating continuous original animations. Earlier pre-phase baseline observation was approximately 90.7% of one core, also under different session conditions. Ambient or Off remain available when lower power matters; Normal is left selected as explicitly requested.

The prior five implementation commits remain intact. Only the focused motion restoration and its documentation belong to the separate follow-up commit. Personal configuration and captures are not committed, and nothing is pushed.
