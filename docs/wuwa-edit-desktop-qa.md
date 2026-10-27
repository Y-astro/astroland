# WuWa Edit Desktop — QA Report: Shared Shell Polish & Themed Scrollbar (Agent 1)

**Date**: 2026-10-27  
**Scope**: Edit Desktop Interface (`WidgetEditorPanel.qml`, `LegacyBarLayoutConfig.qml`, `StyledScrollBar.qml`, `GlobalStates.qml`)  
**Design Direction**: WuWa B+ Material Language (Dense Jinzhou Frost)  
- Dark frosted teal / blue-green glass (`colWindowShell` `#081312` @ 0.88 alpha)
- Antique-gold hairlines (`colWindowBorder` `#8E774F` @ 0.28 alpha)
- Warm ivory primary text (`colTextPrimary` `#EDEAE0`)
- Misty sage secondary text (`colTextSecondary` `#7F9489`)
- Slim vertical scrollbar: 5px dark translucent track (`colTealInkDark` @ 0.45) with antique-gold thumb (`colAccent` `#8E774F` @ 0.70 resting, 0.95 hover/active)

---

## 1. Visual Verification & Screenshots

| Target | Screenshot (Cropped) | Full Desktop Capture | Scrollbar Thumb Coordinates & Verification |
| :--- | :--- | :--- | :--- |
| **Widgets tab (Scrolled Near Top)** | [`screenshot_1_widgets_top.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-edit-desktop-qa/screenshot_1_widgets_top.png) | [`screenshot_1_top_full.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-edit-desktop-qa/screenshot_1_top_full.png) | Thumb at Y: 238..318 (81px height at top). Color `#8E774F` (antique gold), dark translucent track visible. |
| **Widgets tab (Scrolled Mid-List)** | [`screenshot_2_widgets_mid.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-edit-desktop-qa/screenshot_2_widgets_mid.png) | [`screenshot_2_mid_full.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-edit-desktop-qa/screenshot_2_mid_full.png) | Thumb at Y: 432..512 (81px height at mid). Smooth response to drag & wheel navigation. |
| **Bar tab** | [`screenshot_3_bar.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-edit-desktop-qa/screenshot_3_bar.png) | [`screenshot_3_bar_full.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-edit-desktop-qa/screenshot_3_bar_full.png) | Thumb at Y: 150..867 (718px height). Proportional to Flickable content height. |

---

## 2. Changes Summary

1. **`StyledScrollBar.qml`**:
   - Scope detection via `inSettings` / `isSettingsScope` hierarchy traversal.
   - Distinct WuWa visual state (`applyWuWa: SettingsTheme.isWuWa && inSettings`):
     - Background track: 5px width, rounded pill ends, color `SettingsTheme.colTealInkDark` at 0.45 alpha.
     - Content item thumb: 5px width, rounded pill ends, antique-gold (`SettingsTheme.colAccent`), resting opacity 0.70 when content overflows (`size < 1.0`), brightening to 0.95 on hover/press.
   - 100% preservation of classic / non-WuWa scrollbar behavior.

2. **`WidgetEditorPanel.qml`**:
   - Added `isSettingsScope: true` and `isWuWa: SettingsTheme.isWuWa` to inherit centralized settings tokens.
   - Shell background: `SettingsTheme.colWindowShell` with `SettingsTheme.colWindowBorder` hairline.
   - Header: Drag indicator in antique gold / misty sage, title in warm ivory demi-bold, "Done" pill button with hairline border.
   - Search & Tabs: `MaterialTextField` and `ConfigSelectionArray` automatically bind to WuWa tokens via `isSettingsScope`.
   - Catalog Rows & Headers: Catalog rows styled with `SettingsTheme.colRowBg` / `colRowBorder`, antique gold icons, warm ivory titles, misty sage categories, and accent-colored status indicators.
   - Scrollbar integration: Attached `ScrollBar.vertical: StyledScrollBar { id: catalogScrollBar }` with dynamic right margin channel (10px) to prevent catalog cards from overlapping the track.
   - Programmatic scroll hook: Listens to `GlobalStates.editModeScrollRequested(dy)` for smooth scrolling and keyboard navigation.

3. **`LegacyBarLayoutConfig.qml`**:
   - Exposed `readonly property alias flickable: contentPage.flickable` to allow standard scrolling integration.

4. **`GlobalStates.qml`**:
   - Added `signal editModeScrollRequested(real dy)` and `function scroll(dy: real): void` to the `editMode` IPC handler.

---

## 3. Preservations & Compliance
- **Data models & presets**: Untouched.
- **Wallpaper selector**: Untouched.
- **Bar layout editing logic**: Completely preserved.
- **Motion & performance**: Validated against `Appearance.animation.elementMoveFast`. Zero custom blur passes introduced (compositor blur retained).
- **Automated Tests**:
  - `qmllint modules/common/widgets/StyledScrollBar.qml modules/ii/editMode/WidgetEditorPanel.qml modules/ii/editMode/LegacyBarLayoutConfig.qml` -> Clean (0 warnings).
  - `test_edit_mode_motion_audit.py` -> Passed (2/2).
  - `test_type_to_search_edit_mode_contract.py` -> Passed (2/2).
