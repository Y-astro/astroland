import QtQuick
import qs.modules.common

MouseArea { // Right side | scroll to change volume
    id: root

    signal scrollUp(delta: int)
    signal scrollDown(delta: int)
    signal movedAway()

    property bool hovered: false
    property real lastScrollX: 0
    property real lastScrollY: 0
    property bool trackingScroll: false
    property real moveThreshold: 20
    property real touchpadDeltaThreshold: 240
    property real _touchpadDelta: 0
    property bool invertMouse: false

    acceptedButtons: Qt.LeftButton
    hoverEnabled: true

    onEntered: {
        root.hovered = true;
    }

    onExited: {
        root.hovered = false;
        root.trackingScroll = false;
        root._touchpadDelta = 0;
    }

    function handleWheel(event) {
        if (event.phase === Qt.ScrollBegin || event.phase === Qt.ScrollEnd)
            root._touchpadDelta = 0;

        const rawDelta = event.angleDelta.y;
        if (rawDelta !== 0) {
            // QtWayland sends primaryPointingDevice (TouchPad on gesture seats) for all wheel events; use scroll phase.
            const hasScrollPhase = event.phase !== undefined && event.phase !== Qt.NoScrollPhase;
            const isTouchpad = hasScrollPhase
                || (event.device === undefined && Math.abs(rawDelta) < (Config.options?.interactions?.scrolling?.mouseScrollDeltaThreshold ?? 120));

            if (!isTouchpad) {
                root._touchpadDelta = 0;
                const delta = root.invertMouse ? -rawDelta : rawDelta;
                if (delta < 0)
                    root.scrollDown(delta);
                else
                    root.scrollUp(delta);
            } else {
                // Natural scroll negates touchpad axis delta on the compositor; restore finger-up == up.
                const invertTouchpad = event.inverted || (Config.options?.hyprland?.input?.touchpad?.naturalScroll ?? false);
                const delta = invertTouchpad ? -rawDelta : rawDelta;
                if ((root._touchpadDelta > 0 && delta < 0) || (root._touchpadDelta < 0 && delta > 0))
                    root._touchpadDelta = 0;
                root._touchpadDelta += delta;

                const threshold = root.touchpadDeltaThreshold;
                while (Math.abs(root._touchpadDelta) >= threshold) {
                    if (root._touchpadDelta > 0) {
                        root._touchpadDelta -= threshold;
                        root.scrollUp(threshold);
                    } else {
                        root._touchpadDelta += threshold;
                        root.scrollDown(-threshold);
                    }
                }
            }
        }

        // Store the mouse position and start tracking
        root.lastScrollX = event.x;
        root.lastScrollY = event.y;
        root.trackingScroll = true;
    }

    onWheel: event => root.handleWheel(event)

    onPositionChanged: mouse => {
        if (root.trackingScroll) {
            const dx = mouse.x - root.lastScrollX;
            const dy = mouse.y - root.lastScrollY;
            if (Math.sqrt(dx * dx + dy * dy) > root.moveThreshold) {
                root.movedAway();
                root.trackingScroll = false;
            }
        }
    }

    onContainsMouseChanged: {
        if (!root.containsMouse && root.trackingScroll) {
            root.movedAway();
            root.trackingScroll = false;
        }
    }
}
