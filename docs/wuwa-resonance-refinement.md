# WuWa Resonance visual refinement

This pass refines the live `end4-pC` configuration on top of `0163f28`. It preserves the five implementation commits, activation fix, wallpaper, widget geometry, custom preferences, media/visualizer behavior, and unrelated working-tree edits. No personal settings or screenshot data belongs in this commit. No push was performed.

## Root causes and changes

- **Chrono Resonator:** rotating glyph bounds previously intersected stationary strokes, while the open capsule extended into the outer instrument track. `ResonanceClockGeometry.qml` supplies shared geometry: cardinal diamonds at .95R, ornament track .92R, fixed ticks beginning .86R, a single rotating numeral orbit .74R, and quiet ring .60R. The closed minute/seconds capsule occupies the inner east sector; its existing mask only runs when the capsule is shown. Four cardinal diamonds, a small caption and static frequency signature follow prototype05. Real weather is bounded/elided; zero degrees remains valid. Existing timekeeping, preferences, rotation/resync and Classic face remain available. WuWa rotation and the bounded hourly pulse respect window visibility, screen lock, fullscreen and motion settings.
- **Resonance Monitor:** implicit widths previously made the two thermal columns asymmetric. Equal-width columns now share font fitting and baseline geometry, with a centered divider and real temperature gauges. CPU history, actual RAM usage and compact responsive ornamentation retain the 132×120 card footprint. Header icons hide at constrained widths; labels elide. Missing temperatures display `--`.
- **IslandFiller:** WuWa applied redundant idle attenuation (`.45 × intensity`) on top of the existing opacity/falloff, while a dark teal tertiary color dulled strands. Warm ivory/sage RGB bindings and the original configured opacity restore gold/ivory luminosity. Shader premultiplication was already correct. Shader sources/binaries, Tacet code, Normal cadence, Cava and media behavior are unchanged.

Modified implementation files: `ConcentricClockWidget.qml`, `concentric/{ResonanceClockGeometry,ConcentricDialCanvas,ConcentricMinutePill,ConcentricComplication,ResonanceRing}.qml`, `resources/ResonanceStatCard.qml`, and `bar/IslandFiller.qml` under `modules/ii/background/widgets` / `modules/ii/bar`.

## Visual evidence and focused validation

Private evidence root: `/home/astro/.local/state/wuwa-refinement-20261018/`. All six supplied references were inspected before editing; prototype05 governed clock hierarchy, reference04 exposed overlap, and reference06 governed ribbon luminance. Generated boards were directional. Actual screenshots preserve the wallpaper and positions, rather than substituting concept art.

- `before-*.png`: live pre-refinement desktop and native-size clock/thermal/resource/bar crops.
- `native-clock-*-s*-a*.png`: 34 native GPU captures using the actual clock source with mocked boundary services, real OpacityMasks, four scales (80/100/130/150%), eight rotation angles, representative digit widths, and 23:59→00:00. Completion image and nonblank-image checks guard against silently blank rendering. These exercise actual displayed hours/minutes/seconds, including zero-degree and long-description weather cases.
- Clock source fixture: 850 geometry/time/state assertions passed. Its software images bypass GPU masks; the separate native captures validate those masks.
- Thermal fixture: 128 assertions across four sizes and four sensor pairs, including `--`/99°C/100°C. Actual text centers, font fit and baselines checked. Resource lifecycle/paint fixture: nine checks; existing resource lifecycle contract: five tests.
- Actual-source bar fixture: 31 checks, including paused Normal motion, nine filler styles, gap geometry, hidden/reduced/locked/off gates and resume transitions. Native Tacet pixel comparisons confirm motion in Normal and Ambient, static Off. Both palettes and Classic/WuWa round trips were captured and visually inspected.
- Live Quickshell MPRIS pause/resume verified with temporarily muted playback; paused state, position and volume restored. Widget lock setting round trip passed; no physical drag was synthesized. A temporary native fullscreen window entered/exited fullscreen, and the shell resumed. Actual password screen locking remains manual.
- Installed Qt6 parser validates the edited QML. Both existing shaders compile with the installed `qsb` into private temporary outputs; original shader files remain unchanged.

The combined old media/resource test invocation has two pre-existing errors referencing missing `modules/ii/bar/BarComponent.qml`, also absent at `0163f28`. It is not reported as an all-tests pass. Full `qmllint` semantic validation is limited by Quickshell's runtime imports; native rendering and focused assertions provide the operational evidence.

## Performance

Pending final retained rendering experiment and comparable samples. Normal animation cadence is never reduced as an optimization. CPU percentages refer to **one CPU core**, GPU readings to the **whole GPU**, including Hyprland and other applications. Measurements are observational; they do not claim exclusive GPU attribution or frame-time profiling.

## Settings and manual checks

Settings → Colors & Themes → Resonance Theme (WuWa): enable, fixed/theme palette, intensity and Normal/Ambient/Off motion. Desktop Widgets → Resource Styles → Resource Monitor selects WuWa/Classic. Desktop Widgets → Concentric Clock Options → Clock Skin selects WuWa/Classic; existing time/font/subdial controls still apply.

Persisted keys in `~/.config/illogical-impulse/config.json`:

- `appearance.wuwaTheme.{enabled,paletteMode,intensity,motionMode}`
- `background.widgets.resources.style`
- `background.widgets.concentric_clock.skin` (instance geometry remains in `background.widgets.activeWidgets`)
- `bar.islandFiller.opacity` (existing ribbon opacity; no new setting)

Final state: enabled, fixed palette, intensity0.85, Normal motion, both WuWa skins. Legacy clock `enable:false` remains false; the active widget instance supplies the visible clock. All personal setting values are compared with the saved preflight configuration after temporary tests.

Remaining manual checks: physical drag/resize with the preferred pointer, password lock/unlock, multiple monitors or fractional display scaling, long sessions across suspend/resume and a real hourly boundary, and subjective motion/contrast on the physical display. Native simulated times/scales and state fixtures cover geometry and gates; they do not replace those hardware/session checks. No multi-monitor hardware was attached.

## Rollback

The focused refinement commit can be reverted independently after saving subsequent user edits. Source-only preflight copies are also retained under `.git/wuwa-refinement-checkpoints/20261018/`; private project/settings backups are under the evidence root. Restore only explicitly owned source files if using the checkpoint. Do not extract a whole archive over the live tree or replace personal `config.json`; unrelated edits must remain intact. Classic skins and theme Off remain reversible through Settings.
