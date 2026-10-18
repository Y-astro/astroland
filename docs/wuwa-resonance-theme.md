# Jinzhou Resonance Theme Specification & Token Guide

This document defines the architectural tokens, semantics, configuration bindings, and consumption patterns for the **Wuthering Waves (WuWa) × Hyprland: Jinzhou Resonance Terminal** theme foundation.

---

## 1. Visual Direction & Hierarchy

The visual identity is modeled as an in-universe **Jinzhou Resonance Terminal**:
- Dark translucent teal glass (`#142826`)
- Antique-gold hairline accents (`#C9A66E`)
- Warm-ivory numeric and high-contrast typography (`#F3DBAC`)
- Misty sage technical labels and secondary borders (`#A5B8AF`)
- Thermal warning and sensor threshold alert orange (`#D17C55`)

**Visual hierarchy rules**:
1. **Wallpaper** is always the primary visual canvas; widgets must remain airy and translucent without blocking sunset or vibrant backdrop details.
2. **Clock** serves as the anchor focal instrument on desktop.
3. **Metrics Array** (3-card HUD) provides discrete, quiet telemetry without flashing or cartoon-like rounded cards.
4. **Harmonic Bar** fills dead space with sinuous frequency strands that taper gently into floating island pills.

---

## 2. Palette Specification

### Fixed Jinzhou Palette

| Token Name | Hex Code | RGB | Role / Usage |
|---|---|---|---|
| `fixedTealInk` | `#142826` | `rgb(20, 40, 38)` | Deep translucent glass backing, dark ink fill |
| `fixedMistySage` | `#A5B8AF` | `rgb(165, 184, 175)` | Technical labels, secondary ticks, muted dividers |
| `fixedAntiqueGold` | `#C9A66E` | `rgb(201, 166, 110)` | Hairline borders, active orbital rings, frequency crests |
| `fixedWarmIvory` | `#F3DBAC` | `rgb(243, 219, 172)` | Primary numerals, central time text, metric values |
| `fixedThermalOrange` | `#D17C55` | `rgb(209, 124, 85)` | High load alerts, thermal threshold (>75°C), warnings |

### Theme-Adaptive Mode

When `paletteMode` is set to `"theme"`, colors are automatically derived from the active wallpaper via Matugen / `Appearance.colors`:
- `themeTealInk`: `Appearance.colors.colLayer0`
- `themeMistySage`: `Appearance.colors.colSecondary`
- `themeAntiqueGold`: `Appearance.colors.colPrimary`
- `themeWarmIvory`: `Appearance.colors.colOnLayer0` (semantic paired foreground for `colLayer0` glass, ensuring reliable light and dark contrast)
- `themeThermalOrange`: `Appearance.m3colors.m3error` / `colError`

---

## 3. Configuration Schema

Preferences are persisted in `~/.config/illogical-impulse/config.json` under `appearance.wuwaTheme`:

```json
{
  "appearance": {
    "wuwaTheme": {
      "enabled": false,
      "paletteMode": "fixed",
      "intensity": 0.85,
      "motionMode": "normal"
    }
  }
}
```

### Options Description

| Key | Type | Default | Values | Description |
|---|---|---|---|---|
| `enabled` | `bool` | `false` | `true`, `false` | Global theme activation for bar and shell accents. (Widgets can opt-in independently via widget skin preferences). |
| `paletteMode` | `string` | `"fixed"` | `"fixed"`, `"theme"` | `"fixed"` uses authentic Jinzhou hexes; `"theme"` uses Matugen wallpaper colors. |
| `intensity` | `real` | `0.85` | `0.0` .. `1.0` | Clamped multiplier for glass alpha and hairline border contrast. |
| `motionMode` | `string` | `"normal"` | `"normal"`, `"ambient"`, `"off"` | Animation gating. Automatically forced to `"off"` when `Appearance.reducedMotion` is true. |

---

## 4. Consuming the `ResonanceTheme` Singleton

The singleton is registered under `qs.modules.common.ResonanceTheme` and is automatically available in all components importing `qs.modules.common`:

```qml
import QtQuick
import qs.modules.common

Rectangle {
    // Glass surface with theme intensity
    color: ResonanceTheme.bgGlass
    radius: 12

    // Hairline border
    border.color: ResonanceTheme.borderHairline
    border.width: 1

    StyledText {
        anchors.centerIn: parent
        text: "24°C"
        color: ResonanceTheme.textPrimary
    }
}
```

### Key Semantic Properties

