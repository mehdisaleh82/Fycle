import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/cycle_change.dart';
import 'package:fycle/domain/cycle_history.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/symptom.dart';

/// Cycles of the given [lengths], the first starting on 1 January 2025,
/// followed by a period that opens the cycle going on.
List<LoggedCycle> cyclesOf(List<int> lengths) {
  var start = CalendarDay(2025, 1, 1);
  final flow = <CalendarDay, FlowIntensity>{};
  for (final length in [...lengths, 0]) {
    for (var i = 0; i < 4; i++) {
      flow[start.addDays(i)] = FlowIntensity.medium;
    }
    start = start.addDays(length);
  }
  return cycleHistory(flow);
}

CycleChange changeOf(
  List<int> lengths, {
  int daysIntoCurrent = 10,
  List<DayEntry> days = const [],
}) {
  final cycles = cyclesOf(lengths);
  return cycleChangeOn(
    cycles.last.start.addDays(daysIntoCurrent),
    cycles: cycles,
    days: days,
  );
}

void main() {
  test('nothing to tell before two complete cycles', () {
    expect(changeOf([]).isEmpty, isTrue);
    final one = changeOf([28]);
    expect(one.cyclesCompared, 0);
    expect(one.isEmpty, isTrue);
  });

  test('counts the cycles that differ from the one before by 7 days', () {
    final steady = changeOf([28, 30, 27, 29]);
    expect(steady.cyclesCompared, 3);
    expect(steady.markedDifferences, 0);
    expect(steady.differenceComesBack, isFalse);

    // 28 to 35 is 7 days: counted. 35 to 29 is 6: not counted.
    final once = changeOf([28, 35, 29]);
    expect(once.markedDifferences, 1);
    expect(once.differenceComesBack, isFalse);

    final twice = changeOf([28, 37, 28, 28]);
    expect(twice.markedDifferences, 2);
    expect(twice.differenceComesBack, isTrue);
  });

  test('looks at the last ten cycles only', () {
    // Two marked differences, then eleven steady cycles.
    final change = changeOf([28, 40, 28, ...List.filled(11, 28)]);
    expect(change.cyclesCompared, 10);
    expect(change.markedDifferences, 0);
  });

  test('a cycle of 60 days or more is a long interval', () {
    expect(changeOf([28, 59, 28]).longestInterval, isNull);
    expect(changeOf([28, 60, 28]).longestInterval, 60);
    expect(changeOf([28, 66, 75, 28]).longestInterval, 75);
  });

  test('a cycle too long to be one is a gap in the log, not a change', () {
    final change = changeOf([28, 120, 28, 29]);
    expect(change.longestInterval, isNull);
    // Only 28 and 29 are next to each other.
    expect(change.cyclesCompared, 1);
    expect(change.markedDifferences, 0);
  });

  test('60 days into the cycle going on, says so', () {
    expect(changeOf([28], daysIntoCurrent: 59).daysSinceLastPeriod, isNull);
    final change = changeOf([28], daysIntoCurrent: 60);
    expect(change.daysSinceLastPeriod, 60);
    expect(change.isEmpty, isFalse);
  });

  test('counts the days with each sign over the last 90 days', () {
    final cycles = cyclesOf([28, 28]);
    final today = cycles.last.start.addDays(5);
    DayEntry signs(int daysAgo, Set<Symptom> symptoms) =>
        DayEntry(day: today.addDays(-daysAgo), symptoms: symptoms);
    final change = cycleChangeOn(
      today,
      cycles: cycles,
      days: [
        signs(0, {Symptom.hotFlashes, Symptom.nightSweats}),
        signs(3, {Symptom.hotFlashes}),
        signs(89, {Symptom.hotFlashes, Symptom.cramps}),
        signs(90, {Symptom.hotFlashes}),
        signs(10, {Symptom.cramps}),
      ],
    );
    expect(change.hotFlashDays, 3);
    expect(change.nightSweatDays, 1);
  });
}
