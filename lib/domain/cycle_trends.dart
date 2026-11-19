import 'calendar_day.dart';
import 'cycle_history.dart';
import 'day_entry.dart';
import 'pain_level.dart';
import 'period_predictor.dart';
import 'sleep_quality.dart';
import 'symptom.dart';

/// How often one logged sign came back at each moment of the cycle.
///
/// A sign is a value of one of the logged choices: a symptom, a pain level
/// other than "none", a mood, a sleep quality or a libido level.
///
/// This is a count of what was logged, nothing more: it explains nothing
/// and predicts nothing.
final class SignTrend {
  SignTrend({
    required this.sign,
    required Map<CycleMoment, int> cyclesByMoment,
    required this.cyclesConsidered,
  }) : cyclesByMoment = Map.unmodifiable(cyclesByMoment);

  final Enum sign;

  /// For each moment, in how many of the considered cycles the sign was
  /// logged at least once at that moment. Moments never seen are absent.
  final Map<CycleMoment, int> cyclesByMoment;

  /// Number of cycles looked at.
  final int cyclesConsidered;

  /// Cycles in which the sign was logged at [moment].
  int cyclesAt(CycleMoment moment) => cyclesByMoment[moment] ?? 0;

  /// The moment at which the sign came back in the most cycles. When two
  /// moments tie, the earlier value of [CycleMoment] wins.
  CycleMoment get mainMoment {
    var best = CycleMoment.values.first;
    for (final moment in CycleMoment.values) {
      if (cyclesAt(moment) > cyclesAt(best)) {
        best = moment;
      }
    }
    return best;
  }

  @override
  String toString() =>
      'SignTrend(${sign.name}, $cyclesByMoment of $cyclesConsidered)';
}

/// Below this many complete cycles, nothing is said: one cycle is not a
/// trend.
const int minCyclesForTrends = 2;

/// A sign is listed only when it came back at the same moment in at least
/// this many cycles.
const int minCyclesForOneTrend = 2;

/// The signs logged on a day.
Iterable<Enum> signsOf(DayEntry entry) sync* {
  final pain = entry.pain;
  if (pain != null && pain != PainLevel.none) {
    yield pain;
  }
  final mood = entry.mood;
  if (mood != null) {
    yield mood;
  }
  final sleep = entry.sleep;
  if (sleep != null) {
    yield sleep;
  }
  final libido = entry.libido;
  if (libido != null) {
    yield libido;
  }
  yield* entry.symptoms;
}

