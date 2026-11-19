import 'calendar_day.dart';

/// How much the logged history supports a prediction.
enum PredictionConfidence { low, medium, high }

/// An estimate of when the next period may start.
///
/// Always a range of days, never a single date: it is an estimate drawn from
/// past entries, not a certainty.
final class PeriodPrediction {
  const PeriodPrediction({
    required this.earliestStart,
    required this.latestStart,
    required this.confidence,
    required this.estimatedCycleLength,
    required this.cyclesUsed,
  });

  /// First day of the range (inclusive).
  final CalendarDay earliestStart;

  /// Last day of the range (inclusive).
  final CalendarDay latestStart;

  final PredictionConfidence confidence;

  /// Estimated number of days from one period start to the next.
  final int estimatedCycleLength;

  /// Number of logged cycles the estimate is based on. Zero when it rests
  /// only on the declared usual length or on the default length.
  final int cyclesUsed;

  /// Number of days in the range, both ends included.
  int get rangeLengthInDays => latestStart.daysSince(earliestStart) + 1;

  @override
  String toString() =>
      'PeriodPrediction($earliestStart..$latestStart, ${confidence.name}, '
      'cycle $estimatedCycleLength d, $cyclesUsed cycles used)';
}
