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
    // SURFACE / BACKGROUND COLORS
    // =========================================================================
    readonly property color colBackground: isWuWa
        ? ResonanceTheme.bgGlassPopup
        : (Config.options.appearance.transparency.popups ? Appearance.colors.colLayer0 : Appearance.m3colors.m3surfaceContainer)

    readonly property color colCardBackground: isWuWa
        ? ResonanceTheme.bgGlassPopupCard
        : (Config.options.appearance.transparency.popups ? Appearance.colors.colLayer1 : Appearance.colors.colSurfaceContainerHigh)

    readonly property color colCardBackgroundLow: isWuWa
        ? ResonanceTheme.bgGlassSubtle
        : Appearance.colors.colSurfaceContainerLow

    readonly property color colCardBackgroundHover: isWuWa
        ? ResonanceTheme.bgGlassPopupCardHover
        : Appearance.colors.colSurfaceContainerHighest

    readonly property color colCardBackgroundActive: isWuWa
        ? ResonanceTheme.bgGlassPopupCardActive
        : Appearance.colors.colPrimaryContainer

    readonly property color colCardBackgroundElevated: isWuWa
        ? ResonanceTheme.bgGlassPopupCardElevated
        : (Config.options.appearance.transparency.popups ? Appearance.colors.colLayer2 : Appearance.colors.colSurfaceContainerHighest)

    readonly property color colDivider: isWuWa
        ? ResonanceTheme.bgGlassPopupDivider
        : Appearance.colors.colSurfaceContainerHighest

    // =========================================================================
    // BORDERS & HAIRLINES
    // =========================================================================
    readonly property real borderWidth: isWuWa
        ? 1
        : (Config.options.appearance.transparency.popups ? 0 : 1)

    readonly property color colBorder: isWuWa
        ? ResonanceTheme.borderHairline
        : (Config.options.appearance.transparency.popups ? "transparent" : Appearance.colors.colLayer0Border)

    readonly property real cardBorderWidth: isWuWa ? 1 : 0
    readonly property color colCardBorder: isWuWa ? ResonanceTheme.borderSubtle : "transparent"

    // =========================================================================
    // CORNER RADII
    // =========================================================================
    readonly property real radiusPopup: Appearance.rounding.large
    readonly property real radiusCard: Appearance.rounding.normal
    readonly property real radiusPill: Appearance.rounding.full
    readonly property real radiusSmall: Appearance.rounding.small

    // =========================================================================
    // TYPOGRAPHY & TEXT HIERARCHY
    // =========================================================================
    readonly property color colTextPrimary: isWuWa ? ResonanceTheme.textPrimary : Appearance.colors.colOnSurface
    readonly property color colTextSecondary: isWuWa ? ResonanceTheme.textSecondary : Appearance.colors.colOnSurfaceVariant
    readonly property color colTextTertiary: isWuWa ? ResonanceTheme.textTertiary : Appearance.colors.colSubtext
    readonly property color colTextWarning: isWuWa ? ResonanceTheme.textWarning : Appearance.colors.colError
    readonly property color colAccent: isWuWa ? ResonanceTheme.accentGold : Appearance.colors.colPrimary
    readonly property color colTextOnAccent: isWuWa ? ResonanceTheme.colTealInk : Appearance.colors.colOnPrimary

    // =========================================================================
    // METRICS & SPACING CONVENTIONS
    // =========================================================================
    readonly property real marginOuter: 10
    readonly property real paddingCard: 12
    readonly property real spacingVertical: 8
    readonly property real spacingHorizontal: 8
    readonly property real spacingHeader: 6

    // =========================================================================
    // SHADOW TREATMENT
    // =========================================================================
    // In WuWa mode, shadow is disabled to preserve pure frosted glass aesthetics
    // and prevent compositor shadow-blur artifacts with Hyprland layer blur.
    readonly property bool showShadow: !isWuWa && !Config.options.appearance.transparency.popups
}
