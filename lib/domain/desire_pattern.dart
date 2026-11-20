import 'dart:math' as math;

import 'calendar_day.dart';
import 'cycle_history.dart';
import 'day_entry.dart';
import 'libido_level.dart';
import 'period_prediction.dart';
import 'period_predictor.dart';

/// The days of the cycle on which she most often logged a high desire, in
/// her past cycles. A count of what she logged, nothing more: it explains
/// nothing and promises nothing.
final class DesireWindow {
  const DesireWindow({
    required this.fromDay,
    required this.toDay,
    required this.cycles,
    required this.cyclesConsidered,
  });

  /// First and last day of the cycle of the window, 1 on the first day of
  /// the period.
  final int fromDay;
  final int toDay;

  /// Cycles in which a high desire was logged inside the window, out of
  /// the cycles in which desire was logged at all.
  final int cycles;
  final int cyclesConsidered;

  @override
  bool operator ==(Object other) =>
      other is DesireWindow &&
      other.fromDay == fromDay &&
      other.toDay == toDay &&
      other.cycles == cycles &&
      other.cyclesConsidered == cyclesConsidered;

  @override
  int get hashCode => Object.hash(fromDay, toDay, cycles, cyclesConsidered);

  @override
  String toString() =>
      'DesireWindow(days $fromDay..$toDay, $cycles of $cyclesConsidered)';
}

/// The window looked for is at most this many days long.
const int desireWindowDays = 5;

/// A window is hers once a high desire was logged inside it in this many
/// cycles, and in at least half the cycles considered.
const int minCyclesForDesire = 2;

/// Finds where in the cycle she most often logged a high desire, over the
/// last [maxCycles] complete, plausible cycles in which she logged desire
/// at least once. Returns null while there is too little to go by.
DesireWindow? usualDesireWindow({
  required List<LoggedCycle> cycles,
  required Iterable<DayEntry> days,
  int maxCycles = PeriodPredictor.maxCyclesConsidered,
}) {
  final logged = [
    for (final entry in days)
      if (entry.libido != null) entry,
  ];
  // The days of high desire of each cycle in which desire was logged.
  final highDays = <Set<int>>[];
  for (final cycle in cycles.reversed) {
    final end = cycle.end;
    if (end == null || !cycle.isPlausible) {
      continue;
    }
    final inCycle = [
      for (final entry in logged)
        if (!entry.day.isBefore(cycle.start) && !entry.day.isAfter(end)) entry,
    ];
    if (inCycle.isEmpty) {
      continue;
    }
    highDays.add({
      for (final entry in inCycle)
        if (entry.libido == LibidoLevel.high)
          entry.day.daysSince(cycle.start) + 1,
    });
    if (highDays.length == maxCycles) {
      break;
    }
  }
  final all = highDays.expand((cycle) => cycle);
  if (highDays.length < minCyclesForDesire || all.isEmpty) {
    return null;
  }

  var bestStart = 0;
  var bestCycles = 0;
  var bestDays = 0;
  for (var start = 1; start <= all.reduce(math.max); start++) {
    bool inside(int day) => day >= start && day < start + desireWindowDays;
    final cyclesIn = highDays.where((cycle) => cycle.any(inside)).length;
    final daysIn = all.where(inside).length;
    if (cyclesIn > bestCycles ||
        (cyclesIn == bestCycles && daysIn > bestDays)) {
      bestStart = start;
      bestCycles = cyclesIn;
      bestDays = daysIn;
    }
  }
  if (bestCycles < minCyclesForDesire || bestCycles * 2 < highDays.length) {
    return null;
  }
  // Tightened to the days she logged.
  final inWindow = all.where(
    (day) => day >= bestStart && day < bestStart + desireWindowDays,
  );
  return DesireWindow(
    fromDay: inWindow.reduce(math.min),
    toDay: inWindow.reduce(math.max),
    cycles: bestCycles,
    cyclesConsidered: highDays.length,
  );
}

/// The dates [window] falls on next: in the cycle going on, which started
/// on [cycleStart], while it is not behind; otherwise in the cycle after,
/// counted from the estimated range of its start, which makes the dates an
/// estimate drawn from an estimate. Null when there is nothing ahead.
({CalendarDay from, CalendarDay to})? desireDatesAhead(
  DesireWindow window, {
  required CalendarDay cycleStart,
  required CalendarDay today,
  PeriodPrediction? prediction,
}) {
  final to = cycleStart.addDays(window.toDay - 1);
  if (!to.isBefore(today)) {
    return (from: cycleStart.addDays(window.fromDay - 1), to: to);
  }
  if (prediction == null || prediction.latestStart.isBefore(today)) {
    return null;
  }
  return (
    from: prediction.earliestStart.addDays(window.fromDay - 1),
    to: prediction.latestStart.addDays(window.toDay - 1),
  );
}
