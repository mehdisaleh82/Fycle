import 'day_entry.dart';
import 'mood.dart';
import 'pain_level.dart';
import 'sleep_quality.dart';
import 'symptom.dart';

/// What a tip of the day can be about, when it answers what she logged
/// today rather than the phase of her cycle.
///
/// Each topic has one short tip of everyday comfort: nothing is diagnosed,
/// no medicine is named, and the texts are to be read by a health
/// professional before publication (CLAUDE.md, rule 7).
enum TipTopic {
  pain,
  headache,
  nightSweats,
  poorSleep,
  fatigue,
  backPain,
  bloating,
  nausea,
  breastTenderness,
  lowMood,
}

/// The topic of the tip for what is logged in [entry], or null when
/// nothing logged calls for one: the tip of the phase is then shown.
///
/// When several things are logged, the first of [TipTopic] wins: what
/// hurts comes before what tires, and the body before the mood.
TipTopic? tipTopicFor(DayEntry entry) {
  final symptoms = entry.symptoms;
  bool any(Set<Symptom> among) => symptoms.any(among.contains);
  if (entry.pain == PainLevel.moderate ||
      entry.pain == PainLevel.severe ||
      symptoms.contains(Symptom.cramps)) {
    return TipTopic.pain;
  }
  if (any(const {Symptom.headache, Symptom.migraine})) {
    return TipTopic.headache;
  }
  if (any(const {Symptom.nightSweats, Symptom.hotFlashes})) {
    return TipTopic.nightSweats;
  }
  if (entry.sleep == SleepQuality.poor || symptoms.contains(Symptom.insomnia)) {
    return TipTopic.poorSleep;
  }
  if (symptoms.contains(Symptom.fatigue)) {
    return TipTopic.fatigue;
  }
  if (symptoms.contains(Symptom.backPain)) {
    return TipTopic.backPain;
  }
  if (symptoms.contains(Symptom.bloating)) {
    return TipTopic.bloating;
  }
  if (symptoms.contains(Symptom.nausea)) {
    return TipTopic.nausea;
  }
  if (symptoms.contains(Symptom.breastTenderness)) {
    return TipTopic.breastTenderness;
  }
  if (entry.mood == Mood.sad ||
      entry.mood == Mood.anxious ||
      entry.mood == Mood.irritable ||
      symptoms.contains(Symptom.moodSwings)) {
    return TipTopic.lowMood;
  }
  return null;
}
