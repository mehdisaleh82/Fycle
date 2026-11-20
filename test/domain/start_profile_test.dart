import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/cycle_history.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/period_end_estimate.dart';
import 'package:fycle/domain/period_predictor.dart';
import 'package:fycle/domain/start_profile.dart';

void main() {
  group('what the setup asks', () {
    test('recent changes: for the perimenopause, or from 40', () {
      expect(asksAboutRecentChanges(goals: {}), isFalse);
      expect(asksAboutRecentChanges(goals: {}, age: 39), isFalse);
      expect(asksAboutRecentChanges(goals: {}, age: 40), isTrue);
      expect(
        asksAboutRecentChanges(goals: {Goal.perimenopause}, age: 30),
        isTrue,
      );
    });

    test('the fertile window is shown unless she only wants her dates', () {
      expect(showsFertilityFor({}), isTrue);
      expect(showsFertilityFor({Goal.trackPeriods}), isFalse);
      expect(showsFertilityFor({Goal.perimenopause}), isFalse);
      expect(showsFertilityFor({Goal.trackPeriods, Goal.conceive}), isTrue);
      expect(showsFertilityFor({Goal.understandBody}), isTrue);
      // Asking for it by name is enough.
      expect(
        showsFertilityFor({Goal.trackPeriods}, wishes: {Wish.fertileWindow}),
        isTrue,
      );
      expect(showsFertilityFor({}, wishes: {Wish.knowWhen}), isFalse);
    });

    test('never with a hormonal contraception', () {
      expect(
        showsFertilityFor({}, contraception: Contraception.hormonal),
        isFalse,
      );
      expect(
        showsFertilityFor(
          {Goal.conceive},
          wishes: {Wish.fertileWindow},
          contraception: Contraception.hormonal,
        ),
        isFalse,
      );
      expect(
        showsFertilityFor({}, contraception: Contraception.nonHormonal),
        isTrue,
      );
    });

    test('no dates are asked of someone without periods', () {
      expect(hasPeriods(null), isTrue);
      expect(hasPeriods(CycleRegularity.irregular), isTrue);
      expect(hasPeriods(CycleRegularity.noPeriods), isFalse);
    });
  });

  group('cycles she calls irregular', () {
    const predictor = PeriodPredictor();
    final start = CalendarDay(2026, 3, 1);

    test('start from the widest range, whatever length she gave', () {
      final prediction = predictor.predict(
        periodStarts: [start],
        usualCycleLength: 30,
        irregular: true,
      )!;
      expect(prediction.earliestStart, start.addDays(20));
      expect(prediction.latestStart, start.addDays(40));
    });

    test('keep at least five days on each side before three cycles', () {
      final prediction = predictor.predict(
        periodStarts: [start, start.addDays(28), start.addDays(56)],
        irregular: true,
      )!;
      expect(prediction.cyclesUsed, 2);
      expect(prediction.latestStart.daysSince(prediction.earliestStart), 10);
    });

    test('are then measured from her own dates, like any others', () {
      final starts = [for (var i = 0; i < 5; i++) start.addDays(28 * i)];
      final regular = predictor.predict(periodStarts: starts)!;
      final irregular = predictor.predict(
        periodStarts: starts,
        irregular: true,
      )!;
      expect(irregular.earliestStart, regular.earliestStart);
      expect(irregular.latestStart, regular.latestStart);
    });
  });

  group('the period length she gave', () {
    Map<CalendarDay, FlowIntensity> period(CalendarDay from, int days) => {
      for (var i = 0; i < days; i++) from.addDays(i): FlowIntensity.medium,
    };

    test('stands in before two past periods are known', () {
      final cycles = cycleHistory(period(CalendarDay(2026, 3, 1), 2));
      final estimate = periodEndEstimate(
        dayOfPeriod: 2,
        cycles: cycles,
        declaredPeriodLength: 5,
      )!;
      expect(estimate.earliestDaysLeft, 3);
      expect(estimate.latestDaysLeft, 3);
      expect(estimate.periodsUsed, 0);
    });

    test('says nothing once the period outlasts it', () {
      final cycles = cycleHistory(period(CalendarDay(2026, 3, 1), 6));
      expect(
        periodEndEstimate(
          dayOfPeriod: 6,
          cycles: cycles,
          declaredPeriodLength: 5,
        ),
        isNull,
      );
    });

    test('gives way to her own past periods', () {
      final cycles = cycleHistory({
        ...period(CalendarDay(2026, 1, 1), 4),
        ...period(CalendarDay(2026, 1, 29), 6),
        ...period(CalendarDay(2026, 2, 26), 1),
      });
      final estimate = periodEndEstimate(
        dayOfPeriod: 1,
        cycles: cycles,
        declaredPeriodLength: 9,
      )!;
      expect(estimate.periodsUsed, 2);
      expect(estimate.earliestDaysLeft, 3);
      expect(estimate.latestDaysLeft, 5);
    });
  });
}
