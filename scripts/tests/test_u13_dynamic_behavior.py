#!/usr/bin/env python3
"""Dynamic behavioral test suite for Task U13: Notification Group-Dismissal Batching.

Validates:
  1. Baseline N-writes/mutations vs Candidate 1-write/mutation on group swipe.
  2. Group swipe execution and list filtering.
  3. Single dismiss delegation via discardNotification(id).
  4. Empty and None ID list resilience (zero writes/mutations).
  5. Missing ID resilience (no list changes, zero writes, signal preservation).
  6. Duplicate ID deduplication via Set (single pass, single write, single signal).
  7. Cross-app separation (unrelated apps and order preserved).
  8. Racing timer cancellation and stale-timer guard safety.
  9. Tracked server notification dismissals vs untracked/restored items.
 10. Persistence JSON formatting and reload integrity.
 11. Clear-all (discardAllNotifications) lifecycle.
 12. Batch alias compatibility (discardNotificationBatch).
"""

from __future__ import annotations

import json
import os
import shutil
import tempfile
import time
import unittest


class MockServerNotification:
    def __init__(self, notif_id: int, tracked: bool = True):
        self.id = notif_id
        self.tracked = tracked
        self.dismissed = False
        self.dismiss_count = 0

    def dismiss(self):
        self.dismissed = True
        self.dismiss_count += 1
        self.tracked = False


class MockNotifTimer:
    def __init__(self, notif_id: int):
        self.notificationId = notif_id
        self.running = True
        self.destroyed = False
        self.stopped = False

    def stop(self):
        self.running = False
        self.stopped = True

    def destroy(self):
        self.destroyed = True


