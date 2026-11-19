import 'calendar_day.dart';
import 'cycle_history.dart';
import 'cycle_trends.dart';
import 'day_entry.dart';
import 'period_prediction.dart';
import 'period_predictor.dart';

/// Where a length shown to the user comes from.
enum LengthSource {
  /// Counted on logged cycles or periods.
  logged,

  /// The usual length given by the user.
  declared,

  /// Nothing is known yet: the common length is assumed.
  assumed,

  /// The period of the current cycle, which may still be going on.
  current,
}

/// The few figures shown first: where today falls in the cycle and what is
/// known of its lengths. Available from the very first logged date.
final class CycleOverview {
  const CycleOverview({
    required this.dayOfCycle,
    required this.cycleLength,
    required this.cycleLengthSource,
    required this.periodLength,
    required this.periodLengthSource,
    required this.daysUntilEarliest,
    required this.daysUntilLatest,
    required this.daysLogged,
    required this.completeCycles,
  });

  /// 1 on the first day of the last logged period. Null when no period was
  /// logged.
  final int? dayOfCycle;

  /// Days from one period start to the next.
  final int cycleLength;
  final LengthSource cycleLengthSource;

  /// Days a period lasts, or null when no period was logged.
  final int? periodLength;
  final LengthSource? periodLengthSource;

  /// Days from today to the first day of the predicted range. Zero or less
  /// once the range has started. Null without a prediction.
  final int? daysUntilEarliest;

  /// Days from today to the last day of the predicted range. Negative once
  /// the range is over. Null without a prediction.
  final int? daysUntilLatest;

  /// Number of days with anything logged.
  final int daysLogged;

  /// Number of complete, plausible cycles in the log.
  final int completeCycles;
}

/// Builds the overview for [today] from what the log gives.
CycleOverview cycleOverviewOn(
  CalendarDay today, {
  required List<LoggedCycle> cycles,
  required PeriodPrediction? prediction,
  required int? usualCycleLength,
  required int daysLogged,
}) {
  final averages = cycleAverages(cycles, today: today);
  final current = cycles.isEmpty ? null : cycles.last;

  final int cycleLength;
  final LengthSource cycleSource;
  if (prediction != null && prediction.cyclesUsed > 0) {
    cycleLength = prediction.estimatedCycleLength;
    cycleSource = LengthSource.logged;
  } else if (usualCycleLength != null) {
    cycleLength = usualCycleLength;
    cycleSource = LengthSource.declared;
  } else {
    cycleLength = PeriodPredictor.defaultCycleLength;
    cycleSource = LengthSource.assumed;
  }

  final int? periodLength;
  final LengthSource? periodSource;
  final averagePeriod = averages.periodLength;
  if (averagePeriod != null) {
    periodLength = averagePeriod.round();
    periodSource = LengthSource.logged;
  } else if (current != null) {
    periodLength = current.periodLength;
    periodSource = LengthSource.current;
  } else {
    periodLength = null;
    periodSource = null;
  }

  final sinceStart = current == null ? null : today.daysSince(current.start);
  return CycleOverview(
    dayOfCycle: sinceStart == null || sinceStart < 0 ? null : sinceStart + 1,
    cycleLength: cycleLength,
    cycleLengthSource: cycleSource,
    periodLength: periodLength,
    periodLengthSource: periodSource,
    daysUntilEarliest: prediction?.earliestStart.daysSince(today),
    daysUntilLatest: prediction?.latestStart.daysSince(today),
    daysLogged: daysLogged,
    completeCycles: [
      for (final cycle in cycles)
        if (cycle.isPlausible) cycle,
    ].length,
  );
}

/// A sign that was logged around the same day of the cycle in several past
/// cycles.
final class UsualSign {
  const UsualSign({
    required this.sign,
    required this.cycles,
    required this.cyclesConsidered,
  });

  final Enum sign;

  /// Cycles in which it was logged around that day.
  final int cycles;

  /// Cycles looked at.
  final int cyclesConsidered;

  @override
  String toString() => 'UsualSign(${sign.name}, $cycles of $cyclesConsidered)';
}

