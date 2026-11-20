import 'calendar_day.dart';
import 'cycle_status.dart';
import 'fertility_estimate.dart';
import 'life_stage.dart';
import 'period_prediction.dart';
import 'start_profile.dart';

/// Where a day stands in the cycle, in plain words.
///
/// Named after what is known from dates (her period, the days before the
/// next one), never after an ovulation the app cannot observe: the middle
/// of the cycle is the estimated range, nothing more (CLAUDE.md, rule 7).
enum CyclePhase {
  /// Flow is logged for the day.
  period,

  /// After her period, before the estimated middle of the cycle.
  afterPeriod,

  /// The estimated fertile window, up to the last day ovulation is
  /// estimated on.
  midCycle,

  /// After the middle, more than a few days before the next period.
  secondPart,

  /// The last days before the estimated period, and the days it is due.
  beforePeriod,
}

/// The days before the estimated period that count as "before the period".
/// Premenstrual signs are most often described in the few days before
/// bleeding; five is a way to name days, not a criterion of anything. To
/// be confirmed by a health professional with the texts of the card.
const int daysBeforePeriod = 5;

/// The phase of [today], or null when nothing can be said: no estimate, a
/// period that is late (the cycle is not following the estimate, whatever
/// the reason), a pregnancy, periods not back after a birth, or a hormonal
/// contraception, with which bleeding does not follow the hormones of a
/// natural cycle.
CyclePhase? cyclePhaseOn(
  CalendarDay today, {
  required CycleStatus status,
  required CalendarDay? cycleStart,
  required FertilityEstimate? fertility,
  required Profile? profile,
  required Contraception? contraception,
}) {
  if (!followsACycle(profile) || contraception == Contraception.hormonal) {
    return null;
  }
  switch (status) {
    case NoEstimate() || EstimateOutdated() || PeriodLate():
      return null;
    case PeriodOngoing():
      return CyclePhase.period;
    case PeriodDue():
      return CyclePhase.beforePeriod;
    case PeriodExpected(:final prediction, :final daysUntil):
      // The estimated middle first: with a wide range for the next
      // period, it can reach into the days counted back from that range,
      // and the card must not contradict the ring.
      if (fertility != null &&
          !today.isBefore(fertility.windowStart) &&
          !today.isAfter(fertility.latestOvulation)) {
        return CyclePhase.midCycle;
      }
      if (daysUntil <= daysBeforePeriod) {
        return CyclePhase.beforePeriod;
      }
      if (fertility != null) {
        return today.isBefore(fertility.windowStart)
            ? CyclePhase.afterPeriod
            : CyclePhase.secondPart;
      }
      // No ovulation estimate (turned off, or too few cycles): the middle
      // is not named, only the two halves.
      return _inFirstHalf(today, cycleStart, prediction)
          ? CyclePhase.afterPeriod
          : CyclePhase.secondPart;
  }
}

bool _inFirstHalf(
  CalendarDay today,
  CalendarDay? cycleStart,
  PeriodPrediction prediction,
) {
  if (cycleStart == null) {
    return false;
  }
  final elapsed = today.daysSince(cycleStart);
  final left = prediction.earliestStart.daysSince(today);
  return elapsed < left;
}

/// How many tips each phase has. One is shown a day.
const int tipsPerPhase = 3;

/// The tip of the day: changes every day, the same all day long.
int tipIndexOn(CalendarDay today) =>
    today.daysSince(CalendarDay(2020, 1, 1)) % tipsPerPhase;
