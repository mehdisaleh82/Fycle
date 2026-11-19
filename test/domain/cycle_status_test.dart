import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/cycle_status.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/period_prediction.dart';

void main() {
  // A period logged from 1 to 4 March, the next one expected 27 to 31 March.
  final flow = {
    CalendarDay(2026, 3, 1): FlowIntensity.medium,
    CalendarDay(2026, 3, 2): FlowIntensity.heavy,
    CalendarDay(2026, 3, 3): FlowIntensity.light,
    CalendarDay(2026, 3, 4): FlowIntensity.spotting,
  };
  final prediction = PeriodPrediction(
    earliestStart: CalendarDay(2026, 3, 27),
    latestStart: CalendarDay(2026, 3, 31),
    confidence: PredictionConfidence.low,
    estimatedCycleLength: 28,
    cyclesUsed: 0,
  );

  CycleStatus statusOn(int month, int day) => cycleStatusOn(
    CalendarDay(2026, month, day),
    flowByDay: flow,
    prediction: prediction,
  );

  test('no prediction means no estimate', () {
    final status = cycleStatusOn(
      CalendarDay(2026, 3, 1),
      flowByDay: const {},
      prediction: null,
    );
    expect(status, isA<NoEstimate>());
  });

  test('a day with flow is a day of the period, counted from its start', () {
    final first = statusOn(3, 1) as PeriodOngoing;
    expect(first.dayOfPeriod, 1);
    final third = statusOn(3, 3) as PeriodOngoing;
    expect(third.dayOfPeriod, 3);
    expect(third.next, same(prediction));
  });

  test('spotting alone is not a period day', () {
    expect(statusOn(3, 4), isA<PeriodExpected>());
  });

  test('before the range, the days until it starts are counted', () {
    final status = statusOn(3, 20) as PeriodExpected;
    expect(status.daysUntil, 7);
    expect((statusOn(3, 26) as PeriodExpected).daysUntil, 1);
  });

  test('both ends of the range are inside it', () {
    expect(statusOn(3, 27), isA<PeriodDue>());
    expect(statusOn(3, 31), isA<PeriodDue>());
  });

  test('after the range, the days past it are counted', () {
    expect((statusOn(4, 1) as PeriodLate).daysLate, 1);
    expect((statusOn(4, 10) as PeriodLate).daysLate, 10);
  });

  test('long after the range, the estimate is outdated', () {
    expect((statusOn(6, 29) as PeriodLate).daysLate, maxDaysLateReported);
    expect(statusOn(6, 30), isA<EstimateOutdated>());
  });
}
