import 'calendar_day.dart';
import 'cycle_history.dart';
import 'day_entry.dart';
import 'symptom.dart';

/// What her dates show from one cycle to the next, read with the bleeding
/// criteria used to describe the years before the menopause.
///
/// Source: Harlow et al., "Executive summary of the Stages of Reproductive
/// Aging Workshop + 10", Journal of Clinical Endocrinology & Metabolism,
/// 2012. Two criteria rest on dates alone:
/// - a persistent difference of 7 days or more in the length of consecutive
///   cycles, persistent meaning that it comes back within 10 cycles;
/// - an interval of 60 days or more without a period.
///
/// This counts what was logged against those thresholds. It names no stage
/// and is no diagnosis (CLAUDE.md, rule 7): many things other than age move
/// a cycle, and only a health professional can tell them apart.

/// A difference of this many days or more between two consecutive cycles is
/// counted.
const int markedDifferenceDays = 7;

/// The most recent complete cycles looked at.
const int changeWindowCycles = 10;

/// From this many counted differences in the window, the difference is one
/// that comes back.
const int differencesToComeBack = 2;

/// An interval of this many days or more between two periods is counted.
const int longIntervalDays = 60;

/// The signs asked about are counted over this many days.
const int signWindowDays = 90;

/// The signs asked about when the app is set up and counted in the review,
/// for those who follow a changing cycle, in the order they are shown.
const List<Symptom> changeSigns = [
  Symptom.hotFlashes,
  Symptom.nightSweats,
  Symptom.insomnia,
  Symptom.fatigue,
  Symptom.moodSwings,
  Symptom.migraine,
  Symptom.vaginalDryness,
  Symptom.jointPain,
  Symptom.brainFog,
  Symptom.palpitations,
];

/// Among them, the ones the journal offers only to those who follow a
/// changing cycle. The others are offered to everyone.
const Set<Symptom> followerOnlySigns = {
  Symptom.hotFlashes,
  Symptom.nightSweats,
  Symptom.vaginalDryness,
  Symptom.jointPain,
  Symptom.brainFog,
  Symptom.palpitations,
};

final class CycleChange {
  const CycleChange({
    required this.cyclesCompared,
    required this.markedDifferences,
    required this.longestInterval,
    required this.daysSinceLastPeriod,
    required this.signDays,
  });

  /// Complete cycles compared with the one before. Zero while fewer than
  /// two complete cycles are known.
  final int cyclesCompared;

  /// How many of them differ from the one before by
  /// [markedDifferenceDays] or more.
  final int markedDifferences;

  /// Whether such a difference came back within the window.
  bool get differenceComesBack => markedDifferences >= differencesToComeBack;

  /// Length of the longest complete cycle of the window, when it reaches
  /// [longIntervalDays]. Null otherwise.
  final int? longestInterval;

  /// Days since the first day of the last period, when the cycle going on
  /// reaches [longIntervalDays]. Null otherwise.
  final int? daysSinceLastPeriod;

  /// Days on which each of the [changeSigns] was logged in the last
  /// [signWindowDays] days. Signs never logged are absent.
  final Map<Symptom, int> signDays;

  /// True when there is nothing to tell yet: too few cycles to compare, no
  /// long interval and no sign logged.
  bool get isEmpty =>
      cyclesCompared == 0 &&
      longestInterval == null &&
      daysSinceLastPeriod == null &&
      signDays.isEmpty;
}

/// Reads [cycles] (as returned by [cycleHistory], oldest first, the current
/// cycle last) and [days] on [today].
CycleChange cycleChangeOn(
  CalendarDay today, {
  required List<LoggedCycle> cycles,
  required List<DayEntry> days,
}) {
  final complete = [
    for (final cycle in cycles)
      if (cycle.isComplete) cycle,
  ];
  final window = complete.length > changeWindowCycles + 1
      ? complete.sublist(complete.length - changeWindowCycles - 1)
      : complete;

  var compared = 0;
  var marked = 0;
  int? longest;
  for (var i = 0; i < window.length; i++) {
    final cycle = window[i];
    if (!cycle.isPlausible) {
      // More likely a period that was not logged than a cycle.
      continue;
    }
    final length = cycle.length!;
    // The cycle before the window only serves as a point of comparison.
    final counted = window.length <= changeWindowCycles || i > 0;
    if (counted &&
        length >= longIntervalDays &&
        (longest == null || length > longest)) {
      longest = length;
    }
    if (i == 0 || !window[i - 1].isPlausible) {
      continue;
    }
    compared++;
    if ((length - window[i - 1].length!).abs() >= markedDifferenceDays) {
      marked++;
    }
  }

  int? sinceLast;
  if (cycles.isNotEmpty && !cycles.last.isComplete) {
    final running = today.daysSince(cycles.last.start);
    if (running >= longIntervalDays) {
      sinceLast = running;
    }
  }

  final signDays = <Symptom, int>{};
  for (final entry in days) {
    final ago = today.daysSince(entry.day);
    if (ago < 0 || ago >= signWindowDays) {
      continue;
    }
    for (final sign in changeSigns) {
      if (entry.symptoms.contains(sign)) {
        signDays[sign] = (signDays[sign] ?? 0) + 1;
      }
    }
  }

  return CycleChange(
    cyclesCompared: compared,
    markedDifferences: marked,
    longestInterval: longest,
    daysSinceLastPeriod: sinceLast,
    signDays: Map.unmodifiable(signDays),
  );
}
