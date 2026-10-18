pragma ComponentBehavior: Bound

import QtQuick

Canvas {
    id: root

    // Data props passed from parent (root clock)
    property string text: ""
    property color color: "#ede8dd"        // Primary text (temperature / battery %)
    property color accentColor: "#e6c67a"  // Accent text (condition description)
    property real accentOpacity: 0.85

    // Geometry props passed from parent
    property real baseDiameter: 264
    property real radius: baseDiameter * 0.266
    property real maxArcSpan: 100.0 * Math.PI / 180.0
    property string fontFamily: ""
    property int fontPixelSize: Math.max(8, Math.round(baseDiameter * 0.038))
    property int fontWeight: Font.DemiBold
    property real letterSpacing: Math.max(0.8, baseDiameter * 0.005)

    // Observable inspection properties for verification / telemetry
    readonly property string displayedText: internalDisplayedText
    readonly property real computedArcSpan: internalComputedSpan
    readonly property real minAngle: internalMinAngle
    readonly property real maxAngle: internalMaxAngle
    readonly property bool isShortened: internalIsShortened

    property string internalDisplayedText: ""
    property real internalComputedSpan: 0.0
    property real internalMinAngle: 0.0
    property real internalMaxAngle: 0.0
    property bool internalIsShortened: false

    anchors.fill: parent
    contextType: "2d"

    onTextChanged: requestPaint()
    onColorChanged: requestPaint()
    onAccentColorChanged: requestPaint()
    onAccentOpacityChanged: requestPaint()
    onRadiusChanged: requestPaint()
    onMaxArcSpanChanged: requestPaint()
    onFontPixelSizeChanged: requestPaint()
    onFontFamilyChanged: requestPaint()
    onFontWeightChanged: requestPaint()
    onLetterSpacingChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onVisibleChanged: {
        if (visible) requestPaint();
    }

    // Helper grouping combining diacritics, variation selectors, and ZWJ sequences with base codepoint
    function splitGraphemes(str) {
        if (!str) return [];
        var points = Array.from(str);
        var clusters = [];
        var combiningRe = /^[\u0300-\u036F\u1AB0-\u1AFF\u1DC0-\u1DFF\u20D0-\u20FF\uFE00-\uFE0F\uFE20-\uFE2F]$/;

        for (var i = 0; i < points.length; i++) {
            var ch = points[i];
            if (i > 0 && clusters.length > 0 && (combiningRe.test(ch) || points[i - 1] === "\u200D" || ch === "\u200D")) {
                clusters[clusters.length - 1] += ch;
            } else {
                clusters.push(ch);
            }
        }
        return clusters;
    }

    onPaint: {
        var ctx = getContext("2d");
        ctx.reset();

        var trimmed = root.text ? root.text.trim() : "";
        if (!trimmed || root.radius <= 0 || width <= 0 || height <= 0) {
            root.internalDisplayedText = "";
            root.internalComputedSpan = 0.0;
            root.internalMinAngle = 0.0;
            root.internalMaxAngle = 0.0;
            root.internalIsShortened = false;
            return;
        }

        var cx = width / 2.0;
        var cy = height / 2.0;
        var r = root.radius;
        var maxSpan = root.maxArcSpan > 0 ? root.maxArcSpan : (100.0 * Math.PI / 180.0);
        var spacing = root.letterSpacing;

        // Font specification
        var weightStr = (root.fontWeight === Font.Bold || root.fontWeight === Font.DemiBold) ? "600 " : "";
        var familyStr = root.fontFamily ? ("\"" + root.fontFamily + "\", sans-serif") : "sans-serif";
        ctx.font = weightStr + root.fontPixelSize + "px " + familyStr;
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";

        function measureChars(chars) {
            var widths = [];
            var totalW = 0;
            for (var i = 0; i < chars.length; i++) {
                var w = ctx.measureText(chars[i]).width;
                widths.push(w);
                totalW += w;
            }
            if (chars.length > 1) {
                totalW += (chars.length - 1) * spacing;
            }
            return { widths: widths, totalWidth: totalW, span: totalW / r };
        }

        var sep = " · ";
        var sepIdx = trimmed.indexOf(sep);
        var finalText = trimmed;
        var chars = splitGraphemes(trimmed);
        var measured = measureChars(chars);
        var shortened = false;

        // Adaptive shortening with strict temperature priority
        if (measured.span > maxSpan && sepIdx !== -1) {
            var tempPart = trimmed.substring(0, sepIdx);
            var descPart = trimmed.substring(sepIdx + sep.length);
            var descChars = splitGraphemes(descPart);

            var fit = false;
            // Shorten description character by character from the end with ellipsis
            for (var len = descChars.length - 1; len >= 1; len--) {
                var candidate = tempPart + sep + descChars.slice(0, len).join("") + "…";
                var cChars = splitGraphemes(candidate);
                var cMeasured = measureChars(cChars);
                if (cMeasured.span <= maxSpan) {
                    finalText = candidate;
                    chars = cChars;
                    measured = cMeasured;
                    fit = true;
                    shortened = true;
                    break;
                }
            }

            // If even 1 description character with ellipsis does not fit, keep temperature alone
            if (!fit) {
                var tempChars = splitGraphemes(tempPart);
                var tMeasured = measureChars(tempChars);
                if (tMeasured.span <= maxSpan) {
                    finalText = tempPart;
                    chars = tempChars;
                    measured = tMeasured;
                    fit = true;
                    shortened = true;
                }
            }
        }

        // Fallback truncation if string still exceeds maxSpan (e.g. very long temp or battery string)
        if (measured.span > maxSpan) {
            for (var tLen = chars.length - 1; tLen >= 1; tLen--) {
                var tCandidate = chars.slice(0, tLen).join("") + "…";
                var tcChars = splitGraphemes(tCandidate);
                var tcMeasured = measureChars(tcChars);
                if (tcMeasured.span <= maxSpan) {
                    finalText = tCandidate;
                    chars = tcChars;
                    measured = tcMeasured;
                    shortened = true;
                    break;
                }
            }
        }

        // Update telemetry properties
        root.internalDisplayedText = finalText;
        root.internalComputedSpan = measured.span;
        root.internalIsShortened = shortened;

        // Locate separator position in character array for two-tone color assignment
        var sepCharIndex = -1;
        if (finalText.indexOf(sep) !== -1) {
            var sepChars = splitGraphemes(sep);
            for (var si = 0; si <= chars.length - sepChars.length; si++) {
                var match = true;
                for (var sj = 0; sj < sepChars.length; sj++) {
                    if (chars[si + sj] !== sepChars[sj]) {
                        match = false;
                        break;
                    }
                }
                if (match) {
                    sepCharIndex = si;
                    break;
                }
            }
        }

        var primaryFill = root.color;
        var accentAlpha = (root.accentColor.a !== undefined ? root.accentColor.a : 1.0) * root.accentOpacity;
        var accentFill = Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, accentAlpha);

        var totalW = measured.totalWidth;
        var totalSpan = measured.span;
        var startAngle = -totalSpan / 2.0;

        root.internalMinAngle = startAngle;
        root.internalMaxAngle = totalSpan / 2.0;

        var curArcDist = 0;
        for (var k = 0; k < chars.length; k++) {
            var ch = chars[k];
            var chW = measured.widths[k];
            var charCenterDist = curArcDist + chW / 2.0;
            var a = startAngle + (charCenterDist / r);

            // Coordinates along the lower concentric circumference:
            // cx + r * sin(a), cy + r * cos(a) with rotate(-a)
            var tx = cx + r * Math.sin(a);
            var ty = cy + r * Math.cos(a);

            var isAccent = (sepCharIndex !== -1 && k >= sepCharIndex);
            ctx.fillStyle = isAccent ? accentFill : primaryFill;

            ctx.save();
            ctx.translate(tx, ty);
            ctx.rotate(-a);
            ctx.fillText(ch, 0, 0);
            ctx.restore();

            curArcDist += chW + spacing;
        }
    }
}
