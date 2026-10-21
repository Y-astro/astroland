import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

RippleButton {
    id: button

    readonly property bool isWuWa: ResonanceTheme.enabled

    property string buttonIcon
    property string buttonText
    property bool keyboardDown: false
    property real size: 120

    buttonRadius: (button.focus || button.down) ? size / 2 : Appearance.rounding.verylarge

    borderWidth: isWuWa ? (button.focus ? 1.5 : 1) : 0
    borderColor: isWuWa
        ? (button.focus
            ? ResonanceTheme.accentGold
            : (button.hovered ? ResonanceTheme.borderAccent : ResonanceTheme.borderHairline))
        : "transparent"

    colBackground: isWuWa
        ? (button.keyboardDown
            ? ResonanceTheme.bgGlassPopupCardActive
            : (button.focus
                ? ResonanceTheme.alpha(ResonanceTheme.colTealInkDark, Math.min(0.95, 0.84 + 0.08 * ResonanceTheme.intensity))
                : ResonanceTheme.alpha(ResonanceTheme.colTealInkDark, Math.min(0.88, 0.76 + 0.06 * ResonanceTheme.intensity))))
        : (button.keyboardDown
            ? Appearance.colors.colSecondaryContainerActive
            : (button.focus ? Appearance.colors.colPrimary : Appearance.colors.colSecondaryContainer))

    colBackgroundHover: isWuWa
        ? ResonanceTheme.bgGlassPopupCardHover
        : Appearance.colors.colPrimary

    colBackgroundActive: isWuWa
        ? ResonanceTheme.bgGlassPopupCardActive
        : (Appearance.colors.colSecondaryContainerActive ?? Appearance.colors.colPrimaryActive)

    colRipple: isWuWa
        ? ResonanceTheme.accentGold
        : Appearance.colors.colPrimaryActive

    property color colText: isWuWa
        ? ((button.focus || button.down || button.keyboardDown) ? ResonanceTheme.crestHighlight : ResonanceTheme.colWarmIvory)
        : ((button.down || button.keyboardDown || button.focus || button.hovered)
            ? Appearance.m3colors.m3onPrimary
            : Appearance.colors.colOnLayer0)

    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    background.implicitHeight: size
    background.implicitWidth: size

    Behavior on buttonRadius {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    Behavior on borderColor {
        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            keyboardDown = true
            button.clicked()
            event.accepted = true;
        }
    }
    Keys.onReleased: (event) => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            keyboardDown = false
            event.accepted = true;
        }
    }

    contentItem: Item {
        anchors.fill: parent

        // Slightly raised inner material (WuWa mode only)
        Rectangle {
            id: innerMaterial
            visible: button.isWuWa
            anchors.fill: parent
            anchors.margins: 7
            radius: Math.max(4, button.buttonRadius - 7)
            color: {
                if (button.down || button.keyboardDown)
                    return ResonanceTheme.alpha(ResonanceTheme.accentGold, 0.22 * ResonanceTheme.intensity);
                if (button.focus)
                    return ResonanceTheme.alpha(ResonanceTheme.accentGold, 0.14 * ResonanceTheme.intensity);
                if (button.hovered)
                    return ResonanceTheme.alpha(ResonanceTheme.colTealInk, 0.60 * ResonanceTheme.intensity);
                return ResonanceTheme.alpha(ResonanceTheme.colTealInk, 0.40 * ResonanceTheme.intensity);
            }
            border.width: 1
            border.color: {
                if (button.focus)
                    return ResonanceTheme.alpha(ResonanceTheme.accentGold, 0.55 * ResonanceTheme.intensity);
                if (button.hovered)
                    return ResonanceTheme.alpha(ResonanceTheme.colAntiqueGold, 0.35 * ResonanceTheme.intensity);
                return ResonanceTheme.alpha(ResonanceTheme.colMistySage, 0.14 * ResonanceTheme.intensity);
            }

            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
            Behavior on border.color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
        }

        MaterialSymbol {
            id: icon
            anchors.fill: parent
            color: button.colText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            iconSize: 45
            text: button.buttonIcon
        }
    }

    StyledToolTip {
        text: buttonText
    }

}
