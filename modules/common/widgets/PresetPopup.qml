import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Popup {
    id: root
    property var onOverwrite: () => {}
    property var onExportZip: () => {}

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
    readonly property bool applyWuWa: SettingsTheme.isWuWa && inSettings

    width: 190
    padding: 8
    modal: false
    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape

    background: Item {
        StyledRectangularShadow { target: popupBg }
        Rectangle {
            id: popupBg
            anchors.fill: parent
            radius: Appearance.rounding.small
            color: root.applyWuWa ? SettingsTheme.colMenuBg : Appearance.m3colors.m3surfaceContainerHigh
            border.width: 1
            border.color: root.applyWuWa ? SettingsTheme.colMenuBorder : Appearance.colors.colLayer0Border
        }
    }

    contentItem: ColumnLayout {
        spacing: 2
        RippleButton {
            Layout.fillWidth: true
            implicitHeight: 40
            buttonRadius: Appearance.rounding.small
            colBackground: "transparent"
            colBackgroundHover: root.applyWuWa ? SettingsTheme.colRowHover : Appearance.colors.colLayer2Hover
            colRipple: root.applyWuWa ? SettingsTheme.colAccent : Appearance.colors.colLayer2Active
            horizontalPadding: 12
            onClicked: { root.close(); root.onOverwrite() }
            contentItem: RowLayout {
                spacing: 10
                MaterialSymbol {
                    text: "save_as"
                    iconSize: Appearance.font.pixelSize.normal
                    color: root.applyWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnLayer0
                }
                StyledText {
                    text: Translation.tr("Overwrite")
                    color: root.applyWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnLayer0
                    Layout.fillWidth: true
                    font.pixelSize: Appearance.font.pixelSize.small
                }
            }
        }
        RippleButton {
            Layout.fillWidth: true
            implicitHeight: 40
            buttonRadius: Appearance.rounding.small
            colBackground: "transparent"
            colBackgroundHover: root.applyWuWa ? SettingsTheme.colRowHover : Appearance.colors.colLayer2Hover
            colRipple: root.applyWuWa ? SettingsTheme.colAccent : Appearance.colors.colLayer2Active
            horizontalPadding: 12
            onClicked: { root.close(); root.onExportZip() }
            contentItem: RowLayout {
                spacing: 10
                MaterialSymbol {
                    text: "folder_zip"
                    iconSize: Appearance.font.pixelSize.normal
                    color: root.applyWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnLayer0
                }
                StyledText {
                    text: Translation.tr("Export ZIP")
                    color: root.applyWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnLayer0
                    Layout.fillWidth: true
                    font.pixelSize: Appearance.font.pixelSize.small
                }
            }
        }
    }
}
