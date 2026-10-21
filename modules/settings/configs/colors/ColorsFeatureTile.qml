import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

/**
 * A feature as a tile, the way the clock shows an alarm: the tile takes the primary
 * container while the feature is on and the pane colour while it is off, its switch
 * and actions follow that family, and the icon's shape morphs with the state.
 * `default` content goes in the footer, left of the optional "Configure" action.
 */
Rectangle {
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
    property var shapeOn: MaterialShape.Shape.Cookie9Sided
    property var shapeOff: MaterialShape.Shape.Circle
    property string title: ""
    property string summary: ""
    property bool checked: false
    property bool configurable: false
    default property alias footer: footerRow.data

    signal toggled(bool value)
    signal configureRequested()

    readonly property bool engaged: tileHover.hovered
    readonly property color colContent: root.applyWuWa
        ? SettingsTheme.colTextPrimary
        : (root.checked ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnLayer1)

    radius: Appearance.rounding.verylarge
    color: root.applyWuWa
        ? (root.checked
            ? (root.engaged ? Qt.lighter(SettingsTheme.colCardBg, 1.25) : SettingsTheme.colCardBg)
            : (root.engaged ? SettingsTheme.colRowHover : SettingsTheme.colCardBg))
        : (root.checked
            ? (root.engaged ? Appearance.colors.colPrimaryContainerHover : Appearance.colors.colPrimaryContainer)
            : (root.engaged ? Appearance.colors.colLayer1Hover : Appearance.colors.colLayer1))
    border.width: root.applyWuWa ? 1 : 0
    border.color: root.applyWuWa
        ? (root.checked ? SettingsTheme.colAccent : SettingsTheme.colCardBorder)
        : "transparent"
    Behavior on color {
        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
    }
    Behavior on border.color {
        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
    }

    HoverHandler {
        id: tileHover
    }
    // Under the content, so the switch and the buttons keep their own clicks.
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.configurable ? root.configureRequested() : root.toggled(!root.checked)
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 20
            topMargin: 18
            rightMargin: 18
        }
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            MaterialShapeWrappedMaterialSymbol {
                text: root.symbol
                iconSize: 22
                padding: 11
                fill: root.checked ? 1 : 0
                shape: root.checked ? root.shapeOn : root.shapeOff
                color: root.applyWuWa
                    ? (root.checked ? SettingsTheme.colAccent : SettingsTheme.colItemBg)
                    : (root.checked ? Appearance.colors.colPrimary : Appearance.colors.colSecondaryContainer)
                colSymbol: root.applyWuWa
                    ? (root.checked ? SettingsTheme.colNavOnActive : SettingsTheme.colTextSecondary)
                    : (root.checked ? Appearance.colors.colOnPrimary : Appearance.colors.colOnSecondaryContainer)
                Behavior on color {
                    animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                }
            }

            Item {
                Layout.fillWidth: true
            }

            StyledSwitch {
                Layout.alignment: Qt.AlignVCenter
                sizeScale: 0.85
                checked: root.checked
                activeColor: root.applyWuWa ? SettingsTheme.colAccent : Appearance.colors.colPrimary
                activeThumbColor: root.applyWuWa ? SettingsTheme.colThumbActive : Appearance.colors.colOnPrimary
                inactiveColor: root.applyWuWa ? SettingsTheme.colTrackInactive : Appearance.colors.colSurfaceContainerHighest
                onToggled: root.toggled(checked)
            }
        }

        StyledText {
            Layout.fillWidth: true
            Layout.topMargin: 14
            text: root.title
            font.family: Appearance.font.family.title
            font.variableAxes: Appearance.font.variableAxes.titleRounded
            font.pixelSize: Appearance.font.pixelSize.larger
            color: root.colContent
            elide: Text.ElideRight
        }

        StyledText {
            id: summaryText
            Layout.fillWidth: true
            Layout.topMargin: 2
            // Two lines are always reserved so tiles in a row keep their footers level.
            Layout.preferredHeight: summaryMetrics.height * 2
            text: root.summary
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: root.applyWuWa ? SettingsTheme.colTextSecondary : root.colContent
            opacity: 0.8
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
            verticalAlignment: Text.AlignTop

            FontMetrics {
                id: summaryMetrics
                font: summaryText.font
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 12
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            RowLayout {
                id: footerRow
                Layout.fillWidth: true
                spacing: 8
            }

            RippleButton {
                id: configureButton
                visible: root.configurable
                Layout.alignment: Qt.AlignRight
                implicitHeight: 36
                implicitWidth: configureRow.implicitWidth + 28
                buttonRadius: height / 2
                buttonRadiusPressed: Appearance.rounding.small
                borderWidth: root.applyWuWa ? 1 : 0
                borderColor: root.applyWuWa ? SettingsTheme.colRowBorder : "transparent"
                colBackground: root.applyWuWa ? SettingsTheme.colItemBg : ColorUtils.applyAlpha(root.colContent, 0.1)
                colBackgroundHover: root.applyWuWa ? SettingsTheme.colRowHover : ColorUtils.applyAlpha(root.colContent, 0.18)
                colBackgroundActive: root.applyWuWa ? SettingsTheme.colRowHover : ColorUtils.applyAlpha(root.colContent, 0.26)
                colRipple: root.applyWuWa ? SettingsTheme.colRowHover : ColorUtils.applyAlpha(root.colContent, 0.26)
                onClicked: root.configureRequested()

                contentItem: Item {
                    RowLayout {
                        id: configureRow
                        anchors.centerIn: parent
                        spacing: 6

                        MaterialSymbol {
                            text: "tune"
                            iconSize: Appearance.font.pixelSize.normal
                            color: root.applyWuWa ? SettingsTheme.colTextPrimary : root.colContent
                        }
                        StyledText {
                            text: Translation.tr("Configure")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            font.weight: Font.DemiBold
                            color: root.applyWuWa ? SettingsTheme.colTextPrimary : root.colContent
                        }
                    }
                }
            }
        }
    }
}
