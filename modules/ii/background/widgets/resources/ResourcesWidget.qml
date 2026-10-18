import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.common.widgets.widgetCanvas
import qs.modules.ii.background.widgets

AbstractBackgroundWidget {
    id: root
    configEntryName: "resources"
    hoverEnabled: true

    property real widgetWidth: 420
    property real cardSpacing: 12
    property real cardHeight: 120
    property real cardWidth: (widgetWidth - cardSpacing * 2) / 3
    readonly property bool isVertical: root.configEntry?.vertical ?? false
    property bool hasBattery: Battery.available

    readonly property string configuredStyle: root.configEntry?.style ?? "classic"
    readonly property bool isWuWa: configuredStyle === "wuwa"

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    component StatCard: Rectangle {
        id: statCard
        property string icon: ""
        property string value: ""
        property string label: ""
        property int shape: MaterialShape.Shape.Cookie12Sided
        property color bgColor: Appearance.colors.colPrimaryContainer
        property color shapeColor: Appearance.colors.colPrimary

        implicitWidth: root.cardWidth
        implicitHeight: root.cardHeight
        radius: Appearance.rounding?.verylarge ?? 30
        color: statCard.bgColor

        StyledRectangularShadow {
            target: statCard
            z: -2
        }

        FastBlurred {
            anchors.fill: parent
            blurSource: root.wallpaperItem
            cardRadius: statCard.radius
            tint: Appearance.colors.colLayer1
            tintOpacity: 0.55
            trackX: statCard.x + (statCard.parent ? statCard.parent.x : 0) + row.x + root.x
            trackY: statCard.y + (statCard.parent ? statCard.parent.y : 0) + row.y + root.y
            visible: Config.options.background.widgets.blurWidgets 
        }

        ColumnLayout {
            anchors {
                fill: parent
                margins: 14
            }
            spacing: -4

            MaterialShapeWrappedMaterialSymbol {
                Layout.alignment: Qt.AlignRight
                shape: statCard.shape
                color: statCard.shapeColor
                colSymbol: Appearance.colors.colOnPrimary
                text: statCard.icon
                iconSize: 18
                fill: 1
                padding: 6
                implicitWidth: 34
                implicitHeight: 34
            }

            Item { Layout.fillHeight: true }

            StyledText {
                text: statCard.value
                font.pixelSize: Appearance.font.pixelSize.hugeass
                font.weight: Font.Bold
                color: Appearance.colors.colOnPrimaryContainer
            }

            StyledText {
                text: statCard.label
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnPrimaryContainer
                opacity: 0.6
            }
        }
    }

    component TempStatCard: Rectangle {
        id: tempCard
        property color bgColor: Appearance.colors.colTertiaryContainer
        property color shapeColor: Appearance.colors.colTertiary

        implicitWidth: root.cardWidth
        implicitHeight: root.cardHeight
        radius: Appearance.rounding?.verylarge ?? 30
        color: tempCard.bgColor

        StyledRectangularShadow {
            target: tempCard
            z: -2
        }

        FastBlurred {
            anchors.fill: parent
            blurSource: root.wallpaperItem
            cardRadius: tempCard.radius
            tint: Appearance.colors.colLayer1
            tintOpacity: 0.55
            trackX: tempCard.x + (tempCard.parent ? tempCard.parent.x : 0) + row.x + root.x
            trackY: tempCard.y + (tempCard.parent ? tempCard.parent.y : 0) + row.y + root.y
            visible: Config.options.background.widgets.blurWidgets 
        }

        ColumnLayout {
            anchors {
                fill: parent
                margins: 14
            }
            spacing: -4

            CustomIcon {
                Layout.alignment: Qt.AlignRight
                implicitWidth: 34
                implicitHeight: 34
                width: 34
                height: 34
                source: "thermal-chip-symbolic.svg"
                colorize: true
                color: tempCard.shapeColor
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                spacing: 0
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: -4
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1

                    StyledText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: (ResourceUsage.cpuTemp > 0 ? Math.round(ResourceUsage.cpuTemp) : "--") + "°C"
                        font.pixelSize: Appearance.font.pixelSize.larger
                        font.weight: Font.Bold
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 12
                        color: Appearance.colors.colOnPrimaryContainer
                    }

                    StyledText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: "CPU"
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colOnPrimaryContainer
                        opacity: 0.6
                    }
                }

                ColumnLayout {
                    spacing: -4
                    Layout.alignment: Qt.AlignHCenter
                    Layout.leftMargin: 3
                    Layout.rightMargin: 3

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: "|"
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colOnPrimaryContainer
                        opacity: 0.4
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: "|"
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colOnPrimaryContainer
                        opacity: 0.4
                    }
                }

                ColumnLayout {
                    spacing: -4
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1

                    StyledText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: (ResourceUsage.gpuTemp > 0 ? Math.round(ResourceUsage.gpuTemp) : "--") + "°C"
                        font.pixelSize: Appearance.font.pixelSize.larger
                        font.weight: Font.Bold
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 12
                        color: Appearance.colors.colOnPrimaryContainer
                    }

                    StyledText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: "GPU"
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colOnPrimaryContainer
                        opacity: 0.6
                    }
                }
            }
        }
    }

    Component {
        id: classicCpuCardComp
        StatCard {
            icon: "planner_review"
            value: Math.round(ResourceUsage.cpuUsage * 100) + "%"
            label: "CPU"
            shape: MaterialShape.Shape.Gem
        }
    }

    Component {
        id: classicRamCardComp
        StatCard {
            icon: "memory"
            value: Math.round(ResourceUsage.memoryUsedPercentage * 100) + "%"
            label: "RAM"
            shape: MaterialShape.Shape.Cookie4Sided
            bgColor: Appearance.colors.colSecondaryContainer
            shapeColor: Appearance.colors.colSecondary
        }
    }

    Component {
        id: classicTempCardComp
        TempStatCard {
            bgColor: Appearance.colors.colTertiaryContainer
            shapeColor: Appearance.colors.colTertiary
        }
    }

    Component {
        id: wuwaCpuCardComp
        ResonanceStatCard {
            cardType: "cpu"
            implicitWidth: root.cardWidth
            implicitHeight: root.cardHeight
            wallpaperItem: root.wallpaperItem
            live: root.live
            trackX: x + (parent ? parent.x : 0) + row.x + root.x
            trackY: y + (parent ? parent.y : 0) + row.y + root.y
        }
    }

    Component {
        id: wuwaRamCardComp
        ResonanceStatCard {
            cardType: "ram"
            implicitWidth: root.cardWidth
            implicitHeight: root.cardHeight
            wallpaperItem: root.wallpaperItem
            live: root.live
            trackX: x + (parent ? parent.x : 0) + row.x + root.x
            trackY: y + (parent ? parent.y : 0) + row.y + root.y
        }
    }

    Component {
        id: wuwaTempCardComp
        ResonanceStatCard {
            cardType: "temp"
            implicitWidth: root.cardWidth
            implicitHeight: root.cardHeight
            wallpaperItem: root.wallpaperItem
            live: root.live
            trackX: x + (parent ? parent.x : 0) + row.x + root.x
            trackY: y + (parent ? parent.y : 0) + row.y + root.y
        }
    }

    Grid {
        id: row
        columns: root.isVertical ? 1 : 3
        spacing: root.cardSpacing

        Loader {
            sourceComponent: root.isWuWa ? wuwaCpuCardComp : classicCpuCardComp
        }
        Loader {
            sourceComponent: root.isWuWa ? wuwaRamCardComp : classicRamCardComp
        }
        Loader {
            sourceComponent: root.isWuWa ? wuwaTempCardComp : classicTempCardComp
        }
    }
    Rectangle {
        id: toggleHandle
        width: 16
        height: 16
        radius: 6
        color: Appearance.colors.colOnPrimaryContainer
        anchors {
            left: parent.right
            bottom: parent.bottom
            margins: -6
        }
        opacity: root.containsMouse || toggleArea.containsMouse ? 0.7 : 0
        visible: opacity > 0 && !Config.options.background.widgetsLocked

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }

        MaterialSymbol {
            anchors.centerIn: parent
            text: "rotate_right"
            iconSize: 11
            color: Appearance.colors.colPrimaryContainer

            RotationAnimation on rotation {
                running: toggleArea.containsMouse
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
            }
        }

        MouseArea {
            id: toggleArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.configEntry)
                    root.configEntry.vertical = !root.isVertical;
            }
        }
    }
}