- **Surfaces**:
  - `ResonanceTheme.bgGlass`: Default glass fill (`colTealInk` at `0.72 * intensity`)
  - `ResonanceTheme.bgGlassElevated`: Higher contrast glass fill (`0.85 * intensity`)
  - `ResonanceTheme.bgGlassSubtle`: Low opacity veil (`0.40 * intensity`)
- **Borders**:
  - `ResonanceTheme.borderHairline`: Delicately visible gold hairline (`0.35 * intensity`)
  - `ResonanceTheme.borderAccent`: High-visibility gold outline (`0.65 * intensity`)
  - `ResonanceTheme.borderSubtle`: Sage divider line (`0.20 * intensity`)
- **Typography**:
  - `ResonanceTheme.textPrimary`: Warm ivory for main readouts
  - `ResonanceTheme.textSecondary`: Sage for labels and unit markers
  - `ResonanceTheme.textTertiary`: Muted sage for secondary descriptions
  - `ResonanceTheme.textAccent`: Gold for highlights
  - `ResonanceTheme.textWarning`: Thermal orange for alerts
- **Typography Scale**:
  - `ResonanceTheme.fontMetricValue` / `metricValue`: Primary telemetry readout and clock numeral size (`23` px, mapping to `Appearance.font.pixelSize.hugeass`)
  - `ResonanceTheme.fontMetricSubValue` / `metricSubValue`: Secondary readouts and metric units (`17` px, mapping to `Appearance.font.pixelSize.large`)
  - `ResonanceTheme.fontDetailText` / `detailText`: Sensor descriptions and card labels (`15` px, mapping to `Appearance.font.pixelSize.small`)
  - `ResonanceTheme.fontTechnicalLabel` / `technicalLabel`: Compact technical badges and frequency identifiers (`12` px, mapping to `Appearance.font.pixelSize.smaller`)
  - `ResonanceTheme.fontMicroBadge` / `microBadge`: Micro tags and index indicators (`10` px, mapping to `Appearance.font.pixelSize.smallest`)
- **Motion Helpers**:
  - `ResonanceTheme.effectiveMotionMode`: `"normal"` | `"ambient"` | `"off"` (honors `Appearance.reducedMotion`)
  - `ResonanceTheme.motionNormal`: `true` only if full motion is allowed
  - `ResonanceTheme.motionAmbient`: `true` for calm ambient pulses
  - `ResonanceTheme.motionOff`: `true` if motion should be completely frozen
- **Utility Method**:
  - `ResonanceTheme.alpha(color, real)`: Safe alpha helper returning `Qt.rgba` clamped between `0.0` and `1.0`.

---

## 5. Settings Integration

Controls are placed directly in the native Settings window under:
**Settings -> Colors & Themes (`modules/settings/configs/ColorsThemesConfig.qml`) -> "Resonance Theme (WuWa)"**:
- **Enable Jinzhou Resonance theme**: Toggle switch activating global theme for opted-in bar and media elements (desktop widgets can opt in independently).
- **Palette mode**: Segmented choice between Fixed Jinzhou and Theme Adaptive (available independently of global toggle).
- **Motion mode**: Normal, Ambient, Off (indicates when reduced motion is forced by system).
- **Theme intensity**: Subtle (60%), Restrained (85%), Vivid (100%).

---

## 6. Tooling & Verification

- **Qt6 Toolchain**: Verification and formatting for components utilizing modern QML pragmas (`pragma ComponentBehavior: Bound`) must use the Qt6 binaries at `/usr/lib/qt6/bin/qmlformat` and `/usr/lib/qt6/bin/qmllint` (Qt 6.12.0). The legacy binaries at `/usr/bin/` are Qt5 and do not recognize Qt6 syntax.
- **Syntax Validation**: Run `/usr/lib/qt6/bin/qmlformat <file.qml>` to verify AST correctness without errors.

---

## 7. Phase 2 — Resonance Monitoring Array (3-Card HUD)

Phase 2 introduces the **Resonance Monitoring Array** skin for the desktop resource widget (`modules/ii/background/widgets/resources/ResourcesWidget.qml`), replacing the oversized cartoon cards with three restrained Jinzhou terminal instruments while preserving geometry (`~420x120`), horizontal/vertical orientation toggle, drag/lock behavior, and classic look when not opted-in.

### Configuration Schema

Persisted in `~/.config/illogical-impulse/config.json` under `background.widgets.resources`:

```json
{
  "background": {
    "widgets": {
      "resources": {
        "style": "classic"
      }
    }
  }
}
```

