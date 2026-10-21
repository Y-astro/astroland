import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

GroupButton {
    id: button

    readonly property bool inSettings: {
        var win = button.QsWindow ? button.QsWindow.window : null;
        if (win && win.isSettingsWindow)
            return true;
        var p = button.parent;
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

    property string buttonIcon: ""
    property string buttonText: ""
    /// Scales the icon, the label and the horizontal padding together. 1 is the desktop
    /// size; a touch-first surface asks for more without every caller re-deriving it.
    property real contentScale: 1

    baseHeight: 36 * button.contentScale
    baseWidth: content.implicitWidth + 46 * button.contentScale
    clickedWidth: baseWidth + 6

    readonly property int fullRadius: Config.options.appearance.sharpMode ? Appearance.rounding.full : baseHeight / 2
    buttonRadius: fullRadius
    buttonRadiusPressed: Appearance.rounding.small
    colBackground: button.applyWuWa ? SettingsTheme.colRowBg : Appearance.colors.colLayer2
    colBackgroundHover: button.applyWuWa ? SettingsTheme.colRowHover : Appearance.colors.colLayer2Hover
    colBackgroundActive: button.applyWuWa ? SettingsTheme.colRowHover : Appearance.colors.colLayer2Active
    colBackgroundToggled: button.applyWuWa ? SettingsTheme.colAccent : ((Appearance && Appearance.colors) ? Appearance.colors.colPrimary : "#65558F")
    colBackgroundToggledHover: button.applyWuWa ? SettingsTheme.colNavActiveHover : ((Appearance && Appearance.colors) ? Appearance.colors.colPrimaryHover : "#77699C")
    colBackgroundToggledActive: button.applyWuWa ? SettingsTheme.colNavActiveHover : ((Appearance && Appearance.colors) ? Appearance.colors.colPrimaryActive : "#D6CEE2")
    borderWidth: button.applyWuWa ? 1 : 0
    borderColor: button.applyWuWa ? (button.toggled ? SettingsTheme.colAccent : SettingsTheme.colRowBorder) : Appearance.colors.colSecondary
    property color colText: button.applyWuWa
        ? (toggled ? SettingsTheme.colNavOnActive : SettingsTheme.colTextPrimary)
        : (toggled ? Appearance.m3colors.m3onPrimary : Appearance.colors.colOnLayer1)

    contentItem: Item {
        id: content
        anchors.fill: parent
        implicitWidth: contentRowLayout.implicitWidth
        implicitHeight: contentRowLayout.implicitHeight
        RowLayout {
            id: contentRowLayout
            anchors.centerIn: parent
            spacing: 5
            MaterialSymbol {
                visible: buttonIcon !== ""
                text: buttonIcon
                iconSize: Appearance.font.pixelSize.huge * button.contentScale
                color: button.colText
            }
            StyledText {
                visible: buttonText !== ""
                text: buttonText
                font.pixelSize: Appearance.font.pixelSize.small * button.contentScale
                color: button.colText
            }
        }
    }

}
