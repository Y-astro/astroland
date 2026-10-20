import QtQuick
import qs.modules.common

Rectangle {
    id: root

    radius: Appearance.rounding.normal
    color: ResonanceTheme.enabled ? ResonanceTheme.bgGlassSidebarCard : Appearance.colors.colLayer1
    border.width: ResonanceTheme.enabled ? 1 : 0
    border.color: ResonanceTheme.enabled ? ResonanceTheme.borderSidebarCard : "transparent"

    signal openAudioOutputDialog()
    signal openAudioInputDialog()
    signal openBluetoothDialog()
    signal openNightLightDialog()
    signal openWifiDialog()
    signal openTailscaleDialog()
}
