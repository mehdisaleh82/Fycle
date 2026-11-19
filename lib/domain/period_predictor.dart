import 'dart:math' as math;

import 'calendar_day.dart';
import 'period_prediction.dart';

/// Estimates when the next period may start, from past period start days.
///
/// Method: weighted average of the most recent cycle lengths, with a range
/// that widens when cycles vary or when few are known. The parameters and
/// their reasons are recorded in docs/DECISIONS.md.
final class PeriodPredictor {
  const PeriodPredictor();

  /// Only the most recent cycles are considered.
  static const int maxCyclesConsidered = 6;

  /// A shorter cycle is treated as an entry mistake and ignored.
  static const int minCycleLength = 15;

  /// A longer cycle is treated as a gap in the log and ignored.
  static const int maxCycleLength = 90;

  /// A cycle longer than this many times the reference length most likely
  /// hides a period that was not logged, and is ignored.
  static const double missedEntryFactor = 1.7;

  /// Cycle length assumed when nothing else is known.
  static const int defaultCycleLength = 28;

  /// The range reaches this many standard deviations on each side.
  static const double spreadFactor = 1.5;

  /// Margin on each side while nothing is known of her own cycles and the
  /// estimate rests on a published average. In Fehring et al., 2006, 95 % of
  /// cycles fell within 22 to 36 days: seven days on each side of the mean.
  static const int populationMarginDays = 7;

  /// Margin on each side while the estimate rests on the usual length she
  /// gave herself: she knows her cycle better than an average does.
  static const int declaredMarginDays = 5;

  /// The range never reaches further than this on each side.
  static const int maxMarginDays = 10;

  /// Below this many logged cycles, the declared usual length (if any)
  /// counts as one extra, lightly weighted cycle.
  static const int cyclesBeforeIgnoringDeclaredLength = 3;

  /// Predicts the next period start from [periodStarts] (any order,
  /// duplicates allowed) and, if the user gave one, [usualCycleLength].
  ///
  /// [referenceCycleLength] is the published average for her age, when her
  /// age is known. It stands in while she declared no length, and fades as
  /// her own cycles come in; it never narrows the range, since it says
  /// nothing of her.
  ///
  /// Returns null when [periodStarts] is empty: there is nothing to count
  /// from. Throws an [ArgumentError] if [usualCycleLength] is outside
  /// [minCycleLength]..[maxCycleLength].
  PeriodPrediction? predict({
    required Iterable<CalendarDay> periodStarts,
    int? usualCycleLength,
    int? referenceCycleLength,
  }) {
    if (usualCycleLength != null &&
        (usualCycleLength < minCycleLength ||
            usualCycleLength > maxCycleLength)) {
      throw ArgumentError.value(
        usualCycleLength,
        'usualCycleLength',
        'Must be between $minCycleLength and $maxCycleLength days',
      );
    }

    final starts = periodStarts.toSet().toList()..sort();
    if (starts.isEmpty) {
      return null;
    }
    final lastStart = starts.last;

    final reference = referenceCycleLength?.clamp(
      minCycleLength,
      maxCycleLength,
    );
    // What stands in for her own cycles while there are few of them.
    final startingLength = usualCycleLength ?? reference;
    final cycles = _retainedCycles(starts, startingLength);

    if (cycles.isEmpty) {
      return _prediction(
        lastStart: lastStart,
        cycleLength: startingLength ?? defaultCycleLength,
        margin: usualCycleLength != null
            ? declaredMarginDays
            : populationMarginDays,
        confidence: PredictionConfidence.low,
        cyclesUsed: 0,
      );
    }

    // Most recent cycle first: weights 6, 5, 4...
    final lengths = <int>[];
    final weights = <int>[];
    for (var age = 0; age < cycles.length; age++) {
      lengths.add(cycles[cycles.length - 1 - age]);
      weights.add(maxCyclesConsidered - age);
    }
    if (startingLength != null &&
        cycles.length < cyclesBeforeIgnoringDeclaredLength) {
      lengths.add(startingLength);
      weights.add(1);
    }

    final totalWeight = weights.reduce((a, b) => a + b);
    var weightedSum = 0.0;
    for (var i = 0; i < lengths.length; i++) {
      weightedSum += weights[i] * lengths[i];
    }
    final mean = weightedSum / totalWeight;

    var weightedSquares = 0.0;
    for (var i = 0; i < lengths.length; i++) {
      final deviation = lengths[i] - mean;
      weightedSquares += weights[i] * deviation * deviation;
    }
    final spread = math.sqrt(weightedSquares / totalWeight);

    // The small epsilon keeps floating-point noise from adding a day.
    final spreadMargin = (spreadFactor * spread - 1e-9).ceil();
    final margin = math.min(
      maxMarginDays,
      math.max(_minMargin(cycles.length), spreadMargin),
    );

    return _prediction(
      lastStart: lastStart,
      cycleLength: mean.round(),
      margin: margin,
      confidence: _confidence(cycles.length, margin),
      cyclesUsed: cycles.length,
    );
  }

