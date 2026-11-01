import QtQuick
import Quickshell
import Qt5Compat.GraphicalEffects

FloatingWindow {
    id: win
    width: 1920
    height: 1200
    visible: true
    color: "#0f111a"

    property var wallpapers: [
        "/home/astro/Pictures/Wallpapers/wallhaven-k8d7j7.jpg",                                // Native
        "/home/astro/Pictures/Wallpapers/1378781.png",                                         // 4K
        "/home/astro/Pictures/Wallpapers/wallpaperflare.com_wallpaper_upscayl_3x_digital-art-4x.png", // 8K
        "/home/astro/Pictures/Wallpapers/wallhaven-lydkg2.jpg",                                // Ultrawide
        "/home/astro/Pictures/Wallpapers/test_portrait_2160x3840.png"                          // Portrait
    ]

    property var shaders: ["pixelate", "dissolve", "ripple", "Doom", "circlePit"]
    property int currentIdx: 0

    readonly property size boundedSourceSize: Qt.size(
        Math.ceil(win.width * Screen.devicePixelRatio),
        Math.ceil(win.height * Screen.devicePixelRatio)
    )

    Item {
        id: surface
        anchors.fill: parent

        Image {
            id: previousWallpaper
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            cache: true
            mipmap: true
            smooth: true
            layer.enabled: true
            sourceSize: win.boundedSourceSize
            source: ""
        }

        Image {
            id: wallpaper
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            cache: true
            smooth: true
            mipmap: true
            asynchronous: true
            layer.enabled: true
            sourceSize: win.boundedSourceSize
            source: win.wallpapers[0]
            visible: transitionAnim.running ? false : true

            onStatusChanged: {
                if (status === Image.Ready && switchPending) {
                    switchPending = false
                    transitionAnim.restart()
                }
            }
        }

        ShaderEffect {
            id: transitionEffect
            anchors.fill: parent
            visible: transitionAnim.running

            property var fromImage: previousWallpaper
            property var toImage: wallpaper
            property var source1: previousWallpaper
            property var source2: wallpaper
            property real time: 0.0
            property real progress: transitionProgress
            property real aspectX: width / height
            property real aspectY: 1.0
            property vector2d aspectRatio: Qt.vector2d(aspectX, aspectY)
            property vector2d origin: Qt.vector2d(0.5, 0.5)

            fragmentShader: Qt.resolvedUrl(`../modules/ii/background/shaders/${win.shaders[win.currentIdx % win.shaders.length]}.frag.qsb`)

            Timer {
                interval: 16
                repeat: true
                running: transitionEffect.visible
                onTriggered: transitionEffect.time += 0.016
            }
        }

        // Live Simulated Audio Visualizer (Fluid bars) at the bottom
        Row {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6
            Repeater {
                model: 48
                Rectangle {
                    required property int index
                    width: 10
                    radius: 5
                    color: Qt.hsla((index / 48.0) * 0.8 + 0.5, 0.75, 0.65, 0.85)
                    
                    property real hVal: 30
                    height: hVal
                    Behavior on height {
                        NumberAnimation { duration: 80; easing.type: Easing.OutQuad }
                    }
                }
            }
        }

        Timer {
            interval: 80
            running: true
            repeat: true
            onTriggered: {
                // Animate bars
                for (let i = 0; i < 48; i++) {
                    const rowChild = surface.children[3].children[i]
                    if (rowChild) {
                        rowChild.hVal = 20 + Math.random() * 120
                    }
                }
            }
        }
    }

    property real transitionProgress: 1.0
    property bool switchPending: false

    NumberAnimation {
        id: transitionAnim
        target: win
        property: "transitionProgress"
        from: 0.0
        to: 1.0
        duration: 1000
        easing.type: Easing.InOutQuad
        onFinished: {
            previousWallpaper.source = wallpaper.source
            transitionProgress = 1.0
        }
    }

    function doSwitch() {
        win.currentIdx++
        if (win.currentIdx >= win.wallpapers.length) {
            console.log("DEMO_FINISHED")
            Qt.quit()
            return
        }
        previousWallpaper.source = wallpaper.source
        switchPending = true
        transitionProgress = 0.0
        wallpaper.source = win.wallpapers[win.currentIdx]
    }

    Timer {
        id: switchCycleTimer
        interval: 1800
        repeat: true
        running: true
        onTriggered: win.doSwitch()
    }
}
