import qs.modules.common
import QtQuick
import QtQuick.Controls

/**
 * Material 3 switch. See https://m3.material.io/components/switch/overview
 */
Switch {
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

    // The M3 default is oversized for a pointer, hence the 0.75. But this control is
    // dragged directly, not only tapped, so a finger needs the spec size back.
    property real sizeScale: PanelFamily.touchFirst ? 1.0 : 0.75
    implicitHeight: 32 * root.sizeScale
    implicitWidth: 52 * root.sizeScale
    property color activeColor: applyWuWa ? SettingsTheme.colAccent : (Appearance?.colors.colPrimary ?? "#685496")
    property color inactiveColor: applyWuWa ? SettingsTheme.colTrackInactive : (Appearance?.colors.colSurfaceContainerHighest ?? "#45464F")
    property color activeThumbColor: applyWuWa ? SettingsTheme.colThumbActive : Appearance.m3colors.m3onPrimary
    property color inactiveThumbColor: applyWuWa ? SettingsTheme.colThumbInactive : Appearance.m3colors.m3outline

    property bool isPressed: root.pressed || root.down
    scale: (isPressed && enabled) ? 0.95 : 1.0
    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutQuad
        }
    }

    PointingHandInteraction {}

    // Custom track styling
    background: Rectangle {
        width: parent.width
        height: parent.height
        radius: Appearance?.rounding.full ?? 9999
        color: root.checked ? root.activeColor : (root.applyWuWa && root.hovered ? Qt.lighter(root.inactiveColor, 1.25) : root.inactiveColor)
        border.width: root.applyWuWa ? 1 : 0
        border.color: root.applyWuWa ? (root.activeFocus ? SettingsTheme.colBorderFocused : (root.checked ? root.activeColor : SettingsTheme.colTrackBorder)) : "transparent"

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
        Behavior on border.color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }

    // Custom thumb styling
    indicator: Rectangle {
        width: (root.pressed || root.down) ? (28 * root.sizeScale) : (24 * root.sizeScale)
        height: (root.pressed || root.down) ? (28 * root.sizeScale) : (24 * root.sizeScale)
        radius: Appearance.rounding.full
        color: root.checked ? root.activeThumbColor : root.inactiveThumbColor
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: root.checked ? ((root.pressed || root.down) ? (22 * root.sizeScale) : (24 * root.sizeScale)) : ((root.pressed || root.down) ? (2 * root.sizeScale) : (4 * root.sizeScale))

        Behavior on anchors.leftMargin {
            NumberAnimation {
                duration: Appearance.animationCurves.expressiveFastSpatialDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: Appearance.animationCurves.expressiveFastSpatialDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: Appearance.animationCurves.expressiveFastSpatialDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
            }
        }
        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }

        MaterialSymbol {
            width: 18 * root.sizeScale
            height: 18 * root.sizeScale
            anchors.centerIn: parent
            text: root.checked ? "check" : "close"
            iconSize: 18 * root.sizeScale
            color: root.checked ? root.activeColor : root.inactiveColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            Behavior on iconSize {
                NumberAnimation {
                    duration: Appearance.animationCurves.expressiveFastSpatialDuration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
                }
            }
            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
        }
    }
}
