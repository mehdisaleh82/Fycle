import 'dart:math' as math;

import 'calendar_day.dart';
import 'cycle_history.dart';
import 'cycle_overview.dart';
import 'cycle_status.dart';
import 'flow_intensity.dart';
import 'period_predictor.dart';
import 'period_starts.dart';

/// A question the home screen asks to fill in what was left out of the
/// log, in one tap. Never a reproach, and nothing is filled in without her
/// answer.
sealed class CatchUp {
  const CatchUp();
}

/// The estimated range has come, or is past, and no period is logged:
/// "Has your period started?".
final class AskPeriodStarted extends CatchUp {
  const AskPeriodStarted({required this.earliestStart});

  /// The first day a new period can be said to have started on: an earlier
  /// day would belong to the period before.
  final CalendarDay earliestStart;
}

/// Flow was logged a few days ago and nothing since, within the length her
/// periods usually have: "Is your period still going on?".
final class AskPeriodContinues extends CatchUp {
  const AskPeriodContinues({required this.lastFlowDay});

  /// The last day flow was logged on.
  final CalendarDay lastFlowDay;
}

/// A gap of more than this many days after the last flow day is not asked
/// about: too long ago to be answered from memory in one tap.
const int maxDaysAskedAfterFlow = 3;

/// How long a period of hers may last, to bound what is asked and what is
/// filled in: her longest recent period, else the length she gave, else the
/// reference used everywhere in the app.
int periodLengthToFill({
  required List<LoggedCycle> cycles,
  int? declaredPeriodLength,
  int maxPeriods = PeriodPredictor.maxCyclesConsidered,
}) {
  final past = [
    for (final cycle in cycles.take(math.max(0, cycles.length - 1)))
      if (cycle.isPlausible) cycle.periodLength,
  ];
  final recent = past.length > maxPeriods
      ? past.sublist(past.length - maxPeriods)
      : past;
  if (recent.isNotEmpty) {
    return recent.reduce(math.max);
  }
  return declaredPeriodLength ?? referencePeriodLength;
}

/// What to ask on [today], if anything.
///
/// [notYetOn] is the day she last answered "not yet" on, and [endedAfter]
/// the last flow day of the period she said was over: the same question is
/// not asked twice.
CatchUp? catchUpOn(
  CalendarDay today, {
  required Map<CalendarDay, FlowIntensity> flowByDay,
  required CycleStatus status,
  required List<LoggedCycle> cycles,
  int? declaredPeriodLength,
  CalendarDay? notYetOn,
  CalendarDay? endedAfter,
}) {
  if (status is NoEstimate ||
      status is EstimateOutdated ||
      flowByDay[today] != null) {
    // Nothing is estimated (a pregnancy, among others), or today is
    // answered, spotting included.
    return null;
  }
  CalendarDay? lastFlowDay;
  for (final entry in flowByDay.entries) {
    if (entry.value != FlowIntensity.spotting &&
        entry.key.isBefore(today) &&
        (lastFlowDay == null || entry.key.isAfter(lastFlowDay))) {
      lastFlowDay = entry.key;
    }
  }

  if (status is PeriodDue || status is PeriodLate) {
    if (notYetOn == today) {
      return null;
    }
    return AskPeriodStarted(
      earliestStart: lastFlowDay == null
          ? today.addDays(-maxDaysLateReported)
          : lastFlowDay.addDays(minFlowFreeDaysBetweenPeriods + 1),
    );
  }

  if (lastFlowDay == null || cycles.isEmpty || endedAfter == lastFlowDay) {
    return null;
  }
  final gap = today.daysSince(lastFlowDay);
  final dayOfPeriod = today.daysSince(cycles.last.start) + 1;
  if (gap > maxDaysAskedAfterFlow ||
      dayOfPeriod >
          periodLengthToFill(
            cycles: cycles,
            declaredPeriodLength: declaredPeriodLength,
          )) {
    return null;
  }
  return AskPeriodContinues(lastFlowDay: lastFlowDay);
}

/// The days to fill in when she says her period started on [start]: from
/// that day to [today], without going past [periodLength] days.
List<CalendarDay> daysSinceStart(
  CalendarDay start,
  CalendarDay today, {
  required int periodLength,
}) => [
  for (var i = 0; i < periodLength && !start.addDays(i).isAfter(today); i++)
    start.addDays(i),
];

/// The days to fill in when she says her period still goes on: every day
/// after [lastFlowDay], up to [today].
List<CalendarDay> daysSinceLastFlow(
  CalendarDay lastFlowDay,
  CalendarDay today,
) => [
  for (
    var day = lastFlowDay.addDays(1);
    !day.isAfter(today);
    day = day.addDays(1)
  )
    day,
];
