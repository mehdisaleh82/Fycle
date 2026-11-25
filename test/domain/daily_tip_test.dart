import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/daily_tip.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/mood.dart';
import 'package:fycle/domain/pain_level.dart';
import 'package:fycle/domain/sleep_quality.dart';
import 'package:fycle/domain/symptom.dart';

void main() {
  final day = CalendarDay(2026, 3, 20);

  test('nothing logged, or nothing that calls for a tip, gives no topic', () {
    expect(tipTopicFor(DayEntry(day: day)), isNull);
    expect(
      tipTopicFor(
        DayEntry(
          day: day,
          flow: FlowIntensity.medium,
          pain: PainLevel.mild,
          mood: Mood.calm,
          sleep: SleepQuality.good,
          symptoms: {Symptom.acne},
          note: 'Made-up note',
        ),
      ),
      isNull,
    );
  });

  test('each thing logged leads to its topic', () {
    TipTopic? of({
      PainLevel? pain,
      Mood? mood,
      SleepQuality? sleep,
      Set<Symptom> symptoms = const {},
    }) => tipTopicFor(
      DayEntry(
        day: day,
        pain: pain,
        mood: mood,
        sleep: sleep,
        symptoms: symptoms,
      ),
    );

    expect(of(pain: PainLevel.moderate), TipTopic.pain);
    expect(of(pain: PainLevel.severe), TipTopic.pain);
    expect(of(symptoms: {Symptom.cramps}), TipTopic.pain);
    expect(of(symptoms: {Symptom.headache}), TipTopic.headache);
    expect(of(symptoms: {Symptom.migraine}), TipTopic.headache);
    expect(of(symptoms: {Symptom.nightSweats}), TipTopic.nightSweats);
    expect(of(symptoms: {Symptom.hotFlashes}), TipTopic.nightSweats);
    expect(of(sleep: SleepQuality.poor), TipTopic.poorSleep);
    expect(of(symptoms: {Symptom.insomnia}), TipTopic.poorSleep);
    expect(of(symptoms: {Symptom.fatigue}), TipTopic.fatigue);
    expect(of(symptoms: {Symptom.backPain}), TipTopic.backPain);
    expect(of(symptoms: {Symptom.bloating}), TipTopic.bloating);
    expect(of(symptoms: {Symptom.nausea}), TipTopic.nausea);
    expect(of(symptoms: {Symptom.breastTenderness}), TipTopic.breastTenderness);
    expect(of(mood: Mood.sad), TipTopic.lowMood);
    expect(of(mood: Mood.anxious), TipTopic.lowMood);
    expect(of(mood: Mood.irritable), TipTopic.lowMood);
    expect(of(symptoms: {Symptom.moodSwings}), TipTopic.lowMood);
  });

  test('what hurts comes before what tires, and the body before the mood', () {
    expect(
      tipTopicFor(
        DayEntry(
          day: day,
          pain: PainLevel.severe,
          mood: Mood.sad,
          sleep: SleepQuality.poor,
          symptoms: {Symptom.fatigue, Symptom.headache},
        ),
      ),
      TipTopic.pain,
    );
    expect(
      tipTopicFor(
        DayEntry(
          day: day,
          mood: Mood.sad,
          sleep: SleepQuality.poor,
          symptoms: {Symptom.fatigue},
        ),
      ),
      TipTopic.poorSleep,
    );
    expect(
      tipTopicFor(
        DayEntry(day: day, mood: Mood.anxious, symptoms: {Symptom.bloating}),
      ),
      TipTopic.bloating,
    );
  });
}
