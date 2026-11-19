import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/csv_export.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/symptom.dart';

import 'fakes.dart';

void main() {
  test('with nothing logged, only the header line is written', () {
    expect(daysToCsv([]), '﻿date,flow,pain,mood,symptoms,note\r\n');
  });

  test('writes one line per day', () {
    final lines = daysToCsv(sampleData().days).split('\r\n');
    expect(lines, [
      '﻿date,flow,pain,mood,symptoms,note',
      '2026-03-05,medium,moderate,irritable,backPain; cramps,'
          '"Stayed home, ""slow"" day"',
      '2026-03-06,heavy,,,,',
      '2026-03-20,,,happy,,"Été, cœur léger"',
      '',
    ]);
  });

  test('uses the labels it is given, and sorts symptoms by label', () {
    final labels = CsvLabels(
      date: 'Jour',
      flow: 'Règles',
      pain: 'Douleur',
      mood: 'Humeur',
      symptoms: 'Symptômes, tous',
      note: 'Note',
      flowName: (flow) => 'F-${flow.name}',
      painName: (pain) => 'P-${pain.name}',
      moodName: (mood) => 'M-${mood.name}',
      symptomName: (symptom) =>
          symptom == Symptom.cramps ? 'Zz crampes' : 'Aa dos',
    );
    final lines = daysToCsv(
      sampleData().days.take(1),
      labels: labels,
    ).split('\r\n');
    expect(
      lines[0],
      '\u{FEFF}Jour,Règles,Douleur,Humeur,"Symptômes, tous",Note',
    );
    expect(
      lines[1],
      '2026-03-05,F-medium,P-moderate,M-irritable,Aa dos; Zz crampes,'
      '"Stayed home, ""slow"" day"',
    );
  });

  test('keeps a note with line breaks inside one quoted cell', () {
    final csv = daysToCsv([
      DayEntry(day: CalendarDay(2026, 3, 5), note: 'one\ntwo'),
    ]);
    expect(csv, endsWith('2026-03-05,,,,,"one\ntwo"\r\n'));
  });

  test('a note that looks like a formula is written as plain text', () {
    for (final note in ['=1+1', '+33 6 00', '-5', '@home']) {
      final csv = daysToCsv([
        DayEntry(day: CalendarDay(2026, 3, 5), note: note),
      ]);
      expect(csv, contains(",'$note"), reason: note);
    }
  });
}
