pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Item {
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

    readonly property bool soundsEnabled: Config.options.sounds.enable
    readonly property string themeId: Config.options.sounds.theme
    readonly property var selectedTheme: SoundService.themes.find(theme => theme.id === root.themeId)
    readonly property string themeName: selectedTheme && selectedTheme.name ? selectedTheme.name : themeId
    readonly property int volume: Config.options.sounds.volume ?? 100
    readonly property string statusText: soundsEnabled ? Translation.tr("Enabled") : Translation.tr("Disabled")
    readonly property string statusIcon: soundsEnabled ? "volume_up" : "volume_off"
    readonly property var previewEvents: ["audio-volume-change", "bell"]

    Layout.fillWidth: true
    implicitHeight: statusCard.implicitHeight

    Rectangle {
        id: statusCard

        anchors.fill: parent
        implicitHeight: cardLayout.implicitHeight + Appearance.font.pixelSize.normal * 2
        radius: Appearance.rounding.normal
        color: root.applyWuWa
            ? (root.soundsEnabled ? SettingsTheme.colCardBg : SettingsTheme.colRowBg)
            : (root.soundsEnabled ? Appearance.colors.colPrimaryContainer : Appearance.colors.colLayer2Base)
        border.width: root.applyWuWa ? 1 : 0
        border.color: root.applyWuWa ? SettingsTheme.colCardBorder : "transparent"

        ColumnLayout {
            id: cardLayout

            anchors.fill: parent
            anchors.margins: Appearance.font.pixelSize.normal
            spacing: Appearance.font.pixelSize.smallest

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.font.pixelSize.smallest

                MaterialShapeWrappedMaterialSymbol {
                    text: root.statusIcon
                    iconSize: Appearance.font.pixelSize.large
                    padding: Appearance.font.pixelSize.smallest
                    shape: root.soundsEnabled ? MaterialShape.Shape.Clover4Leaf : MaterialShape.Shape.Cookie7Sided
                    color: root.applyWuWa
                        ? (root.soundsEnabled ? SettingsTheme.colAccent : SettingsTheme.colItemBg)
                        : (root.soundsEnabled ? Appearance.colors.colPrimary : Appearance.colors.colSecondary)
                    colSymbol: root.applyWuWa
                        ? (root.soundsEnabled ? SettingsTheme.colNavOnActive : SettingsTheme.colTextSecondary)
                        : (root.soundsEnabled ? Appearance.colors.colOnPrimary : Appearance.colors.colOnSecondary)
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    StyledText {
                        text: Translation.tr("System sounds")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.DemiBold
                        color: root.applyWuWa
                            ? SettingsTheme.colTextPrimary
                            : (root.soundsEnabled ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnLayer2)
                    }

                    StyledText {
                        text: root.statusText
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: root.applyWuWa
                            ? SettingsTheme.colTextSecondary
                            : (root.soundsEnabled ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colSubtext)
                    }
                }

                RippleButton {
                    implicitHeight: Appearance.font.pixelSize.huge + Appearance.font.pixelSize.smallest
                    buttonRadius: Appearance.rounding.full
                    colBackground: root.applyWuWa
                        ? (root.soundsEnabled ? SettingsTheme.colAccent : SettingsTheme.colItemBg)
                        : (root.soundsEnabled ? Appearance.colors.colPrimary : Appearance.colors.colSecondaryContainer)
                    colBackgroundHover: root.applyWuWa
                        ? (root.soundsEnabled ? SettingsTheme.colNavActiveHover : SettingsTheme.colRowHover)
                        : (root.soundsEnabled ? Appearance.colors.colPrimaryHover : Appearance.colors.colSecondaryContainerHover)
                    colRipple: root.applyWuWa
                        ? (root.soundsEnabled ? SettingsTheme.colNavActiveHover : SettingsTheme.colAccent)
                        : (root.soundsEnabled ? Appearance.colors.colPrimaryActive : Appearance.colors.colSecondaryContainerActive)
                    borderWidth: root.applyWuWa ? 1 : 0
                    borderColor: root.applyWuWa ? (root.soundsEnabled ? SettingsTheme.colAccent : SettingsTheme.colCardBorder) : "transparent"
                    Accessible.name: Translation.tr("Preview system sound")
                    Accessible.description: Translation.tr("Play a preview using the %1 sound theme at %2 percent volume.").arg(root.themeName).arg(String(root.volume))
                    onClicked: SoundService.preview(root.themeId, root.previewEvents)

                    contentItem: RowLayout {
                        anchors.centerIn: parent
                        spacing: Appearance.font.pixelSize.smallest

                        MaterialSymbol {
                            text: "play_arrow"
                            iconSize: Appearance.font.pixelSize.normal
                            color: root.applyWuWa
                                ? (root.soundsEnabled ? SettingsTheme.colNavOnActive : SettingsTheme.colTextPrimary)
                                : (root.soundsEnabled ? Appearance.colors.colOnPrimary : Appearance.colors.colOnSecondaryContainer)
                        }

                        StyledText {
                            text: Translation.tr("Preview")
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.DemiBold
                            color: root.applyWuWa
                                ? (root.soundsEnabled ? SettingsTheme.colNavOnActive : SettingsTheme.colTextPrimary)
                                : (root.soundsEnabled ? Appearance.colors.colOnPrimary : Appearance.colors.colOnSecondaryContainer)
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.font.pixelSize.small

                StyledText {
                    Layout.fillWidth: true
                    text: Translation.tr("Theme: %1").arg(root.themeName)
                    elide: Text.ElideRight
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: root.applyWuWa
                        ? SettingsTheme.colTextSecondary
                        : (root.soundsEnabled ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colSubtext)
                }

                StyledText {
                    text: Translation.tr("Volume: %1%").arg(String(root.volume))
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: root.applyWuWa
                        ? SettingsTheme.colTextSecondary
                        : (root.soundsEnabled ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colSubtext)
                }
            }
        }
    }
}
