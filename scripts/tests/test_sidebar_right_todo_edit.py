"""Verify the edit button and edit flow in modules/ii/sidebarRight/todo offscreen."""
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
QT6_RUNNERS = ("/usr/lib/qt6/bin/qmltestrunner", "/usr/lib64/qt6/bin/qmltestrunner")


def find_runner():
    for candidate in QT6_RUNNERS:
        if os.access(candidate, os.X_OK):
            return candidate
    return shutil.which("qmltestrunner6") or shutil.which("qmltestrunner")


def build_fixture(out: Path) -> None:
    def put(rel, text):
        p = out / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(text, encoding="utf-8")

    for name in ("TodoWidget.qml", "TaskList.qml", "TodoItemActionButton.qml"):
        put(f"qs/modules/ii/sidebarRight/todo/{name}",
            (ROOT / "modules/ii/sidebarRight/todo" / name).read_text(encoding="utf-8"))

    put("Quickshell/ScriptModel.qml", """import QtQuick
ListModel {
    property var values: []
    function sync() { clear(); for (const v of values) append({ modelData: v }); }
    onValuesChanged: sync()
    Component.onCompleted: if (count === 0) sync()
}
""")
    put("Quickshell/qmldir", "module Quickshell\nScriptModel 1.0 ScriptModel.qml\n")

    put("qs/modules/common/widgets/StyledListView.qml", """import QtQuick
ListView {
    property bool animateAppearance: false
}
""")
    put("qs/modules/common/widgets/StyledText.qml", """import QtQuick
Text {
    font.pixelSize: 14
    color: "white"
}
""")
    put("qs/modules/common/widgets/MaterialSymbol.qml", """import QtQuick
Text {
    property real iconSize: 16
    property real fill: 0
    font.pixelSize: iconSize
}
""")
    put("qs/modules/common/widgets/RippleButton.qml", """import QtQuick
import QtQuick.Controls
Button {
    property real buttonRadius: 10
    property color colBackground: "transparent"
    property color colBackgroundHover: "transparent"
    property color colBackgroundActive: "transparent"
    property color colRipple: "transparent"
}
""")
    put("qs/modules/common/widgets/FloatingActionButton.qml", """import QtQuick
import QtQuick.Controls
Button {
    property real buttonRadius: 14
    property string iconText: "add"
}
""")
    put("qs/modules/common/widgets/DialogButton.qml", """import QtQuick
import QtQuick.Controls
Button {
    property string buttonText: ""
    text: buttonText
}
""")
    put("qs/modules/common/widgets/StyledRectangularShadow.qml", """import QtQuick
Item {
    property var target: null
    property real radius: 0
    property real blur: 0
}
""")
    put("qs/modules/common/widgets/StyledToolTip.qml", """import QtQuick.Controls
ToolTip {
    property bool extraVisibleCondition: true
}
""")
    put("qs/modules/common/widgets/SecondaryTabBar.qml", """import QtQuick.Controls
TabBar {
    function setCurrentIndex(i) { currentIndex = i; }
    function incrementCurrentIndex() { if (currentIndex < count - 1) currentIndex += 1; }
    function decrementCurrentIndex() { if (currentIndex > 0) currentIndex -= 1; }
}
""")
    put("qs/modules/common/widgets/SecondaryTabButton.qml", """import QtQuick.Controls
TabButton {
    property string buttonText: ""
    property string buttonIcon: ""
    text: buttonText
}
""")

    put("qs/modules/common/Appearance.qml", """pragma Singleton
import QtQuick
QtObject {
    property var colors: ({
        colLayer1: "#1c1f1d",
        colLayer2: "#252926",
        colOnLayer1: "#e6e1e5",
        colPrimary: "#d1b87a",
        colSecondaryContainer: "#4a4432",
        colScrim: "#88000000"
    })
    property var m3colors: ({
        m3surfaceContainerHigh: "#2b2927",
        m3onSurface: "#e6e1e5",
        m3onSurfaceVariant: "#cac4d0",
        m3onSecondaryContainer: "#ffdcc5",
        m3outline: "#938f99"
    })
    property var rounding: ({
        verysmall: 4,
        small: 8,
        normal: 12
    })
    property var sizes: ({ elevationMargin: 8 })
    property var font: ({
        pixelSize: ({ normal: 14, larger: 18 }),
        family: ({ main: "sans-serif" })
    })
    property var animation: ({
        elementMove: ({ velocity: 400 }),
        elementMoveFast: ({ duration: 1, type: Easing.Linear, bezierCurve: [0, 0, 1, 1] })
    })
}
""")
    put("qs/services/Translation.qml", """pragma Singleton
import QtQuick
QtObject {
    function tr(s) { return s; }
}
""")
    put("qs/services/Todo.qml", """pragma Singleton
import QtQuick
QtObject {
    id: root
    property var list: [
        { id: "t-1", content: "fix bluetooth pairing", done: false, provider: "local" },
        { id: "t-2", content: "already done", done: true, provider: "local" },
        { id: "t-locked", content: "read only item", done: false, provider: "locked" }
    ]
    property int updateCalls: 0
    function canEditTask(task) {
        return !!task && task.provider !== "locked";
    }
    function addTask(desc) {
        root.list = root.list.concat([{ id: "t-" + (root.list.length + 1), content: desc, done: false, provider: "local" }]);
    }
    function updateItem(task, changes) {
        if (!root.canEditTask(task))
            return false;
        const nextTitle = String(changes?.content ?? "").trim();
        if (nextTitle.length === 0)
            return false;
        const idx = root.list.findIndex(item => item.id === task.id);
        if (idx < 0)
            return false;
        const next = root.list.slice(0);
        next[idx] = Object.assign({}, next[idx], { content: nextTitle });
        root.list = next;
        root.updateCalls += 1;
        return true;
    }
    function markDone(idx) {}
    function markUnfinished(idx) {}
    function deleteItem(idx) {}
}
""")

    for folder in out.rglob("*"):
        if not folder.is_dir():
            continue
        qmls = sorted(folder.glob("*.qml"))
        if not qmls:
            continue
        lines = ["module " + ".".join(folder.relative_to(out).parts)]
        for q in qmls:
            prefix = "singleton " if "pragma Singleton" in q.read_text(encoding="utf-8") else ""
            lines.append(f"{prefix}{q.stem} 1.0 {q.name}")
        (folder / "qmldir").write_text("\n".join(lines) + "\n", encoding="utf-8")

    put("tests/tst_sidebar_right_todo_edit.qml", """import QtQuick
import QtQuick.Controls
import QtTest
import qs.services
import qs.modules.ii.sidebarRight.todo

Item {
    width: 400
    height: 360

    TodoWidget {
        id: widget
        anchors.fill: parent
    }

    function findAll(node, pred, acc = [], seen = new Set()) {
        if (!node || seen.has(node)) return acc;
        seen.add(node);
        if (pred(node)) acc.push(node);
        for (const child of node.children ?? [])
            findAll(child, pred, acc, seen);
        if (node.contentItem && node.contentItem !== node)
            findAll(node.contentItem, pred, acc, seen);
        return acc;
    }

    function findButtonBySymbol(rootItem, symbolText) {
        return findAll(rootItem, n => n.tooltipText !== undefined && n.contentItem && n.contentItem.text === symbolText
            || (n.tooltipText === undefined && typeof n.clicked === "function" && n.contentItem && n.contentItem.text === symbolText));
    }

    function findDialogButton(rootItem, labelText) {
        const matches = findAll(rootItem, n => n.buttonText === labelText && typeof n.clicked === "function");
        return matches.length > 0 ? matches[0] : null;
    }

    TestCase {
        name: "SidebarRightTodoEdit"
        when: windowShown

        function test_edit_button_and_dialog_flow() {
            wait(50);

            const swipeView = findAll(widget, n => n instanceof SwipeView)[0];
            verify(swipeView !== undefined);
            const unfinishedPage = swipeView.itemAt(0);
            const donePage = swipeView.itemAt(1);

            // Unfinished tab has 2 items; t-1 is editable, t-locked is not.
            const editButtons = findButtonBySymbol(unfinishedPage, "edit").filter(b => b.visible);
            const checkButtons = findButtonBySymbol(unfinishedPage, "check").filter(b => b.visible);
            compare(editButtons.length, 1);
            compare(checkButtons.length, 2);

            // Edit button sits immediately to the left of the tick mark in the same row.
            verify(editButtons[0].parent === checkButtons[0].parent);
            verify(editButtons[0].x < checkButtons[0].x);

            // Open edit dialog for the first task.
            editButtons[0].clicked();
            wait(30);
            verify(widget.showAddDialog);
            verify(widget.isEditing);

            const titleLabels = findAll(widget, n => n.text === "Edit task");
            compare(titleLabels.length, 1);
            const inputs = findAll(widget, n => n instanceof TextField);
            compare(inputs.length, 1);
            const input = inputs[0];
            compare(input.text, "fix bluetooth pairing");
            verify(input.activeFocus);

            const saveBtn = findDialogButton(widget, "Save");
            verify(saveBtn !== null);
            verify(saveBtn.enabled);

            // Whitespace-only edit is rejected.
            input.text = "   ";
            verify(!saveBtn.enabled);
            saveBtn.clicked();
            verify(widget.showAddDialog);
            compare(Todo.updateCalls, 0);

            // Valid edit saves via Todo.updateItem and closes dialog.
            input.text = "fix bluetooth audio";
            verify(saveBtn.enabled);
            saveBtn.clicked();
            wait(30);
            verify(!widget.showAddDialog);
            compare(Todo.updateCalls, 1);
            compare(Todo.list[0].content, "fix bluetooth audio");

            // Cancel / Escape does not modify task, and Add dialog resets cleanly.
            const nextEditButtons = findButtonBySymbol(unfinishedPage, "edit").filter(b => b.visible);
            nextEditButtons[0].clicked();
            wait(30);
            input.text = "unsaved change";
            keyClick(Qt.Key_Escape);
            wait(30);
            verify(!widget.showAddDialog);
            compare(Todo.list[0].content, "fix bluetooth audio");

            keyClick(Qt.Key_N);
            wait(30);
            verify(widget.showAddDialog);
            verify(!widget.isEditing);
            compare(input.text, "");
            verify(findAll(widget, n => n.text === "Add task").length === 1);
            findDialogButton(widget, "Cancel").clicked();
            wait(30);

            // Done tab also allows editing without switching away from Done tab.
            const tabBar = findAll(widget, n => typeof n.setCurrentIndex === "function")[0];
            tabBar.setCurrentIndex(1);
            wait(50);
            const doneEditButtons = findButtonBySymbol(donePage, "edit").filter(b => b.visible);
            compare(doneEditButtons.length, 1);
            doneEditButtons[0].clicked();
            wait(30);
            compare(input.text, "already done");
            input.text = "already done updated";
            findDialogButton(widget, "Save").clicked();
            wait(30);
            compare(tabBar.currentIndex, 1);
            compare(Todo.list[1].content, "already done updated");
        }
    }
}
""")


class SidebarRightTodoEditTests(unittest.TestCase):
    def test_sidebar_right_todo_edit_flow(self):
        runner = find_runner()
        if runner is None:
            self.skipTest("no Qt6 qmltestrunner available")

        with tempfile.TemporaryDirectory(prefix="ii-sidebar-todo-edit-") as tmp:
            out = Path(tmp)
            build_fixture(out)
            res = subprocess.run(
                [runner, "-input", str(out / "tests"), "-import", str(out)],
                env={
                    **os.environ,
                    "QT_QPA_PLATFORM": "offscreen",
                    "QT_QUICK_BACKEND": "software",
                    "QT_QUICK_CONTROLS_STYLE": "Basic",
                },
                capture_output=True,
                text=True,
                timeout=60,
            )
        self.assertEqual(
            res.returncode,
            0,
            f"qmltestrunner exited {res.returncode}\n--- stdout ---\n{res.stdout}\n--- stderr ---\n{res.stderr}",
        )


if __name__ == "__main__":
    unittest.main()
