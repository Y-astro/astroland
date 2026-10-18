import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.modules.settings.configs.colors

Item {
    id: colorsThemesRoot
    anchors.fill: parent

    property alias contentY: pageRoot.contentY
    property alias activeSubPage: subPageOverlay.activeSubPage

    ContentPage {
        id: pageRoot
        anchors.fill: parent
        forceWidth: false
        opacity: subPageOverlay.slideProgress

        // ── Wallpapers ──────────────────────────────────────────────────
        ColorsWallpaperHero {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
        }

        // ── Colour scheme ───────────────────────────────────────────────
        ColorsPalettePane {
            Layout.fillWidth: true
        }

        // ── Automation & integrations ───────────────────────────────────
        AppSettingsSection {
            Layout.topMargin: 12
            title: Translation.tr("Automation & integrations")
            symbol: "auto_awesome"

            Item {
                id: tiles
                Layout.fillWidth: true
                implicitHeight: tileFlow.implicitHeight

                readonly property int gap: 12
                readonly property int fits: Math.max(1, Math.floor((width + gap) / (300 + gap)))
                // Four tiles: one row of four, two of two or a column, never 3 + 1.
                readonly property int columns: fits >= 4 ? 4 : fits >= 2 ? 2 : 1
                readonly property int tileWidth: Math.floor((width - gap * (columns - 1)) / columns)
                readonly property int tileHeight: 200

                Flow {
                    id: tileFlow
                    width: parent.width
                    spacing: tiles.gap

                    ColorsFeatureTile {
                        width: tiles.tileWidth
                        height: tiles.tileHeight
                        symbol: "nightlight"
                        shapeOn: MaterialShape.Shape.Cookie12Sided
                        title: Translation.tr("Automatic dark mode")
                        summary: {
                            const light = Config.options.light;
                            const parts = [];
                            if (light.darkMode.automatic)
                                parts.push(Translation.tr("Dark %1–%2").arg(light.darkMode.from).arg(light.darkMode.to));
                            if (light.night.automatic)
                                parts.push(Translation.tr("Night Light %1–%2").arg(light.night.from).arg(light.night.to));
                            return parts.length > 0 ? parts.join(" · ")
                                : Translation.tr("Switch to dark mode and warm the screen on a schedule");
                        }
                        checked: Config.options.light.darkMode.automatic || Config.options.light.night.automatic
                        configurable: true
                        onConfigureRequested: colorsThemesRoot.activeSubPage = Qt.resolvedUrl("widgets/SchedulingConfig.qml")
                        onToggled: value => {
                            Config.options.light.darkMode.automatic = value;
                            Config.options.light.night.automatic = value;
                            if (!value)
                                Hyprsunset.disableTemperature();
                        }
                    }

                    ColorsFeatureTile {
                        id: themingTile
                        width: tiles.tileWidth
                        height: tiles.tileHeight
                        symbol: "format_color_fill"
                        shapeOn: MaterialShape.Shape.Flower
                        title: Translation.tr("App theming")
                        summary: Translation.tr("Wallpaper colors for the shell and utilities, Qt apps and terminals")
                        checked: Config.options.appearance.wallpaperTheming.enableAppsAndShell
                        onToggled: value => Config.options.appearance.wallpaperTheming.enableAppsAndShell = value

                        ColorsChip {
                            enabled: themingTile.checked
                            label: Translation.tr("Qt apps")
                            symbol: "widgets"
                            chosen: Config.options.appearance.wallpaperTheming.enableQtApps
                            colContent: themingTile.colContent
                            colChosen: Appearance.colors.colPrimary
                            colOnChosen: Appearance.colors.colOnPrimary
                            onClicked: Config.options.appearance.wallpaperTheming.enableQtApps = !chosen
                        }
                        ColorsChip {
                            enabled: themingTile.checked
                            label: Translation.tr("Terminal")
                            symbol: "terminal"
                            chosen: Config.options.appearance.wallpaperTheming.enableTerminal
                            colContent: themingTile.colContent
                            colChosen: Appearance.colors.colPrimary
                            colOnChosen: Appearance.colors.colOnPrimary
                            onClicked: Config.options.appearance.wallpaperTheming.enableTerminal = !chosen
                        }
                    }

                    ColorsFeatureTile {
                        width: tiles.tileWidth
                        height: tiles.tileHeight
                        symbol: "play_circle"
                        shapeOn: MaterialShape.Shape.SoftBurst
                        title: Translation.tr("Wallpaper Engine")
                        summary: Config.options.background.useWallpaperEngine && Config.options.background.wallpaperEngineId
                            ? Translation.tr("Playing Workshop item %1").arg(Config.options.background.wallpaperEngineId)
                            : Translation.tr("Animated wallpapers from the Steam Workshop")
                        checked: Config.options.background.useWallpaperEngine
                        configurable: true
                        onConfigureRequested: colorsThemesRoot.activeSubPage = Qt.resolvedUrl("widgets/WallpaperEngineConfig.qml")
                        onToggled: value => {
                            if (Config.options.background.useWallpaperEngine === value)
                                return;
                            Config.options.background.useWallpaperEngine = value;
                            Config.saveOptionsNow();
                            if (value && Config.options.background.wallpaperEngineId) {
                                Wallpapers.apply(Config.options.background.wallpaperEngineId);
                            } else if (!value) {
                                Quickshell.execDetached(["bash", "-c", "pkill -f linux-wallpaperengine; sleep 0.3; pkill -9 -f linux-wallpaperengine 2>/dev/null; true"]);
                                if (Config.options.background.wallpaperPath)
                                    Wallpapers.apply(Config.options.background.wallpaperPath);
                            }
                        }
                    }

                    ColorsFeatureTile {
                        width: tiles.tileWidth
                        height: tiles.tileHeight
                        symbol: "keyboard"
                        shapeOn: MaterialShape.Shape.Clover4Leaf
                        title: Translation.tr("OpenRGB integration")
                        summary: Translation.tr("Light your keyboard and peripherals with the palette")
                        checked: Config.options.appearance.openrgb.enable
                        configurable: true
                        onConfigureRequested: colorsThemesRoot.activeSubPage = Qt.resolvedUrl("widgets/OpenRGBConfig.qml")
                        onToggled: value => Config.options.appearance.openrgb.enable = value
                    }
                }
            }
        }

        // ── Wallpaper picker ────────────────────────────────────────────
        AppSettingsSection {
            Layout.topMargin: 12
            title: Translation.tr("Wallpaper picker")
            symbol: "imagesmode"

            AppChoiceRow {
                symbol: "folder_open"
                title: Translation.tr("Picker")
                description: Translation.tr("What opens when you change a wallpaper")
                options: [
                    { label: Translation.tr("Built-in"), value: false, icon: "grid_view" },
                    { label: Translation.tr("System dialog"), value: true, icon: "folder_shared" }
                ]
                currentValue: Config.options.wallpaperSelector.useSystemFileDialog
                onSelected: value => Config.options.wallpaperSelector.useSystemFileDialog = value
            }

            AppFieldRow {
                symbol: "download"
                title: Translation.tr("Download folder")
                description: Translation.tr("Where the wallpaper browser saves images")
                placeholder: Translation.tr("Download path...")
                value: Config.options.wallpapers.paths.download
                onEdited: text => Config.options.wallpapers.paths.download = text
            }
        }

        // ── Jinzhou Resonance Theme (WuWa) ──────────────────────────────
        AppSettingsSection {
            Layout.topMargin: 12
            title: Translation.tr("Resonance Theme (WuWa)")
            symbol: "waves"

            AppToggleRow {
                symbol: "spark"
                title: Translation.tr("Enable Jinzhou Resonance theme")
                description: Translation.tr("Apply antique gold, misty teal glass, and ivory accents to opted-in bar and media components (desktop widgets can opt in independently)")
                checked: Config.options.appearance.wuwaTheme.enabled
                onToggled: value => Config.options.appearance.wuwaTheme.enabled = value
            }

            AppChoiceRow {
                symbol: "palette"
                title: Translation.tr("Palette mode")
                description: Translation.tr("Fixed authentic Jinzhou palette or dynamic wallpaper-derived scheme")
                options: [
                    { label: Translation.tr("Fixed (WuWa)"), value: "fixed", icon: "colorize" },
                    { label: Translation.tr("Theme adaptive"), value: "theme", icon: "wallpaper" }
                ]
                currentValue: Config.options.appearance.wuwaTheme.paletteMode ?? "fixed"
                onSelected: value => Config.options.appearance.wuwaTheme.paletteMode = value
            }

            AppChoiceRow {
                symbol: "motion_photos_on"
                title: Translation.tr("Motion mode")
                description: Appearance.reducedMotion
                    ? Translation.tr("Forced to Off by global reduced-motion preference")
                    : Translation.tr("Frequency animations and fluid breathing dynamics")
                options: [
                    { label: Translation.tr("Normal"), value: "normal", icon: "play_arrow" },
                    { label: Translation.tr("Ambient"), value: "ambient", icon: "air" },
                    { label: Translation.tr("Off"), value: "off", icon: "block" }
                ]
                currentValue: Config.options.appearance.wuwaTheme.motionMode ?? "normal"
                onSelected: value => Config.options.appearance.wuwaTheme.motionMode = value
            }

            AppChoiceRow {
                symbol: "opacity"
                title: Translation.tr("Theme intensity")
                description: Translation.tr("Glass density, hairline prominence, and accent saturation")
                options: [
                    { label: Translation.tr("Subtle (60%)"), value: 0.60, icon: "exposure_neg_1" },
                    { label: Translation.tr("Restrained (85%)"), value: 0.85, icon: "contrast" },
                    { label: Translation.tr("Vivid (100%)"), value: 1.00, icon: "exposure_plus_1" }
                ]
                currentValue: {
                    const raw = Number(Config.options.appearance.wuwaTheme.intensity ?? 0.85);
                    if (raw <= 0.70) return 0.60;
                    if (raw >= 0.95) return 1.00;
                    return 0.85;
                }
                onSelected: value => Config.options.appearance.wuwaTheme.intensity = value
            }
        }
    }

    ConfigSubPageHost {
        id: subPageOverlay
        anchors.fill: parent
        z: 10
    }
}
