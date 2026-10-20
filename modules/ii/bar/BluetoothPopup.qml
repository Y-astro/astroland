import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root

    function deviceType(device) {
        switch (Icons.getBluetoothDeviceMaterialSymbol(device?.icon || "")) {
        case "headphones": return Translation.tr("Headphones")
        case "earbuds": return Translation.tr("Earbuds")
        case "speaker": return Translation.tr("Speaker")
        case "keyboard": return Translation.tr("Keyboard")
        case "mouse": return Translation.tr("Mouse")
        case "gamepad": return Translation.tr("Game controller")
        case "phone": return Translation.tr("Phone")
        case "tablet": return Translation.tr("Tablet")
        case "computer": return Translation.tr("Computer")
        case "printer": return Translation.tr("Printer")
        default: return Translation.tr("Bluetooth device")
        }
    }

    function hasBattery(device) {
        return device?.batteryAvailable && Number.isFinite(Number(device?.battery))
    }

    ColumnLayout {
        id: contentLayout
        implicitWidth: 280
        spacing: 8

        Rectangle {
            visible: BluetoothStatus.connectedDevices.length === 0
            implicitWidth: 280
            implicitHeight: visible ? emptyText.implicitHeight + 24 : 0
            radius: BarPopupTheme.radiusCard
            color: BarPopupTheme.colCardBackground
            border.width: BarPopupTheme.cardBorderWidth
            border.color: BarPopupTheme.colCardBorder

            StyledText {
                id: emptyText
                anchors.centerIn: parent
                color: BarPopupTheme.colTextSecondary
                text: BluetoothStatus.enabled
                    ? Translation.tr("No connected devices")
                    : Translation.tr("Bluetooth is off")
            }
        }

        Repeater {
            model: BluetoothStatus.connectedDevices

            delegate: Rectangle {
                required property var modelData
                implicitWidth: 280
                implicitHeight: cardContent.implicitHeight + 24
                radius: BarPopupTheme.radiusCard
                color: BarPopupTheme.colCardBackground
                border.width: BarPopupTheme.cardBorderWidth
                border.color: BarPopupTheme.colCardBorder

                ColumnLayout {
                    id: cardContent
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        topMargin: 16
                    }
                    width: parent.width - 32
                    spacing: 4

                    StyledText {
                        Layout.fillWidth: true
                        text: modelData?.name || Translation.tr("Unknown device")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.Medium
                        color: BarPopupTheme.colTextPrimary
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: `${root.deviceType(modelData)} · ${Translation.tr("Connected")}`
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: BarPopupTheme.colTextSecondary
                        opacity: 0.8
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        implicitWidth: parent.width
                        spacing: 8

                        MaterialShapeWrappedMaterialSymbol {
                            Layout.alignment: Qt.AlignVCenter
                            shape: MaterialShape.Shape.ClamShell
                            text: Icons.getBluetoothDeviceMaterialSymbol(modelData?.icon || "")
                            iconSize: Appearance.font.pixelSize.large
                            implicitSize: Appearance.font.pixelSize.hugeass * 2
                            color: BarPopupTheme.colIconContainer
                            colSymbol: BarPopupTheme.colAccent
                        }

                        Item { Layout.fillWidth: true }

                        StyledText {
                            visible: root.hasBattery(modelData)
                            Layout.alignment: Qt.AlignVCenter
                            text: `${Math.round(Number(modelData.battery) * 100)}%`
                            font.pixelSize: Appearance.font.pixelSize.hugeass * 2
                            font.weight: Font.DemiBold
                            font.features: { "tnum": 1 }
                            color: BarPopupTheme.colAccent
                        }
                    }
                }

            }
        }
    }
}
