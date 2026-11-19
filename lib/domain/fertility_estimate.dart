import 'calendar_day.dart';
import 'cycle_history.dart';
import 'period_prediction.dart';

/// A calendar estimate of when ovulation may fall, and of the days around
/// it during which conception is most likely.
///
/// Always two ranges of days, never a single date. It is drawn from logged
/// period dates only, with no measurement of the body: it must never be
/// presented as a method of contraception, as a diagnosis, or as telling
/// which days are "safe" (CLAUDE.md, rule 7).
///
/// The figures below are starting assumptions, to be confirmed by a health
/// professional before any release outside private testing
/// (docs/DECISIONS.md).
final class FertilityEstimate {
  const FertilityEstimate({
    required this.earliestOvulation,
    required this.latestOvulation,
    required this.windowStart,
    required this.windowEnd,
    required this.confidence,
  });

  /// First day of the range in which ovulation is estimated (inclusive).
  final CalendarDay earliestOvulation;

  /// Last day of that range (inclusive).
  final CalendarDay latestOvulation;

  /// First day of the estimated fertile window (inclusive).
  final CalendarDay windowStart;

  /// Last day of the estimated fertile window (inclusive).
  final CalendarDay windowEnd;

  /// How much the logged history supports the estimate. For a cycle that
  /// has ended, the next period is known: only the assumptions remain.
  final PredictionConfidence confidence;

  /// True when [day] falls inside the estimated fertile window.
  bool windowContains(CalendarDay day) =>
      !day.isBefore(windowStart) && !day.isAfter(windowEnd);

  @override
  bool operator ==(Object other) =>
      other is FertilityEstimate &&
      other.earliestOvulation == earliestOvulation &&
      other.latestOvulation == latestOvulation &&
      other.windowStart == windowStart &&
      other.windowEnd == windowEnd &&
      other.confidence == confidence;

  @override
  int get hashCode => Object.hash(
    earliestOvulation,
    latestOvulation,
    windowStart,
    windowEnd,
    confidence,
  );

  @override
  String toString() =>
      'FertilityEstimate(ovulation $earliestOvulation..$latestOvulation, '
      'window $windowStart..$windowEnd, ${confidence.name})';
}

/// Assumed number of days from ovulation to the next period.
const int assumedDaysFromOvulationToPeriod = 14;

/// The assumption above is given this many days of margin on each side.
const int ovulationMarginDays = 2;

/// The window opens this many days before the earliest ovulation day.
const int fertileDaysBeforeOvulation = 5;

/// The window closes this many days after the latest ovulation day.
const int fertileDaysAfterOvulation = 1;

/// Below this many logged cycles behind the prediction, no estimate is
/// given: there is too little to count from.
const int minCyclesForFertilityEstimate = 2;

/// The estimate for the current cycle, drawn from the [prediction] of the
/// next period, or null when fewer than [minCyclesForFertilityEstimate]
/// cycles support that prediction.
///
/// The range of the prediction carries over: when the next period is
/// uncertain, so is the estimate. The window never opens before
/// [lastPeriodStart].
FertilityEstimate? fertilityEstimateFrom(
  PeriodPrediction prediction, {
  required CalendarDay lastPeriodStart,
}) {
  if (prediction.cyclesUsed < minCyclesForFertilityEstimate) {
    return null;
  }
  return _estimate(
    earliestNextPeriod: prediction.earliestStart,
    latestNextPeriod: prediction.latestStart,
    cycleStart: lastPeriodStart,
    confidence: prediction.confidence,
  );
}

/// The estimate for a cycle that has ended, looking back from the day the
/// next period really started. Null for the current cycle and for a cycle
/// whose length is not plausible.
FertilityEstimate? pastFertilityEstimate(LoggedCycle cycle) {
  final length = cycle.length;
  if (length == null || !cycle.isPlausible) {
    return null;
  }
  final nextStart = cycle.start.addDays(length);
  return _estimate(
    earliestNextPeriod: nextStart,
    latestNextPeriod: nextStart,
    cycleStart: cycle.start,
    confidence: PredictionConfidence.high,
  );
}

FertilityEstimate _estimate({
  required CalendarDay earliestNextPeriod,
  required CalendarDay latestNextPeriod,
  required CalendarDay cycleStart,
  required PredictionConfidence confidence,
}) {
  CalendarDay notBeforeCycle(CalendarDay day) =>
      day.isBefore(cycleStart) ? cycleStart : day;

  final earliest = notBeforeCycle(
    earliestNextPeriod.addDays(
      -assumedDaysFromOvulationToPeriod - ovulationMarginDays,
    ),
  );
  final latest = notBeforeCycle(
    latestNextPeriod.addDays(
      -assumedDaysFromOvulationToPeriod + ovulationMarginDays,
    ),
  );
  return FertilityEstimate(
    earliestOvulation: earliest,
    latestOvulation: latest,
    windowStart: notBeforeCycle(earliest.addDays(-fertileDaysBeforeOvulation)),
    windowEnd: latest.addDays(fertileDaysAfterOvulation),
    confidence: confidence,
  );
}
