pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

Item {
    id: rootCard

    required property string cardType // "cpu" | "ram" | "temp"
    property var wallpaperItem: null
    property bool live: true
    property real trackX: 0
    property real trackY: 0

    implicitWidth: 132
    implicitHeight: 120

    // Bounded & normalized telemetry inputs
    readonly property real cpuVal: Number.isFinite(ResourceUsage.cpuUsage)
        ? Math.max(0.0, Math.min(1.0, ResourceUsage.cpuUsage))
        : 0.0

    readonly property real ramVal: Number.isFinite(ResourceUsage.memoryUsedPercentage)
        ? Math.max(0.0, Math.min(1.0, ResourceUsage.memoryUsedPercentage))
        : 0.0

    property var overrideCpuTemp: undefined
    property var overrideGpuTemp: undefined

    readonly property real cpuTemp: overrideCpuTemp !== undefined
        ? (Number.isFinite(overrideCpuTemp) ? Number(overrideCpuTemp) : 0.0)
        : (Number.isFinite(ResourceUsage.cpuTemp) ? ResourceUsage.cpuTemp : 0.0)

    readonly property real gpuTemp: overrideGpuTemp !== undefined
        ? (Number.isFinite(overrideGpuTemp) ? Number(overrideGpuTemp) : 0.0)
        : (Number.isFinite(ResourceUsage.gpuTemp) ? ResourceUsage.gpuTemp : 0.0)

    // Unavailable / <= 0 temperatures format strictly as "--"
    readonly property string cpuTempStr: cpuTemp > 0 ? (Math.round(cpuTemp) + "°C") : "--"
    readonly property string gpuTempStr: gpuTemp > 0 ? (Math.round(gpuTemp) + "°C") : "--"

    // Deliberate thermal threshold: warn only above 75°C
    readonly property bool cpuHot: cpuTemp > 75
    readonly property bool gpuHot: gpuTemp > 75

    // Balanced thermal value font size shared by both CPU and GPU to ensure matching baselines
    readonly property int thermalValueFontSize: Math.min(ResonanceTheme.fontMetricSubValue, Math.max(12, Math.round((rootCard.width - 24) / 6.2)))

    // Glass backdrop & hairline framing
    Rectangle {
        id: bgRect
        anchors.fill: parent
        radius: 10
        color: ResonanceTheme.bgGlass
        border.color: ResonanceTheme.borderHairline
        border.width: 1
        clip: true

        // Fast wallpaper blur when enabled in shell settings
        FastBlurred {
            anchors.fill: parent
            blurSource: rootCard.wallpaperItem
            cardRadius: bgRect.radius
            tint: ResonanceTheme.colTealInk
            tintOpacity: 0.25 * ResonanceTheme.intensity
            trackX: rootCard.trackX
            trackY: rootCard.trackY
            visible: (Config.options.background?.widgets?.blurWidgets ?? false) && rootCard.wallpaperItem !== null
        }

        // Cached Jinzhou Terminal Frame Ornaments & Header Icon Canvas
        Canvas {
            id: frameCanvas
            anchors.fill: parent
            renderTarget: Canvas.Image
            renderStrategy: Canvas.Cooperative

            readonly property bool isWarning: (rootCard.cpuHot || rootCard.gpuHot)

            onIsWarningChanged: requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            Component.onCompleted: requestPaint()

            Connections {
                target: ResonanceTheme
                function onBorderAccentChanged() { frameCanvas.requestPaint(); }
                function onAccentGoldChanged() { frameCanvas.requestPaint(); }
                function onTextWarningChanged() { frameCanvas.requestPaint(); }
            }

            Connections {
                target: rootCard
                function onLiveChanged() {
                    if (rootCard.live) frameCanvas.requestPaint();
                }
            }

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                var w = width;
                var h = height;

                // ── 1. CORNER BRACKETS & CARDINAL DIAMOND (w >= 100 && h >= 80) ──
                if (w >= 100 && h >= 80) {
                    var colBorderAccent = ResonanceTheme.borderAccent;
                    var colAccentGold = ResonanceTheme.accentGold;

                    // Top-left bracket: 8x1 horizontal, 1x8 vertical, 2x2 gold corner
                    ctx.fillStyle = colBorderAccent;
                    ctx.fillRect(0, 0, 8, 1);
                    ctx.fillRect(0, 0, 1, 8);
                    ctx.fillStyle = colAccentGold;
                    ctx.fillRect(0, 0, 2, 2);

                    // Top-right bracket: 8x1 horizontal, 1x8 vertical, 2x2 gold corner
                    ctx.fillStyle = colBorderAccent;
                    ctx.fillRect(w - 8, 0, 8, 1);
                    ctx.fillRect(w - 1, 0, 1, 8);
                    ctx.fillStyle = colAccentGold;
                    ctx.fillRect(w - 2, 0, 2, 2);

                    // Bottom-left bracket: 8x1 horizontal, 1x8 vertical
                    ctx.fillStyle = colBorderAccent;
                    ctx.fillRect(0, h - 1, 8, 1);
                    ctx.fillRect(0, h - 8, 1, 8);

                    // Bottom-right bracket: 8x1 horizontal, 1x8 vertical
                    ctx.fillStyle = colBorderAccent;
                    ctx.fillRect(w - 8, h - 1, 8, 1);
                    ctx.fillRect(w - 1, h - 8, 1, 8);

                    // Subtle top cardinal diamond: 3x3 rotated 45°, topMargin 2, opacity 0.7
                    ctx.save();
                    ctx.fillStyle = ResonanceTheme.alpha(colBorderAccent, 0.7);
                    ctx.translate(w / 2, 3.5);
                    ctx.rotate(Math.PI / 4);
                    ctx.fillRect(-1.5, -1.5, 3, 3);
                    ctx.restore();
                }

                // ── 2. HEADER ICON (w >= 115) ──
                var marker = null;
                if (rootCard.cardType === "cpu") marker = cpuIconMarker;
                else if (rootCard.cardType === "ram") marker = ramIconMarker;
                else marker = thermalIconMarker;

                if (marker && marker.visible && w >= 115) {
                    var pt = marker.mapToItem(frameCanvas, 0, 0);
                    var mx = (pt && isFinite(pt.x)) ? pt.x : (w - 23);
                    var my = (pt && isFinite(pt.y)) ? pt.y : 9;

                    function drawRoundRect(c, rx, ry, rw, rh, r) {
                        c.beginPath();
                        c.moveTo(rx + r, ry);
                        c.lineTo(rx + rw - r, ry);
                        c.arcTo(rx + rw, ry, rx + rw, ry + r, r);
                        c.lineTo(rx + rw, ry + rh - r);
                        c.arcTo(rx + rw, ry + rh, rx + rw - r, ry + rh, r);
                        c.lineTo(rx + r, ry + rh);
                        c.arcTo(rx, ry + rh, rx, ry + rh - r, r);
                        c.lineTo(rx, ry + r);
                        c.arcTo(rx, ry, rx + r, ry, r);
                        c.closePath();
                    }

                    if (rootCard.cardType === "cpu") {
                        // CPU Micro-chip icon
                        ctx.save();
                        ctx.strokeStyle = ResonanceTheme.alpha(ResonanceTheme.accentGold, 0.85);
                        ctx.lineWidth = 1;
                        drawRoundRect(ctx, mx + 2.5, my + 2.5, 9, 9, 2);
                        ctx.stroke();

                        ctx.fillStyle = ResonanceTheme.alpha(ResonanceTheme.accentGold, 0.85);
                        ctx.fillRect(mx + 5.5, my + 5.5, 3, 3);

                        ctx.fillStyle = ResonanceTheme.alpha(ResonanceTheme.accentGold, 0.6);
                        ctx.fillRect(mx + 5, my, 4, 1);
                        ctx.fillRect(mx + 5, my + 13, 4, 1);
                        ctx.fillRect(mx, my + 5, 1, 4);
                        ctx.fillRect(mx + 13, my + 5, 1, 4);
                        ctx.restore();
                    } else if (rootCard.cardType === "ram") {
                        // RAM stick icon
                        ctx.save();
                        ctx.strokeStyle = ResonanceTheme.alpha(ResonanceTheme.accentGold, 0.85);
                        ctx.lineWidth = 1;
                        drawRoundRect(ctx, mx + 1, my + 3, 12, 8, 1);
                        ctx.stroke();

                        ctx.fillStyle = ResonanceTheme.alpha(ResonanceTheme.accentGold, 0.7);
                        ctx.fillRect(mx + 3, my + 5, 3, 4);
                        ctx.fillRect(mx + 8, my + 5, 3, 4);

                        ctx.fillStyle = ResonanceTheme.alpha(ResonanceTheme.accentGold, 0.6);
                        ctx.fillRect(mx + 3, my + 12, 8, 1);
                        ctx.restore();
                    } else {
                        // Thermometer icon
                        var iconCol = (rootCard.cpuHot || rootCard.gpuHot) ? ResonanceTheme.textWarning : ResonanceTheme.accentGold;
                        ctx.save();
                        ctx.strokeStyle = ResonanceTheme.alpha(iconCol, 0.85);
                        ctx.lineWidth = 1;
                        drawRoundRect(ctx, mx + 5, my + 1, 4, 8, 2);
                        ctx.stroke();

                        ctx.fillStyle = ResonanceTheme.alpha(iconCol, 0.85);
                        ctx.beginPath();
                        ctx.arc(mx + 7, my + 9.5, 3.5, 0, 2 * Math.PI);
                        ctx.fill();
                        ctx.restore();
                    }
                }
            }
        }

        // Card Content Layout
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 9
            spacing: 2
            Layout.minimumWidth: 0

            // =================================================================
            // CPU CARD
            // =================================================================
            Item {
                visible: rootCard.cardType === "cpu"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 0
                Layout.preferredWidth: visible ? -1 : 0
                Layout.preferredHeight: visible ? -1 : 0
                implicitWidth: 0

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 1
                    Layout.minimumWidth: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 2

                        StyledText {
                            text: "CPU"
                            font.pixelSize: ResonanceTheme.fontMicroBadge
                            font.letterSpacing: 0.5
                            color: ResonanceTheme.textSecondary
                            opacity: 0.85
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            elide: Text.ElideRight
                        }
                        // Micro-chip icon marker (responsive: hides when width < 115)
                        Item {
                            id: cpuIconMarker
                            visible: rootCard.width >= 115
                            Layout.preferredWidth: visible ? 14 : 0
                            Layout.preferredHeight: 14
                            Layout.minimumWidth: 0
                            width: 14
                            height: 14
                            onXChanged: frameCanvas.requestPaint()
                            onYChanged: frameCanvas.requestPaint()
                            onVisibleChanged: frameCanvas.requestPaint()
                        }
                    }

                    StyledText {
                        text: Math.round(rootCard.cpuVal * 100) + "%"
                        font.pixelSize: ResonanceTheme.fontMetricValue
                        font.weight: Font.Bold
                        color: ResonanceTheme.textPrimary
                    }

                    StyledText {
                        text: (Number.isFinite(ResourceUsage.cpuFreqMhz) && ResourceUsage.cpuFreqMhz > 0)
                            ? (ResourceUsage.cpuFreqMhz >= 1000
                                ? (ResourceUsage.cpuFreqMhz / 1000).toFixed(1) + " GHz"
                                : Math.round(ResourceUsage.cpuFreqMhz) + " MHz")
                            : "—"
                        font.pixelSize: ResonanceTheme.fontMicroBadge
                        color: ResonanceTheme.textSecondary
                        opacity: 0.75
                    }

                    Canvas {
                        id: cpuCanvas
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        Layout.topMargin: 2

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);

                            // Subtle baseline
                            ctx.beginPath();
                            ctx.strokeStyle = ResonanceTheme.borderSubtle;
                            ctx.lineWidth = 1;
                            ctx.moveTo(0, height - 1);
                            ctx.lineTo(width, height - 1);
                            ctx.stroke();

                            // Real sampled CPU clock speed trace (~30-60 rolling samples)
                            var rawHistory = ResourceUsage.cpuFreqHistory || [];
                            var maxSamples = 60;
                            var history = rawHistory.slice(-maxSamples);
                            var count = history.length;

                            if (count === 0)
                                return;

                            var topPad = 2;
                            var botPad = 3;
                            var usableH = Math.max(1, height - topPad - botPad);

                            // Filter valid positive frequencies to determine sane rolling min/max
                            var validFreqs = [];
                            for (var i = 0; i < count; i++) {
                                var f = history[i];
                                if (Number.isFinite(f) && f > 0)
                                    validFreqs.push(f);
                            }

                            if (validFreqs.length === 0)
                                return;

                            if (validFreqs.length === 1) {
                                // Warmup with a single sample: baseline + node at vertical center
                                var singleY = topPad + usableH * 0.5;
                                ctx.beginPath();
                                ctx.arc(width - 2, singleY, 1.8, 0, 2 * Math.PI);
                                ctx.fillStyle = ResonanceTheme.accentGold;
                                ctx.fill();
                                return;
                            }

                            var minFreq = validFreqs[0];
                            var maxFreq = validFreqs[0];
                            for (var v = 1; v < validFreqs.length; v++) {
                                if (validFreqs[v] < minFreq) minFreq = validFreqs[v];
                                if (validFreqs[v] > maxFreq) maxFreq = validFreqs[v];
                            }

                            var span = maxFreq - minFreq;
                            // Sane rolling range: minimum 500 MHz span prevents microscopic noise
                            // from being deceptively amplified into full-scale peaks
                            var effectiveSpan = Math.max(span, 500);
                            var margin = effectiveSpan * 0.12;
                            var center = (minFreq + maxFreq) * 0.5;
                            var plotMin = Math.max(0, center - effectiveSpan * 0.5 - margin);
                            var plotMax = center + effectiveSpan * 0.5 + margin;
                            var range = Math.max(1, plotMax - plotMin);

                            function freqToY(val) {
                                var norm = Math.max(0.0, Math.min(1.0, (val - plotMin) / range));
                                return (height - botPad) - norm * usableH;
                            }

                            var step = (count > 1) ? (width / (count - 1)) : width;
                            var lastValidY = freqToY(validFreqs[0]);

                            ctx.beginPath();
                            ctx.strokeStyle = ResonanceTheme.accentGold;
                            ctx.lineWidth = 1.2;

                            for (var j = 0; j < count; j++) {
                                var val = history[j];
                                var currentY = (Number.isFinite(val) && val > 0) ? freqToY(val) : lastValidY;
                                lastValidY = currentY;
                                var currentX = j * step;
                                if (j === 0) ctx.moveTo(currentX, currentY);
                                else ctx.lineTo(currentX, currentY);
                            }
                            ctx.stroke();

                            // Warm gold terminal node at the latest valid sample position
                            var lastX = (count - 1) * step;
                            var finalFreq = (Number.isFinite(history[count - 1]) && history[count - 1] > 0)
                                ? history[count - 1]
                                : validFreqs[validFreqs.length - 1];
                            var finalY = freqToY(finalFreq);
                            ctx.beginPath();
                            ctx.arc(lastX, finalY, 1.8, 0, 2 * Math.PI);
                            ctx.fillStyle = ResonanceTheme.accentGold;
                            ctx.fill();
                        }

                        Connections {
                            target: ResourceUsage
                            function onCpuFreqMhzChanged() {
                                if (rootCard.cardType === "cpu" && rootCard.live && rootCard.visible)
                                    cpuCanvas.requestPaint();
                            }
                            function onCpuFreqHistoryChanged() {
                                if (rootCard.cardType === "cpu" && rootCard.live && rootCard.visible)
                                    cpuCanvas.requestPaint();
                            }
                        }

                        Connections {
                            target: ResonanceTheme
                            function onAccentGoldChanged() {
                                if (rootCard.cardType === "cpu" && rootCard.live && rootCard.visible)
                                    cpuCanvas.requestPaint();
                            }
                            function onBorderSubtleChanged() {
                                if (rootCard.cardType === "cpu" && rootCard.live && rootCard.visible)
                                    cpuCanvas.requestPaint();
                            }
                            function onPaletteModeChanged() {
                                if (rootCard.cardType === "cpu" && rootCard.live && rootCard.visible)
                                    cpuCanvas.requestPaint();
                            }
                            function onIntensityChanged() {
                                if (rootCard.cardType === "cpu" && rootCard.live && rootCard.visible)
                                    cpuCanvas.requestPaint();
                            }
                        }

                        Connections {
                            target: rootCard
                            function onLiveChanged() {
                                if (rootCard.cardType === "cpu" && rootCard.live && rootCard.visible)
                                    cpuCanvas.requestPaint();
                            }
                            function onVisibleChanged() {
                                if (rootCard.cardType === "cpu" && rootCard.live && rootCard.visible)
                                    cpuCanvas.requestPaint();
                            }
                        }
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                    }
                }
            }

            // =================================================================
            // RAM CARD
            // =================================================================
            Item {
                visible: rootCard.cardType === "ram"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 0
                Layout.preferredWidth: visible ? -1 : 0
                Layout.preferredHeight: visible ? -1 : 0
                implicitWidth: 0

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 2
                    Layout.minimumWidth: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 2

                        StyledText {
                            text: "RAM"
                            font.pixelSize: ResonanceTheme.fontMicroBadge
                            font.letterSpacing: 0.5
                            color: ResonanceTheme.textSecondary
                            opacity: 0.85
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            elide: Text.ElideRight
                        }
                        // RAM stick icon marker (responsive: hides when width < 115)
                        Item {
                            id: ramIconMarker
                            visible: rootCard.width >= 115
                            Layout.preferredWidth: visible ? 14 : 0
                            Layout.preferredHeight: 14
                            Layout.minimumWidth: 0
                            width: 14
                            height: 14
                            onXChanged: frameCanvas.requestPaint()
                            onYChanged: frameCanvas.requestPaint()
                            onVisibleChanged: frameCanvas.requestPaint()
                        }
                    }

                    StyledText {
                        text: Math.round(rootCard.ramVal * 100) + "%"
                        font.pixelSize: ResonanceTheme.fontMetricValue
                        font.weight: Font.Bold
                        color: ResonanceTheme.textPrimary
                    }

                    StyledText {
                        text: ResourceUsage.kbToGbString(ResourceUsage.memoryUsed) + " / " + ResourceUsage.kbToGbString(ResourceUsage.memoryTotal)
                        font.pixelSize: ResonanceTheme.fontMicroBadge
                        color: ResonanceTheme.textSecondary
                        opacity: 0.75
                    }

                    Canvas {
                        id: ramCanvas
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        Layout.topMargin: 2

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);

                            var w = width;
                            var h = height;
                            if (w <= 0 || h <= 0) return;

                            var padX = 2;
                            var trackW = w - 2 * padX;
                            var numSegs = 10;
                            var gap = 1;
                            var segW = (trackW - (numSegs - 1) * gap) / numSegs;
                            var ry = 2;
                            var rh = 6;

                            var ramVal = rootCard.ramVal;
                            var filledCount = Math.round(ramVal * numSegs);
                            if (ramVal > 0.001 && filledCount === 0)
                                filledCount = 1;

                            var colGold = ResonanceTheme.accentGold;
                            var colOrange = ResonanceTheme.colThermalOrange;
                            var colSage = ResonanceTheme.colMistySage;
                            var colBorderAccent = ResonanceTheme.borderAccent;
                            var colBorderSubtle = ResonanceTheme.borderSubtle;
                            var intensity = ResonanceTheme.intensity;

                            // 1. Terminal End Brackets [ and ]
                            ctx.strokeStyle = ResonanceTheme.alpha(colGold, 0.70 * intensity);
                            ctx.lineWidth = 1;

                            // Left bracket
                            ctx.beginPath();
                            ctx.moveTo(padX, ry);
                            ctx.lineTo(0.5, ry);
                            ctx.lineTo(0.5, ry + rh);
                            ctx.lineTo(padX, ry + rh);
                            ctx.stroke();

                            // Right bracket
                            ctx.beginPath();
                            ctx.moveTo(w - padX, ry);
                            ctx.lineTo(w - 0.5, ry);
                            ctx.lineTo(w - 0.5, ry + rh);
                            ctx.lineTo(w - padX, ry + rh);
                            ctx.stroke();

                            // 2. Ten Resonance Memory Segments
                            for (var i = 0; i < numSegs; i++) {
                                var x0 = Math.round(padX + i * (segW + gap));
                                var x1 = Math.round(padX + i * (segW + gap) + segW);
                                var sw = x1 - x0;
                                var isFilled = (i < filledCount);
                                var isWarn = (i >= 8);

                                if (isFilled) {
                                    var fillColor = isWarn ? colOrange : colGold;
                                    var strokeColor = isWarn ? colOrange : colBorderAccent;

                                    ctx.fillStyle = fillColor;
                                    ctx.fillRect(x0, ry, sw, rh);

                                    ctx.strokeStyle = strokeColor;
                                    ctx.lineWidth = 1;
                                    ctx.strokeRect(x0 + 0.5, ry + 0.5, sw - 1, rh - 1);
                                } else {
                                    // Subtle inactive track
                                    ctx.fillStyle = ResonanceTheme.alpha(colSage, 0.12 * intensity);
                                    ctx.fillRect(x0, ry, sw, rh);

                                    ctx.strokeStyle = ResonanceTheme.alpha(colSage, 0.22 * intensity);
                                    ctx.lineWidth = 1;
                                    ctx.strokeRect(x0 + 0.5, ry + 0.5, sw - 1, rh - 1);
                                }
                            }

                            // 3. Calibration Graduation Ticks (0%, 25%, 50%, 75%, 100%)
                            var yTick = 12;
                            var tickPositions = [
                                { x: padX, col: colBorderSubtle },
                                { x: Math.round(padX + trackW * 0.25), col: colBorderSubtle },
                                { x: Math.round(w / 2), col: colBorderAccent },
                                { x: Math.round(padX + trackW * 0.75), col: colBorderSubtle },
                                { x: w - padX - 1, col: colBorderSubtle }
                            ];

                            ctx.lineWidth = 1;
                            for (var t = 0; t < tickPositions.length; t++) {
                                var tp = tickPositions[t];
                                ctx.strokeStyle = tp.col;
                                ctx.beginPath();
                                ctx.moveTo(tp.x + 0.5, yTick);
                                ctx.lineTo(tp.x + 0.5, yTick + 2);
                                ctx.stroke();
                            }

                            // 4. Baseline (matching CPU card baseline at height - 1)
                            ctx.strokeStyle = colBorderSubtle;
                            ctx.lineWidth = 1;
                            ctx.beginPath();
                            ctx.moveTo(0, h - 1);
                            ctx.lineTo(w, h - 1);
                            ctx.stroke();

                            // 5. Center Diamond Node
                            var cx = w / 2;
                            var cy = h - 1;
                            ctx.save();
                            ctx.fillStyle = colGold;
                            ctx.translate(cx, cy);
                            ctx.rotate(Math.PI / 4);
                            ctx.fillRect(-1.5, -1.5, 3, 3);
                            ctx.restore();
                        }

                        Connections {
                            target: rootCard
                            function onRamValChanged() {
                                if (rootCard.cardType === "ram" && rootCard.live && rootCard.visible)
                                    ramCanvas.requestPaint();
                            }
                            function onLiveChanged() {
                                if (rootCard.cardType === "ram" && rootCard.live && rootCard.visible)
                                    ramCanvas.requestPaint();
                            }
                            function onVisibleChanged() {
                                if (rootCard.cardType === "ram" && rootCard.live && rootCard.visible)
                                    ramCanvas.requestPaint();
                            }
                        }

                        Connections {
                            target: ResonanceTheme
                            function onAccentGoldChanged() {
                                if (rootCard.cardType === "ram" && rootCard.live && rootCard.visible)
                                    ramCanvas.requestPaint();
                            }
                            function onColThermalOrangeChanged() {
                                if (rootCard.cardType === "ram" && rootCard.live && rootCard.visible)
                                    ramCanvas.requestPaint();
                            }
                            function onBorderAccentChanged() {
                                if (rootCard.cardType === "ram" && rootCard.live && rootCard.visible)
                                    ramCanvas.requestPaint();
                            }
                            function onBorderSubtleChanged() {
                                if (rootCard.cardType === "ram" && rootCard.live && rootCard.visible)
                                    ramCanvas.requestPaint();
                            }
                            function onIntensityChanged() {
                                if (rootCard.cardType === "ram" && rootCard.live && rootCard.visible)
                                    ramCanvas.requestPaint();
                            }
                            function onPaletteModeChanged() {
                                if (rootCard.cardType === "ram" && rootCard.live && rootCard.visible)
                                    ramCanvas.requestPaint();
                            }
                        }

                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                    }
                }
            }

            // =================================================================
            // THERMAL CARD (Combined CPU & GPU Symmetrical Layout)
            // =================================================================
            Item {
                visible: rootCard.cardType === "temp"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 0
                Layout.preferredWidth: visible ? -1 : 0
                Layout.preferredHeight: visible ? -1 : 0
                implicitWidth: 0

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 2
                    Layout.minimumWidth: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 2

                        StyledText {
                            text: "THERMAL"
                            font.pixelSize: ResonanceTheme.fontMicroBadge
                            font.letterSpacing: 0.5
                            color: ResonanceTheme.textSecondary
                            opacity: 0.85
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            elide: Text.ElideRight
                        }
                        // Thermometer icon marker (responsive: hides when width < 115)
                        Item {
                            id: thermalIconMarker
                            visible: rootCard.width >= 115
                            Layout.preferredWidth: visible ? 14 : 0
                            Layout.preferredHeight: 14
                            Layout.minimumWidth: 0
                            width: 14
                            height: 14
                            onXChanged: frameCanvas.requestPaint()
                            onYChanged: frameCanvas.requestPaint()
                            onVisibleChanged: frameCanvas.requestPaint()
                        }
                    }

                    // Symmetrical 50/50 dual-column array
                    Item {
                        id: thermalColsContainer
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: 0
                        implicitWidth: 0

                        Column {
                            anchors.centerIn: parent
                            width: parent.width
                            spacing: 1

                            // Row 1: Telemetry Values (Baseline & center aligned)
                            Row {
                                width: parent.width
                                height: 20

                                Item {
                                    id: cpuValBox
                                    width: parent.width / 2
                                    height: parent.height

                                    StyledText {
                                        id: cpuValText
                                        anchors.centerIn: parent
                                        text: rootCard.cpuTempStr
                                        font.pixelSize: rootCard.thermalValueFontSize
                                        font.weight: Font.Bold
                                        color: rootCard.cpuHot ? ResonanceTheme.textWarning : ResonanceTheme.textPrimary
                                    }
                                }

                                Item {
                                    id: gpuValBox
                                    width: parent.width / 2
                                    height: parent.height

                                    StyledText {
                                        id: gpuValText
                                        anchors.centerIn: parent
                                        text: rootCard.gpuTempStr
                                        font.pixelSize: rootCard.thermalValueFontSize
                                        font.weight: Font.Bold
                                        color: rootCard.gpuHot ? ResonanceTheme.textWarning : ResonanceTheme.textPrimary
                                    }
                                }
                            }

                            // Row 2: Sensor Labels (Baseline & center aligned)
                            Row {
                                width: parent.width
                                height: 12

                                Item {
                                    id: cpuLabelBox
                                    width: parent.width / 2
                                    height: parent.height

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: "CPU"
                                        font.pixelSize: ResonanceTheme.fontTechnicalLabel
                                        color: ResonanceTheme.textSecondary
                                        opacity: 0.75
                                    }
                                }

                                Item {
                                    id: gpuLabelBox
                                    width: parent.width / 2
                                    height: parent.height

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: "GPU"
                                        font.pixelSize: ResonanceTheme.fontTechnicalLabel
                                        color: ResonanceTheme.textSecondary
                                        opacity: 0.75
                                    }
                                }
                            }

                            // Row 3: Arc Gauges (Identical dimensions, anchor, and vertical axis)
                            Row {
                                width: parent.width
                                height: 22

                                Item {
                                    id: cpuGaugeBox
                                    width: parent.width / 2
                                    height: parent.height

                                    Canvas {
                                        id: cpuGaugeCanvas
                                        anchors.centerIn: parent
                                        width: 36
                                        height: 22
                                        Component.onCompleted: requestPaint()

                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.reset();
                                            ctx.clearRect(0, 0, width, height);
                                            var cx = width / 2;
                                            var cy = height - 3;
                                            var r = 13;

                                            // Background track
                                            ctx.beginPath();
                                            ctx.lineWidth = 2.5;
                                            ctx.strokeStyle = ResonanceTheme.alpha(ResonanceTheme.colMistySage, 0.20 * ResonanceTheme.intensity);
                                            ctx.arc(cx, cy, r, Math.PI, 2.0 * Math.PI, false);
                                            ctx.stroke();

                                            // Active fill arc (honest value-based fill)
                                            if (rootCard.cpuTemp > 0) {
                                                var frac = Math.min(1.0, Math.max(0.0, (rootCard.cpuTemp - 25.0) / 75.0));
                                                if (frac > 0) {
                                                    ctx.beginPath();
                                                    ctx.lineWidth = 2.5;
                                                    ctx.strokeStyle = rootCard.cpuHot ? ResonanceTheme.textWarning : ResonanceTheme.accentGold;
                                                    ctx.arc(cx, cy, r, Math.PI, Math.PI + frac * Math.PI, false);
                                                    ctx.stroke();
                                                }
                                            }

                                            // Center pivot dot
                                            ctx.beginPath();
                                            ctx.arc(cx, cy, 1.5, 0, 2 * Math.PI);
                                            ctx.fillStyle = ResonanceTheme.borderAccent;
                                            ctx.fill();
                                        }

                                        Connections {
                                            target: rootCard
                                            function onCpuTempChanged() { if (rootCard.cardType === "temp" && rootCard.live && rootCard.visible) cpuGaugeCanvas.requestPaint(); }
                                            function onCpuHotChanged() { if (rootCard.cardType === "temp" && rootCard.live && rootCard.visible) cpuGaugeCanvas.requestPaint(); }
                                            function onLiveChanged() { if (rootCard.cardType === "temp" && rootCard.live && rootCard.visible) cpuGaugeCanvas.requestPaint(); }
                                            function onVisibleChanged() { if (rootCard.cardType === "temp" && rootCard.live && rootCard.visible) cpuGaugeCanvas.requestPaint(); }
                                        }

                                        Connections {
                                            target: ResonanceTheme
                                            function onAccentGoldChanged() { if (rootCard.cardType === "temp" && rootCard.live && rootCard.visible) cpuGaugeCanvas.requestPaint(); }
                                            function onBorderAccentChanged() { if (rootCard.cardType === "temp" && rootCard.live && rootCard.visible) cpuGaugeCanvas.requestPaint(); }
                                            function onTextWarningChanged() { if (rootCard.cardType === "temp" && rootCard.live && rootCard.visible) cpuGaugeCanvas.requestPaint(); }
                                            function onIntensityChanged() { if (rootCard.cardType === "temp" && rootCard.live && rootCard.visible) cpuGaugeCanvas.requestPaint(); }
                                        }
                                        onWidthChanged: requestPaint()
                                        onHeightChanged: requestPaint()
                                    }
                                }

                                Item {
                                    id: gpuGaugeBox
                                    width: parent.width / 2
                                    height: parent.height

                                    Canvas {
                                        id: gpuGaugeCanvas
                                        anchors.centerIn: parent
                                        width: 36
                                        height: 22
                                        Component.onCompleted: requestPaint()

                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.reset();
                                            ctx.clearRect(0, 0, width, height);
                                            var cx = width / 2;
                                            var cy = height - 3;
                                            var r = 13;

                                            // Background track
                                            ctx.beginPath();
                                            ctx.lineWidth = 2.5;
                                            ctx.strokeStyle = ResonanceTheme.alpha(ResonanceTheme.colMistySage, 0.20 * ResonanceTheme.intensity);
                                            ctx.arc(cx, cy, r, Math.PI, 2.0 * Math.PI, false);
                                            ctx.stroke();

                                            // Active fill arc (honest value-based fill)
                                            if (rootCard.gpuTemp > 0) {
                                                var frac = Math.min(1.0, Math.max(0.0, (rootCard.gpuTemp - 25.0) / 75.0));
                                                if (frac > 0) {
                                                    ctx.beginPath();
                                                    ctx.lineWidth = 2.5;
                                                    ctx.strokeStyle = rootCard.gpuHot ? ResonanceTheme.textWarning : ResonanceTheme.accentGold;
                                                    ctx.arc(cx, cy, r, Math.PI, Math.PI + frac * Math.PI, false);
                                                    ctx.stroke();
                                                }
                                            }

                                            // Center pivot dot
                                            ctx.beginPath();
                                            ctx.arc(cx, cy, 1.5, 0, 2 * Math.PI);
                                            ctx.fillStyle = ResonanceTheme.borderAccent;
                                            ctx.fill();
                                        }

                                        Connections {
                                            target: rootCard
                                            function onGpuTempChanged() { if (rootCard.cardType === "temp" && rootCard.live && rootCard.visible) gpuGaugeCanvas.requestPaint(); }
                                            function onGpuHotChanged() { if (rootCard.cardType === "temp" && rootCard.live && rootCard.visible) gpuGaugeCanvas.requestPaint(); }
                                            function onLiveChanged() { if (rootCard.cardType === "temp" && rootCard.live && rootCard.visible) gpuGaugeCanvas.requestPaint(); }
                                            function onVisibleChanged() { if (rootCard.cardType === "temp" && rootCard.live && rootCard.visible) gpuGaugeCanvas.requestPaint(); }
                                        }

                                        Connections {
                                            target: ResonanceTheme
                                            function onAccentGoldChanged() { if (rootCard.cardType === "temp" && rootCard.live && rootCard.visible) gpuGaugeCanvas.requestPaint(); }
                                            function onBorderAccentChanged() { if (rootCard.cardType === "temp" && rootCard.live && rootCard.visible) gpuGaugeCanvas.requestPaint(); }
                                            function onTextWarningChanged() { if (rootCard.cardType === "temp" && rootCard.live && rootCard.visible) gpuGaugeCanvas.requestPaint(); }
                                            function onIntensityChanged() { if (rootCard.cardType === "temp" && rootCard.live && rootCard.visible) gpuGaugeCanvas.requestPaint(); }
                                        }
                                        onWidthChanged: requestPaint()
                                        onHeightChanged: requestPaint()
                                    }
                                }
                            }
                        }

                        // Center Hairline Divider & Accent Diamond (overlay centered on exact midline)
                        Item {
                            id: dividerCol
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: 1

                            Rectangle {
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.topMargin: 4
                                anchors.bottomMargin: 4
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 1
                                color: ResonanceTheme.borderHairline

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 4
                                    height: 4
                                    rotation: 45
                                    color: ResonanceTheme.accentGold
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
