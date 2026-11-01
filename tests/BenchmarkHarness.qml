import QtQuick
import Quickshell

FloatingWindow {
    id: win
    width: 1920
    height: 1200
    visible: true
    color: "black"

    // Parameters set via command line or env
    property string testMode: Quickshell.env("TEST_MODE") || "unbounded" // unbounded or bounded
    property string wallpaperListJson: Quickshell.env("WALLPAPER_LIST") || "[]"
    property var wallpapers: JSON.parse(wallpaperListJson)
    property int currentIndex: 0
    property bool warmPhase: false

    property var results: []

    // Frame timing tracking
    property real lastFrameTime: 0
    property real maxFrameTimeDuringSwitch: 0
    property int droppedFramesDuringSwitch: 0
    property bool isSwitching: false
    property real switchStartTime: 0

    FrameAnimation {
        running: true
        onTriggered: {
            const now = Date.now()
            if (win.lastFrameTime > 0) {
                const dt = now - win.lastFrameTime
                if (win.isSwitching) {
                    if (dt > win.maxFrameTimeDuringSwitch) {
                        win.maxFrameTimeDuringSwitch = dt
                    }
                    if (dt > 12.0) { // At 165Hz (6ms), >12ms is 2+ dropped frames
                        win.droppedFramesDuringSwitch += Math.floor(dt / 6.06) - 1
                    }
                }
            }
            win.lastFrameTime = now
        }
    }

    // A rotating spinner to continuously drive frames on the render thread
    Rectangle {
        id: spinner
        width: 100
        height: 100
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 20
        color: "transparent"
        border.color: "cyan"
        border.width: 4
        z: 999
        RotationAnimation on rotation {
            from: 0; to: 360; duration: 500; loops: Animation.Infinite
        }
    }

    readonly property size boundedSourceSize: Qt.size(
        Math.ceil(win.width * Screen.devicePixelRatio),
        Math.ceil(win.height * Screen.devicePixelRatio)
    )

    Image {
        id: previousImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        cache: true
        mipmap: true
        smooth: true
        layer.enabled: true
        sourceSize: win.testMode === "bounded" ? win.boundedSourceSize : Qt.size(0, 0)
    }

    Image {
        id: currentImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        cache: true
        mipmap: true
        smooth: true
        asynchronous: true
        layer.enabled: true
        sourceSize: win.testMode === "bounded" ? win.boundedSourceSize : Qt.size(0, 0)

        property real transitionProgress: 1.0

        onStatusChanged: {
            if (status === Image.Ready) {
                const readyTime = Date.now()
                const decodeMs = readyTime - win.switchStartTime
                
                // Trigger transition animation
                transitionAnim.restart()
            }
        }
    }

    NumberAnimation {
        id: transitionAnim
        target: currentImage
        property: "transitionProgress"
        from: 0.0
        to: 1.0
        duration: 500
        easing.type: Easing.InOutQuad
        onFinished: {
            const finishTime = Date.now()
            const totalMs = finishTime - win.switchStartTime
            win.isSwitching = false

            win.results.push({
                file: win.wallpapers[win.currentIndex],
                mode: win.testMode,
                phase: win.warmPhase ? "warm" : "cold",
                decodeTimeMs: finishTime - win.switchStartTime - 500,
                totalTimeMs: totalMs,
                maxFrameDeltaMs: win.maxFrameTimeDuringSwitch,
                droppedFrames: win.droppedFramesDuringSwitch,
                paintedSize: `${currentImage.paintedWidth}x${currentImage.paintedHeight}`,
                implicitSize: `${currentImage.implicitWidth}x${currentImage.implicitHeight}`
            })

            // Next test after brief pause
            nextTimer.interval = 100
            nextTimer.restart()
        }
    }

    Timer {
        id: nextTimer
        onTriggered: {
            win.currentIndex++
            if (win.currentIndex >= win.wallpapers.length) {
                if (!win.warmPhase) {
                    // Start warm phase: re-test all wallpapers to test cache hit behavior
                    win.warmPhase = true
                    win.currentIndex = 0
                    runCurrentTest()
                } else {
                    // All done! Output results
                    console.log("BENCHMARK_RESULTS_JSON:" + JSON.stringify(win.results))
                    Qt.quit()
                }
            } else {
                runCurrentTest()
            }
        }
    }

    function runCurrentTest() {
        if (win.currentIndex >= win.wallpapers.length) return
        const path = win.wallpapers[win.currentIndex]
        
        // Setup previous image
        previousImage.source = currentImage.source
        
        // Start switch measurement
        win.maxFrameTimeDuringSwitch = 0
        win.droppedFramesDuringSwitch = 0
        win.isSwitching = true
        win.switchStartTime = Date.now()
        currentImage.transitionProgress = 0.0
        currentImage.source = "file://" + path
    }

    Component.onCompleted: {
        if (win.wallpapers.length === 0) {
            console.log("No wallpapers provided.")
            Qt.quit()
            return
        }
        // Small delay to let window show up and stabilize
        startupTimer.restart()
    }

    Timer {
        id: startupTimer
        interval: 300
        onTriggered: win.runCurrentTest()
    }
}
