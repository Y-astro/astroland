from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]
CLOCK_POPUP_BAR_PATH = ROOT / "modules" / "ii" / "bar" / "ClockWidgetPopup.qml"
CLOCK_POPUP_MODERN_PATH = ROOT / "modules" / "ii" / "bar" / "popups" / "clock" / "ClockWidgetPopup.qml"
CLOCK_HEADER_CARD_PATH = ROOT / "modules" / "ii" / "bar" / "shared" / "cards" / "ClockHeaderCard.qml"
INFO_PILL_PATH = ROOT / "modules" / "ii" / "bar" / "shared" / "cards" / "InfoPill.qml"
LOCALSEND_PILL_PATH = ROOT / "modules" / "ii" / "bar" / "shared" / "cards" / "LocalSendPill.qml"
ALARMS_CARD_PATH = ROOT / "modules" / "ii" / "bar" / "shared" / "cards" / "AlarmsCard.qml"
WORLD_CLOCKS_CARD_PATH = ROOT / "modules" / "ii" / "bar" / "shared" / "cards" / "WorldClocksCard.qml"
MEDIA_CONTROLS_PATH = ROOT / "modules" / "ii" / "mediaControls" / "MediaControls.qml"
PLAYER_PATH = ROOT / "modules" / "common" / "widgets" / "Player.qml"
PLAYER_CONTROLS_PATH = ROOT / "modules" / "common" / "widgets" / "PlayerControls.qml"
MEDIA_POPUP_PATH = ROOT / "modules" / "ii" / "bar" / "popups" / "media" / "MediaPopup.qml"


class CenterClusterPopupsContractTest(unittest.TestCase):
    def setUp(self):
        self.clock_popup_bar = CLOCK_POPUP_BAR_PATH.read_text(encoding="utf-8")
        self.clock_popup_modern = CLOCK_POPUP_MODERN_PATH.read_text(encoding="utf-8")
        self.clock_header_card = CLOCK_HEADER_CARD_PATH.read_text(encoding="utf-8")
        self.info_pill = INFO_PILL_PATH.read_text(encoding="utf-8")
        self.localsend_pill = LOCALSEND_PILL_PATH.read_text(encoding="utf-8")
        self.alarms_card = ALARMS_CARD_PATH.read_text(encoding="utf-8")
        self.world_clocks_card = WORLD_CLOCKS_CARD_PATH.read_text(encoding="utf-8")
        self.media_controls = MEDIA_CONTROLS_PATH.read_text(encoding="utf-8")
        self.player = PLAYER_PATH.read_text(encoding="utf-8")
        self.player_controls = PLAYER_CONTROLS_PATH.read_text(encoding="utf-8")
        self.media_popup = MEDIA_POPUP_PATH.read_text(encoding="utf-8")

    def test_clock_calendar_popup_uses_bar_popup_theme(self):
        self.assertIn("BarPopupTheme.colTextPrimary", self.clock_popup_bar)
        self.assertIn("BarPopupTheme.colTextSecondary", self.clock_popup_bar)
        self.assertIn("BarPopupTheme.colCardBackground", self.clock_popup_bar)
        self.assertIn("BarPopupTheme.colCardBackgroundActive", self.clock_popup_bar)
        self.assertIn("BarPopupTheme.colCardBorder", self.clock_popup_bar)
        self.assertIn("BarPopupTheme.cardBorderWidth", self.clock_popup_bar)
        self.assertIn("BarPopupTheme.colAccent", self.clock_popup_bar)

    def test_modern_clock_popup_and_subcards(self):
        self.assertIn("BarPopupTheme.colCardBackgroundActive", self.clock_popup_modern)
        self.assertIn("BarPopupTheme.colTextPrimary", self.clock_popup_modern)
        self.assertIn("BarPopupTheme.colAccent", self.clock_popup_modern)

        # ClockHeaderCard
        self.assertIn("BarPopupTheme.isWuWa ? ResonanceTheme.bgGlassPopupCardElevated", self.clock_header_card)

        # InfoPill
        self.assertIn("border.width: BarPopupTheme.cardBorderWidth", self.info_pill)
        self.assertIn("border.color: BarPopupTheme.colCardBorder", self.info_pill)

        # LocalSendPill
        self.assertIn("BarPopupTheme.isWuWa", self.localsend_pill)
        self.assertIn("BarPopupTheme.colCardBackground", self.localsend_pill)
        self.assertIn("BarPopupTheme.colTextPrimary", self.localsend_pill)

        # AlarmsCard
        self.assertIn("BarPopupTheme.radiusCard", self.alarms_card)
        self.assertIn("BarPopupTheme.colCardBackground", self.alarms_card)
        self.assertIn("BarPopupTheme.cardBorderWidth", self.alarms_card)
        self.assertIn("BarPopupTheme.colCardBorder", self.alarms_card)
        self.assertIn("BarPopupTheme.colTextPrimary", self.alarms_card)
        self.assertIn("BarPopupTheme.colTextSecondary", self.alarms_card)

        # WorldClocksCard
        self.assertIn("BarPopupTheme.radiusCard", self.world_clocks_card)
        self.assertIn("BarPopupTheme.colCardBackgroundElevated", self.world_clocks_card)
        self.assertIn("BarPopupTheme.cardBorderWidth", self.world_clocks_card)
        self.assertIn("BarPopupTheme.colCardBorder", self.world_clocks_card)
        self.assertIn("BarPopupTheme.colTextPrimary", self.world_clocks_card)

    def test_media_controls_and_empty_state(self):
        # MediaControls empty state
        self.assertIn("color: BarPopupTheme.colBackground", self.media_controls)
        self.assertIn("border.width: BarPopupTheme.borderWidth", self.media_controls)
        self.assertIn("border.color: BarPopupTheme.colBorder", self.media_controls)
        self.assertIn("color: BarPopupTheme.colAccent", self.media_controls)
        self.assertIn("color: BarPopupTheme.colTextPrimary", self.media_controls)
        self.assertIn("color: BarPopupTheme.colTextSecondary", self.media_controls)

        # Player
        self.assertIn("color: BarPopupTheme.isWuWa ? BarPopupTheme.colBackground", self.player)
        self.assertIn("border.width: BarPopupTheme.borderWidth", self.player)
        self.assertIn("border.color: BarPopupTheme.colBorder", self.player)
        self.assertIn("color: BarPopupTheme.isWuWa ? BarPopupTheme.colAccent", self.player)

        # PlayerControls
        self.assertIn("BarPopupTheme.isWuWa ? BarPopupTheme.colTextPrimary", self.player_controls)
        self.assertIn("BarPopupTheme.isWuWa ? BarPopupTheme.colTextSecondary", self.player_controls)
        self.assertIn("BarPopupTheme.isWuWa ? BarPopupTheme.colAccent", self.player_controls)

        # MediaPopup
        self.assertIn("popupRadius: BarPopupTheme.radiusPopup", self.media_popup)


if __name__ == "__main__":
    unittest.main()
