import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/cycle_history.dart';
import 'package:fycle/domain/device_readings.dart';
import 'package:fycle/domain/flow_intensity.dart';

void main() {
  // Periods on 1 Jan, 29 Jan and 26 Feb: two complete cycles of 28 days.
  final starts = [
    CalendarDay(2026, 1, 1),
    CalendarDay(2026, 1, 29),
    CalendarDay(2026, 2, 26),
  ];
  final cycles = cycleHistory({
    for (final start in starts)
      for (var i = 0; i < 4; i++) start.addDays(i): FlowIntensity.medium,
  });

  /// A made-up night for every day of the two complete cycles: the heart
  /// a little faster in the second half.
  List<DeviceDay> nights() => [
    for (final start in starts.take(2))
      for (var i = 0; i < 28; i++)
        DeviceDay(
          day: start.addDays(i),
          sleepMinutes: 420,
          restingHeartRate: i < 14 ? 58 : 62,
        ),
  ];

  test('each half of her cycles is averaged on its own', () {
    final halves = compareCycleHalves(cycles: cycles, days: nights());
    expect(halves.map((half) => half.measure), [
      DeviceMeasure.sleep,
      DeviceMeasure.restingHeartRate,
    ]);
    final heart = halves.last;
    expect(heart.firstHalf.value, 58);
    expect(heart.secondHalf.value, 62);
    expect(heart.firstHalf.days, 28);
    expect(heart.cycles, 2);
  });

  test('too few measured days in a half, and nothing is compared', () {
    final few = [
      for (var i = 0; i < 4; i++)
        DeviceDay(day: starts[0].addDays(i), restingHeartRate: 58),
      for (var i = 14; i < 28; i++)
        DeviceDay(day: starts[0].addDays(i), restingHeartRate: 62),
    ];
    expect(compareCycleHalves(cycles: cycles, days: few), isEmpty);
  });

  test('the cycle going on is left out: its middle is not known', () {
    final current = [
      for (var i = 0; i < 20; i++)
        DeviceDay(day: starts[2].addDays(i), restingHeartRate: 60),
    ];
    expect(compareCycleHalves(cycles: cycles, days: current), isEmpty);
  });

  test('the recent averages look at the last thirty days only', () {
    final today = CalendarDay(2026, 3, 20);
    final averages = recentDeviceAverages(today, [
      DeviceDay(day: today, sleepMinutes: 400, wristTemperature: 36.4),
      DeviceDay(day: today.addDays(-29), sleepMinutes: 440),
      // Too old, and tomorrow: neither counts.
      DeviceDay(day: today.addDays(-30), sleepMinutes: 100),
      DeviceDay(day: today.addDays(1), sleepMinutes: 100),
    ]);
    expect(averages.map((average) => average.measure), [
      DeviceMeasure.sleep,
      DeviceMeasure.wristTemperature,
    ]);
    expect(averages.first.value, 420);
    expect(averages.first.days, 2);
    expect(averages.last.value, 36.4);
    expect(recentDeviceAverages(today, const []), isEmpty);
  });

  test('a night counts for the day she wakes up on', () {
    expect(nightOf(DateTime(2026, 3, 19, 22, 30)), CalendarDay(2026, 3, 20));
    expect(nightOf(DateTime(2026, 3, 20, 2)), CalendarDay(2026, 3, 20));
    // A nap in the afternoon stays on its day.
    expect(nightOf(DateTime(2026, 3, 20, 14)), CalendarDay(2026, 3, 20));
  });

  test('two sources recording the same night are not added up', () {
    final watch = [
      (from: DateTime(2026, 3, 19, 23), to: DateTime(2026, 3, 20, 3)),
      (from: DateTime(2026, 3, 20, 3), to: DateTime(2026, 3, 20, 7)),
    ];
    expect(sleepMinutesOf(watch), 480);
    final ring = (
      from: DateTime(2026, 3, 19, 23, 30),
      to: DateTime(2026, 3, 20, 7, 15),
    );
    expect(sleepMinutesOf([...watch, ring]), 495);
    expect(sleepMinutesOf(const []), 0);
  });
}
