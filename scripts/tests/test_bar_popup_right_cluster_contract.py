from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]
POPUP_THEME_PATH = ROOT / "modules" / "common" / "BarPopupTheme.qml"
BATTERY_POPUP_PATH = ROOT / "modules" / "ii" / "bar" / "BatteryPopup.qml"
BATTERY_POPUP_POPUP_PATH = ROOT / "modules" / "ii" / "bar" / "popups" / "battery" / "BatteryPopup.qml"
RESOURCE_CARD_PATH = ROOT / "modules" / "common" / "widgets" / "ResourceCard.qml"
BLUETOOTH_POPUP_PATH = ROOT / "modules" / "ii" / "bar" / "BluetoothPopup.qml"
BLUETOOTH_DEVICES_POPUP_PATH = ROOT / "modules" / "ii" / "bar" / "popups" / "bluetooth" / "BluetoothDevicesPopup.qml"
EXPRESSIVE_BLUETOOTH_POPUP_PATH = ROOT / "modules" / "ii" / "bar" / "popups" / "bluetooth" / "ExpressiveBluetoothDevicesPopup.qml"
SYSTRAY_MENU_PATH = ROOT / "modules" / "ii" / "bar" / "SysTrayMenu.qml"
SYSTRAY_ENTRY_PATH = ROOT / "modules" / "ii" / "bar" / "SysTrayMenuEntry.qml"
NETWORK_POPUP_PATH = ROOT / "modules" / "ii" / "bar" / "NetworkSpeedPopup.qml"


