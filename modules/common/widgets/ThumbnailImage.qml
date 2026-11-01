import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

/**
 * Thumbnail image. It currently generates to the right place at the right size, but does not handle metadata/maintenance on modification.
 * See Freedesktop's spec: https://specifications.freedesktop.org/thumbnail-spec/thumbnail-spec-latest.html
 */
StyledImage {
    id: root

    property bool generateThumbnail: true
    required property string sourcePath
    readonly property real thumbnailDevicePixelRatio: (QsWindow.window as QsWindow)?.devicePixelRatio ?? 1
    property string thumbnailSizeName: Images.thumbnailSizeNameForDimensions(
        Math.max(1, Math.ceil(width * thumbnailDevicePixelRatio)),
        Math.max(1, Math.ceil(height * thumbnailDevicePixelRatio))
    )
    readonly property bool sourceIsVideo: /\.(mp4|mkv|webm|avi|mov|m4v|ogv|gif)$/i.test(sourcePath)
    property var thumbnailService: null
    readonly property bool thumbnailGenerationRunning: thumbnailGeneration.running
    property bool reloadRequested: false
    property string thumbnailPath: {
        if (sourcePath.length == 0)
            return "";
        const resolvedUrlWithoutFileProtocol = FileUtils.trimFileProtocol(`${Qt.resolvedUrl(sourcePath)}`);
        const encodedUrlWithoutFileProtocol = resolvedUrlWithoutFileProtocol.split("/").map(part => encodeURIComponent(part)).join("/");
        const md5Hash = Qt.md5(`file://${encodedUrlWithoutFileProtocol}`);
        return `${Directories.genericCache}/thumbnails/${thumbnailSizeName}/${md5Hash}.png`;
    }
    source: reloadRequested ? "" : thumbnailPath

    asynchronous: true
    smooth: true
    mipmap: false

    opacity: status === Image.Ready ? 1 : 0
    Behavior on opacity {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    // Generated lazily: only when the thumbnail fails to load, once per thumbnail path,
    // and not while the service's folder run may still make it. A card whose thumbnail
    // exists spawns nothing, which matters for grids of thousands of wallpapers.
    property string attemptedThumbnailPath: ""
    readonly property bool serviceMayGenerate: root.thumbnailService !== null
        && (root.thumbnailService.thumbnailGenerationRunning ?? false)

    function startThumbnailGeneration() {
        if (!root.generateThumbnail || root.thumbnailPath.length === 0
                || root.status !== Image.Error || root.serviceMayGenerate
                || root.attemptedThumbnailPath === root.thumbnailPath)
            return;
        root.attemptedThumbnailPath = root.thumbnailPath;
        thumbnailGeneration.running = false;
        thumbnailGeneration.running = true;
    }

    onStatusChanged: if (status === Image.Error) root.startThumbnailGeneration()
    onGenerateThumbnailChanged: root.startThumbnailGeneration()

    function reloadThumbnail() {
        if (!root.thumbnailPath)
            return;

        root.cache = false;
        root.reloadRequested = true;
        Qt.callLater(function() {
            root.reloadRequested = false;
            root.cache = true;
        });
    }

    Connections {
        target: root.thumbnailService
        enabled: root.thumbnailService !== null
        ignoreUnknownSignals: true

        // Files the run made were reloaded one by one; at the end only a card still
        // without its thumbnail needs another look (or its own generation).
        function onThumbnailGenerated(directory) {
            if (root.status === Image.Ready)
                return;
            if (FileUtils.parentDirectory(root.sourcePath) === FileUtils.trimFileProtocol(directory))
                root.reloadThumbnail();
            else
                root.startThumbnailGeneration();
        }

        function onThumbnailGeneratedFile(filePath) {
            if (FileUtils.trimFileProtocol(root.sourcePath) === filePath)
                root.reloadThumbnail();
        }
    }

    Process {
        id: thumbnailGeneration
        command: {
            if (!root.generateThumbnail || root.sourcePath.length === 0)
                return ["true"];

            const maxSize = Images.thumbnailSizes[root.thumbnailSizeName];
            const thumbPath = FileUtils.trimFileProtocol(root.thumbnailPath);
            const srcPath = FileUtils.trimFileProtocol(root.sourcePath);

            if (root.sourceIsVideo) {
                return ["bash", "-c", `
                    thumb="$1"; src="$2"; max="$3"
                    mkdir -p "\${thumb%/*}"
                    [ -f "$thumb" ] && exit 0
                    command -v ffmpeg >/dev/null 2>&1 || exit 2
                    tmp="$thumb.$$.tmp.png"
                    trap 'kill "$pid" 2>/dev/null; rm -f "$tmp"' EXIT
                    ffmpeg -v error -y -i "$src" -frames:v 1 -vf "scale=$max:$max:force_original_aspect_ratio=decrease" -f image2 -c:v png "$tmp" & pid=$!
                    wait "$pid" && mv "$tmp" "$thumb" && exit 1
                    exit 2
                `, "_", thumbPath, srcPath, `${maxSize}`];
            }

            return ["bash", "-c", `
                thumb="$1"; src="$2"; max="$3"
                mkdir -p "\${thumb%/*}"
                [ -f "$thumb" ] && exit 0
                tmp="$thumb.$$.tmp.png"
                trap 'kill "$pid" 2>/dev/null; rm -f "$tmp"' EXIT
                magick "$src" -resize "$max"x"$max" "$tmp" & pid=$!
                wait "$pid" && mv "$tmp" "$thumb" && exit 1
                exit 2
            `, "_", thumbPath, srcPath, `${maxSize}`];
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 1) { // Force reload if thumbnail had to be generated
                root.reloadThumbnail();
            }
        }
    }
}
