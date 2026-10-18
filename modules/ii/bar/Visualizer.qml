import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Mpris
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    property bool vertical: Config.options.bar.vertical
    property bool isMaterial: Config.options.bar.cornerStyle === 3
    property bool mirrored: false
    property bool isPlaying: MprisController.activePlayer?.isPlaying ?? false

    // Target dimensions for the tacet mark inside the bar pill
    property real visualizerWidth: 105
    property real visualizerHeight: 30

    implicitWidth: vertical
        ? Appearance.sizes.verticalBarWidth
        : (isMaterial ? visualizerWidth + 20 : visualizerWidth)
    implicitHeight: vertical
        ? (isMaterial ? visualizerWidth + 20 : visualizerWidth)
        : Appearance.sizes.barHeight

    transform: Scale {
        xScale: !root.vertical && root.mirrored ? -1 : 1
        origin.x: root.width / 2
    }

    // Audio energy derived from visualizer points
    readonly property real audioEnergy: {
        const pts = GlobalStates.visualizerPoints;
        if (!pts || pts.length === 0) return 0;
        let sum = 0;
        const len = Math.min(pts.length, 16);
        for (let i = 0; i < len; i++)
            sum += Number.isFinite(pts[i]) ? Math.max(0, pts[i]) : 0;
        return Math.min(1.0, (sum / len) / 60.0);
    }
    readonly property bool hasAudio: audioEnergy > 0.05 || root.isPlaying

    // Theme color adaptation
    readonly property color auraColor: ResonanceTheme.enabled ? ResonanceTheme.accentGold : Appearance.colors.colPrimary
    readonly property color shaderPrimary: ResonanceTheme.enabled ? ResonanceTheme.accentGold : Appearance.colors.colPrimary
    readonly property color shaderAccent: ResonanceTheme.enabled ? ResonanceTheme.textPrimary : Appearance.m3colors.m3tertiary

    // Motion gating
    readonly property bool motionOff: Appearance.reducedMotion || (ResonanceTheme.enabled && ResonanceTheme.motionOff)
    readonly property bool motionAmbient: ResonanceTheme.enabled && ResonanceTheme.motionAmbient && !Appearance.reducedMotion
    readonly property bool canAnimate: root.visible && root.opacity > 0
        && (!root.Window.window || root.Window.window.visible)
        && !GlobalStates.screenLocked && !root.motionOff
    readonly property bool activeMotionRunning: canAnimate && hasAudio

    property real ambientPhase: 0.0

    function resetIfInactive() {
        if (!activeMotionRunning && (!canAnimate || !motionAmbient)) {
            container.anchors.verticalCenterOffset = 0;
            breathScale.xScale = 1.0;
            breathScale.yScale = 1.0;
            auraOverlay.opacity = 0.35;
        }
    }

    onActiveMotionRunningChanged: resetIfInactive()
    onCanAnimateChanged: resetIfInactive()
    onMotionAmbientChanged: resetIfInactive()

    // Active music playback animation driver (~30 fps, bounded motion reacting to audio energy)
    Timer {
        id: shaderTimer
        interval: 33 // ~30 fps
        repeat: true
        running: root.activeMotionRunning
        onTriggered: {
            animatedShader.time += 0.033;
            var energy = root.audioEnergy;
            breathScale.yScale = 1.0 + 0.08 * energy;
            breathScale.xScale = 1.0 - 0.04 * energy;
            container.anchors.verticalCenterOffset = -1.5 * energy;
            auraOverlay.opacity = 0.22 + 0.35 * energy;
        }
    }

    // Ambient mode low-rate gentle idle breath (~8 fps, only when ambient motion enabled and idle)
    Timer {
        id: ambientTimer
        interval: 125 // ~8 fps
        repeat: true
        running: root.canAnimate && root.motionAmbient && !root.hasAudio
        onTriggered: {
            root.ambientPhase = (root.ambientPhase + 0.08) % (2.0 * Math.PI);
            breathScale.yScale = 1.0 + 0.04 * Math.sin(root.ambientPhase);
            breathScale.xScale = 1.0 - 0.02 * Math.sin(root.ambientPhase);
            container.anchors.verticalCenterOffset = 0;
            auraOverlay.opacity = 0.25 + 0.15 * Math.sin(root.ambientPhase);
            animatedShader.time += 0.008;
        }
    }

    Item {
        id: container
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 0
        width: root.visualizerWidth
        height: root.visualizerHeight
        rotation: root.vertical ? 90 : 0

        transform: Scale {
            id: breathScale
            origin.x: container.width / 2
            origin.y: container.height / 2
            xScale: 1.0
            yScale: 1.0
        }

        // Texture provider: high-resolution SVG render of the authentic WuWa Tacet Mark
        Image {
            id: tacetSource
            source: Qt.resolvedUrl("../../../assets/icons/tacet-mark.svg")
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            sourceSize.width: 496
            sourceSize.height: 165
            smooth: true
            mipmap: true
        }

        ShaderEffectSource {
            id: tacetSourceItem
            sourceItem: tacetSource
            hideSource: true
            live: false
        }

        // Layer 1: Soft luminous aura / glow behind the tacet mark
        Image {
            id: auraImage
            source: Qt.resolvedUrl("../../../assets/icons/tacet-mark.svg")
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            sourceSize.width: 496
            sourceSize.height: 165
            smooth: true
        }

        ColorOverlay {
            id: auraOverlay
            anchors.fill: auraImage
            source: auraImage
            color: root.auraColor
            scale: 1.08
            opacity: 0.35
        }

        FastBlur {
            anchors.fill: auraOverlay
            source: auraOverlay
            radius: 8
            opacity: 0.8
        }

        // Layer 2: Sharp animated tacet mark with resonant energy wave & highlight crest
        ShaderEffect {
            id: animatedShader
            anchors.fill: parent

            property var source: tacetSourceItem
            property real time: 0.0
            property vector2d resolution: Qt.vector2d(width, height)
            property color colorPrimary: root.shaderPrimary
            property color colorAccent: root.shaderAccent

            fragmentShader: Qt.resolvedUrl("shaders/tacet_animated.frag.qsb")
        }
    }
}
