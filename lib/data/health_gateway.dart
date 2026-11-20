import 'dart:io';

import 'package:flutter/services.dart';
import 'package:health/health.dart';

import '../domain/calendar_day.dart';
import '../domain/device_readings.dart';
import '../domain/flow_intensity.dart';

/// The health data of the phone (Apple Health), read on the phone itself.
/// Nothing is written there and nothing is sent anywhere: the days of
/// period she already noted elsewhere are read once, when she asks, and
/// copied into the journal (CLAUDE.md, rule 1).
abstract interface class HealthGateway {
  /// The days of period the phone knows, with how heavy each was. Null
  /// when the phone has no such data to offer or she did not allow it.
  Future<Map<CalendarDay, FlowIntensity>?> readPeriodDays({
    required DateTime now,
  });

  /// What a watch or a sensor measured over the last [deviceDaysBack]
  /// days: sleep, heart rate at rest, temperature at the wrist. Null when
  /// the phone has no such data to offer or she did not allow it.
  Future<List<DeviceDay>?> readDeviceDays({required DateTime now});
}

/// How far back the days are read.
const int healthYearsBack = 3;

/// How far back the measures of a watch are read: about four cycles.
const int deviceDaysBack = 120;

/// Apple Health, through the `health` package. On any other system, there
/// is nothing to read yet (Health Connect on Android is to come, rule 10).
final class SystemHealthGateway implements HealthGateway {
  const SystemHealthGateway();

  @override
  Future<Map<CalendarDay, FlowIntensity>?> readPeriodDays({
    required DateTime now,
  }) async {
    if (!Platform.isIOS) {
      return null;
    }
    try {
      final health = Health();
      await health.configure();
      const types = [HealthDataType.MENSTRUATION_FLOW];
      final allowed = await health.requestAuthorization(
        types,
        permissions: const [HealthDataAccess.READ],
      );
      if (!allowed) {
        return null;
      }
      final points = await health.getHealthDataFromTypes(
        types: types,
        startTime: DateTime(now.year - healthYearsBack, now.month, now.day),
        endTime: now,
      );
      final days = <CalendarDay, FlowIntensity>{};
      for (final point in points) {
        final value = point.value;
        if (value is! MenstruationFlowHealthValue) {
          continue;
        }
        final flow = switch (value.flow) {
          MenstrualFlow.light => FlowIntensity.light,
          // A day of period whose flow was not said is kept as medium.
          MenstrualFlow.medium ||
          MenstrualFlow.unspecified => FlowIntensity.medium,
          MenstrualFlow.heavy => FlowIntensity.heavy,
          MenstrualFlow.spotting => FlowIntensity.spotting,
          MenstrualFlow.none || null => null,
        };
        if (flow != null) {
          days[CalendarDay.fromDateTime(point.dateFrom)] = flow;
        }
      }
      return days;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    } on Exception {
      return null;
    }
  }

  @override
  Future<List<DeviceDay>?> readDeviceDays({required DateTime now}) async {
    if (!Platform.isIOS) {
      return null;
    }
    try {
      final health = Health();
      await health.configure();
      // A watch files a night under its stages; other sources under plain
      // "asleep". Both are counted.
      const sleep = [
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.SLEEP_LIGHT,
        HealthDataType.SLEEP_DEEP,
        HealthDataType.SLEEP_REM,
      ];
      const types = [
        ...sleep,
        HealthDataType.RESTING_HEART_RATE,
        HealthDataType.SLEEP_WRIST_TEMPERATURE,
      ];
      final allowed = await health.requestAuthorization(
        types,
        permissions: [for (final _ in types) HealthDataAccess.READ],
      );
      if (!allowed) {
        return null;
      }
      final points = await health.getHealthDataFromTypes(
        types: types,
        startTime: now.subtract(const Duration(days: deviceDaysBack)),
        endTime: now,
      );
      final minutes = <CalendarDay, int>{};
      final beats = <CalendarDay, List<double>>{};
      final degrees = <CalendarDay, List<double>>{};
      for (final point in points) {
        final value = point.value;
        if (value is! NumericHealthValue) {
          continue;
        }
        // A night belongs to the day she woke up on.
        final day = CalendarDay.fromDateTime(point.dateTo);
        final number = value.numericValue.toDouble();
        if (sleep.contains(point.type)) {
          final slept = point.dateTo.difference(point.dateFrom).inMinutes;
          minutes[day] = (minutes[day] ?? 0) + slept;
        } else if (point.type == HealthDataType.RESTING_HEART_RATE) {
          beats.putIfAbsent(day, () => []).add(number);
        } else if (point.type == HealthDataType.SLEEP_WRIST_TEMPERATURE) {
          degrees.putIfAbsent(day, () => []).add(number);
        }
      }
      double mean(List<double> values) =>
          values.reduce((a, b) => a + b) / values.length;
      final days = {...minutes.keys, ...beats.keys, ...degrees.keys}.toList()
        ..sort();
      return [
        for (final day in days)
          DeviceDay(
            day: day,
            sleepMinutes: minutes[day],
            restingHeartRate: beats[day] == null ? null : mean(beats[day]!),
            wristTemperature: degrees[day] == null ? null : mean(degrees[day]!),
          ),
      ];
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    } on Exception {
      return null;
    }
  }
}
