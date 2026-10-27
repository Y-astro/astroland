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

---

# WuWa Edit Desktop — QA Report: Widgets Tab Segmentation & Hierarchy (Agent 2)

**Date**: 2026-10-27  
**Scope**: Edit Desktop Interface (`WidgetEditorPanel.qml`, `test_widgets_tab_hierarchy_contract.py`)  
**Design Direction**: WuWa B+ Material Language (Dense Jinzhou Frost & Structural Parity with Bar tab)  
- 3-tier depth logic:
  1. **Tier 1 (Outer Shell)**: Dark frosted teal / blue-green glass (`colWindowShell` `#081312` @ 0.88 alpha) with antique-gold hairline border.
  2. **Tier 2 (Section Cards)**: Discrete frosted card blocks for each widget category (`colCardBg` with `colCardBorder` hairline, `radius: Appearance.rounding.normal`, 12px breathing room between cards).
  3. **Tier 3 (Internal Rows)**: Structured widget rows (`colRowBg`, `colRowBorder`, `radius: Appearance.rounding.small`, 6px row spacing) with distinct installed/active state highlights.
- Visual Parity: `NoticeBox` instruction banner ported to top of Widgets tab, mirroring the Bar tab layout.

---

## 1. Visual Verification & Screenshots

| Target | Screenshot (Cropped) | Full Desktop Capture | Visual Hierarchy & State Verification |
| :--- | :--- | :--- | :--- |
| **Widgets tab Top Area** | [`agent2_1_widgets_top.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-edit-desktop-qa/agent2_1_widgets_top.png) | [`agent2_1_top_full.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-edit-desktop-qa/agent2_1_top_full.png) | `NoticeBox` banner at top, search input, and first category section card ("Clocks") with antique-gold icon, warm ivory title, count pill ("32"), and chevron. |
| **Two Category Blocks (Clocks & Date)** | [`agent2_2_two_categories.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-edit-desktop-qa/agent2_2_two_categories.png) | [`agent2_2_two_categories_full.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-edit-desktop-qa/agent2_2_two_categories_full.png) | 12px breathing room between "Clocks" card and "Date" card. "Date" card features its own calendar icon, count pill ("14"), and distinct date widgets. |
| **Mixed Installed / Inactive Rows** | [`agent2_3_mixed_installed.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-edit-desktop-qa/agent2_3_mixed_installed.png) | [`agent2_1_top_full.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-edit-desktop-qa/agent2_1_top_full.png) | Installed "Concentric Clock" displays antique-gold hairline border, gold-tinted background, and circular checkmark (`✓`) badge. Inactive rows display dark translucent background and subtle `+` add action. |

---

## 2. Structural & Architectural Changes

1. **Section-Card Architecture**:
   - Replaced flat `ListView` and bare text headers with discrete `categoryCard` blocks inside `StyledFlickable`.
   - Each category is an enclosed card (`SettingsTheme.colCardBg`, `SettingsTheme.colCardBorder`, `radius: Appearance.rounding.normal`).
   - Grouped and ordered categories: `Clocks`, `Date`, `Weather`, `Media`, `System`, `Resources`, `Devices`, `Productivity`, `Photos`, and `Other`.
   - Date and Clocks are decoupled into separate, distinct categories.

2. **Section Header Affordances**:
   - Semantic icon in antique gold (`SettingsTheme.colAccent`).
   - Category title in warm ivory demi-bold (`SettingsTheme.colTextPrimary`).
   - Frosted count badge pill displaying the count of available widgets in that category.
   - Interactive expand/collapse chevron animating rotation via `Appearance.animation.elementMoveFast.numberAnimation`.

3. **Widget Row Formatting & Installed States**:
   - 52px practical row density with structured left icon (22px), title (13px DemiBold/Medium), and subtitle/description (11px).
   - Inactive widgets display a subtle circular `+` button in misty sage.
   - Installed/active widgets display an antique-gold tinted background (`colAccent` @ 0.12), an antique-gold hairline border (`colAccent` @ 0.45), and a circular antique-gold checkmark badge (`✓`).
   - Clicking an active widget selects it on the desktop; clicking an inactive widget adds it to the desktop.