  /// Lengths of the recent cycles worth trusting, oldest first.
  List<int> _retainedCycles(List<CalendarDay> starts, int? usualCycleLength) {
    final plausible = <int>[];
    for (var i = 1; i < starts.length; i++) {
      final length = starts[i].daysSince(starts[i - 1]);
      if (length >= minCycleLength && length <= maxCycleLength) {
        plausible.add(length);
      }
    }
    final recent = plausible.length > maxCyclesConsidered
        ? plausible.sublist(plausible.length - maxCyclesConsidered)
        : plausible;

    final retained = <int>[];
    for (var i = 0; i < recent.length; i++) {
      final reference = _referenceLength(recent, i, usualCycleLength);
      if (reference == null || recent[i] <= missedEntryFactor * reference) {
        retained.add(recent[i]);
      }
    }
    // A missed entry is an exception. When half the cycles or more look
    // too long, that is how the cycles are: keep them all and let the range
    // widen. A lone cycle has only the declared length to be judged by.
    final setAside = recent.length - retained.length;
    if (recent.length > 1 && setAside * 2 >= recent.length) {
      return recent;
    }
    return retained;
  }

  /// The length the cycle at [index] is compared with, or null when there is
  /// nothing to compare it with.
  double? _referenceLength(List<int> cycles, int index, int? usualCycleLength) {
    final others = [
      for (var i = 0; i < cycles.length; i++)
        if (i != index) cycles[i],
    ]..sort();
    if (others.isEmpty) {
      // A lone cycle can only be checked against the declared length.
      return usualCycleLength?.toDouble();
    }
    final middle = others.length ~/ 2;
    return others.length.isOdd
        ? others[middle].toDouble()
        : (others[middle - 1] + others[middle]) / 2;
  }

  /// Narrowest margin allowed for a given number of cycles: few cycles, wide
  /// range.
  int _minMargin(int cycleCount) {
    if (cycleCount >= 6) return 1;
    if (cycleCount >= 3) return 2;
    if (cycleCount == 2) return 3;
    return 4;
  }

  PredictionConfidence _confidence(int cycleCount, int margin) {
    if (cycleCount >= 4 && margin <= 2) return PredictionConfidence.high;
    if (cycleCount >= 2 && margin <= 4) return PredictionConfidence.medium;
    return PredictionConfidence.low;
  }

  PeriodPrediction _prediction({
    required CalendarDay lastStart,
    required int cycleLength,
    required int margin,
    required PredictionConfidence confidence,
    required int cyclesUsed,
  }) => PeriodPrediction(
    earliestStart: lastStart.addDays(cycleLength - margin),
    latestStart: lastStart.addDays(cycleLength + margin),
    confidence: confidence,
    estimatedCycleLength: cycleLength,
    cyclesUsed: cyclesUsed,
  );
}
