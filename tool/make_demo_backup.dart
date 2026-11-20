// Writes a backup file filled with made-up data, to see how the app looks
// after more than a year of use. Nothing in it comes from a real person.
//
// Run from the root of the project:
//
//     dart run tool/make_demo_backup.dart test/fixtures/demo-one-year.fycle
//
// The file is read back before the script ends. Its password is the one
// below: it protects nothing but invented days.
import 'dart:io';
import 'dart:math';

import 'package:fycle/data/backup_codec.dart';
import 'package:fycle/data/fycle_data.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/libido_level.dart';
import 'package:fycle/domain/mood.dart';
import 'package:fycle/domain/pain_level.dart';
import 'package:fycle/domain/sleep_quality.dart';
import 'package:fycle/domain/start_profile.dart';
import 'package:fycle/domain/symptom.dart';

const String demoPassword = 'demo-fycle-2026';

/// The day the story is told from, and the first day of the last period.
final CalendarDay today = CalendarDay(2026, 11, 20);
final CalendarDay lastStart = CalendarDay(2026, 11, 8);

/// Lengths of the complete cycles, oldest first: steady at first, then
/// three cycles that differ from the one before by a week or more.
const List<int> cycleLengths = [
  28, 29, 27, 28, 30, 28, 27, 29, 36, 27, 28, 35, 29, 28, //
];

/// How long the period of each cycle lasts, the current one last.
const List<int> periodLengths = [5, 4, 5, 5, 4, 5, 6, 5, 4, 6, 5, 5, 4, 5, 5];

/// The signs of a changing cycle appear from this cycle on.
const int signsFromCycle = 8;

void main(List<String> arguments) async {
  final path = arguments.isEmpty
      ? 'test/fixtures/demo-one-year.fycle'
      : arguments.first;
  final random = Random(2026);
  bool chance(double probability) => random.nextDouble() < probability;
  T pick<T>(List<T> values) => values[random.nextInt(values.length)];

  final days = <CalendarDay, DayEntry>{};
  var start = lastStart.addDays(-cycleLengths.reduce((a, b) => a + b));
  for (var cycle = 0; cycle <= cycleLengths.length; cycle++) {
    final current = cycle == cycleLengths.length;
    final length = current ? today.daysSince(start) + 1 : cycleLengths[cycle];
    // Where the cycle is expected to end, to place what comes before it.
    final expected = current ? 28 : length;
    final period = periodLengths[cycle];
    for (var i = 0; i < length; i++) {
      final day = start.addDays(i);
      final toEnd = expected - i;
      FlowIntensity? flow;
      PainLevel? pain;
      Mood? mood;
      SleepQuality? sleep;
      LibidoLevel? libido;
      final symptoms = <Symptom>{};
      String? note;

      if (i < period) {
        flow = switch (i) {
          0 => FlowIntensity.medium,
          1 => FlowIntensity.heavy,
          2 => FlowIntensity.medium,
          _ => FlowIntensity.light,
        };
        pain = switch (i) {
          0 => PainLevel.moderate,
          1 => chance(0.5) ? PainLevel.moderate : PainLevel.mild,
          2 => PainLevel.mild,
          _ => PainLevel.none,
        };
        if (i < 2) {
          symptoms.add(Symptom.cramps);
        }
        if (i == 1 && chance(0.6)) {
          symptoms.add(Symptom.fatigue);
        }
        if (i == 0 && chance(0.4)) {
          symptoms.add(Symptom.backPain);
        }
        mood = i < 2 ? pick([Mood.sad, Mood.calm, Mood.irritable]) : Mood.calm;
        sleep = i == 0 ? SleepQuality.fair : pick(SleepQuality.values);
      } else if (!current && toEnd <= 3) {
        // The days before the next period: what comes back each cycle.
        symptoms.add(Symptom.bloating);
        if (toEnd <= 2) {
          symptoms.add(Symptom.breastTenderness);
        }
        if (chance(0.5)) {
          symptoms.add(Symptom.cravings);
        }
        mood = toEnd == 1
            ? Mood.irritable
            : pick([Mood.irritable, Mood.anxious]);
        sleep = toEnd == 2 ? SleepQuality.poor : SleepQuality.fair;
        pain = toEnd == 1 ? PainLevel.mild : null;
      } else if ((toEnd - 14).abs() <= 1) {
        // Around the middle of the cycle.
        libido = LibidoLevel.high;
        mood = Mood.happy;
        sleep = SleepQuality.good;
      } else if (chance(0.45)) {
        mood = pick([Mood.calm, Mood.happy, Mood.calm, Mood.anxious]);
        sleep = pick([SleepQuality.good, SleepQuality.good, SleepQuality.fair]);
        if (chance(0.3)) {
          libido = pick(LibidoLevel.values);
        }
        if (chance(0.1)) {
          symptoms.add(Symptom.headache);
        }
      }

      if (cycle >= signsFromCycle && i >= period) {
        if (chance(0.12)) {
          symptoms.add(Symptom.hotFlashes);
        }
        if (chance(0.07)) {
          symptoms.add(Symptom.nightSweats);
          sleep = SleepQuality.poor;
        }
      }
      if (i == 1 && cycle % 5 == 2) {
        note = 'Made-up note: a long day, early night.';
      }

      final entry = DayEntry(
        day: day,
        flow: flow,
        pain: pain,
        mood: mood,
        sleep: sleep,
        libido: libido,
        symptoms: symptoms,
        note: note,
      );
      if (!entry.isEmpty) {
        days[day] = entry;
      }
    }
    start = start.addDays(length);
  }

  final sorted = days.values.toList()..sort((a, b) => a.day.compareTo(b.day));
  final data = FycleData(
    birthYear: 1984,
    usualPeriodLength: 5,
    regularity: CycleRegularity.unknown,
    days: sorted,
  );
  const codec = BackupCodec();
  final bytes = await codec.encode(data, demoPassword);
  final file = File(path)..createSync(recursive: true);
  file.writeAsBytesSync(bytes);

  // Read back, as the app will.
  final read = await codec.decode(file.readAsBytesSync(), demoPassword);
  if (read.days.length != sorted.length || read.birthYear != 1984) {
    stderr.writeln('The file does not read back as written.');
    exit(1);
  }
  stdout.writeln(
    '$path: ${read.days.length} days from ${read.days.first.day} to '
    '${read.days.last.day}, ${cycleLengths.length} complete cycles, '
    '${bytes.length} bytes.',
  );
}
