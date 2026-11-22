pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.services
import qs.modules.common
import qs.modules.common.functions

Singleton {
    id: root

    // Centralized through GlobalStates to eliminate duplicate cava processes
    readonly property list<real> visualizerPoints: GlobalStates.visualizerPoints
    readonly property bool active: visualizerPoints.length > 0 && visualizerPoints.some(p => p > 0)
}
