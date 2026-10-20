import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs.modules.ii.sidebarRight.notifications
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    radius: Appearance.rounding.normal
    color: ResonanceTheme.enabled ? ResonanceTheme.bgGlassSidebarCard : Appearance.colors.colLayer1
    border.width: ResonanceTheme.enabled ? 1 : 0
    border.color: ResonanceTheme.enabled ? ResonanceTheme.borderSidebarCard : "transparent"

    NotificationList {
        anchors.fill: parent
        anchors.margins: 5
    }
}
