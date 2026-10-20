import qs.modules.common
import qs.modules.common.widgets
import QtQuick

GroupButton {
    id: button
    property string buttonIcon
    baseWidth: 40
    baseHeight: 40
    clickedWidth: baseWidth + 20
    toggled: false
    buttonRadius: (altAction && toggled) ? Appearance?.rounding.normal : Math.min(baseHeight, baseWidth) / 2
    buttonRadiusPressed: Appearance?.rounding?.small

    colBackground: "transparent"
    colBackgroundHover: ResonanceTheme.enabled ? ResonanceTheme.bgGlassSidebarItemHover : Appearance.colors.colLayer1Hover
    colBackgroundActive: ResonanceTheme.enabled ? ResonanceTheme.bgGlassSidebarItemActive : Appearance.colors.colLayer1Active
    colBackgroundToggled: ResonanceTheme.enabled ? ResonanceTheme.accentGold : Appearance.colors.colPrimary
    colBackgroundToggledHover: ResonanceTheme.enabled ? ResonanceTheme.accentGold : Appearance.colors.colPrimaryHover
    colBackgroundToggledActive: ResonanceTheme.enabled ? ResonanceTheme.accentGold : Appearance.colors.colPrimaryActive
    borderWidth: (ResonanceTheme.enabled && toggled) ? 1 : 0
    borderColor: ResonanceTheme.enabled ? ResonanceTheme.borderAccent : "transparent"

    contentItem: MaterialSymbol {
        anchors.centerIn: parent
        iconSize: 22
        fill: toggled ? 1 : 0
        color: toggled
            ? (ResonanceTheme.enabled ? ResonanceTheme.colTealInkDark : Appearance.m3colors.m3onPrimary)
            : (ResonanceTheme.enabled
                ? (button.isHovered ? ResonanceTheme.textPrimary : ResonanceTheme.textSecondary)
                : Appearance.colors.colOnLayer1)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: buttonIcon

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }

}