/// A day counts as "around" a day of the cycle within this many days.
const int daysAroundCycleDay = 1;

/// What was logged around [dayOfCycle] (1 is the first day of a period) in
/// at least two of the last [maxCycles] complete, plausible cycles. The
/// signs seen in the most cycles come first.
///
/// A count of past entries, shown as such: it predicts nothing.
List<UsualSign> usualSignsAround(
  int dayOfCycle, {
  required List<LoggedCycle> cycles,
  required Iterable<DayEntry> days,
  int maxCycles = PeriodPredictor.maxCyclesConsidered,
}) {
  final usable = [
    for (final cycle in cycles)
      if (cycle.isPlausible) cycle,
  ];
  final recent = usable.length > maxCycles
      ? usable.sublist(usable.length - maxCycles)
      : usable;
  if (recent.length < minCyclesForTrends) {
    return const [];
  }

  final seen = <Enum, Set<CalendarDay>>{};
  for (final entry in days) {
    for (final cycle in recent) {
      final position = entry.day.daysSince(cycle.start) + 1;
      if (position < 1 || position > cycle.length!) {
        continue;
      }
      if ((position - dayOfCycle).abs() <= daysAroundCycleDay) {
        for (final sign in signsOf(entry)) {
          seen.putIfAbsent(sign, () => {}).add(cycle.start);
        }
      }
    }
  }

  final result = [
    for (final MapEntry(key: sign, value: starts) in seen.entries)
      if (starts.length >= minCyclesForOneTrend)
        UsualSign(
          sign: sign,
          cycles: starts.length,
          cyclesConsidered: recent.length,
        ),
  ];
  String order(Enum sign) =>
      '${sign.runtimeType}/${sign.index.toString().padLeft(3, '0')}';
  result.sort((a, b) {
    final byCount = b.cycles.compareTo(a.cycles);
    return byCount != 0 ? byCount : order(a.sign).compareTo(order(b.sign));
  });
  return result;
}

/// What the entries make possible, in the order it comes.
enum Insight {
  /// An estimate of the next period: from the first logged period.
  estimate,

  /// Average lengths: once a cycle has ended.
  averages,

  /// What comes back at the same moment, and the ovulation estimate: once
  /// two cycles have ended.
  trends,

  /// A narrower, more reliable estimate: with several regular cycles.
  reliableEstimate,
}

/// One line of "the more you log, the more you see".
final class InsightStep {
  const InsightStep({
    required this.insight,
    required this.have,
    required this.need,
  });

  final Insight insight;

  /// How many logged period starts or complete cycles there are, capped at
  /// [need].
  final int have;

  /// How many it takes.
  final int need;

  bool get reached => have >= need;

  @override
  String toString() => 'InsightStep(${insight.name}, $have/$need)';
}

/// Complete cycles it takes before the estimate can be called reliable.
/// Regular cycles are needed too: see [insightSteps].
const int cyclesForReliableEstimate = 4;

/// The steps, in order, with how far the log has come for each.
///
/// The last step is reached only when the prediction itself is highly
/// reliable: enough cycles, and regular ones.
List<InsightStep> insightSteps({
  required List<LoggedCycle> cycles,
  required PeriodPrediction? prediction,
}) {
  final complete = [
    for (final cycle in cycles)
      if (cycle.isPlausible) cycle,
  ].length;
  int capped(int value, int need) => value > need ? need : value;
  final reliable = prediction?.confidence == PredictionConfidence.high;
  return [
    InsightStep(
      insight: Insight.estimate,
      have: capped(cycles.length, 1),
      need: 1,
    ),
    InsightStep(insight: Insight.averages, have: capped(complete, 1), need: 1),
    InsightStep(
      insight: Insight.trends,
      have: capped(complete, minCyclesForTrends),
      need: minCyclesForTrends,
    ),
    InsightStep(
      insight: Insight.reliableEstimate,
      have: reliable
          ? cyclesForReliableEstimate
          : capped(complete, cyclesForReliableEstimate - 1),
      need: cyclesForReliableEstimate,
    ),
  ];
}
