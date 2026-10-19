import QtQuick
import Quickshell

import qs.modules.common

/**
 * A shell panel, created in its own turn of the event loop.
 *
 * The panel itself is built synchronously, exactly as it always was. What changed is
 * only when: a panel takes a slot from `PanelSchedule` the moment it first wants to
 * exist, and waits for that slot to come up instead of racing every other panel into
 * one pass. See PanelSchedule for why this is a queue and not asynchronous loading.
 */
LazyLoader {
    id: root

    property bool extraCondition: true
    property bool lazy: false
    property bool lazyOpen: false
    property bool retainAfterOpen: false
    property bool everOpened: false

    onLazyOpenChanged: {
        if (root.lazy && root.lazyOpen) {
            root.everOpened = true;
        }
    }

    readonly property bool wanted: Config.ready && root.extraCondition && (!root.lazy || (root.retainAfterOpen ? root.everOpened : root.lazyOpen))

    /// Zero until this panel has asked for a slot. It is released when the panel is no
    /// longer wanted so inactive panel families do not retain a schedule ticket.
    property int ticket: 0

    function takeTicket() {
        if (!root.wanted || root.ticket !== 0)
            return;
        if (root.lazy && PanelSchedule.idle) {
            root.ticket = PanelSchedule.take();
            PanelSchedule.released = root.ticket;
            return;
        }
        root.ticket = PanelSchedule.take();
    }

    active: root.wanted && root.ticket > 0 && PanelSchedule.released >= root.ticket

    onWantedChanged: {
        if (root.wanted)
            root.takeTicket();
        else
            root.ticket = 0;
    }
    Component.onCompleted: root.takeTicket()

    Timer {
        id: releaseCollect
        interval: 500
        onTriggered: {
            if (!root.active && typeof gc === "function")
                gc();
        }
    }

    onActiveChanged: {
        if (!root.active && root.lazy && !root.retainAfterOpen)
            releaseCollect.restart();
    }
}
