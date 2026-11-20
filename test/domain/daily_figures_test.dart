import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/cycle_history.dart';
import 'package:fycle/domain/daily_figures.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/libido_level.dart';
import 'package:fycle/domain/mood.dart';
import 'package:fycle/domain/pain_level.dart';
import 'package:fycle/domain/period_prediction.dart';
import 'package:fycle/domain/sleep_quality.dart';
import 'package:fycle/domain/start_profile.dart';
import 'package:fycle/domain/symptom.dart';

void main() {
  final today = CalendarDay(2026, 3, 20);

  group('the last seven days', () {
    test('run from six days ago to today, with what was filled in', () {
      final entries = {
        today: DayEntry(day: today, mood: Mood.calm, sleep: SleepQuality.good),
        today.addDays(-2): DayEntry(
          day: today.addDays(-2),
          symptoms: const {Symptom.headache},
        ),
        // Too old to count.
        today.addDays(-7): DayEntry(
          day: today.addDays(-7),
          pain: PainLevel.mild,
        ),
      };
      final week = lastSevenDays(today, (day) => entries[day]);

      expect(week, hasLength(7));
      expect(week.first.day, today.addDays(-6));
      expect(week.last.day, today);
      expect(week.where((day) => day.logged), hasLength(2));
      expect(week.last.filled, {Tracked.mood, Tracked.sleep});
      expect(week[4].filled, {Tracked.symptoms});
      expect(week.first.logged, isFalse);
    });
  });

  test('the month counts the days gone by, today included', () {
    final month = monthLogged(today, {
      CalendarDay(2026, 3, 1),
      CalendarDay(2026, 3, 20),
      CalendarDay(2026, 2, 28),
      CalendarDay(2026, 3, 25),
    });
    expect(month.logged, 2);
    expect(month.elapsed, 20);
  });

  group('the cycle going on', () {
    Map<CalendarDay, FlowIntensity> period(CalendarDay from) => {
      for (var i = 0; i < 4; i++) from.addDays(i): FlowIntensity.medium,
    };
    final flow = {
      ...period(CalendarDay(2026, 1, 31)),
      ...period(CalendarDay(2026, 2, 28)),
    };
    final days = [
      for (final day in flow.keys) DayEntry(day: day, flow: flow[day]),
      // Previous cycle: one good night within its first 21 days, one after.
      DayEntry(day: CalendarDay(2026, 2, 10), sleep: SleepQuality.good),
      DayEntry(day: CalendarDay(2026, 2, 25), sleep: SleepQuality.good),
      DayEntry(
        day: CalendarDay(2026, 3, 10),
        sleep: SleepQuality.good,
        mood: Mood.happy,
        libido: LibidoLevel.high,
      ),
      DayEntry(
        day: CalendarDay(2026, 3, 12),
        pain: PainLevel.mild,
        mood: Mood.calm,
      ),
      DayEntry(
        day: CalendarDay(2026, 3, 14),
        pain: PainLevel.none,
        mood: Mood.calm,
      ),
    ]..sort((a, b) => a.day.compareTo(b.day));

    test(
      'is counted up to today, next to the one before at the same point',
      () {
        final figures = cycleFiguresOn(
          today,
          cycles: cycleHistory(flow),
          days: days,
        )!;

        expect(figures.current.days, 21);
        expect(figures.current.daysLogged, 7);
        expect(figures.current.goodNights, 1);
        // "None" is not a day with pain.
        expect(figures.current.painDays, 1);
        expect(figures.current.commonMood, Mood.calm);
        expect(figures.current.commonLibido, LibidoLevel.high);

        expect(figures.previous!.days, 21);
        expect(figures.previous!.daysLogged, 5);
        expect(figures.previous!.goodNights, 1);
        expect(figures.previous!.commonMood, isNull);
      },
    );

    test('has nothing to say before a first period', () {
      expect(cycleFiguresOn(today, cycles: const [], days: const []), isNull);
    });

    test('stands alone when it is the first cycle', () {
      final first = period(CalendarDay(2026, 3, 15));
      final figures = cycleFiguresOn(
        today,
        cycles: cycleHistory(first),
        days: [
          for (final day in first.keys) DayEntry(day: day, flow: first[day]),
        ],
      )!;
      expect(figures.current.days, 6);
      expect(figures.previous, isNull);
    });
  });

  group('the reliability of the estimate', () {
    PeriodPrediction prediction(PredictionConfidence confidence, int cycles) =>
        PeriodPrediction(
          earliestStart: today,
          latestStart: today.addDays(6),
          confidence: confidence,
          estimatedCycleLength: 28,
          cyclesUsed: cycles,
        );

    test('says how many cycles are missing for the next level', () {
      final low = reliabilityStepOf(prediction(PredictionConfidence.low, 0));
      expect(low.cyclesMissing, 2);
      expect(low.heldByVariation, isFalse);

      final medium = reliabilityStepOf(
        prediction(PredictionConfidence.medium, 3),
      );
      expect(medium.cyclesMissing, 1);
      expect(medium.heldByVariation, isFalse);
    });

    test('says so when cycles are not what is missing', () {
      final step = reliabilityStepOf(prediction(PredictionConfidence.low, 5));
      expect(step.cyclesMissing, 0);
      expect(step.heldByVariation, isTrue);
    });

    test('asks nothing more at the highest level', () {
      final step = reliabilityStepOf(prediction(PredictionConfidence.high, 6));
      expect(step.cyclesMissing, 0);
      expect(step.heldByVariation, isFalse);
    });
  });
}
