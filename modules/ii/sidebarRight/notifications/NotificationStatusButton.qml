import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

GroupButton {
    id: button
    property string buttonIcon: ""
    property string buttonText: ""

    baseHeight: 36
    baseWidth: content.implicitWidth + 46
    clickedWidth: baseWidth + 6

    buttonRadius: baseHeight / 2
    buttonRadiusPressed: Appearance.rounding.small
    colBackground: ResonanceTheme.enabled ? ResonanceTheme.bgGlassSidebarItem : Appearance.colors.colLayer2
    colBackgroundHover: ResonanceTheme.enabled ? ResonanceTheme.bgGlassSidebarItemHover : Appearance.colors.colLayer2Hover
    colBackgroundActive: ResonanceTheme.enabled ? ResonanceTheme.bgGlassSidebarItemActive : Appearance.colors.colLayer2Active
    colBackgroundToggled: ResonanceTheme.enabled ? ResonanceTheme.accentGold : Appearance.colors.colPrimary
    colBackgroundToggledHover: ResonanceTheme.enabled ? ResonanceTheme.accentGold : Appearance.colors.colPrimaryHover
    colBackgroundToggledActive: ResonanceTheme.enabled ? ResonanceTheme.accentGold : Appearance.colors.colPrimaryActive
    borderWidth: ResonanceTheme.enabled ? 1 : 0
    borderColor: ResonanceTheme.enabled ? (toggled ? ResonanceTheme.borderAccent : ResonanceTheme.borderSidebarItem) : Appearance.colors.colSecondary
    property color colText: ResonanceTheme.enabled
        ? (toggled ? ResonanceTheme.colTealInkDark : (button.isHovered ? ResonanceTheme.textPrimary : ResonanceTheme.textSecondary))
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
                iconSize: Appearance.font.pixelSize.huge
                color: button.colText
            }
            StyledText {
                visible: buttonText !== ""
                text: buttonText
                font.pixelSize: Appearance.font.pixelSize.small
                color: button.colText
            }
        }
    }

}