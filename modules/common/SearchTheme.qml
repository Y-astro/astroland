pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.modules.common
import qs.modules.common.functions

Singleton {
    id: root

    readonly property bool isWuWa: ResonanceTheme.enabled

    // =========================================================================
    // SURFACE / BACKGROUND MATERIALS
    // =========================================================================
    // Shared outer Search container (deep teal frosted glass matching context menus):
    // Standard collapsed search pill & normal results view:
    readonly property color colContainer: isWuWa
        ? ResonanceTheme.alpha(ResonanceTheme.colTealInk, Math.min(0.88, 0.76 + 0.08 * ResonanceTheme.intensity))
        : Appearance.colors.colBackgroundSurfaceContainer

    // Denser frosted glass for large hosted panels (ensures high contrast and legibility):
    readonly property color colContainerDense: isWuWa
        ? ResonanceTheme.alpha(ResonanceTheme.colTealInkDark, Math.min(0.94, 0.86 + 0.06 * ResonanceTheme.intensity))
        : Appearance.colors.colBackgroundSurfaceContainer

    // Search input field background:
    // In WuWa mode: transparent by default to make the search field and expanded panel
    // feel like parts of one continuous surface. Focus state has a subtle golden wash.
    // In Classic mode: Appearance.colors.colLayer1.
    readonly property color colSearchField: isWuWa
        ? "transparent"
        : Appearance.colors.colLayer1

    readonly property color colSearchFieldFocused: isWuWa
        ? ResonanceTheme.alpha(ResonanceTheme.colAntiqueGold, 0.06 * ResonanceTheme.intensity)
        : Appearance.colors.colLayer1

    // Action feedback bar background:
    readonly property color colFeedbackBar: isWuWa
        ? ResonanceTheme.bgGlassPopupCardElevated
        : Appearance.colors.colSecondaryContainer

    // Skeleton row backgrounds:
    readonly property color colSkeletonRow: isWuWa
        ? ResonanceTheme.bgGlassPopupCard
        : Appearance.colors.colSurfaceContainerHigh

    readonly property color colSkeletonItem: isWuWa
        ? ResonanceTheme.bgGlassSubtle
        : Appearance.colors.colSurfaceContainerHighest

    // Result group slab background (expressive grouping):
    readonly property color colGroupSlab: isWuWa
        ? ResonanceTheme.bgGlassPopupCard
        : Appearance.colors.colSurfaceContainerHigh

    // Empty search state fallback chips:
    readonly property color colChipBackground: isWuWa
        ? ResonanceTheme.bgGlassPopupCard
        : Appearance.colors.colSurfaceContainerHigh

    readonly property color colChipBackgroundHover: isWuWa
        ? ResonanceTheme.bgGlassPopupCardHover
        : Appearance.colors.colSecondaryContainerHover

    readonly property color colChipRipple: isWuWa
        ? ResonanceTheme.accentGold
        : Appearance.colors.colSecondaryContainerActive

    // =========================================================================
    // BORDERS & HAIRLINES
    // =========================================================================
    readonly property real borderWidth: isWuWa ? 1 : 0

    // Antique-gold hairline perimeter border:
    readonly property color colBorder: isWuWa
        ? ResonanceTheme.borderHairline
        : "transparent"

    // Subtle search-focus accent on container perimeter:
    readonly property color colBorderFocused: isWuWa
        ? ResonanceTheme.borderAccent
        : "transparent"

    readonly property real cardBorderWidth: isWuWa ? 1 : 0
    readonly property color colCardBorder: isWuWa ? ResonanceTheme.borderSubtle : "transparent"

    // =========================================================================
    // TYPOGRAPHY & TEXT HIERARCHY
    // =========================================================================
    // Warm ivory primary / input text:
    readonly property color colTextPrimary: isWuWa ? ResonanceTheme.textPrimary : Appearance.colors.colOnLayer1
    // Misty sage placeholder / secondary text:
    readonly property color colTextSecondary: isWuWa ? ResonanceTheme.textSecondary : Appearance.colors.colSubtext
    readonly property color colTextTertiary: isWuWa ? ResonanceTheme.textTertiary : Appearance.colors.colSubtext
    // Restrained antique gold accent:
    readonly property color colAccent: isWuWa ? ResonanceTheme.accentGold : Appearance.colors.colPrimary
    readonly property color colIcon: isWuWa ? ResonanceTheme.accentGold : Appearance.colors.colOnSecondaryContainer

    // Selection styling:
    readonly property color colSelection: isWuWa ? ResonanceTheme.accentGold : Appearance.colors.colSecondaryContainer
    readonly property color colSelectionText: isWuWa ? ResonanceTheme.colTealInkDark : Appearance.colors.colOnSecondaryContainer

    // =========================================================================
    // SHADOW TREATMENT
    // =========================================================================
    // Disabled in WuWa mode to maintain pure frosted glass aesthetics and eliminate compositor halo artifacts:
    readonly property bool showShadow: !isWuWa && !Config.options.appearance.transparency.popups && !Config.options.appearance.transparency.enable
}
