import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common

/**
 * "Related: X" cross-link chip for settings pages. Navigates the settings
 * window to another page by its SettingsPageRegistry id, optionally
 * highlighting a section after landing.
 *
 *   RelatedChip {
 *       pageId: "coreServices"
 *       label: Translation.tr("Weather service")
 *       sectionHighlight: Translation.tr("Weather")
 *   }
 */
RippleButton {
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

    property string pageId: ""
    property string label: ""
    // Translated section title passed to pendingSectionHighlight on arrival
    property string sectionHighlight: ""
    property string chipIcon: "arrow_outward"

    implicitHeight: 28
    buttonRadius: Appearance.rounding.full
    colBackground: root.applyWuWa ? SettingsTheme.colItemBg : Appearance.colors.colSecondaryContainer
    colBackgroundHover: root.applyWuWa ? SettingsTheme.colRowHover : Appearance.colors.colSecondaryContainerHover
    colRipple: root.applyWuWa ? SettingsTheme.colAccent : Appearance.colors.colSecondaryContainerActive
    borderWidth: root.applyWuWa ? 1 : 0
    borderColor: root.applyWuWa ? SettingsTheme.colCardBorder : "transparent"

    onClicked: {
        const win = root.QsWindow.window;
        if (!win || win.pageIndexById === undefined)
            return ;

        const idx = win.pageIndexById(root.pageId);
        if (idx < 0)
            return ;

        if (root.sectionHighlight !== "")
            win.pendingSectionHighlight = root.sectionHighlight;

        win.currentPage = idx;
    }

    contentItem: RowLayout {
        spacing: 4

        MaterialSymbol {
            Layout.leftMargin: 8
            text: root.chipIcon
            iconSize: 14
            color: root.applyWuWa ? SettingsTheme.colAccent : Appearance.colors.colOnSecondaryContainer
        }

        StyledText {
            Layout.rightMargin: 10
            text: root.label
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: root.applyWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnSecondaryContainer
        }

    }

}
