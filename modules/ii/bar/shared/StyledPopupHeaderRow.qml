import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Row {
    id: root
    required property var icon
    required property var label
    spacing: BarPopupTheme.spacingHeader

    MaterialSymbol {
        anchors.verticalCenter: parent.verticalCenter
        fill: 0
        font.weight: Font.DemiBold
        text: root.icon
        iconSize: Appearance.font.pixelSize.large
        color: BarPopupTheme.colTextSecondary
    }

    StyledText {
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        font {
            weight: Font.DemiBold
            pixelSize: Appearance.font.pixelSize.normal
        }
        color: BarPopupTheme.colTextPrimary
    }
}