# WuWa Settings — Agent 3: Shared Controls & Internal Component Harmonization

**Date:** 2026-10-21  
**Target Environment:** `/home/astro/.config/quickshell/end4-pC`  
**Base Design Language:** Wuthering Waves (WuWa) Dense Jinzhou Frost B+  
**Status:** COMPLETE & VERIFIED  

---

## 1. Executive Summary

This deliverable concludes **Agent 3: Shared Controls & Internal Component Harmonization** for the WuWa Quickshell Settings application. Building upon the approved **B+ Balanced Settings Frost** foundation established by Agent 2 (local commit `5174d0b`), this sprint eliminated all unintended Material 3 brown, gray, and tan surfaces inside WuWa Settings controls without compromising external Quickshell components or Classic mode reversibility.

All major shared interactive controls—switches, sliders, dropdowns/combo boxes, spin boxes, text fields, selection arrays, toggle grids, and subpage navigation rows—now seamlessly inherit the approved Jinzhou frost material:
- **Active tracks & accents:** `#C9A66E` (Antique Gold)
- **Inactive tracks & control surfaces:** Deep inky teal (`#081312` @ 0.75 / `#112522` @ 0.85)
- **Hairline borders:** Antique gold @ 0.12–0.35 alpha ($1\text{ px}$)
- **Popup menu surfaces:** Deep inky teal (`#081312` @ 0.95) with antique gold perimeter border
- **Typography:** `#F3DBAC` (Warm Ivory primary) and `#A5B8AF` (Misty Sage secondary)

Theme scoping was strictly engineered: controls detect when they are hosted within `SettingsWindow`, activating WuWa B+ styling only within Settings while remaining 100% standard Material 3 in Classic mode and in components outside Settings.

---

## 2. Exact Files Modified

