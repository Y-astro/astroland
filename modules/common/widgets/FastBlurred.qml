import QtQuick
import Qt5Compat.GraphicalEffects
import qs.modules.common
import qs.services

Item {
    id: root
    required property Item blurSource
    property real cardRadius: 30
    property color tint: "white"
    property real tintOpacity: 0.15
    property real blurRadius: Config.options.background.widgets.blurRadius ?? 32
    property real trackX: 0
    property real trackY: 0

    // Dynamic rendering override for callers requiring continuous updates
    property bool dynamicUpdates: false

    // Internal live state controlled by invalidation triggers
    property bool _activeLive: true

    readonly property real oversample: blurRadius * 1.5

    // Public invalidation function
    function scheduleUpdate() {
        _activeLive = true;
        if (shaderSource) {
            shaderSource.scheduleUpdate();
        }
        settleTimer.restart();
    }

    function refresh() {
        scheduleUpdate();
    }

    Timer {
        id: settleTimer
        interval: 150
        repeat: false
        onTriggered: {
            if (!root.dynamicUpdates && !root.sourceIsTransitioning) {
                root._activeLive = false;
            }
        }
    }

    // Monitor wallpaper transition if blurSource provides transition telemetry
    readonly property bool sourceIsTransitioning: (root.blurSource && root.blurSource.isTransitioning !== undefined)
        ? Boolean(root.blurSource.isTransitioning)
        : false

    onSourceIsTransitioningChanged: {
        if (sourceIsTransitioning) {
            _activeLive = true;
        } else {
            scheduleUpdate();
        }
    }

    // Invalidate when blurSource signals an update serial change
    readonly property int sourceUpdateSerial: (root.blurSource && root.blurSource.updateSerial !== undefined)
        ? root.blurSource.updateSerial
        : 0
    onSourceUpdateSerialChanged: scheduleUpdate()

    // Invalidate on geometry / placement changes
    onTrackXChanged: scheduleUpdate()
    onTrackYChanged: scheduleUpdate()
    onXChanged: scheduleUpdate()
    onYChanged: scheduleUpdate()
    onWidthChanged: scheduleUpdate()
    onHeightChanged: scheduleUpdate()
    onBlurRadiusChanged: scheduleUpdate()
    onCardRadiusChanged: scheduleUpdate()
    onBlurSourceChanged: scheduleUpdate()

    // Invalidate on wallpaper changes
    readonly property string _wallpaperTrigger: String(Config.options?.background?.wallpaperPath ?? "")
        + "|" + String(Wallpapers?.effectiveWallpaperPath ?? "")
    on_WallpaperTriggerChanged: scheduleUpdate()

    // Invalidate on preset / theme switch
    readonly property bool _themeTrigger: ResonanceTheme.enabled
    on_ThemeTriggerChanged: scheduleUpdate()

    // Invalidate if window / screen scale changes
    readonly property var _screen: root.Window.window ? root.Window.window.screen : null
    readonly property real _screenScale: _screen ? (_screen.devicePixelRatio ?? 1.0) : 1.0
    on_ScreenScaleChanged: scheduleUpdate()

    Component.onCompleted: {
        _activeLive = true;
        settleTimer.restart();
    }

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width; height: root.height
            radius: root.cardRadius
        }
    }

    FastBlur {
        id: blur
        x: -root.oversample
        y: -root.oversample
        width: root.width + root.oversample * 2
        height: root.height + root.oversample * 2
        radius: root.blurRadius
        visible: root.blurSource !== null
        source: root.blurSource ? shaderSource : null

        ShaderEffectSource {
            id: shaderSource
            sourceItem: root.blurSource
            sourceRect: {
                var _fx = root.trackX
                var _fy = root.trackY
                if (!root.blurSource) return Qt.rect(0, 0, 0, 0)
                var pt = root.mapToItem(root.blurSource, -root.oversample, -root.oversample)
                return Qt.rect(pt.x, pt.y, blur.width, blur.height)
            }
            hideSource: false
            live: root.dynamicUpdates || root.sourceIsTransitioning || root._activeLive
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: root.cardRadius
        color: root.tint
        opacity: root.tintOpacity
    }
}