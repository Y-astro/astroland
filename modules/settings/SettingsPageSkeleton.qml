import QtQuick
import QtQuick.Layouts
import qs.modules.common

Item {
    id: root

    property bool revealed: false

    opacity: revealed ? 1 : 0
    visible: opacity > 0

    // Always animated, including in Settings Performance Mode: this is one
    // fading item, and skipping it is what turned the skeleton into a hard
    // flash of grey cards instead of a transition.
    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.animation.elementMoveFast.duration
            easing.type: Appearance.animation.elementMoveFast.type
            easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.rounding.normal
        spacing: Appearance.rounding.small

        Repeater {
            model: 3

            delegate: Rectangle {
                required property int index

                Layout.fillWidth: true
                Layout.preferredHeight: index === 0 ? 190 : 150
                radius: Appearance.rounding.large
                color: SettingsTheme.isWuWa ? SettingsTheme.colCardBg : Appearance.colors.colLayer1
                border.width: SettingsTheme.isWuWa ? SettingsTheme.cardBorderWidth : 0
                border.color: SettingsTheme.isWuWa ? SettingsTheme.colCardBorder : "transparent"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Appearance.rounding.large
                    spacing: Appearance.rounding.small

                    Rectangle {
                        Layout.preferredWidth: parent.width * (index === 0 ? 0.34 : 0.48)
                        Layout.preferredHeight: Appearance.font.pixelSize.normal
                        radius: Appearance.rounding.small
                        color: SettingsTheme.isWuWa ? SettingsTheme.colRowBg : Appearance.colors.colLayer3
                        border.width: SettingsTheme.isWuWa ? 1 : 0
                        border.color: SettingsTheme.isWuWa ? SettingsTheme.colRowBorder : "transparent"
                    }

                    Item {
                        Layout.preferredHeight: Appearance.rounding.unsharpenmore
                    }

                    Repeater {
                        model: 2

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Appearance.font.pixelSize.small
                            radius: Appearance.rounding.small
                            color: SettingsTheme.isWuWa ? SettingsTheme.colRowBg : Appearance.colors.colLayer3
                            border.width: SettingsTheme.isWuWa ? 1 : 0
                            border.color: SettingsTheme.isWuWa ? SettingsTheme.colRowBorder : "transparent"
                            opacity: SettingsTheme.isWuWa ? 0.9 : 0.72
                        }
                    }
                }
            }
        }
    }
}
