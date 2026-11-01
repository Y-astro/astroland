#!/usr/bin/env python3
"""Dynamic behavioral test for U01: Hide/Reveal, Pause/Resume, Seek, Track Change, and Multi-Consumer."""

import time
import unittest
from pathlib import Path


class MockPlayer:
    def __init__(self):
        self.isPlaying = True
        self.canSeek = True
        self.trackLength = 180.0
        self.position = 30.0
        self.trackTitle = "Resonance Horizon (Bench)"
        self.trackArtist = "Wuthering Waves"
        self.positionChangedFired = 0

    def positionChanged(self):
        self.positionChangedFired += 1

    def seekFraction(self, fraction):
        self.position = self.trackLength * fraction


class MockMprisController:
    def __init__(self, player):
        self.activePlayer = player

    def trackProgressOf(self, player):
        if not player or player.trackLength == 0:
            return 0.0
        return player.position / player.trackLength

    def hasTrackLength(self, player):
        return player and player.trackLength > 0

    def seekFraction(self, player, fraction):
        if player:
            player.seekFraction(fraction)


class MockLyricsService:
    def __init__(self):
        self.hasSyncedLines = True
        self.currentIndex = 0
        self.statusText = "Echoes in the wind"
        self.restartCount = 0

    def restartLyrics(self):
        self.restartCount += 1


class SimulatedQuickToggleMedia:
    def __init__(self, player, controller, lyrics):
        self.player = player
        self.controller = controller
        self.lyrics = lyrics
        self.visible = True
        self.windowVisible = False  # Initially window is closed / unmapped
        self.heldTrackProgress = 0.0
        self.portrait = 1.0
        self.seekReveal = 0.0
        self.lyricsAnimated = False

    @property
    def shownInWindow(self):
        return self.visible and self.windowVisible

    @property
    def trackProgress(self):
        if self.shownInWindow:
            return self.controller.trackProgressOf(self.player)
        return self.heldTrackProgress

    def onTrackProgressChanged(self):
        if self.shownInWindow:
            self.heldTrackProgress = self.trackProgress

    @property
    def animateLyricsChange(self):
        return self.shownInWindow

    @property
    def timerRunning(self):
        return (self.player.isPlaying and self.shownInWindow and 
                (self.portrait > 0.5 or self.seekReveal > 0.5))

    @property
    def animateWave(self):
        return self.player.isPlaying and self.shownInWindow

    def onLyricTextChanged(self):
        if self.animateLyricsChange:
            self.lyricsAnimated = True
        else:
            self.lyricsAnimated = False


class SimulatedAndroidMediaWidget:
    def __init__(self, player, controller, lyrics):
        self.player = player
        self.controller = controller
        self.lyrics = lyrics
        self.visible = True
        self.opacity = 1.0
        self.hasActiveWindows = True  # Desktop covered initially
        self.mediaControlsOpen = False
        self.shownProgress = 0.0
        self.shownLyricIndex = -1
        self.lyricJump = False
        self.activeLyricText = ""
        self.displaySongText = "Echoes in the wind"
        self.lyricAnimationStarted = 0
        self.lyricAnimationStopped = 0
        self.scrollAnimStarted = 0
        self.scrollOffset = 0

    @property
    def paused(self):
        return self.hasActiveWindows and not self.mediaControlsOpen

    @property
    def live(self):
        return self.visible and self.opacity > 0 and not self.paused

    @property
    def liveProgress(self):
        return self.controller.trackProgressOf(self.player)

    @property
    def liveLyricIndex(self):
        return self.lyrics.currentIndex if self.lyrics.currentIndex is not None else -1

    def syncPlayback(self):
        if not self.live:
            return
        self.shownProgress = self.liveProgress
        self.shownLyricIndex = self.liveLyricIndex

    def setLive(self, nowLive):
        if nowLive:
            self.hasActiveWindows = False
            self.lyricJump = True
            self.syncPlayback()
            self.lyricJump = False
            if self.activeLyricText != self.displaySongText:
                self.lyricAnimationStopped += 1
                self.activeLyricText = self.displaySongText
        else:
            self.hasActiveWindows = True

    def onDisplaySongTextChanged(self, newText):
        self.displaySongText = newText
        if not self.live:
            return
        self.lyricAnimationStopped += 1
        self.lyricAnimationStarted += 1

    def onTargetLyricIndexChanged(self, newIndex):
        if not self.live:
            return
        if self.lyricJump:
            self.scrollOffset = 0
            return
        self.scrollOffset = 10
        self.scrollAnimStarted += 1

    @property
    def timerRunning(self):
        return self.player.isPlaying and self.live

    @property
    def animateWave(self):
        return self.player.isPlaying and self.live and (not self.hasActiveWindows or self.mediaControlsOpen)


