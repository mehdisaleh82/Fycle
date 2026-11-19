import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/cycle_comparison.dart';
import 'package:fycle/domain/cycle_history.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/pain_level.dart';
import 'package:fycle/domain/sleep_quality.dart';

/// Fictional log: a period of [length] days of flow starting on [start].
List<DayEntry> period(CalendarDay start, int length) => [
  for (var i = 0; i < length; i++)
    DayEntry(day: start.addDays(i), flow: FlowIntensity.medium),
];

CycleComparison? compare(List<DayEntry> days, CalendarDay today) =>
    compareWithPreviousCycle(
      cycles: cycleHistory({
        for (final entry in days)
          if (entry.flow != null) entry.day: entry.flow!,
      }),
      days: days,
      today: today,
    );

void main() {
  final first = CalendarDay(2026, 1, 1);
  final second = first.addDays(28);

  test('there is nothing to compare with before a second cycle', () {
    expect(compare(const [], first), isNull);
    expect(compare(period(first, 4), first.addDays(10)), isNull);
  });

  test('both cycles are taken at the same point', () {
    final days = [
      ...period(first, 5),
      DayEntry(day: first.addDays(6), pain: PainLevel.mild),
      DayEntry(day: first.addDays(8), sleep: SleepQuality.poor),
      // After day 10 of the first cycle: not compared yet.
      DayEntry(day: first.addDays(15), pain: PainLevel.severe),
      DayEntry(day: first.addDays(20), sleep: SleepQuality.poor),
      ...period(second, 4),
      DayEntry(day: second.addDays(5), sleep: SleepQuality.poor),
      DayEntry(day: second.addDays(7), sleep: SleepQuality.poor),
    ];
    // Day 10 of the second cycle.
    final result = compare(days, second.addDays(9))!;
    expect(result.dayOfCycle, 10);
    expect(
      result.current,
      const CycleSnapshot(
        periodDays: 4,
        painDays: 0,
        poorSleepNights: 2,
        daysLogged: 6,
      ),
    );
    expect(
      result.previous,
      const CycleSnapshot(
        periodDays: 5,
        painDays: 1,
        poorSleepNights: 1,
        daysLogged: 7,
      ),
    );
  });

  test('spotting and the absence of pain are not counted', () {
    final days = [
      ...period(first, 3),
      DayEntry(
        day: first.addDays(3),
        flow: FlowIntensity.spotting,
        pain: PainLevel.none,
      ),
      ...period(second, 3),
    ];
    final result = compare(days, second.addDays(5))!;
    expect(result.previous.periodDays, 3);
    expect(result.previous.painDays, 0);
    expect(result.previous.daysLogged, 4);
  });

  test('a current cycle longer than the one before stops at its length', () {
    final days = [...period(first, 4), ...period(second, 4)];
    final result = compare(days, second.addDays(40))!;
    expect(result.dayOfCycle, 28);
  });

  test('a cycle hiding a missed period is not compared with', () {
    final days = [...period(first, 4), ...period(first.addDays(120), 4)];
    expect(compare(days, first.addDays(125)), isNull);
  });

  test('the first day of a new cycle is already compared', () {
    final days = [...period(first, 4), ...period(second, 1)];
    final result = compare(days, second)!;
    expect(result.dayOfCycle, 1);
    expect(result.current.periodDays, 1);
    expect(result.previous.periodDays, 1);
  });
}
