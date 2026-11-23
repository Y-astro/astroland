# QuickShell Thermal and CPU Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Eliminate high CPU usage, thread leaks, and unnecessary rendering in QuickShell (`end4-pC`) to significantly reduce laptop heat and thermal load.

**Architecture:** 
1. Fix socket connection handling in `kdeconnect_adb_tunnel.py` by replacing unbound blocking reads with explicit socket timeouts, clean bidirectional shutdown, and bounded worker threads.
2. Optimize the audio visualizer pipeline by tuning `cava` sample rate and gating `GlobalStates.visualizerPoints` updates in `MediaControls.qml` so bindings only dirty the scene graph when a visualizer component is actively displayed.
3. Add failure backoff to `ResourceUsage.qml`'s GPU monitor process so NVML driver mismatches do not repeatedly spawn failing sub-processes.

**Tech Stack:** Python 3, QML (QtQuick / Quickshell), `cava`, `unittest`

**Spec:** In-session thermal investigation report (investigation of `qs -c end4-pC` burning 86% CPU, leaking 1,753 threads, and driving 165 Hz Hyprland compositing).

## Global Constraints

- Do not alter existing external behavior or break KDE Connect ADB tunneling.
- Keep the diffs minimal and maintain existing project style and architecture.
- All Python scripts must run cleanly without external dependencies outside the standard library (`socket`, `select`, `threading`, `time`).
- Do not remove user features: visualizers must continue working when active media views are open.

## Review Focus

1. **Thread cleanup:** Sockets closing from either client or remote end must cleanly terminate both reader/writer threads without leaking `threading.Thread` instances.
2. **Tunnel reconnect:** ADB disconnects and reconnects must reset and clean up existing proxy sockets cleanly.
3. **Visualizer responsiveness:** Lowering visualizer rate must retain smooth visual appearance while reducing compositor load.
4. **Binding storms:** Setting `GlobalStates.visualizerPoints` must not trigger when no visible UI element is rendering bars.
5. **GPU polling resilience:** NVML / driver mismatch must not cause infinite retry loops.

---

### Task 1: Fix Thread and Socket Leak in `kdeconnect_adb_tunnel.py`

**Files:**
- Modify: `/home/astro/.config/quickshell/end4-pC/scripts/phone/kdeconnect_adb_tunnel.py`
- Test: `/home/astro/.config/quickshell/end4-pC/tests/test_kdeconnect_adb_tunnel.py`

- [ ] **Step 1: Write a reproduction test for thread leak under connection churn**
  Create `tests/test_kdeconnect_adb_tunnel.py` using `unittest`. The test sets up a mock TCP echo/sink server, initializes `TcpProxyServer`, connects and disconnects 20 clients sequentially, and asserts that active thread count returns to baseline (`<= 2` threads above main thread).

- [ ] **Step 2: Run test to observe baseline behavior / leak**
  Run: `python3 -m unittest /home/astro/.config/quickshell/end4-pC/tests/test_kdeconnect_adb_tunnel.py`
  Confirm that threads leak or remain blocked in `recv()`.

- [ ] **Step 3: Implement clean socket shutdown and bounded thread lifecycle**
  In `scripts/phone/kdeconnect_adb_tunnel.py`:
  - Set reasonable timeouts on `client_sock` and `remote_sock` (e.g. 5 seconds for connect/keepalive).
  - In `pipe(src, dst)`: when `src.recv()` returns 0 or throws an error, explicitly invoke `dst.shutdown(socket.SHUT_RDWR)` before closing both sockets. This immediately wakes up the sibling thread blocking on `dst.recv()`.
  - In `_handle_client`: add a timeout to `t1.join(timeout=2.0)` and `t2.join(timeout=2.0)`.
  - Ensure all opened sockets are closed in a guaranteed `finally:` block.

- [ ] **Step 4: Verify test passes with zero thread leaks**
  Run: `python3 -m unittest /home/astro/.config/quickshell/end4-pC/tests/test_kdeconnect_adb_tunnel.py`
  Verify all 20 client churn connections cleanly terminate threads without hanging.

