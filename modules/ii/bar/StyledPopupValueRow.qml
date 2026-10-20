import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

RowLayout {
    id: root
    required property string icon
    required property string label
    required property string value
    spacing: 4

    MaterialSymbol {
        text: root.icon
        color: BarPopupTheme.colAccent
        iconSize: Appearance.font.pixelSize.large
    }
    StyledText {
        text: root.label
        color: BarPopupTheme.colTextSecondary
    }
    StyledText {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
        visible: root.value !== ""
        color: BarPopupTheme.colTextPrimary
        text: root.value
    }
}
