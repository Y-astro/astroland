#!/usr/bin/env python3
"""Contract and regression tests for Task U13: Notification group-dismissal batching."""

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
NOTIFICATION_GROUP_PATH = ROOT / "modules/common/widgets/NotificationGroup.qml"
NOTIFICATIONS_SERVICE_PATH = ROOT / "services/Notifications.qml"


class TestU13NotificationBatchDismissal(unittest.TestCase):
    def setUp(self):
        self.notif_group = NOTIFICATION_GROUP_PATH.read_text(encoding="utf-8")
        self.notif_service = NOTIFICATIONS_SERVICE_PATH.read_text(encoding="utf-8")

    def test_notification_group_batch_dismiss_contract(self):
        # 1. onFinished maps IDs and calls discardNotifications once
        self.assertIn("const ids = root.notifications.map((notif) => notif.notificationId);", self.notif_group)
        self.assertIn("Qt.callLater(() => Notifications.discardNotifications(ids));", self.notif_group)

        # 2. No iterative discardNotification loop in destroyAnimation
        self.assertNotIn("root.notifications.forEach((notif) => {", self.notif_group)

    def test_notifications_service_batch_dismiss_definition(self):
        # 3. discardNotifications function exists and builds idSet
        self.assertIn("function discardNotifications(ids) {", self.notif_service)
        self.assertIn("const idSet = new Set(ids);", self.notif_service)

        # 4. Filters list and persists once
        self.assertIn("root.list = remaining;", self.notif_service)
        self.assertIn("notifFileView.setText(stringifyList(root.list));", self.notif_service)

        # 5. Dismisses tracked server notifications
        self.assertIn("if (externalNotif?.tracked) {", self.notif_service)
        self.assertIn("externalNotif.dismiss();", self.notif_service)

        # 6. Emits per-ID discard signals
        self.assertIn("idSet.forEach((id) => root.discard(id));", self.notif_service)

    def test_single_discard_delegation(self):
        # 7. discardNotification(id) forwards to root.discardNotifications([id])
        self.assertIn("function discardNotification(id) {", self.notif_service)
        self.assertIn("root.discardNotifications([id]);", self.notif_service)

    def test_batch_alias_preservation(self):
        # 8. discardNotificationBatch alias exists for compatibility
        self.assertIn("function discardNotificationBatch(ids) {", self.notif_service)
        self.assertIn("root.discardNotifications(ids);", self.notif_service)

    def test_timer_cancellation_and_stale_timer_guard(self):
        # 9. Active timer stopped and destroyed on discard
        self.assertIn("notif.timer.stop();", self.notif_service)
        self.assertIn("notif.timer.destroy();", self.notif_service)

        # 10. Stale timer guard intact in NotifTimer component
        self.assertIn("if (!notifObject) {", self.notif_service)
        self.assertIn("destroy();", self.notif_service)
        self.assertIn("return;", self.notif_service)

    def test_clear_all_and_dnd_preservation(self):
        # 11. discardAllNotifications untouched
        self.assertIn("function discardAllNotifications() {", self.notif_service)
        self.assertIn("root.discardAll();", self.notif_service)

        # 12. popupInhibited and silent logic preserved
        self.assertIn("property bool silent: false", self.notif_service)
        self.assertIn("property bool popupInhibited: (GlobalStates?.sidebarRightOpen ?? false) || silent", self.notif_service)


if __name__ == "__main__":
    unittest.main()
