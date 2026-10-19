pragma Singleton

import QtQuick
import Quickshell
import qs.modules.common
import qs.modules.common.functions

Singleton {
    id: root

    // =========================================================================
    // CONFIGURATION BINDINGS
    // =========================================================================
    readonly property bool enabled: Config.ready
        ? (Config.options.appearance.wuwaTheme.enabled ?? false)
        : false

    readonly property string paletteMode: {
        if (!Config.ready) return "fixed";
        const mode = Config.options.appearance.wuwaTheme.paletteMode;
        return mode === "theme" ? "theme" : "fixed";
    }

    // Safe, normalized, finite clamped intensity (default restrained 0.85)
    readonly property real intensity: {
        if (!Config.ready) return 0.85;
        const val = Number(Config.options.appearance.wuwaTheme.intensity ?? 0.85);
        return isFinite(val) ? Math.max(0.0, Math.min(1.0, val)) : 0.85;
    }

    readonly property string configuredMotionMode: {
        if (!Config.ready) return "normal";
        const mode = Config.options.appearance.wuwaTheme.motionMode;
        if (mode === "ambient" || mode === "off") return mode;
        return "normal";
    }

    // Automatically honor system / shell reduced motion
    readonly property string effectiveMotionMode: Appearance.reducedMotion
        ? "off"
        : root.configuredMotionMode

    readonly property bool motionNormal: effectiveMotionMode === "normal"
    readonly property bool motionAmbient: effectiveMotionMode === "ambient"
    readonly property bool motionOff: effectiveMotionMode === "off"

    // =========================================================================
    // FIXED JINZHOU PALETTE (Raw design specifications)
    // =========================================================================
    readonly property color fixedTealInk: "#142826"       // Deep glass / teal ink
    readonly property color fixedMistySage: "#A5B8AF"     // Misty sage
    readonly property color fixedAntiqueGold: "#C9A66E"   // Antique gold
    readonly property color fixedWarmIvory: "#F3DBAC"     // Warm ivory
    readonly property color fixedThermalOrange: "#D17C55" // Thermal / warning orange

    // =========================================================================
    // THEME-ADAPTIVE PALETTE (Derived from Appearance.colors / Matugen)
    // =========================================================================
    readonly property color themeTealInk: (Appearance.colors && Appearance.colors.colLayer0) ? Appearance.colors.colLayer0 : "#142826"
    readonly property color themeMistySage: (Appearance.colors && Appearance.colors.colSecondary) ? Appearance.colors.colSecondary : "#A5B8AF"
    readonly property color themeAntiqueGold: (Appearance.colors && Appearance.colors.colPrimary) ? Appearance.colors.colPrimary : "#C9A66E"
    readonly property color themeWarmIvory: (Appearance.colors && Appearance.colors.colOnLayer0) ? Appearance.colors.colOnLayer0 : "#F3DBAC"
    readonly property color themeThermalOrange: (Appearance.m3colors && Appearance.m3colors.m3error) ? Appearance.m3colors.m3error : ((Appearance.colors && Appearance.colors.colError) ? Appearance.colors.colError : "#D17C55")

    // Active base colors switching on paletteMode ("fixed" vs "theme")
    readonly property bool isFixedPalette: root.paletteMode === "fixed"

    readonly property color colTealInk: root.isFixedPalette ? root.fixedTealInk : root.themeTealInk
    readonly property color colMistySage: root.isFixedPalette ? root.fixedMistySage : root.themeMistySage
    readonly property color colAntiqueGold: root.isFixedPalette ? root.fixedAntiqueGold : root.themeAntiqueGold
    readonly property color colWarmIvory: root.isFixedPalette ? root.fixedWarmIvory : root.themeWarmIvory
    readonly property color colThermalOrange: root.isFixedPalette ? root.fixedThermalOrange : root.themeThermalOrange

    // =========================================================================
    // SEMANTIC ROLES FOR COMPONENTS
    // =========================================================================
    // Surface & Glass
    readonly property color bgGlass: ColorUtils.applyAlpha(colTealInk, 0.72 * root.intensity)
    readonly property color bgGlassElevated: ColorUtils.applyAlpha(colTealInk, 0.85 * root.intensity)
    readonly property color bgGlassPill: ColorUtils.applyAlpha(colTealInk, Math.min(0.94, 0.76 + 0.08 * root.intensity))
    readonly property color bgGlassSubtle: ColorUtils.applyAlpha(colTealInk, 0.40 * root.intensity)

    // Borders & Hairlines
    readonly property color borderHairline: ColorUtils.applyAlpha(colAntiqueGold, 0.35 * root.intensity)
    readonly property color borderAccent: ColorUtils.applyAlpha(colAntiqueGold, 0.65 * root.intensity)
    readonly property color borderSubtle: ColorUtils.applyAlpha(colMistySage, 0.20 * root.intensity)

    // Typography Colors
    readonly property color textPrimary: colWarmIvory
    readonly property color textSecondary: colMistySage
    readonly property color textTertiary: ColorUtils.applyAlpha(colMistySage, 0.60)
    readonly property color textAccent: colAntiqueGold
    readonly property color textWarning: colThermalOrange

    // Typography Scale (Semantic numeric sizes based on Appearance.font.pixelSize)
    readonly property int fontMetricValue: (Appearance.font && Appearance.font.pixelSize && Appearance.font.pixelSize.hugeass) ? Appearance.font.pixelSize.hugeass : 23
    readonly property int fontMetricSubValue: (Appearance.font && Appearance.font.pixelSize && Appearance.font.pixelSize.large) ? Appearance.font.pixelSize.large : 17
    readonly property int fontTechnicalLabel: (Appearance.font && Appearance.font.pixelSize && Appearance.font.pixelSize.smaller) ? Appearance.font.pixelSize.smaller : 12
    readonly property int fontDetailText: (Appearance.font && Appearance.font.pixelSize && Appearance.font.pixelSize.small) ? Appearance.font.pixelSize.small : 15
    readonly property int fontMicroBadge: (Appearance.font && Appearance.font.pixelSize && Appearance.font.pixelSize.smallest) ? Appearance.font.pixelSize.smallest : 10

    // Semantic aliases
    readonly property int metricValue: fontMetricValue
    readonly property int metricSubValue: fontMetricSubValue
    readonly property int technicalLabel: fontTechnicalLabel
    readonly property int detailText: fontDetailText
    readonly property int microBadge: fontMicroBadge

    // Accents & Signals
    readonly property color accentGold: colAntiqueGold
    readonly property color accentGlow: ColorUtils.applyAlpha(colAntiqueGold, 0.25 * root.intensity)
    readonly property color warningOrange: colThermalOrange
    readonly property color crestHighlight: Qt.rgba(1.0, 0.95, 0.85, 0.90) // Gold-ivory crest

    // Meters & Tracks
    readonly property color trackMuted: ColorUtils.applyAlpha(colTealInk, 0.50)
    readonly property color trackBorder: ColorUtils.applyAlpha(colMistySage, 0.25)
    readonly property color trackFill: colAntiqueGold

    // =========================================================================
    // UTILITIES
    // =========================================================================
    function alpha(c: color, a: real): color {
        return ColorUtils.applyAlpha(c, Math.max(0.0, Math.min(1.0, a)));
    }
}
