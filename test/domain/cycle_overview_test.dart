import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/cycle_history.dart';
import 'package:fycle/domain/cycle_overview.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/period_predictor.dart';
import 'package:fycle/domain/period_starts.dart';
import 'package:fycle/domain/symptom.dart';

/// Fictional log: periods of [periodLength] days, starting [lengths] days
/// apart from [first], followed by one last period (the current cycle).
List<DayEntry> periods(
  CalendarDay first,
  List<int> lengths, {
  int periodLength = 4,
}) {
  final days = <DayEntry>[];
  var start = first;
  for (final length in [...lengths, 0]) {
    for (var i = 0; i < periodLength; i++) {
      days.add(DayEntry(day: start.addDays(i), flow: FlowIntensity.medium));
    }
    start = start.addDays(length);
  }
  return days;
}

Map<CalendarDay, FlowIntensity> flowOf(List<DayEntry> days) => {
  for (final entry in days)
    if (entry.flow != null) entry.day: entry.flow!,
};

CycleOverview overview(
  List<DayEntry> days,
  CalendarDay today, {
  int? usualCycleLength,
}) {
  final flow = flowOf(days);
  return cycleOverviewOn(
    today,
    cycles: cycleHistory(flow),
    prediction: const PeriodPredictor().predict(
      periodStarts: periodStartsFrom(flow),
      usualCycleLength: usualCycleLength,
    ),
    usualCycleLength: usualCycleLength,
    daysLogged: days.length,
  );
}

