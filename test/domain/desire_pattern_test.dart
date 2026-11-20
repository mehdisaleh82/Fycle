import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/cycle_history.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/desire_pattern.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/libido_level.dart';
import 'package:fycle/domain/period_prediction.dart';

void main() {
  // Periods on 1 Jan, 29 Jan, 26 Feb and 26 Mar: three complete cycles of
  // 28 days, then the cycle going on.
  final starts = [
    CalendarDay(2026, 1, 1),
    CalendarDay(2026, 1, 29),
    CalendarDay(2026, 2, 26),
    CalendarDay(2026, 3, 26),
  ];
  final cycles = cycleHistory({
    for (final start in starts)
      for (var i = 0; i < 4; i++) start.addDays(i): FlowIntensity.medium,
  });

  /// Desire logged on the [day]th day of the cycle numbered [cycle].
  DayEntry desire(int cycle, int day, LibidoLevel level) =>
      DayEntry(day: starts[cycle].addDays(day - 1), libido: level);

  group('where in the cycle her desire is often higher', () {
    test('the days she logged it high, cycle after cycle', () {
      final window = usualDesireWindow(
        cycles: cycles,
        days: [
          desire(0, 13, LibidoLevel.high),
          desire(0, 14, LibidoLevel.high),
          desire(1, 12, LibidoLevel.high),
          // Logged, but never high, in the third cycle.
          desire(2, 13, LibidoLevel.low),
          // A lone high day elsewhere does not move the window.
          desire(1, 24, LibidoLevel.high),
        ],
      );
      expect(
        window,
        const DesireWindow(
          fromDay: 12,
          toDay: 14,
          cycles: 2,
          cyclesConsidered: 3,
        ),
      );
    });

    test('nothing while desire was logged in one cycle only', () {
      expect(
        usualDesireWindow(
          cycles: cycles,
          days: [
            desire(0, 13, LibidoLevel.high),
            desire(0, 14, LibidoLevel.high),
          ],
        ),
        isNull,
      );
    });

    test('nothing when the high days never fall together', () {
      expect(
        usualDesireWindow(
          cycles: cycles,
          days: [
            desire(0, 5, LibidoLevel.high),
            desire(1, 15, LibidoLevel.high),
            desire(2, 25, LibidoLevel.high),
          ],
        ),
        isNull,
      );
    });

    test('a cycle in which desire was not logged is not held against it', () {
      final window = usualDesireWindow(
        cycles: cycles,
        days: [
          desire(0, 13, LibidoLevel.high),
          desire(1, 13, LibidoLevel.high),
        ],
      );
      expect(window?.cycles, 2);
      expect(window?.cyclesConsidered, 2);
    });
  });

  group('the dates ahead', () {
    const window = DesireWindow(
      fromDay: 12,
      toDay: 14,
      cycles: 2,
      cyclesConsidered: 3,
    );
    final prediction = PeriodPrediction(
      earliestStart: CalendarDay(2026, 4, 21),
      latestStart: CalendarDay(2026, 4, 25),
      confidence: PredictionConfidence.medium,
      estimatedCycleLength: 28,
      cyclesUsed: 3,
    );

    test('in the cycle going on, while they are not behind', () {
      final dates = desireDatesAhead(
        window,
        cycleStart: starts.last,
        today: CalendarDay(2026, 4, 1),
        prediction: prediction,
      );
      expect(dates, (
        from: CalendarDay(2026, 4, 6),
        to: CalendarDay(2026, 4, 8),
      ));
    });

    test('in the cycle after, counted from its estimated range', () {
      final dates = desireDatesAhead(
        window,
        cycleStart: starts.last,
        today: CalendarDay(2026, 4, 12),
        prediction: prediction,
      );
      expect(dates, (
        from: CalendarDay(2026, 5, 2),
        to: CalendarDay(2026, 5, 8),
      ));
    });

    test('nothing once the estimated range is behind', () {
      expect(
        desireDatesAhead(
          window,
          cycleStart: starts.last,
          today: CalendarDay(2026, 5, 10),
          prediction: prediction,
        ),
        isNull,
      );
    });
  });
}
