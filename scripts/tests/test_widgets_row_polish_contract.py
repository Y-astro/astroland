#!/usr/bin/env python3
"""Contract test for WuWa Edit Desktop: Widget Row Polish & Interaction Clarity (Agent 3).
Verifies that widget entries in the Edit Desktop -> Widgets tab feature refined row-level
styling aligned with the WuWa B+ (Dense Jinzhou Frost) design language:
- 32x32 squircle icon container with centered glyphs for vertical alignment across rows
- Warm ivory title (13px, DemiBold when active) vs misty sage subtitle (11px) hierarchy
- 26x26 circular trailing action pill with clear plus/check semantics
- Darker inner row surface (colRowBg / colRowHover) with subtle antique-gold border
- Gold accents for active/installed states and hover states
- Preservation of click behavior and underlying logic"""

import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[2]


def source(rel_path: str) -> str:
    return (ROOT / rel_path).read_text(encoding="utf-8")


class WidgetsRowPolishContractTests(unittest.TestCase):
    def setUp(self):
        self.qml = source("modules/ii/editMode/WidgetEditorPanel.qml")

    def test_icon_tile_alignment_and_container(self):
        # Leading symbol sits inside a dedicated 32x32 container for pixel-perfect vertical alignment
        self.assertIn("id: iconTile", self.qml)
        self.assertIn("implicitWidth: 32", self.qml)
        self.assertIn("implicitHeight: 32", self.qml)
        self.assertIn("Appearance.rounding.verysmall", self.qml)
        self.assertIn("anchors.centerIn: parent", self.qml)
        self.assertIn("iconSize: 18", self.qml)

    def test_typography_hierarchy(self):
        # Title uses 13px warm ivory with weight differentiation on active rows
        self.assertIn("font.pixelSize: 13", self.qml)
        self.assertIn("font.weight: widgetRowWrapper.activeOrAdded ? Font.DemiBold : Font.Medium", self.qml)
        self.assertIn("SettingsTheme.colTextPrimary", self.qml)

        # Subtitle uses 11px misty sage with subtle opacity contrast
        self.assertIn("font.pixelSize: 11", self.qml)
        self.assertIn("SettingsTheme.colTextSecondary", self.qml)
        self.assertIn("opacity: widgetRowWrapper.activeOrAdded ? 0.90 : 0.75", self.qml)

    def test_trailing_action_badge(self):
        # Action badge is a 26x26 circular badge with distinct plus and check states
        self.assertIn("id: actionBadge", self.qml)
        self.assertIn("implicitWidth: 26", self.qml)
        self.assertIn("implicitHeight: 26", self.qml)
        self.assertIn("radius: 13", self.qml)
        self.assertIn('text: widgetRowWrapper.activeOrAdded ? "check" : "add"', self.qml)
        self.assertIn("iconSize: 15", self.qml)

    def test_inner_row_materials_and_hover(self):
        # Row uses SettingsTheme B+ tokens: colRowBg, colRowHover, colRowBorder
        self.assertIn("SettingsTheme.colRowBg", self.qml)
        self.assertIn("SettingsTheme.colRowHover", self.qml)
        self.assertIn("SettingsTheme.colRowBorder", self.qml)
        self.assertIn("SettingsTheme.rowBorderWidth", self.qml)
        self.assertIn("SettingsTheme.colAccent", self.qml)

    def test_click_and_selection_logic_preservation(self):
        # Preserves selectOrAdd invocation on row click
        self.assertIn("onClicked: root.selectOrAdd(widgetRowWrapper.widgetItem)", self.qml)
        self.assertIn("readonly property bool isSelected:", self.qml)


if __name__ == "__main__":
    unittest.main()
