import QtQuick
import qs.modules.common
import qs.modules.common.widgets

/// The small pill the hub's rows use for a word about themselves - who set an option, how many
/// settings behind a door were changed. Takes no room while it has nothing to say.
Rectangle {
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

    visible: root.text !== ""
    implicitHeight: 22
    implicitWidth: label.implicitWidth + 14
    radius: Appearance.rounding.full
    color: root.applyWuWa ? SettingsTheme.colItemBg : Appearance.colors.colSecondaryContainer
    border.width: root.applyWuWa ? 1 : 0
    border.color: root.applyWuWa ? SettingsTheme.colRowBorder : "transparent"

    StyledText {
        id: label
        anchors.centerIn: parent
        text: root.text
        font.pixelSize: Appearance.font.pixelSize.smallest
        color: root.applyWuWa ? SettingsTheme.colAccent : Appearance.colors.colOnSecondaryContainer
    }
}
