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
    // Main floating card surface:
    // In WuWa mode: Deep inky teal glass, matching top-bar popup material language
    // with calibrated opacity for high readability over bright wallpapers.
    // In classic mode: Exact existing Appearance.colors.colLayer0.
    readonly property color colBackground: isWuWa
        ? ResonanceTheme.alpha(ResonanceTheme.colTealInk, Math.min(0.88, 0.76 + 0.08 * ResonanceTheme.intensity))
        : Appearance.colors.colLayer0

    // Elevated cards inside menu (e.g. wallpaper recents card, submenu sections):
    readonly property color colCardBackground: isWuWa
        ? ResonanceTheme.bgGlassPopupCard
        : Appearance.colors.colLayer1

    readonly property color colCardBackgroundSubtle: isWuWa
        ? ResonanceTheme.bgGlassSubtle
        : Appearance.colors.colLayer0

    // Action row normal state:
    readonly property color colRowBackground: isWuWa
        ? ResonanceTheme.alpha(ResonanceTheme.colTealInk, 0.25 * ResonanceTheme.intensity)
        : "transparent"

    // Action row hover state (slightly raised/illuminated gold-tinted teal):
    readonly property color colRowBackgroundHover: isWuWa
        ? ResonanceTheme.bgGlassPopupCardHover
        : Appearance.colors.colLayer1Hover

    // Action row active state (antique-gold active emphasis):
    readonly property color colRowBackgroundActive: isWuWa
        ? ResonanceTheme.bgGlassPopupCardActive
        : Appearance.colors.colLayer1Active

    readonly property color colRipple: isWuWa
        ? ResonanceTheme.accentGold
        : Appearance.colors.colLayer1Active

    // Separators / Dividers:
    readonly property color colDivider: isWuWa
        ? ResonanceTheme.bgGlassPopupDivider
        : Appearance.colors.colOutlineVariant

    readonly property real dividerOpacity: isWuWa ? 1.0 : 0.5

    // =========================================================================
    // BORDERS & HAIRLINES
    // =========================================================================
    // Hairline antique gold perimeter:
    readonly property real borderWidth: isWuWa ? 1 : 0
    readonly property color colBorder: isWuWa
        ? ResonanceTheme.borderHairline
        : Appearance.colors.colLayer0Border

    // Inner card border:
    readonly property real cardBorderWidth: isWuWa ? 1 : 0
    readonly property color colCardBorder: isWuWa
        ? ResonanceTheme.borderSubtle
        : "transparent"

    // Row border:
    readonly property real rowBorderWidth: isWuWa ? 1 : 0
    readonly property color colRowBorder: isWuWa
        ? ResonanceTheme.alpha(ResonanceTheme.colMistySage, 0.12 * ResonanceTheme.intensity)
        : "transparent"

    readonly property color colRowBorderHover: isWuWa
        ? ResonanceTheme.borderSubtle
        : "transparent"

    // =========================================================================
    // CORNER GEOMETRY
    // =========================================================================
    readonly property real radiusMenu: Appearance.rounding.large
    readonly property real radiusCard: Appearance.rounding.large
    readonly property real radiusRow: ContextMenus.compact ? Appearance.rounding.small : Appearance.rounding.normal

    // =========================================================================
    // TYPOGRAPHY & ICONOGRAPHY
    // =========================================================================
    // Warm ivory primary text:
    readonly property color colTextPrimary: isWuWa ? ResonanceTheme.textPrimary : Appearance.colors.colOnSurface
    // Misty sage secondary text / icons:
    readonly property color colTextSecondary: isWuWa ? ResonanceTheme.textSecondary : Appearance.colors.colOnSurfaceVariant
    readonly property color colTextTertiary: isWuWa ? ResonanceTheme.textTertiary : Appearance.colors.colSubtext
    // Restrained antique gold accent for highlights / chevrons:
    readonly property color colAccent: isWuWa ? ResonanceTheme.accentGold : Appearance.colors.colPrimary
    readonly property color colIcon: isWuWa ? ResonanceTheme.colWarmIvory : Appearance.colors.colOnSurface
    readonly property color colIconAccent: isWuWa ? ResonanceTheme.accentGold : Appearance.colors.colPrimary
    readonly property color colChevron: isWuWa ? ResonanceTheme.accentGold : Appearance.colors.colOnSurfaceVariant

    // Disabled state:
    readonly property real disabledOpacity: 0.38
}
