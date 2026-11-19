import '../domain/day_entry.dart';
import '../domain/flow_intensity.dart';
import '../domain/libido_level.dart';
import '../domain/mood.dart';
import '../domain/pain_level.dart';
import '../domain/sleep_quality.dart';
import '../domain/symptom.dart';

/// The words written in a CSV export: column headers and the name of each
/// choice.
///
/// The data layer holds no interface text. The interface passes its own
/// translated labels; [CsvLabels.english] writes the stored English names.
final class CsvLabels {
  const CsvLabels({
    required this.date,
    required this.flow,
    required this.pain,
    required this.mood,
    required this.sleep,
    required this.libido,
    required this.symptoms,
    required this.note,
    required this.flowName,
    required this.painName,
    required this.moodName,
    required this.sleepName,
    required this.libidoName,
    required this.symptomName,
  });

  /// Headers and values as they are stored: in English.
  static const CsvLabels english = CsvLabels(
    date: 'date',
    flow: 'flow',
    pain: 'pain',
    mood: 'mood',
    sleep: 'sleep',
    libido: 'libido',
    symptoms: 'symptoms',
    note: 'note',
    flowName: _storedName,
    painName: _storedName,
    moodName: _storedName,
    sleepName: _storedName,
    libidoName: _storedName,
    symptomName: _storedName,
  );

  final String date;
  final String flow;
  final String pain;
  final String mood;
  final String sleep;
  final String libido;
  final String symptoms;
  final String note;

  final String Function(FlowIntensity) flowName;
  final String Function(PainLevel) painName;
  final String Function(Mood) moodName;
  final String Function(SleepQuality) sleepName;
  final String Function(LibidoLevel) libidoName;
  final String Function(Symptom) symptomName;

  static String _storedName(Enum value) => value.name;
}

/// Turns logged days into a CSV text that opens in any spreadsheet.
///
/// One line per day, columns date, flow, pain, mood, sleep, libido, symptoms, note,
/// worded
/// with [labels]. The date stays an ISO date in every language. Several
/// symptoms are separated by `; `. The text starts with a byte order mark so
/// that spreadsheets read accented letters correctly, and lines end with
/// CRLF as the CSV standard (RFC 4180) asks.
///
/// This export is not encrypted: it is meant to be read.
String daysToCsv(
  Iterable<DayEntry> days, {
  CsvLabels labels = CsvLabels.english,
}) {
  final buffer = StringBuffer('\u{FEFF}')
    ..write(
      [
        labels.date,
        labels.flow,
        labels.pain,
        labels.mood,
        labels.sleep,
        labels.libido,
        labels.symptoms,
        labels.note,
      ].map(_quoted).join(','),
    )
    ..write('\r\n');
  for (final entry in days) {
    final flow = entry.flow;
    final pain = entry.pain;
    final mood = entry.mood;
    final sleep = entry.sleep;
    final libido = entry.libido;
    final symptoms = entry.symptoms.map(labels.symptomName).toList()..sort();
    buffer
      ..write(
        [
          '${entry.day}',
          flow == null ? '' : labels.flowName(flow),
          pain == null ? '' : labels.painName(pain),
          mood == null ? '' : labels.moodName(mood),
          sleep == null ? '' : labels.sleepName(sleep),
          libido == null ? '' : labels.libidoName(libido),
          symptoms.join('; '),
          _safeText(entry.note ?? ''),
        ].map(_quoted).join(','),
      )
      ..write('\r\n');
  }
  return buffer.toString();
}

/// A spreadsheet runs a cell that starts with one of these characters as a
/// formula. A leading apostrophe makes it plain text.
String _safeText(String text) =>
    text.startsWith(RegExp(r'[=+\-@\t\r]')) ? "'$text" : text;

String _quoted(String field) => field.contains(RegExp(r'[",\r\n]'))
    ? '"${field.replaceAll('"', '""')}"'
    : field;