void main() {
  final first = CalendarDay(2026, 1, 1);

  group('cycleOverviewOn', () {
    test('with nothing logged, only the assumed cycle length is known', () {
      final result = overview(const [], first);
      expect(result.dayOfCycle, isNull);
      expect(result.cycleLength, PeriodPredictor.defaultCycleLength);
      expect(result.cycleLengthSource, LengthSource.assumed);
      expect(result.periodLength, referencePeriodLength);
      expect(result.periodLengthSource, LengthSource.assumed);
      expect(result.daysUntilEarliest, isNull);
      expect(result.daysLogged, 0);
      expect(result.completeCycles, 0);
    });

    test('gives figures from the very first logged date', () {
      final days = [DayEntry(day: first, flow: FlowIntensity.medium)];
      final result = overview(days, first.addDays(11));
      expect(result.dayOfCycle, 12);
      expect(result.cycleLength, 28);
      expect(result.cycleLengthSource, LengthSource.assumed);
      // Over for more than a week: it counts as a known period length.
      expect(result.periodLength, 1);
      expect(result.periodLengthSource, LengthSource.logged);
      expect(result.daysUntilEarliest, isNotNull);
      expect(result.daysUntilLatest, greaterThan(result.daysUntilEarliest!));
      expect(result.daysLogged, 1);
    });

    test('a period that may still be going on is given as current', () {
      final days = periods(first, []);
      final result = overview(days, first.addDays(4));
      expect(result.dayOfCycle, 5);
      expect(result.periodLength, 4);
      expect(result.periodLengthSource, LengthSource.current);
    });

    test('uses the declared length until cycles are logged', () {
      final days = [DayEntry(day: first, flow: FlowIntensity.medium)];
      final result = overview(days, first, usualCycleLength: 31);
      expect(result.cycleLength, 31);
      expect(result.cycleLengthSource, LengthSource.declared);
    });

    test('then counts on the logged cycles', () {
      final days = periods(first, [30, 30, 30], periodLength: 5);
      final result = overview(
        days,
        first.addDays(90 + 9),
        usualCycleLength: 25,
      );
      expect(result.dayOfCycle, 10);
      expect(result.cycleLength, 30);
      expect(result.cycleLengthSource, LengthSource.logged);
      expect(result.periodLength, 5);
      expect(result.periodLengthSource, LengthSource.logged);
      expect(result.completeCycles, 3);
    });

    test('the countdown goes negative once the range is behind', () {
      final days = periods(first, [28, 28]);
      final result = overview(days, first.addDays(56 + 60));
      expect(result.daysUntilLatest, isNegative);
    });
  });

  group('usualSignsAround', () {
    // Three complete cycles of 28 days.
    final log = periods(first, [28, 28, 28]);
    final starts = [first, first.addDays(28), first.addDays(56)];

    List<DayEntry> withSigns(List<DayEntry> extra) => [
      ...log.where((entry) => extra.every((added) => added.day != entry.day)),
      ...extra,
    ];

    test('finds what was logged around that day in several cycles', () {
      final days = withSigns([
        // Around day 14: on days 13, 14 and 15 of the three cycles.
        DayEntry(day: starts[0].addDays(12), symptoms: {Symptom.bloating}),
        DayEntry(day: starts[1].addDays(13), symptoms: {Symptom.bloating}),
        DayEntry(day: starts[2].addDays(14), symptoms: {Symptom.bloating}),
        // Twice only.
        DayEntry(day: starts[0].addDays(13), symptoms: {Symptom.fatigue}),
        DayEntry(
          day: starts[1].addDays(13),
          symptoms: {Symptom.fatigue, Symptom.bloating},
        ),
        // Once: not usual.
        DayEntry(day: starts[2].addDays(13), symptoms: {Symptom.acne}),
        // Far from day 14.
        DayEntry(day: starts[0].addDays(20), symptoms: {Symptom.nausea}),
        DayEntry(day: starts[1].addDays(20), symptoms: {Symptom.nausea}),
      ]);
      final usual = usualSignsAround(
        14,
        cycles: cycleHistory(flowOf(days)),
        days: days,
      );
      expect(
        [for (final sign in usual) sign.sign],
        [Symptom.bloating, Symptom.fatigue],
      );
      expect(usual.first.cycles, 3);
      expect(usual.first.cyclesConsidered, 3);
      expect(usual.last.cycles, 2);
    });

    test('says nothing with fewer than two complete cycles', () {
      final days = [
        ...periods(first, [28]),
        DayEntry(day: first.addDays(13), symptoms: {Symptom.bloating}),
      ];
      expect(
        usualSignsAround(14, cycles: cycleHistory(flowOf(days)), days: days),
        isEmpty,
      );
    });

    test('the current cycle is not counted', () {
      final days = withSigns([
        DayEntry(day: starts[0].addDays(13), symptoms: {Symptom.bloating}),
        // Day 14 of the current cycle.
        DayEntry(day: first.addDays(84 + 13), symptoms: {Symptom.bloating}),
      ]);
      expect(
        usualSignsAround(14, cycles: cycleHistory(flowOf(days)), days: days),
        isEmpty,
      );
    });
  });

  group('insightSteps', () {
    List<InsightStep> steps(List<DayEntry> days) {
      final flow = flowOf(days);
      return insightSteps(
        cycles: cycleHistory(flow),
        prediction: const PeriodPredictor().predict(
          periodStarts: periodStartsFrom(flow),
        ),
      );
    }

    test('nothing is reached with an empty log', () {
      expect(
        [for (final step in steps(const [])) step.reached],
        [false, false, false, false],
      );
    });

    test('a first period gives the estimate', () {
      final result = steps(periods(first, []));
      expect(
        [for (final step in result) step.reached],
        [true, false, false, false],
      );
      expect(result[2].have, 0);
      expect(result[2].need, 2);
    });

    test('each complete cycle brings more', () {
      expect(
        [
          for (final step in steps(periods(first, [28]))) step.reached,
        ],
        [true, true, false, false],
      );
      final two = steps(periods(first, [28, 28]));
      expect([for (final step in two) step.reached], [true, true, true, false]);
      expect(two[3].have, 2);
      expect(two[3].need, 4);
    });

    test('several regular cycles make the estimate reliable', () {
      final result = steps(periods(first, [28, 28, 28, 28, 28, 28]));
      expect(result.every((step) => step.reached), isTrue);
    });

    test('irregular cycles do not, however many there are', () {
      final result = steps(periods(first, [22, 36, 24, 38, 23, 37]));
      expect(result[2].reached, isTrue);
      expect(result[3].reached, isFalse);
      expect(result[3].have, lessThan(result[3].need));
    });
  });
}
