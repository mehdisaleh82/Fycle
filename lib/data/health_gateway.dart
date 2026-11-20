import 'dart:io';

import 'package:flutter/services.dart';
import 'package:health/health.dart';

import '../domain/calendar_day.dart';
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
}

/// How far back the days are read.
const int healthYearsBack = 3;

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
}
