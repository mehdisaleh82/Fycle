import 'dart:math' as math;

import 'cycle_history.dart';
import 'period_predictor.dart';

/// An estimate of how many more days the period going on may last, drawn
/// from how long her past periods lasted. Always a range, and only her own
/// figures: no published average is used here.
final class PeriodEndEstimate {
  const PeriodEndEstimate({
    required this.earliestDaysLeft,
    required this.latestDaysLeft,
    required this.periodsUsed,
  });

  /// Days left after today if this period is as short as her shortest
  /// recent one. Zero when today may be the last day.
  final int earliestDaysLeft;

  /// Days left after today if it is as long as her longest recent one.
  final int latestDaysLeft;

  /// Number of past periods the estimate is based on.
  final int periodsUsed;

  @override
  String toString() =>
      'PeriodEndEstimate($earliestDaysLeft..$latestDaysLeft more days, '
      '$periodsUsed periods used)';
}

/// Below this many past periods, nothing is estimated.
const int minPeriodsForEndEstimate = 2;

/// Estimates the end of the period going on, on its [dayOfPeriod]th day
/// (1 on the first day). [cycles] is the whole history, oldest first, the
/// current cycle last.
///
/// Returns null while fewer than [minPeriodsForEndEstimate] past periods are
/// known, and when this period already lasts longer than all of them: there
/// is then nothing to go by.
PeriodEndEstimate? periodEndEstimate({
  required int dayOfPeriod,
  required List<LoggedCycle> cycles,
  int maxPeriods = PeriodPredictor.maxCyclesConsidered,
}) {
  if (cycles.length < 2 || dayOfPeriod < 1) {
    return null;
  }
  final past = [
    for (final cycle in cycles.sublist(0, cycles.length - 1))
      if (cycle.isPlausible) cycle.periodLength,
  ];
  final recent = past.length > maxPeriods
      ? past.sublist(past.length - maxPeriods)
      : past;
  if (recent.length < minPeriodsForEndEstimate) {
    return null;
  }
  final shortest = recent.reduce(math.min);
  final longest = recent.reduce(math.max);
  if (dayOfPeriod > longest) {
    return null;
  }
  return PeriodEndEstimate(
    earliestDaysLeft: math.max(0, shortest - dayOfPeriod),
    latestDaysLeft: longest - dayOfPeriod,
    periodsUsed: recent.length,
  );
}
