import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/catch_up.dart';
import 'package:fycle/domain/cycle_history.dart';
import 'package:fycle/domain/cycle_status.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/period_prediction.dart';

/// Fictional log: periods of [length] days starting on each of [starts].
Map<CalendarDay, FlowIntensity> flowOf(
  List<CalendarDay> starts, {
  int length = 4,
}) => {
  for (final start in starts)
    for (var i = 0; i < length; i++) start.addDays(i): FlowIntensity.medium,
};

void main() {
  final prediction = PeriodPrediction(
    earliestStart: CalendarDay(2026, 3, 25),
    latestStart: CalendarDay(2026, 3, 29),
    confidence: PredictionConfidence.medium,
    estimatedCycleLength: 28,
    cyclesUsed: 2,
  );
  final starts = [
    CalendarDay(2026, 1, 3),
    CalendarDay(2026, 1, 31),
    CalendarDay(2026, 2, 28),
  ];
  final flow = flowOf(starts);
  final cycles = cycleHistory(flow);

  CatchUp? ask(
    CalendarDay today, {
    Map<CalendarDay, FlowIntensity>? flowByDay,
    CalendarDay? notYetOn,
    CalendarDay? endedAfter,
    int? declaredPeriodLength,
  }) {
    final log = flowByDay ?? flow;
    return catchUpOn(
      today,
      flowByDay: log,
      status: cycleStatusOn(today, flowByDay: log, prediction: prediction),
      cycles: cycleHistory(log),
      declaredPeriodLength: declaredPeriodLength,
      notYetOn: notYetOn,
      endedAfter: endedAfter,
    );
  }

  group('a period that may have started', () {
    test('is not asked about before the estimated range', () {
      expect(ask(CalendarDay(2026, 3, 24)), isNull);
    });

    test('is asked about inside the range and after it', () {
      final due = ask(CalendarDay(2026, 3, 25));
      expect(due, isA<AskPeriodStarted>());
      // The last flow day was 3 March: a new period starts on the 11th at
      // the earliest.
      expect(
        (due! as AskPeriodStarted).earliestStart,
        CalendarDay(2026, 3, 11),
      );
      expect(ask(CalendarDay(2026, 4, 5)), isA<AskPeriodStarted>());
    });

    test('is not asked about twice on the day she said not yet', () {
      final today = CalendarDay(2026, 3, 26);
      expect(ask(today, notYetOn: today), isNull);
      expect(ask(today.addDays(1), notYetOn: today), isA<AskPeriodStarted>());
    });

    test('is not asked about once the log has been left aside', () {
      expect(ask(CalendarDay(2026, 9, 1)), isNull);
    });

    test('fills from the day she gives to today, within her usual length', () {
      final today = CalendarDay(2026, 3, 30);
      expect(daysSinceStart(CalendarDay(2026, 3, 29), today, periodLength: 4), [
        CalendarDay(2026, 3, 29),
        today,
      ]);
      expect(daysSinceStart(CalendarDay(2026, 3, 22), today, periodLength: 4), [
        for (var day = 22; day <= 25; day++) CalendarDay(2026, 3, day),
      ]);
    });
  });

  group('a period logged on its first days only', () {
    // The last period was logged on its first day only.
    final short = {
      ...flowOf(starts.sublist(0, 2)),
      CalendarDay(2026, 2, 28): FlowIntensity.medium,
    };

    test('is asked about while her usual length is not reached', () {
      final found = ask(CalendarDay(2026, 3, 2), flowByDay: short);
      expect(found, isA<AskPeriodContinues>());
      expect(
        (found! as AskPeriodContinues).lastFlowDay,
        CalendarDay(2026, 2, 28),
      );
      // Her periods last 4 days: on the 5th day, nothing is asked.
      expect(ask(CalendarDay(2026, 3, 4), flowByDay: short), isNull);
    });

    test('is not asked about once today is logged', () {
      final today = CalendarDay(2026, 3, 1);
      expect(
        ask(today, flowByDay: {...short, today: FlowIntensity.light}),
        isNull,
      );
    });

    test('is not asked about again once she said it was over', () {
      expect(
        ask(
          CalendarDay(2026, 3, 1),
          flowByDay: short,
          endedAfter: CalendarDay(2026, 2, 28),
        ),
        isNull,
      );
    });

    test('fills every day since the last one logged', () {
      expect(
        daysSinceLastFlow(CalendarDay(2026, 2, 28), CalendarDay(2026, 3, 2)),
        [CalendarDay(2026, 3, 1), CalendarDay(2026, 3, 2)],
      );
    });
  });

  group('how long a period of hers may last', () {
    test('her longest recent period', () {
      expect(periodLengthToFill(cycles: cycles, declaredPeriodLength: 6), 4);
    });

    test('what she said, then the reference, while none is complete', () {
      final first = cycleHistory({
        CalendarDay(2026, 2, 28): FlowIntensity.medium,
      });
      expect(periodLengthToFill(cycles: first, declaredPeriodLength: 6), 6);
      expect(periodLengthToFill(cycles: first), 5);
    });
  });
}
