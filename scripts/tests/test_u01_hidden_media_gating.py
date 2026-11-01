#!/usr/bin/env python3
"""Contract and regression tests for Task U01: Gating hidden media animation and polling."""

import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
QT_MEDIA_PATH = ROOT / "modules/common/quickToggles/androidStyle/QuickToggleMediaContent.qml"
ANDROID_MEDIA_PATH = ROOT / "modules/ii/background/widgets/media/AndroidMediaWidget.qml"
ABSTRACT_WIDGET_PATH = ROOT / "modules/ii/background/widgets/AbstractBackgroundWidget.qml"


class TestU01HiddenMediaGating(unittest.TestCase):
    def setUp(self):
        self.qt_media = QT_MEDIA_PATH.read_text(encoding="utf-8")
        self.android_media = ANDROID_MEDIA_PATH.read_text(encoding="utf-8")
        self.abstract_widget = ABSTRACT_WIDGET_PATH.read_text(encoding="utf-8")

    def test_abstract_background_widget_provides_live_contract(self):
        self.assertIn("property bool paused: false", self.abstract_widget)
        self.assertIn("property bool live: root.visible && root.opacity > 0 && !root.paused", self.abstract_widget)

    def test_quick_toggle_media_shown_in_window_contract(self):
        # 1. Traces host-window visibility plus item visibility
        self.assertIn("readonly property bool shownInWindow: root.visible && (root.Window.window?.visible ?? false)", self.qt_media)

        # 2. Progress holds while not shown in window
        self.assertIn("readonly property real trackProgress: root.shownInWindow ? MprisController.trackProgressOf(root.player) : root.heldTrackProgress", self.qt_media)
        self.assertIn("onTrackProgressChanged: if (root.shownInWindow) root.heldTrackProgress = root.trackProgress", self.qt_media)

        # 3. Lyric change animation gated on shown in window
        self.assertIn("animateChange: root.shownInWindow", self.qt_media)

        # 4. Position poll timer gated on shown in window
        self.assertIn("running: root.playing && root.shownInWindow && (root.portrait > 0.5 || root.seekReveal > 0.5)", self.qt_media)

        # 5. Seek slider uses held track progress and gates wave animation
        self.assertIn("animateWave: root.playing && root.shownInWindow", self.qt_media)
        self.assertIn("value: root.trackProgress", self.qt_media)
        self.assertIn("value = Qt.binding(() => root.trackProgress)", self.qt_media)

    def test_android_media_widget_paused_and_live_contract(self):
        # 1. Host pause signal contract: desktop covered by windows
        self.assertIn("paused: root.hasActiveWindows && !GlobalStates.mediaControlsOpen", self.android_media)

        # 2. Live vs shown progress and lyric properties
        self.assertIn("readonly property real liveProgress: MprisController.trackProgressOf(root.player)", self.android_media)
        self.assertIn("readonly property int liveLyricIndex: LyricsService.currentIndex", self.android_media)
        self.assertIn("property real shownProgress: 0", self.android_media)
        self.assertIn("property int shownLyricIndex: -1", self.android_media)
        self.assertIn("property bool lyricJump: false", self.android_media)

        # 3. syncPlayback is gated by root.live
        self.assertIn("if (!root.live)\n            return;", self.android_media)
        self.assertIn("root.shownProgress = root.liveProgress;", self.android_media)
        self.assertIn("root.shownLyricIndex = root.liveLyricIndex;", self.android_media)

        # 4. onLiveChanged synchronizes immediately without replaying hidden transitions
        self.assertIn("root.lyricJump = true;", self.android_media)
        self.assertIn("root.syncPlayback();", self.android_media)
        self.assertIn("root.lyricJump = false;", self.android_media)
        self.assertIn("lyricTransitionAnimation.stop();", self.android_media)
        self.assertIn("root.activeLyricText = root.displaySongText;", self.android_media)

        # 5. onDisplaySongTextChanged gated while not live
        self.assertIn("onDisplaySongTextChanged: {\n        if (!root.live)\n            return;", self.android_media)

        # 6. Position poll timer gated by root.live (not just root.visible)
        self.assertIn("running: root.playing && root.live", self.android_media)

        # 7. Component.onCompleted initializes shown progress and lyric index
        self.assertIn("root.shownProgress = root.liveProgress;", self.android_media)
        self.assertIn("root.shownLyricIndex = root.liveLyricIndex;", self.android_media)

        # 8. Lyric container uses shownLyricIndex and suppresses scroll animation on lyricJump
        self.assertIn("readonly property int targetCurrentIndex: LyricsService.hasSyncedLines ? root.shownLyricIndex : -1", self.android_media)
        self.assertIn("if (root.lyricJump) {\n                                            scrollOffset = 0;\n                                            return;\n                                        }", self.android_media)

        # 9. Sliders and progress bars use shownProgress and gate wave animation on live
        self.assertIn("animateWave: root.playing && root.live && (!root.hasActiveWindows || GlobalStates.mediaControlsOpen)", self.android_media)
        self.assertIn("value: root.shownProgress", self.android_media)
        self.assertIn("value = Qt.binding(() => root.shownProgress)", self.android_media)

    def test_shared_player_and_lyrics_service_not_stopped(self):
        # Verify we did not pause the player or lyrics service globally
        self.assertNotIn("MprisController.pause", self.qt_media)
        self.assertNotIn("LyricsService.stop", self.qt_media)
        self.assertNotIn("LyricsService.pause", self.qt_media)
        self.assertNotIn("LyricsService.stop", self.android_media)


if __name__ == "__main__":
    unittest.main()
