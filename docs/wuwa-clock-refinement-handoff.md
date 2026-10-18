# WuWa Chrono Resonator — continuation handoff

## Current state

Clock-only v2 refinement is implemented and visually accepted by Codex. Final AGY visual confirmation completed; independent review completed without blocking findings. Do not resume resource/bar/performance work.

Live installation: /home/astro/.config/quickshell/end4-pC, branch my-setup. Baseline commit0163f28 and the earlier five phase commits remain intact. The completion commit is the commit that introduces this handoff; locate it with:
git log -1 --format='%h %s' -- docs/wuwa-clock-refinement-handoff.md
No push was performed.

One safe clock-only restart completed: PID366121 →464443, one Quickshell instance and one Cava reader. Discover the current PID by config path before any future IPC/restart. Actual shell: /home/astro/.config/quickshell/end4-pC/shell.qml.

Global WuWa theme remains enabled/fixed/intensity0.85/Normal, clock skin WuWa. Active instance concentric_clock-mvais4d6-len4 remains x1476,y168,size110 (264px). Legacy clock enable:false remains false. All personal setting values equal the v2 preflight snapshot; all pre-existing nonclock dirty-file hashes match. Earlier uncommitted resource/bar work, wallpaper, visualizer, media and other user edits were preserved and are excluded from this commit.

## Architecture and completed changes

- WuWa defaults to true12-hour time through a separate wuwaUse24h:false schema preference. Classic use24h:true remains unchanged. AM/PM follows real hours and is hidden in WuWa24h mode.
- Hour ink is centered at0.50D independently of the capsule, with TextMetrics bearing correction only for WuWa. Current font preferences remain; WuWa size is capped at26% of diameter. Capsule x0.68D,width0.25D,height0.14D shares hour centerline y0.46D, with dominant minutes and smaller seconds.
- Stationary cardinal/tick/inner-arc structure is separate from the moving numeral track. Twelve upright Text glyphs orbit at0.74R, counter-rotated under the existing single wall-clock-synced FrameAnimation. No new animation driver or timing policy. Whole glyphs fade before intersecting the capsule exclusion box; the40° clipped-05 defect was reproduced, corrected, rendered and viewed. Hidden capsule restores all numeral visibility.
- AM/PM occupies the upper inner dial at(0.50D,0.285D), framed by separated decorative arc wings.
- Real weather comes from existing Weather.data.temp/description, preserving units,0°C and missing-data fallback. A service-free Canvas curves the annotation along the lower inner circumference at radius0.266D, maximum100° span. Measured glyph widths preserve temperature and elide long conditions. Common combining marks/variation selectors/ZWJ sequences are grouped. Weather/battery/none choices remain; complex RTL joining is unverified.
- Local glass uses a central feather and an elliptical wing behind/beyond the capsule, affecting only background blur/fallback. Existing FastBlurred is reused through an instance mask override; the shared component is unchanged. WuWa tint maps sqrt(1-transparency) times intensity, respecting transparent endpoints. Classic tint retains its original1-transparency mapping.
- Functional numerals, AM/PM and weather retain ivory contrast independently of the glass mask; decorative gold strokes remain restrained. Fine outer arc/tick alpha was raised after inspecting bright-background evidence. No resource/bar source or animation cadence changed in this pass.

Changed source files (relative to repo):

- modules/common/Config.qml — only the new clock preference.
- modules/settings/configs/widgets/DesktopConcentricClockConfig.qml — active-face24-hour switch and WuWa alias handling.
- modules/ii/background/widgets/clock/ConcentricClockWidget.qml
- modules/ii/background/widgets/clock/concentric/ResonanceClockGeometry.qml
- modules/ii/background/widgets/clock/concentric/ConcentricHourDisplay.qml
- modules/ii/background/widgets/clock/concentric/ConcentricMinutePill.qml
- modules/ii/background/widgets/clock/concentric/ConcentricDialCanvas.qml
- modules/ii/background/widgets/clock/concentric/ResonanceRing.qml
- modules/ii/background/widgets/clock/concentric/ResonanceWeatherArc.qml
- modules/ii/background/widgets/clock/concentric/ConcentricComplication.qml — earlier clock-only real-temperature/zero-value integration retained.

## Actual visual evidence and verification

Evidence root: /home/astro/.local/state/wuwa-clock-v2-20261018/

All six references in /home/astro/Downloads/wuwa_clock_refinement_v2/references/ were actually viewed before changes. Primary design02, AM/PM03, weather arc04, real desktop05. Complete master prompt: CODEX_CLOCK_ONLY_PROMPT.md in that kit.

