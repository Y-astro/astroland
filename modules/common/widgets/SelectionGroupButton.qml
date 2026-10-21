import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.services
import qs.modules.common
import qs.modules.common.widgets

GroupButton {
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

    horizontalPadding: 12
    verticalPadding: 8
    bounce: true
    clickedWidth: baseWidth + (isAtSide ? 8 : 12)
    buttonRadiusPressed: Appearance.rounding.small
    Layout.fillWidth: false
    Layout.fillHeight: false
    scale: 1.0
    property string buttonIcon
    property string buttonShape
    property string buttonSymbol
    property string buttonColor
    property bool leftmost: false
    property bool rightmost: false
    property bool isDragging: false
    
    readonly property bool sharpModeEnabled: Config.options?.appearance?.sharpMode ?? false
    readonly property int fullRadius: sharpModeEnabled ? Appearance.rounding.full : height / 2
    leftRadius: root.isPressed ? root.buttonRadiusPressed : ((toggled || leftmost) ? fullRadius : Appearance.rounding.unsharpenmore)
    rightRadius: root.isPressed ? root.buttonRadiusPressed : ((toggled || rightmost) ? fullRadius : Appearance.rounding.unsharpenmore)
    colBackground: applyWuWa ? SettingsTheme.colControlBg : Appearance.colors.colSecondaryContainer
    colBackgroundHover: applyWuWa ? SettingsTheme.colControlBgHover : Appearance.colors.colSecondaryContainerHover
    colBackgroundActive: applyWuWa ? SettingsTheme.colControlBgActive : Appearance.colors.colSecondaryContainerActive
    colBackgroundToggled: applyWuWa ? SettingsTheme.colOptionSelected : (Appearance?.colors.colPrimary ?? "#65558F")
    colBackgroundToggledHover: applyWuWa ? SettingsTheme.colOptionSelectedHover : (Appearance?.colors.colPrimaryHover ?? "#77699C")
    colBackgroundToggledActive: applyWuWa ? Qt.darker(SettingsTheme.colOptionSelected, 1.15) : (Appearance?.colors.colPrimaryActive ?? "#D6CEE2")
    borderWidth: applyWuWa ? 1 : 0
    borderColor: applyWuWa ? (root.toggled ? SettingsTheme.colAccent : SettingsTheme.colControlBorder) : Appearance.colors.colSecondary

    contentItem: RowLayout {
        spacing: 4 * (root.buttonText?.length > 0)

        MaterialSymbol {
            Layout.alignment: Qt.AlignVCenter
            visible: root.buttonIcon !== undefined && root.buttonIcon !== ""
            text: root.buttonIcon || ""
            iconSize: Appearance.font.pixelSize.larger
            fill: root.toggled ? 1 : 0
            color: root.toggled ? (root.applyWuWa ? SettingsTheme.colOptionOnSelected : Appearance.colors.colOnPrimary) : (root.applyWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnSecondaryContainer)
        }

        Loader {
            Layout.alignment: Qt.AlignVCenter
            active: root.buttonShape !== undefined && root.buttonShape !== ""
            visible: active
            sourceComponent: root.buttonShape === "Rectangle" ? rectangleShapeComp : materialShapeComp
        }

        Component {
            id: rectangleShapeComp
            Rectangle {
                implicitWidth: Appearance.font.pixelSize.larger
                implicitHeight: Appearance.font.pixelSize.larger
                radius: Math.min(implicitWidth / 2, Appearance.rounding.windowRounding > 0 ? 4 : 0)
                color: root.buttonColor !== "" ? root.buttonColor : root.toggled ? (root.applyWuWa ? SettingsTheme.colOptionOnSelected : Appearance.colors.colOnPrimary) : (root.applyWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnSecondaryContainer)
            }
        }

        Component {
            id: materialShapeComp
            MaterialShape {
                id: materialSymbol2
                implicitWidth: Appearance.font.pixelSize.larger
                implicitHeight: Appearance.font.pixelSize.larger
                shapeString: root.buttonShape
                color: root.buttonColor !== "" ? root.buttonColor : root.toggled ? (root.applyWuWa ? SettingsTheme.colOptionOnSelected : Appearance.colors.colOnPrimary) : (root.applyWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnSecondaryContainer)
            }
        }

        Loader {
            Layout.alignment: Qt.AlignVCenter
            active: root.buttonSymbol !== undefined && root.buttonSymbol !== ""
            visible: active
            sourceComponent: CustomIcon {
                id: materialSymbol3
                width: Appearance.font.pixelSize.larger
                height: Appearance.font.pixelSize.larger
                source: root.buttonSymbol
                colorize: true
                color: root.toggled ? (root.applyWuWa ? SettingsTheme.colOptionOnSelected : Appearance.colors.colOnPrimary) : (root.applyWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnSecondaryContainer)
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            visible: root.buttonText !== undefined && root.buttonText.length > 0
            color: root.toggled ? (root.applyWuWa ? SettingsTheme.colOptionOnSelected : Appearance.colors.colOnPrimary) : (root.applyWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnSecondaryContainer)
            text: root.buttonText || ""
        }
    }
}
