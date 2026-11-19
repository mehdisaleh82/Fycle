import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/clinical_review.dart';
import 'package:fycle/domain/cycle_history.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/period_predictor.dart';
import 'package:fycle/domain/reference_cycle.dart';
import 'package:fycle/domain/study_facts.dart';

/// Fictional log: periods of [periodLength] days of [intensity], starting
/// [lengths] days apart from [first], followed by one last period.
Map<CalendarDay, FlowIntensity> periods(
  CalendarDay first,
  List<int> lengths, {
  int periodLength = 4,
  FlowIntensity intensity = FlowIntensity.medium,
}) {
  final log = <CalendarDay, FlowIntensity>{};
  var start = first;
  for (final length in [...lengths, 0]) {
    for (var i = 0; i < periodLength; i++) {
      log[start.addDays(i)] = intensity;
    }
    start = start.addDays(length);
  }
  return log;
}

ClinicalReview? review(
  Map<CalendarDay, FlowIntensity> log,
  CalendarDay today, {
  int? age,
}) => clinicalReview(
  cycles: cycleHistory(log),
  flowByDay: log,
  today: today,
  age: age,
);

void main() {
  final first = CalendarDay(2026, 1, 1);

  group('clinicalReview', () {
    test('there is none before a cycle has ended', () {
      expect(review(periods(first, []), first.addDays(10)), isNull);
      expect(review({}, first), isNull);
    });

    test('regular cycles of usual length are within every range', () {
      final log = periods(first, [28, 29, 27, 28]);
      final result = review(log, first.addDays(115))!;
      expect(result.cyclesCounted, 4);
      expect(result.meanCycleLength, 28);
      expect(result.frequency, RangePosition.within);
      expect(result.shortestCycle, 27);
      expect(result.longestCycle, 29);
      expect(result.variation, 2);
      expect(result.regular, isTrue);
      expect(result.meanPeriodLength, 4);
      expect(result.longestPeriod, 4);
      expect(result.duration, RangePosition.within);
      expect(result.volume, BleedingVolume.moderate);
      expect(result.spottingDaysBetweenPeriods, 0);
    });

    test('short cycles are called frequent, long ones infrequent', () {
      final short = review(periods(first, [21, 22, 21]), first.addDays(70))!;
      expect(short.frequency, RangePosition.below);
      final long = review(periods(first, [42, 40, 41]), first.addDays(130))!;
      expect(long.frequency, RangePosition.above);
    });

    test('the limits of the range are inside it', () {
      expect(
        review(periods(first, [24, 24]), first.addDays(50))!.frequency,
        RangePosition.within,
      );
      expect(
        review(periods(first, [38, 38]), first.addDays(80))!.frequency,
        RangePosition.within,
      );
    });

    test('regularity is not judged on fewer than three cycles', () {
      final result = review(periods(first, [26, 34]), first.addDays(62))!;
      expect(result.variation, 8);
      expect(result.regular, isNull);
    });

    test('the limit on variation depends on age', () {
      final log = periods(first, [26, 34, 30]);
      final today = first.addDays(95);
      // 8 days between the shortest and the longest.
      expect(review(log, today, age: 30)!.regular, isFalse);
      expect(review(log, today, age: 30)!.regularVariationLimit, 7);
      expect(review(log, today, age: 22)!.regular, isTrue);
      expect(review(log, today, age: 44)!.regular, isTrue);
      expect(review(log, today)!.regular, isTrue);
      expect(review(log, today)!.regularVariationLimit, 9);
    });

    test('a period longer than eight days is called prolonged', () {
      final result = review(
        periods(first, [30, 30], periodLength: 10),
        first.addDays(62),
      )!;
      expect(result.meanPeriodLength, 10);
      expect(result.duration, RangePosition.above);
      expect(
        review(
          periods(first, [30, 30], periodLength: 8),
          first.addDays(62),
        )!.duration,
        RangePosition.within,
      );
    });

    test('the volume follows the heaviest day of the periods', () {
      expect(
        review(
          periods(first, [28, 28], intensity: FlowIntensity.light),
          first.addDays(60),
        )!.volume,
        BleedingVolume.light,
      );
      final log = periods(first, [28, 28], intensity: FlowIntensity.light);
      // One heavy day in each of the two complete cycles.
      log[first.addDays(1)] = FlowIntensity.heavy;
      log[first.addDays(29)] = FlowIntensity.heavy;
      expect(review(log, first.addDays(60))!.volume, BleedingVolume.heavy);
    });

    test('spotting between periods is counted, not inside them', () {
      final log = periods(first, [28, 28]);
      log[first.addDays(14)] = FlowIntensity.spotting;
      log[first.addDays(15)] = FlowIntensity.spotting;
      log[first.addDays(40)] = FlowIntensity.spotting;
      // In the current cycle: not looked at.
      log[first.addDays(70)] = FlowIntensity.spotting;
      expect(review(log, first.addDays(72))!.spottingDaysBetweenPeriods, 3);
    });

    test('gives the first part of the cycle as a range', () {
      final result = review(periods(first, [30, 30, 30]), first.addDays(95))!;
      // 30 days minus a second part of 13 days, give or take 3.
      expect(result.follicularDaysEarliest, 14);
      expect(result.follicularDaysLatest, 20);
    });

    test('only the last year is looked at, and implausible cycles are '
        'left out', () {
      final old = periods(CalendarDay(2024, 1, 1), [40, 40, 40]);
      final recent = periods(first, [28, 120, 28]);
      final result = review({...old, ...recent}, first.addDays(180))!;
      expect(result.cyclesCounted, 2);
      expect(result.meanCycleLength, 28);
    });
  });

  group('referenceCycleLengthForAge', () {
    test('is the common length when the age is unknown', () {
      expect(
        referenceCycleLengthForAge(null),
        PeriodPredictor.defaultCycleLength,
      );
    });

    test('follows the slope of the study between 25 and 45', () {
      expect(referenceCycleLengthForAge(25), 30);
      expect(referenceCycleLengthForAge(30), 29);
      expect(referenceCycleLengthForAge(35), 28);
      expect(referenceCycleLengthForAge(45), 27);
    });

    test('never grows with age, and is flat outside the measured range', () {
      for (var age = minProfileAge; age < maxProfileAge; age++) {
        expect(
          referenceCycleLengthForAge(age + 1),
          lessThanOrEqualTo(referenceCycleLengthForAge(age)),
          reason: 'age $age',
        );
      }
      expect(referenceCycleLengthForAge(16), referenceCycleLengthForAge(25));
      expect(referenceCycleLengthForAge(60), referenceCycleLengthForAge(45));
    });

    test('an age comes from a plausible year of birth only', () {
      expect(ageIn(2026, null), isNull);
      expect(ageIn(2026, 1990), 36);
      expect(ageIn(2026, 2020), isNull);
      expect(ageIn(2026, 1940), isNull);
      expect(ageIn(2026, 2030), isNull);
      expect(ageIn(2026, 2016), 10);
      expect(ageIn(2026, 1956), 70);
    });
  });

  group('studyFactOn', () {
    test('a new fact each day, the same all day', () {
      final day = CalendarDay(2026, 3, 20);
      expect(studyFactOn(day), studyFactOn(CalendarDay(2026, 3, 20)));
      expect(studyFactOn(day.addDays(1)), isNot(studyFactOn(day)));
    });

    test('every fact comes up in turn, before and after the first day', () {
      for (final start in [CalendarDay(2025, 6, 1), CalendarDay(2027, 2, 1)]) {
        final seen = {
          for (var i = 0; i < StudyFact.values.length; i++)
            studyFactOn(start.addDays(i)),
        };
        expect(seen, StudyFact.values.toSet());
      }
    });
  });
}
