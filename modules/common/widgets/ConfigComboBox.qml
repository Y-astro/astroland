import qs.modules.common.widgets
import qs.modules.common
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RowLayout {
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

    property string text: ""
    property string description: ""
    property string buttonIcon: ""
    property var model: []
    property string textRole: "displayName"
    property var currentValue: undefined

    property real fieldWidth: 220

    property alias comboBox: comboBox

    signal selected(var newValue)

    spacing: 10
    Layout.leftMargin: 8
    Layout.rightMargin: 8

    OptionalMaterialSymbol {
        icon: root.buttonIcon
        iconSize: Appearance.font.pixelSize.larger
        opacity: root.enabled ? 1 : 0.4
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0
        StyledText {
            Layout.fillWidth: true
            text: root.text
            color: root.applyWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnSecondaryContainer
            opacity: root.enabled ? 1 : 0.4
        }
        StyledText {
            Layout.fillWidth: true
            visible: root.description.length > 0
            text: root.description
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: root.applyWuWa ? SettingsTheme.colTextSecondary : Appearance.colors.colSubtext
            wrapMode: Text.Wrap
            opacity: root.enabled ? 1 : 0.4
        }
    }

    StyledComboBox {
        id: comboBox
        Layout.preferredWidth: root.fieldWidth
        Layout.alignment: Qt.AlignVCenter
        enabled: root.enabled
        textRole: root.textRole
        model: root.model

        currentIndex: {
            const index = root.model.findIndex(item => item.value === root.currentValue);
            return index !== -1 ? index : 0;
        }

        onActivated: index => {
            root.selected(comboBox.model[index].value);
        }
    }
}