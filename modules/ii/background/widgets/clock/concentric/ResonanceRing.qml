pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.services

Item {
    id: root

    property real baseWidth: width
    property real baseHeight: height
    property bool minutePillVisible: true
    property bool live: true

    property color accentGold: ResonanceTheme.accentGold
    property color borderSubtle: ResonanceTheme.borderSubtle
    property color borderHairline: ResonanceTheme.borderHairline
    property color textIvory: ResonanceTheme.textPrimary
    property color textSecondary: ResonanceTheme.textSecondary
    property real intensity: ResonanceTheme.intensity

    ResonanceClockGeometry { id: clockGeom }

    anchors.fill: parent
    enabled: false

    Canvas {
        id: ringCanvas
        anchors.fill: parent
        contextType: "2d"

        function drawPointedDiamond(ctx, x, y, size, fill) {
            ctx.save();
            ctx.fillStyle = fill;
            ctx.beginPath();
            ctx.moveTo(x, y - size * 1.25);
            ctx.lineTo(x + size * 0.85, y);
            ctx.lineTo(x, y + size * 1.25);
            ctx.lineTo(x - size * 0.85, y);
            ctx.closePath();
            ctx.fill();
            ctx.restore();
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var w = width;
            var h = height;
            if (w <= 0 || h <= 0) return;

            var cx = w / 2;
            var cy = h / 2;
            var diameter = Math.min(w, h);
            var geom = clockGeom.get(diameter);

            var rCardinal = geom.rCardinal;
            var rOrnament = geom.rOrnament;
            var rTickInner = geom.rTickInner;
            var rQuiet = geom.rQuiet;
            var diamondSize = geom.cardinalSize;

            // Angular bounds of minute capsule region near 3:00 (angle 0)
            var capAngleTop = -0.32;
            var capAngleBottom = 0.16;

            // ── 1. FOUR POINTED CARDINAL DIAMONDS (all visible, clear of capsule) ──
            // North (12:00)
            drawPointedDiamond(ctx, cx, cy - rCardinal, diamondSize, root.accentGold);
            // South (6:00)
            drawPointedDiamond(ctx, cx, cy + rCardinal, diamondSize, root.accentGold);
            // West (9:00)
            drawPointedDiamond(ctx, cx - rCardinal, cy, diamondSize, root.accentGold);
            // East (3:00) - sits at 0.95R, safely outside capsule right edge (0.86R)
            drawPointedDiamond(ctx, cx + rCardinal, cy, diamondSize, root.accentGold);

            // ── 2. BROKEN CIRCUMFERENCE AT rOrnament & TICKS AT >= rTickInner ──
            var majorTickLen = rOrnament - rTickInner;
            var minorTickLen = majorTickLen * 0.50;
            var arcGapRad = 3.5 * Math.PI / 180.0; // 3.5 degree gap around major hour marks

            for (var k = 0; k < 12; k++) {
                var angle = -Math.PI / 2 + (k * Math.PI / 6);
                var isNearCapsule = (k === 3) || (angle >= capAngleTop && angle <= capAngleBottom);

                // Major tick at hour mark (omit at 3:00 to keep capsule clean)
                if (!isNearCapsule) {
                    var cosA = Math.cos(angle);
                    var sinA = Math.sin(angle);
                    ctx.save();
                    ctx.strokeStyle = root.accentGold;
                    ctx.lineWidth = Math.max(1.0, diameter * 0.005);
                    ctx.beginPath();
                    ctx.moveTo(cx + cosA * rTickInner, cy + sinA * rTickInner);
                    ctx.lineTo(cx + cosA * rOrnament, cy + sinA * rOrnament);
                    ctx.stroke();
                    ctx.restore();
                }

                // Broken outer arc between hour marks
                var arcStart = angle + arcGapRad;
                var arcEnd = angle + (Math.PI / 6) - arcGapRad;
                if (!(arcStart < capAngleBottom && arcEnd > capAngleTop)) {
                    ctx.save();
                    ctx.strokeStyle = ColorUtils.applyAlpha(root.accentGold, 0.75 * root.intensity);
                    ctx.lineWidth = 1.0;
                    ctx.beginPath();
                    ctx.arc(cx, cy, rOrnament, arcStart, arcEnd, false);
                    ctx.stroke();
                    ctx.restore();
                }

                // 4 Fine ticklets between each pair of major divisions (6 degree intervals)
                for (var m = 1; m < 5; m++) {
                    var subAngle = angle + (m * Math.PI / 30);
                    if (subAngle >= capAngleTop && subAngle <= capAngleBottom) continue;

                    var cosS = Math.cos(subAngle);
                    var sinS = Math.sin(subAngle);
                    ctx.save();
                    ctx.strokeStyle = ColorUtils.applyAlpha(root.accentGold, 0.78 * root.intensity);
                    ctx.lineWidth = 1.0;
                    ctx.beginPath();
                    ctx.moveTo(cx + cosS * (rOrnament - minorTickLen), cy + sinS * (rOrnament - minorTickLen));
                    ctx.lineTo(cx + cosS * rOrnament, cy + sinS * rOrnament);
                    ctx.stroke();
                    ctx.restore();
                }
            }

            // ── 3. INNER QUIET RING (rQuiet ~0.60R, broken where crossing capsule) ──
            ctx.save();
            ctx.strokeStyle = ColorUtils.applyAlpha(root.borderSubtle, 0.45 * root.intensity);
            ctx.lineWidth = 1.0;
            ctx.beginPath();
            // Arc going around from below capsule to above capsule
            ctx.arc(cx, cy, rQuiet, capAngleBottom + 0.05, (2 * Math.PI) + capAngleTop - 0.05, false);
            ctx.stroke();
            ctx.restore();

            // ── 4. SOFT FRAMING BRACKET (Upper) ──
            ctx.save();
            ctx.strokeStyle = ColorUtils.applyAlpha(root.accentGold, 0.28 * root.intensity);
            ctx.lineWidth = 1.0;

            // Upper bracket (arches over the hour, split to frame the AM/PM label cleanly)
            // Left wing: from cx - 0.22D to cx - 0.08D
            ctx.beginPath();
            ctx.moveTo(cx - diameter * 0.22, cy - diameter * 0.18);
            ctx.quadraticCurveTo(cx - diameter * 0.15, cy - diameter * 0.235, cx - diameter * 0.08, cy - diameter * 0.23);
            ctx.stroke();

            // Right wing: from cx + 0.08D to cx + 0.22D
            ctx.beginPath();
            ctx.moveTo(cx + diameter * 0.08, cy - diameter * 0.23);
            ctx.quadraticCurveTo(cx + diameter * 0.15, cy - diameter * 0.235, cx + diameter * 0.22, cy - diameter * 0.18);
            ctx.stroke();
            ctx.restore();

            // ── 5. STATIC ECG SIGNATURE (at cy + 0.175D) ──
            var sigY = geom.yEcg;
            var sigW = diameter * 0.24;
            var halfW = sigW / 2;

            ctx.save();
            ctx.strokeStyle = ColorUtils.applyAlpha(root.accentGold, 0.75 * root.intensity);
            ctx.lineWidth = 1.2;
            ctx.beginPath();
            ctx.moveTo(cx - halfW, sigY);
            ctx.lineTo(cx - sigW * 0.20, sigY);
            // P wave
            ctx.lineTo(cx - sigW * 0.14, sigY - 2.0);
            ctx.lineTo(cx - sigW * 0.08, sigY);
            // Q dip
            ctx.lineTo(cx - sigW * 0.04, sigY + 2.8);
            // R peak
            ctx.lineTo(cx, sigY - 7.5);
            // S dip
            ctx.lineTo(cx + sigW * 0.04, sigY + 4.5);
            // T wave
            ctx.lineTo(cx + sigW * 0.09, sigY - 3.0);
            ctx.lineTo(cx + sigW * 0.15, sigY);
            // End baseline
            ctx.lineTo(cx + halfW, sigY);
            ctx.stroke();
            ctx.restore();

            // Tiny central node in focal signature
            drawPointedDiamond(ctx, cx, sigY, Math.max(1.8, diameter * 0.009), root.accentGold);
        }
    }

    scale: ringPulseScale
    property real ringPulseScale: 1.0
    readonly property bool pulseAllowed: root.live && root.visible && ResonanceTheme.motionNormal && !Appearance.reducedMotion

    onPulseAllowedChanged: {
        if (!pulseAllowed && hourPulseAnim.running) {
            hourPulseAnim.stop();
            root.ringPulseScale = 1.0;
        }
    }

    SequentialAnimation {
        id: hourPulseAnim
        onStopped: {
            root.ringPulseScale = 1.0;
        }
        PropertyAnimation {
            target: root
            property: "ringPulseScale"
            from: 1.0
            to: 1.012
            duration: 800
            easing.type: Easing.OutCubic
        }
        PropertyAnimation {
            target: root
            property: "ringPulseScale"
            from: 1.012
            to: 1.0
            duration: 1200
            easing.type: Easing.InOutQuad
        }
    }

    Connections {
        target: DateTime.clock
        function onHoursChanged() {
            if (root.pulseAllowed) {
                hourPulseAnim.restart();
            }
        }
    }

    onWidthChanged: ringCanvas.requestPaint()
    onHeightChanged: ringCanvas.requestPaint()
    onMinutePillVisibleChanged: ringCanvas.requestPaint()
    onLiveChanged: {
        if (live && visible) ringCanvas.requestPaint();
    }
    onVisibleChanged: {
        if (live && visible) ringCanvas.requestPaint();
    }

    Connections {
        enabled: root.live && root.visible
        target: ResonanceTheme
        function onAccentGoldChanged() { ringCanvas.requestPaint(); }
        function onBorderSubtleChanged() { ringCanvas.requestPaint(); }
        function onBorderHairlineChanged() { ringCanvas.requestPaint(); }
        function onTextPrimaryChanged() { ringCanvas.requestPaint(); }
        function onTextSecondaryChanged() { ringCanvas.requestPaint(); }
        function onIntensityChanged() { ringCanvas.requestPaint(); }
        function onPaletteModeChanged() { ringCanvas.requestPaint(); }
    }
}
