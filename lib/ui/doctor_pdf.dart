import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/calendar_day.dart';
import '../domain/cycle_change.dart';
import '../domain/cycle_history.dart';
import '../domain/day_entry.dart';
import '../domain/migraine.dart';
import '../l10n/app_localizations.dart';
import 'labels.dart';

/// How many cycles the report lists, the most recent first.
const int reportCyclesListed = 6;

/// The report for a consultation, as a PDF made on the phone: the dates and
/// lengths of the last cycles, their averages, what changed from one cycle
/// to the next and the migraines counted. It lists what was logged; it is
/// no diagnosis (CLAUDE.md, rule 7). Nothing is sent anywhere: the file is
/// handed to the user, who keeps or shows it.
Future<Uint8List> buildDoctorPdf(
  AppLocalizations l10n, {
  required CalendarDay today,
  required List<LoggedCycle> cycles,
  required List<DayEntry> days,
  required bool followsChanges,
  int? age,
}) {
  final complete = [
    for (final cycle in cycles)
      if (cycle.isPlausible) cycle,
  ];
  final listed = complete.reversed.take(reportCyclesListed).toList();
  final lengths = [for (final cycle in listed) cycle.length!];
  final periods = [for (final cycle in listed) cycle.periodLength];
  double mean(List<int> values) =>
      values.reduce((a, b) => a + b) / values.length;

  final change = cycleChangeOn(today, cycles: cycles, days: days);
  final migraines = migraineSummaryOn(today, days: days, cycles: cycles);

  pw.Widget title(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
    child: pw.Text(
      _plain(text),
      style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
    ),
  );
  pw.Widget line(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 3),
    child: pw.Text(_plain(text), style: const pw.TextStyle(fontSize: 10.5)),
  );

  final document = pw.Document();
  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        pw.Text(
          _plain(l10n.doctorReportTitle),
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        line(l10n.doctorReportIntro(mediumDate(l10n, today))),
        if (age != null) line(l10n.doctorReportAge(age)),
        title(l10n.pdfAveragesTitle),
        if (listed.isEmpty)
          line(l10n.pdfNoCycle)
        else ...[
          line(l10n.pdfBasis(listed.length)),
          line(l10n.pdfMeanCycle(dayCount(l10n, mean(lengths)))),
          line(
            l10n.pdfCycleRange(
              lengths.reduce((a, b) => a < b ? a : b),
              lengths.reduce((a, b) => a > b ? a : b),
            ),
          ),
          line(l10n.pdfMeanPeriod(dayCount(l10n, mean(periods)))),
        ],
        title(l10n.pdfCyclesTitle),
        if (cycles.isNotEmpty && !cycles.last.isComplete)
          line(l10n.historyCurrent(mediumDate(l10n, cycles.last.start))),
        for (final cycle in listed)
          line(
            l10n.pdfCycleLine(
              mediumDate(l10n, cycle.start),
              mediumDate(l10n, cycle.end!),
              cycle.length!,
              cycle.periodLength,
            ),
          ),
        if (followsChanges && !change.isEmpty) ...[
          title(l10n.changeTitle),
          if (change.cyclesCompared > 0)
            line(
              change.markedDifferences == 0
                  ? l10n.changeNoDifference(change.cyclesCompared + 1)
                  : l10n.changeDifferences(
                      change.markedDifferences,
                      change.cyclesCompared + 1,
                    ),
            ),
          if (change.longestInterval case final interval?)
            line(l10n.changeLongInterval(interval)),
          if (change.daysSinceLastPeriod case final since?)
            line(l10n.changeSinceLast(since)),
          if (change.signDays.isNotEmpty)
            line(
              l10n.changeSignsList(
                [
                  for (final sign in changeSigns)
                    if (change.signDays[sign] case final count?)
                      l10n.changeSignDays(symptomLabel(l10n, sign), count),
                ].join(l10n.listSeparator),
              ),
            ),
        ],
        if (migraines != null) ...[
          title(l10n.symptomMigraine),
          line(l10n.migraineSummaryDays(migraines.days)),
          line(l10n.migraineSummaryPeriod(migraines.duringPeriod)),
          if (migraines.withMedication > 0)
            line(l10n.migraineSummaryMedication(migraines.withMedication)),
          if (migraines.commonIntensity case final intensity?)
            line(l10n.migraineSummaryIntensity(painLabel(l10n, intensity))),
        ],
        pw.SizedBox(height: 18),
        pw.Text(
          _plain(l10n.pdfFooter),
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ],
    ),
  );
  return document.save();
}

/// The fonts built into every PDF reader cover Western European letters
/// only. Bundling a font would weigh megabytes; until the app is offered in
/// another script, the few characters outside that set are written with
/// their plain equivalent.
String _plain(String text) {
  const replacements = {
    '’': "'",
    '‘': "'",
    '“': '"',
    '”': '"',
    '–': '-',
    '—': '-',
    '…': '...',
    ' ': ' ',
    ' ': ' ',
    ' ': ' ',
    'œ': 'oe',
    'Œ': 'OE',
  };
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    final character = String.fromCharCode(rune);
    final replaced = replacements[character];
    if (replaced != null) {
      buffer.write(replaced);
    } else if (rune <= 0xFF) {
      buffer.write(character);
    } else {
      buffer.write('?');
    }
  }
  return buffer.toString();
}
