import qs.modules.common
import qs.modules.common.widgets
import QtQuick

RippleButton {
    id: button
    property string buttonText: ""
    property string tooltipText: ""
    property bool forceCircle: false

    implicitHeight: 30
    implicitWidth: forceCircle ? implicitHeight : (contentItem.implicitWidth + 10 * 2)
    Behavior on implicitWidth {
        SmoothedAnimation {
            velocity: Appearance.animation.elementMove.velocity
        }
    }

    background.anchors.fill: button
    buttonRadius: Appearance.rounding.full
    colBackground: ResonanceTheme.enabled ? ResonanceTheme.bgGlassSidebarItem : Appearance.colors.colLayer2
    colBackgroundHover: ResonanceTheme.enabled ? ResonanceTheme.bgGlassSidebarItemHover : Appearance.colors.colLayer2Hover
    colRipple: ResonanceTheme.enabled ? ResonanceTheme.bgGlassSidebarItemActive : Appearance.colors.colLayer2Active
    borderWidth: ResonanceTheme.enabled ? 1 : 0
    borderColor: ResonanceTheme.enabled ? (button.hovered ? ResonanceTheme.borderAccent : ResonanceTheme.borderSidebarItem) : (Appearance.colors.colOutline ?? "transparent")

    contentItem: StyledText {
        text: buttonText
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Appearance.font.pixelSize.larger
        color: ResonanceTheme.enabled ? (button.hovered ? ResonanceTheme.accentGold : ResonanceTheme.textPrimary) : Appearance.colors.colOnLayer1
    }

    StyledToolTip {
        text: tooltipText
        extraVisibleCondition: tooltipText.length > 0
    }
}