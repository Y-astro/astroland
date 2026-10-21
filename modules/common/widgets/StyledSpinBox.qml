import qs.modules.common
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls

/**
 * Material 3 styled SpinBox component.
 */
SpinBox {
    id: root

    readonly property bool inSettings: {
        var win = root.QsWindow ? root.QsWindow.window : null;
        if (win && win.isSettingsWindow)
            return true;
        var p = root.parent;
        var depth = 0;
        while (p && depth < 20) {
            if (p.isSettingsScope || p.isSettingsWindow || p.inSettings)
                return true;
            p = p.parent;
            depth++;
        }
        return false;
    }
    readonly property bool isSettingsScope: inSettings
    readonly property bool applyWuWa: SettingsTheme.isWuWa && inSettings

    property real baseHeight: 35
    property real radius: Appearance.rounding.small
    property real innerButtonRadius: Appearance.rounding.unsharpen
    editable: true

    opacity: root.enabled ? 1 : 0.4

    background: Rectangle {
        color: root.applyWuWa ? SettingsTheme.colControlBg : Appearance.colors.colLayer2
        radius: root.radius
        border.width: root.applyWuWa ? 1 : 0
        border.color: root.applyWuWa ? (root.activeFocus ? SettingsTheme.colBorderFocused : SettingsTheme.colControlBorder) : "transparent"

        Behavior on border.color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }

    contentItem: Item {
        implicitHeight: root.baseHeight
        implicitWidth: Math.max(labelText.implicitWidth, 40)

        StyledTextInput {
            id: labelText
            anchors.centerIn: parent
            text: root.value // displayText would make the numbers weird like 1,000 instead of 1000
            color: root.applyWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnLayer2
            selectionColor: root.applyWuWa ? SettingsTheme.colAccent : Appearance.colors.colSecondaryContainer
            selectedTextColor: root.applyWuWa ? SettingsTheme.colTealInkDark : Appearance.colors.colOnSecondaryContainer
            font.family: Appearance.font.family.numbers
            font.variableAxes: Appearance.font.variableAxes.numbers
            font.pixelSize: Appearance.font.pixelSize.small
            validator: root.validator
            onTextChanged: {
                root.value = parseFloat(text);
            }
        }
    }

    down.indicator: Rectangle {
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
        }
        implicitHeight: root.baseHeight
        implicitWidth: root.baseHeight
        topLeftRadius: root.radius
        bottomLeftRadius: root.radius
        topRightRadius: root.innerButtonRadius
        bottomRightRadius: root.innerButtonRadius

        color: root.down.pressed ? (root.applyWuWa ? SettingsTheme.colControlBgActive : Appearance.colors.colLayer2Active) : 
            root.down.hovered ? (root.applyWuWa ? SettingsTheme.colControlBgHover : Appearance.colors.colLayer2Hover) : 
            (root.applyWuWa ? "transparent" : ColorUtils.transparentize(Appearance.colors.colLayer2))
        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }

        MaterialSymbol {
            anchors.centerIn: parent
            text: "remove"
            iconSize: 20
            color: root.applyWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnLayer2
        }
    }

    up.indicator: Rectangle {
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
        }
        implicitHeight: root.baseHeight
        implicitWidth: root.baseHeight
        topRightRadius: root.radius
        bottomRightRadius: root.radius
        topLeftRadius: root.innerButtonRadius
        bottomLeftRadius: root.innerButtonRadius

        color: root.up.pressed ? (root.applyWuWa ? SettingsTheme.colControlBgActive : Appearance.colors.colLayer2Active) : 
            root.up.hovered ? (root.applyWuWa ? SettingsTheme.colControlBgHover : Appearance.colors.colLayer2Hover) : 
            (root.applyWuWa ? "transparent" : ColorUtils.transparentize(Appearance.colors.colLayer2))
        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }

        MaterialSymbol {
            anchors.centerIn: parent
            text: "add"
            iconSize: 20
            color: root.applyWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnLayer2
        }
    }
}
