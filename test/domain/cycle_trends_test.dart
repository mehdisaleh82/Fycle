import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/cycle_history.dart';
import 'package:fycle/domain/cycle_trends.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/libido_level.dart';
import 'package:fycle/domain/mood.dart';
import 'package:fycle/domain/pain_level.dart';
import 'package:fycle/domain/sleep_quality.dart';
import 'package:fycle/domain/symptom.dart';

/// Fictional log: periods of 4 days, starting [lengths] days apart from
/// [first], followed by one last period (the current cycle).
List<DayEntry> periods(CalendarDay first, List<int> lengths) {
  final days = <DayEntry>[];
  var start = first;
  for (final length in [...lengths, 0]) {
    for (var i = 0; i < 4; i++) {
      days.add(DayEntry(day: start.addDays(i), flow: FlowIntensity.medium));
    }
    start = start.addDays(length);
  }
  return days;
}

/// Merges [extra] into [days], keeping the flow already logged on a day.
List<DayEntry> withEntries(List<DayEntry> days, List<DayEntry> extra) {
  final byDay = {for (final entry in days) entry.day: entry};
  for (final entry in extra) {
    byDay[entry.day] = DayEntry(
      day: entry.day,
      flow: byDay[entry.day]?.flow,
      pain: entry.pain,
      mood: entry.mood,
      sleep: entry.sleep,
      libido: entry.libido,
      symptoms: entry.symptoms,
    );
  }
  return byDay.values.toList();
}

List<LoggedCycle> cyclesOf(List<DayEntry> days) => cycleHistory({
  for (final entry in days)
    if (entry.flow != null) entry.day: entry.flow!,
});