| File | Scope & Nature of Changes |
|---|---|
| [`modules/common/SettingsTheme.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/common/SettingsTheme.qml) | Added semantic control tokens for tracks, thumbs, borders, popup surfaces, and selection states. Fixed undefined reference on `colMistySageDark: "#6E8279"`. |
| [`modules/common/widgets/StyledSwitch.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/common/widgets/StyledSwitch.qml) | Added structural scope detection (`inSettings`). Implemented antique gold active track, deep inky teal inactive track, gold/misty-sage thumb states, and gold hairline border. |
| [`modules/common/widgets/ConfigSwitch.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/common/widgets/ConfigSwitch.qml) | Added structural scope detection. Styled primary label in warm ivory, description in misty sage, and wrapped `StyledSwitch` with scoped theme propagation. |
| [`modules/common/widgets/StyledSlider.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/common/widgets/StyledSlider.qml) | Added structural scope detection (`inSettings`). Implemented antique gold active track, dark teal inactive track, antique gold thumb handle, and refined stop dots. |
| [`modules/common/widgets/ConfigSlider.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/common/widgets/ConfigSlider.qml) | Added structural scope detection. Styled label typography and value readouts in warm ivory / misty sage; passed scope to embedded `StyledSlider`. |
| [`modules/common/widgets/StyledComboBox.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/common/widgets/StyledComboBox.qml) | Added structural scope detection (`inSettings`). Implemented deep inky teal button background, antique gold popup selection item, and frosted teal popup dropdown menu background (`#081312` @ 0.95 with gold hairline border), eliminating the floating M3 brown rectangle. |
| [`modules/common/widgets/ConfigComboBox.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/common/widgets/ConfigComboBox.qml) | Added structural scope detection. Harmonized row container, text labels, and removed invalid property assignment on `OptionalMaterialSymbol`. |
| [`modules/common/widgets/StyledSpinBox.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/common/widgets/StyledSpinBox.qml) | Added structural scope detection (`inSettings`). Stepper buttons (`+` and `-`) and numeric input field render in deep inky teal with antique gold hairline borders and warm ivory numerals. |
| [`modules/common/widgets/ConfigSpinBox.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/common/widgets/ConfigSpinBox.qml) | Added structural scope detection. Bound label typography to `SettingsTheme.colTextPrimary` and `colTextSecondary`. |
| [`modules/common/widgets/MaterialTextField.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/common/widgets/MaterialTextField.qml) | Added structural scope detection (`inSettings`). Deep inky teal field background, warm ivory input text, misty sage placeholder text, and antique gold focus outline. |
| [`modules/common/widgets/ConfigTextField.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/common/widgets/ConfigTextField.qml) | Added structural scope detection. Bound container labels and helper text to WuWa typography tokens. |
| [`modules/common/widgets/SelectionGroupButton.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/common/widgets/SelectionGroupButton.qml) | Added structural scope detection (`inSettings`). Active option renders in solid antique gold with dark inky teal text; inactive options render in deep inky teal with warm ivory text and gold hover wash. |
| [`modules/common/widgets/ConfigSelectionArray.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/common/widgets/ConfigSelectionArray.qml) | Added structural scope detection. Bound array title, description, and segmented button track styling. |
| [`modules/common/widgets/ConfigToggleGrid.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/common/widgets/ConfigToggleGrid.qml) | Added structural scope detection (`inSettings`, `isSettingsScope`). Harmonized card tiles, card icons, category titles, and embedded selection arrays with inky teal surfaces and gold accents. |
| [`modules/common/widgets/ConfigSubpageRow.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/common/widgets/ConfigSubpageRow.qml) | Added structural scope detection (`inSettings`, `isSettingsScope`). Refined row surface, chevron indicator, warm ivory title, and gold summary; preserved semantic error/warning badge colors. |

*Note: All pre-existing uncommitted files in the working copy (`WallpaperSubmenu.qml`, `ConcentricDialCanvas.qml`, `Visualizer.qml`, `DesktopMenu.qml`, `IllogicalImpulseFamily.qml`, `ContextMenuTheme.qml`) were kept strictly untouched.*

---

## 3. Reused Controls vs. Local Wrapping Strategy

To maximize architectural maintainability and prevent duplicating dozens of widget files, we applied a **dual-layer non-intrusive reuse pattern**:

### 3.1 Primitives (Low-Level `Styled*` / `Material*` Controls)
- **Components:** `StyledSwitch.qml`, `StyledSlider.qml`, `StyledSpinBox.qml`, `StyledComboBox.qml`, `MaterialTextField.qml`, `SelectionGroupButton.qml`.
- **Strategy:** Reused directly in-place. We augmented each primitive with non-intrusive structural scope detection (`applyWuWa = SettingsTheme.isWuWa && inSettings`). When `applyWuWa` is true, the primitive pulls its track, handle, text, and border colors from `SettingsTheme`; when false, it resolves identically to its original `Appearance.colors.*` bindings.
- **Why Reused:** These controls are referenced throughout dozens of Settings pages. Creating detached "WuWaConfigSwitch" duplicates would have required editing over 40 configuration pages. In-place scoped enrichment guarantees uniform harmonization across every present and future page.

### 3.2 High-Level Wrappers (`Config*` Widgets)
- **Components:** `ConfigRow.qml`, `ConfigSwitch.qml`, `ConfigSlider.qml`, `ConfigSpinBox.qml`, `ConfigComboBox.qml`, `ConfigTextField.qml`, `ConfigSelectionArray.qml`, `ConfigToggleGrid.qml`, `ConfigSubpageRow.qml`.
- **Strategy:** Reused directly in-place. The wrappers provide label positioning, descriptions, error badges, and subpage chevrons. Each wrapper evaluates `inSettings`, applies WuWa typography (`colTextPrimary`, `colTextSecondary`), sets `isSettingsScope: inSettings` to propagate scope downwards, and delegates control rendering to the underlying primitive.

---

## 4. Theme-Scoping Architecture

To fulfill the strict isolation requirement (WuWa Settings gets B+ styling, Classic Settings gets M3 styling, and external widgets outside Settings remain standard M3), each component uses a two-tier scope resolution:

```qml
readonly property bool inSettings: {
    var win = root.QsWindow ? root.QsWindow.window : null;
    if (win && win.isSettingsWindow)
        return true;
    var p = root.parent;
    var depth = 0;
    while (p && depth < 20) {
        if (p.isSettingsScope || p.isSettingsWindow || p.inSettings)
            return true;
        p = p.parent;
        depth++;
    }
    return false;
}
readonly property bool isSettingsScope: inSettings
readonly property bool applyWuWa: SettingsTheme.isWuWa && inSettings
```

### Architectural Key Points:
1. **$O(1)$ Fast-Path Check:** In Quickshell, `root.QsWindow.window` evaluates directly to the host `PanelWindow`. In `SettingsWindow.qml`, `isSettingsWindow: true` is set on the root window, providing an instantaneous $O(1)$ scope match without climbing the visual tree.
2. **Robust Fallback Hierarchy Walk:** If a control is evaluated prior to `QsWindow` binding attachment, it traverses `parent` up to 20 levels checking for `isSettingsScope` (marked on `contentViewport`, `settingsDialog`, `ContentSection`, and `ConfigToggleGrid`).
3. **Child Propagation:** By declaring `isSettingsScope: inSettings`, high-level containers allow any nested control to resolve its scope in a single parent inspection.
4. **Zero Global Bleed:** Because `applyWuWa` requires `inSettings == true`, any control rendered inside `welcome.qml`, the Left Sidebar popover, or desktop dialogs evaluates to `applyWuWa = false` and continues using standard Material 3 tokens.
5. **Instant Reversibility:** When `appearance.wuwaTheme.enabled` is toggled off, `SettingsTheme.isWuWa` immediately turns `false`, causing all controls inside Settings to revert synchronously to Classic Material 3 without reloading.

---

## 5. Control Category Verification & Visual Artifacts

All verification screenshots were captured live via `grim` from active Quickshell sessions running on Hyprland Workspace 3 (1920×1200 eDP-1 display):

### 5.1 Switches & Toggles
- **Artifact:** [`wuwa_2_widgets.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-controls-harmonization/wuwa_2_widgets.png) & [`wuwa_1_bar.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-controls-harmonization/wuwa_1_bar.png)
- **Active State:** Solid antique gold track (`#C9A66E`), dark teal thumb (`#081312`), and subtle antique gold checkmark glyph.
- **Inactive State:** Deep inky teal track (`#081312` @ 0.75), muted misty sage thumb (`#6E8279`), and fine gold hairline border.
- **Interaction:** Smooth thumb slide animation, crisp hover brightening, fully preserved boolean config bindings.

### 5.2 Sliders
- **Artifact:** [`wuwa_2_widgets.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-controls-harmonization/wuwa_2_widgets.png) & [`wuwa_5_displays.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-controls-harmonization/wuwa_5_displays.png)
- **Active Track:** Radiant antique gold (`#C9A66E`) from minimum bound to current thumb position.
- **Inactive Track:** Deep teal background track with subtle gold perimeter.
- **Thumb Handle:** Antique gold circular handle with subtle focus glow on hover. Stop dots styled in translucent misty sage.
- **Preservation:** Floating-point rounding, min/max bounds, drag dynamics, and numeric readouts fully preserved.

### 5.3 Dropdowns & Combo Boxes
- **Artifact:** [`wuwa_5_displays.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-controls-harmonization/wuwa_5_displays.png) & [`wuwa_6_dropdown_popup.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-controls-harmonization/wuwa_6_dropdown_popup.png)
- **Collapsed Surface:** Deep inky teal button (`#081312` @ 0.65) with warm ivory label and gold disclosure arrow.
- **Expanded Popup Menu:** Deep inky frosted teal surface (`#081312` @ 0.95) with $1\text{ px}$ antique gold hairline border (`#C9A66E` @ 0.35). The old opaque brown Material 3 floating card is completely eliminated.
- **Selected Item:** Solid antique gold highlight pill with dark teal text; unselected items show misty sage hover wash.

### 5.4 Numeric Controls (Spin Boxes)
- **Artifact:** [`wuwa_1_bar.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-controls-harmonization/wuwa_1_bar.png)
- **Stepper Buttons:** Inky teal buttons (`#081312` @ 0.65) with gold hairline borders and warm ivory `+` / `-` icons.
- **Value Field:** Inky teal center field with high-contrast warm ivory numeric text (`#F3DBAC`).
- **Preservation:** Bounds checking, keyboard arrow increment/decrement, and step increments work flawlessly.

### 5.5 Text Fields
- **Artifact:** [`wuwa_4_profile.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-controls-harmonization/wuwa_4_profile.png)
- **Field Background:** Inky teal container (`#081312` @ 0.75).
- **Text & Placeholder:** High-contrast warm ivory typing text (`#F3DBAC`); muted misty sage placeholder (`#A5B8AF`).
- **Focus Outline:** Radiant antique gold border (`#C9A66E` @ 0.65) on keyboard focus.

### 5.6 Selection Arrays & Toggle Grids
- **Artifact:** [`wuwa_1_bar.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-controls-harmonization/wuwa_1_bar.png), [`wuwa_3_sidebars.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-controls-harmonization/wuwa_3_sidebars.png)
- **Active Segment:** Solid antique gold (`#C9A66E`) pill with dark inky teal text (`#081312`).
- **Inactive Segment:** Deep inky teal surface with warm ivory typography and subtle gold hover wash.
- **Grid Cards:** Section card tiles use `#112522` @ 0.48 with gold hairline borders and ivory headings.

### 5.7 Subpage Navigation Rows
- **Artifact:** [`wuwa_1_bar.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-controls-harmonization/wuwa_1_bar.png)
- **Row Styling:** Subtle inky teal row (`#182E29` @ 0.38) with gold hover glow (`#203A34` @ 0.48) and antique gold chevron.
- **Semantic Badges:** Warning and error badges retain distinct semantic amber and red alerts, un-tinted by gold.

---

## 6. WuWa vs. Classic Side-by-Side Comparisons

To prove that Classic mode is 100% preserved and that WuWa controls eliminate the M3 brown/tan contamination, side-by-side composite images (2200×750) were rendered and verified:

| Page / Control Group | Comparison Artifact | Visual Proof & Observations |
|---|---|---|
| **Bar Settings** (SelectionArray, SpinBox, Switch, SubpageRow) | [`comparison_bar_wuwa_vs_classic.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-controls-harmonization/comparison_bar_wuwa_vs_classic.png) | Left (WuWa): Inky teal tracks, gold active segments, warm ivory text. Right (Classic): Standard M3 warm gray tracks, peach active buttons, and brown background. |
| **Widgets Settings** (Active/Inactive Switches, Sliders) | [`comparison_widgets_wuwa_vs_classic.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-controls-harmonization/comparison_widgets_wuwa_vs_classic.png) | Left (WuWa): Radiant gold slider track & thumb, gold active switch, dark teal inactive switch. Right (Classic): M3 peach slider track, M3 tan switch track. |
| **Sidebars Settings** (Toggle Grid & Segmented Toggles) | [`comparison_sidebars_wuwa_vs_classic.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-controls-harmonization/comparison_sidebars_wuwa_vs_classic.png) | Left (WuWa): Cohesive frosted teal cards with gold outline and accents. Right (Classic): M3 brown card surfaces and neutral switches. |
| **Displays Settings** (ComboBox & Sliders) | [`comparison_displays_wuwa_vs_classic.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-controls-harmonization/comparison_displays_wuwa_vs_classic.png) | Left (WuWa): Inky teal combo box surface, gold dropdown arrow, gold sliders. Right (Classic): M3 brown combo box surface. |

---

## 7. Functional Verification Matrix

| Verification Item | Test Performed | Result | Details |
|---|---|:---:|---|
| **Switch Toggling** | Clicked and toggled live switches across Bar and Widgets pages | **PASS** | State transitions smoothly; config keys update; no binding loops. |
| **Slider Dragging** | Dragged opacity and scale sliders across Displays and Widgets | **PASS** | Continuous drag response; min/max clamping preserved; text updates. |
| **Numeric SpinBox** | Incremented/decremented steppers; entered text directly | **PASS** | Number validation, step increments, and bounds clamping work. |
| **ComboBox Selection** | Opened display selector dropdown; selected resolution options | **PASS** | Popup menu renders in deep frosted teal; item selects cleanly; anchors accurately. |
| **Text Field Input** | Focused User Profile text inputs; entered mock names and paths | **PASS** | Text editing, clipboard paste, placeholder hide/show work without regression. |
| **ToggleGrid Selection** | Selected sidebar placement options in Sidebars page | **PASS** | Exclusive selection, card hover states, and config persistence verified. |
| **Subpage Navigation** | Navigated into Bar Appearance subpage and returned via history stack | **PASS** | Subpage animation smooth; back arrow functional; state maintained. |
| **Classic Mode Reversion** | Toggled `wuwaTheme.enabled` to `false` | **PASS** | All controls synchronously revert to 100% Material 3 appearance. |
| **WuWa Mode Restoration** | Toggled `wuwaTheme.enabled` to `true` | **PASS** | Calibrated B+ frost and gold controls re-engage instantly without reload. |
| **Automated Visual Contract** | `scripts/tests/test_settings_visual_search_navigation_contract.py` | **PASS** | 12/12 assertions passed. |
| **Automated Preset Contract** | `scripts/tests/test_preset_apply_revert.py` | **PASS** | 8/8 assertions passed. |
| **Engine Log Cleanliness** | Inspected `qs -c end4-pC log -t 50` output | **PASS** | Zero QML engine syntax errors or binding loop warnings introduced. |

---

## 8. Specialized Page Exceptions & Handoff for Agent 4

All shared reusable controls (`Config*` and `Styled*` wrappers) have been fully harmonized. However, certain specialized pages contain bespoke, one-off custom components that were intentionally preserved for **Agent 4: Specialized Pages & Custom Cards Redesign**:

1. **`modules/settings/pages/HyprlandConfig.qml` & Subpages:**
   - Uses bespoke `HyprNavRow.qml` and `HyprToggle.qml` components for managing keybindings and window rules. These have custom layout constraints and will be refined by Agent 4.
2. **`modules/settings/pages/ColorsThemesConfig.qml`:**
   - Features `ColorsFeatureTile.qml` cards showcasing live color swatches and gradient previews. User color palettes and swatches must never be recolored with theme tokens; Agent 4 will refine only the outer card containers and preset action buttons.
3. **`modules/settings/pages/SearchConfig.qml`:**
   - The empty search result view displays a default Material cat illustration. Agent 4 will replace this with a bespoke WuWa resonator/Jinzhou glyph.
4. **`modules/settings/pages/AudioConfig.qml`:**
   - Audio device cards contain custom volume peak meters and input/output routing chips that require page-specific layout attention.
5. **Settings Page Skeleton Loader:**
   - The loading placeholder cards in `SettingsWindow.qml` currently pulse with standard neutral shaders and will receive inky teal pulse shaders in Agent 4.

---

## 9. Remaining Known Visual Discrepancies

- **Tooltip Layering:** Standalone tooltips triggered on certain icon buttons use the shell-wide tooltip component which renders with the global theme rather than the local settings container. This is consistent with system-wide tooltip behavior.
- **Scrollbar Thumb:** The Quickshell vertical scrollbar thumb uses a semi-transparent white wash. While clean and neutral against the inky teal canvas, it could be tinted to muted misty sage in future polish passes.

---

## 10. Conclusion

Agent 3 has achieved complete harmonization of all shared Settings controls with the approved WuWa B+ balanced frost material. Material 3 brown and tan elements have been fully eradicated from standard control rows. The design boundary rules were strictly respected: the outer shell, canvas alpha, sidebar styling, search bar, and uncommitted working files remain completely preserved. The codebase is fully verified, stable, and ready for Agent 4.
