pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services

Item {
    id: root
    implicitHeight: navigationRow.implicitHeight
    height: implicitHeight

    signal requestOpenSubPage(url subPageUrl)

    RowLayout {
        id: navigationRow
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        // Contacts Card
        RippleButton {
            id: contactsBtn
            Layout.fillWidth: true
            // Equal preferred widths so the row splits exactly in half;
            // left to implicitWidth, the longer label claimed more.
            Layout.preferredWidth: 1
            Layout.minimumWidth: 0
            Layout.preferredHeight: 58
            buttonRadius: Appearance.rounding.normal
            colBackground: ResonanceTheme.enabled ? ResonanceTheme.bgGlassPopupCard : Appearance.colors.colLayer3
            colBackgroundHover: ResonanceTheme.enabled ? ResonanceTheme.bgGlassPopupCardHover : Appearance.colors.colLayer3Hover
            colBackgroundActive: ResonanceTheme.enabled ? ResonanceTheme.bgGlassPopupCardActive : (Appearance.colors.colLayer3Active ?? Appearance.colors.colLayer3Hover)
            borderWidth: ResonanceTheme.enabled ? 1 : 0
            borderColor: ResonanceTheme.enabled ? ResonanceTheme.borderHairline : "transparent"

            contentItem: RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                MaterialShapeWrappedMaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "contacts"
                    iconSize: 20
                    padding: 8
                    fill: 1.0
                    color: ResonanceTheme.enabled
                        ? ColorUtils.applyAlpha(ResonanceTheme.colAntiqueGold, 0.16)
                        : Appearance.colors.colPrimaryContainer
                    colSymbol: ResonanceTheme.enabled
                        ? ResonanceTheme.colAntiqueGold
                        : Appearance.colors.colOnPrimaryContainer
                    shape: MaterialShape.Shape.Cookie9Sided
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 0

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Contacts")
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.DemiBold
                        color: ResonanceTheme.enabled ? ResonanceTheme.textPrimary : Appearance.colors.colOnLayer3
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: PhoneContactsService.ready
                              ? (PhoneContactsService.count === 1
                                 ? Translation.tr("1 contact")
                                 : Translation.tr("%1 contacts").arg(String(PhoneContactsService.count)))
                              : Translation.tr("Syncing…")
                        font.pixelSize: Appearance.font.pixelSize.smallest
                        color: ResonanceTheme.enabled ? ResonanceTheme.textSecondary : Appearance.colors.colSubtext
                        opacity: ResonanceTheme.enabled ? 0.9 : 0.8
                        elide: Text.ElideRight
                    }
                }

                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "chevron_right"
                    iconSize: Appearance.font.pixelSize.normal
                    color: ResonanceTheme.enabled ? ResonanceTheme.textTertiary : Appearance.colors.colSubtext
                }
            }

            onClicked: root.requestOpenSubPage(Qt.resolvedUrl("PhoneContactsPage.qml"))
        }

        // Android Apps Card
        RippleButton {
            id: appsBtn
            Layout.fillWidth: true
            // Equal preferred widths so the row splits exactly in half;
            // left to implicitWidth, the longer label claimed more.
            Layout.preferredWidth: 1
            Layout.minimumWidth: 0
            Layout.preferredHeight: 58
            buttonRadius: Appearance.rounding.normal
            colBackground: ResonanceTheme.enabled ? ResonanceTheme.bgGlassPopupCard : Appearance.colors.colLayer3
            colBackgroundHover: ResonanceTheme.enabled ? ResonanceTheme.bgGlassPopupCardHover : Appearance.colors.colLayer3Hover
            colBackgroundActive: ResonanceTheme.enabled ? ResonanceTheme.bgGlassPopupCardActive : (Appearance.colors.colLayer3Active ?? Appearance.colors.colLayer3Hover)
            borderWidth: ResonanceTheme.enabled ? 1 : 0
            borderColor: ResonanceTheme.enabled ? ResonanceTheme.borderHairline : "transparent"

            contentItem: RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                MaterialShapeWrappedMaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "apps"
                    iconSize: 20
                    padding: 8
                    fill: 1.0
                    color: ResonanceTheme.enabled
                        ? ColorUtils.applyAlpha(ResonanceTheme.colMistySage, 0.16)
                        : Appearance.colors.colSecondaryContainer
                    colSymbol: ResonanceTheme.enabled
                        ? ResonanceTheme.colMistySage
                        : Appearance.colors.colOnSecondaryContainer
                    shape: MaterialShape.Shape.Cookie9Sided
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 0

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Android Apps")
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.DemiBold
                        color: ResonanceTheme.enabled ? ResonanceTheme.textPrimary : Appearance.colors.colOnLayer3
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("scrcpy 4.0 App Mode")
                        font.pixelSize: Appearance.font.pixelSize.smallest
                        color: ResonanceTheme.enabled ? ResonanceTheme.textSecondary : Appearance.colors.colSubtext
                        opacity: ResonanceTheme.enabled ? 0.9 : 0.8
                        elide: Text.ElideRight
                    }
                }

                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    text: "chevron_right"
                    iconSize: Appearance.font.pixelSize.normal
                    color: ResonanceTheme.enabled ? ResonanceTheme.textTertiary : Appearance.colors.colSubtext
                }
            }

            onClicked: root.requestOpenSubPage(Qt.resolvedUrl("PhoneAppsPage.qml"))
        }
    }
}
