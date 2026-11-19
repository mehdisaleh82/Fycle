import 'calendar_day.dart';
import 'flow_intensity.dart';
import 'mood.dart';
import 'pain_level.dart';
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
    Set<Symptom> symptoms = const {},
    String? note,
  }) : symptoms = Set.unmodifiable(symptoms),
       note = (note == null || note.trim().isEmpty) ? null : note;

  final CalendarDay day;
  final FlowIntensity? flow;
  final PainLevel? pain;
  final Mood? mood;
  final Set<Symptom> symptoms;
  final String? note;

  /// True when nothing was logged, so the entry does not need to be kept.
  bool get isEmpty =>
      flow == null &&
      pain == null &&
      mood == null &&
      symptoms.isEmpty &&
      note == null;

  @override
  bool operator ==(Object other) =>
      other is DayEntry &&
      other.day == day &&
      other.flow == flow &&
      other.pain == pain &&
      other.mood == mood &&
      other.note == note &&
      other.symptoms.length == symptoms.length &&
      other.symptoms.containsAll(symptoms);

  @override
  int get hashCode => Object.hash(
    day,
    flow,
    pain,
    mood,
    note,
    Object.hashAllUnordered(symptoms),
  );

  @override
  String toString() =>
      'DayEntry($day, flow: ${flow?.name}, pain: ${pain?.name}, '
      'mood: ${mood?.name}, symptoms: ${symptoms.map((s) => s.name).toList()}, '
      'note: ${note == null ? 'no' : 'yes'})';
}
