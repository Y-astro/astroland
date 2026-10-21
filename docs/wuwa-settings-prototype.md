# WuWa Quickshell — Settings Redesign: Live Material Prototype & Approval Checkpoint

**Date:** 2026-10-21  
**Target Environment:** `/home/astro/.config/quickshell/end4-pC`  
**Base Design Language:** Wuthering Waves (WuWa) Dense Jinzhou Frost B2  
**Status:** Approved (Selected: Variant B — Balanced Settings Frost)  

---

## 1. Executive Summary & Design Objective

The Settings application represents the final major surface in the Wuthering Waves (WuWa) desktop environment awaiting redesign. The objective of this visual prototype checkpoint is to demonstrate a sophisticated, Jinzhou-inspired control interface rather than a generic collection of disconnected translucent cards.

Following the approved WuWa B2 Jinzhou design palette:
- **Deep Inky Teal Shell:** `#0c1b1a` and `#081312`
- **Antique Gold Highlights:** `#C9A66E`
- **Warm Ivory Primary Text & Titles:** `#F3DBAC`
- **Misty Sage Secondary Text & Subdued Elements:** `#A5B8AF`
- **Hairline Ornamental Borders:** Restrained antique gold with subtle alpha scaling

To resolve the architectural tension between offscreen render performance and frosted glass aesthetics, this prototype implements **two material-density variants** sharing the identical color palette:
1. **Variant A — Dense Settings Glass:** Darker, grounded appearance; opaque canvas and sidebar; zero-cost `CornerCutouts`; highest text contrast; minimal wallpaper bleed.
2. **Variant B — Balanced Settings Frost:** Frosted glass appearance (88% shell, 72% canvas); compositor blur diffusion over wallpaper; true alpha-blended `OpacityMask` corner clipping.

---

## 2. Existing Settings Architecture & Preservation

The existing Quickshell Settings application (`SettingsWindow.qml`) implements an intricate performance and state architecture:
- **Centered Dialog Geometry:** Rendered centered (1100×750 px) inside a fullscreen transparent `PanelWindow` on layer-shell (`quickshell:settings`).
- **Lazy Page Loading & Gating:** Heavy configuration pages are loaded asynchronously through `pageLoader` with a `pageActivationTimer` gate and fallback `SettingsPageSkeleton`.
- **Search Indexing & Navigation History:** `SearchRegistry` indexes page metadata and sections; `SearchBar.qml` drives live query matching and section highlighting.
- **Scroll Position Restoration & Transitions:** Fast smooth transitions, scroll offset caching per page, and keyboard navigation (`Qt.BackButton` / `Qt.ForwardButton`).
- **Corner Clipping Architecture:**
  - When the background is opaque (`contentViewport.opaqueBackground = true`), corners are masked via **`CornerCutouts`** (zero offscreen texture overhead).
  - When the background is translucent, `layer.effect: OpacityMask` is activated, routing the viewport through an offscreen FBO texture.

**Preservation Guarantee:** All navigation, search indexing, page loaders, skeletons, keyboard handlers, and settings state logic were preserved 100% intact. No rewrites or destructive architectural modifications were made.

---

## 3. Analysis of Historical Revert (`745fad7aa` reverting `4ed1ab3`)

Before implementing this prototype, commit `4ed1ab3` and its subsequent revert `745fad7aa` were inspected:
- **What Failed in `4ed1ab3`:**
  1. `SettingsWindow.qml` was directly bound to `ResonanceTheme.bgGlassPopup` (~0.68 alpha), and `Sidebar.qml` was bound to `bgGlassPopupCard` (~0.41 alpha).
  2. Because the background alpha was < 1.0, `contentViewport.opaqueBackground` evaluated to `false`, forcibly activating `OpacityMask` on the entire flickable viewport. This caused offscreen texture redraws on every scroll and transition frame.
  3. Setting cards (`ContentSection.qml`, `ColorsPalettePane.qml`, etc.) and typography were left unstyled, resulting in harsh light/grey cards floating over a low-opacity teal layer with illegible text.
  4. Global color tokens (`Appearance.colors.colLayer0`) were polluted, destabilizing other panels.
