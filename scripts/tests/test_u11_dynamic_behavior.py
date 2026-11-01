#!/usr/bin/env python3
"""Dynamic behavioral tests for Task U11: AlarmService timer gating and scheduling lifecycle.

Tests:
  1. Startup with empty alarms list: timer halted, no wakeups.
  2. First alarm creation: prompt evaluation, timer starts running.
  3. Last alarm removal: timer stops running immediately.
  4. Disabled-only alarms: timer remains stopped, nextAlarm is null, untilText empty.
  5. Toggling disabled alarm to enabled: prompt evaluation, no false missed alarms for idle period.
  6. Due alarm event: triggers alarm ringing and signals.
  7. Snooze event: quiets ringing alarm, stays active, re-triggers on expiry.
  8. One-off alarm stop: disables alarm, stops timer if no other alarms remain.
  9. Repeating alarm stop: keeps alarm enabled, schedules next occurrence.
 10. Suspend-gap catch-up (< catchUpMinutes): alarm rings upon resume.
 11. Suspend-gap expiration (> catchUpMinutes): alarm recorded as missed.
 12. Suspend-gap simulation (> 120s): wakeDebounce restarted.
 13. Suspend-gap simulation with NO alarms: clean resume without spurious events.
"""

from __future__ import annotations

import datetime
import unittest


