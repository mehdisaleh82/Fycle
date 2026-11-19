import 'calendar_day.dart';
import 'cycle_history.dart';
import 'day_entry.dart';
import 'flow_intensity.dart';
import 'pain_level.dart';
import 'sleep_quality.dart';

/// What was logged over the first days of a cycle.
final class CycleSnapshot {
  const CycleSnapshot({
    required this.periodDays,
    required this.painDays,
    required this.poorSleepNights,
    required this.daysLogged,
  });

  /// Days with flow, spotting left out.
  final int periodDays;

  /// Days with a pain other than "none".
  final int painDays;

  /// Nights logged as poor sleep.
  final int poorSleepNights;

  /// Days with anything logged.
  final int daysLogged;

  @override
  bool operator ==(Object other) =>
      other is CycleSnapshot &&
      other.periodDays == periodDays &&
      other.painDays == painDays &&
      other.poorSleepNights == poorSleepNights &&
      other.daysLogged == daysLogged;

  @override
  int get hashCode =>
      Object.hash(periodDays, painDays, poorSleepNights, daysLogged);

  @override
  String toString() =>
      'CycleSnapshot(period $periodDays, pain $painDays, '
      'sleep $poorSleepNights, logged $daysLogged)';
}

/// The current cycle next to the one before, both taken at the same point:
/// the first [dayOfCycle] days of each. A plain side-by-side of what was
/// logged; nothing is judged better or worse.
final class CycleComparison {
  const CycleComparison({
    required this.dayOfCycle,
    required this.current,
    required this.previous,
  });

  /// How many days of each cycle are compared: the day of the current cycle
  /// today, or the whole of the previous cycle when it was shorter.
  final int dayOfCycle;

  final CycleSnapshot current;
  final CycleSnapshot previous;
}

/// Compares the current cycle of [cycles] (as returned by [cycleHistory])
/// with the one before, up to [today].
///
/// Returns null when there is no cycle before the current one, when that
/// cycle has an implausible length (most likely a period that was not
/// logged), or when [today] comes before the current cycle.
CycleComparison? compareWithPreviousCycle({
  required List<LoggedCycle> cycles,
  required Iterable<DayEntry> days,
  required CalendarDay today,
}) {
  if (cycles.length < 2) {
    return null;
  }
  final current = cycles.last;
  final previous = cycles[cycles.length - 2];
  if (!previous.isPlausible || today.isBefore(current.start)) {
    return null;
  }
  final reached = today.daysSince(current.start) + 1;
  final span = reached > previous.length! ? previous.length! : reached;

  CycleSnapshot snapshot(CalendarDay start) {
    final end = start.addDays(span - 1);
    var period = 0;
    var pain = 0;
    var poorSleep = 0;
    var logged = 0;
    for (final entry in days) {
      if (entry.day.isBefore(start) || entry.day.isAfter(end)) {
        continue;
      }
      logged++;
      final flow = entry.flow;
      if (flow != null && flow != FlowIntensity.spotting) {
        period++;
      }
      final level = entry.pain;
      if (level != null && level != PainLevel.none) {
        pain++;
      }
      if (entry.sleep == SleepQuality.poor) {
        poorSleep++;
      }
    }
    return CycleSnapshot(
      periodDays: period,
      painDays: pain,
      poorSleepNights: poorSleep,
      daysLogged: logged,
    );
  }

  return CycleComparison(
    dayOfCycle: span,
    current: snapshot(current.start),
    previous: snapshot(previous.start),
  );
}
