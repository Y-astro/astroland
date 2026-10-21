import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

/**
 * Filter / toggle chip of the timetable vocabulary: a dashed outline while off, the
 * secondary container once chosen, a check sliding in front of the label. `count`
 * adds a small badge after the label.
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

    property string symbol: ""
    property string label: ""
    property bool chosen: false
    property int count: -1
    /// Chips on a coloured card take its content colour for the outline and text.
    property color colContent: applyWuWa ? SettingsTheme.colTextSecondary : Appearance.colors.colOnSurfaceVariant
    property color colChosen: applyWuWa ? SettingsTheme.colAccent : Appearance.colors.colSecondaryContainer
    property color colOnChosen: applyWuWa ? SettingsTheme.colNavOnActive : Appearance.colors.colOnSecondaryContainer

    implicitHeight: 36
    implicitWidth: chipRow.implicitWidth + 28
    buttonRadius: height / 2
    buttonRadiusPressed: Appearance.rounding.small
    toggled: root.chosen
    colBackground: "transparent"
    colBackgroundHover: applyWuWa ? SettingsTheme.colRowHover : ColorUtils.applyAlpha(root.colContent, 0.08)
    colBackgroundActive: applyWuWa ? SettingsTheme.colRowHover : ColorUtils.applyAlpha(root.colContent, 0.16)
    colRipple: applyWuWa ? SettingsTheme.colRowHover : ColorUtils.applyAlpha(root.colContent, 0.16)
    colBackgroundToggled: root.colChosen
    colBackgroundToggledHover: applyWuWa ? SettingsTheme.colNavActiveHover : ColorUtils.mix(root.colChosen, root.colOnChosen, 0.9)
    colBackgroundToggledActive: applyWuWa ? SettingsTheme.colNavActiveHover : ColorUtils.mix(root.colChosen, root.colOnChosen, 0.8)
    colRippleToggled: applyWuWa ? SettingsTheme.colNavActiveHover : ColorUtils.mix(root.colChosen, root.colOnChosen, 0.8)
    opacity: root.enabled ? 1 : 0.4

    DashedBorder {
        anchors.fill: parent
        visible: !root.chosen
        color: root.applyWuWa ? SettingsTheme.colCardBorder : ColorUtils.applyAlpha(root.colContent, 0.55)
        borderWidth: 1
        dashLength: 4
        gapLength: 3
        radius: height / 2
    }

    contentItem: Item {
        RowLayout {
            id: chipRow
            anchors.centerIn: parent
            spacing: 6

            MaterialSymbol {
                visible: root.chosen || root.symbol.length > 0
                text: root.chosen ? "check" : root.symbol
                iconSize: Appearance.font.pixelSize.normal
                fill: root.chosen ? 1 : 0
                color: root.chosen ? root.colOnChosen : root.colContent
            }

            StyledText {
                text: root.label
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.weight: Font.Bold
                color: root.chosen ? root.colOnChosen : root.colContent
            }

            Rectangle {
                visible: root.count >= 0
                implicitWidth: Math.max(implicitHeight, countText.implicitWidth + 10)
                implicitHeight: 20
                radius: height / 2
                color: root.chosen
                    ? (root.applyWuWa ? ColorUtils.applyAlpha(SettingsTheme.colNavOnActive, 0.18) : ColorUtils.applyAlpha(root.colOnChosen, 0.14))
                    : (root.applyWuWa ? SettingsTheme.colItemBg : ColorUtils.applyAlpha(root.colContent, 0.12))

                StyledText {
                    id: countText
                    anchors.centerIn: parent
                    text: String(root.count)
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    font.weight: Font.Bold
                    color: root.chosen ? root.colOnChosen : (root.applyWuWa ? SettingsTheme.colTextPrimary : root.colContent)
                }
            }
        }
    }
}