4. **Search & Collapsing**:
   - Two-way binding for `MaterialTextField` search.
   - Non-empty search queries automatically expand matching categories and filter out empty categories.
   - Empty search results present a stylized empty state notice ("No widgets found").
   - Category expansion/collapse state persists across searches.

---

## 3. Preservations & Compliance
- **Data models & presets**: 100% untouched.
- **Bar tab**: 100% untouched.
- **Wallpaper selector**: 100% untouched.
- **Widget add/select logic**: `selectOrAdd`, `add`, `duplicate`, `removeSelection` preserved identically.
- **Motion compliance**: All animations strictly adhere to `Appearance.animation` tiers (`test_edit_mode_motion_audit.py`).
- **Automated Tests**:
  - `qmllint modules/ii/editMode/WidgetEditorPanel.qml` -> Clean (0 warnings).
  - `test_edit_mode_motion_audit.py` -> Passed (2/2).
  - `test_type_to_search_edit_mode_contract.py` -> Passed (2/2).
  - `test_widgets_tab_hierarchy_contract.py` -> Passed (7/7).

---

# WuWa Edit Desktop — QA Report: Widget Row Polish & Interaction Clarity (Agent 3)

**Date**: 2026-10-27  
**Scope**: Edit Desktop Interface (`WidgetEditorPanel.qml`, `test_widgets_row_polish_contract.py`)  
**Design Direction**: WuWa B+ Material Language (Dense Jinzhou Frost Row-Level Polish)  
- **Dark Inky Teal Row Surfaces**: `SettingsTheme.colRowBg` (`#182E29` @ 0.38 alpha) transitioning to `SettingsTheme.colRowHover` (`#203a34` @ 0.48 alpha) on hover.
- **Hairline Antique Gold Borders**: `SettingsTheme.colRowBorder` (antique gold @ 0.12 * intensity) brightening smoothly to 0.28 * intensity on hover.
- **Dedicated 32x32 Squircle Icon Containers**: Anchors every leading glyph in a centered tile (`radius: Appearance.rounding.verysmall`), eliminating optical jitter across variable-width glyphs.
- **Warm Ivory & Misty Sage Typography Hierarchy**: 13px warm ivory title (`Font.DemiBold` for active, `Font.Medium` for inactive) paired with 11px misty sage secondary description (`opacity: 0.90` active vs `0.75` resting).
- **Tactile 26x26 Trailing Action Badges**: Circular badge with distinct interactive states — subtle dark teal glass with misty sage `+` for uninstalled widgets, antique gold glass badge with solid antique gold border and `✓` checkmark for installed/active widgets.

---

## 1. Visual Verification & Screenshots

| Target | Screenshot Closeup | Visual Detail & Interaction State |
| :--- | :--- | :--- |
| **Normal Row (Resting Inactive)** | [`agent3_1_normal_row.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-edit-desktop-qa/agent3_1_normal_row.png) | Dark frosted inner surface (`colRowBg`), 32x32 squircle icon tile with misty sage glyph, warm ivory 13px title, 11px misty sage description, circular `+` pill. |
| **Hovered Row (Hovered Inactive)** | [`agent3_2_hovered_row.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-edit-desktop-qa/agent3_2_hovered_row.png) | Hover surface (`colRowHover`), illuminated antique gold border, darkened icon tile with warm ivory glyph, hand pointer cursor, and glowing antique gold `+` badge. |
| **Active/Installed Row with Check (Resting)** | [`agent3_3_active_installed_row.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-edit-desktop-qa/agent3_3_active_installed_row.png) | Antique gold tinted glass background, antique gold hairline border, 32x32 gold icon tile with glowing antique gold icon, 13px DemiBold title, and circular gold checkmark (`✓`) badge. |
| **Inactive Row with Plus Detail** | [`agent3_4_inactive_row_plus.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-edit-desktop-qa/agent3_4_inactive_row_plus.png) | High-contrast detail of resting inactive row showing the 26x26 circular `+` button in misty sage, clean padding (10px horizontal), and 52px density. |
| **Active/Installed Row (Hovered)** | [`agent3_5_active_hovered_row.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-edit-desktop-qa/agent3_5_active_hovered_row.png) | Active row reacting to hover: reinforced antique gold border glow (`colAccent` @ 0.60), brightened checkmark badge, and pointer cursor. |
| **Full Panel Overview** | [`agent3_overview_panel.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-edit-desktop-qa/agent3_overview_panel.png) | Full 440px wide Edit Desktop panel showing multiple section cards and aligned widget rows. |