- before-clock.png / before-desktop.png: real pre-v2 state.
- final-clock.png / final-desktop.png: real live result after safe restart, captured20:55, explicitly opened and viewed by implementing AGY and Codex.
- before-after-clock.png: actual264px crops at1:1, with no rescaling.
- stage1-native-*.png and stage1-cutout-*.png: boundary-time geometry and capsule-entry evidence. Native actual-source mocked-time suite:15 cases,180 assertions;00:00AM,12:01PM,13:09PM,18:53PM,23:59PM. Stage1 previews were192/240/312px plus the actual264px live crop. Additional cardinal/oblique phases included the failing40° cutout and its correction. Representative images were actually viewed by both agents.
- stage2-weather-s*.png:15 native weather cases,114 assertions, actual211/264/343px (80/100/130% of live size); clear, rain, long storm, Latin accents, missing data and0°C. Curved text/clearance were actually viewed by both agents. This is separate from timekeeping validation.
- stage3-glass-s*.png:12 current native composited cases across211/264/343px, bright/dark backgrounds, real FastBlurred and fallback. Strict Classic tint parity passes.
- stage3-mask-diagnostic.png: raw264px mask; pixel(250,121), beyond capsule right edge245.52, has alpha66; pixel(262,121) and outside corner(10,10) have alpha0. Native images, mask and real live result were actually viewed by implementing AGY and Codex.
- All10 changed QML files parse with installed Qt6 qmlformat. git diff --check passes. Fresh live logs contain no new clock type/reference/shader errors. Pre-existing StyledDropShadow non-parent anchor warning remains; logs are not claimed entirely warning-free.
- settings-preserved.json and final-runtime.json record preservation and operational checks. No CPU/GPU/FPS/power benchmarks were run in this clock-only pass.

Initial Stage3 transparent previews were rejected: they omitted the backdrop and used an empty blur stub. The corrected current stage3-glass-check.py uses the real blur component and composited backdrop. Its two mechanical harness errors (overbroad ID replacement and wrong diagnostic size) were fixed before acceptance. Do not cite rejected previews as contrast proof.

Independent review: Completed read-only source and image review; no blocking issues found. The reviewer reran the current12-case/98-assertion glass harness, inspected final live/bright/dark images and primary reference, and reported remaining hardware/session coverage limits. Raw report: /home/astro/.local/state/codex-agy/runs/9a1b371628d418a8d97af2e2/20261018T153329Z-b78b8029/worker-response.md. Its multiline header was not accepted by the wrapper parser; Codex read the complete report and independently verified its relevant evidence. Source geometry above is authoritative.

## Settings

Settings → Desktop Widgets → Concentric Clock Options →24-Hour Format now controls the selected face's preference. WuWa key: background.widgets.concentric_clock.wuwaUse24h; Classic key remains use24h. Existing Clock Skin, Appearance blur/transparency, font and optional subdial controls remain.

No personal config replacement is needed. The new WuWa preference defaults tofalse until changed through the existing switch.

## Remaining manual checks / limits

No known visual blocker remains in the inspected live/default layout. Physical password lock/unlock, drag/resize, suspend/resume, multi-monitor/fractional display scaling and subjective contrast/motion on the physical display remain manual. Long conditions intentionally elide; complex bidirectional/RTL shaping is not verified. Native mocked-time previews do not change system time or replace these hardware/session checks.

## Continue in AGY without rediscovery

Read this handoff and the kit master prompt first. Use the exact files/evidence above; do not scan the whole repository or resume deferred work. Main persistent conversation21a09212-1d2c-4e67-aafa-56021ac8c92d; independent review443737ef-1c14-4d86-ab4d-d7c4c75e421d. Wrapper: /home/astro/.agents/skills/agy-subagent/scripts/agy-subagent.py, chat wuwa-resonance-20261018-root, project live repo.

Current reusable native harness: private stage3-glass-check.py. Stage1/2 scripts were stage-specific; do not blindly rerun them against new components/masks without copying the new types and restoring all GPU masks. Never use the old empty native-clock-fixture.qml.

Private capture-clock.py LABEL briefly focuses workspace99 with the correct Hyprland Lua dispatch, asserts it, captures the actual clock and restores the previous workspace in finally. Legacy dispatch workspace99 is unsupported here. Pure qml6 previews use mocked services, not another Quickshell/Cava instance.

Private restart-clock-only.py performs only the safe operational restart. Do NOT use the older broad-project final-restart.py, which launches prohibited benchmarks.

Pre-v2 source/config checkpoint, unrelated hashes and source diff are retained in the evidence root. Restore only owned clock files if necessary; never overwrite the complete live tree or personal config. The completion commit can be reverted separately after preserving subsequent edits.
