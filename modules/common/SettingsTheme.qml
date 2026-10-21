pragma Singleton

import QtQuick
import Quickshell
import qs.modules.common
import qs.modules.common.functions

/**
 * SettingsTheme: Settings-local WuWa Material System Adapter
 *
 * Provides finalized B+ calibrated frosted glass material tokens for Settings.
 * Fully integrated with the approved WuWa B2 Jinzhou design language:
 * - Deep inky teal (#081312 / #0B1B1A)
 * - Antique gold (#C9A66E)
 * - Warm ivory (#F3DBAC)
 * - Misty sage (#A5B8AF)
 *
 * Driven by ResonanceTheme.enabled:
 * - When WuWa is enabled: applies approved B+ Balanced Settings Frost material.
 * - When WuWa is disabled: reverts cleanly to Classic Appearance tokens.
 */
Singleton {
    id: root

    // =========================================================================
    // THEME STATE CONTROLLER
    // =========================================================================
    readonly property bool isWuWa: ResonanceTheme.enabled

    // =========================================================================
    // BASE PALETTE (Approved WuWa B2 Tokens)
    // =========================================================================
    readonly property color colTealInk: ResonanceTheme.colTealInk         // #0c1b1a
    readonly property color colTealInkDark: "#081312"                     // #081312 (calibrated dense base)
    readonly property color colAntiqueGold: ResonanceTheme.colAntiqueGold // #C9A66E
    readonly property color colWarmIvory: ResonanceTheme.colWarmIvory     // #F3DBAC
    readonly property color colMistySage: ResonanceTheme.colMistySage     // #A5B8AF
    readonly property color colMistySageDark: "#6E8279"                   // #6E8279
    readonly property real intensity: ResonanceTheme.intensity            // ~0.85

    // =========================================================================
    // WINDOW SHELL & BORDERS (Approved B+ Material)
    // =========================================================================
    // Outer dialog card background: #081312 at 0.88 alpha
    readonly property color colWindowShell: !isWuWa
        ? Appearance.colors.colLayer0
        : ColorUtils.applyAlpha(colTealInkDark, 0.88)

    // Outer hairline perimeter border (antique gold):
    readonly property color colWindowBorder: !isWuWa
        ? Appearance.colors.colLayer0Border
        : ColorUtils.applyAlpha(colAntiqueGold, 0.38 * intensity)

    // =========================================================================
    // SIDEBAR / NAVIGATION AREA (Approved Variant B Material)
    // =========================================================================
    // Navigation container background: #081312 at 0.65 alpha
    readonly property color colSidebarBg: !isWuWa
        ? Appearance.colors.colLayer0
        : ColorUtils.applyAlpha(colTealInkDark, 0.65)

    readonly property color colSidebarBorder: !isWuWa
        ? "transparent"
        : ColorUtils.applyAlpha(colAntiqueGold, 0.18 * intensity)

    readonly property bool sidebarOpaque: !isWuWa
        ? (Appearance.colors.colLayer0.a >= 1)
        : false

    readonly property color colSidebarCutout: !isWuWa
        ? Appearance.colors.colLayer0
        : colSidebarBg

    // =========================================================================
    // MAIN CONTENT CANVAS (Approved B+ Calibrated Material)
    // =========================================================================
    // Content canvas background: #0B1B1A at 0.50 alpha
    readonly property color colCanvasBg: !isWuWa
        ? Appearance.colors.colLayer0
        : ColorUtils.applyAlpha("#0B1B1A", 0.50)

    readonly property bool canvasOpaque: !isWuWa
        ? (Appearance.colors.colLayer0.a >= 1)
        : false

    readonly property color colCanvasCutout: !isWuWa
        ? Appearance.colors.colLayer0
        : colCanvasBg

    // =========================================================================
    // SETTING CARDS (ContentSection, ColorsPalettePane)
    // =========================================================================
    // Raised setting cards: #112522 at 0.48 alpha
    readonly property color colCardBg: !isWuWa
        ? Appearance.colors.colLayer0
        : ColorUtils.applyAlpha("#112522", 0.48)

    readonly property real cardBorderWidth: isWuWa ? 1 : 0
    // Section borders: antique gold at 0.20 * intensity
    readonly property color colCardBorder: !isWuWa
        ? Appearance.colors.colLayer0Border
        : ColorUtils.applyAlpha(colAntiqueGold, 0.20 * intensity)

    // =========================================================================
    // INTERNAL CONTROL ROWS & SUBSECTIONS (ContentSubsection)
    // =========================================================================
    // Internal row surfaces: #182E29 at 0.38 alpha
    readonly property color colRowBg: !isWuWa
        ? Appearance.colors.colLayer2
        : ColorUtils.applyAlpha("#182E29", 0.38)

    // Row hover: #203A34 at 0.48 alpha
    readonly property color colRowHover: !isWuWa
        ? Appearance.colors.colLayer2Hover
        : ColorUtils.applyAlpha("#203a34", 0.48)

    readonly property real rowBorderWidth: isWuWa ? 1 : 0
    // Row borders: antique gold at 0.12 * intensity
    readonly property color colRowBorder: !isWuWa
        ? "transparent"
        : ColorUtils.applyAlpha(colAntiqueGold, 0.12 * intensity)

    // =========================================================================
    // NAVIGATION ITEMS (SidebarNavButton)
    // =========================================================================
    // Active navigation pill (solid antique gold):
    readonly property color colNavActive: isWuWa
        ? colAntiqueGold
        : Appearance.colors.colPrimary

    readonly property color colNavActiveHover: isWuWa
        ? Qt.lighter(colAntiqueGold, 1.08)
        : Appearance.colors.colPrimaryHover

    readonly property color colNavOnActive: isWuWa
        ? colTealInkDark
        : Appearance.colors.colOnPrimary

    // Inactive navigation pill:
    readonly property color colNavInactive: isWuWa
        ? ColorUtils.applyAlpha(colTealInkDark, 0.35)
        : Appearance.colors.colLayer2

    readonly property color colNavHover: isWuWa
        ? ColorUtils.applyAlpha(colAntiqueGold, 0.16 * intensity)
        : Appearance.colors.colLayer2Hover

    readonly property color colNavBorder: isWuWa
        ? ColorUtils.applyAlpha(colAntiqueGold, 0.10 * intensity)
        : "transparent"

    // =========================================================================
    // HEADER CONTROLS (UserHeader, SearchBar)
    // =========================================================================
    // Input / Search field:
    readonly property color colSearchField: isWuWa
        ? ColorUtils.applyAlpha(colTealInkDark, 0.60)
        : Appearance.colors.colLayer1

    readonly property color colSearchFieldFocused: isWuWa
        ? ColorUtils.applyAlpha(colTealInkDark, 0.75)
        : Appearance.colors.colLayer1

    // Pill backgrounds (user header, close button, search icon):
    readonly property color colItemBg: isWuWa
        ? ColorUtils.applyAlpha(colTealInkDark, 0.65)
        : Appearance.colors.colLayer2

    // =========================================================================
    // TYPOGRAPHY & ACCENTS
    // =========================================================================
    // Primary typography: #F3DBAC
    readonly property color colTextPrimary: isWuWa ? colWarmIvory : Appearance.colors.colOnLayer1
    // Secondary typography: #A5B8AF
    readonly property color colTextSecondary: isWuWa ? colMistySage : Appearance.colors.colSubtext
    // Accent gold: #C9A66E
    readonly property color colAccent: isWuWa ? colAntiqueGold : Appearance.colors.colPrimary
    readonly property color colBorderFocused: isWuWa ? ColorUtils.applyAlpha(colAntiqueGold, 0.65 * intensity) : "transparent"

    // =========================================================================
    // REUSABLE CONTROLS & INTERACTION TOKENS (Switches, Sliders, Dropdowns, etc.)
    // =========================================================================
    // Switch & Slider Track
    readonly property color colTrackInactive: isWuWa
        ? ColorUtils.applyAlpha(colTealInkDark, 0.70)
        : (Appearance?.colors.colSurfaceContainerHighest ?? "#45464F")

    readonly property color colTrackBorder: isWuWa
        ? ColorUtils.applyAlpha(colAntiqueGold, 0.20 * intensity)
        : "transparent"

    // Switch Thumb
    readonly property color colThumbActive: isWuWa
        ? colTealInkDark
        : Appearance.m3colors.m3onPrimary

    readonly property color colThumbInactive: isWuWa
        ? colMistySageDark
        : Appearance.m3colors.m3outline

    // Slider Handle & Dots
    readonly property color colSliderDot: isWuWa
        ? ColorUtils.applyAlpha(colMistySage, 0.50)
        : Appearance.m3colors.m3onSecondaryContainer

    readonly property color colSliderDotActive: isWuWa
        ? colTealInkDark
        : Appearance.m3colors.m3onPrimary

    // Dropdown & Selection Surfaces (Deep Teal)
    readonly property color colControlBg: isWuWa
        ? ColorUtils.applyAlpha(colTealInkDark, 0.60)
        : Appearance.colors.colSecondaryContainer

    readonly property color colControlBgHover: isWuWa
        ? ColorUtils.applyAlpha("#203a34", 0.70)
        : Appearance.colors.colSecondaryContainerHover

    readonly property color colControlBgActive: isWuWa
        ? ColorUtils.applyAlpha(colAntiqueGold, 0.25 * intensity)
        : Appearance.colors.colSecondaryContainerActive

    readonly property color colControlBorder: isWuWa
        ? ColorUtils.applyAlpha(colAntiqueGold, 0.18 * intensity)
        : "transparent"

    // Selection Group / Option Buttons (Toggled = Gold, Untoggled = Deep Teal)
    readonly property color colOptionSelected: isWuWa
        ? colAntiqueGold
        : Appearance.colors.colPrimary

    readonly property color colOptionSelectedHover: isWuWa
        ? Qt.lighter(colAntiqueGold, 1.08)
        : Appearance.colors.colPrimaryHover

    readonly property color colOptionOnSelected: isWuWa
        ? colTealInkDark
        : Appearance.colors.colOnPrimary

    // Popup Menu Surface (Dropdown list)
    readonly property color colPopupBg: isWuWa
        ? ColorUtils.applyAlpha(colTealInkDark, 0.95)
        : Appearance.m3colors.m3surfaceContainerHigh

    readonly property color colPopupBorder: isWuWa
        ? ColorUtils.applyAlpha(colAntiqueGold, 0.28 * intensity)
        : "transparent"

    // Control Icon Container / Badge
    readonly property color colControlIconBg: isWuWa
        ? ColorUtils.applyAlpha(colTealInkDark, 0.60)
        : Appearance.colors.colLayer3

    readonly property color colControlIconActiveBg: isWuWa
        ? colAntiqueGold
        : Appearance.colors.colPrimaryContainer

    readonly property color colControlIconOnActive: isWuWa
        ? colTealInkDark
        : Appearance.colors.colOnPrimaryContainer
}