- **Lessons Applied in Current Prototype:**
  - Used an isolated singleton adapter [`SettingsTheme.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/common/SettingsTheme.qml) without polluting global `Appearance.colors` or speculative `ResonanceTheme` properties.
  - Provided **Variant A** specifically to evaluate zero-cost `CornerCutouts` with 100% opaque internal canvas.
  - Handled the complete hierarchy: Shell, Navigation, Canvas, Cards, Inputs, and Typography in unified harmony.

---

## 4. Exact Files Modified

The prototype was implemented with minimal footprint, touching only the surfaces required to demonstrate the material system:

| File | Nature of Change |
|---|---|
| [`modules/common/SettingsTheme.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/common/SettingsTheme.qml) | **New file.** Settings-local material system adapter; reactive watcher for `/tmp/wuwa_settings_variant.txt`. |
| [`SettingsWindow.qml`](file:///home/astro/.config/quickshell/end4-pC/SettingsWindow.qml) | Shell background, hairline border, canvas background, cutout colors, search input reset on close. |
| [`modules/settings/Sidebar.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/settings/Sidebar.qml) | Sidebar container background, border, cutouts, group headers to misty sage. |
| [`modules/settings/SidebarNavButton.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/settings/SidebarNavButton.qml) | Antique gold active state with dark ink text/icon; misty sage inactive with subtle dark teal hover. |
| [`modules/settings/SearchBar.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/settings/SearchBar.qml) | Search input pill styling, warm ivory text, misty sage placeholder, gold action icons, `clear()` handler. |
| [`modules/settings/UserHeader.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/settings/UserHeader.qml) | Dark teal pill container with hairline border, warm ivory username, misty sage greeting. |
| [`modules/common/widgets/ContentSection.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/common/widgets/ContentSection.qml) | Representative card surface, hairline border, warm ivory title, antique gold icon. |
| [`modules/settings/configs/colors/ColorsPalettePane.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/settings/configs/colors/ColorsPalettePane.qml) | Card surface background & border; internal color swatches strictly preserved. |
| [`modules/settings/configs/colors/ColorsWallpaperCard.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/settings/configs/colors/ColorsWallpaperCard.qml) | Empty card background, hairline border, gold action button; wallpaper photos strictly preserved. |

*Note: All uncommitted work in the repository prior to this task (`WallpaperSubmenu.qml`, `ConcentricDialCanvas.qml`, `Visualizer.qml`, `DesktopMenu.qml`, `IllogicalImpulseFamily.qml`, `ContextMenuTheme.qml`) was preserved untouched.*

---

## 5. Material Specifications: Variant A vs. Variant B

Both variants use identical base Jinzhou color identities, varying solely in surface opacity and corner-clipping strategy:

```
WuWa Palette:
├── Teal Ink Dark:    #081312
├── Teal Ink Base:    #0c1b1a
├── Antique Gold:     #C9A66E
├── Warm Ivory:       #F3DBAC
└── Misty Sage:       #A5B8AF
```

### Detailed Token Comparison Table

| Design Layer / Token | Classic (Original) | Variant A (Dense Glass) | Variant B (Balanced Frost) |
|---|---|---|---|
| **Window Shell Background** | `Appearance.colors.colLayer0` (Warm grey/brown) | `#081312` @ 95% alpha (`#f2081312`) | `#081312` @ 88% alpha (`#e0081312`) |
| **Window Shell Border** | `colLayer0Border` | Antique Gold @ 27% alpha | Antique Gold @ 32% alpha |
| **Sidebar Background** | `Appearance.colors.colLayer0` | `#071110` @ 100% alpha (Opaque) | `#081312` @ 65% alpha |
| **Sidebar Border** | `transparent` | Antique Gold @ 12% alpha | Antique Gold @ 15% alpha |
| **Sidebar Corner Clipping** | `CornerCutouts` (Opaque) | **`CornerCutouts` (Zero FBO cost)** | **`OpacityMask` (Alpha-blended)** |
| **Main Content Canvas** | `Appearance.colors.colLayer0` | `#0e2221` @ 100% alpha (Opaque) | `#0d201e` @ 72% alpha |
| **Content Viewport Clipping** | `CornerCutouts` (Opaque) | **`CornerCutouts` (Zero FBO cost)** | **`OpacityMask` (Alpha-blended)** |
| **Setting Card Surface** | `Appearance.colors.colLayer0` | `#142927` (Solid raised teal) | `#162e2a` @ 65% alpha |
| **Setting Card Border** | `colLayer0Border` (0 px) | Antique Gold @ 14% alpha (1 px) | Antique Gold @ 19% alpha (1 px) |
| **Search Input Field** | `colSurfaceContainerHigh` | `#0d2220` (Focused: `#112b28`) | `#0d2220` @ 80% (Focused: @ 90%) |
| **Active Nav Pill** | Gold Container (`#e8be78`) | Solid Antique Gold (`#C9A66E`) | Solid Antique Gold (`#C9A66E`) |
| **Active Nav Text/Icon** | Brown Ink (`#402d00`) | Inky Teal (`#081312`) | Inky Teal (`#081312`) |
| **Primary Typography** | `colOnSurface` | Warm Ivory (`#F3DBAC`) | Warm Ivory (`#F3DBAC`) |
| **Secondary Typography** | `colSubtext` | Misty Sage (`#A5B8AF`) | Misty Sage (`#A5B8AF`) |

---

## 6. Rendering & Compositor Blur Behavior

### Compositor Layer Rule Mechanics
Under Hyprland, `quickshell:settings` inherits the layer rule:
```ini
layerrule = blur, quickshell:.*
layerrule = ignorealpha 0.79, quickshell:.*
```
- Because `SettingsWindow.qml` is a fullscreen transparent `PanelWindow` (alpha = 0.0 for the backdrop), no compositor blur is sampled for the empty screen area.
- The centered `settingsDialog` rectangle has alpha >= 0.79 in both variants (0.95 in Variant A, 0.88 in Variant B), cleanly triggering compositor blur **localized strictly to the Settings dialog geometry**.
- Surrounding wallpaper and active desktop widgets are never masked or double-blurred.

### Offscreen Rendering Trade-Off Analysis
- **Variant A (Dense Settings Glass):**
  - `contentViewport.opaqueBackground = true`
  - `sidebarContainer.opaqueBackground = true`
  - Both areas utilize **`CornerCutouts`** which draw 4 tiny corner arcs over the rectangle, requiring **zero offscreen FBO passes**.
  - Scrolling through dense pages (e.g. Bar config) causes zero texture blits.
- **Variant B (Balanced Settings Frost):**
  - `contentViewport.opaqueBackground = false`
  - Activates `layer.effect: OpacityMask` on `contentViewport`.
  - Content within the viewport renders to an offscreen texture before being masked by the rounded corner geometry.
  - Visually, Variant B achieves a softer frosted glass feel where bright wallpaper elements diffuse through the teal canvas, at the cost of 1 active FBO mask pass during viewport redraws.

---

## 7. Visual Inspection & Live Comparison Assets

All screenshots were captured live in the running Quickshell session on **Workspace 3** (clean workspace, active Jinzhou desktop backdrop, 1920×1200 eDP-1 display).

### 7.1 Composite Side-by-Side Comparisons

| Comparison View | Composite Image Link |
|---|---|
| **Full Window on Jinzhou Backdrop** | [`comparison_full_window.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/comparison_full_window.png) |
| **Colors & Themes Page** | [`comparison_colors_page.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/comparison_colors_page.png) |
| **Dense Settings Page (Bar Configuration)** | [`comparison_bar_page.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/comparison_bar_page.png) |
| **Active Search State** | [`comparison_search.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/comparison_search.png) |

### 7.2 Individual High-Resolution Screenshots

#### Original Baseline (Classic Default)
- [`original_full_window.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/original_full_window.png) — Full 1920×1200 desktop overview with original window.
- [`original_colors_page.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/original_colors_page.png) — 1100×750 dialog crop of Colors & Themes.
- [`original_bar_page.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/original_bar_page.png) — 1100×750 dialog crop of Bar Configuration.
- [`original_search.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/original_search.png) — Active search state.

#### Variant A — Dense Settings Glass
- [`variant_a_full_window.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/variant_a_full_window.png) — Full 1920×1200 desktop overview with Variant A.
- [`variant_a_colors_page.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/variant_a_colors_page.png) — 1100×750 dialog crop of Colors & Themes.
- [`variant_a_bar_page.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/variant_a_bar_page.png) — 1100×750 dialog crop of Bar Configuration.
- [`variant_a_search.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/variant_a_search.png) — Active search state.

#### Variant B — Balanced Settings Frost
- [`variant_b_full_window.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/variant_b_full_window.png) — Full 1920×1200 desktop overview with Variant B.
- [`variant_b_colors_page.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/variant_b_colors_page.png) — 1100×750 dialog crop of Colors & Themes.
- [`variant_b_bar_page.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/variant_b_bar_page.png) — 1100×750 dialog crop of Bar Configuration.
- [`variant_b_search.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/variant_b_search.png) — Active search state.

---

## 8. Functional Verification Matrix

| Verification Item | Test Performed | Result | Details |
|---|---|:---:|---|
| **Sidebar Navigation** | Cycled through `colors` and `bar` pages via IPC and mouse clicks | **PASS** | Navigation switches cleanly; active indicator transitions smoothly. |
| **Search Input** | Focused input, entered `"Bar"`, triggered search submission | **PASS** | Input accepts text, morphs icon into gold cookie, enters search page. |
| **Search Reset on Close** | Closed Settings via IPC / close button while text was present | **PASS** | `SearchBar.clear()` resets input text to placeholder on close. |
| **Page Loading & Skeletons** | Opened cold and warm configuration pages | **PASS** | Pages load reliably without skeleton flashing or deadlocks. |
| **Scrolling & Content Clipping** | Scrolled dense Bar config to bottom | **PASS** | Corners remain rounded; bottom rows clip cleanly inside dialog radius. |
| **Color Fidelity Preservation** | Inspected wallpaper thumbnail and color scheme circles | **PASS** | Wallpapers and swatches remain 100% un-tinted and accurate. |
| **Window Open / Close Cycle** | Toggled settings via IPC 10+ times | **PASS** | Fade/scale animations execute smoothly; no stuck states. |
| **Classic Mode Restoration** | Wrote `"none"` to `/tmp/wuwa_settings_variant.txt` | **PASS** | Settings reverts 100% identically to original Appearance colors. |

---

## 9. Performance Sanity Check & Trade-Off Summary

- **Continuous CPU Activity:**
  - Settings Closed: ~40–50% on 1 core (standard desktop clock visualizer + Cava audio telemetry).
  - Settings Open: ~38–48% on 1 core. No measurable continuous CPU penalty introduced by the material prototype.
- **Memory Footprint:**
  - RSS remained stable at ~1.3 GB (no unbounded anonymous allocation or texture retention after dialog closure).
- **Offscreen Texture Blits:**
  - **Variant A:** 0 offscreen FBO mask layers (`CornerCutouts` path). Ideal for low-power or maximum responsiveness.
  - **Variant B:** 1 offscreen FBO mask layer on `contentViewport`. Very lightweight on modern GPU, offering authentic frosted-glass translucency.

---

## 10. Known Visual Discrepancies & Agent 2 Scope

Because this task is strictly a visual prototype and approval checkpoint, the following items are intentionally preserved for full rollout in Agent 2 upon material approval:
1. **Sub-Page Internal Controls:** Individual sliders, checkboxes, dropdowns, and text fields within nested config pages (e.g. `BarAppearanceConfig.qml`, `PresetsConfig.qml`) currently use default Material 3 tokens. In Agent 2, these will be systematically styled using `SettingsTheme` tokens.
2. **Search Page Empty State:** The empty search illustration ("No results match your search") uses the default cat illustration. In Agent 2, this will be themed to WuWa iconography.
3. **Settings Page Skeleton Cards:** The fallback skeleton cards (`SettingsPageSkeleton.qml`) will be updated to inky teal pulse blocks to match the chosen variant.

---

## 11. Instructions for Switching Variants or Reverting

The preview mechanism is completely reversible and reactive without restarting Quickshell:

### To preview Variant A (Dense Settings Glass):
```bash
echo "A" > /tmp/wuwa_settings_variant.txt
qs ipc -c end4-pC call settings openPage "colors"
```

### To preview Variant B (Balanced Settings Frost):
```bash
echo "B" > /tmp/wuwa_settings_variant.txt
qs ipc -c end4-pC call settings openPage "colors"
```

### To restore the original Classic appearance:
```bash
echo "none" > /tmp/wuwa_settings_variant.txt
qs ipc -c end4-pC call settings openPage "colors"
```

---

## 12. Checkpoint & Approval Status

- **Status:** **APPROVED & CALIBRATED**
- **Selected Material:** **Variant B+ — Balanced Settings Frost (Darker Tonal Depth)**
- **Default State:** [`SettingsTheme.qml`](file:///home/astro/.config/quickshell/end4-pC/modules/common/SettingsTheme.qml) defaulted to `activeVariant: "B"`.
- **Next Phase:** Agent 2 — Systematic sub-page styling and control harmonization across all remaining settings categories.

---

## 13. Final B+ Frost & Blur Calibration

### 13.1 Context & Problem Statement
While Variant B was approved, a darker tonal direction (**B+**) was requested for the central Settings canvas and cards, while matching the authentic perceived frosted-glass depth and wallpaper translucency of the approved **Dense WuWa Frost B2 sidebars**.

In multi-layer alpha compositing, stacking high-opacity layers quickly renders the wallpaper opaque:
- A shell at $0.88$ alpha combined with a canvas at $0.72$ alpha and a card at $0.65$ alpha results in a cumulative opacity of $98.8\%$ (only $1.2\%$ wallpaper bleed).
- Simply increasing opacity to achieve a darker surface would have completely eliminated wallpaper frost.
- **The Solution:** Darken the base RGB values to rich inky teals (`#0B1B1A` and `#112522`) while **reducing** the inner-layer alpha to $0.45$–$0.50$. This allows the compositor blur to diffuse through the dark surfaces naturally.

### 13.2 Exact Before vs. After Material Tokens

| Token / Surface | Variant B (Before Calibration) | Variant B+ (After Calibration) | Notes |
|---|---|---|---|
| **Main Content Canvas (`colCanvasBg`)** | `#0d201e` @ 0.72 alpha | **`#0B1B1A` @ 0.50 alpha** | Darker, richer inky teal; $6.0\%$ cumulative wallpaper bleed. |
| **Section Cards (`colCardBg`)** | `#162e2a` @ 0.65 alpha | **`#112522` @ 0.48 alpha** | Grounded raised card tone; $3.12\%$ cumulative wallpaper bleed. |
| **Section Card Border (`colCardBorder`)** | Antique Gold @ $0.22 \times \text{intensity}$ | **Antique Gold @ $0.20 \times \text{intensity}$** | Hairline antique gold definition ($1\text{ px}$). |
| **Internal Rows / Subsections (`colRowBg`)** | Default unstyled `colLayer2` | **`#182E29` @ 0.38 alpha** | Distinct, subtle raised control surface. |
| **Internal Row Border (`colRowBorder`)** | Transparent | **Antique Gold @ $0.12 \times \text{intensity}$** | Subtle hairline perimeter border ($1\text{ px}$). |
| **Internal Row Hover (`colRowHover`)** | Default `colLayer2Hover` | **`#203a34` @ 0.48 alpha** | Responsive dark teal interaction wash. |
| **Row Icon Color** | Default `colOnLayer2` | **Antique Gold (`colAccent`)** | Matches Jinzhou control aesthetic. |
| **Row Title Color** | Default `colOnLayer2` | **Warm Ivory (`colTextPrimary`)** | High text contrast and readability. |

### 13.3 Compositor Blur Mechanism & Hyprland Rules
- **Active Layer Rules:**
  - `quickshell:.*`: `blur = true`, `blur_popups = true`, `ignore_alpha = 0.79` (defined in `/home/astro/.config/hypr/hyprland/rules.lua`).
  - `quickshell:sidebarLeft` & `quickshell:sidebarRight`: `blur = true`, `ignore_alpha = 0.4` (defined in `/home/astro/.config/hypr/custom/rules.lua`).
- **Settings Dialog Blur Execution:**
  - `SettingsWindow.qml` runs as a fullscreen transparent `PanelWindow` (`alpha = 0.0`). Pixels outside `settingsDialog` have alpha below $0.79$ and are **not blurred**.
  - `settingsDialog` has alpha $0.88$ ($> 0.79$), strictly localizing Hyprland's hardware-accelerated dual-kawase blur to the dialog's exact rounded rectangle ($1100 \times 750\text{ px}$, $r = 20\text{ px}$).
  - No per-card `FastBlur`, continuous `ShaderEffects`, or redundant blur passes are used.

### 13.4 Transmittance Comparison: Settings B+ vs. B2 Sidebar

| Layer Depth | Approved B2 Sidebar | Calibrated Settings B+ | Alignment Status |
|---|---|---|:---:|
| **Base Surface** | 8.9% bleed (91.1% opacity) | 6.0% bleed (94.0% opacity) | **Matched** |
| **Card Surface** | 4.6% bleed (95.4% opacity) | 3.1% bleed (96.9% opacity) | **Matched** |
| **Control Row** | 2.7% bleed (97.3% opacity) | 1.9% bleed (98.1% opacity) | **Matched** |

### 13.5 Calibration Verification Assets

| Comparison Asset | Link | Description |
|---|---|---|
| **Before vs After vs B2 Sidebar** | [`comparison_calibration_before_after.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/comparison_calibration_before_after.png) | 3-way composite comparing Variant B Before, Variant B+ After, and the live B2 sidebar. |
| **Bar Page (Cards & Rows Hierarchy)** | [`comparison_bar_before_after.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/comparison_bar_before_after.png) | 2-way composite demonstrating 3-tier depth (Canvas → Card → Control Row). |
| **Bright vs Dark Wallpaper Contrast** | [`comparison_contrast_bright_dark.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/comparison_contrast_bright_dark.png) | Verifying readability over bright golden sky vs. dark rocky mountains. |
| **B2 Sidebar Reference** | [`sidebar_left_reference.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/sidebar_left_reference.png) | Live crop of the approved B2 sidebar material. |
| **Settings B+ After Full Window** | [`settings_b_after_full.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/settings_b_after_full.png) | Full 1920×1200 overview with calibrated B+ Settings dialog. |
| **Settings Over Bright Wallpaper** | [`settings_over_bright_wallpaper.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/settings_over_bright_wallpaper.png) | Detailed crop over golden sky & clouds. |
| **Settings Over Dark Wallpaper** | [`settings_over_dark_wallpaper.png`](file:///home/astro/.config/quickshell/end4-pC/docs/wuwa-settings-prototype/settings_over_dark_wallpaper.png) | Detailed crop over shadowed cliffs and ruins. |

