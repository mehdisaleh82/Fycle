import 'calendar_day.dart';
import 'cycle_history.dart';
import 'day_entry.dart';
import 'period_prediction.dart';
import 'period_predictor.dart';
import 'symptom.dart';

/// The signs she is asked about when the app is set up: "before your
/// period, do you often have…", in the order they are shown.
const List<Symptom> signsAskedBeforePeriod = [
  Symptom.cravings,
  Symptom.bloating,
  Symptom.breastTenderness,
  Symptom.fatigue,
  Symptom.moodSwings,
  Symptom.headache,
  Symptom.acne,
  Symptom.cramps,
  Symptom.backPain,
  Symptom.insomnia,
];

/// What is commonly reported in the days before a period, shown while
/// nothing is known of her. A general benchmark, said as such, never a
/// statement about her (CLAUDE.md, rule 7). Sources in docs/DECISIONS.md,
/// decision 160.
const List<Symptom> commonSignsBeforePeriod = [
  Symptom.bloating,
  Symptom.cravings,
  Symptom.breastTenderness,
  Symptom.fatigue,
  Symptom.moodSwings,
  Symptom.headache,
];

/// Where a line about a sign comes from. It is always shown with the line.
enum SignSource {
  /// Counted in what she logged.
  logged,

  /// What she said when the app was set up.
  declared,

  /// What is commonly reported, by anyone.
  common,
}

/// A sign that comes in the days before a period.
final class SignBeforePeriod {
  const SignBeforePeriod({
    required this.sign,
    required this.source,
    this.cycles = 0,
    this.cyclesConsidered = 0,
    this.farthestDaysBefore,
    this.nearestDaysBefore,
  });

  final Symptom sign;
  final SignSource source;

  /// For a logged sign: in how many of the [cyclesConsidered] cycles it was
  /// logged in the days before the next period.
  final int cycles;
  final int cyclesConsidered;

  /// For a logged sign: how many days before the period it was first
  /// logged, from the cycle where it came the earliest
  /// ([farthestDaysBefore]) to the one where it came the latest
  /// ([nearestDaysBefore]). 1 is the day before the period.
  final int? farthestDaysBefore;
  final int? nearestDaysBefore;

  @override
  String toString() =>
      'SignBeforePeriod(${sign.name}, ${source.name}, $cycles of '
      '$cyclesConsidered, $nearestDaysBefore..$farthestDaysBefore)';
}

/// The signs of the days before a period, hers first.
///
/// Counted backwards from the period that followed, not from the first day
/// of the cycle: in a cycle that varies, a sign does not come on the same
/// day of the cycle, but it does come about as long before the period.
///
/// A logged sign is listed when it came back in the last
/// [daysCountedBeforeNextPeriod] days of at least [minCyclesForASign]
/// cycles, and of half the cycles looked at (the last [maxCycles] complete,
/// plausible ones). Then come the signs she named in the setup that the log
/// does not show yet. With neither, the common ones.
///
/// A count of what was logged or said: it explains nothing and promises
/// nothing.
List<SignBeforePeriod> signsBeforePeriod({
  required List<LoggedCycle> cycles,
  required Iterable<DayEntry> days,
  Set<Symptom> declared = const {},
  int maxCycles = PeriodPredictor.maxCyclesConsidered,
}) {
  final usable = [
    for (final cycle in cycles)
      if (cycle.isPlausible) cycle,
  ];
  final recent = usable.length > maxCycles
      ? usable.sublist(usable.length - maxCycles)
      : usable;

  // sign -> start of the cycle -> days before the next period it was first
  // logged
  final first = <Symptom, Map<CalendarDay, int>>{};
  if (recent.length >= minCyclesForASign) {
    for (final entry in days) {
      if (entry.symptoms.isEmpty) {
        continue;
      }
      for (final cycle in recent) {
        final end = cycle.end!;
        if (entry.day.isAfter(end) || !entry.day.isAfter(cycle.periodEnd)) {
          continue;
        }
        final daysBefore = end.daysSince(entry.day) + 1;
        if (daysBefore > daysCountedBeforeNextPeriod) {
          continue;
        }
        for (final sign in entry.symptoms) {
          final byCycle = first.putIfAbsent(sign, () => {});
          final known = byCycle[cycle.start];
          if (known == null || daysBefore > known) {
            byCycle[cycle.start] = daysBefore;
          }
        }
      }
    }
  }

  final logged = <SignBeforePeriod>[];
  for (final MapEntry(key: sign, value: byCycle) in first.entries) {
    final count = byCycle.length;
    if (count < minCyclesForASign || count * 2 < recent.length) {
      continue;
    }
    final firsts = byCycle.values.toList()..sort();
    logged.add(
      SignBeforePeriod(
        sign: sign,
        source: SignSource.logged,
        cycles: count,
        cyclesConsidered: recent.length,
        farthestDaysBefore: firsts.last,
        nearestDaysBefore: firsts.first,
      ),
    );
  }
  logged.sort((a, b) {
    final byCount = b.cycles.compareTo(a.cycles);
    return byCount != 0 ? byCount : a.sign.index.compareTo(b.sign.index);
  });

  final seen = {for (final sign in logged) sign.sign};
  final result = [
    ...logged,
    for (final sign in signsAskedBeforePeriod)
      if (declared.contains(sign) && !seen.contains(sign))
        SignBeforePeriod(sign: sign, source: SignSource.declared),
  ];
  if (result.isNotEmpty) {
    return result;
  }
  return [
    for (final sign in commonSignsBeforePeriod)
      SignBeforePeriod(sign: sign, source: SignSource.common),
  ];
}

/// A sign is counted as hers from this many cycles.
const int minCyclesForASign = 2;

/// How many days before the estimated range the first of [signs] may come:
/// the earliest she logged one, or the whole span looked at when none was
/// logged yet.
int daysSignsComeBefore(List<SignBeforePeriod> signs) {
  var days = 0;
  for (final sign in signs) {
    final farthest = sign.farthestDaysBefore;
    if (farthest != null && farthest > days) {
      days = farthest;
    }
  }
  return days == 0 ? daysCountedBeforeNextPeriod : days;
}

/// The first day on which [signs] may come before the period estimated by
/// [prediction]. An estimate drawn from an estimate: to be shown with
/// "about".
CalendarDay signsMayComeFrom(
  PeriodPrediction prediction,
  List<SignBeforePeriod> signs,
) => prediction.earliestStart.addDays(-daysSignsComeBefore(signs));
