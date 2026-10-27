import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.ii.background.widgets
import "."

Rectangle {
    id: root
    required property var screen
    signal dragBy(real dx, real dy)
    property string query: ""
    property bool showingOptions: false
    property var collapsedCategories: ({})
    readonly property var instance: (Config.options.background.activeWidgets ?? []).find(entry => (entry.id ?? entry.instanceId) === GlobalStates.editWidgetInstanceId)
    readonly property var entry: GlobalStates.editWidgetInstanceId ? root.instance : Config.options.background.widgets[GlobalStates.editWidgetKey]
    readonly property var metadata: root.instance ? WidgetsRegistry.getWidgetMetadata(root.instance.widgetId) : null
    readonly property var legacy: LegacyWidgetCatalog.widgets.find(entry => entry.id === GlobalStates.editWidgetKey)
    readonly property string selectionName: (root.metadata ? root.metadata.name : "") || (root.legacy ? root.legacy.name : "") || ""

    readonly property bool isSettingsScope: true
    readonly property bool isWuWa: SettingsTheme.isWuWa
    readonly property alias catalogFlickable: catalogFlickable

    function normalizeCategory(cat) {
        if (!cat) return "Other";
        const c = String(cat).trim();
        const lower = c.toLowerCase();
        if (lower === "clock") return "Clock";
        if (lower === "date") return "Date";
        if (lower === "weather") return "Weather";
        if (lower === "productivity" || lower === "utility") return "Productivity";
        if (lower === "media") return "Media";
        if (lower === "system") return "System";
        if (lower === "resources") return "Resources";
        if (lower === "devices") return "Devices";
        if (lower === "images" || lower === "photo" || lower === "photos" || lower === "image") return "Photos";
        return c;
    }

    function displayCategory(normCat) {
        if (normCat === "Clock") return qsTr("Clocks");
        if (normCat === "Date") return qsTr("Date");
        if (normCat === "Weather") return qsTr("Weather");
        if (normCat === "Media") return qsTr("Media");
        if (normCat === "System") return qsTr("System");
        if (normCat === "Resources") return qsTr("Resources");
        if (normCat === "Devices") return qsTr("Devices");
        if (normCat === "Productivity") return qsTr("Productivity");
        if (normCat === "Photos") return qsTr("Photos");
        return normCat;
    }

    function categoryIcon(normCat) {
        if (normCat === "Clock" || normCat === "Clocks") return "schedule";
        if (normCat === "Date") return "calendar_month";
        if (normCat === "Weather") return "cloud";
        if (normCat === "Media") return "music_note";
        if (normCat === "System") return "settings";
        if (normCat === "Resources") return "monitor_heart";
        if (normCat === "Devices") return "devices";
        if (normCat === "Productivity") return "checklist";
        if (normCat === "Photos" || normCat === "Images") return "photo";
        return "widgets";
    }

    readonly property var categoryOrder: [
        "Clock",
        "Date",
        "Weather",
        "Media",
        "System",
        "Resources",
        "Devices",
        "Productivity",
        "Photos",
        "Other"
    ]

    function toggleCategory(cat) {
        const copy = Object.assign({}, root.collapsedCategories);
        if (copy[cat]) delete copy[cat];
        else copy[cat] = true;
        root.collapsedCategories = copy;
    }

    readonly property var catalog: {
        const legacyItems = LegacyWidgetCatalog.widgets.map(w => {
            const norm = root.normalizeCategory(w.category);
            return Object.assign({}, w, {
                legacy: true,
                normalizedCategory: norm,
                displayCategory: root.displayCategory(norm)
            });
        });
        const registryItems = WidgetsRegistry.allWidgets.map(w => {
            const norm = root.normalizeCategory(w.category);
            return Object.assign({}, w, {
                id: w.widgetId,
                legacy: false,
                normalizedCategory: norm,
                displayCategory: root.displayCategory(norm)
            });
        });
        return legacyItems.concat(registryItems);
    }

    readonly property var categoriesModel: {
        const q = (root.query || "").trim().toLowerCase();
        const all = root.catalog;
        const groups = {};
        for (let i = 0; i < all.length; i++) {
            const w = all[i];
            const norm = w.normalizedCategory || "Other";
            if (!groups[norm]) {
                groups[norm] = {
                    key: norm,
                    title: root.displayCategory(norm),
                    icon: root.categoryIcon(norm),
                    widgets: []
                };
            }
            if (!q) {
                groups[norm].widgets.push(w);
            } else {
                const searchString = (w.name + " " + (w.description || "") + " " + (w.category || "") + " " + norm + " " + w.displayCategory).toLowerCase();
                if (searchString.includes(q)) {
                    groups[norm].widgets.push(w);
                }
            }
        }

        const result = [];
        for (let i = 0; i < root.categoryOrder.length; i++) {
            const key = root.categoryOrder[i];
            if (groups[key] && groups[key].widgets.length > 0) {
                groups[key].widgets.sort((a, b) => a.name.localeCompare(b.name));
                result.push(groups[key]);
                delete groups[key];
            }
        }
        const remainingKeys = Object.keys(groups).sort();
        for (let i = 0; i < remainingKeys.length; i++) {
            const key = remainingKeys[i];
            if (groups[key].widgets.length > 0) {
                groups[key].widgets.sort((a, b) => a.name.localeCompare(b.name));
                result.push(groups[key]);
            }
        }
        return result;
    }

    color: isWuWa ? SettingsTheme.colWindowShell : Appearance.colors.colLayer0
    radius: Appearance.rounding.large
    border.width: isWuWa ? 1 : 0
    border.color: isWuWa ? SettingsTheme.colWindowBorder : (Appearance.colors.colLayer0Border ?? "transparent")
    clip: true

    function setPosition(key, value) {
        if (!root.entry) return;
        if (GlobalStates.editWidgetInstanceId)
            Config.options.background.activeWidgets = Config.options.background.activeWidgets.map(entry => entry.id === GlobalStates.editWidgetInstanceId ? Object.assign({}, entry, { [key]: value }) : entry);
        else root.entry[key] = value;
    }
    function selectOrAdd(widget) {
        if (widget.legacy) {
            const cfg = Config.options.background.widgets[widget.id];
            if (cfg && cfg.enable) {
                GlobalStates.selectEditWidget(widget.id, "", widget.id);
            } else {
                root.add(widget);
            }
            return;
        }
        const activeList = Config.options.background.activeWidgets ?? [];
        const matching = activeList.filter(entry => (entry.widgetId ?? entry.id) === widget.id);
        if (matching.length === 0) {
            root.add(widget);
            return;
        }
        let target = matching.find(entry => (entry.id ?? entry.instanceId) === GlobalStates.editWidgetInstanceId);
        if (!target) {
            const currentMonitor = root.screen ? root.screen.name : (GlobalStates.editModeMonitorName || "");
            target = matching.find(entry => !entry.monitorName || entry.monitorName === currentMonitor);
        }
        if (!target) target = matching[0];
        const targetId = String(target.id ?? target.instanceId ?? "");
        GlobalStates.selectEditWidget(targetId, targetId, widget.id);
    }
    function add(widget) {
        if (widget.legacy) {
            const cfg = Config.options.background.widgets[widget.id];
            cfg.enable = true;
            GlobalStates.selectEditWidget(widget.id, "", widget.id);
        } else {
            const id = widget.id + "-" + Date.now().toString(36) + "-" + Math.random().toString(36).slice(2, 6);
            Config.options.background.activeWidgets = (Config.options.background.activeWidgets ?? []).concat([{
                id: id, widgetId: widget.id, x: Math.max(24, root.screen.width / 3 - 150), y: Math.max(72, root.screen.height / 3 - 120),
                z: 10, placementStrategy: "free", monitorName: root.screen.name, lockBehavior: "keep", pinned: false
            }]);
            GlobalStates.selectEditWidget(id, id, widget.id);
        }
    }
    function removeSelection() {
        const instanceId = GlobalStates.editWidgetInstanceId;
        if (instanceId) {
            Config.options.background.activeWidgets = (Config.options.background.activeWidgets ?? []).filter(entry => (entry.id ?? entry.instanceId) !== instanceId);
        } else if (root.entry) {
            root.entry.enable = false;
        }
        GlobalStates.selectEditWidget("", "", "");
    }
    function duplicate() {
        if (!root.instance) return;
        const id = root.instance.widgetId + "-" + Date.now().toString(36) + "-" + Math.random().toString(36).slice(2, 6);
        const copy = Object.assign({}, root.instance, { id: id, x: root.instance.x + 24, y: root.instance.y + 24 });
        Config.options.background.activeWidgets = (Config.options.background.activeWidgets ?? []).concat([copy]);
        GlobalStates.selectEditWidget(copy.id, copy.id, GlobalStates.editWidgetConfigName);
    }
    Connections {
        target: GlobalStates
        function onEditWidgetKeyChanged() { root.showingOptions = false; }
        function onEditWidgetOptionsRequested() { root.showingOptions = true; }
        function onEditModeScrollRequested(dy) {
            if (GlobalStates.editModePage === "bar") {
                if (barLoader.item && barLoader.item.flickable) {
                    var f = barLoader.item.flickable;
                    f.contentY = Math.max(0, Math.min(f.contentHeight - f.height, f.contentY + dy));
                }
            } else if (root.catalogFlickable) {
                var cf = root.catalogFlickable;
                cf.contentY = Math.max(0, Math.min(cf.contentHeight - cf.height, cf.contentY + dy));
            }
        }
    }
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; onWheel: wheel => wheel.accepted = true }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Item {
                id: headerDragArea
                Layout.fillWidth: true
                implicitHeight: 40
                readonly property bool hovered: headerHover.hovered && !headerDrag.active

                HoverHandler {
                    id: headerHover
                    cursorShape: Qt.OpenHandCursor
                }

                DragHandler {
                    id: headerDrag
                    target: null
                    grabPermissions: PointerHandler.CanTakeOverFromAnything
                    cursorShape: Qt.ClosedHandCursor

                    property real lastSceneX: 0
                    property real lastSceneY: 0

                    onActiveChanged: {
                        if (active) {
                            lastSceneX = centroid.scenePosition.x;
                            lastSceneY = centroid.scenePosition.y;
                        }
                    }

                    onCentroidChanged: {
                        if (!active) return;
                        var cx = centroid.scenePosition.x;
                        var cy = centroid.scenePosition.y;
                        var dx = cx - lastSceneX;
                        var dy = cy - lastSceneY;
                        lastSceneX = cx;
                        lastSceneY = cy;
                        if (dx !== 0 || dy !== 0) {
                            root.dragBy(dx, dy);
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 6

                    MaterialSymbol {
                        text: "drag_indicator"
                        iconSize: 20
                        color: root.isWuWa
                            ? (headerDrag.active ? SettingsTheme.colAccent : (headerHover.hovered ? SettingsTheme.colTextPrimary : SettingsTheme.colTextSecondary))
                            : Appearance.colors.colSubtext
                        opacity: headerDrag.active ? 1.0 : (headerHover.hovered ? 0.8 : 0.4)
                        Behavior on opacity {
                            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                        }
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: qsTr("Edit desktop")
                        font.pixelSize: 22
                        font.weight: Font.DemiBold
                        color: root.isWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnLayer0
                        elide: Text.ElideRight
                    }
                }

                StyledToolTip {
                    extraVisibleCondition: headerDragArea.hovered
                    text: qsTr("Drag to move")
                }
            }

            RippleButton {
                id: doneBtn
                implicitWidth: 70; implicitHeight: 40
                buttonRadius: Appearance.rounding.small
                colBackground: root.isWuWa ? SettingsTheme.colItemBg : ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)
                colBackgroundHover: root.isWuWa ? SettingsTheme.colNavHover : Appearance.colors.colLayer1Hover
                colBackgroundActive: root.isWuWa ? SettingsTheme.colControlBgActive : Appearance.colors.colLayer1Active
                colRipple: root.isWuWa ? SettingsTheme.colAccent : Appearance.colors.colLayer1Active
                borderWidth: root.isWuWa ? 1 : 0
                borderColor: root.isWuWa ? SettingsTheme.colNavBorder : "transparent"
                onClicked: GlobalStates.closeEditMode()
                StyledText {
                    anchors.centerIn: parent
                    text: qsTr("Done")
                    font.weight: Font.Medium
                    color: root.isWuWa
                        ? (doneBtn.hovered ? SettingsTheme.colTextPrimary : SettingsTheme.colAccent)
                        : Appearance.colors.colOnLayer1
                }
            }
        }
        ConfigSelectionArray {
            Layout.fillWidth: true
            options: [{ value: "widgets", displayName: qsTr("Widgets"), icon: "widgets" }, { value: "bar", displayName: qsTr("Bar"), icon: "view_stream" }]
            currentValue: GlobalStates.editModePage
            onSelected: value => GlobalStates.editModePage = value
        }
        Loader {
            id: barLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            active: GlobalStates.editModePage === "bar"
            visible: active
            sourceComponent: Component { LegacyBarLayoutConfig {} }
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: GlobalStates.editModePage !== "bar"
            spacing: 8
            NoticeBox {
                Layout.fillWidth: true
                materialIcon: "drag_indicator"
                text: qsTr("Drag widgets to move them. Ctrl-click to select several, or drag a selection box on the desktop.")
            }
            RowLayout {
                visible: root.entry !== undefined && root.entry !== null
                Layout.fillWidth: true
                StyledText {
                    Layout.fillWidth: true
                    text: root.selectionName
                    font.bold: true
                    elide: Text.ElideRight
                    color: root.isWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnLayer1
                }
                RippleButton {
                    implicitWidth: 36; implicitHeight: 36
                    buttonRadius: Appearance.rounding.small
                    colBackground: root.isWuWa ? SettingsTheme.colItemBg : "transparent"
                    colBackgroundHover: root.isWuWa ? SettingsTheme.colNavHover : Appearance.colors.colLayer1Hover
                    colRipple: root.isWuWa ? SettingsTheme.colAccent : Appearance.colors.colLayer1Active
                    borderWidth: root.isWuWa ? 1 : 0
                    borderColor: root.isWuWa ? SettingsTheme.colNavBorder : "transparent"
                    visible: root.instance !== undefined
                    onClicked: root.duplicate()
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "content_copy"
                        iconSize: 20
                        color: root.isWuWa ? SettingsTheme.colTextSecondary : Appearance.colors.colOnLayer1
                    }
                    StyledToolTip { text: qsTr("Duplicate") }
                }
                RippleButton {
                    implicitWidth: 36; implicitHeight: 36
                    buttonRadius: Appearance.rounding.small
                    colBackground: root.isWuWa ? SettingsTheme.colItemBg : "transparent"
                    colBackgroundHover: root.isWuWa ? ColorUtils.applyAlpha(ResonanceTheme.colThermalOrange, 0.20) : Appearance.colors.colLayer1Hover
                    colRipple: root.isWuWa ? ResonanceTheme.colThermalOrange : Appearance.colors.colLayer1Active
                    borderWidth: root.isWuWa ? 1 : 0
                    borderColor: root.isWuWa ? SettingsTheme.colNavBorder : "transparent"
                    onClicked: root.removeSelection()
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "delete"
                        iconSize: 20
                        color: root.isWuWa ? SettingsTheme.colTextSecondary : Appearance.colors.colOnLayer1
                    }
                    StyledToolTip { text: qsTr("Remove") }
                }
            }
            RowLayout {
                visible: !!root.entry
                Layout.fillWidth: true
                Repeater {
                    model: ["x", "y"]
                    delegate: ConfigSpinBox {
                        required property string modelData
                        Layout.fillWidth: true
                        text: modelData.toUpperCase(); icon: "open_with"
                        from: 0; to: modelData === "x" ? root.screen.width : root.screen.height
                        value: Math.round((root.entry && root.entry[modelData] !== undefined) ? root.entry[modelData] : 0)
                        onValueChanged: if (root.entry && root.entry[modelData] !== value) root.setPosition(modelData, value)
                    }
                }
            }
            ConfigComboBox {
                Layout.fillWidth: true
                visible: !!root.entry
                text: qsTr("Placement")
                fieldWidth: 175
                currentValue: (root.entry && root.entry.placementStrategy) ? root.entry.placementStrategy : "free"
                model: [{ value: "free", displayName: qsTr("Free") }, { value: "leastBusy", displayName: qsTr("Least busy") }, { value: "mostBusy", displayName: qsTr("Most busy") }]
                onSelected: value => root.setPosition("placementStrategy", value)
            }
            ConfigComboBox {
                Layout.fillWidth: true
                visible: !!root.instance
                text: qsTr("Lock screen")
                fieldWidth: 175
                currentValue: (root.instance && root.instance.lockBehavior) ? root.instance.lockBehavior : "keep"
                model: [{ value: "keep", displayName: qsTr("Show") }, { value: "hide", displayName: qsTr("Hide") }, { value: "lockOnly", displayName: qsTr("Only when locked") }]
                onSelected: value => root.setPosition("lockBehavior", value)
            }
            ConfigSwitch {
                Layout.fillWidth: true
                visible: !!root.instance
                text: qsTr("Pinned")
                checked: !!(root.instance && root.instance.pinned)
                onCheckedChanged: if (root.instance && checked !== root.instance.pinned) root.setPosition("pinned", checked)
            }
            RippleButton {
                id: optionsBtn
                Layout.fillWidth: true; implicitHeight: 36
                buttonRadius: Appearance.rounding.small
                colBackground: root.isWuWa ? SettingsTheme.colItemBg : "transparent"
                colBackgroundHover: root.isWuWa ? SettingsTheme.colNavHover : Appearance.colors.colLayer1Hover
                colRipple: root.isWuWa ? SettingsTheme.colAccent : Appearance.colors.colLayer1Active
                borderWidth: root.isWuWa ? 1 : 0
                borderColor: root.isWuWa ? SettingsTheme.colNavBorder : "transparent"
                visible: !!root.entry
                onClicked: root.showingOptions = !root.showingOptions
                StyledText {
                    anchors.centerIn: parent
                    text: root.showingOptions ? qsTr("Back to catalog") : qsTr("Widget options")
                    color: root.isWuWa ? (optionsBtn.hovered ? SettingsTheme.colTextPrimary : SettingsTheme.colAccent) : Appearance.colors.colOnLayer1
                }
            }
            Loader {
                Layout.fillWidth: true; Layout.fillHeight: true
                visible: active
                active: root.showingOptions
                source: (root.metadata && root.metadata.configPage) ? Qt.resolvedUrl("../../settings/configs/" + root.metadata.configPage) : ""
                sourceComponent: (root.metadata && root.metadata.configPage) ? null : legacyOptions
                onLoaded: if (item && item.goBack) item.goBack.connect(() => root.showingOptions = false)
            }
            ColumnLayout {
                Layout.fillWidth: true; Layout.fillHeight: true
                visible: !root.showingOptions
                spacing: 10

                MaterialTextField {
                    Layout.fillWidth: true
                    placeholderText: qsTr("Find a widget…")
                    text: root.query
                    onTextEdited: root.query = text
                }

                StyledFlickable {
                    id: catalogFlickable
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: width
                    contentHeight: categoriesColumn.implicitHeight + 16
                    flickableDirection: Flickable.VerticalFlick

                    ColumnLayout {
                        id: categoriesColumn
                        width: catalogFlickable.width - 10
                        spacing: 12

                        Item {
                            Layout.fillWidth: true
                            implicitHeight: 110
                            visible: root.categoriesModel.length === 0
                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 8
                                MaterialSymbol {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "search_off"
                                    iconSize: 32
                                    color: root.isWuWa ? SettingsTheme.colTextSecondary : Appearance.colors.colSubtext
                                }
                                StyledText {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: qsTr("No widgets found")
                                    font.pixelSize: 13
                                    color: root.isWuWa ? SettingsTheme.colTextSecondary : Appearance.colors.colSubtext
                                }
                            }
                        }

                        Repeater {
                            model: root.categoriesModel
                            delegate: Rectangle {
                                id: categoryCard
                                required property var modelData
                                Layout.fillWidth: true
                                radius: Appearance.rounding.normal
                                color: root.isWuWa ? SettingsTheme.colCardBg : Appearance.colors.colLayer0
                                border.width: root.isWuWa ? SettingsTheme.cardBorderWidth : 1
                                border.color: root.isWuWa ? SettingsTheme.colCardBorder : Appearance.colors.colLayer0Border
                                clip: true

                                readonly property var categoryData: modelData
                                readonly property bool isCollapsed: !root.query && !!root.collapsedCategories[categoryData.key]

                                implicitHeight: cardInnerLayout.implicitHeight + 20

                                ColumnLayout {
                                    id: cardInnerLayout
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        top: parent.top
                                        margins: 10
                                    }
                                    spacing: 8

                                    RippleButton {
                                        id: categoryHeaderBtn
                                        Layout.fillWidth: true
                                        implicitHeight: 38
                                        buttonRadius: Appearance.rounding.small
                                        colBackground: "transparent"
                                        colBackgroundHover: root.isWuWa ? SettingsTheme.colRowHover : Appearance.colors.colLayer1Hover
                                        colBackgroundActive: root.isWuWa ? SettingsTheme.colControlBgActive : Appearance.colors.colLayer1Active
                                        colRipple: root.isWuWa ? SettingsTheme.colAccent : Appearance.colors.colLayer1Active
                                        onClicked: root.toggleCategory(categoryCard.categoryData.key)

                                        contentItem: RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 6
                                            anchors.rightMargin: 8
                                            spacing: 8

                                            MaterialSymbol {
                                                text: categoryCard.categoryData.icon
                                                iconSize: 20
                                                color: root.isWuWa ? SettingsTheme.colAccent : Appearance.colors.colPrimary
                                            }

                                            StyledText {
                                                Layout.fillWidth: true
                                                text: categoryCard.categoryData.title
                                                font.pixelSize: 14
                                                font.weight: Font.DemiBold
                                                color: root.isWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnLayer1
                                            }

                                            Rectangle {
                                                implicitWidth: countText.implicitWidth + 14
                                                implicitHeight: 20
                                                radius: 10
                                                color: root.isWuWa ? ColorUtils.applyAlpha(SettingsTheme.colAccent, 0.12) : Appearance.colors.colLayer1Hover
                                                border.width: 1
                                                border.color: root.isWuWa ? ColorUtils.applyAlpha(SettingsTheme.colAccent, 0.28) : "transparent"

                                                StyledText {
                                                    id: countText
                                                    anchors.centerIn: parent
                                                    text: String(categoryCard.categoryData.widgets.length)
                                                    font.pixelSize: 11
                                                    font.weight: Font.Medium
                                                    color: root.isWuWa ? SettingsTheme.colAccent : Appearance.colors.colSubtext
                                                }
                                            }

                                            MaterialSymbol {
                                                text: "keyboard_arrow_down"
                                                iconSize: 20
                                                color: root.isWuWa ? SettingsTheme.colTextSecondary : Appearance.colors.colOnLayer1
                                                rotation: categoryCard.isCollapsed ? -90 : 0
                                                Behavior on rotation {
                                                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                                                }
                                            }
                                        }
                                    }

                                    ColumnLayout {
                                        id: rowsColumn
                                        Layout.fillWidth: true
                                        visible: !categoryCard.isCollapsed
                                        spacing: 6

                                        Repeater {
                                            model: categoryCard.categoryData.widgets
                                            delegate: Item {
                                                id: widgetRowWrapper
                                                required property var modelData
                                                Layout.fillWidth: true
                                                implicitHeight: 52

                                                readonly property var widgetItem: modelData
                                                readonly property bool activeOrAdded: {
                                                    if (widgetItem.legacy) {
                                                        return !!(Config.options.background.widgets[widgetItem.id] && Config.options.background.widgets[widgetItem.id].enable);
                                                    }
                                                    const activeList = Config.options.background.activeWidgets ?? [];
                                                    return activeList.some(entry => (entry.widgetId ?? entry.id) === widgetItem.id);
                                                }
                                                readonly property bool isSelected: {
                                                    if (widgetItem.legacy) {
                                                        return GlobalStates.editWidgetKey === widgetItem.id;
                                                    }
                                                    return !!(root.instance && (root.instance.widgetId ?? root.instance.id) === widgetItem.id);
                                                }

                                                RippleButton {
                                                    id: widgetRowBtn
                                                    anchors.fill: parent
                                                    buttonRadius: Appearance.rounding.small
                                                    colBackground: widgetRowWrapper.activeOrAdded
                                                        ? (root.isWuWa ? (widgetRowWrapper.isSelected ? ColorUtils.applyAlpha(SettingsTheme.colAccent, 0.16) : ColorUtils.applyAlpha(SettingsTheme.colAccent, 0.10)) : Appearance.colors.colSecondaryContainer)
                                                        : (root.isWuWa ? SettingsTheme.colRowBg : "transparent")
                                                    colBackgroundHover: widgetRowWrapper.activeOrAdded
                                                        ? (root.isWuWa ? (widgetRowWrapper.isSelected ? ColorUtils.applyAlpha(SettingsTheme.colAccent, 0.22) : ColorUtils.applyAlpha(SettingsTheme.colAccent, 0.16)) : Appearance.colors.colLayer1Hover)
                                                        : (root.isWuWa ? SettingsTheme.colRowHover : Appearance.colors.colLayer1Hover)
                                                    colBackgroundActive: root.isWuWa ? SettingsTheme.colControlBgActive : Appearance.colors.colLayer1Active
                                                    colRipple: root.isWuWa ? SettingsTheme.colAccent : Appearance.colors.colLayer1Active
                                                    borderWidth: root.isWuWa ? SettingsTheme.rowBorderWidth : 0
                                                    borderColor: widgetRowWrapper.activeOrAdded
                                                        ? (root.isWuWa ? (widgetRowBtn.hovered ? ColorUtils.applyAlpha(SettingsTheme.colAccent, 0.60) : (widgetRowWrapper.isSelected ? ColorUtils.applyAlpha(SettingsTheme.colAccent, 0.50) : ColorUtils.applyAlpha(SettingsTheme.colAccent, 0.35))) : Appearance.colors.colPrimary)
                                                        : (root.isWuWa ? (widgetRowBtn.hovered ? ColorUtils.applyAlpha(SettingsTheme.colAntiqueGold, 0.28 * SettingsTheme.intensity) : SettingsTheme.colRowBorder) : "transparent")
                                                    onClicked: root.selectOrAdd(widgetRowWrapper.widgetItem)

                                                    contentItem: RowLayout {
                                                        anchors.fill: parent
                                                        anchors.leftMargin: 10
                                                        anchors.rightMargin: 10
                                                        spacing: 10

                                                        Rectangle {
                                                            id: iconTile
                                                            Layout.alignment: Qt.AlignVCenter
                                                            implicitWidth: 32
                                                            implicitHeight: 32
                                                            radius: Appearance.rounding.verysmall
                                                            color: widgetRowWrapper.activeOrAdded
                                                                ? (root.isWuWa ? (widgetRowBtn.hovered ? ColorUtils.applyAlpha(SettingsTheme.colAccent, 0.24) : ColorUtils.applyAlpha(SettingsTheme.colAccent, 0.16)) : Appearance.colors.colPrimaryContainer)
                                                                : (root.isWuWa ? (widgetRowBtn.hovered ? ColorUtils.applyAlpha(SettingsTheme.colTealInkDark, 0.70) : ColorUtils.applyAlpha(SettingsTheme.colTealInkDark, 0.45)) : Appearance.colors.colLayer1)
                                                            border.width: root.isWuWa ? 1 : 0
                                                            border.color: widgetRowWrapper.activeOrAdded
                                                                ? (root.isWuWa ? (widgetRowBtn.hovered ? ColorUtils.applyAlpha(SettingsTheme.colAccent, 0.60) : ColorUtils.applyAlpha(SettingsTheme.colAccent, 0.38)) : "transparent")
                                                                : (root.isWuWa ? (widgetRowBtn.hovered ? ColorUtils.applyAlpha(SettingsTheme.colAccent, 0.24) : ColorUtils.applyAlpha(SettingsTheme.colAntiqueGold, 0.10 * SettingsTheme.intensity)) : "transparent")

                                                            MaterialSymbol {
                                                                anchors.centerIn: parent
                                                                text: widgetRowWrapper.widgetItem.icon || "widgets"
                                                                iconSize: 18
                                                                color: widgetRowWrapper.activeOrAdded
                                                                    ? (root.isWuWa ? (widgetRowBtn.hovered ? Qt.lighter(SettingsTheme.colAccent, 1.10) : SettingsTheme.colAccent) : Appearance.colors.colOnPrimaryContainer)
                                                                    : (root.isWuWa ? (widgetRowBtn.hovered ? SettingsTheme.colTextPrimary : SettingsTheme.colTextSecondary) : Appearance.colors.colOnLayer1)
                                                            }
                                                        }

                                                        ColumnLayout {
                                                            Layout.fillWidth: true
                                                            Layout.alignment: Qt.AlignVCenter
                                                            spacing: 2

                                                            StyledText {
                                                                Layout.fillWidth: true
                                                                text: widgetRowWrapper.widgetItem.name
                                                                elide: Text.ElideRight
                                                                font.pixelSize: 13
                                                                font.weight: widgetRowWrapper.activeOrAdded ? Font.DemiBold : Font.Medium
                                                                color: root.isWuWa
                                                                    ? (widgetRowWrapper.activeOrAdded ? SettingsTheme.colTextPrimary : (widgetRowBtn.hovered ? Qt.lighter(SettingsTheme.colTextPrimary, 1.05) : SettingsTheme.colTextPrimary))
                                                                    : Appearance.colors.colOnLayer1
                                                            }

                                                            StyledText {
                                                                Layout.fillWidth: true
                                                                text: widgetRowWrapper.widgetItem.description || widgetRowWrapper.widgetItem.displayCategory || widgetRowWrapper.widgetItem.category || ""
                                                                elide: Text.ElideRight
                                                                font.pixelSize: 11
                                                                color: root.isWuWa
                                                                    ? (widgetRowBtn.hovered ? Qt.lighter(SettingsTheme.colTextSecondary, 1.10) : SettingsTheme.colTextSecondary)
                                                                    : Appearance.colors.colSubtext
                                                                opacity: widgetRowWrapper.activeOrAdded ? 0.90 : 0.75
                                                            }
                                                        }

                                                        Rectangle {
                                                            id: actionBadge
                                                            Layout.alignment: Qt.AlignVCenter
                                                            implicitWidth: 26
                                                            implicitHeight: 26
                                                            radius: 13
                                                            color: widgetRowWrapper.activeOrAdded
                                                                ? (root.isWuWa ? (widgetRowBtn.hovered ? ColorUtils.applyAlpha(SettingsTheme.colAccent, 0.28) : ColorUtils.applyAlpha(SettingsTheme.colAccent, 0.20)) : Appearance.colors.colPrimary)
                                                                : (root.isWuWa ? (widgetRowBtn.hovered ? ColorUtils.applyAlpha(SettingsTheme.colTealInkDark, 0.70) : ColorUtils.applyAlpha(SettingsTheme.colTealInkDark, 0.45)) : "transparent")
                                                            border.width: 1
                                                            border.color: widgetRowWrapper.activeOrAdded
                                                                ? (root.isWuWa ? (widgetRowBtn.hovered ? Qt.lighter(SettingsTheme.colAccent, 1.15) : SettingsTheme.colAccent) : "transparent")
                                                                : (root.isWuWa ? (widgetRowBtn.hovered ? ColorUtils.applyAlpha(SettingsTheme.colAccent, 0.40) : ColorUtils.applyAlpha(SettingsTheme.colTextSecondary, 0.22)) : "transparent")

                                                            MaterialSymbol {
                                                                anchors.centerIn: parent
                                                                text: widgetRowWrapper.activeOrAdded ? "check" : "add"
                                                                iconSize: 15
                                                                color: widgetRowWrapper.activeOrAdded
                                                                    ? (root.isWuWa ? (widgetRowBtn.hovered ? Qt.lighter(SettingsTheme.colAccent, 1.15) : SettingsTheme.colAccent) : Appearance.colors.colOnPrimary)
                                                                    : (root.isWuWa ? (widgetRowBtn.hovered ? SettingsTheme.colTextPrimary : SettingsTheme.colTextSecondary) : Appearance.colors.colOnLayer1)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    Component {
        id: legacyOptions
        LegacyWidgetOptions { configName: GlobalStates.editWidgetConfigName }
    }
}
