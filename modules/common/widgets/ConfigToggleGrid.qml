import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

GridLayout {
    id: root
    Layout.fillWidth: true

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

    property var model: []
    property var currentValues: ({})
    property int gridColumns: Math.max(1, Math.floor(parent ? parent.width / 280 : 280))
    property int cardSpacing: 12

    signal itemChanged(string key, var value)

    columns: root.gridColumns
    columnSpacing: root.cardSpacing
    rowSpacing: root.cardSpacing

    Repeater {
        model: root.model

        delegate: Rectangle {
            id: card
            Layout.fillWidth: true
            Layout.minimumWidth: 210
            implicitHeight: rowLayout.implicitHeight + 24
            radius: pressed ? Appearance.rounding.large : Appearance.rounding.normal
            color: root.applyWuWa
                ? (card.pressed ? ColorUtils.applyAlpha(SettingsTheme.colAccent, 0.20) : (hoverHandler.hovered ? SettingsTheme.colRowHover : SettingsTheme.colRowBg))
                : (pressed ? Appearance.colors.colLayer2Active : (hoverHandler.hovered ? Appearance.colors.colLayer2Hover : Appearance.colors.colLayer2))
            border.width: root.applyWuWa ? SettingsTheme.rowBorderWidth : 0
            border.color: root.applyWuWa ? SettingsTheme.colRowBorder : "transparent"

            required property var modelData
            readonly property string itemKey: modelData.key || ""
            property bool pressed: false

            Behavior on color {
                ColorAnimation {
                    duration: Appearance.animation.elementMoveFast.duration
                    easing.type: Appearance.animation.elementMoveFast.type
                    easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
                }
            }

            Behavior on radius {
                NumberAnimation {
                    duration: Appearance.animation.elementMoveFast.duration
                    easing.type: Appearance.animation.elementMoveFast.type
                    easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Appearance.animation.elementMoveFast.duration
                    easing.type: Appearance.animation.elementMoveFast.type
                    easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
                }
            }

            scale: pressed ? 0.98 : (hoverHandler.hovered ? 1.01 : 1.0)
            transformOrigin: Item.Center

            MouseArea {
                anchors.fill: parent
                hoverEnabled: false
                cursorShape: Qt.ArrowCursor
                onPressed: card.pressed = true
                onReleased: card.pressed = false
                onCanceled: card.pressed = false
            }

            RowLayout {
                id: rowLayout
                anchors {
                    fill: parent
                    leftMargin: 14
                    rightMargin: 14
                    topMargin: 12
                    bottomMargin: 12
                }
                spacing: 12

                MaterialShapeWrappedMaterialSymbol {
                    id: iconShape
                    Layout.alignment: Qt.AlignVCenter
                    iconSize: Appearance.font.pixelSize.normal
                    shape: MaterialShape.Shape.Circle
                    padding: 9
                    fill: card.modelData.icon ? 1 : 0
                    color: root.applyWuWa ? SettingsTheme.colControlIconBg : Appearance.colors.colSurfaceContainerHigh
                    colSymbol: root.applyWuWa ? SettingsTheme.colTextSecondary : Appearance.colors.colOnSurfaceVariant
                    text: card.modelData.icon || ""
                }

                StyledText {
                    Layout.alignment: Qt.AlignVCenter
                    text: card.modelData.name || ""
                    font.weight: Font.DemiBold
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: root.applyWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnLayer2
                    verticalAlignment: Text.AlignVCenter
                }

                Item {
                    Layout.fillWidth: true
                }

                ConfigSelectionArray {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    currentValue: root.currentValues[card.itemKey]
                    onSelected: newValue => root.itemChanged(card.itemKey, newValue)
                    options: card.modelData.options || []
                }
            }

            HoverHandler {
                id: hoverHandler
            }
        }
    }
}
