# WuWa Resonance validation — 2026-10-18

Implemented all five prompt-pack phases in the live `end4-pC` configuration on
`my-setup`. Local checkpoints: `2935ab0` (foundation), `f342243` (resources),
`5f55aaa` (clock), `23648b8` (bar). No upstream sync or push was performed.

## Activation and defaults

The final desktop retains **classic resource/clock skins and the disabled global
theme**. Positions, widget size, blur, transparency and bar layout were restored.

| Native setting | Persistent option | Choices |
|---|---|---|
| Colors & Themes → Resonance Theme (WuWa) | `appearance.wuwaTheme.enabled` | Off by default; opts bar/media into the palette |
| Same section: palette / intensity / motion | `appearance.wuwaTheme.{paletteMode,intensity,motionMode}` | `fixed` / `theme`; 0–1; `normal` / `ambient` / `off` |
| Desktop resource styles → Resource Monitor (3-Card Array) → Card Style | `background.widgets.resources.style` | `classic` / `wuwa` |
| Concentric Clock Options → Clock Skin | `background.widgets.concentric_clock.skin` | `classic` / `wuwa` |

Desktop skins opt in independently. Palette and motion controls remain available
with the global toggle off. `Appearance.reducedMotion` takes precedence.
The personal settings file is `~/.config/illogical-impulse/config.json`; it was
backed up privately and never committed.

## Architecture and preservation

`Config` stores typed `JsonObject` defaults. `ResonanceTheme` exposes fixed Jinzhou
or wallpaper-adaptive semantic colors, typography, intensity and motion flags.
It consumes existing `Appearance`/`ColorUtils` without changing global Material
tokens. Quickshell discovers the singleton through its existing module mapping.

Resource cards consume the existing `ResourceUsage` service. The optional skin
keeps three cards, with CPU and GPU temperatures together; missing temperatures
display `--`, and warnings start strictly above 75°C. The CPU trace repaints on
metric/palette changes and stops while hidden or paused. No resource poller was
added. Loader offsets preserve wallpaper sampling in both orientations.

The clock retains the existing blur, dial styles, capsule mask and one rotating
dial animation. Its existing local seconds clock now supplies hour, minute and
second values consistently. Ambient/off motion uses accurate second steps.
The etched ring is static; the original transparency slider remains effective.

The bar retains its gap/span calculations, all nine filler styles, Tacet SVG,
shader uniforms and MPRIS input handlers. Its selected legacy `Media.qml` passes
its playback state to the Tacet component. Four perpetual animations and the
unconditional Tacet frame ticker were replaced with conditional timers. Filler
timer intervals are 83 ms idle, 33 ms with audio, and 125 ms ambient. These are
timer rates, not measured GPU frame rates. Hidden windows, lock/reduced motion
and motion-off stop decorative work; motion-off also freezes audio uniforms.

Shader source/binaries, desktop visualizer adaptive governor, service edits,
sidebar/Tailscale work, wallpaper and placement machinery remain unchanged.

## Checks and evidence

Evidence and runnable fixtures are local under
`~/.local/state/wuwa-resonance-20261018/`. Fixtures load current production QML,
substituting platform/service boundaries; they do not reproduce widget logic.

The exact fixture commands (from any directory) are:

```sh
wuwa_evidence_dir="$HOME/.local/state/wuwa-resonance-20261018"
python3 "$wuwa_evidence_dir/check-theme.py"
python3 "$wuwa_evidence_dir/check-resources.py"
python3 "$wuwa_evidence_dir/check-clock.py"
python3 "$wuwa_evidence_dir/check-bar.py"
```

| Check | Result |
|---|---|
| `/usr/lib/qt6/bin/qmlformat` on all 13 changed QML files | Parse pass |
| `/usr/lib/qt6/bin/qmllint --json …` | Ran; dynamic `qs.*` imports leave unresolved-type/property diagnostics, so this is not a clean semantic-lint claim |
| `python3 …/check-theme.py` | 10 assertions: fixed/theme colors, light/dark pairing, invalid intensity, motion fallbacks |
| `python3 …/check-resources.py` | 9 assertions: normalization, missing/hot sensors, actual Canvas palette redraw, pause/hide/resume |
| `python3 …/check-clock.py` | 12 assertions: 11:59:58→12:00:02, midnight/12–24h, stepped rotation, capsule scaling, pause/resume |
| `python3 …/check-bar.py` | 22 assertions: playback/idle, motion/lock, hidden window, invalid audio, gap/span and nine legacy styles |
| Separate AGY review conversation | No important source findings; reran the 53 assertions and exercised the ring Canvas |
| Live Wayland captures | Both resource orientations; clock sizes 80/100/125 with normal/ambient/off motion; later seconds capture |
| `live-bar-styles.py` | All nine styles rendered on native graphics backend; zero new relevant shader/bar error lines |
| Targeted restart | Old PID 2056 exited; `qs -c end4-pC -n -d` started PID 172879; one shell and one Cava process |
| Persistence/opt-out | Saved theme flags and classic skins survived startup; original geometry/settings restored |
| `git diff --check`, shader/governor comparison, original user diff comparison | Pass |

