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

## 7. Implementation Rollback

If rollback is needed:
1. Set `Config.options.appearance.wuwaTheme.enabled = false` in Settings or `~/.config/illogical-impulse/config.json`.
2. Inspect `git status` and `git diff` first to ensure uncommitted work in other files is not inadvertently overwritten.
3. To revert the Phase 1 files safely, restore only the owned files (`modules/common/Config.qml` and `modules/settings/configs/ColorsThemesConfig.qml`) from the private backup directory (`/home/astro/.local/state/wuwa-resonance-20261018/`) or delete `modules/common/ResonanceTheme.qml` and `docs/wuwa-resonance-theme.md`, avoiding blanket `git restore .` which would destroy pre-existing dirty files.