| Property | Type | Default | Options | Description |
|---|---|---|---|---|
| `style` | `string` | `"classic"` | `"classic"`, `"wuwa"` | Style selection for the 3-card desktop resource monitor. Operates independently of global shell theme. |

### Component Architecture

- **Skin Switching**: Conditional `Loader`s retain the original `StatCard` and `TempStatCard` for `"classic"`. Only an explicit `style: "wuwa"` loads `ResonanceStatCard.qml`; the global bar/media toggle does not select desktop skins.
- **Card 1: CPU Resonance**:
  - Accurate finite clamped CPU percentage (`Math.round(cpuUsage * 100) + "%"`).
  - Frequency metadata readout.
  - Sinuous frequency oscilloscope trace rendered on Canvas; redraws **only on CPU usage updates** (`onCpuUsageChanged`), never per-frame.
- **Card 2: RAM Memory Allocation**:
  - Accurate RAM percentage.
  - Exact GB allocation sub-reading (`ResourceUsage.kbToGbString`).
  - 10-step segmented meter with hairline antique-gold active segment styling.
- **Card 3: Dual Thermal Sensor Array**:
  - Combined CPU and GPU temperatures inside a single card separated by a fine vertical hairline divider.
  - Unavailable/missing sensors (`<= 0°C` or non-finite) display cleanly as `"--"`.
  - Alert threshold: `ResonanceTheme.textWarning` (thermal orange) activates **only above 75°C**. Missing sensors are never styled orange.
- **Corner Engravings & Glass**:
  - Muted dark teal translucent glass (`ResonanceTheme.bgGlass`, radius `10px`).
  - Corner L-bracket engravings and single diamond accent node (`ResonanceTheme.accentGold`).

### Settings Integration

The style option is exposed natively under:
**Settings -> Desktop Widgets -> Resource Styles (`modules/settings/configs/widgets/DesktopResourceStylesConfig.qml`) -> "Resource Monitor (3-Card Array)"**:
- **Card Style**: Segmented switch between **Classic** (`"classic"`) and **Resonance (WuWa)** (`"wuwa"`).

---

## 8. Phase 3 — Chrono Resonator (Concentric Clock)

Phase 3 introduces the **Chrono Resonator** skin for the desktop concentric clock (`modules/ii/background/widgets/clock/ConcentricClockWidget.qml`), converting the timepiece into an antique gold and translucent teal frequency instrument while maintaining dial styles, complications, 12/24-hour modes, minute capsule alignment, and fluid time accuracy.

### Configuration Schema

Persisted in `~/.config/illogical-impulse/config.json` under `background.widgets.concentric_clock`:

```json
{
  "background": {
    "widgets": {
      "concentric_clock": {
        "skin": "classic"
      }
    }
  }
}
```

| Property | Type | Default | Options | Description |
|---|---|---|---|---|
| `skin` | `string` | `"classic"` | `"classic"`, `"wuwa"` | Skin selection for the concentric clock widget. Operates independently of the global shell theme. |

### Component Architecture & Visual Layers

1. **Outer Etched Ring & Broken Orbit (`modules/ii/background/widgets/clock/concentric/ResonanceRing.qml`)**:
   - 12 major division radial ticks at each 30° hour position rendered in antique gold (`ResonanceTheme.accentGold`).
   - Broken hairline outer orbit arc segments separated by 8° gap intervals around each major tick.
   - 4 fine ticklets at 6° intervals between each pair of major divisions rendered in muted antique gold (`0.40 * intensity`).
   - 4 navigation diamond markers at North, South, West (and East if minute pill is hidden).
   - Inner concentric accent orbit at `0.385 * diameter` providing depth without obscuring numerals.
   - **Static rendering**: Canvas repaints only on size or theme token changes, never per-frame.

2. **Focal Signature (Frequency Motif)**:
   - Positioned below the central hour readout (`cy + 0.165 * diameter`).
   - Delicate horizontal hairline waveform (`w = 0.22 * diameter`) with central frequency crest and gold diamond node.
   - The signature uses geometry only; no unreadable microtype.

3. **Gated Stepped / Smooth Rotation (`ConcentricDialCanvas.qml`)**:
   - `property bool smoothRotation: true`: When `true`, smooth 60/120 Hz `FrameAnimation` continuously rotates the seconds dial.
   - When motion is reduced (`Appearance.reducedMotion` or `ResonanceTheme.motionMode` is `"off"` or `"ambient"`), `smoothRotation` becomes `false`: `FrameAnimation` is stopped (0 frame overhead), and `resync()` updates rotation in accurate 1-second stepped increments (`90.0 - (second % 60) * 6.0`) on each second tick.
   - Paused completely when `!root.live` or `!visible`.

