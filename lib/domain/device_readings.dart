import 'calendar_day.dart';
import 'cycle_history.dart';

/// What a watch or a sensor measured on one day, as the phone keeps it.
/// Read on the phone when she asks, shown, and not stored by the app
/// (CLAUDE.md, rule 1).
final class DeviceDay {
  const DeviceDay({
    required this.day,
    this.sleepMinutes,
    this.restingHeartRate,
    this.wristTemperature,
  });

  /// The day she woke up on, for a night.
  final CalendarDay day;

  /// Minutes asleep in the night that ended on [day].
  final int? sleepMinutes;

  /// Beats per minute at rest.
  final double? restingHeartRate;

  /// Temperature at the wrist during sleep, in degrees Celsius.
  final double? wristTemperature;
}

enum DeviceMeasure { sleep, restingHeartRate, wristTemperature }

double? _valueOf(DeviceDay day, DeviceMeasure measure) => switch (measure) {
  DeviceMeasure.sleep => day.sleepMinutes?.toDouble(),
  DeviceMeasure.restingHeartRate => day.restingHeartRate,
  DeviceMeasure.wristTemperature => day.wristTemperature,
};

/// The average of one measure over some days, and how many days it rests
/// on.
final class DeviceAverage {
  const DeviceAverage({
    required this.measure,
    required this.value,
    required this.days,
  });

  final DeviceMeasure measure;
  final double value;
  final int days;
}

/// How many days back the recent averages look.
const int deviceRecentDays = 30;

/// The average of each measure over the [deviceRecentDays] days up to
/// [today]. A measure with no value is left out.
List<DeviceAverage> recentDeviceAverages(
  CalendarDay today,
  Iterable<DeviceDay> days,
) {
  final from = today.addDays(-(deviceRecentDays - 1));
  final recent = [
    for (final day in days)
      if (!day.day.isBefore(from) && !day.day.isAfter(today)) day,
  ];
  return [
    for (final measure in DeviceMeasure.values) ?_average(recent, measure),
  ];
}

DeviceAverage? _average(Iterable<DeviceDay> days, DeviceMeasure measure) {
  final values = [for (final day in days) ?_valueOf(day, measure)];
  if (values.isEmpty) {
    return null;
  }
  return DeviceAverage(
    measure: measure,
    value: values.reduce((a, b) => a + b) / values.length,
    days: values.length,
  );
}

/// One measure, averaged over the first half and over the second half of
/// her complete cycles.
final class HalvesComparison {
  const HalvesComparison({
    required this.measure,
    required this.firstHalf,
    required this.secondHalf,
    required this.cycles,
  });

  final DeviceMeasure measure;
  final DeviceAverage firstHalf;
  final DeviceAverage secondHalf;

  /// Complete cycles that had measures.
  final int cycles;
}

/// Each half needs this many measured days before anything is compared.
const int minDeviceDaysPerHalf = 5;

/// Compares each measure between the two halves of her complete, plausible
/// cycles. The halves are cut by dates, in the middle of each cycle: no
/// ovulation is assumed, and none is deduced from the result. An average of
/// her own measures, shown as such (CLAUDE.md, rule 7).
List<HalvesComparison> compareCycleHalves({
  required List<LoggedCycle> cycles,
  required Iterable<DeviceDay> days,
}) {
  final first = <DeviceDay>[];
  final second = <DeviceDay>[];
  final withMeasures = <DeviceMeasure, Set<CalendarDay>>{};
  for (final cycle in cycles) {
    final length = cycle.length;
    if (length == null || !cycle.isPlausible) {
      continue;
    }
    for (final day in days) {
      final position = day.day.daysSince(cycle.start);
      if (position < 0 || position >= length) {
        continue;
      }
      (position * 2 < length ? first : second).add(day);
      for (final measure in DeviceMeasure.values) {
        if (_valueOf(day, measure) != null) {
          withMeasures.putIfAbsent(measure, () => {}).add(cycle.start);
        }
      }
    }
  }
  final result = <HalvesComparison>[];
  for (final measure in DeviceMeasure.values) {
    final a = _average(first, measure);
    final b = _average(second, measure);
    if (a == null ||
        b == null ||
        a.days < minDeviceDaysPerHalf ||
        b.days < minDeviceDaysPerHalf) {
      continue;
    }
    result.add(
      HalvesComparison(
        measure: measure,
        firstHalf: a,
        secondHalf: b,
        cycles: withMeasures[measure]!.length,
      ),
    );
  }
  return result;
}
