// Measures the period prediction against published cycle lengths.
//
// Usage: dart run tool/backtest_prediction.dart <cycles.csv>
//
// The file is not part of the repository. It holds one line per cycle, in
// order for each woman: woman,age,cycle_length[,...], after a header line.
// Each cycle is predicted from the ones before it only, as the app would
// have done on the day the previous period started.
import 'dart:io';
import 'dart:math' as math;

import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/period_predictor.dart';
import 'package:fycle/domain/reference_cycle.dart';

/// Results gathered for the predictions made with a given number of cycles
/// already known.
class Tally {
  int count = 0;
  double absoluteError = 0;
  int within = 0;
  int withinTwoDays = 0;
  int width = 0;
  double lastCycleError = 0;
  double plainMeanError = 0;

  String line(String label) {
    String rate(int hits) => '${(100 * hits / count).toStringAsFixed(0)} %';
    String mean(num total) => (total / count).toStringAsFixed(2);
    return '${label.padRight(10)} ${'$count'.padLeft(5)}   '
        '${mean(absoluteError).padLeft(5)}   '
        '${rate(withinTwoDays).padLeft(5)}   '
        '${rate(within).padLeft(5)}   '
        '${mean(width).padLeft(5)}   '
        '${mean(lastCycleError).padLeft(5)}   '
        '${mean(plainMeanError).padLeft(5)}';
  }
}

String bucket(int known) => switch (known) {
  0 => '0',
  1 => '1',
  2 => '2',
  < 6 => '3 to 5',
  _ => '6 or more',
};

void main(List<String> arguments) {
  if (arguments.length != 1) {
    stderr.writeln('Usage: dart run tool/backtest_prediction.dart <file.csv>');
    exitCode = 64;
    return;
  }
  final cyclesOf = <String, List<int>>{};
  final ageOf = <String, int?>{};
  for (final line in File(arguments.single).readAsLinesSync().skip(1)) {
    final cells = line.split(',');
    if (cells.length < 3) {
      continue;
    }
    final length = int.tryParse(cells[2]);
    if (length == null) {
      continue;
    }
    cyclesOf.putIfAbsent(cells[0], () => []).add(length);
    ageOf[cells[0]] = int.tryParse(cells[1]);
  }

  const predictor = PeriodPredictor();
  final origin = CalendarDay(2000, 1, 1);
  final tallies = <String, Tally>{};
  final all = Tally();
  for (final MapEntry(key: woman, value: lengths) in cyclesOf.entries) {
    final reference = referenceCycleLengthForAge(ageOf[woman]);
    final starts = [origin];
    for (var i = 0; i < lengths.length; i++) {
      final prediction = predictor.predict(
        periodStarts: starts,
        referenceCycleLength: reference,
      )!;
      final actual = starts.last.addDays(lengths[i]);
      final centre = starts.last.addDays(prediction.estimatedCycleLength);
      final error = actual.daysSince(centre).abs();
      final past = lengths.sublist(0, i);
      final lastCycle = past.isEmpty ? reference : past.last;
      final plainMean = past.isEmpty
          ? reference.toDouble()
          : past.reduce((a, b) => a + b) / past.length;
      for (final tally in [all, tallies.putIfAbsent(bucket(i), Tally.new)]) {
        tally
          ..count += 1
          ..absoluteError += error
          ..withinTwoDays += error <= 2 ? 1 : 0
          ..within +=
              !actual.isBefore(prediction.earliestStart) &&
                  !actual.isAfter(prediction.latestStart)
              ? 1
              : 0
          ..width +=
              prediction.latestStart.daysSince(prediction.earliestStart) + 1
          ..lastCycleError += (lengths[i] - lastCycle).abs()
          ..plainMeanError += (lengths[i] - plainMean.round()).abs();
      }
      starts.add(actual);
    }
  }

  final total = cyclesOf.values.fold(0, (sum, list) => sum + list.length);
  final longest = cyclesOf.values.map((list) => list.length).reduce(math.max);
  stdout
    ..writeln(
      '${cyclesOf.length} women, $total cycles '
      '(up to $longest per woman)',
    )
    ..writeln(
      'known      count   error   <=2 d   in rng   width   last    mean',
    );
  for (final label in ['0', '1', '2', '3 to 5', '6 or more']) {
    final tally = tallies[label];
    if (tally != null) {
      stdout.writeln(tally.line(label));
    }
  }
  stdout
    ..writeln(all.line('all'))
    ..writeln()
    ..writeln('known: cycles of hers already logged when predicting.')
    ..writeln('error: mean days between the middle of the range and the day.')
    ..writeln('<=2 d: share of predictions whose middle is within 2 days.')
    ..writeln('in rng: share of periods that started inside the range.')
    ..writeln('width: mean number of days in the range.')
    ..writeln('last, mean: the same error when repeating her last cycle, or')
    ..writeln('  the plain mean of all her past cycles.');
}