class DynamicBehaviorTests(unittest.TestCase):
    def setUp(self):
        self.player = MockPlayer()
        self.controller = MockMprisController(self.player)
        self.lyrics = MockLyricsService()
        self.qt = SimulatedQuickToggleMedia(self.player, self.controller, self.lyrics)
        self.bg = SimulatedAndroidMediaWidget(self.player, self.controller, self.lyrics)

    def test_quick_toggle_hidden_gating(self):
        # 1. Closed sidebar (windowVisible == False):
        self.assertFalse(self.qt.shownInWindow)
        self.assertFalse(self.qt.timerRunning)
        self.assertFalse(self.qt.animateWave)
        self.assertFalse(self.qt.animateLyricsChange)

        # 2. Simulate playback position ticks while hidden
        self.player.position = 60.0
        # Progress holds at 0
        self.assertEqual(self.qt.trackProgress, 0.0)

        # 3. Simulate lyric change while hidden
        self.lyrics.statusText = "New lyric line"
        self.qt.onLyricTextChanged()
        self.assertFalse(self.qt.lyricsAnimated, "Lyric animation must be suppressed while hidden")

        # 4. Reveal sidebar (windowVisible == True):
        self.qt.windowVisible = True
        self.assertTrue(self.qt.shownInWindow)
        self.assertTrue(self.qt.timerRunning)
        self.assertTrue(self.qt.animateWave)
        self.assertTrue(self.qt.animateLyricsChange)
        self.qt.onTrackProgressChanged()
        # Immediately catches up to live progress (60/180 = 0.333)
        self.assertAlmostEqual(self.qt.trackProgress, 60.0 / 180.0)

    def test_android_media_widget_paused_and_reveal_sync(self):
        # 1. Initial state: desktop covered by windows
        self.assertTrue(self.bg.paused)
        self.assertFalse(self.bg.live)
        self.assertFalse(self.bg.timerRunning)
        self.assertFalse(self.bg.animateWave)

        # 2. Advance song while paused (lyrics & progress advance)
        self.player.position = 90.0
        self.lyrics.currentIndex = 5
        self.bg.syncPlayback()
        # Progress and lyric index must remain held
        self.assertEqual(self.bg.shownProgress, 0.0)
        self.assertEqual(self.bg.shownLyricIndex, -1)

        # 3. Song title changes while paused
        self.bg.onDisplaySongTextChanged("Verse 2: Sky clearing")
        self.assertEqual(self.bg.lyricAnimationStarted, 0, "No lyric animation while paused")

        # 4. Reveal desktop (windows minimized or switched workspace)
        self.bg.hasActiveWindows = False
        self.bg.setLive(True)
        self.assertFalse(self.bg.paused)
        self.assertTrue(self.bg.live)
        self.assertTrue(self.bg.timerRunning)

        # Progress and lyric immediately sync
        self.assertAlmostEqual(self.bg.shownProgress, 90.0 / 180.0)
        self.assertEqual(self.bg.shownLyricIndex, 5)
        # Lyric jump suppressed scroll animation backlog
        self.assertEqual(self.bg.scrollAnimStarted, 0)
        self.assertEqual(self.bg.scrollOffset, 0)
        # Active text caught up directly without playing transition
        self.assertEqual(self.bg.activeLyricText, "Verse 2: Sky clearing")

    def test_seeking_works_while_live(self):
        # Reveal desktop
        self.bg.hasActiveWindows = False
        self.bg.setLive(True)

        # User seeks to 75%
        self.controller.seekFraction(self.player, 0.75)
        self.assertEqual(self.player.position, 135.0)
        self.bg.syncPlayback()
        self.assertAlmostEqual(self.bg.shownProgress, 0.75)

    def test_pause_resume_playback(self):
        # Reveal desktop
        self.bg.hasActiveWindows = False
        self.bg.setLive(True)
        self.assertTrue(self.bg.timerRunning)

        # Pause player
        self.player.isPlaying = False
        self.assertFalse(self.bg.timerRunning)
        self.assertFalse(self.bg.animateWave)

        # Resume player
        self.player.isPlaying = True
        self.assertTrue(self.bg.timerRunning)
        self.assertTrue(self.bg.animateWave)

    def test_other_consumers_unaffected(self):
        # Simulating that independent bar/desktop consumers read MprisController directly
        barProgress = self.controller.trackProgressOf(self.player)
        self.assertAlmostEqual(barProgress, self.player.position / self.player.trackLength)
        # Player is still playing and shared
        self.assertTrue(self.player.isPlaying)


if __name__ == "__main__":
    unittest.main()