The Colors & Themes page opened without new errors. Screenshots remain private,
including `resources-horizontal.png`, `resources-vertical.png`,
`chrono-80-normal.png`, `chrono-100-ambient.png`, `chrono-125-off.png`,
`chrono-off-later.png` and `bar-live-*.png`.

No shader rebuild was necessary: `.frag` and `.qsb` files match the baseline.
The installed compiler is `/usr/lib/qt6/bin/qsb` 6.12.0. If subsequently changing a
fragment, use the repository's build convention and verify reflection/loading:

```sh
/usr/lib/qt6/bin/qsb --glsl "100 es,120,150" --hlsl 50 --msl 12 -o file.frag.qsb file.frag
```

## Performance observations

Each row samples 60 seconds from the same fresh Quickshell process using
`measure.py` / `benchmark.py`. CPU percentages are **one-core equivalents**.
RSS is the endpoint in MiB. Playback used muted Spotify to avoid audible
interruption; its saved position, volume and paused state were restored.

| Profile | Quickshell CPU | QS RSS | Hyprland CPU | NVIDIA GPU utilization, start→end |
|---|---:|---:|---:|---:|
| Classic, MPRIS paused | 29.53% | 848.8 | 27.20% | 17→16% |
| WuWa, MPRIS paused | 24.87% | 848.5 | 27.82% | 15→16% |
| WuWa, muted playback | 30.33% | 854.6 | 27.23% | 18→16% |
| Classic, muted playback | 28.20% | 859.9 | 35.43% | 16→16% |

These samples show no significant regression, but they are observational:
system audio, voice activity and other apps were uncontrolled. Paused MPRIS is
not proof of a silent idle desktop; muted playback is not a bass-heavy audio
stress test. GPU values cover the entire RTX 5060 Laptop GPU, not Quickshell
alone. Endpoint power readings ranged roughly 21–25 W; no GPU savings claim is
made. RSS stayed around 849–860 MiB during the sequence.

An earlier pre-change paused-media sample measured 90.70% QS CPU and about
1.35 GiB RSS. It used a long-running process, so restart/session differences
prevent attributing that entire difference to these changes.

## Remaining limits and existing warnings

- One connected 1920×1200 display at compositor scale 1. Widget scaling was
  exercised; fractional compositor scaling and multiple monitors remain manual.
- Physical drag/touch, full keyboard navigation, vertical bar layouts, fullscreen
  gaming, lyrics/seek/track-change interactions and complication hardware
  combinations remain manual. Their existing handlers/providers were preserved;
  decorative ring items are disabled for input, and cards add no pointer handler.
- Startup retains the existing `StyledDropShadow` anchor warning in
  `ConcentricClockWidget.qml` (the shadow block is identical to the baseline).
  No new import/type/shader errors were found for the changed components.
- A shared bar clock stalled during hot-reload testing and resynced through the
  existing precision preference. After fresh startup, captures advanced
  correctly across the performance sequence. Future hot reloads merit a time
  sanity check; the desktop clock now uses its existing local seconds clock.

## Rollback

For a visual rollback, disable the global theme and select both classic desktop
skins—the final saved state already does this. Review current edits before any
code rollback. Revert only the task's commits in reverse order, or inspect and
restore individual task files from the private archive; do not reset the tree.

Private backups: `project-before.tar.gz`, `personal-config-before.json`,
`preexisting.diff` and `preexisting-status.txt` under the evidence directory.
For settings rollback, restore only the relevant keys after comparison; replacing
the entire personal JSON could discard newer preferences. Keep private paths,
account settings and screenshots out of commits.

## Exact source files changed

```text
modules/common/Config.qml
modules/common/ResonanceTheme.qml
modules/settings/configs/ColorsThemesConfig.qml
modules/settings/configs/widgets/DesktopResourceStylesConfig.qml
modules/settings/configs/widgets/DesktopConcentricClockConfig.qml
modules/ii/background/widgets/resources/ResourcesWidget.qml
modules/ii/background/widgets/resources/ResonanceStatCard.qml
modules/ii/background/widgets/clock/ConcentricClockWidget.qml
modules/ii/background/widgets/clock/concentric/ConcentricDialCanvas.qml
modules/ii/background/widgets/clock/concentric/ResonanceRing.qml
modules/ii/bar/IslandFiller.qml
modules/ii/bar/Visualizer.qml
modules/ii/bar/Media.qml
```

Documentation: `docs/wuwa-resonance-theme.md`, this report, and the three task
tracking files under `docs/wuwa-work/`. Earlier root planning files were retained.
