from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]
RESOURCE_CARD_PATH = ROOT / "modules" / "common" / "widgets" / "ResourceCard.qml"
RESOURCES_POPUP_PATH = ROOT / "modules" / "ii" / "bar" / "ResourcesPopup.qml"
ACTIVE_WINDOW_POPUP_PATH = ROOT / "modules" / "ii" / "bar" / "popups" / "activeWindow" / "ActiveWindowPopup.qml"
EXPRESSIVE_RESOURCES_POPUP_PATH = ROOT / "modules" / "ii" / "bar" / "popups" / "resources" / "ExpressiveResourcesPopup.qml"
COMMON_STYLED_POPUP_PATH = ROOT / "modules" / "common" / "widgets" / "StyledPopup.qml"


class BarPopupLeftClusterContractTest(unittest.TestCase):
    def setUp(self):
        self.resource_card_text = RESOURCE_CARD_PATH.read_text(encoding="utf-8")
        self.resources_popup_text = RESOURCES_POPUP_PATH.read_text(encoding="utf-8")
        self.active_window_popup_text = ACTIVE_WINDOW_POPUP_PATH.read_text(encoding="utf-8")
        self.expressive_resources_popup_text = EXPRESSIVE_RESOURCES_POPUP_PATH.read_text(encoding="utf-8")
        self.common_styled_popup_text = COMMON_STYLED_POPUP_PATH.read_text(encoding="utf-8")

    def test_resource_card_uses_bar_popup_theme(self):
        # Card container & geometry
        self.assertIn("radius: BarPopupTheme.radiusCard", self.resource_card_text)
        self.assertIn("BarPopupTheme.colCardBackground", self.resource_card_text)
        self.assertIn("BarPopupTheme.cardBorderWidth", self.resource_card_text)
        self.assertIn("BarPopupTheme.colCardBorder", self.resource_card_text)

        # Typography & accents
        self.assertIn("color: BarPopupTheme.colTextPrimary", self.resource_card_text)
        self.assertIn("color: BarPopupTheme.colTextSecondary", self.resource_card_text)
        self.assertIn("return BarPopupTheme.colAccent", self.resource_card_text)
        self.assertIn("BarPopupTheme.colCardBackgroundLow", self.resource_card_text)

    def test_resources_popup_uses_bar_popup_theme(self):
        self.assertIn("BarPopupTheme.spacingHorizontal", self.resources_popup_text)
        self.assertIn("BarPopupTheme.spacingVertical", self.resources_popup_text)
        self.assertIn("BarPopupTheme.colAccent", self.resources_popup_text)
        self.assertIn("BarPopupTheme.colTextSecondary", self.resources_popup_text)

    def test_active_window_popup_uses_bar_popup_theme(self):
        self.assertIn("radius: BarPopupTheme.radiusCard", self.active_window_popup_text)
        self.assertIn("color: BarPopupTheme.colCardBackground", self.active_window_popup_text)
        self.assertIn("border.width: BarPopupTheme.cardBorderWidth", self.active_window_popup_text)
        self.assertIn("border.color: BarPopupTheme.colCardBorder", self.active_window_popup_text)
        self.assertIn("color: BarPopupTheme.colTextPrimary", self.active_window_popup_text)
        self.assertIn("color: BarPopupTheme.colDivider", self.active_window_popup_text)
        self.assertIn("color: BarPopupTheme.colTextSecondary", self.active_window_popup_text)

    def test_expressive_resources_popup_uses_bar_popup_theme(self):
        self.assertIn("radius: BarPopupTheme.radiusCard", self.expressive_resources_popup_text)
        self.assertIn("color: BarPopupTheme.colCardBackground", self.expressive_resources_popup_text)
        self.assertIn("border.width: BarPopupTheme.cardBorderWidth", self.expressive_resources_popup_text)
        self.assertIn("border.color: BarPopupTheme.colCardBorder", self.expressive_resources_popup_text)
        self.assertIn("color: BarPopupTheme.colTextPrimary", self.expressive_resources_popup_text)
        self.assertIn("color: BarPopupTheme.colTextSecondary", self.expressive_resources_popup_text)

    def test_common_styled_popup_uses_bar_popup_theme(self):
        self.assertIn("color: BarPopupTheme.colBackground", self.common_styled_popup_text)
        self.assertIn("radius: BarPopupTheme.radiusPopup", self.common_styled_popup_text)
        self.assertIn("border.width: BarPopupTheme.borderWidth", self.common_styled_popup_text)
        self.assertIn("border.color: BarPopupTheme.colBorder", self.common_styled_popup_text)
        self.assertIn("visible: BarPopupTheme.showShadow", self.common_styled_popup_text)


if __name__ == "__main__":
    unittest.main()
