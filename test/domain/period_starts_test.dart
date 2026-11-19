import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/period_starts.dart';

/// Fictional log: [length] consecutive flow days starting on [start].
Map<CalendarDay, FlowIntensity> flowRun(
  CalendarDay start,
  int length, {
  FlowIntensity intensity = FlowIntensity.medium,
}) => {for (var i = 0; i < length; i++) start.addDays(i): intensity};

void main() {
  group('periodStartsFrom', () {
    test('returns nothing for an empty log', () {
      expect(periodStartsFrom({}), isEmpty);
    });

    test('finds the first day of a single period', () {
      final log = flowRun(CalendarDay(2026, 1, 10), 5);
      expect(periodStartsFrom(log), [CalendarDay(2026, 1, 10)]);
    });

    test('finds one start per period, in chronological order', () {
      final log = {
        ...flowRun(CalendarDay(2026, 3, 7), 5),
        ...flowRun(CalendarDay(2026, 1, 10), 5),
        ...flowRun(CalendarDay(2026, 2, 7), 4),
      };
      expect(periodStartsFrom(log), [
        CalendarDay(2026, 1, 10),
        CalendarDay(2026, 2, 7),
        CalendarDay(2026, 3, 7),
      ]);
    });

    test('a short pause inside a period does not start a new one', () {
      final log = {
        ...flowRun(CalendarDay(2026, 1, 10), 3),
        // Two days without flow, then flow again.
        ...flowRun(CalendarDay(2026, 1, 15), 2),
      };
      expect(periodStartsFrom(log), [CalendarDay(2026, 1, 10)]);
    });

    test('six flow-free days are still the same period', () {
      final log = {
        CalendarDay(2026, 1, 10): FlowIntensity.heavy,
        CalendarDay(2026, 1, 17): FlowIntensity.light,
      };
      expect(periodStartsFrom(log), [CalendarDay(2026, 1, 10)]);
    });

    test('seven flow-free days start a new period', () {
      final log = {
        CalendarDay(2026, 1, 10): FlowIntensity.heavy,
        CalendarDay(2026, 1, 18): FlowIntensity.light,
      };
      expect(periodStartsFrom(log), [
        CalendarDay(2026, 1, 10),
        CalendarDay(2026, 1, 18),
      ]);
    });

    test('isolated spotting does not start a period', () {
      final log = {
        ...flowRun(CalendarDay(2026, 1, 10), 5),
        CalendarDay(2026, 1, 24): FlowIntensity.spotting,
        ...flowRun(CalendarDay(2026, 2, 7), 5),
      };
      expect(periodStartsFrom(log), [
        CalendarDay(2026, 1, 10),
        CalendarDay(2026, 2, 7),
      ]);
    });

    test('spotting just before a period is not its first day', () {
      final log = {
        CalendarDay(2026, 2, 6): FlowIntensity.spotting,
        ...flowRun(CalendarDay(2026, 2, 7), 5),
      };
      expect(periodStartsFrom(log), [CalendarDay(2026, 2, 7)]);
    });

    test('a log with spotting only has no period', () {
      final log = flowRun(
        CalendarDay(2026, 1, 10),
        3,
        intensity: FlowIntensity.spotting,
      );
      expect(periodStartsFrom(log), isEmpty);
    });
  });
}
