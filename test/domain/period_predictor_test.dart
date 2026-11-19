import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/period_prediction.dart';
import 'package:fycle/domain/period_predictor.dart';

/// Fictional history: a first period start, then one start after each of
/// the given cycle lengths (oldest first).
List<CalendarDay> startsFromCycles(List<int> cycleLengths) {
  var day = CalendarDay(2026, 1, 5);
  final starts = [day];
  for (final length in cycleLengths) {
    day = day.addDays(length);
    starts.add(day);
  }
  return starts;
}

/// Days on each side of the estimated start.
int marginOf(PeriodPrediction prediction) =>
    (prediction.rangeLengthInDays - 1) ~/ 2;

void main() {
  const predictor = PeriodPredictor();

  PeriodPrediction predictFromCycles(List<int> cycles, {int? usual}) =>
      predictor.predict(
        periodStarts: startsFromCycles(cycles),
        usualCycleLength: usual,
      )!;

  group('no history', () {
    test('no period start gives no prediction', () {
      expect(predictor.predict(periodStarts: []), isNull);
      expect(predictor.predict(periodStarts: [], usualCycleLength: 30), isNull);
    });

    test('one start and no declared length falls back to 28 days, widely', () {
      final start = CalendarDay(2026, 3, 1);
      final prediction = predictor.predict(periodStarts: [start])!;
      expect(prediction.estimatedCycleLength, 28);
      expect(prediction.earliestStart, start.addDays(21));
      expect(prediction.latestStart, start.addDays(35));
      expect(prediction.confidence, PredictionConfidence.low);
      expect(prediction.cyclesUsed, 0);
    });

    test('one start with a declared length uses that length', () {
      final start = CalendarDay(2026, 3, 1);
      final prediction = predictor.predict(
        periodStarts: [start],
        usualCycleLength: 32,
      )!;
      expect(prediction.estimatedCycleLength, 32);
      expect(prediction.earliestStart, start.addDays(27));
      expect(prediction.latestStart, start.addDays(37));
      expect(prediction.confidence, PredictionConfidence.low);
      expect(prediction.cyclesUsed, 0);
    });
  });

  group('a single cycle', () {
    test('uses its length with a wide range and low confidence', () {
      final starts = startsFromCycles([30]);
      final prediction = predictor.predict(periodStarts: starts)!;
      expect(prediction.estimatedCycleLength, 30);
      expect(prediction.earliestStart, starts.last.addDays(26));
      expect(prediction.latestStart, starts.last.addDays(34));
      expect(prediction.confidence, PredictionConfidence.low);
      expect(prediction.cyclesUsed, 1);
    });

    test('the declared length nudges the estimate', () {
      final prediction = predictFromCycles([32], usual: 26);
      // (6 x 32 + 1 x 26) / 7 = 31.1
      expect(prediction.estimatedCycleLength, 31);
      expect(prediction.confidence, PredictionConfidence.low);
    });

    test('a cycle far longer than the declared length is set aside', () {
      final prediction = predictFromCycles([58], usual: 28);
      expect(prediction.estimatedCycleLength, 28);
      expect(prediction.cyclesUsed, 0);
      expect(prediction.confidence, PredictionConfidence.low);
    });
  });

  group('regular cycles', () {
    test('six identical cycles give a narrow range and high confidence', () {
      final starts = startsFromCycles([28, 28, 28, 28, 28, 28]);
      final prediction = predictor.predict(periodStarts: starts)!;
      expect(prediction.estimatedCycleLength, 28);
      expect(prediction.earliestStart, starts.last.addDays(27));
      expect(prediction.latestStart, starts.last.addDays(29));
      expect(prediction.confidence, PredictionConfidence.high);
      expect(prediction.cyclesUsed, 6);
    });

    test('never a single date, even for perfectly regular cycles', () {
      final prediction = predictFromCycles(List.filled(12, 28));
      expect(prediction.rangeLengthInDays, greaterThanOrEqualTo(3));
      expect(prediction.earliestStart.isBefore(prediction.latestStart), isTrue);
    });

    test('nearly regular cycles stay at high confidence', () {
      final prediction = predictFromCycles([28, 29, 28, 27, 28, 29]);
      expect(prediction.estimatedCycleLength, 28);
      expect(marginOf(prediction), 2);
      expect(prediction.confidence, PredictionConfidence.high);
    });

    test('fewer cycles mean a wider range and lower confidence', () {
      final two = predictFromCycles([28, 28]);
      final three = predictFromCycles([28, 28, 28]);
      final four = predictFromCycles([28, 28, 28, 28]);
      expect(marginOf(two), 3);
      expect(two.confidence, PredictionConfidence.medium);
      expect(marginOf(three), 2);
      expect(three.confidence, PredictionConfidence.medium);
      expect(marginOf(four), 2);
      expect(four.confidence, PredictionConfidence.high);
    });

    test('only the six most recent cycles count', () {
      final prediction = predictFromCycles([
        40, 40, 40, 40, // Older pattern.
        28, 28, 28, 28, 28, 28,
      ]);
      expect(prediction.estimatedCycleLength, 28);
      expect(prediction.cyclesUsed, 6);
      expect(prediction.confidence, PredictionConfidence.high);
    });

    test('recent cycles weigh more than older ones', () {
      final shortening = predictFromCycles([32, 32, 32, 26, 26, 26]);
      final lengthening = predictFromCycles([26, 26, 26, 32, 32, 32]);
      expect(shortening.estimatedCycleLength, lessThan(29));
      expect(lengthening.estimatedCycleLength, greaterThan(29));
    });

    test('the declared length is ignored once three cycles are known', () {
      final without = predictFromCycles([30, 30, 30]);
      final withDeclared = predictFromCycles([30, 30, 30], usual: 24);
      expect(withDeclared.estimatedCycleLength, without.estimatedCycleLength);
      expect(withDeclared.earliestStart, without.earliestStart);
      expect(withDeclared.latestStart, without.latestStart);
    });

    test('order and duplicates in the input do not matter', () {
      final starts = startsFromCycles([28, 30, 27, 29]);
      final shuffled = [...starts.reversed, starts[1], starts[3]];
      final a = predictor.predict(periodStarts: starts)!;
      final b = predictor.predict(periodStarts: shuffled)!;
      expect(b.earliestStart, a.earliestStart);
      expect(b.latestStart, a.latestStart);
      expect(b.cyclesUsed, a.cyclesUsed);
    });
  });

  group('irregular cycles', () {
    test('the range widens and confidence drops', () {
      final starts = startsFromCycles([24, 35, 27, 33, 29, 38]);
      final prediction = predictor.predict(periodStarts: starts)!;
      // Weighted mean 32.4, weighted spread 4.5 days, x 1.5 = 6.7.
      expect(prediction.estimatedCycleLength, 32);
      expect(marginOf(prediction), 7);
      expect(prediction.earliestStart, starts.last.addDays(25));
      expect(prediction.latestStart, starts.last.addDays(39));
      expect(prediction.confidence, PredictionConfidence.low);
      expect(prediction.cyclesUsed, 6);
    });

    test('moderately irregular cycles give medium confidence', () {
      final prediction = predictFromCycles([26, 30, 27, 31, 28, 30]);
      expect(marginOf(prediction), inInclusiveRange(3, 4));
      expect(prediction.confidence, PredictionConfidence.medium);
    });

    test('the range never exceeds ten days on each side', () {
      final prediction = predictFromCycles([20, 45, 22, 44, 21, 46]);
      expect(marginOf(prediction), 10);
      expect(prediction.confidence, PredictionConfidence.low);
    });
  });

  group('missed cycle (gap in the log)', () {
    test('a cycle about twice as long as the others is set aside', () {
      final starts = startsFromCycles([28, 28, 56, 28, 28]);
      final prediction = predictor.predict(periodStarts: starts)!;
      expect(prediction.estimatedCycleLength, 28);
      expect(prediction.cyclesUsed, 4);
      expect(prediction.earliestStart, starts.last.addDays(26));
      expect(prediction.latestStart, starts.last.addDays(30));
      expect(prediction.confidence, PredictionConfidence.high);
    });

    test('a gap in the most recent cycle still counts from the last start', () {
      final starts = startsFromCycles([29, 29, 29, 58]);
      final prediction = predictor.predict(periodStarts: starts)!;
      expect(prediction.estimatedCycleLength, 29);
      expect(prediction.cyclesUsed, 3);
      expect(prediction.earliestStart, starts.last.addDays(27));
    });

    test('with two cycles, nothing tells a gap from a long cycle', () {
      final prediction = predictFromCycles([28, 56]);
      // Both are kept: (6 x 56 + 5 x 28) / 11 = 43.3, widest range.
      expect(prediction.cyclesUsed, 2);
      expect(prediction.estimatedCycleLength, 43);
      expect(marginOf(prediction), 10);
      expect(prediction.confidence, PredictionConfidence.low);
    });

    test('long cycles that keep coming back are a pattern, not gaps', () {
      final prediction = predictFromCycles([22, 44, 21, 45, 22, 46]);
      expect(prediction.cyclesUsed, 6);
      expect(marginOf(prediction), 10);
      expect(prediction.confidence, PredictionConfidence.low);
    });

    test('a gap of several months is ignored', () {
      final prediction = predictFromCycles([30, 30, 200, 30, 30]);
      expect(prediction.estimatedCycleLength, 30);
      expect(prediction.cyclesUsed, 4);
    });
  });

  group('very long or very short cycles', () {
    test(
      'a long cycle below the gap threshold is kept and widens the range',
      () {
        final prediction = predictFromCycles([28, 28, 45, 28, 28]);
        expect(prediction.cyclesUsed, 5);
        // (28 x 16 + 45 x 4) / 20 = 31.4
        expect(prediction.estimatedCycleLength, 31);
        expect(marginOf(prediction), 10);
        expect(prediction.confidence, PredictionConfidence.low);
      },
    );

    test('consistently long cycles are all kept', () {
      final prediction = predictFromCycles([50, 52, 49, 51, 50, 51]);
      expect(prediction.cyclesUsed, 6);
      expect(prediction.estimatedCycleLength, inInclusiveRange(50, 51));
      expect(prediction.confidence, PredictionConfidence.high);
    });

    test('consistently short cycles are all kept', () {
      final prediction = predictFromCycles([21, 22, 21, 20, 21, 21]);
      expect(prediction.cyclesUsed, 6);
      expect(prediction.estimatedCycleLength, 21);
      expect(prediction.confidence, PredictionConfidence.high);
    });

    test('a cycle under fifteen days is treated as an entry mistake', () {
      final prediction = predictFromCycles([28, 28, 8, 28]);
      expect(prediction.cyclesUsed, 3);
      expect(prediction.estimatedCycleLength, 28);
    });

    test('a short cycle of fifteen days or more is kept', () {
      final prediction = predictFromCycles([28, 28, 18, 28]);
      expect(prediction.cyclesUsed, 4);
      expect(prediction.estimatedCycleLength, lessThan(28));
      expect(marginOf(prediction), greaterThan(2));
    });

    test('the range always lies after the last period start', () {
      final starts = startsFromCycles([15, 40, 15, 40, 15, 40]);
      final prediction = predictor.predict(periodStarts: starts)!;
      expect(prediction.earliestStart.isAfter(starts.last), isTrue);
    });
  });

  group('reference length for her age', () {
    final start = CalendarDay(2026, 3, 1);

    test('centres the first estimate, with the range of an average', () {
      final prediction = predictor.predict(
        periodStarts: [start],
        referenceCycleLength: 30,
      )!;
      expect(prediction.estimatedCycleLength, 30);
      // An average says nothing of her: the range stays the widest.
      expect(marginOf(prediction), PeriodPredictor.populationMarginDays);
      expect(prediction.cyclesUsed, 0);
    });

    test('gives way to the length she declared', () {
      final prediction = predictor.predict(
        periodStarts: [start],
        usualCycleLength: 26,
        referenceCycleLength: 30,
      )!;
      expect(prediction.estimatedCycleLength, 26);
      expect(marginOf(prediction), PeriodPredictor.declaredMarginDays);
    });

    test('weighs lightly beside her first cycles, then not at all', () {
      PeriodPrediction withReference(List<int> cycles) => predictor.predict(
        periodStarts: startsFromCycles(cycles),
        referenceCycleLength: 30,
      )!;
      // One cycle of 24 days: pulled a little towards the reference.
      expect(withReference([24]).estimatedCycleLength, 25);
      expect(
        withReference([24, 24, 24]).estimatedCycleLength,
        predictFromCycles([24, 24, 24]).estimatedCycleLength,
      );
    });
  });

  group('declared usual length', () {
    test('rejects lengths outside the plausible range', () {
      final starts = [CalendarDay(2026, 3, 1)];
      expect(
        () => predictor.predict(periodStarts: starts, usualCycleLength: 5),
        throwsArgumentError,
      );
      expect(
        () => predictor.predict(periodStarts: starts, usualCycleLength: 120),
        throwsArgumentError,
      );
    });
  });
}
