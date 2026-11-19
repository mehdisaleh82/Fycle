import 'calendar_day.dart';
import 'flow_intensity.dart';
import 'period_prediction.dart';
import 'period_starts.dart';

/// Where a given day stands relative to the log and to the prediction.
///
/// The predictor does not know what day it is; this is where "today" comes
/// in. Nothing here is a medical statement: a late period is only a day past
/// an estimated range.
sealed class CycleStatus {
  const CycleStatus();
}

/// Nothing to count from: no period was ever logged.
final class NoEstimate extends CycleStatus {
  const NoEstimate();
}

/// Flow is logged for the day itself.
final class PeriodOngoing extends CycleStatus {
  const PeriodOngoing({required this.dayOfPeriod, required this.next});

  /// 1 on the first day of the period.
  final int dayOfPeriod;

  /// The estimate for the period after this one.
  final PeriodPrediction next;
}

/// The predicted range has not started yet.
final class PeriodExpected extends CycleStatus {
  const PeriodExpected({required this.prediction, required this.daysUntil});

  final PeriodPrediction prediction;

  /// Days until the first day of the range, at least 1.
  final int daysUntil;
}

/// The day falls inside the predicted range.
final class PeriodDue extends CycleStatus {
  const PeriodDue({required this.prediction});

  final PeriodPrediction prediction;
}

/// The predicted range is over and no new period was logged.
final class PeriodLate extends CycleStatus {
  const PeriodLate({required this.prediction, required this.daysLate});

  final PeriodPrediction prediction;

  /// Days since the last day of the range, at least 1.
  final int daysLate;
}

/// The predicted range is so far behind that the log has most likely been
/// left aside for a while: counting days would mean nothing.
final class EstimateOutdated extends CycleStatus {
  const EstimateOutdated();
}

/// Past this many days after the range, the status is [EstimateOutdated]
/// rather than [PeriodLate]. Same limit as the longest cycle the predictor
/// accepts.
const int maxDaysLateReported = 90;

/// The status of [today], from the day-by-day flow log and the prediction
/// drawn from it.
CycleStatus cycleStatusOn(
  CalendarDay today, {
  required Map<CalendarDay, FlowIntensity> flowByDay,
  required PeriodPrediction? prediction,
}) {
  if (prediction == null) {
    return const NoEstimate();
  }

  final flowToday = flowByDay[today];
  if (flowToday != null && flowToday != FlowIntensity.spotting) {
    CalendarDay? start;
    for (final candidate in periodStartsFrom(flowByDay)) {
      if (!candidate.isAfter(today)) {
        start = candidate;
      }
    }
    if (start != null) {
      return PeriodOngoing(
        dayOfPeriod: today.daysSince(start) + 1,
        next: prediction,
      );
    }
  }

  if (today.isBefore(prediction.earliestStart)) {
    return PeriodExpected(
      prediction: prediction,
      daysUntil: prediction.earliestStart.daysSince(today),
    );
  }
  if (!today.isAfter(prediction.latestStart)) {
    return PeriodDue(prediction: prediction);
  }
  final daysLate = today.daysSince(prediction.latestStart);
  if (daysLate > maxDaysLateReported) {
    return const EstimateOutdated();
  }
  return PeriodLate(prediction: prediction, daysLate: daysLate);
}
