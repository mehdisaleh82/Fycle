import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/cycle_history.dart';
import 'package:fycle/domain/flow_intensity.dart';

/// Fictional log: [length] consecutive flow days starting on [start].
Map<CalendarDay, FlowIntensity> flowRun(
  CalendarDay start,
  int length, {
  FlowIntensity intensity = FlowIntensity.medium,
}) => {for (var i = 0; i < length; i++) start.addDays(i): intensity};

void main() {
  final jan = CalendarDay(2026, 1, 10);
  final feb = CalendarDay(2026, 2, 7); // 28 days later
  final mar = CalendarDay(2026, 3, 9); // 30 days later

  group('cycleHistory', () {
    test('returns nothing for an empty log', () {
      expect(cycleHistory({}), isEmpty);
    });

    test('a single period is the current cycle, with no length yet', () {
      final cycles = cycleHistory(flowRun(jan, 5));
      expect(cycles, [LoggedCycle(start: jan, length: null, periodLength: 5)]);
      expect(cycles.single.isComplete, isFalse);
      expect(cycles.single.isPlausible, isFalse);
      expect(cycles.single.end, isNull);
    });

    test('lists complete cycles oldest first, then the current one', () {
      final cycles = cycleHistory({
        ...flowRun(mar, 6),
        ...flowRun(jan, 5),
        ...flowRun(feb, 4),
      });
      expect(cycles, [
        LoggedCycle(start: jan, length: 28, periodLength: 5),
        LoggedCycle(start: feb, length: 30, periodLength: 4),
        LoggedCycle(start: mar, length: null, periodLength: 6),
      ]);
      expect(cycles.first.end, CalendarDay(2026, 2, 6));
      expect(cycles.first.periodEnd, CalendarDay(2026, 1, 14));
    });

    test('a short pause inside a period counts in its length', () {
      final cycles = cycleHistory({
        ...flowRun(jan, 3),
        ...flowRun(jan.addDays(5), 2),
      });
      expect(cycles.single.periodLength, 7);
    });

    test('spotting neither starts nor extends a period', () {
      final cycles = cycleHistory({
        ...flowRun(jan.addDays(-2), 2, intensity: FlowIntensity.spotting),
        ...flowRun(jan, 4),
        ...flowRun(jan.addDays(4), 2, intensity: FlowIntensity.spotting),
        ...flowRun(jan.addDays(15), 1, intensity: FlowIntensity.spotting),
      });
      expect(cycles, [LoggedCycle(start: jan, length: null, periodLength: 4)]);
    });

    test('a very long or very short cycle is listed but not plausible', () {
      final cycles = cycleHistory({
        ...flowRun(jan, 4),
        ...flowRun(jan.addDays(120), 4),
        ...flowRun(jan.addDays(132), 4),
        ...flowRun(jan.addDays(160), 4),
      });
      expect([for (final cycle in cycles) cycle.length], [120, 12, 28, null]);
      expect(
        [for (final cycle in cycles) cycle.isPlausible],
        [false, false, true, false],
      );
    });
  });

  group('cycleAverages', () {
    test('has no average for an empty log', () {
      final averages = cycleAverages(const [], today: jan);
      expect(averages.cycleLength, isNull);
      expect(averages.periodLength, isNull);
      expect(averages.cyclesCounted, 0);
    });

    test('averages complete cycles and their periods', () {
      final cycles = cycleHistory({
        ...flowRun(jan, 5),
        ...flowRun(feb, 4),
        ...flowRun(mar, 6),
      });
      final averages = cycleAverages(cycles, today: mar.addDays(2));
      expect(averages.cycleLength, 29);
      expect(averages.cyclesCounted, 2);
      // The period of the current cycle may still be going on.
      expect(averages.periodLength, 4.5);
    });

    test('counts the current period once it is clearly over', () {
      final cycles = cycleHistory({
        ...flowRun(jan, 5),
        ...flowRun(feb, 4),
        ...flowRun(mar, 6),
      });
      final averages = cycleAverages(cycles, today: mar.addDays(20));
      expect(averages.periodLength, 5);
    });

    test('with one period only, waits until it is over', () {
      final cycles = cycleHistory(flowRun(jan, 5));
      expect(cycleAverages(cycles, today: jan.addDays(4)).periodLength, isNull);
      expect(cycleAverages(cycles, today: jan.addDays(12)).periodLength, 5);
      expect(cycleAverages(cycles, today: jan.addDays(12)).cycleLength, isNull);
    });

    test('leaves implausible cycles out', () {
      final cycles = cycleHistory({
        ...flowRun(jan, 4),
        ...flowRun(jan.addDays(120), 4),
        ...flowRun(jan.addDays(148), 4),
        ...flowRun(jan.addDays(178), 4),
      });
      final averages = cycleAverages(cycles, today: jan.addDays(179));
      expect(averages.cycleLength, 29);
      expect(averages.cyclesCounted, 2);
    });

    test('keeps the most recent cycles only', () {
      final log = <CalendarDay, FlowIntensity>{};
      var start = jan;
      // Three cycles of 40 days, then six of 28.
      for (final length in [40, 40, 40, 28, 28, 28, 28, 28, 28]) {
        log.addAll(flowRun(start, 4));
        start = start.addDays(length);
      }
      log.addAll(flowRun(start, 4));
      final averages = cycleAverages(cycleHistory(log), today: start);
      expect(averages.cycleLength, 28);
      expect(averages.cyclesCounted, 6);
    });
  });

  group('cycleMomentOf', () {
    final cycle = LoggedCycle(start: jan, length: 28, periodLength: 5);

    test('period days', () {
      expect(cycleMomentOf(jan, cycle), CycleMoment.period);
      expect(cycleMomentOf(jan.addDays(4), cycle), CycleMoment.period);
    });

    test('the last seven days come before the next period', () {
      expect(cycleMomentOf(jan.addDays(20), cycle), CycleMoment.rest);
      expect(
        cycleMomentOf(jan.addDays(21), cycle),
        CycleMoment.beforeNextPeriod,
      );
      expect(
        cycleMomentOf(jan.addDays(27), cycle),
        CycleMoment.beforeNextPeriod,
      );
    });

    test('every other day is the rest of the cycle', () {
      expect(cycleMomentOf(jan.addDays(5), cycle), CycleMoment.rest);
    });

    test('a day outside the cycle has no moment', () {
      expect(cycleMomentOf(jan.addDays(-1), cycle), isNull);
      expect(cycleMomentOf(jan.addDays(28), cycle), isNull);
    });

    test('the current cycle has no moments yet', () {
      final current = LoggedCycle(start: jan, length: null, periodLength: 5);
      expect(cycleMomentOf(jan, current), isNull);
    });

    test('in a very short cycle the period comes first', () {
      final short = LoggedCycle(start: jan, length: 9, periodLength: 5);
      expect(cycleMomentOf(jan.addDays(4), short), CycleMoment.period);
      expect(
        cycleMomentOf(jan.addDays(5), short),
        CycleMoment.beforeNextPeriod,
      );
    });
  });
}
