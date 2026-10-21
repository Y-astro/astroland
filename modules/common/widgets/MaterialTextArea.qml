import qs.modules.common
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls

/**
 * Material 3 styled TextArea (filled style)
 * https://m3.material.io/components/text-fields/overview
 * Note: We don't use NativeRendering because it makes the small placeholder text look weird
 */
TextArea {
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

    Material.theme: Material.System
    Material.accent: Appearance.m3colors.m3primary
    Material.primary: Appearance.m3colors.m3primary
    Material.background: Appearance.m3colors.m3surface
    Material.foreground: Appearance.m3colors.m3onSurface
    Material.containerStyle: Material.Filled
    renderType: Text.QtRendering

    color: root.applyWuWa ? SettingsTheme.colTextPrimary : ((Appearance && Appearance.colors) ? Appearance.colors.colOnLayer1 : Appearance.m3colors.m3onSurface)
    selectedTextColor: root.applyWuWa ? SettingsTheme.colNavOnActive : Appearance.m3colors.m3onSecondaryContainer
    selectionColor: root.applyWuWa ? SettingsTheme.colAccent : Appearance.colors.colSecondaryContainer
    placeholderTextColor: root.applyWuWa ? SettingsTheme.colTextSecondary : Appearance.m3colors.m3outline

    background: Rectangle {
        implicitHeight: 56
        color: root.applyWuWa
            ? (root.focus ? SettingsTheme.colSearchFieldFocused : SettingsTheme.colSearchField)
            : Appearance.colors.colLayer1 
        topLeftRadius: 4
        topRightRadius: 4
        border.width: root.applyWuWa ? 1 : 0
        border.color: root.applyWuWa
            ? (root.focus ? SettingsTheme.colBorderFocused : SettingsTheme.colCardBorder)
            : "transparent"

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 1
            color: root.applyWuWa
                ? (root.focus ? SettingsTheme.colAccent : (root.hovered ? SettingsTheme.colBorderFocused : SettingsTheme.colCardBorder))
                : (root.focus ? Appearance.m3colors.m3primary : 
                    root.hovered ? Appearance.m3colors.m3outline : Appearance.m3colors.m3outlineVariant)

            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
        }
    }

    font {
        family: Appearance.font.family.main
        pixelSize: Appearance.font.pixelSize.small
        hintingPreference: Font.PreferFullHinting
        variableAxes: Appearance.font.variableAxes.main
    }
    wrapMode: TextEdit.Wrap
}