class BarPopupRightClusterContractTest(unittest.TestCase):
    def setUp(self):
        self.popup_theme_text = POPUP_THEME_PATH.read_text(encoding="utf-8")
        self.battery_popup_text = BATTERY_POPUP_PATH.read_text(encoding="utf-8")
        self.battery_popup_popup_text = BATTERY_POPUP_POPUP_PATH.read_text(encoding="utf-8")
        self.resource_card_text = RESOURCE_CARD_PATH.read_text(encoding="utf-8")
        self.bluetooth_popup_text = BLUETOOTH_POPUP_PATH.read_text(encoding="utf-8")
        self.bluetooth_devices_text = BLUETOOTH_DEVICES_POPUP_PATH.read_text(encoding="utf-8")
        self.expressive_bluetooth_text = EXPRESSIVE_BLUETOOTH_POPUP_PATH.read_text(encoding="utf-8")
        self.systray_menu_text = SYSTRAY_MENU_PATH.read_text(encoding="utf-8")
        self.systray_entry_text = SYSTRAY_ENTRY_PATH.read_text(encoding="utf-8")
        self.network_popup_text = NETWORK_POPUP_PATH.read_text(encoding="utf-8")

    def test_bar_popup_theme_defines_meters_and_state_tokens(self):
        self.assertIn("readonly property color colTrack:", self.popup_theme_text)
        self.assertIn("readonly property color colTrackBorder:", self.popup_theme_text)
        self.assertIn("readonly property color colWarning:", self.popup_theme_text)
        self.assertIn("readonly property color colError:", self.popup_theme_text)
        self.assertIn("readonly property color colIconContainer:", self.popup_theme_text)

    def test_battery_popups_use_bar_popup_theme(self):
        # Root BatteryPopup
        self.assertIn("BarPopupTheme.colIconContainer", self.battery_popup_text)
        self.assertIn("BarPopupTheme.colTextPrimary", self.battery_popup_text)
        self.assertIn("BarPopupTheme.colTextSecondary", self.battery_popup_text)
        self.assertIn("BarPopupTheme.colAccent", self.battery_popup_text)

        # Detailed popups/battery/BatteryPopup
        self.assertIn("BarPopupTheme.radiusCard", self.battery_popup_popup_text)
        self.assertIn("BarPopupTheme.colCardBackground", self.battery_popup_popup_text)
        self.assertIn("BarPopupTheme.cardBorderWidth", self.battery_popup_popup_text)
        self.assertIn("BarPopupTheme.colCardBorder", self.battery_popup_popup_text)
        self.assertIn("BarPopupTheme.colTextPrimary", self.battery_popup_popup_text)
        self.assertIn("BarPopupTheme.colTextSecondary", self.battery_popup_popup_text)
        self.assertIn("BarPopupTheme.colTextTertiary", self.battery_popup_popup_text)
        self.assertIn("BarPopupTheme.colTrack", self.battery_popup_popup_text)
        self.assertIn("BarPopupTheme.colDivider", self.battery_popup_popup_text)

    def test_resource_card_uses_bar_popup_theme(self):
        self.assertIn("BarPopupTheme.colCardBackground", self.resource_card_text)
        self.assertIn("BarPopupTheme.cardBorderWidth", self.resource_card_text)
        self.assertIn("BarPopupTheme.colCardBorder", self.resource_card_text)
        self.assertIn("BarPopupTheme.radiusCard", self.resource_card_text)
        self.assertIn("BarPopupTheme.colAccent", self.resource_card_text)
        self.assertIn("BarPopupTheme.colTextPrimary", self.resource_card_text)
        self.assertIn("BarPopupTheme.colTextSecondary", self.resource_card_text)
        self.assertIn("BarPopupTheme.colTrack", self.resource_card_text)

    def test_bluetooth_popups_use_bar_popup_theme(self):
        # Root BluetoothPopup
        self.assertIn("BarPopupTheme.radiusCard", self.bluetooth_popup_text)
        self.assertIn("BarPopupTheme.colCardBackground", self.bluetooth_popup_text)
        self.assertIn("BarPopupTheme.colCardBorder", self.bluetooth_popup_text)
        self.assertIn("BarPopupTheme.colTextPrimary", self.bluetooth_popup_text)
        self.assertIn("BarPopupTheme.colTextSecondary", self.bluetooth_popup_text)
        self.assertIn("BarPopupTheme.colAccent", self.bluetooth_popup_text)

        # BluetoothDevicesPopup
        self.assertIn("BarPopupTheme.radiusCard", self.bluetooth_devices_text)
        self.assertIn("BarPopupTheme.colCardBackground", self.bluetooth_devices_text)
        self.assertIn("BarPopupTheme.colCardBorder", self.bluetooth_devices_text)
        self.assertIn("BarPopupTheme.colTextPrimary", self.bluetooth_devices_text)
        self.assertIn("BarPopupTheme.colTextSecondary", self.bluetooth_devices_text)
        self.assertIn("BarPopupTheme.colAccent", self.bluetooth_devices_text)
        self.assertIn("BarPopupTheme.colTrack", self.bluetooth_devices_text)

        # ExpressiveBluetoothDevicesPopup
        self.assertIn("BarPopupTheme.colCardBackground", self.expressive_bluetooth_text)
        self.assertIn("BarPopupTheme.colTextPrimary", self.expressive_bluetooth_text)
        self.assertIn("BarPopupTheme.colAccent", self.expressive_bluetooth_text)
        self.assertIn("BarPopupTheme.cardBorderWidth", self.expressive_bluetooth_text)
        self.assertIn("BarPopupTheme.colCardBorder", self.expressive_bluetooth_text)

    def test_systray_popups_use_bar_popup_theme(self):
        # SysTrayMenu
        self.assertIn("BarPopupTheme.colBackground", self.systray_menu_text)
        self.assertIn("BarPopupTheme.radiusCard", self.systray_menu_text)
        self.assertIn("BarPopupTheme.borderWidth", self.systray_menu_text)
        self.assertIn("BarPopupTheme.colBorder", self.systray_menu_text)
        self.assertIn("BarPopupTheme.colDivider", self.systray_menu_text)
        self.assertIn("BarPopupTheme.colTextPrimary", self.systray_menu_text)
        self.assertIn("BarPopupTheme.colAccent", self.systray_menu_text)

        # SysTrayMenuEntry
        self.assertIn("BarPopupTheme.colDivider", self.systray_entry_text)
        self.assertIn("BarPopupTheme.colCardBackground", self.systray_entry_text)
        self.assertIn("BarPopupTheme.colTextPrimary", self.systray_entry_text)
        self.assertIn("BarPopupTheme.colAccent", self.systray_entry_text)

    def test_network_speed_popup_uses_bar_popup_theme(self):
        self.assertIn("BarPopupTheme.colCardBackground", self.network_popup_text)
        self.assertIn("BarPopupTheme.cardBorderWidth", self.network_popup_text)
        self.assertIn("BarPopupTheme.colCardBorder", self.network_popup_text)
        self.assertIn("BarPopupTheme.colTextPrimary", self.network_popup_text)
        self.assertIn("BarPopupTheme.colTextSecondary", self.network_popup_text)
        self.assertIn("BarPopupTheme.colAccent", self.network_popup_text)


if __name__ == "__main__":
    unittest.main()