/// What came back, and when, over the last [maxCycles] complete and
/// plausible cycles of [cycles] (as returned by [cycleHistory]).
///
/// Returns nothing below [minCyclesForTrends] such cycles. The signs seen
/// in the most cycles come first.
List<SignTrend> cycleTrends({
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

  // sign -> moment -> starts of the cycles in which it was seen
  final seen = <Enum, Map<CycleMoment, Set<CalendarDay>>>{};
  for (final entry in days) {
    final cycle = _cycleOf(entry.day, recent);
    if (cycle == null) {
      continue;
    }
    final moment = cycleMomentOf(entry.day, cycle);
    if (moment == null) {
      continue;
    }
    for (final sign in signsOf(entry)) {
      seen
          .putIfAbsent(sign, () => {})
          .putIfAbsent(moment, () => {})
          .add(cycle.start);
    }
  }

  final trends = <SignTrend>[];
  for (final MapEntry(key: sign, value: byMoment) in seen.entries) {
    final counts = {
      for (final MapEntry(key: moment, value: starts) in byMoment.entries)
        moment: starts.length,
    };
    if (counts.values.any((count) => count >= minCyclesForOneTrend)) {
      trends.add(
        SignTrend(
          sign: sign,
          cyclesByMoment: counts,
          cyclesConsidered: recent.length,
        ),
      );
    }
  }
  int best(SignTrend trend) => trend.cyclesAt(trend.mainMoment);
  trends.sort((a, b) {
    final byCount = best(b).compareTo(best(a));
    return byCount != 0 ? byCount : _order(a.sign).compareTo(_order(b.sign));
  });
  return trends;
}

LoggedCycle? _cycleOf(CalendarDay day, List<LoggedCycle> cycles) {
  for (final cycle in cycles) {
    final end = cycle.end;
    if (end != null && !day.isBefore(cycle.start) && !day.isAfter(end)) {
      return cycle;
    }
  }
  return null;
}

/// A stable order between signs of different kinds: by kind, then by the
/// order of the values.
String _order(Enum sign) =>
    '${sign.runtimeType}/${sign.index.toString().padLeft(3, '0')}';

/// What to say when a cycle has just ended: its length next to the ones
/// before, and what was logged most.
final class CycleSummary {
  CycleSummary({
    required this.cycle,
    required this.previousAverageLength,
    required List<Symptom> mostLoggedSymptoms,
  }) : mostLoggedSymptoms = List.unmodifiable(mostLoggedSymptoms);

  /// The cycle that has just ended.
  final LoggedCycle cycle;

  /// Average length of the plausible cycles before it, or null if there is
  /// none to compare with.
  final double? previousAverageLength;

  /// Up to [maxSymptomsInSummary] symptoms, the ones logged on the most
  /// days of the cycle first.
  final List<Symptom> mostLoggedSymptoms;

  /// Days of difference with the cycles before, rounded: positive when the
  /// cycle was longer. Null when there is nothing to compare with.
  int? get differenceWithPrevious {
    final average = previousAverageLength;
    return average == null ? null : (cycle.length! - average).round();
  }
}

/// At most this many symptoms are named in a [CycleSummary].
const int maxSymptomsInSummary = 3;

/// The summary of the last complete cycle of [cycles], or null when no
/// cycle has ended yet or when its length is not plausible (most likely a
/// period that was not logged: nothing sensible can be said about it).
CycleSummary? lastCycleSummary({
  required List<LoggedCycle> cycles,
  required Iterable<DayEntry> days,
  int maxCycles = PeriodPredictor.maxCyclesConsidered,
}) {
  if (cycles.length < 2) {
    return null;
  }
  final ended = cycles[cycles.length - 2];
  if (!ended.isPlausible) {
    return null;
  }

  final before = [
    for (final cycle in cycles.sublist(0, cycles.length - 2))
      if (cycle.isPlausible) cycle,
  ];
  final compared = before.length > maxCycles
      ? before.sublist(before.length - maxCycles)
      : before;

  final end = ended.end!;
  final dayCounts = <Symptom, int>{};
  for (final entry in days) {
    if (entry.day.isBefore(ended.start) || entry.day.isAfter(end)) {
      continue;
    }
    for (final symptom in entry.symptoms) {
      dayCounts[symptom] = (dayCounts[symptom] ?? 0) + 1;
    }
  }
  final symptoms = dayCounts.keys.toList()
    ..sort((a, b) {
      final byCount = dayCounts[b]!.compareTo(dayCounts[a]!);
      return byCount != 0 ? byCount : a.index.compareTo(b.index);
    });

  return CycleSummary(
    cycle: ended,
    previousAverageLength: compared.isEmpty
        ? null
        : compared.fold<int>(0, (sum, cycle) => sum + cycle.length!) /
              compared.length,
    mostLoggedSymptoms: symptoms.take(maxSymptomsInSummary).toList(),
  );
}

/// What was logged since the current cycle started: a report that can be
/// read at any time, without waiting for the cycle to end.
final class CycleReport {
  CycleReport({
    required this.cycle,
    required this.dayOfCycle,
    required this.daysLogged,
    required this.painDays,
    required this.poorSleepNights,
    required List<Symptom> mostLoggedSymptoms,
  }) : mostLoggedSymptoms = List.unmodifiable(mostLoggedSymptoms);

  /// The current cycle.
  final LoggedCycle cycle;

  /// 1 on the first day of the period.
  final int dayOfCycle;

  /// Days of this cycle with anything logged.
  final int daysLogged;

  /// Days of this cycle with a pain other than "none".
  final int painDays;

  /// Nights of this cycle logged as poor sleep.
  final int poorSleepNights;

  /// Up to [maxSymptomsInSummary] symptoms, the ones logged on the most
  /// days first.
  final List<Symptom> mostLoggedSymptoms;
}

/// The report of the current cycle on [today], or null when no period was
/// logged or when [today] comes before it.
CycleReport? currentCycleReport({
  required List<LoggedCycle> cycles,
  required Iterable<DayEntry> days,
  required CalendarDay today,
}) {
  if (cycles.isEmpty) {
    return null;
  }
  final cycle = cycles.last;
  if (today.isBefore(cycle.start)) {
    return null;
  }
  var logged = 0;
  var pain = 0;
  var poorSleep = 0;
  final dayCounts = <Symptom, int>{};
  for (final entry in days) {
    if (entry.day.isBefore(cycle.start) || entry.day.isAfter(today)) {
      continue;
    }
    logged++;
    final level = entry.pain;
    if (level != null && level != PainLevel.none) {
      pain++;
    }
    if (entry.sleep == SleepQuality.poor) {
      poorSleep++;
    }
    for (final symptom in entry.symptoms) {
      dayCounts[symptom] = (dayCounts[symptom] ?? 0) + 1;
    }
  }
  final symptoms = dayCounts.keys.toList()
    ..sort((a, b) {
      final byCount = dayCounts[b]!.compareTo(dayCounts[a]!);
      return byCount != 0 ? byCount : a.index.compareTo(b.index);
    });
  return CycleReport(
    cycle: cycle,
    dayOfCycle: today.daysSince(cycle.start) + 1,
    daysLogged: logged,
    painDays: pain,
    poorSleepNights: poorSleep,
    mostLoggedSymptoms: symptoms.take(maxSymptomsInSummary).toList(),
  );
}
