import QtQuick
import Quickshell
import Qt5Compat.GraphicalEffects

FloatingWindow {
    id: win
    width: 1920
    height: 1200
    visible: true
    color: "black"

    property string testMode: Quickshell.env("TEST_MODE") || "unbounded" // unbounded or bounded
    property string testWallpaper: Quickshell.env("TEST_WALLPAPER") || ""
    property string prevWallpaper: Quickshell.env("PREV_WALLPAPER") || ""
    property real testProgress: parseFloat(Quickshell.env("TEST_PROGRESS") || "1.0")
    property string testShader: Quickshell.env("TEST_SHADER") || "pixelate"
    property string testEffect: Quickshell.env("TEST_EFFECT") || "none" // none, fastblur, gaussianblur, visualizer
    property string outputPath: Quickshell.env("OUTPUT_PATH") || "/tmp/visual_test.png"

    readonly property size boundedSourceSize: Qt.size(
        Math.ceil(win.width * Screen.devicePixelRatio),
        Math.ceil(win.height * Screen.devicePixelRatio)
    )

    Item {
        id: rootSurface
        anchors.fill: parent

        Image {
            id: previousWallpaper
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            cache: true
            mipmap: true
            smooth: true
            layer.enabled: true
            visible: true
            sourceSize: win.testMode === "bounded" ? win.boundedSourceSize : Qt.size(0, 0)
            source: win.prevWallpaper !== "" ? "file://" + win.prevWallpaper : ""
        }

        Image {
            id: wallpaper
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            cache: true
            smooth: true
            mipmap: true
            asynchronous: false
            layer.enabled: true
            visible: win.testProgress >= 1.0 && win.testEffect !== "fastblur" && win.testEffect !== "gaussianblur"
            sourceSize: win.testMode === "bounded" ? win.boundedSourceSize : Qt.size(0, 0)
            source: win.testWallpaper !== "" ? "file://" + win.testWallpaper : ""
        }

        ShaderEffect {
            id: transitionEffect
            anchors.fill: parent
            visible: win.testProgress < 1.0 && win.testEffect !== "fastblur" && win.testEffect !== "gaussianblur"

            property var fromImage: previousWallpaper
            property var toImage: wallpaper
            property var source1: previousWallpaper
            property var source2: wallpaper
            property real time: 0.5
            property real progress: win.testProgress
            property real aspectX: width / height
            property real aspectY: 1.0
            property vector2d aspectRatio: Qt.vector2d(aspectX, aspectY)
            property vector2d origin: Qt.vector2d(0.5, 0.5)

            fragmentShader: Qt.resolvedUrl(`../modules/ii/background/shaders/${win.testShader}.frag.qsb`)
        }

        // FastBlur effect test
        FastBlur {
            id: fastBlurItem
            anchors.fill: parent
            visible: win.testEffect === "fastblur"
            source: win.testProgress >= 1.0 ? wallpaper : transitionEffect
            radius: 48
        }

        // GaussianBlur effect test
        GaussianBlur {
            id: gaussianBlurItem
            anchors.fill: parent
            visible: win.testEffect === "gaussianblur"
            source: win.testProgress >= 1.0 ? wallpaper : transitionEffect
            radius: 40
            samples: 24
        }
    }

    Timer {
        interval: 400
        running: true
        onTriggered: {
            rootSurface.grabToImage(function(result) {
                result.saveToFile(win.outputPath)
                console.log("VISUAL_CAPTURE_SAVED:" + win.outputPath)
                Qt.quit()
            })
        }
    }
}
