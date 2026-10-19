import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import QtQuick.Shapes as Shapes
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.ii.background.widgets
import qs.modules.ii.background.widgets.clock.minuteMarks
import "concentric"

AbstractBackgroundWidget {
    id: root

    configEntryName: "concentric_clock"

    visibleWhenLocked: root.lockBehavior === "keep" || root.lockBehavior === "custom" || root.lockBehavior === "center" || root.lockBehavior === "lockOnly" || (Config.options.lock.centerWidget === "concentric_clock")
    opacity: {
        if (root.lockBehavior === "lockOnly")
            return GlobalStates.screenLocked ? 1 : 0;
        if (GlobalStates.screenLocked && !visibleWhenLocked)
            return 0;
        return 1;
    }

    readonly property real contentScale: (Config.options.background.widgets.concentric_clock.widgetSize ?? 100) / 100.0
    implicitWidth: 240 * contentScale
    implicitHeight: 240 * contentScale

    // Config options with safe fallbacks
    readonly property string cfgSkin: Config.ready ? (Config.options.background.widgets.concentric_clock.skin ?? "classic") : "classic"
    readonly property bool isWuWa: cfgSkin === "wuwa" || cfgSkin === "chrono_resonator"
    readonly property bool smoothMotion: isWuWa
        ? (ResonanceTheme.motionNormal && !Appearance.reducedMotion)
        : !Appearance.reducedMotion

    readonly property string cfgDialStyle: Config.ready ? (Config.options.background.widgets.concentric_clock.dialStyle ?? "concentric") : "concentric"
    readonly property string cfgFrameStyle: Config.ready ? (Config.options.background.widgets.concentric_clock.frameStyle ?? "none") : "none"
    readonly property bool cfgBoldFont: Config.ready ? (Config.options.background.widgets.concentric_clock.boldFont ?? false) : false
    readonly property bool cfgUse24h: Config.ready
        ? (root.isWuWa
            ? (Config.options.background.widgets.concentric_clock.wuwaUse24h ?? false)
            : (Config.options.background.widgets.concentric_clock.use24h ?? true))
        : (root.isWuWa ? false : true)
    readonly property bool cfgShowHourText: Config.ready ? (Config.options.background.widgets.concentric_clock.showHourText ?? true) : true

    readonly property string cfgHourHandStyle: Config.ready ? (Config.options.background.widgets.concentric_clock.hourHandStyle ?? "hide") : "hide"
    readonly property string cfgMinuteHandStyle: Config.ready ? (Config.options.background.widgets.concentric_clock.minuteHandStyle ?? "hide") : "hide"
    readonly property string cfgSecondHandStyle: Config.ready ? (Config.options.background.widgets.concentric_clock.secondHandStyle ?? "hide") : "hide"
    readonly property bool cfgShowHourMarks: Config.ready ? (Config.options.background.widgets.concentric_clock.showHourMarks ?? false) : false

    readonly property string cfgMinuteStyle: Config.ready ? (Config.options.background.widgets.concentric_clock.minuteStyle ?? "pill_horizontal") : "pill_horizontal"
    readonly property bool cfgShowArc24h: Config.ready ? (Config.options.background.widgets.concentric_clock.showArc24h ?? false) : false
    readonly property bool cfgShowHourSubDial: Config.ready ? (Config.options.background.widgets.concentric_clock.showHourSubDial ?? false) : false
    readonly property bool cfgShowSunsetDial: Config.ready ? (Config.options.background.widgets.concentric_clock.showSunsetDial ?? false) : false
    readonly property string cfgBottomSubDialContent: Config.ready ? (Config.options.background.widgets.concentric_clock.bottomSubDialContent ?? "weather_temp") : "weather_temp"
    readonly property bool cfgShowMinuteDot: Config.ready ? (Config.options.background.widgets.concentric_clock.showMinuteDot ?? false) : false

    readonly property bool cfgQuoteEnable: Config.ready ? (Config.options.background.widgets.concentric_clock.quoteEnable ?? false) : false
    readonly property string cfgQuoteText: Config.ready ? (Config.options.background.widgets.concentric_clock.quoteText ?? "") : ""
    readonly property bool cfgUseBlackBg: Config.ready ? (Config.options.background.widgets.concentric_clock.useBlackBg ?? false) : false
    readonly property bool cfgEnableGlassReflection: Config.ready ? (Config.options.background.widgets.concentric_clock.enableGlassReflection ?? false) : false
    readonly property real cfgMinutePillLeftMargin: Config.ready ? (Config.options.background.widgets.concentric_clock.minutePillLeftMargin ?? 67) / 100.0 : 0.67
    readonly property real cfgSubdialMarginOffset: Config.ready ? (Config.options.background.widgets.concentric_clock.subdialMarginOffset ?? 5) / 100.0 : 0.05
    readonly property real cfgDialMarginOffset: Config.ready ? (Config.options.background.widgets.concentric_clock.dialMarginOffset ?? 3) / 100.0 : 0.03

    readonly property real cfgHourPixelSize: Config.ready ? (Config.options.background.widgets.concentric_clock.hourPixelSize ?? 30) : 30
    readonly property int cfgHourFontWeight: Config.ready ? (Config.options.background.widgets.concentric_clock.hourFontWeight ?? 600) : 600
    readonly property int cfgHourFontWidth: Config.ready ? (Config.options.background.widgets.concentric_clock.hourFontWidth ?? 85) : 85
    readonly property int cfgHourFontRound: Config.ready ? (Config.options.background.widgets.concentric_clock.hourFontRound ?? 100) : 100

    readonly property real cfgBlurRadius: Math.max(0, Math.min(64, Config.ready ? (Config.options.background.widgets.concentric_clock.blurRadius ?? Config.options.background.widgets.blurRadius ?? 32) : 32))
    readonly property real cfgTransparency: Math.max(0.0, Math.min(1.0, Config.ready ? (Config.options.background.widgets.concentric_clock.transparency ?? 0.45) : 0.45))

    readonly property color clockBgColor: isWuWa
        ? ResonanceTheme.colTealInk
        : (root.cfgUseBlackBg ? Appearance.m3colors.m3shadow : Appearance.colors.colPrimaryContainer)
    readonly property color clockTextColor: isWuWa
        ? ResonanceTheme.textPrimary
        : (root.cfgUseBlackBg ? WidgetColorScheme.textColorOnBg : Appearance.colors.colPrimary)
    readonly property color clockSubtextColor: isWuWa
        ? ResonanceTheme.textSecondary
        : (root.cfgUseBlackBg ? WidgetColorScheme.subtextColorOnBg : ColorUtils.applyAlpha(root.clockTextColor, 0.85))
    readonly property color clockAccentColor: isWuWa
        ? ResonanceTheme.accentGold
        : (root.cfgUseBlackBg ? WidgetColorScheme.accentColor : Appearance.colors.colOnPrimaryContainer)

    // Stage 3: WuWa Perceptual Contrast Mapping
    // Non-linear sqrt(rawAlpha) curve provides solid deep teal contrast support behind
    // foreground numerals/text against bright sunset skies while preserving transparency=1 -> 0, transparency=0 -> 1 (before theme intensity scaling).
    // On the lock screen (root.atLock), calibrate baseline opacity to bgGlassElevated (0.85 * intensity) so the dark radial gradient disc is consistently prominent and high-contrast behind the ivory numerals.
    readonly property real wuwaBgAlpha: {
        if (root.atLock) {
            return Math.max(0.85 * ResonanceTheme.intensity, Math.sqrt(1.0 - root.cfgTransparency) * ResonanceTheme.intensity);
        }
        var rawAlpha = 1.0 - root.cfgTransparency;
        return Math.max(0.0, Math.min(1.0, Math.sqrt(rawAlpha) * ResonanceTheme.intensity));
    }

    ResonanceClockGeometry {
        id: clockGeom
    }

    readonly property bool wuwaDialRotating: root.live
        && !GlobalStates.screenLocked
        && (root.Window.window?.visible ?? true)
        && (root.Window.window?.activeWorkspaceWithFullscreen == undefined)

    readonly property string wuwaWeatherTemp: {
        var t = Weather.data?.temp;
        if (t !== undefined && t !== null && String(t).trim() !== "") {
            var str = String(t).trim();
            return str.indexOf("°") !== -1 ? str : str + "°";
        }
        return "--";
    }

    readonly property string wuwaWeatherDesc: {
        var d = Weather.data?.description;
        if (d !== undefined && d !== null && String(d).trim() !== "") {
            var raw = String(d).trim().toUpperCase();
            if (raw === "OVERCAST CLOUDS") return "OVERCAST";
            if (raw === "CLEAR SKY") return "CLEAR";
            return raw;
        }
        return "";
    }

    readonly property string wuwaWeatherText: {
        if (root.cfgBottomSubDialContent === "battery") {
            return Math.round(Battery.percentage * 100) + "%" + (Battery.isCharging ? " ⚡" : "");
        }
        if (wuwaWeatherDesc === "") {
            return wuwaWeatherTemp;
        }
        return wuwaWeatherTemp + " · " + wuwaWeatherDesc;
    }

    // Dynamic offset for sub-dials based on dialStyle to prevent overlapping numbers
    readonly property real dialInnerMargin: ((cfgDialStyle === "concentric" || cfgDialStyle === "inner_only" || cfgDialStyle === "full_dense") ? 0.08 : 0.02) + cfgSubdialMarginOffset

    SystemClock {
        id: localSystemClock
        precision: SystemClock.Seconds
    }

    property int clockSecond: localSystemClock.seconds

    StyledDropShadow {
        target: clockBgCircle
        visible: Config.options.background.widgets.enableShadows ?? true
    }

    Column {
        anchors.centerIn: parent
        spacing: 10

        // Main Clock Container
        Item {
            id: clockContainer
            width: root.implicitWidth
            height: root.implicitHeight

            // Background Circle (Card / Black) with CLIP: TRUE containing all dial elements
            Rectangle {
                id: clockBgCircle
                anchors.fill: parent
                radius: width / 2
                color: root.isWuWa ? "transparent" : ((root.cfgBlurRadius > 0 && root.wallpaperItem !== null) ? "transparent" : ColorUtils.applyAlpha(root.clockBgColor, 1.0 - root.cfgTransparency))
                clip: true

                layer.enabled: !root.isWuWa
                layer.smooth: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: clockBgCircle.width
                        height: clockBgCircle.height
                        radius: width / 2
                        color: "white"
                        visible: false
                    }
                }

                // Stage 3: WuWa Localized Soft Glass Mask
                // Core covers hour/AMPM/resonance/weather, delicate wing extends right behind/beyond capsule
                Canvas {
                    id: wuwaGlassMask
                    anchors.fill: parent
                    visible: false
                    contextType: "2d"

                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()
                    Component.onCompleted: requestPaint()
                    Connections {
                        target: root
                        function onAtLockChanged() { wuwaGlassMask.requestPaint() }
                    }

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        var w = width;
                        var h = height;
                        if (w <= 0 || h <= 0) return;

                        var d = Math.min(w, h);
                        var r = d / 2.0;
                        var cx = w / 2.0;
                        var cy = h / 2.0;

                        // 1. Central Core: Solid deep contrast backing under hour, AM/PM, RESONANCE, ECG, weather
                        // Feather begins at 0.45R (~0.22D) and smoothly fades out to 0.72R (~0.36D)
                        var coreGrad = ctx.createRadialGradient(cx, cy, r * 0.45, cx, cy, r * 0.72);
                        coreGrad.addColorStop(0.0, "rgba(255, 255, 255, 1.0)");
                        coreGrad.addColorStop(0.60, "rgba(255, 255, 255, 0.95)");
                        coreGrad.addColorStop(0.85, "rgba(255, 255, 255, 0.40)");
                        coreGrad.addColorStop(1.0, "rgba(255, 255, 255, 0.0)");

                        ctx.fillStyle = coreGrad;
                        ctx.beginPath();
                        ctx.arc(cx, cy, r * 0.72, 0, Math.PI * 2);
                        ctx.fill();

                        // 2. Localized Glass Wing behind and beyond capsule:
                        // Centered slightly left of capsule (cx ~ 0.77D, cy ~ 0.46D)
                        // Extends beyond the right edge of capsule (x=0.93D) to ~0.99D,
                        // then gradually dissolves out toward the right and outside
                        var capCenterX = d * 0.77;
                        var capCenterY = d * 0.46;
                        var capRadiusX = d * 0.22;
                        var capRadiusY = d * 0.16;

                        ctx.save();
                        ctx.translate(capCenterX, capCenterY);
                        ctx.scale(1.0, capRadiusY / capRadiusX);
                        var capGrad = ctx.createRadialGradient(-d * 0.04, 0, d * 0.04, 0, 0, capRadiusX);
                        capGrad.addColorStop(0.0, "rgba(255, 255, 255, 1.0)");
                        capGrad.addColorStop(0.50, "rgba(255, 255, 255, 0.80)");
                        capGrad.addColorStop(0.75, "rgba(255, 255, 255, 0.35)");
                        capGrad.addColorStop(1.0, "rgba(255, 255, 255, 0.0)");
                        ctx.fillStyle = capGrad;
                        ctx.beginPath();
                        ctx.arc(0, 0, capRadiusX, 0, Math.PI * 2);
                        ctx.fill();
                        ctx.restore();
                    }
                }

                Rectangle {
                    id: bgBlurClassicMask
                    anchors.fill: parent
                    radius: width / 2
                    color: "white"
                    visible: false
                }

                // Wallpaper blur sampler within circle behind existing children
                FastBlurred {
                    id: bgBlur
                    anchors.fill: parent
                    cardRadius: width / 2
                    blurSource: root.wallpaperItem
                    blurRadius: root.cfgBlurRadius
                    trackX: root.x
                    trackY: root.y
                    tint: root.isWuWa ? ResonanceTheme.colTealInk : root.clockBgColor
                    tintOpacity: root.isWuWa ? root.wuwaBgAlpha : (1.0 - root.cfgTransparency)
                    visible: root.cfgBlurRadius > 0 && root.wallpaperItem !== null

                    layer.effect: OpacityMask {
                        maskSource: root.isWuWa ? wuwaGlassMask : bgBlurClassicMask
                    }
                }

                // Static colored glass fallback when wallpaper blur is unavailable
                Item {
                    id: wuwaGlassFallback
                    anchors.fill: parent
                    visible: root.isWuWa && (root.cfgBlurRadius <= 0 || root.wallpaperItem === null)

                    Rectangle {
                        anchors.fill: parent
                        color: ResonanceTheme.colTealInk
                    }

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: wuwaGlassMask
                    }
                    opacity: root.wuwaBgAlpha
                }

                // 1. Dial Canvas wrapped in stationary Item with cutout mask for seconds readout
                Item {
                    id: dialCanvasWrapper
                    anchors.fill: parent

                    readonly property bool maskActive: !root.isWuWa && root.cfgMinuteStyle !== "hide"
                        && (root.cfgDialStyle === "concentric" && root.cfgMinuteStyle === "pill_horizontal")

                    layer.enabled: maskActive
                    layer.smooth: true
                    layer.effect: OpacityMask {
                        maskSource: Canvas {
                            id: dialFadeMask
                            width: dialCanvasWrapper.width
                            height: dialCanvasWrapper.height
                            visible: false
                            contextType: "2d"

                            onPaint: {
                                var ctx = getContext("2d");
                                var w = width;
                                var h = height;
                                ctx.reset();
                                ctx.fillStyle = "white";
                                ctx.fillRect(0, 0, w, h);

                                ctx.globalCompositeOperation = "destination-out";
                                if (root.isWuWa) {
                                    var geom = clockGeom.get(w);
                                    var clr = geom.maskClearance;
                                    var capX = geom.capsuleX - clr;
                                    var capY = (geom.capsuleYCenter - (geom.capsuleHeight / 2.0)) - clr;
                                    var capW = geom.capsuleWidth + (clr * 2.0);
                                    var capH = geom.capsuleHeight + (clr * 2.0);
                                    var capR = capH / 2.0;

                                    ctx.fillStyle = "rgba(0, 0, 0, 1.0)";
                                    ctx.beginPath();
                                    ctx.moveTo(capX + capR, capY);
                                    ctx.lineTo(capX + capW - capR, capY);
                                    ctx.arc(capX + capW - capR, capY + capR, capR, -Math.PI / 2, 0, false);
                                    ctx.lineTo(capX + capW, capY + capH - capR);
                                    ctx.arc(capX + capW - capR, capY + capH - capR, capR, 0, Math.PI / 2, false);
                                    ctx.lineTo(capX + capR, capY + capH);
                                    ctx.arc(capX + capR, capY + capH - capR, capR, Math.PI / 2, Math.PI, false);
                                    ctx.lineTo(capX, capY + capR);
                                    ctx.arc(capX + capR, capY + capR, capR, Math.PI, 3 * Math.PI / 2, false);
                                    ctx.closePath();
                                    ctx.fill();
                                } else {
                                    var cx = w * 0.93;
                                    var cy = h * 0.5;
                                    var rOuter = w * 0.075;
                                    var rInner = w * 0.04;
                                    var grad = ctx.createRadialGradient(cx, cy, 0, cx, cy, rOuter);
                                    grad.addColorStop(0.0, "rgba(0, 0, 0, 1.0)");
                                    grad.addColorStop(rInner / rOuter, "rgba(0, 0, 0, 1.0)");
                                    grad.addColorStop(1.0, "rgba(0, 0, 0, 0.0)");
                                    ctx.fillStyle = grad;
                                    ctx.beginPath();
                                    ctx.arc(cx, cy, rOuter, 0, 2 * Math.PI);
                                    ctx.fill();
                                }
                            }

                            Connections {
                                target: dialCanvasWrapper
                                function onMaskActiveChanged() {
                                    if (dialCanvasWrapper.maskActive) {
                                        dialFadeMask.requestPaint();
                                    }
                                }
                            }

                            Connections {
                                target: root
                                function onIsWuWaChanged() {
                                    dialFadeMask.requestPaint();
                                }
                            }

                            onWidthChanged: requestPaint()
                            onHeightChanged: requestPaint()
                        }
                    }

                    ConcentricDialCanvas {
                        anchors.fill: parent
                        rotateSeconds: root.cfgDialStyle === "concentric"
                        animationActive: root.isWuWa ? root.wuwaDialRotating : root.live
                        smoothRotation: root.smoothMotion
                        isWuWa: root.isWuWa
                        currentSecond: localSystemClock.seconds
                        currentMinute: localSystemClock.minutes
                        dialStyle: root.cfgDialStyle
                        showMinuteDot: root.cfgShowMinuteDot
                        boldFont: root.cfgBoldFont
                        dialMarginOffset: root.cfgDialMarginOffset
                        hideMinutePillArea: root.cfgMinuteStyle !== "hide"
                        textColor: root.clockTextColor
                        subtextColor: root.clockSubtextColor
                        accentColor: root.isWuWa ? ResonanceTheme.textPrimary : root.clockAccentColor
                    }
                }

                // WuWa Chrono Resonator Outer Etched Ring & Focal Signature
                ResonanceRing {
                    anchors.fill: parent
                    visible: root.isWuWa
                    live: root.wuwaDialRotating
                    minutePillVisible: root.cfgMinuteStyle !== "hide"
                }

                // Cookie Clock Big Hour Numbers overlay (Style 7: numbers)
                FadeLoader {
                    anchors.fill: parent
                    shown: root.cfgDialStyle === "numbers"
                    sourceComponent: BigHourNumbers {
                        color: root.clockTextColor
                        numberSize: parent.width * 0.3
                        fontSize: Math.round(parent.width * 0.28)
                        margins: Math.round(parent.width * (0.05 - root.cfgDialMarginOffset))
                    }
                }

                // 2. Outer Frame Overlay
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.color: ColorUtils.applyAlpha(root.clockSubtextColor, root.cfgFrameStyle === "ring_thick" ? 0.35 : 0.2)
                    border.width: root.cfgFrameStyle === "ring_thick" ? 4 : root.cfgFrameStyle === "ring_thin" ? 1.5 : 0
                    visible: root.cfgFrameStyle === "ring_thin" || root.cfgFrameStyle === "ring_thick"
                }

                // Dot Ring Frame Overlay
                Item {
                    anchors.fill: parent
                    visible: root.cfgFrameStyle === "dot_ring"
                    Repeater {
                        model: 60
                        Item {
                            anchors.fill: parent
                            rotation: index * 6
                            Rectangle {
                                width: index % 5 === 0 ? 3 : 1.5
                                height: width
                                radius: width / 2
                                color: ColorUtils.applyAlpha(root.clockSubtextColor, index % 5 === 0 ? 0.6 : 0.3)
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.topMargin: 2
                            }
                        }
                    }
                }

                // 3. Arc 24h (Top)
                FadeLoader {
                    anchors.fill: parent
                    shown: root.cfgShowArc24h
                    sourceComponent: ConcentricArc24h {
                        textColor: root.clockTextColor
                        subtextColor: root.clockSubtextColor
                        accentColor: root.clockAccentColor
                    }
                }

                // 4. Hour Sub-Dial (Bottom-Left 7:30)
                FadeLoader {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: parent.width * (0.16 + root.dialInnerMargin)
                    anchors.bottomMargin: parent.height * (0.20 + root.dialInnerMargin)
                    shown: root.cfgShowHourSubDial
                    sourceComponent: ConcentricSubDial {
                        type: "hour"
                        textColor: root.clockTextColor
                        subtextColor: root.clockSubtextColor
                        accentColor: root.clockAccentColor
                    }
                }

                // 5. Sunset Sub-Dial (Top-Center)
                FadeLoader {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    shown: root.cfgShowSunsetDial
                    sourceComponent: ConcentricSubDial {
                        type: "sunset"
                        textColor: root.clockTextColor
                        subtextColor: root.clockSubtextColor
                        accentColor: root.clockAccentColor
                    }
                }

                // 6. Bottom Complication (Battery / Weather)
                FadeLoader {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: parent.height * (0.06 + root.dialInnerMargin)
                    shown: !root.isWuWa && root.cfgBottomSubDialContent !== "none"
                    sourceComponent: ConcentricComplication {
                        type: root.cfgBottomSubDialContent
                        textColor: root.clockTextColor
                        subtextColor: root.clockSubtextColor
                        accentColor: root.clockAccentColor
                    }
                }

                // 7. Large Hour Display
                FadeLoader {
                    anchors.horizontalCenter: root.isWuWa ? parent.left : parent.horizontalCenter
                    anchors.horizontalCenterOffset: root.isWuWa ? clockGeom.get(parent.width).hourX : 0
                    anchors.verticalCenter: root.isWuWa ? parent.top : parent.verticalCenter
                    anchors.verticalCenterOffset: root.isWuWa ? clockGeom.get(parent.width).hourY : 0
                    shown: root.cfgShowHourText
                    sourceComponent: ConcentricHourDisplay {
                        hour: localSystemClock.hours
                        baseWidth: clockContainer.width
                        use24h: root.cfgUse24h
                        boldFont: root.cfgBoldFont
                        customPixelSize: root.isWuWa ? Math.min(26, root.cfgHourPixelSize) : root.cfgHourPixelSize
                        customWeight: root.cfgHourFontWeight
                        customWidth: root.cfgHourFontWidth
                        customRound: root.cfgHourFontRound
                        opticalCenter: root.isWuWa
                        color: root.clockTextColor
                    }
                }

                // 7b. WuWa Upper Stationary AM/PM Indicator (12h format only)
                StyledText {
                    id: wuwaAmPmText
                    visible: root.isWuWa && !root.cfgUse24h
                    anchors.horizontalCenter: parent.left
                    anchors.horizontalCenterOffset: clockGeom.get(parent.width).xAmPm
                    anchors.verticalCenter: parent.top
                    anchors.verticalCenterOffset: clockGeom.get(parent.width).yAmPm
                    text: (localSystemClock.hours ?? 0) >= 12 ? "PM" : "AM"
                    color: ResonanceTheme.textPrimary
                    opacity: 0.85 * ResonanceTheme.intensity
                    font {
                        family: Appearance.font.family.main
                        pixelSize: Math.max(8, Math.round(clockContainer.width * 0.038))
                        weight: Font.DemiBold
                        letterSpacing: Math.max(1.0, clockContainer.width * 0.008)
                    }
                }

                // 8. Minute Pill (Positioned right at 3:00 / 15 minute tick, clipped by clockBgCircle)
                FadeLoader {
                    anchors.verticalCenter: root.isWuWa ? parent.top : parent.verticalCenter
                    anchors.verticalCenterOffset: root.isWuWa ? clockGeom.get(parent.width).capsuleYCenter : 0
                    anchors.left: parent.left
                    anchors.leftMargin: root.isWuWa ? clockGeom.get(parent.width).capsuleX : (parent.width * root.cfgMinutePillLeftMargin)
                    shown: root.cfgMinuteStyle !== "hide"
                    sourceComponent: ConcentricMinutePill {
                        isWuWa: root.isWuWa
                        baseWidth: clockContainer.width
                        minuteStyle: root.cfgMinuteStyle
                        boldFont: root.cfgBoldFont
                        textColor: root.clockTextColor
                        accentColor: root.clockAccentColor
                        outlineColor: root.isWuWa ? ResonanceTheme.borderAccent : ColorUtils.applyAlpha(root.clockTextColor, 0.5)
                        pillBg: root.isWuWa ? ResonanceTheme.bgGlassElevated : (root.cfgUseBlackBg ? WidgetColorScheme.pillBgColor : ColorUtils.applyAlpha(root.clockBgColor, 0.45))
                        filled: root.isWuWa ? true : !root.cfgUseBlackBg
                        showSeconds: (root.cfgDialStyle === "concentric" && root.cfgMinuteStyle === "pill_horizontal") || root.isWuWa
                        second: localSystemClock.seconds
                        minute: localSystemClock.minutes
                        secondsCenterX: clockContainer.width * (0.93 - root.cfgMinutePillLeftMargin)
                    }
                }

                // 8b. WuWa Under-Center Elements: "RESONANCE" and Constrained Weather readout
                Item {
                    id: wuwaUnderCenter
                    anchors.fill: parent
                    visible: root.isWuWa

                    StyledText {
                        id: resonanceLabel
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.top
                        anchors.verticalCenterOffset: clockGeom.get(parent.width).yResonance
                        text: "RESONANCE"
                        color: ResonanceTheme.accentGold
                        opacity: 0.70 * ResonanceTheme.intensity
                        font {
                            family: Appearance.font.family.main
                            pixelSize: Math.max(8, Math.round(parent.width * 0.038))
                            weight: Font.DemiBold
                            letterSpacing: Math.max(1.0, parent.width * 0.010)
                        }
                    }

                    // 8c. Curved Weather Annotation (WuWa Chrono Resonator Stage 2)
                    ResonanceWeatherArc {
                        id: wuwaWeatherArc
                        anchors.fill: parent
                        visible: root.cfgBottomSubDialContent !== "none"
                        text: root.wuwaWeatherText
                        baseDiameter: clockContainer.width
                        radius: clockGeom.get(parent.width).rWeatherArc
                        maxArcSpan: clockGeom.get(parent.width).maxWeatherArcSpan
                        fontPixelSize: clockGeom.get(parent.width).weatherFontSize
                        fontFamily: Appearance.font.family.main
                        color: ResonanceTheme.textPrimary
                        accentColor: ResonanceTheme.textPrimary
                        accentOpacity: 0.90 * ResonanceTheme.intensity
                    }
                }
            }

            // 9. Hour Marks (Center overlay)
            FadeLoader {
                id: hourMarksLoader
                anchors.centerIn: parent
                shown: root.cfgShowHourMarks
                sourceComponent: HourMarks {
                    implicitSize: parent.width * 0.55
                }
            }

            // 10. Minute Hand (Center overlay)
            FadeLoader {
                anchors.fill: parent
                z: 1
                shown: root.cfgMinuteHandStyle !== "hide"
                sourceComponent: MinuteHand {
                    anchors.fill: parent
                    clockMinute: DateTime.clock.minutes
                    style: root.cfgMinuteHandStyle
                    color: root.clockSubtextColor
                }
            }

            // 11. Hour Hand (Center overlay)
            FadeLoader {
                anchors.fill: parent
                z: (item && item.style === "hollow") ? 0 : 2
                shown: root.cfgHourHandStyle !== "hide"
                sourceComponent: HourHand {
                    clockHour: DateTime.clock.hours % 12
                    clockMinute: DateTime.clock.minutes
                    style: root.cfgHourHandStyle
                    color: root.clockAccentColor
                }
            }

            // 12. Second Hand (Center overlay)
            FadeLoader {
                z: (root.cfgSecondHandStyle === "line") ? 2 : 3
                shown: root.cfgSecondHandStyle !== "hide"
                anchors.fill: parent
                sourceComponent: SecondHand {
                    clockSecond: root.clockSecond
                    style: root.cfgSecondHandStyle
                    color: root.clockSubtextColor
                }
            }

            // 13. Center Pivot Dot
            FadeLoader {
                z: 4
                anchors.centerIn: parent
                shown: root.cfgMinuteHandStyle !== "hide" || root.cfgHourHandStyle !== "hide" || root.cfgSecondHandStyle !== "hide"
                sourceComponent: Rectangle {
                    implicitWidth: 6
                    implicitHeight: 6
                    radius: 3
                    color: root.clockTextColor
                }
            }

            // 14. 3D Glass Dome Reflection Overlay
            Item {
                id: glassReflectionOverlay
                anchors.fill: parent
                z: 10
                enabled: false
                visible: root.cfgEnableGlassReflection

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Item {
                        width: glassReflectionOverlay.width
                        height: glassReflectionOverlay.height

                        Rectangle {
                            id: outerMaskBase
                            anchors.fill: parent
                            radius: width / 2
                            visible: false
                        }

                        FastBlur {
                            anchors.fill: parent
                            source: outerMaskBase
                            radius: 3
                        }
                    }
                }

                // Top-Right Crescent Reflection
                Item {
                    id: topReflectionContainer
                    anchors.fill: parent
                    layer.enabled: true
                    layer.effect: FastBlur {
                        radius: 28
                    }

                    Shapes.Shape {
                        id: topMaskShape
                        anchors.fill: parent
                        visible: false

                        Shapes.ShapePath {
                            strokeColor: "transparent"
                            fillColor: "white"
                            startX: parent.width * 0.40
                            startY: parent.height * 0.04
                            PathArc {
                                x: topMaskShape.width * 0.96
                                y: topMaskShape.height * 0.60
                                radiusX: topMaskShape.width * 0.48
                                radiusY: topMaskShape.height * 0.48
                                useLargeArc: false
                            }
                            PathArc {
                                x: topMaskShape.width * 0.40
                                y: topMaskShape.height * 0.04
                                radiusX: topMaskShape.width * 0.35
                                radiusY: topMaskShape.height * 0.35
                                useLargeArc: false
                                direction: PathArc.Counterclockwise
                            }
                        }
                    }

                    LinearGradient {
                        anchors.fill: parent
                        start: Qt.point(width * 0.40, height * 0.04)
                        end: Qt.point(width * 0.96, height * 0.60)
                        cached: true
                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: "transparent"
                            }
                            GradientStop {
                                position: 0.3
                                color: ColorUtils.applyAlpha("#FFFFFF", 0.42)
                            }
                            GradientStop {
                                position: 0.7
                                color: ColorUtils.applyAlpha("#FFFFFF", 0.42)
                            }
                            GradientStop {
                                position: 1.0
                                color: "transparent"
                            }
                        }
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: topMaskShape
                        }
                    }
                }

                // Bottom-Left Crescent Reflection
                Item {
                    id: bottomReflectionContainer
                    anchors.fill: parent
                    layer.enabled: true
                    layer.effect: FastBlur {
                        radius: 28
                    }

                    Shapes.Shape {
                        id: bottomMaskShape
                        anchors.fill: parent
                        visible: false

                        Shapes.ShapePath {
                            strokeColor: "transparent"
                            fillColor: "white"
                            startX: parent.width * 0.60
                            startY: parent.height * 0.96
                            PathArc {
                                x: bottomMaskShape.width * 0.04
                                y: bottomMaskShape.height * 0.40
                                radiusX: bottomMaskShape.width * 0.48
                                radiusY: bottomMaskShape.height * 0.48
                                useLargeArc: false
                            }
                            PathArc {
                                x: bottomMaskShape.width * 0.60
                                y: bottomMaskShape.height * 0.96
                                radiusX: bottomMaskShape.width * 0.35
                                radiusY: bottomMaskShape.height * 0.35
                                useLargeArc: false
                                direction: PathArc.Counterclockwise
                            }
                        }
                    }

                    LinearGradient {
                        anchors.fill: parent
                        start: Qt.point(width * 0.60, height * 0.96)
                        end: Qt.point(width * 0.04, height * 0.40)
                        cached: true
                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: "transparent"
                            }
                            GradientStop {
                                position: 0.3
                                color: ColorUtils.applyAlpha("#FFFFFF", 0.28)
                            }
                            GradientStop {
                                position: 0.7
                                color: ColorUtils.applyAlpha("#FFFFFF", 0.28)
                            }
                            GradientStop {
                                position: 1.0
                                color: "transparent"
                            }
                        }
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: bottomMaskShape
                        }
                    }
                }
            }
        }

        // Quote below widget
        FadeLoader {
            anchors.horizontalCenter: parent.horizontalCenter
            shown: root.cfgQuoteEnable && root.cfgQuoteText !== ""
            sourceComponent: CookieQuote {}
        }
    }
}
