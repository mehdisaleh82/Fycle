import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/cycle_history.dart';
import 'package:fycle/domain/fertility_estimate.dart';
import 'package:fycle/domain/period_prediction.dart';
import 'package:fycle/domain/period_predictor.dart';

PeriodPrediction prediction(
  CalendarDay earliest,
  CalendarDay latest, {
  int cyclesUsed = 3,
  PredictionConfidence confidence = PredictionConfidence.medium,
}) => PeriodPrediction(
  earliestStart: earliest,
  latestStart: latest,
  confidence: confidence,
  estimatedCycleLength: 28,
  cyclesUsed: cyclesUsed,
);

void main() {
  final lastStart = CalendarDay(2026, 3, 1);

  group('fertilityEstimateFrom', () {
    test('counts back from the predicted range, with a margin', () {
      // Next period expected between 28 and 30 March.
      final estimate = fertilityEstimateFrom(
        prediction(CalendarDay(2026, 3, 28), CalendarDay(2026, 3, 30)),
        lastPeriodStart: lastStart,
      )!;
      // 28 March - 13 - 3, and 30 March - 13 + 3.
      expect(estimate.earliestOvulation, CalendarDay(2026, 3, 12));
      expect(estimate.latestOvulation, CalendarDay(2026, 3, 20));
      // Five days before, one day after.
      expect(estimate.windowStart, CalendarDay(2026, 3, 7));
      expect(estimate.windowEnd, CalendarDay(2026, 3, 21));
      expect(estimate.confidence, PredictionConfidence.medium);
    });

    test('is always a range, even for a one-day prediction', () {
      final day = CalendarDay(2026, 3, 29);
      final estimate = fertilityEstimateFrom(
        prediction(day, day),
        lastPeriodStart: lastStart,
      )!;
      expect(
        estimate.latestOvulation.daysSince(estimate.earliestOvulation),
        2 * ovulationMarginDays,
      );
      expect(estimate.windowEnd.isAfter(estimate.windowStart), isTrue);
    });

    test('widens when the next period is uncertain', () {
      final narrow = fertilityEstimateFrom(
        prediction(CalendarDay(2026, 3, 28), CalendarDay(2026, 3, 30)),
        lastPeriodStart: lastStart,
      )!;
      final wide = fertilityEstimateFrom(
        prediction(
          CalendarDay(2026, 3, 22),
          CalendarDay(2026, 4, 5),
          confidence: PredictionConfidence.low,
        ),
        lastPeriodStart: lastStart,
      )!;
      expect(
        wide.windowEnd.daysSince(wide.windowStart),
        greaterThan(narrow.windowEnd.daysSince(narrow.windowStart)),
      );
      expect(wide.confidence, PredictionConfidence.low);
    });

    test('gives nothing with fewer than two cycles behind it', () {
      for (final cycles in [0, 1]) {
        expect(
          fertilityEstimateFrom(
            prediction(
              CalendarDay(2026, 3, 28),
              CalendarDay(2026, 3, 30),
              cyclesUsed: cycles,
            ),
            lastPeriodStart: lastStart,
          ),
          isNull,
          reason: '$cycles cycles',
        );
      }
    });

    test('never opens before the period that started the cycle', () {
      // A short cycle: next period expected between 16 and 18 March.
      final estimate = fertilityEstimateFrom(
        prediction(CalendarDay(2026, 3, 16), CalendarDay(2026, 3, 18)),
        lastPeriodStart: lastStart,
      )!;
      expect(estimate.earliestOvulation, lastStart);
      expect(estimate.windowStart, lastStart);
      expect(estimate.latestOvulation, CalendarDay(2026, 3, 8));
    });

    test('says which days are inside the window', () {
      final estimate = fertilityEstimateFrom(
        prediction(CalendarDay(2026, 3, 28), CalendarDay(2026, 3, 30)),
        lastPeriodStart: lastStart,
      )!;
      expect(estimate.windowContains(CalendarDay(2026, 3, 6)), isFalse);
      expect(estimate.windowContains(CalendarDay(2026, 3, 7)), isTrue);
      expect(estimate.windowContains(CalendarDay(2026, 3, 21)), isTrue);
      expect(estimate.windowContains(CalendarDay(2026, 3, 22)), isFalse);
    });

    test('works on what the predictor gives for regular cycles', () {
      final starts = [
        CalendarDay(2026, 1, 3),
        CalendarDay(2026, 1, 31),
        CalendarDay(2026, 2, 28),
      ];
      final predicted = const PeriodPredictor().predict(periodStarts: starts)!;
      final estimate = fertilityEstimateFrom(
        predicted,
        lastPeriodStart: starts.last,
      )!;
      // 28-day cycles: ovulation is estimated around 14 March.
      final around = CalendarDay(2026, 3, 14);
      expect(estimate.earliestOvulation.isAfter(around), isFalse);
      expect(estimate.latestOvulation.isBefore(around), isFalse);
      expect(estimate.windowContains(around), isTrue);
    });
  });

  group('pastFertilityEstimate', () {
    test('looks back from the day the next period started', () {
      final estimate = pastFertilityEstimate(
        LoggedCycle(start: lastStart, length: 28, periodLength: 5),
      )!;
      // The next period started on 29 March.
      expect(estimate.earliestOvulation, CalendarDay(2026, 3, 13));
      expect(estimate.latestOvulation, CalendarDay(2026, 3, 19));
      expect(estimate.windowStart, CalendarDay(2026, 3, 8));
      expect(estimate.windowEnd, CalendarDay(2026, 3, 20));
    });

    test('there is none for the current cycle', () {
      expect(
        pastFertilityEstimate(
          LoggedCycle(start: lastStart, length: null, periodLength: 5),
        ),
        isNull,
      );
    });

    test('there is none for a cycle hiding a missed period', () {
      expect(
        pastFertilityEstimate(
          LoggedCycle(start: lastStart, length: 120, periodLength: 5),
        ),
        isNull,
      );
    });
  });
}
