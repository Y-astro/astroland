pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: root

    // Central shared geometry profile for WuWa Chrono Resonator
    // Ensures exact consistency across Dial, Ring, Capsule, Complication, and Mask
    function get(diameter) {
        var d = diameter;
        var r = d / 2.0;
        return {
            d: d,
            r: r,
            cx: r,
            cy: r,
            // Concentric radii
            rCardinal: r * 0.95,
            rOrnament: r * 0.92,
            rTickInner: r * 0.86,
            rOrbit: r * 0.74,
            rQuiet: r * 0.60,
            // Cardinal diamond sizing
            cardinalSize: Math.max(2.5, d * 0.015),
            // Compact minute/seconds capsule geometry
            capsuleX: d * 0.68,
            capsuleWidth: d * 0.25,
            capsuleHeight: d * 0.14,
            capsuleYCenter: d * 0.46,
            capsuleRadius: (d * 0.14) / 2.0,
            maskClearance: 2.0,
            // Center hour placement
            hourX: d * 0.50,
            hourY: d * 0.46,
            hourFontSize: Math.round(d * 0.26),
            // Upper-inner stationary AM/PM placement
            xAmPm: d * 0.50,
            yAmPm: d * 0.285,
            // Under-center quiet area vertical coordinates
            yResonance: r + d * 0.105,
            yEcg: r + d * 0.175,
            yWeather: r + d * 0.235,
            // Maximum width for under-center weather readout to strictly remain inside rQuiet (0.60R)
            maxWeatherWidth: d * 0.36,
            // Stage 2: Curved lower weather annotation along inner circumference
            rWeatherArc: d * 0.266,
            weatherFontSize: Math.max(8, Math.round(d * 0.038)),
            maxWeatherArcSpan: 100.0 * Math.PI / 180.0
        };
    }
}
