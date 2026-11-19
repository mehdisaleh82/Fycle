import 'calendar_day.dart';
import 'cycle_history.dart';
import 'cycle_status.dart';
import 'flow_intensity.dart';
import 'period_prediction.dart';

/// The little the home-screen widget needs to draw the cycle ring on any
/// day without opening the app: where the current cycle started, how long
/// it and its period usually are, and the range in which the next period is
/// expected. Nothing else leaves the encrypted database for the widget: no
/// symptom, no note, no history.
final class WidgetSnapshot {
  const WidgetSnapshot({
    required this.cycleStart,
    required this.cycleLength,
    required this.periodLength,
    required this.nextEarliest,
    required this.nextLatest,
  });

  /// First day of the current cycle.
  final CalendarDay cycleStart;

  /// Days from one period start to the next, as estimated.
  final int cycleLength;

  /// Days of the period that opened the cycle.
  final int periodLength;

  /// First and last day of the range in which the next period is expected.
  final CalendarDay nextEarliest;
  final CalendarDay nextLatest;

  @override
  bool operator ==(Object other) =>
      other is WidgetSnapshot &&
      other.cycleStart == cycleStart &&
      other.cycleLength == cycleLength &&
      other.periodLength == periodLength &&
      other.nextEarliest == nextEarliest &&
      other.nextLatest == nextLatest;

  @override
  int get hashCode => Object.hash(
    cycleStart,
    cycleLength,
    periodLength,
    nextEarliest,
    nextLatest,
  );

  @override
  String toString() =>
      'WidgetSnapshot($cycleStart, cycle $cycleLength, period $periodLength, '
      'next $nextEarliest..$nextLatest)';
}

/// What the widget should show on [today], or null when it should show
/// nothing: no period logged, or a log left aside for so long that counting
/// days would mean nothing.
WidgetSnapshot? widgetSnapshotOn(
  CalendarDay today, {
  required List<LoggedCycle> cycles,
  required Map<CalendarDay, FlowIntensity> flowByDay,
  required PeriodPrediction? prediction,
}) {
  if (prediction == null || cycles.isEmpty) {
    return null;
  }
  final status = cycleStatusOn(
    today,
    flowByDay: flowByDay,
    prediction: prediction,
  );
  if (status is NoEstimate || status is EstimateOutdated) {
    return null;
  }
  final current = cycles.last;
  return WidgetSnapshot(
    cycleStart: current.start,
    cycleLength: prediction.estimatedCycleLength,
    periodLength: current.periodLength,
    nextEarliest: prediction.earliestStart,
    nextLatest: prediction.latestStart,
  );
}
