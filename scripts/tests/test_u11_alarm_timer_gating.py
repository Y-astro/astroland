#!/usr/bin/env python3
"""Contract and regression tests for Task U11: Gating unnecessary AlarmService check timer."""

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ALARM_SERVICE_PATH = ROOT / "services/AlarmService.qml"
BEDTIME_SERVICE_PATH = ROOT / "services/BedtimeService.qml"


class TestU11AlarmTimerGating(unittest.TestCase):
    def setUp(self):
        self.alarm_service = ALARM_SERVICE_PATH.read_text(encoding="utf-8")
        self.bedtime_service = BEDTIME_SERVICE_PATH.read_text(encoding="utf-8")

    def test_has_relevant_alarms_contract(self):
        # 1. Evaluates Persistent.ready
        self.assertIn("readonly property bool hasRelevantAlarms: Persistent.ready", self.alarm_service)

        # 2. Checks active ringing, ring queue, snooze, and enabled alarms
        self.assertIn("root.ringingAlarmIndex !== -1", self.alarm_service)
        self.assertIn("root.ringQueue.length > 0", self.alarm_service)
        self.assertIn("root.snoozedAlarm !== null", self.alarm_service)
        self.assertIn("Array.from(root.alarms).some(alarm => Boolean(alarm && alarm.enabled))", self.alarm_service)

    def test_alarm_check_timer_gated_by_relevant_alarms(self):
        # 3. alarmCheckTimer.running is bound to hasRelevantAlarms
        self.assertIn("id: alarmCheckTimer", self.alarm_service)
        self.assertIn("running: root.hasRelevantAlarms", self.alarm_service)
        self.assertNotIn("running: true\n        onTriggered: checkAlarms()", self.alarm_service)

    def test_prompt_evaluation_on_transition(self):
        # 4. onHasRelevantAlarmsChanged evaluates checkAlarms promptly on activation
        self.assertIn("onHasRelevantAlarmsChanged: {", self.alarm_service)
        self.assertIn("root.checkAlarms();", self.alarm_service)
        self.assertIn("root.lastCheckMs = Date.now() - 1000;", self.alarm_service)

    def test_initialization_and_suspend_catchup_preservation(self):
        # 5. Persistent.onReadyChanged and Component.onCompleted check hasRelevantAlarms
        self.assertIn("if (root.hasRelevantAlarms) {", self.alarm_service)
        self.assertIn("root.lastCheckMs = Persistent.states.alarmState.lastCheck > 0", self.alarm_service)
        self.assertIn("root.lastCheckMs = Date.now();", self.alarm_service)

    def test_hourly_wake_timer_untouched(self):
        # 6. Unrelated hourly wake scheduling is not gated
        self.assertIn("interval: 3600000\n        repeat: true\n        running: true", self.alarm_service)

    def test_bedtime_service_untouched(self):
        # 7. BedtimeService interval remains 30000ms as per task requirements
        self.assertIn("interval: 30000", self.bedtime_service)
        self.assertNotIn("interval: 60000", self.bedtime_service)

    def test_ipc_replay_harness_preserved(self):
        # 8. Replay mechanism for suspend gap simulation remains intact
        self.assertIn("function replaySince(minutes: int): void", self.alarm_service)
        self.assertIn("root.lastCheckMs = Date.now() - Math.max(1, minutes) * 60000;", self.alarm_service)


if __name__ == "__main__":
    unittest.main()
