import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/cycle_phase.dart';
import 'package:fycle/domain/cycle_status.dart';
import 'package:fycle/domain/fertility_estimate.dart';
import 'package:fycle/domain/life_stage.dart';
import 'package:fycle/domain/period_prediction.dart';
import 'package:fycle/domain/start_profile.dart';

void main() {
  // A cycle started on 1 March, the next period estimated from the 27th to
  // the 31st, ovulation from the 12th to the 16th.
  final start = CalendarDay(2026, 3, 1);
  final prediction = PeriodPrediction(
    earliestStart: CalendarDay(2026, 3, 27),
    latestStart: CalendarDay(2026, 3, 31),
    confidence: PredictionConfidence.medium,
    estimatedCycleLength: 28,
    cyclesUsed: 3,
  );
  final fertility = FertilityEstimate(
    earliestOvulation: CalendarDay(2026, 3, 12),
    latestOvulation: CalendarDay(2026, 3, 16),
    windowStart: CalendarDay(2026, 3, 8),
    windowEnd: CalendarDay(2026, 3, 17),
    confidence: PredictionConfidence.medium,
  );

  CycleStatus expectedOn(CalendarDay day) => PeriodExpected(
    prediction: prediction,
    daysUntil: prediction.earliestStart.daysSince(day),
  );

  CyclePhase? phase(
    CalendarDay day, {
    CycleStatus? status,
    FertilityEstimate? estimate,
    bool withEstimate = true,
    Profile? profile,
    Contraception? contraception,
  }) => cyclePhaseOn(
    day,
    status: status ?? expectedOn(day),
    cycleStart: start,
    fertility: withEstimate ? estimate ?? fertility : null,
    profile: profile,
    contraception: contraception,
  );

  test('her period is her period', () {
    expect(
      phase(
        CalendarDay(2026, 3, 2),
        status: PeriodOngoing(dayOfPeriod: 2, next: prediction),
      ),
      CyclePhase.period,
    );
  });

  test('the days of the cycle, around the estimated middle', () {
    expect(phase(CalendarDay(2026, 3, 7)), CyclePhase.afterPeriod);
    expect(phase(CalendarDay(2026, 3, 8)), CyclePhase.midCycle);
    expect(phase(CalendarDay(2026, 3, 16)), CyclePhase.midCycle);
    expect(phase(CalendarDay(2026, 3, 17)), CyclePhase.secondPart);
    expect(phase(CalendarDay(2026, 3, 21)), CyclePhase.secondPart);
  });

  test('the last days before the estimate, and once it is due or late', () {
    expect(phase(CalendarDay(2026, 3, 22)), CyclePhase.beforePeriod);
    expect(phase(CalendarDay(2026, 3, 26)), CyclePhase.beforePeriod);
    expect(
      phase(
        CalendarDay(2026, 3, 28),
        status: PeriodDue(prediction: prediction),
      ),
      CyclePhase.beforePeriod,
    );
    expect(
      phase(
        CalendarDay(2026, 4, 3),
        status: PeriodLate(prediction: prediction, daysLate: 3),
      ),
      CyclePhase.beforePeriod,
    );
  });

  test('without an ovulation estimate, the middle is not named', () {
    CyclePhase? on(int day) =>
        phase(CalendarDay(2026, 3, day), withEstimate: false);
    expect(on(6), CyclePhase.afterPeriod);
    expect(on(13), CyclePhase.afterPeriod);
    expect(on(14), CyclePhase.secondPart);
    expect(on(20), CyclePhase.secondPart);
    expect(on(23), CyclePhase.beforePeriod);
  });

  test('nothing is said when there is nothing to count from', () {
    final day = CalendarDay(2026, 3, 10);
    expect(phase(day, status: const NoEstimate()), isNull);
    expect(phase(day, status: const EstimateOutdated()), isNull);
  });

  test('nothing during a pregnancy, after a birth, or on hormones', () {
    final day = CalendarDay(2026, 3, 10);
    expect(phase(day, profile: Profile.pregnant), isNull);
    expect(phase(day, profile: Profile.postpartum), isNull);
    expect(phase(day, contraception: Contraception.hormonal), isNull);
    expect(
      phase(day, contraception: Contraception.nonHormonal),
      CyclePhase.midCycle,
    );
    expect(phase(day, profile: Profile.perimenopause), CyclePhase.midCycle);
  });

  test('the tip changes from one day to the next, and comes back', () {
    final day = CalendarDay(2026, 3, 10);
    expect(tipIndexOn(day), isNot(tipIndexOn(day.addDays(1))));
    expect(tipIndexOn(day), tipIndexOn(day.addDays(tipsPerPhase)));
    expect(tipIndexOn(day), inInclusiveRange(0, tipsPerPhase - 1));
  });
}