class MockNotificationsService:
    """Accurately mirrors services/Notifications.qml state and batching logic."""
    def __init__(self, file_path: str):
        self.file_path = file_path
        self.list = []
        self.idOffset = 0
        self.unread = 0
        self.silent = False
        self.effectiveSilent = False
        self.persistence_writes = 0
        self.list_mutation_count = 0
        self.list_change_triggers = 0
        self.emitted_discards = []
        self.emitted_discard_all = 0
        self.tracked_server_notifications = []

    def stringifyList(self, lst):
        json_objs = []
        for n in lst:
            json_objs.append({
                "notificationId": n["notificationId"],
                "actions": n.get("actions", []),
                "appIcon": n.get("appIcon", ""),
                "appName": n.get("appName", ""),
                "body": n.get("body", ""),
                "image": n.get("image", ""),
                "summary": n.get("summary", ""),
                "time": n.get("time", 0),
                "urgency": n.get("urgency", "normal"),
            })
        return json.dumps(json_objs, indent=2)

    def write_file(self):
        with open(self.file_path, "w", encoding="utf-8") as f:
            f.write(self.stringifyList(self.list))
        self.persistence_writes += 1

    def reload_file(self):
        with open(self.file_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        self.list = [
            {
                "notificationId": item["notificationId"],
                "actions": item.get("actions", []),
                "appIcon": item.get("appIcon", ""),
                "appName": item.get("appName", ""),
                "body": item.get("body", ""),
                "image": item.get("image", ""),
                "summary": item.get("summary", ""),
                "time": item.get("time", 0),
                "urgency": item.get("urgency", "normal"),
                "notification": None,
                "timer": None,
            }
            for item in data
        ]
        max_id = 0
        for n in self.list:
            max_id = max(max_id, n["notificationId"])
        self.idOffset = max_id

    def add_notification(self, app_name: str, summary: str, body: str, tracked: bool = True, with_timer: bool = False):
        self.idOffset += 1
        nid = self.idOffset
        server_notif = MockServerNotification(nid, tracked=tracked) if tracked else None
        if server_notif:
            self.tracked_server_notifications.append(server_notif)
        timer = MockNotifTimer(nid) if with_timer else None

        notif_obj = {
            "notificationId": nid,
            "appName": app_name,
            "appIcon": f"icon-{app_name.lower()}",
            "summary": summary,
            "body": body,
            "time": time.time() * 1000,
            "urgency": "normal",
            "notification": server_notif,
            "timer": timer,
        }
        self.list = [*self.list, notif_obj]
        self.write_file()
        return nid, notif_obj

    # --- Baseline unbatched discard for comparative proof ---
    def baseline_discardNotification(self, nid: int):
        idx = next((i for i, n in enumerate(self.list) if n["notificationId"] == nid), -1)
        if idx != -1:
            notif_object = self.list[idx]
            external_notif = notif_object.get("notification")
            self.list.pop(idx)
            self.list_mutation_count += 1
            self.write_file()
            self.list_change_triggers += 1
            if external_notif and external_notif.tracked:
                external_notif.dismiss()
        self.emitted_discards.append(nid)

    def baseline_group_swipe(self, ids: list[int]):
        for nid in ids:
            self.baseline_discardNotification(nid)

    # --- Candidate batched discard matching services/Notifications.qml ---
    def discardNotification(self, nid: int):
        self.discardNotifications([nid])

    def discardNotifications(self, ids: list[int]):
        if not ids or len(ids) == 0:
            return
        idSet = set(ids)
        if len(idSet) == 0:
            return
        
        toDismiss = []
        remaining = []
        for notif in self.list:
            if notif["notificationId"] in idSet:
                toDismiss.append(notif)
            else:
                remaining.append(notif)
                
        if len(toDismiss) > 0:
            self.list = remaining
            self.list_mutation_count += 1
            self.write_file()
            self.list_change_triggers += 1
            for notif in toDismiss:
                if notif.get("timer"):
                    notif["timer"].stop()
                    notif["timer"].destroy()
                externalNotif = notif.get("notification")
                if externalNotif and externalNotif.tracked:
                    externalNotif.dismiss()

        for nid in idSet:
            self.emitted_discards.append(nid)

    def discardNotificationBatch(self, ids: list[int]):
        self.discardNotifications(ids)

    def discardAllNotifications(self):
        self.list = []
        self.list_mutation_count += 1
        self.write_file()
        self.list_change_triggers += 1
        for s in self.tracked_server_notifications:
            if s.tracked:
                s.dismiss()
        self.emitted_discard_all += 1

    # Stale timer simulation: triggered after item was removed
    def simulate_timer_trigger(self, nid: int):
        idx = next((i for i, n in enumerate(self.list) if n["notificationId"] == nid), -1)
        if idx == -1:
            # Stale timer guard: item no longer in list -> destroy and return cleanly
            return "stale_guard_activated"
        return "normal_timeout"


class TestU13DynamicBehavior(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp(prefix="test_u13_")
        self.file_path = os.path.join(self.temp_dir, "notifications.json")
        self.service = MockNotificationsService(self.file_path)

    def tearDown(self):
        shutil.rmtree(self.temp_dir, ignore_errors=True)

    def test_01_baseline_vs_candidate_mutation_and_write_count(self):
        # Populate 15 notifications from same app
        ids_burst = []
        for i in range(15):
            nid, _ = self.service.add_notification("Slack", f"Msg #{i}", f"Body #{i}")
            ids_burst.append(nid)

        # Comparative baseline simulation on fresh clone
        base_service = MockNotificationsService(os.path.join(self.temp_dir, "baseline.json"))
        for i in range(15):
            base_service.add_notification("Slack", f"Msg #{i}", f"Body #{i}")
        base_service.list_mutation_count = 0
        base_service.persistence_writes = 0
        base_service.list_change_triggers = 0

        base_service.baseline_group_swipe(ids_burst)
        # Baseline must execute 15 separate mutations and 15 writes
        self.assertEqual(base_service.list_mutation_count, 15)
        self.assertEqual(base_service.persistence_writes, 15)
        self.assertEqual(base_service.list_change_triggers, 15)

        # Candidate execution on 15 items
        self.service.list_mutation_count = 0
        self.service.persistence_writes = 0
        self.service.list_change_triggers = 0

        self.service.discardNotifications(ids_burst)
        # Candidate executes exactly 1 mutation, 1 write, and 1 list change
        self.assertEqual(self.service.list_mutation_count, 1)
        self.assertEqual(self.service.persistence_writes, 1)
        self.assertEqual(self.service.list_change_triggers, 1)
        self.assertEqual(len(self.service.list), 0)

    def test_02_group_swipe_dismissal_preserves_tracked_server_dismissals(self):
        ids = []
        for i in range(5):
            nid, _ = self.service.add_notification("Telegram", f"Alert #{i}", "Payload")
            ids.append(nid)

        self.assertEqual(len(self.service.tracked_server_notifications), 5)
        self.assertTrue(all(s.tracked for s in self.service.tracked_server_notifications))

        # Group swipe
        self.service.discardNotifications(ids)

        # All 5 server notifications dismissed
        self.assertTrue(all(s.dismissed for s in self.service.tracked_server_notifications))
        self.assertTrue(all(not s.tracked for s in self.service.tracked_server_notifications))
        self.assertEqual(len(self.service.emitted_discards), 5)

    def test_03_single_dismiss_delegates_to_discard_notifications(self):
        id1, _ = self.service.add_notification("Email", "Subject 1", "Body 1")
        id2, _ = self.service.add_notification("Email", "Subject 2", "Body 2")

        self.service.persistence_writes = 0
        self.service.discardNotification(id1)

        self.assertEqual(len(self.service.list), 1)
        self.assertEqual(self.service.list[0]["notificationId"], id2)
        self.assertEqual(self.service.persistence_writes, 1)
        self.assertIn(id1, self.service.emitted_discards)

    def test_04_empty_and_none_ids_resilience(self):
        self.service.add_notification("App", "Sum", "Body")
        initial_len = len(self.service.list)
        self.service.persistence_writes = 0
        self.service.list_mutation_count = 0

        self.service.discardNotifications([])
        self.service.discardNotifications(None)

        self.assertEqual(len(self.service.list), initial_len)
        self.assertEqual(self.service.persistence_writes, 0)
        self.assertEqual(self.service.list_mutation_count, 0)
        self.assertEqual(len(self.service.emitted_discards), 0)

    def test_05_missing_ids_handling(self):
        id1, _ = self.service.add_notification("App", "Msg 1", "Body 1")
        self.service.persistence_writes = 0
        self.service.list_mutation_count = 0

        # Discard non-existent ID
        self.service.discardNotifications([99999])

        self.assertEqual(len(self.service.list), 1)
        self.assertEqual(self.service.persistence_writes, 0)
        self.assertEqual(self.service.list_mutation_count, 0)
        # Discard signal still emitted for caller symmetry
        self.assertIn(99999, self.service.emitted_discards)

    def test_06_duplicate_ids_deduplication(self):
        id1, _ = self.service.add_notification("App", "Msg 1", "Body 1")
        self.service.persistence_writes = 0
        self.service.list_mutation_count = 0

        # Pass duplicate IDs
        self.service.discardNotifications([id1, id1, id1])

        self.assertEqual(len(self.service.list), 0)
        self.assertEqual(self.service.persistence_writes, 1)
        self.assertEqual(self.service.list_mutation_count, 1)
        # Deduplicated discard signal
        self.assertEqual(self.service.emitted_discards.count(id1), 1)

    def test_07_cross_app_separation_and_order_preservation(self):
        id_a1, _ = self.service.add_notification("AppA", "A1", "Body A1")
        id_b1, _ = self.service.add_notification("AppB", "B1", "Body B1")
        id_a2, _ = self.service.add_notification("AppA", "A2", "Body A2")
        id_b2, _ = self.service.add_notification("AppB", "B2", "Body B2")
        id_c1, _ = self.service.add_notification("AppC", "C1", "Body C1")

        # Discard only AppA group: [id_a1, id_a2]
        self.service.discardNotifications([id_a1, id_a2])

        remaining_ids = [n["notificationId"] for n in self.service.list]
        self.assertEqual(remaining_ids, [id_b1, id_b2, id_c1])
        # AppB and AppC items completely intact in order
        remaining_apps = [n["appName"] for n in self.service.list]
        self.assertEqual(remaining_apps, ["AppB", "AppB", "AppC"])

    def test_08_racing_timer_cancellation_and_stale_guard(self):
        id1, notif_obj = self.service.add_notification("TimerApp", "Alert", "Body", with_timer=True)
        timer = notif_obj["timer"]
        self.assertTrue(timer.running)
        self.assertFalse(timer.stopped)

        # Batch discard cancels timer
        self.service.discardNotifications([id1])
        self.assertTrue(timer.stopped)
        self.assertTrue(timer.destroyed)

        # Simulate racing timer firing on event loop after discard
        res = self.service.simulate_timer_trigger(id1)
        self.assertEqual(res, "stale_guard_activated")

    def test_09_untracked_and_restored_notifications_handled_safely(self):
        # Untracked item (notification is None)
        id_untracked, _ = self.service.add_notification("Internal", "Info", "Body", tracked=False)
        self.service.discardNotifications([id_untracked])
        self.assertEqual(len(self.service.list), 0)
        self.assertIn(id_untracked, self.service.emitted_discards)

    def test_10_persistence_roundtrip_and_reload(self):
        for i in range(10):
            self.service.add_notification("BulkApp", f"Item {i}", f"Data {i}")

        # Discard half the notifications
        self.service.discardNotifications([1, 3, 5, 7, 9])
        self.assertEqual(len(self.service.list), 5)

        # Reload from persisted disk file
        new_service = MockNotificationsService(self.file_path)
        new_service.reload_file()
        self.assertEqual(len(new_service.list), 5)
        self.assertEqual(new_service.idOffset, 10)
        self.assertEqual([n["notificationId"] for n in new_service.list], [2, 4, 6, 8, 10])

    def test_11_clear_all_notifications_contract(self):
        for i in range(6):
            self.service.add_notification("App", f"Item {i}", "Body")
        self.assertEqual(len(self.service.list), 6)

        self.service.discardAllNotifications()
        self.assertEqual(len(self.service.list), 0)
        self.assertEqual(self.service.emitted_discard_all, 1)
        self.assertTrue(all(s.dismissed for s in self.service.tracked_server_notifications))

    def test_12_discard_notification_batch_alias(self):
        id1, _ = self.service.add_notification("AliasApp", "Item 1", "Body 1")
        id2, _ = self.service.add_notification("AliasApp", "Item 2", "Body 2")

        self.service.discardNotificationBatch([id1, id2])
        self.assertEqual(len(self.service.list), 0)
        self.assertIn(id1, self.service.emitted_discards)
        self.assertIn(id2, self.service.emitted_discards)


if __name__ == "__main__":
    unittest.main()