---

## 2. Row Polish & Structural Improvements

1. **Fixed-Dimension Squircle Icon Tiles**:
   - Replaced raw `MaterialSymbol` alignment with an enclosing 32x32 `iconTile` (`radius: Appearance.rounding.verysmall`).
   - Centered 18px icon inside the container.
   - Guaranteed identical horizontal baseline and left-margin alignment across all categories and varying glyph geometries (e.g. narrow `schedule` vs wide `calendar_month`).
   - Inactive state: `colTealInkDark` @ 0.45 fill, misty sage icon.
   - Active state: `colAccent` @ 0.16 fill, antique gold icon and hairline border.

2. **Typography Hierarchy**:
   - Title: `font.pixelSize: 13`, color warm ivory (`SettingsTheme.colTextPrimary`), weighted `Font.DemiBold` for installed/active rows and `Font.Medium` for inactive rows.
   - Description / Subtitle: `font.pixelSize: 11`, color misty sage (`SettingsTheme.colTextSecondary`), with `opacity: 0.90` on active rows and `0.75` on inactive rows for clean vertical rhythm.
   - Text elision: `Text.ElideRight` applied to prevent badge overlap or layout clipping.

3. **Trailing Action Badge**:
   - 26x26 circular badge (`radius: 13`) with 15px centered symbol.
   - Uninstalled/inactive: Dark inky teal translucent pill (`colTealInkDark` @ 0.45 resting, 0.70 hover) with misty sage `+` icon that warms to warm ivory on row hover.
   - Installed/active: Semi-translucent antique gold pill (`colAccent` @ 0.20 resting, 0.28 hover) with solid antique gold hairline border and antique gold `✓` checkmark.

4. **Interactive States & Hover Feedback**:
   - Inactive hover: Transitions to `SettingsTheme.colRowHover` (`#203a34` @ 0.48), hairline border illuminates to antique gold (`colAntiqueGold` @ 0.28 * intensity), icon tile darkens and icon warms to ivory.
   - Active hover: Tint deepens (`colAccent` @ 0.18), border illuminates to `colAccent` @ 0.60, check badge highlights.
   - Avoids loud neon fills or over-bright hovers; strictly adheres to dense WuWa Jinzhou Frost aesthetics.

5. **Selection & Logic Integrity**:
   - Preserved `root.selectOrAdd(widget)` on click: clicking an uninstalled widget adds it to the desktop canvas; clicking an already installed widget selects it for on-screen editing.
   - `isSelected` focus support: currently selected widget on desktop canvas receives additional accent glow.

---

## 3. Preservations & Compliance
- **Click & Add/Remove Logic**: 100% preserved.
- **Bar Tab**: 100% untouched.
- **Wallpaper Selector**: 100% untouched.
- **Performance & Blur**: Zero custom blur shaders introduced; uses native compositor glass and standard QML property bindings.
- **Motion Compliance**: No raw durations, no bare animations, no `Easing.` in `modules/ii/editMode/` (`test_edit_mode_motion_audit.py`).
- **Automated Tests**:
  - `qmllint modules/ii/editMode/WidgetEditorPanel.qml` -> Clean (0 warnings).
  - `test_edit_mode_motion_audit.py` -> Passed (2/2).
  - `test_type_to_search_edit_mode_contract.py` -> Passed (2/2).
  - `test_widgets_tab_hierarchy_contract.py` -> Passed (7/7).
  - `test_widgets_row_polish_contract.py` -> Passed (5/5).
  - Total: 16/16 tests passing.
