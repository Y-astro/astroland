import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root
    property var today: new Date()

    function usageColor(value) {
        if (value > 0.9) return Appearance.colors.colError
        if (value > 0.6) return Appearance.m3colors.m3tertiary
        return Appearance.colors.colPrimary
    }

    ColumnLayout {
        spacing: 8
        width: 340

        Row {
            width: parent.width

            StyledText {
                text: Qt.locale().toString(root.today, " MMMM")
                font.pixelSize: Appearance.font.pixelSize.huge
                font.weight: Font.Bold
                color: BarPopupTheme.colTextPrimary
            }

            StyledText {
                text: " " + Qt.locale().toString(root.today, "yyyy")
                font.pixelSize: Appearance.font.pixelSize.huge
                color: BarPopupTheme.colTextSecondary
            }
        }

        RowLayout {
            width: parent.width
            spacing: 4

            Repeater {
                model: 7
                delegate: Rectangle {
                    required property int index

                    readonly property var date: {
                        const today = root.today
                        const dow = today.getDay()
                        const d = new Date(today)
                        d.setDate(today.getDate() - dow + index)
                        return d
                    }
                    readonly property bool isToday: {
                        const t = root.today
                        return date.getDate()     === t.getDate() &&
                               date.getMonth()    === t.getMonth() &&
                               date.getFullYear() === t.getFullYear()
                    }

                    Layout.fillWidth: true
                    height: 56
                    radius: BarPopupTheme.radiusCard
                    color: isToday
                        ? BarPopupTheme.colCardBackgroundActive
                        : BarPopupTheme.colCardBackground
                    border.width: BarPopupTheme.cardBorderWidth
                    border.color: isToday
                        ? BarPopupTheme.colAccent
                        : BarPopupTheme.colCardBorder

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: Qt.locale().toString(date, "ddd").slice(0, 2)
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: isToday
                                ? BarPopupTheme.colAccent
                                : BarPopupTheme.colTextSecondary
                            font.weight: isToday ? Font.Bold : Font.Normal
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: date.getDate()
                            font.pixelSize: isToday
                                ? Appearance.font.pixelSize.normal
                                : Appearance.font.pixelSize.small
                            font.weight: isToday ? Font.Bold : Font.Normal
                            color: isToday
                                ? BarPopupTheme.colTextPrimary
                                : BarPopupTheme.colTextPrimary
                        }
                    }
                }
            }
        }

        Row {
            width: parent.width
            spacing: 6

            Column {
                spacing: 2
                anchors.verticalCenter: parent.verticalCenter

                MaterialShapeWrappedMaterialSymbol {
                    shape: MaterialShape.Shape.Clover4Leaf
                    text: "checklist"
                    iconSize: Appearance.font.pixelSize.large
                    implicitSize: 36
                    color: BarPopupTheme.isWuWa ? BarPopupTheme.colCardBackgroundActive : Appearance.colors.colPrimaryContainer
                    colSymbol: BarPopupTheme.colAccent
                }

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: `${Todo.list.filter(t => !t.done).length}`
                    font.pixelSize: Appearance.font.pixelSize.huge
                    font.weight: Font.Bold
                    color: BarPopupTheme.colAccent
                }
            }

            Column {
                width: parent.width - 36 - 6
                spacing: 2

                Repeater {
                    id: todoRepeater
                    model: Math.min(3, Todo.list.filter(t => !t.done).length)

                    delegate: Rectangle {
                        required property int index
                        readonly property var filteredList: Todo.list.filter(t => !t.done)
                        readonly property var todo: filteredList[filteredList.length - 1 - index]
                        readonly property int total: todoRepeater.count
                        readonly property bool isFirst: index === 0
                        readonly property bool isLast: index === total - 1
                        readonly property real bigRadius: BarPopupTheme.radiusCard
                        readonly property real smallRadius: Appearance.rounding.unsharpenmore

                        width: parent.width
                        height: 32
                        topLeftRadius:     isFirst ? bigRadius : smallRadius
                        topRightRadius:    isFirst ? bigRadius : smallRadius
                        bottomLeftRadius:  isLast  ? bigRadius : smallRadius
                        bottomRightRadius: isLast  ? bigRadius : smallRadius
                        color: BarPopupTheme.colCardBackground
                        border.width: BarPopupTheme.cardBorderWidth
                        border.color: BarPopupTheme.colCardBorder

                        StyledText {
                            anchors {
                                left: parent.left
                                leftMargin: 10
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                                rightMargin: 10
                            }
                            text: `    ${todo.content} `
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: BarPopupTheme.colTextPrimary
                            elide: Text.ElideRight
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 64
                    visible: Todo.list.filter(t => !t.done).length === 0
                    radius: BarPopupTheme.radiusCard
                    color: BarPopupTheme.colCardBackground
                    border.width: BarPopupTheme.cardBorderWidth
                    border.color: BarPopupTheme.colCardBorder

                    StyledText {
                        anchors.centerIn: parent
                        text: Translation.tr("No pending tasks")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: BarPopupTheme.colTextSecondary
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 10
            color: "transparent"

            RowLayout {
                anchors.centerIn: parent
                spacing: 6

                MaterialSymbol {
                    text: "timelapse"
                    iconSize: Appearance.font.pixelSize.small
                    color: BarPopupTheme.colAccent
                }

                StyledText {
                    text: Translation.tr("System Uptime")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: BarPopupTheme.colTextSecondary
                }

                StyledText {
                    text: "•"
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: BarPopupTheme.colTextSecondary
                }

                StyledText {
                    text: DateTime.uptime
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: BarPopupTheme.colTextPrimary
                }
            }
        }
    }
}