import QtQuick
import QtQuick.Layouts

import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: sectionCardRoot

    Layout.fillWidth: true
    implicitWidth: 320
    implicitHeight: sectionColumn.implicitHeight + margins * 2

    radius: BarPopupTheme.radiusCard
    color: BarPopupTheme.colCardBackground
    border.width: BarPopupTheme.cardBorderWidth
    border.color: BarPopupTheme.colCardBorder

    property int margins: 16
    property int spacing: 12
    property string shapeString: "Slanted"
    property int shapeSize: 36
    property alias icon: iconSymbol.text
    property alias title: titleText.text
    property alias subtitle: subtitleText.text
    property color shapeColor: BarPopupTheme.isWuWa ? BarPopupTheme.colCardBackgroundHover : Appearance.colors.colTertiaryContainer
    property color symbolColor: BarPopupTheme.isWuWa ? BarPopupTheme.colAccent : Appearance.colors.colOnTertiaryContainer
    property bool showDivider: true
    property string headerExtraText: ""

    default property alias content: contentColumn.data
    property alias shapeContent: shapeItem.data
    property alias headerExtra: headerExtraContainer.data

    ColumnLayout {
        id: sectionColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: sectionCardRoot.margins
        spacing: sectionCardRoot.spacing

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            MaterialShape {
                id: shapeItem
                shapeString: sectionCardRoot.shapeString
                implicitSize: sectionCardRoot.shapeSize
                color: sectionCardRoot.shapeColor

                MaterialSymbol {
                    id: iconSymbol
                    visible: iconSymbol.text !== "" && shapeItem.children.length <= 1
                    anchors.centerIn: parent
                    iconSize: Appearance.font.pixelSize.normal
                    color: sectionCardRoot.symbolColor
                }
            }

            StyledText {
                id: titleText
                Layout.fillWidth: true
                font.family: Appearance.font.family.title
                font.pixelSize: Appearance.font.pixelSize.large
                font.weight: Font.Bold
                color: BarPopupTheme.colTextPrimary
            }

            RowLayout {
                id: headerExtraContainer
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                StyledText {
                    visible: sectionCardRoot.headerExtraText !== ""
                    text: sectionCardRoot.headerExtraText
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: BarPopupTheme.colTextSecondary
                }
            }
        }

        Rectangle {
            visible: sectionCardRoot.showDivider
            Layout.fillWidth: true
            height: 2
            color: BarPopupTheme.colDivider
            radius: 1
        }

        ColumnLayout {
            id: contentColumn
            Layout.fillWidth: true
            spacing: sectionCardRoot.spacing

            StyledText {
                id: subtitleText
                visible: subtitleText.text !== ""
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.Wrap
                font.pixelSize: Appearance.font.pixelSize.normal
                color: BarPopupTheme.colTextSecondary
                lineHeight: 1.4
            }
        }
    }
}