import 'calendar_day.dart';
import 'flow_intensity.dart';
import 'intimacy.dart';
import 'libido_level.dart';
import 'migraine.dart';
import 'mood.dart';
import 'pain_level.dart';
import 'sleep_quality.dart';
import 'symptom.dart';

/// Everything logged for one calendar day.
///
/// Every field except [day] is optional. A day without flow has a null
/// [flow]. A blank [note] is treated as no note.
final class DayEntry {
  DayEntry({
    required this.day,
    this.flow,
    this.pain,
    this.mood,
    this.sleep,
    this.libido,
    this.intimacy,
    Set<Symptom> symptoms = const {},
    String? note,
    MigraineDetail? migraine,
  }) : symptoms = Set.unmodifiable(symptoms),
       note = (note == null || note.trim().isEmpty) ? null : note,
       // The detail of a migraine goes with the migraine ticked.
       migraine =
           migraine == null ||
               migraine.isEmpty ||
               !symptoms.contains(Symptom.migraine)
           ? null
           : migraine;

  final CalendarDay day;
  final FlowIntensity? flow;
  final PainLevel? pain;
  final Mood? mood;
  final SleepQuality? sleep;
  final LibidoLevel? libido;

  /// Sex logged on the day, if she chose to note it.
  final Intimacy? intimacy;
  final Set<Symptom> symptoms;
  final String? note;

  /// What she noted of the migraine of the day, when one is ticked.
  final MigraineDetail? migraine;

  /// The same entry with another [flow] (null for no flow). Everything
  /// else logged for the day is kept.
  DayEntry withFlow(FlowIntensity? flow) => DayEntry(
    day: day,
    flow: flow,
    pain: pain,
    mood: mood,
    sleep: sleep,
    libido: libido,
    intimacy: intimacy,
    symptoms: symptoms,
    note: note,
    migraine: migraine,
  );

  /// The same entry with another [pain] (null for none logged).
  DayEntry withPain(PainLevel? pain) => DayEntry(
    day: day,
    flow: flow,
    pain: pain,
    mood: mood,
    sleep: sleep,
    libido: libido,
    intimacy: intimacy,
    symptoms: symptoms,
    note: note,
    migraine: migraine,
  );

  /// The same entry with another [mood] (null for none logged).
  DayEntry withMood(Mood? mood) => DayEntry(
    day: day,
    flow: flow,
    pain: pain,
    mood: mood,
    sleep: sleep,
    libido: libido,
    intimacy: intimacy,
    symptoms: symptoms,
    note: note,
    migraine: migraine,
  );

  /// The same day with another sleep quality.
  DayEntry withSleep(SleepQuality? sleep) => DayEntry(
    day: day,
    flow: flow,
    pain: pain,
    mood: mood,
    sleep: sleep,
    libido: libido,
    intimacy: intimacy,
    symptoms: symptoms,
    note: note,
    migraine: migraine,
  );

  /// The same day with another libido level.
  DayEntry withLibido(LibidoLevel? libido) => DayEntry(
    day: day,
    flow: flow,
    pain: pain,
    mood: mood,
    sleep: sleep,
    libido: libido,
    intimacy: intimacy,
    symptoms: symptoms,
    note: note,
    migraine: migraine,
  );

  /// The same day with sex logged, or not (null).
  DayEntry withIntimacy(Intimacy? intimacy) => DayEntry(
    day: day,
    flow: flow,
    pain: pain,
    mood: mood,
    sleep: sleep,
    libido: libido,
    intimacy: intimacy,
    symptoms: symptoms,
    note: note,
    migraine: migraine,
  );

  /// The same day with other symptoms ticked.
  DayEntry withSymptoms(Set<Symptom> symptoms) => DayEntry(
    day: day,
    flow: flow,
    pain: pain,
    mood: mood,
    sleep: sleep,
    libido: libido,
    intimacy: intimacy,
    symptoms: symptoms,
    note: note,
    migraine: migraine,
  );

  /// The same day with another detail of its migraine.
  DayEntry withMigraine(MigraineDetail? migraine) => DayEntry(
    day: day,
    flow: flow,
    pain: pain,
    mood: mood,
    sleep: sleep,
    libido: libido,
    intimacy: intimacy,
    symptoms: symptoms,
    note: note,
    migraine: migraine,
  );

  /// How many of the groups of choices are filled in: flow, pain, mood,
  /// sleep, libido and symptoms. The note is free text and is not counted,
  /// nor is sex, which many will never log.
  int get filledGroups => [
    flow != null,
    pain != null,
    mood != null,
    sleep != null,
    libido != null,
    symptoms.isNotEmpty,
  ].where((filled) => filled).length;

  /// Number of groups counted by [filledGroups].
  static const int groupCount = 6;

  /// True when nothing was logged, so the entry does not need to be kept.
  bool get isEmpty =>
      flow == null &&
      pain == null &&
      mood == null &&
      sleep == null &&
      libido == null &&
      intimacy == null &&
      symptoms.isEmpty &&
      note == null;

  @override
  bool operator ==(Object other) =>
      other is DayEntry &&
      other.day == day &&
      other.flow == flow &&
      other.pain == pain &&
      other.mood == mood &&
      other.sleep == sleep &&
      other.libido == libido &&
      other.intimacy == intimacy &&
      other.note == note &&
      other.migraine == migraine &&
      other.symptoms.length == symptoms.length &&
      other.symptoms.containsAll(symptoms);

  @override
  int get hashCode => Object.hash(
    day,
    flow,
    pain,
    mood,
    sleep,
    libido,
    intimacy,
    note,
    migraine,
    Object.hashAllUnordered(symptoms),
  );

  @override
  String toString() =>
      'DayEntry($day, flow: ${flow?.name}, pain: ${pain?.name}, '
      'mood: ${mood?.name}, sleep: ${sleep?.name}, libido: ${libido?.name}, '
      'symptoms: ${symptoms.map((s) => s.name).toList()}, '
      'note: ${note == null ? 'no' : 'yes'})';
}
