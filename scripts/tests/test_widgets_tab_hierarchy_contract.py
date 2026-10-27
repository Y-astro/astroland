#!/usr/bin/env python3
"""Contract test for WuWa Edit Desktop: Widgets Tab Segmentation & Hierarchy.
Verifies that the Widgets tab mirrors the structural language of the Bar tab,
employing 3-tier depth (shell -> section cards -> item rows), distinct category
blocks with headers, count pills, collapse/expand affordances, and styled installed rows."""

import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[2]


def source(rel_path: str) -> str:
    return (ROOT / rel_path).read_text(encoding="utf-8")


class WidgetsTabHierarchyContractTests(unittest.TestCase):
    def setUp(self):
        self.qml = source("modules/ii/editMode/WidgetEditorPanel.qml")

    def test_structural_sibling_with_bar_tab(self):
        # NoticeBox is used at the top of the widgets tab for structural parity with the Bar tab
        self.assertIn("NoticeBox {", self.qml)
        self.assertIn('materialIcon: "drag_indicator"', self.qml)

    def test_scroll_container_uses_styled_flickable(self):
        self.assertIn("StyledFlickable {", self.qml)
        self.assertIn("id: catalogFlickable", self.qml)
        self.assertIn("readonly property alias catalogFlickable: catalogFlickable", self.qml)

    def test_category_ordering_and_segmentation(self):
        # Clocks and Date are prioritized and distinct
        self.assertIn('"Clock"', self.qml)
        self.assertIn('"Date"', self.qml)
        self.assertIn("categoryOrder:", self.qml)
        self.assertIn("categoriesModel:", self.qml)

    def test_section_card_tier(self):
        # Category card container styling adheres to 3-tier depth
        self.assertIn("id: categoryCard", self.qml)
        self.assertIn("SettingsTheme.colCardBg", self.qml)
        self.assertIn("SettingsTheme.colCardBorder", self.qml)
        self.assertIn("SettingsTheme.cardBorderWidth", self.qml)
        self.assertIn("Appearance.rounding.normal", self.qml)

    def test_category_header_structure(self):
        # Header includes category icon, title, count pill, and collapse chevron
        self.assertIn("id: categoryHeaderBtn", self.qml)
        self.assertIn("categoryCard.categoryData.icon", self.qml)
        self.assertIn("categoryCard.categoryData.title", self.qml)
        self.assertIn("categoryCard.categoryData.widgets.length", self.qml)
        self.assertIn("keyboard_arrow_down", self.qml)
        self.assertIn("categoryCard.isCollapsed", self.qml)

    def test_widget_row_tier_and_installed_distinction(self):
        # Internal rows have distinct active/installed states and plus/check semantics
        self.assertIn("id: widgetRowBtn", self.qml)
        self.assertIn("activeOrAdded", self.qml)
        self.assertIn('activeOrAdded ? "check" : "add"', self.qml)
        self.assertIn("SettingsTheme.colRowBg", self.qml)
        self.assertIn("SettingsTheme.colRowBorder", self.qml)

    def test_underlying_logic_preservation(self):
        # Preserves core selection and addition methods
        self.assertIn("function selectOrAdd(widget)", self.qml)
        self.assertIn("function add(widget)", self.qml)
        self.assertIn("function duplicate()", self.qml)
        self.assertIn("function removeSelection()", self.qml)
        self.assertIn("function toggleCategory(cat)", self.qml)


if __name__ == "__main__":
    unittest.main()
