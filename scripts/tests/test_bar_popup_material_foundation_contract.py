from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]
RESONANCE_PATH = ROOT / "modules" / "common" / "ResonanceTheme.qml"
POPUP_THEME_PATH = ROOT / "modules" / "common" / "BarPopupTheme.qml"
POPUP_CARD_PATH = ROOT / "modules" / "ii" / "bar" / "shared" / "BarPopupCard.qml"
STYLED_POPUP_PATH = ROOT / "modules" / "ii" / "bar" / "shared" / "StyledPopup.qml"
HEADER_ROW_PATH = ROOT / "modules" / "ii" / "bar" / "shared" / "StyledPopupHeaderRow.qml"
VALUE_ROW_PATH = ROOT / "modules" / "ii" / "bar" / "shared" / "StyledPopupValueRow.qml"
SECTION_CARD_PATH = ROOT / "modules" / "ii" / "bar" / "shared" / "cards" / "SectionCard.qml"
HERO_CARD_PATH = ROOT / "modules" / "ii" / "bar" / "shared" / "cards" / "HeroCard.qml"


class BarPopupMaterialFoundationContractTest(unittest.TestCase):
    def setUp(self):
        self.resonance_text = RESONANCE_PATH.read_text(encoding="utf-8")
        self.popup_theme_text = POPUP_THEME_PATH.read_text(encoding="utf-8")
        self.popup_card_text = POPUP_CARD_PATH.read_text(encoding="utf-8")
        self.styled_popup_text = STYLED_POPUP_PATH.read_text(encoding="utf-8")
        self.header_row_text = HEADER_ROW_PATH.read_text(encoding="utf-8")
        self.value_row_text = VALUE_ROW_PATH.read_text(encoding="utf-8")
        self.section_card_text = SECTION_CARD_PATH.read_text(encoding="utf-8")
        self.hero_card_text = HERO_CARD_PATH.read_text(encoding="utf-8")

    def test_resonance_theme_defines_popup_tokens(self):
        self.assertIn("readonly property color bgGlassPopup:", self.resonance_text)
        self.assertIn("readonly property color bgGlassPopupCard:", self.resonance_text)
        self.assertIn("readonly property color bgGlassPopupCardHover:", self.resonance_text)
        self.assertIn("readonly property color bgGlassPopupCardActive:", self.resonance_text)
        self.assertIn("readonly property color bgGlassPopupDivider:", self.resonance_text)

    def test_bar_popup_theme_defines_palette_and_metrics(self):
        # Surface colors
        self.assertIn("readonly property color colBackground:", self.popup_theme_text)
        self.assertIn("readonly property color colCardBackground:", self.popup_theme_text)
        self.assertIn("readonly property color colCardBackgroundLow:", self.popup_theme_text)
        self.assertIn("readonly property color colCardBackgroundHover:", self.popup_theme_text)
        self.assertIn("readonly property color colCardBackgroundActive:", self.popup_theme_text)
        self.assertIn("readonly property color colDivider:", self.popup_theme_text)

        # Borders
        self.assertIn("readonly property real borderWidth:", self.popup_theme_text)
        self.assertIn("readonly property color colBorder:", self.popup_theme_text)
        self.assertIn("readonly property real cardBorderWidth:", self.popup_theme_text)
        self.assertIn("readonly property color colCardBorder:", self.popup_theme_text)

        # Radii
        self.assertIn("readonly property real radiusPopup:", self.popup_theme_text)
        self.assertIn("readonly property real radiusCard:", self.popup_theme_text)

        # Typography
        self.assertIn("readonly property color colTextPrimary:", self.popup_theme_text)
        self.assertIn("readonly property color colTextSecondary:", self.popup_theme_text)
        self.assertIn("readonly property color colTextTertiary:", self.popup_theme_text)
        self.assertIn("readonly property color colAccent:", self.popup_theme_text)

        # Shadow control
        self.assertIn("readonly property bool showShadow:", self.popup_theme_text)

    def test_styled_popup_uses_bar_popup_theme(self):
        self.assertIn("color: BarPopupTheme.colBackground", self.styled_popup_text)
        self.assertIn("border.width: BarPopupTheme.borderWidth", self.styled_popup_text)
        self.assertIn("border.color: BarPopupTheme.colBorder", self.styled_popup_text)
        self.assertIn("visible: BarPopupTheme.showShadow", self.styled_popup_text)
        self.assertIn("property int popupRadius: BarPopupTheme.radiusPopup", self.styled_popup_text)

    def test_shared_rows_use_bar_popup_theme(self):
        self.assertIn("BarPopupTheme.colTextSecondary", self.header_row_text)
        self.assertIn("BarPopupTheme.colTextPrimary", self.header_row_text)
        self.assertIn("BarPopupTheme.colAccent", self.value_row_text)
        self.assertIn("BarPopupTheme.colTextSecondary", self.value_row_text)
        self.assertIn("BarPopupTheme.colTextPrimary", self.value_row_text)

    def test_shared_cards_use_bar_popup_theme(self):
        self.assertIn("BarPopupTheme.radiusCard", self.section_card_text)
        self.assertIn("BarPopupTheme.colCardBackground", self.section_card_text)
        self.assertIn("BarPopupTheme.cardBorderWidth", self.section_card_text)
        self.assertIn("BarPopupTheme.colCardBorder", self.section_card_text)
        self.assertIn("BarPopupTheme.colTextPrimary", self.section_card_text)

        self.assertIn("BarPopupTheme.radiusCard", self.hero_card_text)
        self.assertIn("BarPopupTheme.colCardBackground", self.hero_card_text)
        self.assertIn("BarPopupTheme.cardBorderWidth", self.hero_card_text)
        self.assertIn("BarPopupTheme.colCardBorder", self.hero_card_text)

    def test_bar_popup_card_component(self):
        self.assertIn("BarPopupTheme.radiusCard", self.popup_card_text)
        self.assertIn("BarPopupTheme.colCardBackground", self.popup_card_text)
        self.assertIn("BarPopupTheme.colCardBorder", self.popup_card_text)


if __name__ == "__main__":
    unittest.main()