void main() {
  final first = CalendarDay(2026, 1, 1);
  // Three complete cycles of 28 days, starting 1 Jan, 29 Jan and 26 Feb.
  final starts = [first, first.addDays(28), first.addDays(56)];

  group('signsOf', () {
    test('lists what was logged, without the absence of pain', () {
      final entry = DayEntry(
        day: first,
        pain: PainLevel.none,
        mood: Mood.calm,
        sleep: SleepQuality.poor,
        libido: LibidoLevel.high,
        symptoms: {Symptom.cramps},
      );
      expect(signsOf(entry).toSet(), {
        Mood.calm,
        SleepQuality.poor,
        LibidoLevel.high,
        Symptom.cramps,
      });
      expect(signsOf(DayEntry(day: first, pain: PainLevel.severe)).toList(), [
        PainLevel.severe,
      ]);
    });
  });

  group('cycleTrends', () {
    test('says nothing with fewer than two complete cycles', () {
      final days = withEntries(periods(first, [28]), [
        DayEntry(day: first, symptoms: {Symptom.cramps}),
      ]);
      expect(cycleTrends(cycles: cyclesOf(days), days: days), isEmpty);
    });

    test('counts in how many cycles a sign came back at each moment', () {
      final days = withEntries(periods(first, [28, 28, 28]), [
        // Cramps during the period, in all three cycles.
        for (final start in starts)
          DayEntry(day: start.addDays(1), symptoms: {Symptom.cramps}),
        // Twice on the same cycle counts once.
        DayEntry(day: first.addDays(2), symptoms: {Symptom.cramps}),
        // Poor sleep the week before the next period, in two cycles.
        DayEntry(day: starts[0].addDays(25), sleep: SleepQuality.poor),
        DayEntry(day: starts[1].addDays(22), sleep: SleepQuality.poor),
      ]);
      final trends = cycleTrends(cycles: cyclesOf(days), days: days);
      expect(
        [for (final trend in trends) trend.sign],
        [Symptom.cramps, SleepQuality.poor],
      );

      final cramps = trends.first;
      expect(cramps.cyclesConsidered, 3);
      expect(cramps.cyclesAt(CycleMoment.period), 3);
      expect(cramps.cyclesAt(CycleMoment.rest), 0);
      expect(cramps.mainMoment, CycleMoment.period);

      final sleep = trends.last;
      expect(sleep.cyclesAt(CycleMoment.beforeNextPeriod), 2);
      expect(sleep.mainMoment, CycleMoment.beforeNextPeriod);
    });

    test('a sign seen in one cycle only is not a trend', () {
      final days = withEntries(periods(first, [28, 28, 28]), [
        DayEntry(day: first.addDays(10), symptoms: {Symptom.headache}),
        DayEntry(day: first.addDays(11), symptoms: {Symptom.headache}),
      ]);
      expect(cycleTrends(cycles: cyclesOf(days), days: days), isEmpty);
    });

    test('a sign at different moments in each cycle is not a trend', () {
      final days = withEntries(periods(first, [28, 28, 28]), [
        DayEntry(day: starts[0].addDays(1), mood: Mood.sad),
        DayEntry(day: starts[1].addDays(10), mood: Mood.sad),
        DayEntry(day: starts[2].addDays(25), mood: Mood.sad),
      ]);
      expect(cycleTrends(cycles: cyclesOf(days), days: days), isEmpty);
    });

    test('the current cycle is not counted', () {
      final days = withEntries(periods(first, [28, 28]), [
        DayEntry(day: starts[0].addDays(1), symptoms: {Symptom.nausea}),
        // In the current cycle, whose end is unknown.
        DayEntry(day: starts[2].addDays(1), symptoms: {Symptom.nausea}),
      ]);
      expect(cycleTrends(cycles: cyclesOf(days), days: days), isEmpty);
    });

    test('a cycle hiding a missed period is left out', () {
      final days = withEntries(periods(first, [28, 120, 28]), [
        DayEntry(day: first.addDays(1), symptoms: {Symptom.acne}),
        // Inside the 120-day gap.
        DayEntry(day: first.addDays(29), symptoms: {Symptom.acne}),
        DayEntry(day: first.addDays(149), symptoms: {Symptom.acne}),
      ]);
      final trends = cycleTrends(cycles: cyclesOf(days), days: days);
      expect(trends.single.sign, Symptom.acne);
      expect(trends.single.cyclesConsidered, 2);
      expect(trends.single.cyclesAt(CycleMoment.period), 2);
    });

    test('only the most recent cycles are looked at', () {
      final days = withEntries(periods(first, List.filled(8, 28)), [
        // In the two oldest cycles only.
        DayEntry(day: first.addDays(1), symptoms: {Symptom.bloating}),
        DayEntry(day: first.addDays(29), symptoms: {Symptom.bloating}),
      ]);
      expect(cycleTrends(cycles: cyclesOf(days), days: days), isEmpty);
    });

    test('with equal counts, signs keep a stable order', () {
      final days = withEntries(periods(first, [28, 28]), [
        for (final start in starts.take(2))
          DayEntry(
            day: start.addDays(1),
            symptoms: {Symptom.fatigue, Symptom.cramps},
          ),
      ]);
      final trends = cycleTrends(cycles: cyclesOf(days), days: days);
      expect(
        [for (final trend in trends) trend.sign],
        [Symptom.cramps, Symptom.fatigue],
      );
    });
  });

  group('lastCycleSummary', () {
    test('there is none before a cycle has ended', () {
      final days = periods(first, []);
      expect(lastCycleSummary(cycles: cyclesOf(days), days: days), isNull);
    });

    test('a first cycle has nothing to be compared with', () {
      final days = periods(first, [30]);
      final summary = lastCycleSummary(cycles: cyclesOf(days), days: days)!;
      expect(summary.cycle.length, 30);
      expect(summary.previousAverageLength, isNull);
      expect(summary.differenceWithPrevious, isNull);
      expect(summary.mostLoggedSymptoms, isEmpty);
    });

    test('compares the cycle that ended with the ones before', () {
      final days = periods(first, [28, 30, 32]);
      final summary = lastCycleSummary(cycles: cyclesOf(days), days: days)!;
      expect(summary.cycle.start, first.addDays(58));
      expect(summary.cycle.length, 32);
      expect(summary.previousAverageLength, 29);
      expect(summary.differenceWithPrevious, 3);
    });

    test('a shorter cycle gives a negative difference', () {
      final days = periods(first, [30, 30, 26]);
      final summary = lastCycleSummary(cycles: cyclesOf(days), days: days)!;
      expect(summary.differenceWithPrevious, -4);
    });

    test('names the symptoms logged on the most days of that cycle', () {
      final second = first.addDays(28);
      final days = withEntries(periods(first, [28, 28]), [
        // In the cycle before: not counted.
        DayEntry(day: first.addDays(3), symptoms: {Symptom.acne}),
        DayEntry(
          day: second,
          symptoms: {Symptom.cramps, Symptom.fatigue, Symptom.nausea},
        ),
        DayEntry(
          day: second.addDays(1),
          symptoms: {Symptom.cramps, Symptom.fatigue, Symptom.headache},
        ),
        DayEntry(day: second.addDays(2), symptoms: {Symptom.fatigue}),
      ]);
      final summary = lastCycleSummary(cycles: cyclesOf(days), days: days)!;
      expect(summary.mostLoggedSymptoms, [
        Symptom.fatigue,
        Symptom.cramps,
        Symptom.headache,
      ]);
    });

    test('says nothing about a cycle hiding a missed period', () {
      final days = periods(first, [28, 120]);
      expect(lastCycleSummary(cycles: cyclesOf(days), days: days), isNull);
    });
  });
}
