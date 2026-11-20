import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/coming_signs.dart';
import 'package:fycle/domain/cycle_history.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/period_prediction.dart';
import 'package:fycle/domain/reminders.dart';
import 'package:fycle/domain/symptom.dart';

/// Fictional log: periods of 4 days, starting [lengths] days apart from
/// [first], followed by one last period (the current cycle).
List<DayEntry> periods(CalendarDay first, List<int> lengths) {
  final days = <DayEntry>[];
  var start = first;
  for (final length in [...lengths, 0]) {
    for (var i = 0; i < 4; i++) {
      days.add(DayEntry(day: start.addDays(i), flow: FlowIntensity.medium));
    }
    start = start.addDays(length);
  }
  return days;
}

List<LoggedCycle> cyclesOf(List<DayEntry> days) => cycleHistory({
  for (final entry in days)
    if (entry.flow != null) entry.day: entry.flow!,
});

DayEntry signs(CalendarDay day, Set<Symptom> symptoms) =>
    DayEntry(day: day, symptoms: symptoms);

void main() {
  // Periods on 1 Jan, 29 Jan, 26 Feb and 26 Mar: three complete cycles of
  // 28 days.
  final first = CalendarDay(2026, 1, 1);
  final log = periods(first, [28, 28, 28]);
  final cycles = cyclesOf(log);

  group('signs before a period', () {
    test('are counted backwards from the period that followed', () {
      final found = signsBeforePeriod(
        cycles: cycles,
        days: [
          ...log,
          // Three days, then two days before the period of 29 Jan.
          signs(CalendarDay(2026, 1, 26), {Symptom.cravings, Symptom.bloating}),
          signs(CalendarDay(2026, 1, 27), {Symptom.cravings}),
          // The day before the period of 26 Feb.
          signs(CalendarDay(2026, 2, 25), {Symptom.cravings}),
          // In the middle of a cycle: not a sign of the days before.
          signs(CalendarDay(2026, 2, 10), {Symptom.headache}),
          signs(CalendarDay(2026, 3, 10), {Symptom.headache}),
        ],
      );
      expect(found, hasLength(1));
      final cravings = found.single;
      expect(cravings.sign, Symptom.cravings);
      expect(cravings.source, SignSource.logged);
      expect(cravings.cycles, 2);
      expect(cravings.cyclesConsidered, 3);
      // First logged three days before in one cycle, the day before in
      // the other.
      expect(cravings.farthestDaysBefore, 3);
      expect(cravings.nearestDaysBefore, 1);
    });

    test('a sign seen in one cycle only is not hers yet', () {
      final found = signsBeforePeriod(
        cycles: cycles,
        days: [
          ...log,
          signs(CalendarDay(2026, 1, 27), {Symptom.bloating}),
        ],
      );
      expect(found.every((sign) => sign.source == SignSource.common), isTrue);
    });

    test('a sign seen in fewer than half the cycles is left out', () {
      // Five complete cycles, cravings before two of them.
      final long = periods(first, [28, 28, 28, 28, 28]);
      final found = signsBeforePeriod(
        cycles: cyclesOf(long),
        days: [
          ...long,
          signs(CalendarDay(2026, 1, 27), {Symptom.cravings}),
          signs(CalendarDay(2026, 2, 24), {Symptom.cravings}),
        ],
      );
      expect(found.first.source, SignSource.common);
    });

    test('the days of the period itself are not days before', () {
      // A cycle of 21 days with a period of 4: the first days of the cycle
      // are within a week of the next period.
      final short = periods(first, [21, 21, 21]);
      final found = signsBeforePeriod(
        cycles: cyclesOf(short).map((cycle) => cycle).toList(),
        days: [
          for (final entry in short)
            DayEntry(
              day: entry.day,
              flow: entry.flow,
              symptoms: const {Symptom.cramps},
            ),
        ],
      );
      expect(found.first.source, SignSource.common);
    });

    test('what she said comes after what she logged', () {
      final found = signsBeforePeriod(
        cycles: cycles,
        days: [
          ...log,
          signs(CalendarDay(2026, 1, 27), {Symptom.cravings}),
          signs(CalendarDay(2026, 2, 24), {Symptom.cravings}),
        ],
        declared: {Symptom.cravings, Symptom.fatigue},
      );
      expect(
        [for (final sign in found) (sign.sign, sign.source)],
        [
          (Symptom.cravings, SignSource.logged),
          (Symptom.fatigue, SignSource.declared),
        ],
      );
    });

    test('what she said stands from the first day', () {
      final found = signsBeforePeriod(
        cycles: const [],
        days: const [],
        declared: {Symptom.bloating},
      );
      expect(found.single.sign, Symptom.bloating);
      expect(found.single.source, SignSource.declared);
    });

    test('with nothing of hers, the common ones, said as such', () {
      final found = signsBeforePeriod(cycles: const [], days: const []);
      expect([for (final sign in found) sign.sign], commonSignsBeforePeriod);
      expect(found.every((sign) => sign.source == SignSource.common), isTrue);
    });
  });

  group('when they may come', () {
    final prediction = PeriodPrediction(
      earliestStart: CalendarDay(2026, 4, 22),
      latestStart: CalendarDay(2026, 4, 26),
      confidence: PredictionConfidence.medium,
      estimatedCycleLength: 28,
      cyclesUsed: 3,
    );

    test('as long before the range as she logged them the earliest', () {
      const hers = [
        SignBeforePeriod(
          sign: Symptom.cravings,
          source: SignSource.logged,
          cycles: 2,
          cyclesConsidered: 3,
          farthestDaysBefore: 3,
          nearestDaysBefore: 1,
        ),
        SignBeforePeriod(sign: Symptom.fatigue, source: SignSource.declared),
      ];
      expect(signsMayComeFrom(prediction, hers), CalendarDay(2026, 4, 19));
    });

    test('a week before, when none was logged yet', () {
      const said = [
        SignBeforePeriod(sign: Symptom.fatigue, source: SignSource.declared),
      ];
      expect(signsMayComeFrom(prediction, said), CalendarDay(2026, 4, 15));
    });

    test('the reminder comes the day before, once', () {
      final planned = planReminders(
        settings: ReminderSettings(signsEnabled: true),
        today: CalendarDay(2026, 4, 10),
        now: ClockTime(12, 0),
        prediction: prediction,
        signsFrom: CalendarDay(2026, 4, 19),
      );
      expect(planned, [
        PlannedReminder(
          kind: ReminderKind.comingSigns,
          day: CalendarDay(2026, 4, 18),
          time: ClockTime(9, 0),
        ),
      ]);
    });

    test('no reminder while no sign of hers is known, or once it is past', () {
      final settings = ReminderSettings(signsEnabled: true);
      expect(
        planReminders(
          settings: settings,
          today: CalendarDay(2026, 4, 10),
          now: ClockTime(12, 0),
          prediction: prediction,
        ),
        isEmpty,
      );
      expect(
        planReminders(
          settings: settings,
          today: CalendarDay(2026, 4, 18),
          now: ClockTime(12, 0),
          prediction: prediction,
          signsFrom: CalendarDay(2026, 4, 19),
        ),
        isEmpty,
      );
    });
  });
}