4. **Translucent Glass & Minute Pill Integration**:
   - Background circle and blur sample wallpaper using Jinzhou dark teal ink (`ResonanceTheme.colTealInk` / `bgGlassElevated`).
   - Center hour display glows in warm ivory (`ResonanceTheme.textPrimary`).
   - The minute pill at 3 o'clock uses `ResonanceTheme.bgGlassElevated` fill with `ResonanceTheme.borderAccent` hairline border, preserving exact seconds cutout mask alignment.

### Settings Integration

The clock skin is exposed natively under:
**Settings -> Desktop Widgets -> Concentric Clock Options (`modules/settings/configs/widgets/DesktopConcentricClockConfig.qml`) -> "Clock Skin"**:
- **Clock Skin**: Segmented switch between **Classic** (`"classic"`) and **Chrono Resonator (WuWa)** (`"wuwa"`).

---

## 9. Phase 4 — Harmonic Channel & Bar Frequency Polish

Phase 4 harmonizes top-bar frequency ribbons (`modules/ii/bar/IslandFiller.qml`), the small bar Tacet Mark visualizer (`modules/ii/bar/Visualizer.qml`), and active bar media (`modules/ii/bar/Media.qml`) with the Jinzhou Resonance theme while dramatically reducing compositor load:

### Component Architecture & Enhancements

1. **Harmonic Channel Gap Ribbons (`modules/ii/bar/IslandFiller.qml`)**:
   - **Theme Palette Integration**: When `ResonanceTheme.enabled` is active, waves and stream modes transition to Jinzhou antique gold (`accentGold`), secondary sage (`borderSubtle`), and dark teal backing (`colTealInk`). When disabled, original Matugen colors (`colPrimary`, `colSecondary`, `colTertiary`) are preserved.
   - **Crowding Adaptation**: Opacity scales gracefully (`gapOpacity`) in narrow gaps (<140px) to prevent visual clutter between floating islands, while tapering to zero at pill boundaries without overlapping active pills.
   - **Performance & Motion Gating**:
     - Reduced/off motion or screen lock stops the decorative timer. Motion-off also holds shader audio uniforms at zero.
     - Paced clock driver: ~30 fps under real audio playback (`interval: 33ms`), 12 fps when idle (`interval: 83ms`), and ~8 fps in ambient mode (`interval: 125ms`), eliminating the legacy 60 fps idle drain.

2. **Small Bar Tacet Mark Visualizer (`modules/ii/bar/Visualizer.qml`)**:
   - **Elimination of Unconditional Animations**: Removed the 60 fps `FrameAnimation` and 4 infinite `SequentialAnimation` loops.
   - **Audio-Reactive Bounded Motion**: Active music playback animates the shader at a capped ~30 fps (`interval: 33ms`), modulating vertical needle flex and aura glow in direct response to `audioEnergy` from `GlobalStates.visualizerPoints`.
   - **Ambient Mode Idle Breath**: In ambient mode (`motionAmbient`), a low-rate ~8 fps timer (`interval: 125ms`) gently breathes without compositor pressure.
   - **Static Silhouette**: Under reduced motion, screen lock, invisibility, or normal idle without audio, all motion freezes into an elegant static silhouette with zero timer activity.
   - **No Time Leaps**: Shader time increments by fixed delta (`+0.033`), preventing visual jumps when music starts or stops.

3. **Active Legacy Bar Media Polish (`modules/ii/bar/Media.qml`)**:
   - Connects `MprisController.activePlayer?.isPlaying` directly to `Local.Visualizer`, ensuring immediate visual reactivity to playback state changes.
   - All MPRIS interactions, popups, and click/scroll handlers remain unchanged.

---

## 10. Implementation Rollback

If rollback is needed:
1. Revert `ResonanceTheme.enabled = false` and reset widget skins in Settings or `config.json`.
2. Inspect `git status` and `git diff` first to ensure uncommitted work in other files is not inadvertently overwritten.
3. If restoring files from backup, restore only the owned Phase 1, 2, 3, and 4 files, and remove newly created component files.

Bar integration: non-finite/negative samples are quiet; motion-off freezes audio uniforms as well as time. Both drivers stop with their host window hidden. Parent actual-source tests cover these gates and all nine filler selections; native rendering/performance results are in the validation report.
