import '../domain/day_entry.dart';

/// Turns logged days into a CSV text that opens in any spreadsheet.
///
/// One line per day, columns `date, flow, pain, mood, symptoms, note`.
/// Several symptoms are separated by `; `. The text starts with a byte order
/// mark so that spreadsheets read accented letters correctly, and lines end
/// with CRLF as the CSV standard (RFC 4180) asks.
///
/// This export is not encrypted: it is meant to be read.
String daysToCsv(Iterable<DayEntry> days) {
  final buffer = StringBuffer('﻿')
    ..write('date,flow,pain,mood,symptoms,note\r\n');
  for (final entry in days) {
    final symptoms = [for (final symptom in entry.symptoms) symptom.name]
      ..sort();
    buffer
      ..write(
        [
          '${entry.day}',
          entry.flow?.name ?? '',
          entry.pain?.name ?? '',
          entry.mood?.name ?? '',
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
