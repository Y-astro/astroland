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

    readonly property real cpuTemp: Number.isFinite(ResourceUsage.cpuTemp)
        ? ResourceUsage.cpuTemp
        : 0.0

    readonly property real gpuTemp: Number.isFinite(ResourceUsage.gpuTemp)
        ? ResourceUsage.gpuTemp
        : 0.0

    // Unavailable / <= 0 temperatures format strictly as "--"
    readonly property string cpuTempStr: cpuTemp > 0 ? (Math.round(cpuTemp) + "°C") : "--"
    readonly property string gpuTempStr: gpuTemp > 0 ? (Math.round(gpuTemp) + "°C") : "--"

    // Deliberate thermal threshold: warn only above 75°C
    readonly property bool cpuHot: cpuTemp > 75
    readonly property bool gpuHot: gpuTemp > 75

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

        // Jinzhou Terminal Corner Ornament: top-left corner bracket
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            width: 8
            height: 1
            color: ResonanceTheme.borderAccent
        }
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            width: 1
            height: 8
            color: ResonanceTheme.borderAccent
        }


        // Card Content Layout
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 2

            // =================================================================
            // CPU CARD
            // =================================================================
            Item {
                visible: rootCard.cardType === "cpu"
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 1

                    RowLayout {
                        Layout.fillWidth: true
                        StyledText {
                            text: "CPU // 01"
                            font.pixelSize: ResonanceTheme.fontMicroBadge
                            font.letterSpacing: 0.5
                            color: ResonanceTheme.textSecondary
                            opacity: 0.85
                        }
                        Item { Layout.fillWidth: true }
                    }

                    StyledText {
                        text: Math.round(rootCard.cpuVal * 100) + "%"
                        font.pixelSize: ResonanceTheme.fontMetricValue
                        font.weight: Font.Bold
                        color: ResonanceTheme.textPrimary
                    }

                    StyledText {
                        text: ResourceUsage.cpuFreqMhz > 0
                            ? (ResourceUsage.cpuFreqMhz / 1000).toFixed(1) + " GHz"
                            : "LOAD HISTORY"
                        font.pixelSize: ResonanceTheme.fontMicroBadge
                        color: ResonanceTheme.textSecondary
                        opacity: 0.65
                    }

                    Canvas {
                        id: cpuCanvas
                        Layout.fillWidth: true
                        Layout.preferredHeight: 18
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

                            // Sinuous / spire frequency curve from cpuUsageHistory
                            var history = ResourceUsage.cpuUsageHistory || [];
                            var count = Math.min(history.length, 12);
                            if (count > 1) {
                                ctx.beginPath();
                                ctx.strokeStyle = ResonanceTheme.accentGold;
                                ctx.lineWidth = 1.2;
                                var step = width / (count - 1);
                                for (var i = 0; i < count; i++) {
                                    var v = history[history.length - count + i];
                                    var val = Number.isFinite(v) ? Math.max(0, Math.min(1, v)) : 0;
                                    var x = i * step;
                                    var y = (height - 2) - val * (height - 4);
                                    if (i === 0) ctx.moveTo(x, y);
                                    else ctx.lineTo(x, y);
                                }
                                ctx.stroke();
                            } else {
                                ctx.beginPath();
                                ctx.strokeStyle = ResonanceTheme.accentGold;
                                ctx.lineWidth = 1.2;
                                var yMid = (height - 2) - rootCard.cpuVal * (height - 4);
                                ctx.moveTo(0, height - 1);
                                ctx.lineTo(width * 0.4, height - 1);
                                ctx.lineTo(width * 0.5, yMid);
                                ctx.lineTo(width * 0.6, height - 1);
                                ctx.lineTo(width, height - 1);
                                ctx.stroke();
                            }
                        }

                        Connections {
                            target: ResourceUsage
                            function onCpuUsageChanged() {
                                if (rootCard.cardType === "cpu" && rootCard.live && rootCard.visible)
                                    cpuCanvas.requestPaint();
                            }
                            function onCpuUsageHistoryChanged() {
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

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        StyledText {
                            text: "RAM // 02"
                            font.pixelSize: ResonanceTheme.fontMicroBadge
                            font.letterSpacing: 0.5
                            color: ResonanceTheme.textSecondary
                            opacity: 0.85
                        }
                        Item { Layout.fillWidth: true }
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

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 8
                        Layout.topMargin: 4
                        spacing: 2

                        Repeater {
                            model: 10
                            delegate: Rectangle {
                                required property int index
                                Layout.fillWidth: true
                                Layout.preferredHeight: 5
                                radius: 1
                                readonly property real threshold: (index + 0.5) / 10
                                readonly property bool filled: rootCard.ramVal >= threshold
                                color: filled ? ResonanceTheme.accentGold : ResonanceTheme.alpha(ResonanceTheme.colMistySage, 0.18)
                                border.color: filled ? ResonanceTheme.borderAccent : "transparent"
                                border.width: filled ? 1 : 0
                            }
                        }
                    }
                }
            }

            // =================================================================
            // THERMAL CARD (Combined CPU & GPU)
            // =================================================================
            Item {
                visible: rootCard.cardType === "temp"
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        StyledText {
                            text: "THERMAL // 03"
                            font.pixelSize: ResonanceTheme.fontMicroBadge
                            font.letterSpacing: 0.5
                            color: ResonanceTheme.textSecondary
                            opacity: 0.85
                        }
                        Item { Layout.fillWidth: true }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 6

                        // CPU Temp Column
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 1

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: rootCard.cpuTempStr
                                font.pixelSize: Math.min(ResonanceTheme.fontMetricSubValue, (rootCard.width - 34) / 6)
                                font.weight: Font.Bold
                                color: rootCard.cpuHot ? ResonanceTheme.textWarning : ResonanceTheme.textPrimary
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: "CPU"
                                font.pixelSize: ResonanceTheme.fontTechnicalLabel
                                color: ResonanceTheme.textSecondary
                                opacity: 0.7
                            }
                        }

                        // Fine central hairline divider
                        Rectangle {
                            Layout.preferredHeight: 28
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: 1
                            color: ResonanceTheme.borderHairline
                        }

                        // GPU Temp Column
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 1

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: rootCard.gpuTempStr
                                font.pixelSize: Math.min(ResonanceTheme.fontMetricSubValue, (rootCard.width - 34) / 6)
                                font.weight: Font.Bold
                                color: rootCard.gpuHot ? ResonanceTheme.textWarning : ResonanceTheme.textPrimary
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: "GPU"
                                font.pixelSize: ResonanceTheme.fontTechnicalLabel
                                color: ResonanceTheme.textSecondary
                                opacity: 0.7
                            }
                        }
                    }
                }
            }
        }
    }
}
