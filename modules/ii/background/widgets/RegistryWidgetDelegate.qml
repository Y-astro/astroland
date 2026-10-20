pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs
import qs.modules.common
import qs.modules.common.functions
import qs.modules.ii.background.widgets

// Additive adapter for registry instances. Legacy singleton widgets keep their
// existing loader and settings; only explicit activeWidgets entries arrive here.
Item {
    id: root
    required property var instance
    required property var screen
    property var wallpaperItem: null
    property bool wallpaperSafetyTriggered: false

    readonly property bool atLock: GlobalStates.screenLocked || (GlobalStates.lockLookActive ?? false)
    readonly property var resolvedPlacement: WidgetPlacement.resolve(
        root.instance,
        root.screen.name,
        root.atLock,
        root.screen.width,
        root.screen.height,
        240,
        240
    )
    readonly property var placement: ({
        x: Number(root.resolvedPlacement.x ?? root.instance.x ?? 200),
        y: Number(root.resolvedPlacement.y ?? root.instance.y ?? 200),
        z: Number(root.instance.z ?? 0),
        scale: Number(root.resolvedPlacement.scale ?? root.instance.scale ?? 1.0),
        pinned: root.instance.pinned === true,
        placementStrategy: root.instance.placementStrategy ?? "free"
    })

    readonly property bool targetMonitorConnected: {
        const mon = String(root.instance?.monitorName ?? "");
        if (!mon) return true;
        for (let i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === mon)
                return true;
        }
        return false;
    }

    readonly property bool onMonitor: {
        const targetMon = String(root.instance?.monitorName ?? "");
        if (!targetMon)
            return true;
        if (targetMon === root.screen.name)
            return true;
        // If there is only one screen, always render on it
        if (Quickshell.screens.length <= 1)
            return true;
        // Fallback for laptop internal panel renumbering (e.g. eDP-1 vs eDP-2 across reboots)
        if (targetMon.startsWith("eDP") && root.screen.name.startsWith("eDP"))
            return true;
        // If the configured monitor is disconnected, fall back to the primary display
        if (!root.targetMonitorConnected && (Quickshell.screens.length > 0 && Quickshell.screens[0] === root.screen))
            return true;
        return false;
    }

    readonly property string sourceUrl: String(WidgetsRegistry.getQmlPath(root.instance.widgetId))

    Loader {
        id: widgetLoader
        active: root.onMonitor && root.sourceUrl.length > 0
        function loadWidget() {
            if (!active)
                return;
            setSource(root.sourceUrl, {
                screenWidth: Qt.binding(() => root.screen.width),
                screenHeight: Qt.binding(() => root.screen.height),
                scaledScreenWidth: Qt.binding(() => root.screen.width),
                scaledScreenHeight: Qt.binding(() => root.screen.height),
                wallpaperScale: 1,
                wallpaperItem: Qt.binding(() => root.wallpaperItem),
                configEntry: Qt.binding(() => root.placement),
                editInstanceId: Qt.binding(() => String(root.instance.id ?? root.instance.instanceId ?? "")),
                instanceId: Qt.binding(() => String(root.instance.id ?? root.instance.instanceId ?? "")),
                editWidgetId: Qt.binding(() => String(root.instance.widgetId)),
                lockBehavior: Qt.binding(() => root.instance.lockBehavior ?? "keep")
            });
        }
        Component.onCompleted: loadWidget()
        onActiveChanged: loadWidget()
        Connections {
            target: root
            function onSourceUrlChanged() { widgetLoader.loadWidget(); }
        }
    }
}
