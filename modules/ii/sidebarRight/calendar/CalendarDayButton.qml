import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

RippleButton {
    id: button
    property string day
    property int isToday
    property bool bold

    Layout.fillWidth: false
    Layout.fillHeight: false
    implicitWidth: 38; 
    implicitHeight: 38;

    toggled: (isToday == 1)
    buttonRadius: Appearance.rounding.small

    colBackground: "transparent"
    colBackgroundHover: ResonanceTheme.enabled ? ResonanceTheme.alpha(ResonanceTheme.colAntiqueGold, 0.16) : Appearance.colors.colLayer1Hover
    colBackgroundActive: ResonanceTheme.enabled ? ResonanceTheme.alpha(ResonanceTheme.colAntiqueGold, 0.28) : Appearance.colors.colLayer1Active
    colBackgroundToggled: ResonanceTheme.enabled ? ResonanceTheme.accentGold : Appearance.colors.colPrimary
    colBackgroundToggledHover: ResonanceTheme.enabled ? ResonanceTheme.accentGold : Appearance.colors.colPrimaryHover
    colBackgroundToggledActive: ResonanceTheme.enabled ? ResonanceTheme.accentGold : Appearance.colors.colPrimaryActive

    borderWidth: ResonanceTheme.enabled ? ((isToday == 1) ? 1 : (button.hovered ? 1 : 0)) : 0
    borderColor: ResonanceTheme.enabled ? ((isToday == 1) ? ResonanceTheme.borderAccent : ResonanceTheme.alpha(ResonanceTheme.colAntiqueGold, 0.35)) : "transparent"
    
    contentItem: StyledText {
        anchors.fill: parent
        text: day
        horizontalAlignment: Text.AlignHCenter
        font.weight: bold ? Font.DemiBold : Font.Normal
        color: (isToday == 1)
            ? (ResonanceTheme.enabled ? ResonanceTheme.colTealInkDark : Appearance.m3colors.m3onPrimary)
            : (bold
                ? (ResonanceTheme.enabled ? ResonanceTheme.textSecondary : Appearance.colors.colOnLayer1)
                : ((isToday == 0)
                    ? (ResonanceTheme.enabled ? ResonanceTheme.textPrimary : Appearance.colors.colOnLayer1)
                    : (ResonanceTheme.enabled ? ResonanceTheme.alpha(ResonanceTheme.colMistySage, 0.45) : Appearance.colors.colOutlineVariant)))

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }
}

