import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Qt.labs.synchronizer
import "../sidebarPolicies/phone"

Item {
    id: root
    required property var scopeRoot
    property int sidebarPadding: 10
    anchors.fill: parent
    property bool phoneEnabled: (Config.options?.policies?.phone ?? 1) !== 0
    property bool aiChatEnabled: Config.options.policies.ai !== 0
    property bool translatorEnabled: Config.options.sidebar.translator.enable
    property bool animeEnabled: Config.options.policies.weeb !== 0
    property bool animeCloset: Config.options.policies.weeb === 2
    property bool mediaEnabled: Config.options.sidebar.media.enable
    property var tabButtonList: [
        ...(root.phoneEnabled ? [{"icon": "smartphone", "name": Translation.tr("Phone")}] : []),
        ...(root.aiChatEnabled ? [{"icon": "neurology", "name": Translation.tr("Intelligence")}] : []),
        ...(root.translatorEnabled ? [{"icon": "translate", "name": Translation.tr("Translator")}] : []),
        ...(root.mediaEnabled ? [{"icon": "music_note", "name": Translation.tr("Media")}] : []),
        ...((root.animeEnabled && !root.animeCloset) ? [{"icon": "bookmark_heart", "name": Translation.tr("Anime")}] : [])
    ]
    property int tabCount: swipeView.count
    readonly property bool tabsReady: Config.ready && Persistent.ready
    readonly property bool keepLoaded: Config.options.sidebar.keepLeftSidebarLoaded
    readonly property bool shownInWindow: root.visible && (root.Window.window?.visible ?? false)

    Timer {
        id: releaseCollect
        interval: 500
        onTriggered: if (!GlobalStates.sidebarLeftOpen) gc()
    }

    Component {
        id: tabLoader
        Loader {
            property bool visited: false
            // Retain staged files and drafts, and phone subpages while switching tabs.
            readonly property bool hasPendingState: Boolean(item && (
                item.hasStagedFiles || String(item.activeSubPage ?? "").length > 0
                || String(item.inputField?.text ?? "").length > 0))
            active: root.tabsReady && (root.shownInWindow
                && (SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem)
                || root.keepLoaded && visited || hasPendingState)
            onLoaded: {
                visited = true;
                if (SwipeView.isCurrentItem && root.shownInWindow) item.forceActiveFocus();
            }
            onFocusChanged: if (focus && item) item.forceActiveFocus()
            onActiveChanged: if (!active) releaseCollect.restart()
        }
    }

    function applyTabRequest(): void {
        const wanted = GlobalStates.policiesRequestTabIcon;
        if (!wanted) return;
        const index = root.tabButtonList.findIndex(t => t.icon === wanted);
        GlobalStates.policiesRequestTabIcon = "";
        if (index >= 0) {
            verticalTabBar.currentIndex = index;
        }
    }

    Connections {
        target: GlobalStates
        function onPoliciesRequestTabIconChanged(): void {
            root.applyTabRequest();
        }
    }

    function focusActiveItem() {
        swipeView.currentItem?.item?.forceActiveFocus()
    }

    Keys.onPressed: (event) => {
        if (event.modifiers === Qt.ControlModifier) {
            if (event.key === Qt.Key_PageDown) {
                swipeView.incrementCurrentIndex()
                event.accepted = true;
            }
            else if (event.key === Qt.Key_PageUp) {
                swipeView.decrementCurrentIndex()
                event.accepted = true;
            }
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: sidebarPadding
        }
        spacing: verticalTabBar.expanded ? -2 : 0

        VerticalTabBar {
            id: verticalTabBar
            visible: tabButtonList.length > 0
            Layout.fillWidth: true
            tabButtonList: root.tabButtonList
            currentIndex: (Persistent.ready && Persistent.states.sidebar.policies)
                ? Math.min(Math.max(0, Persistent.states.sidebar.policies.tab), Math.max(0, root.tabButtonList.length - 1))
                : 0
            onCurrentIndexChanged: {
                if (swipeView.currentIndex !== currentIndex) {
                    swipeView.currentIndex = currentIndex;
                }
                if (Persistent.ready && Persistent.states.sidebar.policies) {
                    Persistent.states.sidebar.policies.tab = currentIndex;
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitWidth: swipeView.implicitWidth
            implicitHeight: swipeView.implicitHeight
            topLeftRadius: 0
            bottomLeftRadius: Appearance.rounding.normal
            topRightRadius: 0
            bottomRightRadius: Appearance.rounding.normal
            color: ResonanceTheme.enabled ? ResonanceTheme.bgGlassSidebarInner : Appearance.colors.colLayer1

            SwipeView { // Content pages
                id: swipeView
                anchors.fill: parent
                spacing: 10
                currentIndex: verticalTabBar.currentIndex
                onCurrentIndexChanged: {
                    if (verticalTabBar.currentIndex !== currentIndex) {
                        verticalTabBar.currentIndex = currentIndex;
                    }
                }

                clip: true
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: swipeView.width
                        height: swipeView.height
                        radius: Appearance.rounding.small
                    }
                }

                contentChildren: [
                    ...(root.phoneEnabled ? [tabLoader.createObject(swipeView, { sourceComponent: phoneTab })] : []),
                    ...(root.aiChatEnabled ? [tabLoader.createObject(swipeView, { sourceComponent: aiChat })] : []),
                    ...(root.translatorEnabled ? [tabLoader.createObject(swipeView, { sourceComponent: translator })] : []),
                    ...(root.mediaEnabled ? [tabLoader.createObject(swipeView, { sourceComponent: media })] : []),
                    ...((root.tabButtonList.length === 0 || (!root.phoneEnabled && !root.aiChatEnabled && !root.translatorEnabled && root.animeCloset)) ? [tabLoader.createObject(swipeView, { sourceComponent: placeholder })] : []),
                    ...(root.animeEnabled ? [tabLoader.createObject(swipeView, { sourceComponent: anime })] : []),
                ]
            }
        }

        Component {
            id: phoneTab
            Phone {}
        }
        Component {
            id: aiChat
            AiChat {}
        }
        Component {
            id: translator
            Translator {}
        }
        Component {
            id: media
            SidebarPlayerControl {}
        }
        Component {
            id: anime
            Anime {}
        }
        Component {
            id: placeholder
            Item {
                StyledText {
                    anchors.centerIn: parent
                    text: root.animeCloset ? Translation.tr("Nothing") : Translation.tr("Enjoy your empty sidebar...")
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}
