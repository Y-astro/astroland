pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.common
import qs.modules.common.functions

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

    anchors.fill: parent
    enabled: false

    Canvas {
        id: ringCanvas
        anchors.fill: parent
        contextType: "2d"

        function drawDiamond(ctx, x, y, size, fill) {
            ctx.save();
            ctx.fillStyle = fill;
            ctx.beginPath();
            ctx.moveTo(x, y - size);
            ctx.lineTo(x + size, y);
            ctx.lineTo(x, y + size);
            ctx.lineTo(x - size, y);
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

            // ── 1. OUTER ETCHED RING & BROKEN ORBIT ──
            var rOuter = diameter * 0.475;
            var majorTickLen = diameter * 0.038;
            var minorTickLen = diameter * 0.018;
            var arcGapRad = 4.0 * Math.PI / 180.0; // 4 degree gap around major ticks

            // 12 Major Divisions + Broken Arcs + Fine Ticklets
            for (var k = 0; k < 12; k++) {
                var angle = -Math.PI / 2 + (k * Math.PI / 6);

                // Major Tick at hour mark
                var cosA = Math.cos(angle);
                var sinA = Math.sin(angle);
                ctx.save();
                ctx.strokeStyle = root.accentGold;
                ctx.lineWidth = Math.max(1.0, diameter * 0.006);
                ctx.beginPath();
                ctx.moveTo(cx + cosA * (rOuter - majorTickLen), cy + sinA * (rOuter - majorTickLen));
                ctx.lineTo(cx + cosA * (rOuter + diameter * 0.004), cy + sinA * (rOuter + diameter * 0.004));
                ctx.stroke();
                ctx.restore();

                // Broken outer arc between hour marks
                var arcStart = angle + arcGapRad;
                var arcEnd = angle + (Math.PI / 6) - arcGapRad;
                ctx.save();
                ctx.strokeStyle = root.borderHairline;
                ctx.lineWidth = 1.0;
                ctx.beginPath();
                ctx.arc(cx, cy, rOuter, arcStart, arcEnd, false);
                ctx.stroke();
                ctx.restore();

                // 4 Fine ticklets between each pair of major divisions (6 degree intervals)
                for (var m = 1; m < 5; m++) {
                    var subAngle = angle + (m * Math.PI / 30);
                    var cosS = Math.cos(subAngle);
                    var sinS = Math.sin(subAngle);
                    ctx.save();
                    ctx.strokeStyle = ColorUtils.applyAlpha(root.accentGold, 0.40 * root.intensity);
                    ctx.lineWidth = 1.0;
                    ctx.beginPath();
                    ctx.moveTo(cx + cosS * (rOuter - minorTickLen), cy + sinS * (rOuter - minorTickLen));
                    ctx.lineTo(cx + cosS * rOuter, cy + sinS * rOuter);
                    ctx.stroke();
                    ctx.restore();
                }
            }

            // ── 2. FOUR NAVIGATION DIAMONDS ──
            var diamondR = rOuter - diameter * 0.055;
            var diamondSize = Math.max(2.5, diameter * 0.012);

            // North (12:00)
            drawDiamond(ctx, cx, cy - diamondR, diamondSize, root.accentGold);
            // South (6:00)
            drawDiamond(ctx, cx, cy + diamondR, diamondSize, root.accentGold);
            // West (9:00)
            drawDiamond(ctx, cx - diamondR, cy, diamondSize, root.accentGold);
            // East (3:00) - only if minute pill is not masking this area
            if (!root.minutePillVisible) {
                drawDiamond(ctx, cx + diamondR, cy, diamondSize, root.accentGold);
            }

            // ── 3. INNER CONCENTRIC ACCENT ORBIT ──
            var rInner = diameter * 0.385;
            for (var q = 0; q < 4; q++) {
                var qAngle = -Math.PI / 2 + (q * Math.PI / 2);
                var qStart = qAngle + (12.0 * Math.PI / 180.0);
                var qEnd = qAngle + (Math.PI / 2) - (12.0 * Math.PI / 180.0);
                ctx.save();
                ctx.strokeStyle = ColorUtils.applyAlpha(root.borderSubtle, 0.35 * root.intensity);
                ctx.lineWidth = 0.8;
                ctx.beginPath();
                ctx.arc(cx, cy, rInner, qStart, qEnd, false);
                ctx.stroke();
                ctx.restore();
            }

            // ── 4. FOCAL SIGNATURE (TACET / FREQUENCY MOTIF) ──
            var sigY = cy + diameter * 0.165;
            var sigW = diameter * 0.22;
            var halfW = sigW / 2;

            ctx.save();
            ctx.strokeStyle = ColorUtils.applyAlpha(root.accentGold, 0.70 * root.intensity);
            ctx.lineWidth = 1.0;
            ctx.beginPath();
            ctx.moveTo(cx - halfW, sigY);
            ctx.lineTo(cx - sigW * 0.16, sigY);
            ctx.lineTo(cx - sigW * 0.08, sigY - 2.5);
            ctx.lineTo(cx, sigY + 2.5);
            ctx.lineTo(cx + sigW * 0.08, sigY - 2.5);
            ctx.lineTo(cx + sigW * 0.16, sigY);
            ctx.lineTo(cx + halfW, sigY);
            ctx.stroke();
            ctx.restore();

            // Tiny central node in focal signature
            drawDiamond(ctx, cx, sigY, Math.max(1.8, diameter * 0.009), root.accentGold);

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
