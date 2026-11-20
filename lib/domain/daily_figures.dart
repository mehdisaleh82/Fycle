import 'calendar_day.dart';
import 'cycle_history.dart';
import 'day_entry.dart';
import 'libido_level.dart';
import 'mood.dart';
import 'pain_level.dart';
import 'period_prediction.dart';
import 'period_predictor.dart';
import 'sleep_quality.dart';
import 'start_profile.dart';

/// Plain counts of what was logged lately: the last seven days, the month,
/// the cycle going on, and how far the estimate can be trusted. They show
/// what the journal already holds and what is still empty; nothing is
/// scored, and nothing is called good or bad.

/// One of the last seven days.
final class WeekDay {
  const WeekDay({
    required this.day,
    required this.logged,
    required this.filled,
  });

  final CalendarDay day;

  /// Whether anything at all was logged that day.
  final bool logged;

  /// What was filled in that day, among what can be followed.
  final Set<Tracked> filled;
}

/// The last seven days, oldest first, today last. [entryFor] gives what was
/// logged on a day, or null.
List<WeekDay> lastSevenDays(
  CalendarDay today,
  DayEntry? Function(CalendarDay day) entryFor,
) => [
  for (var back = 6; back >= 0; back--)
    _weekDay(today.addDays(-back), entryFor(today.addDays(-back))),
];

WeekDay _weekDay(CalendarDay day, DayEntry? entry) => WeekDay(
  day: day,
  logged: entry != null && !entry.isEmpty,
  filled: {
    if (entry?.pain != null) Tracked.pain,
    if (entry?.mood != null) Tracked.mood,
    if (entry?.sleep != null) Tracked.sleep,
    if (entry?.libido != null) Tracked.libido,
    if (entry != null && entry.symptoms.isNotEmpty) Tracked.symptoms,
  },
);

/// How many days of the month of [today] were logged, out of those gone by,
/// today included.
({int logged, int elapsed}) monthLogged(
  CalendarDay today,
  Set<CalendarDay> loggedDays,
) {
  var logged = 0;
  for (var dayOfMonth = 1; dayOfMonth <= today.day; dayOfMonth++) {
    if (loggedDays.contains(CalendarDay(today.year, today.month, dayOfMonth))) {
      logged++;
    }
  }
  return (logged: logged, elapsed: today.day);
}

/// What was logged over the first days of a cycle.
final class CycleFigures {
  const CycleFigures({
    required this.days,
    required this.daysLogged,
    required this.goodNights,
    required this.painDays,
    required this.commonMood,
    required this.commonLibido,
  });

  /// How many days of the cycle are counted.
  final int days;

  /// Days with anything logged.
  final int daysLogged;

  /// Nights logged as good sleep.
  final int goodNights;

  /// Days with a pain other than "none".
  final int painDays;

  /// The mood and the libido logged most often; on a tie, the most recent
  /// of them. Null when none was logged.
  final Mood? commonMood;
  final LibidoLevel? commonLibido;
}

/// The cycle going on, up to [today], and the cycle before taken over the
/// same number of days. Null while no period was logged, or when the last
/// logged cycle is over.
({CycleFigures current, CycleFigures? previous})? cycleFiguresOn(
  CalendarDay today, {
  required List<LoggedCycle> cycles,
  required List<DayEntry> days,
}) {
  if (cycles.isEmpty || cycles.last.isComplete) {
    return null;
  }
  final current = cycles.last;
  final into = today.daysSince(current.start) + 1;
  if (into < 1) {
    return null;
  }
  final byDay = {for (final entry in days) entry.day: entry};
  CycleFigures over(CalendarDay start, int count) {
    var logged = 0;
    var goodNights = 0;
    var painDays = 0;
    final moods = <Mood, int>{};
    final libidos = <LibidoLevel, int>{};
    Mood? mood;
    LibidoLevel? libido;
    for (var i = 0; i < count; i++) {
      final entry = byDay[start.addDays(i)];
      if (entry == null || entry.isEmpty) {
        continue;
      }
      logged++;
      if (entry.sleep == SleepQuality.good) {
        goodNights++;
      }
      if (entry.pain != null && entry.pain != PainLevel.none) {
        painDays++;
      }
      final dayMood = entry.mood;
      if (dayMood != null) {
        moods[dayMood] = (moods[dayMood] ?? 0) + 1;
        // Days are read oldest first: on a tie, the latest wins.
        if (mood == null || moods[dayMood]! >= moods[mood]!) {
          mood = dayMood;
        }
      }
      final dayLibido = entry.libido;
      if (dayLibido != null) {
        libidos[dayLibido] = (libidos[dayLibido] ?? 0) + 1;
        if (libido == null || libidos[dayLibido]! >= libidos[libido]!) {
          libido = dayLibido;
        }
      }
    }
    return CycleFigures(
      days: count,
      daysLogged: logged,
      goodNights: goodNights,
      painDays: painDays,
      commonMood: mood,
      commonLibido: libido,
    );
  }

  CycleFigures? previous;
  if (cycles.length >= 2) {
    final before = cycles[cycles.length - 2];
    if (before.isPlausible) {
      final count = into < before.length! ? into : before.length!;
      previous = over(before.start, count);
    }
  }
  return (current: over(current.start, into), previous: previous);
}

/// Where the reliability of the estimate stands, and what would raise it.
final class ReliabilityStep {
  const ReliabilityStep({
    required this.confidence,
    required this.cyclesMissing,
    required this.heldByVariation,
  });

  final PredictionConfidence confidence;

  /// Complete cycles still to log before the next level can be reached.
  /// Zero at the highest level, and when cycles are not what is missing.
  final int cyclesMissing;

  /// True when enough cycles are logged for the next level, and the range
  /// stays wide because her cycles differ from one another: nothing she
  /// logs differently would change it.
  final bool heldByVariation;
}

/// Reads [prediction] against the rules of [PeriodPredictor].
ReliabilityStep reliabilityStepOf(PeriodPrediction prediction) {
  final needed = switch (prediction.confidence) {
    PredictionConfidence.low => PeriodPredictor.cyclesForMediumConfidence,
    PredictionConfidence.medium => PeriodPredictor.cyclesForHighConfidence,
    PredictionConfidence.high => 0,
  };
  final missing = needed - prediction.cyclesUsed;
  return ReliabilityStep(
    confidence: prediction.confidence,
    cyclesMissing: missing > 0 ? missing : 0,
    heldByVariation:
        prediction.confidence != PredictionConfidence.high && missing <= 0,
  );
}
