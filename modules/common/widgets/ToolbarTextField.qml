import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.modules.common
import qs.modules.common.widgets

TextField {
    id: filterField

    readonly property bool inSettings: {
        var win = filterField.QsWindow ? filterField.QsWindow.window : null;
        if (win && win.isSettingsWindow)
            return true;
        var p = filterField.parent;
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

    property alias colBackground: background.color

    Layout.fillHeight: true
    implicitWidth: 200
    padding: 10

    placeholderTextColor: filterField.applyWuWa ? SettingsTheme.colTextSecondary : Appearance.colors.colSubtext
    color: filterField.applyWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnLayer1
    font {
        family: Appearance.font.family.main
        pixelSize: Appearance.font.pixelSize.small
        hintingPreference: Font.PreferFullHinting
        variableAxes: Appearance.font.variableAxes.main
    }
    renderType: Text.NativeRendering
    selectedTextColor: filterField.applyWuWa ? SettingsTheme.colNavOnActive : Appearance.colors.colOnSecondaryContainer
    selectionColor: filterField.applyWuWa ? SettingsTheme.colAccent : Appearance.colors.colSecondaryContainer

    // Set this to the item that should receive focus (and key events)
    // when Ctrl is held, e.g. cheatsheetBackground for tab switching.
    property Item keyNavTarget: null

    Keys.priority: Keys.BeforeItem
    Keys.onPressed: event => {
        if ((event.key === Qt.Key_Control || (event.modifiers & Qt.ControlModifier)) && keyNavTarget) {
            keyNavTarget.forceActiveFocus();
            event.accepted = false;
        }
    }

    background: Rectangle {
        id: background
        color: filterField.applyWuWa
            ? (filterField.activeFocus ? SettingsTheme.colSearchFieldFocused : SettingsTheme.colSearchField)
            : Appearance.colors.colLayer1
        radius: Appearance.rounding.full
        border.width: filterField.applyWuWa ? 1 : 0
        border.color: filterField.applyWuWa
            ? (filterField.activeFocus ? SettingsTheme.colBorderFocused : SettingsTheme.colCardBorder)
            : "transparent"
    }

    StyledTextContextMenuLoader {
        id: contextMenu
        targetField: filterField
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        hoverEnabled: true
        cursorShape: Qt.IBeamCursor
        onPressed: mouse => {
            if (mouse.button === Qt.RightButton) {
                filterField.forceActiveFocus();
                contextMenu.popup(mouse.x, mouse.y);
            }
        }
    }
}