- [ ] **Step 5: Commit Task 1**
  Run: `cd /home/astro/.config/quickshell/end4-pC && git add scripts/phone/kdeconnect_adb_tunnel.py tests/test_kdeconnect_adb_tunnel.py && git commit -m "fix(phone): prevent thread and socket leak in kdeconnect adb tunnel"`

---

### Task 2: Optimize Visualizer Pipeline in `cava` and `MediaControls.qml`

**Files:**
- Modify: `/home/astro/.config/quickshell/end4-pC/scripts/cava/raw_output_config.txt:3-4`
- Modify: `/home/astro/.config/quickshell/end4-pC/modules/ii/mediaControls/MediaControls.qml:80-135`

- [ ] **Step 1: Reduce Cava Frame Rate in Config**
  In `/home/astro/.config/quickshell/end4-pC/scripts/cava/raw_output_config.txt`:
  Change `framerate = 60` to `framerate = 30`. 30 FPS provides fluid visualizer animation while cutting pipe I/O and UI parser invocation by 50%.

- [ ] **Step 2: Gate Visualizer Point Processing in `MediaControls.qml`**
  In `MediaControls.qml`:
  - Verify if any visualizer consumer is currently visible before updating `GlobalStates.visualizerPoints`.
  - Define a boolean property `visualizerVisible`:
    ```qml
    readonly property bool hasActiveVisualizerSurface: GlobalStates.mediaControlsOpen ||
        GlobalStates.sidebarRightOpen ||
        (GlobalStates.sidebarLeftOpen && !GlobalStates.mediaLyricsVisible) ||
        GlobalStates.equalizerOpen ||
        Config.options.background.widgets.visualizer.enable ||
        Config.options.background.widgets.visualizer2.enable ||
        Config.options.bar.layouts.leftLayout.includes("visualizer") ||
        Config.options.bar.layouts.middleLayout.includes("visualizer") ||
        Config.options.bar.layouts.rightLayout.includes("visualizer")
    ```
  - In `stdout.onRead`: Only parse and assign `GlobalStates.visualizerPoints = points` if `hasActiveVisualizerSurface` is true. If false and points were not zero, assign `[]` once and pause processing.

- [ ] **Step 3: Verify syntax and behavior**
  Verify QML syntax by running `quickshell --check` or testing configuration load.

- [ ] **Step 4: Commit Task 2**
  Run: `cd /home/astro/.config/quickshell/end4-pC && git add scripts/cava/raw_output_config.txt modules/ii/mediaControls/MediaControls.qml && git commit -m "perf(visualizer): throttle cava framerate and gate visualizer updates to active surfaces"`

---

### Task 3: Add Backoff for NVIDIA NVML Driver Mismatch in `ResourceUsage.qml`

**Files:**
- Modify: `/home/astro/.config/quickshell/end4-pC/services/ResourceUsage.qml`

- [ ] **Step 1: Check driver mismatch failure in `gpuMonitorProc`**
  In `ResourceUsage.qml`:
  - Add a failure counter / backoff state: `property int nvidiaFailureCount: 0`.
  - If `nvidia-smi` produces output containing `version mismatch` or fails consecutively, set `nvidiaFailureCount` and skip running `nvidia-smi` every tick (e.g., scale polling interval to once every 60 seconds instead of standard 2–3s interval).
  - Clear `gpuUsage` and `gpuTemp` safely without crashing or spinning CPU.

- [ ] **Step 2: Verify QML syntax**
  Check that QML parses cleanly and no binding loops are introduced.

- [ ] **Step 3: Commit Task 3**
  Run: `cd /home/astro/.config/quickshell/end4-pC && git add services/ResourceUsage.qml && git commit -m "fix(resources): add failure backoff for nvidia nvml driver mismatch"`

---

### Task 4: Validation and Performance Verification

- [ ] **Step 1: Restart / Reload QuickShell**
  Restart the QuickShell service (`systemctl --user restart quickshell` or `qs -c end4-pC`).

- [ ] **Step 2: Measure CPU and Thread Usage**
  Run `top -b -n 2 -d 1` and check PID of `qs` and python child processes:
  - Verify that `kdeconnect_adb_tunnel.py` maintains `<= 5` threads over time.
  - Verify that `qs` CPU drops from ~87% down to normal desktop idle levels (<10% during media playback, <2% idle).
  - Verify Hyprland CPU load drops correspondingly.
