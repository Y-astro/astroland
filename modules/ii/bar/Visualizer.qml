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
    property real visualizerHeight: 22

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
    readonly property bool motionNormal: !motionOff && !motionAmbient
    readonly property bool canAnimate: root.visible && root.opacity > 0
        && (!root.Window.window || root.Window.window.visible)
        && !GlobalStates.screenLocked && !root.motionOff
    readonly property bool normalRunning: canAnimate && motionNormal
    readonly property bool ambientRunning: canAnimate && motionAmbient

    property real ambientPhase: 0.0
    property real phaseTime: 0.0
    property real smoothEnergy: 0.0

    function advanceMotion(dt) {
        root.phaseTime += dt;
        const twoPi = 2.0 * Math.PI;
        const pBob = root.phaseTime * (twoPi / 3.6);
        const pY = root.phaseTime * (twoPi / 3.0);
        const pX = root.phaseTime * (twoPi / 4.0);
        const pGlow = root.phaseTime * (twoPi / 2.8);

        const idleBob = -0.8 * Math.sin(pBob);
        const idleScaleY = 1.0 + 0.06 * Math.sin(pY);
        const idleScaleX = 1.0 - 0.03 * Math.sin(pX);
        const idleGlow = 0.28 + 0.14 * Math.sin(pGlow);

        const targetEnergy = root.hasAudio ? root.audioEnergy : 0.0;
        root.smoothEnergy += (targetEnergy - root.smoothEnergy) * Math.min(1.0, dt * 10.0);
        const energy = root.smoothEnergy;

        container.anchors.verticalCenterOffset = idleBob * (1.0 - energy * 0.5);
        breathScale.yScale = idleScaleY + 0.07 * energy;
        breathScale.xScale = idleScaleX - 0.03 * energy;
        auraBlur.opacity = Math.min(0.85, idleGlow + 0.30 * energy);
        animatedShader.time += dt * (1.0 + energy * 1.5);
    }

    function resetStatic() {
        if (!normalRunning && !ambientRunning) {
            container.anchors.verticalCenterOffset = 0;
            breathScale.xScale = 1.0;
            breathScale.yScale = 1.0;
            auraBlur.opacity = 0.28;
            root.smoothEnergy = 0.0;
        } else if (ambientRunning) {
            container.anchors.verticalCenterOffset = 0;
            root.smoothEnergy = 0.0;
        }
    }

    onNormalRunningChanged: resetStatic()
    onAmbientRunningChanged: resetStatic()
    Component.onCompleted: resetStatic()

    // Full-rate audio reactive driver during music playback
    FrameAnimation {
        id: audioTicker
        running: root.normalRunning && root.hasAudio
        onTriggered: root.advanceMotion(Math.min(frameTime, 0.05))
    }

    // Paced gentle breathing driver during idle silence (~30 fps)
    Timer {
        id: idleTimer
        interval: 33
        repeat: true
        running: root.normalRunning && !root.hasAudio
        onTriggered: root.advanceMotion(interval / 1000.0)
    }

    // Ambient mode low-rate gentle idle breath (~8 fps, explicitly low-rate including active playback)
    Timer {
        id: ambientTimer
        interval: 125 // ~8 fps
        repeat: true
        running: root.ambientRunning
        onTriggered: {
            root.ambientPhase = (root.ambientPhase + 0.08) % (2.0 * Math.PI);
            breathScale.yScale = 1.0 + 0.04 * Math.sin(root.ambientPhase);
            breathScale.xScale = 1.0 - 0.02 * Math.sin(root.ambientPhase);
            container.anchors.verticalCenterOffset = 0;
            auraBlur.opacity = 0.20 + 0.12 * Math.sin(root.ambientPhase);
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
        // The aura SVG and ColorOverlay are completely static.
        // Animating FastBlur.opacity directly avoids dirtying the blur source, so FastBlur
        // never needs to re-execute multi-pass GPU blur passes each frame.
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
            scale: 1.05
            cached: true
        }

        FastBlur {
            id: auraBlur
            anchors.fill: auraOverlay
            source: auraOverlay
            radius: 6
            cached: true
            opacity: 0.28
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
