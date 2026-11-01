#!/usr/bin/env python3
"""Contract and regression tests for Task U04: Bound text-fit binary search in SqueezedAnnotationStyledText."""

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WIDGET_PATH = ROOT / "modules/common/widgets/SqueezedAnnotationStyledText.qml"


class TestU04TextFitBinarySearch(unittest.TestCase):
    def setUp(self):
        self.code = WIDGET_PATH.read_text(encoding="utf-8")

    def test_subpixel_tolerance_bound(self):
        # 1. Loop converges to 0.05px subpixel tolerance instead of 0.00001px
        self.assertIn("upper - lower > 0.05", self.code)
        self.assertNotIn("upper - lower > 0.00001", self.code)

    def test_hard_iteration_cap(self):
        # 2. Hard iteration limit of 25 iterations is enforced
        self.assertIn("iterations++ < 25", self.code)
        self.assertIn("var iterations = 0", self.code)

    def test_lower_bound_selection_preservation(self):
        # 3. Lower bound is assigned to renderPixelSize to guarantee no clipping
        self.assertIn("root.renderPixelSize = lower", self.code)
        self.assertIn("upper = mid", self.code)
        self.assertIn("lower = mid", self.code)

    def test_lifecycle_and_searching_state_preservation(self):
        # 4. Searching flag is asserted before search and released after
        self.assertIn("root.searching = true;", self.code)
        self.assertIn("root.searching = false;", self.code)
        self.assertIn("root.visible = true", self.code)

    def test_no_styling_or_typography_alterations(self):
        # 5. Visual styling, fonts, and colors remain untouched
        self.assertIn("property real maxFontPixelSize: 100", self.code)
        self.assertIn("property real scaleFactor: 1.0", self.code)
        self.assertIn("property alias font: textWidget.font", self.code)
        self.assertIn("property alias color: textWidget.color", self.code)
        self.assertIn("renderType: Text.QtRendering", self.code)
        self.assertIn("wrapMode: Text.Wrap", self.code)


if __name__ == "__main__":
    unittest.main()
