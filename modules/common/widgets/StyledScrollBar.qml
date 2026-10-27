import QtQuick
import QtQuick.Controls
import qs.modules.common
import qs.modules.common.functions

ScrollBar {
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

    policy: ScrollBar.AsNeeded
    topPadding: Appearance.rounding.normal
    bottomPadding: Appearance.rounding.normal
    leftPadding: applyWuWa ? 2 : 0
    rightPadding: applyWuWa ? 2 : 0
    active: hovered || pressed

    background: Rectangle {
        implicitWidth: root.applyWuWa ? 5 : 0
        visible: root.applyWuWa && (root.policy === ScrollBar.AlwaysOn || root.size < 1.0)
        color: root.applyWuWa
            ? ColorUtils.applyAlpha(SettingsTheme.colTealInkDark, 0.45)
            : "transparent"
        radius: width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    contentItem: Rectangle {
        implicitWidth: root.applyWuWa ? 5 : 4
        implicitHeight: root.visualSize
        radius: width / 2
        color: root.applyWuWa
            ? (root.hovered || root.pressed ? Qt.lighter(SettingsTheme.colAccent, 1.12) : SettingsTheme.colAccent)
            : Appearance.colors.colOnSurfaceVariant

        opacity: root.applyWuWa
            ? (root.size < 1.0 ? ((root.active || root.hovered || root.pressed) ? 0.95 : 0.70) : 0)
            : (root.policy === ScrollBar.AlwaysOn || (root.active && root.size < 1.0) ? 0.5 : 0)

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Appearance.animation.elementMoveFast.type
                easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
            }
        }
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
}
