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
    // A watch files a night under its stages; other sources under plain
    // "asleep". Both are read.
    const sleep = [
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_LIGHT,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_REM,
    ];
    const base = [...sleep, HealthDataType.RESTING_HEART_RATE];
    // Not known to older systems: asked for apart, so that it never takes
    // the rest down with it.
    const temperature = HealthDataType.SLEEP_WRIST_TEMPERATURE;
    try {
      final health = Health();
      await health.configure();
      Future<bool> allow(List<HealthDataType> types) =>
          health.requestAuthorization(
            types,
            permissions: [for (final _ in types) HealthDataAccess.READ],
          );
      bool allowed;
      try {
        allowed = await allow(const [...base, temperature]);
      } on Exception {
        allowed = await allow(base);
      }
      if (!allowed) {
        return null;
      }
      final from = now.subtract(const Duration(days: deviceDaysBack));
      Future<List<HealthDataPoint>> read(HealthDataType type) async {
        try {
          return await health.getHealthDataFromTypes(
            types: [type],
            startTime: from,
            endTime: now,
          );
        } on Exception {
          return const [];
        }
      }

      final stretches = <CalendarDay, List<({DateTime from, DateTime to})>>{};
      for (final type in sleep) {
        for (final point in await read(type)) {
          stretches.putIfAbsent(nightOf(point.dateFrom), () => []).add((
            from: point.dateFrom,
            to: point.dateTo,
          ));
        }
      }
      Future<Map<CalendarDay, List<double>>> numbers(
        HealthDataType type, {
        required bool night,
      }) async {
        final found = <CalendarDay, List<double>>{};
        for (final point in await read(type)) {
          final value = point.value;
          if (value is NumericHealthValue) {
            final day = night
                ? nightOf(point.dateFrom)
                : CalendarDay.fromDateTime(point.dateFrom);
            found.putIfAbsent(day, () => []).add(value.numericValue.toDouble());
          }
        }
        return found;
      }

      final beats = await numbers(
        HealthDataType.RESTING_HEART_RATE,
        night: false,
      );
      final degrees = await numbers(temperature, night: true);
      double mean(List<double> values) =>
          values.reduce((a, b) => a + b) / values.length;
      final days = {...stretches.keys, ...beats.keys, ...degrees.keys}.toList()
        ..sort();
      return [
        for (final day in days)
          DeviceDay(
            day: day,
            sleepMinutes: stretches[day] == null
                ? null
                : sleepMinutesOf(stretches[day]!),
            restingHeartRate: beats[day] == null ? null : mean(beats[day]!),
            wristTemperature: degrees[day] == null ? null : mean(degrees[day]!),
          ),
      ];
    } on Exception {
      return null;
    }
  }
}
