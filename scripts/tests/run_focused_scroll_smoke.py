"""Verify FocusedScrollMouseArea preserves mouse wheel behavior while normalizing touchpad natural scroll and sensitivity."""
from pathlib import Path
import os
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]


def main():
    runner = next((str(p) for p in (
        Path('/usr/lib64/qt6/bin/qmltestrunner'),
        Path('/usr/lib/qt6/bin/qmltestrunner'),
    ) if p.exists()), None) or shutil.which('qmltestrunner6')
    if not runner:
        raise SystemExit('Qt 6 qmltestrunner is required')

    with tempfile.TemporaryDirectory(prefix='ii-focused-scroll-') as directory:
        out = Path(directory)

        def put(name, text):
            path = out / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text)

        put('qs/modules/common/Config.qml', '''pragma Singleton
import QtQuick
QtObject {
    property QtObject options: QtObject {
        property QtObject interactions: QtObject {
            property QtObject scrolling: QtObject {
                property int mouseScrollDeltaThreshold: 120
            }
        }
        property QtObject hyprland: QtObject {
            property QtObject input: QtObject {
                property QtObject touchpad: QtObject {
                    property bool naturalScroll: true
                }
            }
        }
    }
}
''')
        put('qs/modules/common/widgets/FocusedScrollMouseArea.qml',
            (ROOT / 'modules/common/widgets/FocusedScrollMouseArea.qml').read_text())

        put('tests/tst_FocusedScroll.qml', '''import QtQuick
import QtTest
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    width: 200
    height: 40

    property int ups: 0
    property int downs: 0

    FocusedScrollMouseArea {
        id: area
        anchors.fill: parent
        onScrollUp: root.ups++
        onScrollDown: root.downs++
    }

    TestCase {
        name: "FocusedScroll"
        when: windowShown

        function resetCounters() {
            root.ups = 0;
            root.downs = 0;
            area._touchpadDelta = 0;
        }

        function test_mouse_wheel_unchanged() {
            resetCounters();
            // Real mouse wheel event through QtTest: +120 => up, -120 => down
            mouseWheel(area, 50, 20, 0, 120);
            compare(root.ups, 1);
            compare(root.downs, 0);

            mouseWheel(area, 50, 20, 0, -120);
            compare(root.ups, 1);
            compare(root.downs, 1);
        }

        function test_mouse_wheel_inverted() {
            resetCounters();
            area.invertMouse = true;
            try {
                // Inverted mouse wheel: +120 => down, -120 => up
                mouseWheel(area, 50, 20, 0, 120);
                compare(root.ups, 0);
                compare(root.downs, 1);

                mouseWheel(area, 50, 20, 0, -120);
                compare(root.ups, 1);
                compare(root.downs, 1);
            } finally {
                area.invertMouse = false;
            }
        }

        function test_wayland_mouse_wheel_not_inverted_by_touchpad_device_type() {
            resetCounters();
            // QtWayland passes primaryPointingDevice (TouchPad on gesture seats) for mouse wheel too.
            area.handleWheel({
                x: 50, y: 20,
                angleDelta: Qt.point(0, 120),
                inverted: false,
                phase: Qt.NoScrollPhase,
                device: { type: PointerDevice.TouchPad }
            });
            compare(root.ups, 1);
            compare(root.downs, 0);

            area.handleWheel({
                x: 50, y: 20,
                angleDelta: Qt.point(0, -120),
                inverted: false,
                phase: Qt.NoScrollPhase,
                device: { type: PointerDevice.TouchPad }
            });
            compare(root.ups, 1);
            compare(root.downs, 1);
        }

        function test_touchpad_natural_scroll_and_sensitivity() {
            resetCounters();
            // Finger swipe UP with natural_scroll=true gives negative angleDelta and inverted=true
            for (let i = 0; i < 4; i++) {
                area.handleWheel({
                    x: 50, y: 20,
                    angleDelta: Qt.point(0, -60),
                    inverted: true,
                    phase: i === 0 ? Qt.ScrollBegin : Qt.ScrollUpdate,
                    device: { type: PointerDevice.TouchPad }
                });
            }
            // 4 * 60 = 240 => exactly 1 step UP (instead of 4 steps DOWN!)
            compare(root.ups, 1);
            compare(root.downs, 0);

            // Small sub-threshold nudge followed by direction reversal should not trigger old direction
            area.handleWheel({
                x: 50, y: 20,
                angleDelta: Qt.point(0, -100),
                inverted: true,
                phase: Qt.ScrollUpdate,
                device: { type: PointerDevice.TouchPad }
            });
            compare(root.ups, 1);
            compare(root.downs, 0);

            // Finger swipe DOWN with natural_scroll=true gives positive angleDelta
            for (let i = 0; i < 4; i++) {
                area.handleWheel({
                    x: 50, y: 20,
                    angleDelta: Qt.point(0, 60),
                    inverted: true,
                    phase: Qt.ScrollUpdate,
                    device: { type: PointerDevice.TouchPad }
                });
            }
            compare(root.ups, 1);
            compare(root.downs, 1);
        }

        function test_touchpad_scroll_end_resets_residual() {
            resetCounters();
            area.handleWheel({
                x: 50, y: 20,
                angleDelta: Qt.point(0, -180),
                inverted: true,
                phase: Qt.ScrollBegin,
                device: { type: PointerDevice.TouchPad }
            });
            area.handleWheel({
                x: 50, y: 20,
                angleDelta: Qt.point(0, 0),
                inverted: true,
                phase: Qt.ScrollEnd,
                device: { type: PointerDevice.TouchPad }
            });
            compare(area._touchpadDelta, 0);
            compare(root.ups, 0);
        }
    }
}
''')

        for folder in sorted((out / 'qs').rglob('*')):
            if not folder.is_dir():
                continue
            entries = []
            for qml in sorted(folder.glob('*.qml')):
                singleton = 'singleton ' if 'pragma Singleton' in qml.read_text() else ''
                entries.append(f'{singleton}{qml.stem} 1.0 {qml.name}')
            if entries:
                put(str(folder.relative_to(out) / 'qmldir'), '\n'.join(entries) + '\n')

        env = dict(os.environ, QT_QPA_PLATFORM='offscreen',
                   QT_QUICK_BACKEND='software', QT_QUICK_CONTROLS_STYLE='Basic')
        result = subprocess.run([runner, '-input', str(out / 'tests'),
                                 '-import', str(out)],
                                env=env, capture_output=True, text=True, timeout=60)
        print(result.stdout, end='')
        print(result.stderr, end='')
        raise SystemExit(result.returncode)


if __name__ == '__main__':
    main()
