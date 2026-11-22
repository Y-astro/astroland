"""Exercise shell animation and view lifetimes with Qt's event loop."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
RUNNER = shutil.which("qmltestrunner6") or (
    "/usr/lib/qt6/bin/qmltestrunner"
    if Path("/usr/lib/qt6/bin/qmltestrunner").exists()
    else shutil.which("qmltestrunner")
)


class ShellPerformanceLifecycleTests(unittest.TestCase):
    @unittest.skipUnless(RUNNER, "qmltestrunner is unavailable")
    def test_qml_lifecycles(self):
        with tempfile.TemporaryDirectory() as directory:
            directory = Path(directory)
            module = directory / "qs"
            module.mkdir()
            (module / "qmldir").write_text("module qs\nsingleton GlobalStates 1.0 GlobalStates.qml\n")
            (module / "GlobalStates.qml").write_text(
                "pragma Singleton\nimport QtQuick\nQtObject { property list<real> visualizerPoints: []; "
                "property bool sidebarLeftOpen: false }\n"
            )
            shutil.copy2(
                ROOT / "modules/ii/background/widgets/visualizer/VisualizerEngine.qml",
                directory / "VisualizerEngine.qml",
            )
            sidebar = (ROOT / "modules/ii/sidebarLeft/SidebarLeftContent.qml").read_text()
            sidebar_loader = "    Component {\n        id: tabLoader\n" + sidebar.split(
                "    Component {\n        id: tabLoader\n", 1
            )[1].split("\n    function applyTabRequest()", 1)[0]
            (directory / "tst_lifecycle.qml").write_text("""
import QtQuick
import QtQuick.Controls
import QtTest
import qs

TestCase {
    id: root
    name: "ShellPerformanceLifecycle"
    when: windowShown
    width: 100
    height: 100
    VisualizerEngine { id: engine; active: false }
    SignalSpy { id: frames; target: engine; signalName: "frame" }
    property bool tabsReady: true
    property bool keepLoaded: false
    property bool shownInWindow: GlobalStates.sidebarLeftOpen
    Timer { id: releaseCollect; interval: 1 }
    @SIDEBAR_LOADER@
    SwipeView { id: view; anchors.fill: parent }
    Component {
        id: page
        Item {
            property bool hasStagedFiles: false
            property string activeSubPage: ""
            property alias inputField: input
            onFocusChanged: if (focus) input.forceActiveFocus()
            TextInput { id: input }
        }
    }

    function test_hide_and_resume() {
        GlobalStates.visualizerPoints = [500, 250, 100];
        wait(100);
        compare(frames.count, 0);
        engine.active = true;
        tryVerify(() => frames.count > 0);
        engine.active = false;
        const hiddenCount = frames.count;
        const hiddenTime = engine.time;
        GlobalStates.visualizerPoints = [900, 800, 700];
        wait(150);
        compare(frames.count, hiddenCount);
        compare(engine.time, hiddenTime);
        engine.active = true;
        tryVerify(() => frames.count > hiddenCount);
        compare(engine.bandCount, 3);
        tryVerify(() => engine.fade > 0);
        engine.active = false;
        GlobalStates.visualizerPoints = [];
        wait(100);
        engine.active = true;
        tryCompare(engine, "fade", 0, 4000);
        const silentCount = frames.count;
        wait(100);
        compare(frames.count, silentCount);
    }

    function test_sidebar_unload_and_preserve_pending_state() {
        GlobalStates.sidebarLeftOpen = true;
        for (let i = 0; i < 4; ++i)
            view.addItem(tabLoader.createObject(view, {sourceComponent: page}));
        tryVerify(() => view.itemAt(0).item !== null);
        view.forceActiveFocus();
        tryVerify(() => view.itemAt(0).item.inputField.activeFocus);
        keyClick(Qt.Key_A);
        compare(view.itemAt(0).item.inputField.text, "a");
        view.itemAt(0).item.inputField.text = "";
        compare(view.itemAt(3).item, null);
        view.setCurrentIndex(1);
        tryVerify(() => view.itemAt(2).item !== null);
        tryVerify(() => view.itemAt(1).item.inputField.activeFocus);
        const pending = view.itemAt(0).item;
        pending.hasStagedFiles = true;
        GlobalStates.sidebarLeftOpen = false;
        tryCompare(view.itemAt(1), "item", null);
        compare(view.itemAt(0).item, pending);
        pending.inputField.text = "unsent draft";
        pending.hasStagedFiles = false;
        wait(20);
        compare(view.itemAt(0).item, pending);
        pending.activeSubPage = "phone-page.qml";
        pending.inputField.text = "";
        wait(20);
        compare(view.itemAt(0).item, pending);
        pending.activeSubPage = "";
        tryCompare(view.itemAt(0), "item", null);
        root.keepLoaded = true;
        GlobalStates.sidebarLeftOpen = true;
        view.setCurrentIndex(3);
        tryVerify(() => view.itemAt(3).item !== null);
        tryVerify(() => view.itemAt(3).item.inputField.activeFocus);
        GlobalStates.sidebarLeftOpen = false;
        verify(view.itemAt(3).item !== null);
        root.keepLoaded = false;
        tryCompare(view.itemAt(3), "item", null);
    }
}
""".replace("@SIDEBAR_LOADER@", sidebar_loader))
            result = subprocess.run(
                [RUNNER, "-input", str(directory), "-import", str(directory)],
                env={**os.environ, "QT_QPA_PLATFORM": "offscreen", "QT_QUICK_BACKEND": "software"},
                capture_output=True, text=True, timeout=15,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
