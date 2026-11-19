import 'calendar_day.dart';
import 'flow_intensity.dart';
import 'period_predictor.dart';
import 'period_starts.dart';

/// One cycle found in the log: from the first day of a period to the day
/// before the next period starts.
final class LoggedCycle {
  const LoggedCycle({
    required this.start,
    required this.length,
    required this.periodLength,
  });

  /// First day of the period that opens the cycle.
  final CalendarDay start;

  /// Days from [start] to the day before the next period. Null for the
  /// current cycle, whose end is not known yet.
  final int? length;

  /// Days from [start] to the last flow day of the period, both included.
  /// Spotting is not counted. A short pause inside the period is.
  final int periodLength;

  /// False for the current cycle.
  bool get isComplete => length != null;

  /// False when the length is so short or so long that it more likely comes
  /// from an entry mistake or from a period that was not logged. Such a
  /// cycle is listed but left out of averages and trends.
  bool get isPlausible {
    final days = length;
    return days != null &&
        days >= PeriodPredictor.minCycleLength &&
        days <= PeriodPredictor.maxCycleLength;
  }

  /// Last day of the cycle, or null for the current cycle.
  CalendarDay? get end {
    final days = length;
    return days == null ? null : start.addDays(days - 1);
  }

  /// Last flow day of the period that opens the cycle.
  CalendarDay get periodEnd => start.addDays(periodLength - 1);

  @override
  bool operator ==(Object other) =>
      other is LoggedCycle &&
      other.start == start &&
      other.length == length &&
      other.periodLength == periodLength;

  @override
  int get hashCode => Object.hash(start, length, periodLength);

  @override
  String toString() =>
      'LoggedCycle($start, length: $length, period: $periodLength)';
}

/// Lists the cycles of a day-by-day flow log, oldest first. The last one is
/// the current cycle.
///
/// Uses the same rules as [periodStartsFrom]: days absent from [flowByDay]
/// are days without flow, and spotting neither starts a period nor belongs
/// to one.
List<LoggedCycle> cycleHistory(Map<CalendarDay, FlowIntensity> flowByDay) {
  final starts = periodStartsFrom(flowByDay);
  final flowDays = [
    for (final entry in flowByDay.entries)
      if (entry.value != FlowIntensity.spotting) entry.key,
  ]..sort();

  final cycles = <LoggedCycle>[];
  for (var i = 0; i < starts.length; i++) {
    final start = starts[i];
    final nextStart = i + 1 < starts.length ? starts[i + 1] : null;
    var lastFlowDay = start;
    for (final day in flowDays) {
      if (day.isBefore(start)) {
        continue;
      }
      if (nextStart != null && !day.isBefore(nextStart)) {
        break;
      }
      lastFlowDay = day;
    }
    cycles.add(
      LoggedCycle(
        start: start,
        length: nextStart?.daysSince(start),
        periodLength: lastFlowDay.daysSince(start) + 1,
      ),
    );
  }
  return cycles;
}

/// Average lengths over the most recent cycles.
final class CycleAverages {
  const CycleAverages({
    required this.cycleLength,
    required this.periodLength,
    required this.cyclesCounted,
  });

  /// Average length of the counted cycles, in days. Null when no complete,
  /// plausible cycle is known.
  final double? cycleLength;

  /// Average length of the periods, in days. Null when the log is empty.
  final double? periodLength;

  /// Number of complete, plausible cycles behind [cycleLength].
  final int cyclesCounted;
}

/// Averages over the last [maxCycles] complete, plausible cycles of
/// [cycles] (as returned by [cycleHistory]).
///
/// The average period length also counts the period of the current cycle
/// once it is at least a week old: before that it may still be going on.
CycleAverages cycleAverages(
  List<LoggedCycle> cycles, {
  required CalendarDay today,
  int maxCycles = PeriodPredictor.maxCyclesConsidered,
}) {
  final counted = [
    for (final cycle in cycles)
      if (cycle.isPlausible) cycle,
  ];
  final recent = counted.length > maxCycles
      ? counted.sublist(counted.length - maxCycles)
      : counted;

  final periods = [for (final cycle in recent) cycle.periodLength];
  if (cycles.isNotEmpty) {
    final current = cycles.last;
    if (!current.isComplete &&
        today.daysSince(current.periodEnd) > minFlowFreeDaysBetweenPeriods) {
      periods.add(current.periodLength);
    }
  }

  return CycleAverages(
    cycleLength: recent.isEmpty
        ? null
        : recent.fold<int>(0, (sum, cycle) => sum + cycle.length!) /
              recent.length,
    periodLength: periods.isEmpty
        ? null
        : periods.fold<int>(0, (sum, days) => sum + days) / periods.length,
    cyclesCounted: recent.length,
  );
}

/// Where a day falls inside a cycle, in plain descriptive terms.
///
/// These are observations about the calendar, not medical phases: nothing
/// here estimates ovulation.
enum CycleMoment {
  /// From the first to the last flow day of the period.
  period,

  /// The last days of the cycle, just before the next period.
  beforeNextPeriod,

  /// Every other day of the cycle.
  rest,
}

/// How many days before the next period count as [CycleMoment.beforeNextPeriod].
const int daysCountedBeforeNextPeriod = 7;

/// The moment of [day] inside [cycle], or null when [day] is outside the
/// cycle or when the cycle is not complete: without the next period, the
/// days before it cannot be told apart.
///
/// When a cycle is very short, the period takes precedence over the days
/// before the next one.
CycleMoment? cycleMomentOf(CalendarDay day, LoggedCycle cycle) {
  final end = cycle.end;
  if (end == null || day.isBefore(cycle.start) || day.isAfter(end)) {
    return null;
  }
  if (!day.isAfter(cycle.periodEnd)) {
    return CycleMoment.period;
  }
  if (end.daysSince(day) < daysCountedBeforeNextPeriod) {
    return CycleMoment.beforeNextPeriod;
  }
  return CycleMoment.rest;
}
