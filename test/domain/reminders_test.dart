import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/period_prediction.dart';
import 'package:fycle/domain/reminders.dart';

PeriodPrediction predictionFrom(CalendarDay earliest, {int width = 5}) =>
    PeriodPrediction(
      earliestStart: earliest,
      latestStart: earliest.addDays(width - 1),
      confidence: PredictionConfidence.medium,
      estimatedCycleLength: 28,
      cyclesUsed: 3,
    );

void main() {
  final today = CalendarDay(2026, 3, 20);
  final noon = ClockTime(12, 0);

  group('ClockTime', () {
    test('refuses times that do not exist', () {
      expect(() => ClockTime(24, 0), throwsArgumentError);
      expect(() => ClockTime(9, 60), throwsArgumentError);
      expect(() => ClockTime(-1, 0), throwsArgumentError);
    });

    test('converts to and from minutes', () {
      expect(ClockTime(9, 30).minutesSinceMidnight, 570);
      expect(ClockTime.tryFromMinutes(570), ClockTime(9, 30));
      expect(ClockTime.tryFromMinutes(null), isNull);
      expect(ClockTime.tryFromMinutes(-1), isNull);
      expect(ClockTime.tryFromMinutes(24 * 60), isNull);
    });

    test('reads as a clock', () {
      expect('${ClockTime(7, 5)}', '07:05');
    });
  });

  group('settings', () {
    test('everything is off by default', () {
      final settings = ReminderSettings();
      expect(settings.periodEnabled, isFalse);
      expect(settings.dailyEnabled, isFalse);
      expect(settings.anyEnabled, isFalse);
      expect(settings.periodDaysBefore, 2);
      expect(settings.periodTime, ClockTime(9, 0));
      expect(settings.dailyTime, ClockTime(20, 0));
    });

    test('refuses an unknown number of days before', () {
      expect(() => ReminderSettings(periodDaysBefore: 0), throwsArgumentError);
      expect(() => ReminderSettings(periodDaysBefore: 4), throwsArgumentError);
    });
  });

  test('nothing is planned while reminders are off', () {
    expect(
      planReminders(
        settings: ReminderSettings(),
        today: today,
        now: noon,
        prediction: predictionFrom(CalendarDay(2026, 4, 2)),
      ),
      isEmpty,
    );
  });

  group('period approaching', () {
    final settings = ReminderSettings(periodEnabled: true);

    test('comes a few days before the first day of the range', () {
      final planned = planReminders(
        settings: settings,
        today: today,
        now: noon,
        prediction: predictionFrom(CalendarDay(2026, 4, 2)),
      );
      expect(planned, [
        PlannedReminder(
          kind: ReminderKind.periodApproaching,
          day: CalendarDay(2026, 3, 31),
          time: ClockTime(9, 0),
        ),
      ]);
    });

    test('follows the chosen number of days and the chosen time', () {
      final planned = planReminders(
        settings: settings.copyWith(
          periodDaysBefore: 3,
          periodTime: ClockTime(18, 30),
        ),
        today: today,
        now: noon,
        prediction: predictionFrom(CalendarDay(2026, 4, 2)),
      );
      expect(planned.single.day, CalendarDay(2026, 3, 30));
      expect(planned.single.time, ClockTime(18, 30));
    });

    test('is not planned without an estimate', () {
      expect(
        planReminders(settings: settings, today: today, now: noon),
        isEmpty,
      );
    });

    test('is planned later the same day, but never sent late', () {
      final prediction = predictionFrom(today.addDays(2));
      expect(
        planReminders(
          settings: settings,
          today: today,
          now: ClockTime(8, 59),
          prediction: prediction,
        ),
        hasLength(1),
      );
      expect(
        planReminders(
          settings: settings,
          today: today,
          now: ClockTime(9, 0),
          prediction: prediction,
        ),
        isEmpty,
      );
    });

    test('is dropped once the range is too close or has gone by', () {
      for (final earliest in [
        today.addDays(1),
        today,
        today.addDays(-10),
        today.addDays(-200),
      ]) {
        expect(
          planReminders(
            settings: settings,
            today: today,
            now: noon,
            prediction: predictionFrom(earliest),
          ),
          isEmpty,
          reason: 'range starting on $earliest',
        );
      }
    });
  });

  group('daily entry', () {
    final settings = ReminderSettings(dailyEnabled: true);

    test('covers the coming days, one reminder per day', () {
      final planned = planReminders(
        settings: settings,
        today: today,
        now: noon,
      );
      expect(planned, hasLength(dailyReminderHorizonDays));
      expect(planned.first.day, today);
      expect(planned.last.day, today.addDays(dailyReminderHorizonDays - 1));
      expect(
        planned.every(
          (reminder) =>
              reminder.kind == ReminderKind.dailyEntry &&
              reminder.time == ClockTime(20, 0),
        ),
        isTrue,
      );
    });

    test('skips today once the time has gone by', () {
      final planned = planReminders(
        settings: settings,
        today: today,
        now: ClockTime(20, 0),
      );
      expect(planned, hasLength(dailyReminderHorizonDays - 1));
      expect(planned.first.day, today.addDays(1));
    });

    test('skips a day that is already logged', () {
      final planned = planReminders(
        settings: settings,
        today: today,
        now: noon,
        loggedDays: {today, today.addDays(-1)},
      );
      expect(planned, hasLength(dailyReminderHorizonDays - 1));
      expect(planned.first.day, today.addDays(1));
    });

    test('crosses the end of a month and of a year', () {
      final planned = planReminders(
        settings: settings,
        today: CalendarDay(2026, 12, 25),
        now: noon,
      );
      expect(planned.last.day, CalendarDay(2027, 1, 7));
    });
  });

  test('both reminders come out in chronological order', () {
    final planned = planReminders(
      settings: ReminderSettings(periodEnabled: true, dailyEnabled: true),
      today: today,
      now: noon,
      prediction: predictionFrom(today.addDays(5)),
    );
    expect(planned, hasLength(dailyReminderHorizonDays + 1));
    // Three days from now: the period reminder at 9:00, before the daily one.
    expect(planned[3].kind, ReminderKind.periodApproaching);
    expect(planned[3].day, today.addDays(3));
    expect(planned[4].kind, ReminderKind.dailyEntry);
    expect(planned[4].day, today.addDays(3));
  });
}
