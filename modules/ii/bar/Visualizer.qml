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
    property real visualizerWidth: 92
    property real visualizerHeight: 28

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

    // Audio energy derived from unified GlobalStates telemetry
    readonly property real audioEnergy: GlobalStates.audioEnergy
    readonly property bool hasAudio: GlobalStates.hasAudioEnergy || root.isPlaying

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
    property bool settled: true
    property int settleTicks: 0

    function advanceMotion(dt) {
        root.settled = false;
        root.settleTicks = 0;
        root.phaseTime += dt;
        const twoPi = 2.0 * Math.PI;
        const pBob = root.phaseTime * (twoPi / 3.6);
        const pY = root.phaseTime * (twoPi / 3.0);
        const pX = root.phaseTime * (twoPi / 4.0);
        const pGlow = root.phaseTime * (twoPi / 2.8);

        const idleBob = -0.35 * Math.sin(pBob);
        const idleScaleY = 1.0 + 0.04 * Math.sin(pY);
        const idleScaleX = 1.0 - 0.02 * Math.sin(pX);
        const idleGlow = 0.28 + 0.14 * Math.sin(pGlow);

        const targetEnergy = root.hasAudio ? root.audioEnergy : 0.0;
        root.smoothEnergy += (targetEnergy - root.smoothEnergy) * Math.min(1.0, dt * 10.0);
        const energy = root.smoothEnergy;

        container.anchors.verticalCenterOffset = idleBob * (1.0 - energy * 0.5);
        breathScale.yScale = idleScaleY + 0.04 * energy;
        breathScale.xScale = idleScaleX - 0.015 * energy;
        auraBlur.opacity = Math.min(0.85, idleGlow + 0.30 * energy);
        animatedShader.time += dt * (1.0 + energy * 1.5);
    }

    function settleResting(dt) {
        root.settleTicks++;
        // Smooth easing toward neutral resting stance over ~0.5-1s
        const ease = Math.min(1.0, dt * 4.5);

        container.anchors.verticalCenterOffset += (0.0 - container.anchors.verticalCenterOffset) * ease;
        breathScale.xScale += (1.0 - breathScale.xScale) * ease;
        breathScale.yScale += (1.0 - breathScale.yScale) * ease;
        auraBlur.opacity += (0.28 - auraBlur.opacity) * ease;
        root.smoothEnergy += (0.0 - root.smoothEnergy) * ease;
        animatedShader.time += dt * (1.0 + root.smoothEnergy * 1.5);

        const dOffset = Math.abs(container.anchors.verticalCenterOffset);
        const dScaleX = Math.abs(breathScale.xScale - 1.0);
        const dScaleY = Math.abs(breathScale.yScale - 1.0);
        const dAura = Math.abs(auraBlur.opacity - 0.28);
        const dEnergy = Math.abs(root.smoothEnergy);

        if (root.settleTicks >= 30 || (dOffset < 0.01 && dScaleX < 0.001 && dScaleY < 0.001 && dAura < 0.005 && dEnergy < 0.005)) {
            container.anchors.verticalCenterOffset = 0;
            breathScale.xScale = 1.0;
            breathScale.yScale = 1.0;
            auraBlur.opacity = 0.28;
            root.smoothEnergy = 0.0;
            root.settled = true;
            root.settleTicks = 0;
        }
    }

    function resetStatic() {
        if (!normalRunning && !ambientRunning) {
            container.anchors.verticalCenterOffset = 0;
            breathScale.xScale = 1.0;
            breathScale.yScale = 1.0;
            auraBlur.opacity = 0.28;
            root.smoothEnergy = 0.0;
            root.settled = true;
            root.settleTicks = 0;
        } else if (ambientRunning) {
            container.anchors.verticalCenterOffset = 0;
            root.smoothEnergy = 0.0;
            root.settled = true;
            root.settleTicks = 0;
        }
    }

    onNormalRunningChanged: resetStatic()
    onAmbientRunningChanged: resetStatic()
    onHasAudioChanged: {
        if (hasAudio) {
            settled = false;
            settleTicks = 0;
        } else {
            if (normalRunning) {
                settled = false;
                settleTicks = 0;
            } else {
                resetStatic();
            }
        }
    }
    Component.onCompleted: resetStatic()

    // Full-rate audio reactive driver during music playback
    FrameAnimation {
        id: audioTicker
        running: root.normalRunning && root.hasAudio
        onTriggered: root.advanceMotion(Math.min(frameTime, 0.05))
    }

    // Smooth resting settling driver when audio stops (~30 fps, dormant once settled)
    Timer {
        id: idleTimer
        interval: 33
        repeat: true
        running: root.normalRunning && !root.hasAudio && !root.settled
        onTriggered: root.settleResting(interval / 1000.0)
    }

    // Ambient mode low-rate gentle idle breath (~8 fps, explicitly low-rate including active playback)
    Timer {
        id: ambientTimer
        interval: 125 // ~8 fps
        repeat: true
        running: root.ambientRunning
        onTriggered: {
            root.ambientPhase = (root.ambientPhase + 0.08) % (2.0 * Math.PI);
            breathScale.yScale = 1.0 + 0.03 * Math.sin(root.ambientPhase);
            breathScale.xScale = 1.0 - 0.015 * Math.sin(root.ambientPhase);
            container.anchors.verticalCenterOffset = 0;
            auraBlur.opacity = 0.20 + 0.12 * Math.sin(root.ambientPhase);
            animatedShader.time += 0.008;
        }
    }

    Item {
        id: container
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 0
        width: Math.round(root.visualizerHeight * 3)
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
            sourceSize.width: 774
            sourceSize.height: 258
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
            sourceSize.width: 774
            sourceSize.height: 258
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