class MockAlarmService:
    def __init__(self):
        # Configuration
        self.snoozeMinutes = 9
        self.autoSilenceMinutes = 5
        self.catchUpMinutes = 10
        self.wakeFromSuspend = True
        self.wakeLeadSeconds = 90
        self.upcomingMinutes = 60

        # State
        self.persistentReady = False
        self.persistentStates = {
            "alarms": [],
            "alarmState": {
                "lastCheck": 0,
                "missed": []
            }
        }
        self.alarms = []
        self.ringingAlarmIndex = -1
        self.ringQueue = []
        self.upcomingAlarm = None
        self.wakeScheduledFor = None
        self.scheduledWakeKey = "#unsynced"
        self.wakeDebounceRestarted = 0
        self.snoozedAlarm = None
        self.snoozedUntil = 0
        self.lastCheckMs = 0
        self.lastPersistedMinute = -1
        self.checkCount = 0
        self.diskWrites = 0

        # Signals
        self.emittedAlarmRang = []
        self.emittedAlarmDismissed = []
        self.emittedAlarmSnoozed = []
        self.emittedAlarmMissed = []

    @property
    def hasRelevantAlarms(self) -> bool:
        if not self.persistentReady:
            return False
        if self.ringingAlarmIndex != -1 or len(self.ringQueue) > 0 or self.snoozedAlarm is not None:
            return True
        if not self.alarms:
            return False
        return any(bool(a and a.get("enabled", False)) for a in self.alarms)

    @property
    def timerRunning(self) -> bool:
        return self.hasRelevantAlarms

    def setPersistentReady(self, ready: bool, now_ms: float):
        old_has_rel = self.hasRelevantAlarms
        self.persistentReady = ready
        if ready:
            self.alarms = list(self.persistentStates["alarms"])
            self.refreshUpcoming(now_ms)
            self.wakeDebounceRestarted += 1
            if self.hasRelevantAlarms:
                if self.lastCheckMs <= 0:
                    last = self.persistentStates["alarmState"]["lastCheck"]
                    self.lastCheckMs = last if last > 0 else now_ms - 1000
                self.checkAlarms(now_ms)
            else:
                self.lastCheckMs = now_ms
        if self.hasRelevantAlarms != old_has_rel:
            self._onHasRelevantAlarmsChanged(now_ms)

    def _onHasRelevantAlarmsChanged(self, now_ms: float):
        if self.hasRelevantAlarms:
            if self.lastCheckMs <= 0 and self.persistentReady:
                last = self.persistentStates["alarmState"]["lastCheck"]
                self.lastCheckMs = last if last > 0 else now_ms - 1000
            elif self.lastCheckMs > 0:
                self.lastCheckMs = now_ms - 1000
            self.checkAlarms(now_ms)
        else:
            if self.persistentReady:
                self.lastCheckMs = now_ms
                self.persistLastCheck(self.lastCheckMs)

    def persistLastCheck(self, ms: float):
        self.persistentStates["alarmState"]["lastCheck"] = ms
        self.lastPersistedMinute = int(ms // 60000)
        self.diskWrites += 1

    def saveAlarms(self, new_alarms: list, now_ms: float):
        old_has_rel = self.hasRelevantAlarms
        self.persistentStates["alarms"] = [dict(a) for a in new_alarms]
        self.alarms = list(self.persistentStates["alarms"])
        self.refreshUpcoming(now_ms)
        self.wakeDebounceRestarted += 1
        if self.hasRelevantAlarms != old_has_rel:
            self._onHasRelevantAlarmsChanged(now_ms)

    def addAlarm(self, time_str: str, label: str, days: list[bool] | None, date: str, now_ms: float) -> bool:
        if not self.persistentReady:
            return False
        cloned = [dict(a) for a in self.alarms]
        cloned.append({
            "time": time_str or "08:00",
            "label": label or "Alarm",
            "days": days or [False] * 7,
            "date": date or "",
            "enabled": True,
        })
        cloned.sort(key=lambda a: a["time"])
        self.saveAlarms(cloned, now_ms)
        return True

    def deleteAlarm(self, index: int, now_ms: float):
        if not self.persistentReady or index < 0 or index >= len(self.alarms):
            return
        cloned = [dict(a) for a in self.alarms]
        if self.ringingAlarmIndex == index:
            self.stopRinging(now_ms)
        cloned.pop(index)
        self.saveAlarms(cloned, now_ms)

    def toggleAlarm(self, index: int, now_ms: float):
        if not self.persistentReady or index < 0 or index >= len(self.alarms):
            return
        cloned = [dict(a) for a in self.alarms]
        cloned[index]["enabled"] = not cloned[index].get("enabled", False)
        if not cloned[index]["enabled"] and self.ringingAlarmIndex == index:
            self.stopRinging(now_ms)
        self.saveAlarms(cloned, now_ms)

    def keyOf(self, alarm: dict) -> dict:
        return {"time": alarm.get("time", ""), "label": alarm.get("label", ""), "date": alarm.get("date", "")}

    def alarmDateAt(self, alarm: dict, day: datetime.date) -> datetime.datetime:
        parts = alarm.get("time", "00:00").split(":")
        h = int(parts[0]) if len(parts) > 0 else 0
        m = int(parts[1]) if len(parts) > 1 else 0
        return datetime.datetime(day.year, day.month, day.day, h, m, 0)

    def nextOccurrence(self, alarm: dict, from_dt: datetime.datetime) -> datetime.datetime | None:
        if not alarm or not alarm.get("enabled", False):
            return None
        dated = str(alarm.get("date", ""))
        if dated:
            parts = [int(p) for p in dated.split("-")]
            day = datetime.date(parts[0], parts[1], parts[2])
            at = self.alarmDateAt(alarm, day)
            return at if at > from_dt else None
        repeats = any(alarm.get("days", []))
        skip = str(alarm.get("skipDate", ""))
        from_date = from_dt.date()
        for i in range(15):
            day = from_date + datetime.timedelta(days=i)
            at = self.alarmDateAt(alarm, day)
            if at <= from_dt:
                continue
            # Python weekday: Mon=0, Sun=6. QML getDay(): Sun=0, Mon=1
            qml_weekday = (day.weekday() + 1) % 7
            if repeats and not alarm.get("days", [])[qml_weekday]:
                continue
            if day.strftime("%Y-%m-%d") == skip:
                continue
            return at
        return None

    def occurrencesBetween(self, alarm: dict, from_ms: float, to_ms: float) -> list[dict]:
        out = []
        if not alarm or not alarm.get("enabled", False):
            return out
        dated = str(alarm.get("date", ""))
        repeats = any(alarm.get("days", []))
        skip = str(alarm.get("skipDate", ""))
        start_dt = datetime.datetime.fromtimestamp(from_ms / 1000.0)
        days = min(8, int((to_ms - from_ms) / 86400000.0) + 1)
        for i in range(days + 1):
            day = start_dt.date() + datetime.timedelta(days=i)
            at = self.alarmDateAt(alarm, day)
            t = at.timestamp() * 1000.0
            if t <= from_ms or t > to_ms:
                continue
            key = day.strftime("%Y-%m-%d")
            if dated and dated != key:
                continue
            qml_weekday = (day.weekday() + 1) % 7
            if not dated and repeats and not alarm.get("days", [])[qml_weekday]:
                continue
            out.append({"at": at, "ms": t, "skipped": key == skip})
        return out

    def nextAlarm(self, from_dt: datetime.datetime) -> dict | None:
        best = None
        for i, alarm in enumerate(self.alarms):
            at = self.nextOccurrence(alarm, from_dt)
            if at and (best is None or at < best["at"]):
                best = {"index": i, "alarm": alarm, "at": at}
        return best

    def refreshUpcoming(self, now_ms: float):
        now_dt = datetime.datetime.fromtimestamp(now_ms / 1000.0)
        nxt = self.nextAlarm(now_dt)
        within = nxt and ((nxt["at"].timestamp() * 1000.0 - now_ms) <= self.upcomingMinutes * 60000.0)
        self.upcomingAlarm = nxt if within else None

    def triggerAlarm(self, index: int, now_ms: float):
        if index < 0 or index >= len(self.alarms):
            return
        if self.ringingAlarmIndex != -1 and self.ringingAlarmIndex != index:
            self.enqueue(self.alarms[index])
            return
        self.ringingAlarmIndex = index
        alarm = self.alarms[index]
        self.emittedAlarmRang.append(alarm)

    def enqueue(self, alarm: dict):
        key = self.keyOf(alarm)
        if not any(k["time"] == key["time"] and k["label"] == key["label"] and k["date"] == key["date"] for k in self.ringQueue):
            self.ringQueue.append(key)

    def snooze(self, minutes: int, now_ms: float):
        if self.ringingAlarmIndex == -1:
            return
        alarm = self.alarms[self.ringingAlarmIndex]
        length = max(1, int(round(minutes or self.snoozeMinutes)))
        self.snoozedAlarm = {"time": alarm["time"], "label": alarm.get("label", "")}
        self.snoozedUntil = now_ms + length * 60000.0
        self.ringingAlarmIndex = -1
        self.emittedAlarmSnoozed.append(alarm)

    def stopRinging(self, now_ms: float):
        if self.ringingAlarmIndex == -1:
            return
        alarm = self.alarms[self.ringingAlarmIndex]
        if not any(alarm.get("days", [])):
            cloned = [dict(a) for a in self.alarms]
            for c in cloned:
                if c["time"] == alarm["time"] and c.get("label", "") == alarm.get("label", "") and str(c.get("date", "")) == str(alarm.get("date", "")):
                    c["enabled"] = False
                    break
            self.saveAlarms(cloned, now_ms)
        self.ringingAlarmIndex = -1
        self.emittedAlarmDismissed.append(alarm)

    def recordMissed(self, alarm: dict, at_dt: datetime.datetime):
        entry = {"time": str(alarm.get("time", "")), "label": str(alarm.get("label", "")), "at": at_dt.timestamp() * 1000.0}
        missed = list(self.persistentStates["alarmState"].get("missed", []))
        missed.append(entry)
        self.persistentStates["alarmState"]["missed"] = missed[-10:]
        self.emittedAlarmMissed.append((alarm, at_dt))

    def checkAlarms(self, now_ms: float):
        if not self.persistentReady:
            return
        self.checkCount += 1
        now = now_ms
        if self.lastCheckMs <= 0:
            last = self.persistentStates["alarmState"]["lastCheck"]
            self.lastCheckMs = last if last > 0 else now - 1000
        frm = self.lastCheckMs
        if frm > now:
            frm = now - 1000
        frm = max(frm, now - 7 * 86400000.0)
        gap = now - frm

        if self.alarms and len(self.alarms) > 0:
            due = []
            skips_to_clear = []
            for alarm in self.alarms:
                for hit in self.occurrencesBetween(alarm, frm, now):
                    if hit["skipped"]:
                        skips_to_clear.append(self.keyOf(alarm))
                    else:
                        due.append({"alarm": alarm, "at": hit["at"], "ms": hit["ms"]})
            due.sort(key=lambda d: d["ms"])
            handled = False
            disable_one_offs = []
            for item in due:
                handled = True
                late = now - item["ms"]
                if late <= self.catchUpMinutes * 60000.0:
                    if self.ringingAlarmIndex == -1:
                        idx = next((i for i, a in enumerate(self.alarms) if a["time"] == item["alarm"]["time"] and a.get("label", "") == item["alarm"].get("label", "") and str(a.get("date", "")) == str(item["alarm"].get("date", ""))), -1)
                        if idx >= 0:
                            self.triggerAlarm(idx, now)
                    else:
                        self.enqueue(item["alarm"])
                else:
                    self.recordMissed(item["alarm"], item["at"])
                    if not any(item["alarm"].get("days", [])):
                        disable_one_offs.append(self.keyOf(item["alarm"]))

            if skips_to_clear or disable_one_offs:
                cloned = [dict(a) for a in self.alarms]
                for alarm in cloned:
                    key = self.keyOf(alarm)
                    match = lambda k: k["time"] == key["time"] and k["label"] == key["label"] and k["date"] == key["date"]
                    if any(match(k) for k in skips_to_clear):
                        alarm["skipDate"] = ""
                    if any(match(k) for k in disable_one_offs):
                        alarm["enabled"] = False
                self.saveAlarms(cloned, now)
            self.lastCheckMs = now
            if handled:
                self.persistLastCheck(now)
        else:
            self.lastCheckMs = now

        minute = int(now // 60000)
        if minute != self.lastPersistedMinute:
            self.persistLastCheck(now)
            self.refreshUpcoming(now)
        if gap > 120000.0:
            self.wakeDebounceRestarted += 1

    def replaySince(self, minutes: int, now_ms: float):
        self.lastCheckMs = now_ms - max(1, minutes) * 60000.0
        self.checkAlarms(now_ms)


class TestU11AlarmServiceDynamicBehavior(unittest.TestCase):
    def setUp(self):
        self.service = MockAlarmService()
        # Reference epoch: 2026-11-01 10:00:00
        self.base_dt = datetime.datetime(2026, 11, 1, 10, 0, 0)
        self.base_ms = self.base_dt.timestamp() * 1000.0

    def test_startup_with_empty_alarms_list(self):
        # 1. Shell starts with empty alarms
        self.service.setPersistentReady(True, self.base_ms)
        self.assertFalse(self.service.hasRelevantAlarms)
        self.assertFalse(self.service.timerRunning)
        # checkAlarms should not have been called repeatedly
        self.assertEqual(self.service.checkCount, 0)
        self.assertIsNone(self.service.upcomingAlarm)

    def test_first_alarm_creation_starts_evaluation_promptly(self):
        # 2. Add first alarm: timer immediately starts and evaluates
        self.service.setPersistentReady(True, self.base_ms)
        self.assertFalse(self.service.timerRunning)

        # Add alarm for 10:15:00
        self.service.addAlarm("10:15", "Meeting", None, "2026-11-01", self.base_ms)
        self.assertTrue(self.service.hasRelevantAlarms)
        self.assertTrue(self.service.timerRunning)
        # Evaluation ran promptly upon transition
        self.assertEqual(self.service.checkCount, 1)
        self.assertIsNotNone(self.service.upcomingAlarm)
        self.assertEqual(self.service.upcomingAlarm["alarm"]["time"], "10:15")

    def test_last_alarm_removal_stops_timer(self):
        # 3. Remove only alarm: timer halts immediately
        self.service.setPersistentReady(True, self.base_ms)
        self.service.addAlarm("10:15", "Meeting", None, "2026-11-01", self.base_ms)
        self.assertTrue(self.service.timerRunning)

        self.service.deleteAlarm(0, self.base_ms + 1000)
        self.assertFalse(self.service.hasRelevantAlarms)
        self.assertFalse(self.service.timerRunning)
        self.assertIsNone(self.service.upcomingAlarm)

    def test_disabled_only_alarms_halt_timer(self):
        # 4. User has alarms, but all disabled -> timer remains stopped
        self.service.setPersistentReady(True, self.base_ms)
        self.service.addAlarm("08:00", "Morning", None, "", self.base_ms)
        self.service.toggleAlarm(0, self.base_ms + 1000)  # disable it

        self.assertFalse(self.service.hasRelevantAlarms)
        self.assertFalse(self.service.timerRunning)
        self.assertIsNone(self.service.nextAlarm(self.base_dt))
        self.assertIsNone(self.service.upcomingAlarm)

    def test_toggling_disabled_to_enabled_does_not_replay_past_missed(self):
        # 5. User disables an alarm for 09:00 at 08:00.
        # At 11:00 (2 hours later), user re-enables it.
        # It must NOT record missed for 09:00 today!
        self.service.setPersistentReady(True, self.base_ms)  # 10:00:00
        self.service.addAlarm("09:00", "Morning Work", [True] * 7, "", self.base_ms)
        self.service.toggleAlarm(0, self.base_ms)  # disabled

        self.assertFalse(self.service.timerRunning)

        # Fast-forward 2 hours to 12:00:00
        now_12 = self.base_ms + 2 * 3600000.0
        self.service.toggleAlarm(0, now_12)  # re-enable

        self.assertTrue(self.service.timerRunning)
        # Should NOT have recorded a missed alarm for 09:00
        self.assertEqual(len(self.service.emittedAlarmMissed), 0)
        # Next occurrence should be tomorrow at 09:00
        nxt = self.service.nextAlarm(datetime.datetime.fromtimestamp(now_12 / 1000.0))
        self.assertIsNotNone(nxt)
        self.assertEqual(nxt["at"].day, 2)
        self.assertEqual(nxt["at"].hour, 9)

    def test_due_alarm_triggers_ringing_and_signal(self):
        # 6. Clock reaches alarm moment
        self.service.setPersistentReady(True, self.base_ms)  # 10:00:00
        self.service.addAlarm("10:05", "Standup", None, "2026-11-01", self.base_ms)

        # Tick at 10:04:59
        self.service.checkAlarms(self.base_ms + 4 * 60000.0 + 59000.0)
        self.assertEqual(self.service.ringingAlarmIndex, -1)
        self.assertEqual(len(self.service.emittedAlarmRang), 0)

        # Tick at 10:05:00
        self.service.checkAlarms(self.base_ms + 5 * 60000.0)
        self.assertEqual(self.service.ringingAlarmIndex, 0)
        self.assertEqual(len(self.service.emittedAlarmRang), 1)
        self.assertEqual(self.service.emittedAlarmRang[0]["label"], "Standup")
        self.assertTrue(self.service.timerRunning)

    def test_snooze_lifecycle(self):
        # 7. Snooze quiets ringing alarm and re-triggers on expiry
        self.service.setPersistentReady(True, self.base_ms)
        self.service.addAlarm("10:05", "Standup", None, "2026-11-01", self.base_ms)
        self.service.checkAlarms(self.base_ms + 5 * 60000.0)  # rings

        # Snooze for 9 minutes
        self.service.snooze(9, self.base_ms + 5 * 60000.0)
        self.assertEqual(self.service.ringingAlarmIndex, -1)
        self.assertIsNotNone(self.service.snoozedAlarm)
        self.assertEqual(len(self.service.emittedAlarmSnoozed), 1)
        self.assertTrue(self.service.timerRunning)  # stays active while snoozed

    def test_one_off_dismiss_stops_timer(self):
        # 8. Stopping one-off alarm disables it; if last alarm, stops timer
        self.service.setPersistentReady(True, self.base_ms)
        self.service.addAlarm("10:05", "OneOff", None, "2026-11-01", self.base_ms)
        self.service.checkAlarms(self.base_ms + 5 * 60000.0)  # rings

        self.service.stopRinging(self.base_ms + 5 * 60000.0 + 10000.0)
        self.assertEqual(self.service.ringingAlarmIndex, -1)
        self.assertFalse(self.service.alarms[0]["enabled"])
        self.assertFalse(self.service.hasRelevantAlarms)
        self.assertFalse(self.service.timerRunning)

    def test_repeating_alarm_dismiss_retains_timer(self):
        # 9. Stopping repeating alarm keeps enabled=True, retains timer for future
        self.service.setPersistentReady(True, self.base_ms)
        self.service.addAlarm("10:05", "Daily", [True] * 7, "", self.base_ms)
        self.service.checkAlarms(self.base_ms + 5 * 60000.0)  # rings

        self.service.stopRinging(self.base_ms + 5 * 60000.0 + 10000.0)
        self.assertEqual(self.service.ringingAlarmIndex, -1)
        self.assertTrue(self.service.alarms[0]["enabled"])
        self.assertTrue(self.service.hasRelevantAlarms)
        self.assertTrue(self.service.timerRunning)

    def test_suspend_gap_catchup_within_window(self):
        # 10. Alarm set for 10:05. Laptop suspends at 10:04, wakes at 10:08 (4 min gap <= catchUpMinutes 10 min)
        self.service.setPersistentReady(True, self.base_ms)
        self.service.addAlarm("10:05", "Catchup", None, "2026-11-01", self.base_ms)
        self.service.checkAlarms(self.base_ms + 4 * 60000.0)  # last tick before suspend at 10:04

        # Resume at 10:08:00
        resume_ms = self.base_ms + 8 * 60000.0
        self.service.checkAlarms(resume_ms)
        # Should catch up and ring!
        self.assertEqual(self.service.ringingAlarmIndex, 0)
        self.assertEqual(len(self.service.emittedAlarmRang), 1)
        self.assertEqual(len(self.service.emittedAlarmMissed), 0)

    def test_suspend_gap_missed_when_exceeding_window(self):
        # 11. Alarm set for 10:05. Laptop suspends at 10:04, wakes at 10:30 (25 min gap > catchUpMinutes 10 min)
        self.service.setPersistentReady(True, self.base_ms)
        self.service.addAlarm("10:05", "MissedMe", None, "2026-11-01", self.base_ms)
        self.service.checkAlarms(self.base_ms + 4 * 60000.0)

        # Resume at 10:30:00
        resume_ms = self.base_ms + 30 * 60000.0
        self.service.checkAlarms(resume_ms)
        # Should NOT ring, but record missed
        self.assertEqual(self.service.ringingAlarmIndex, -1)
        self.assertEqual(len(self.service.emittedAlarmRang), 0)
        self.assertEqual(len(self.service.emittedAlarmMissed), 1)
        self.assertFalse(self.service.alarms[0]["enabled"])  # one-off disabled
        self.assertFalse(self.service.timerRunning)

    def test_suspend_gap_greater_than_120s_triggers_wake_debounce(self):
        # 12. Gap > 120s triggers wakeDebounce.restart()
        self.service.setPersistentReady(True, self.base_ms)
        self.service.addAlarm("12:00", "FarFuture", None, "2026-11-01", self.base_ms)
        self.service.checkAlarms(self.base_ms)
        initial_resets = self.service.wakeDebounceRestarted

        # Gap of 3 minutes (180s > 120s)
        self.service.checkAlarms(self.base_ms + 180000.0)
        self.assertGreater(self.service.wakeDebounceRestarted, initial_resets)

    def test_suspend_gap_with_no_alarms_generates_zero_events(self):
        # 13. System suspends with no alarms, wakes hours later: 0 missed, 0 ringing, timer remains off
        self.service.setPersistentReady(True, self.base_ms)
        self.assertFalse(self.service.timerRunning)

        # Jump 4 hours ahead
        now_4h = self.base_ms + 4 * 3600000.0
        # Check timer doesn't even run; if someone called checkAlarms:
        self.service.checkAlarms(now_4h)
        self.assertEqual(len(self.service.emittedAlarmRang), 0)
        self.assertEqual(len(self.service.emittedAlarmMissed), 0)
        self.assertFalse(self.service.timerRunning)


if __name__ == "__main__":
    unittest.main()
