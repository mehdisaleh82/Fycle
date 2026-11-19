import 'calendar_day.dart';
import 'period_prediction.dart';

/// A time of day as a clock shows it, with no date and no time zone.
final class ClockTime implements Comparable<ClockTime> {
  /// Throws an [ArgumentError] if the time does not exist (for example 24:00).
  ClockTime(this.hour, this.minute) {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw ArgumentError('Not a time of day: $hour:$minute');
    }
  }

  /// The time [minutes] after midnight, or null outside of a day.
  static ClockTime? tryFromMinutes(int? minutes) {
    if (minutes == null || minutes < 0 || minutes >= 24 * 60) {
      return null;
    }
    return ClockTime(minutes ~/ 60, minutes % 60);
  }

  final int hour;
  final int minute;

  int get minutesSinceMidnight => hour * 60 + minute;

  @override
  int compareTo(ClockTime other) =>
      minutesSinceMidnight.compareTo(other.minutesSinceMidnight);

  @override
  bool operator ==(Object other) =>
      other is ClockTime && other.minutesSinceMidnight == minutesSinceMidnight;

  @override
  int get hashCode => minutesSinceMidnight.hashCode;

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// What the user chose for her reminders. Everything is off by default.
final class ReminderSettings {
  ReminderSettings({
    this.periodEnabled = false,
    this.periodDaysBefore = defaultPeriodDaysBefore,
    ClockTime? periodTime,
    this.dailyEnabled = false,
    ClockTime? dailyTime,
  }) : periodTime = periodTime ?? ClockTime(9, 0),
       dailyTime = dailyTime ?? ClockTime(20, 0) {
    if (!periodDaysBeforeChoices.contains(periodDaysBefore)) {
      throw ArgumentError.value(periodDaysBefore, 'periodDaysBefore');
    }
  }

  static const int defaultPeriodDaysBefore = 2;

  /// How many days before the estimated range the reminder may come.
  static const List<int> periodDaysBeforeChoices = [1, 2, 3];

  /// "Period approaching" reminder.
  final bool periodEnabled;

  /// Days between that reminder and the first day of the estimated range.
  final int periodDaysBefore;
  final ClockTime periodTime;

  /// Daily reminder to log the day.
  final bool dailyEnabled;
  final ClockTime dailyTime;

  bool get anyEnabled => periodEnabled || dailyEnabled;

  ReminderSettings copyWith({
    bool? periodEnabled,
    int? periodDaysBefore,
    ClockTime? periodTime,
    bool? dailyEnabled,
    ClockTime? dailyTime,
  }) => ReminderSettings(
    periodEnabled: periodEnabled ?? this.periodEnabled,
    periodDaysBefore: periodDaysBefore ?? this.periodDaysBefore,
    periodTime: periodTime ?? this.periodTime,
    dailyEnabled: dailyEnabled ?? this.dailyEnabled,
    dailyTime: dailyTime ?? this.dailyTime,
  );

  @override
  bool operator ==(Object other) =>
      other is ReminderSettings &&
      other.periodEnabled == periodEnabled &&
      other.periodDaysBefore == periodDaysBefore &&
      other.periodTime == periodTime &&
      other.dailyEnabled == dailyEnabled &&
      other.dailyTime == dailyTime;

  @override
  int get hashCode => Object.hash(
    periodEnabled,
    periodDaysBefore,
    periodTime,
    dailyEnabled,
    dailyTime,
  );
}

enum ReminderKind { periodApproaching, dailyEntry }

/// One reminder to schedule: a calendar day and a time on the clock of the
/// phone. Turning it into an actual instant is left to the caller.
final class PlannedReminder {
  const PlannedReminder({
    required this.kind,
    required this.day,
    required this.time,
  });

  final ReminderKind kind;
  final CalendarDay day;
  final ClockTime time;

  @override
  bool operator ==(Object other) =>
      other is PlannedReminder &&
      other.kind == kind &&
      other.day == day &&
      other.time == time;

  @override
  int get hashCode => Object.hash(kind, day, time);

  @override
  String toString() => 'PlannedReminder(${kind.name}, $day $time)';
}

/// How many days ahead the daily reminder is scheduled. Each day is its own
/// reminder, so that a day already logged can be skipped and a change of
/// clock (daylight saving time, travel) is picked up at the next planning.
/// Without any visit to the app for that long, the reminder goes quiet.
const int dailyReminderHorizonDays = 14;

/// The reminders that should be pending right now, in chronological order.
///
/// Called again after every entry and every time the app comes to the front:
/// the result replaces whatever was scheduled before. Nothing is ever planned
/// in the past: a reminder whose moment has gone by is dropped, not sent late.
List<PlannedReminder> planReminders({
  required ReminderSettings settings,
  required CalendarDay today,
  required ClockTime now,
  PeriodPrediction? prediction,
  Set<CalendarDay> loggedDays = const {},
}) {
  bool isFuture(CalendarDay day, ClockTime time) =>
      day.isAfter(today) || (day == today && time.compareTo(now) > 0);

  final planned = <PlannedReminder>[];

  if (settings.periodEnabled && prediction != null) {
    final day = prediction.earliestStart.addDays(-settings.periodDaysBefore);
    if (isFuture(day, settings.periodTime)) {
      planned.add(
        PlannedReminder(
          kind: ReminderKind.periodApproaching,
          day: day,
          time: settings.periodTime,
        ),
      );
    }
  }

  if (settings.dailyEnabled) {
    for (var i = 0; i < dailyReminderHorizonDays; i++) {
      final day = today.addDays(i);
      if (!loggedDays.contains(day) && isFuture(day, settings.dailyTime)) {
        planned.add(
          PlannedReminder(
            kind: ReminderKind.dailyEntry,
            day: day,
            time: settings.dailyTime,
          ),
        );
      }
    }
  }

  planned.sort((a, b) {
    final byDay = a.day.compareTo(b.day);
    return byDay != 0 ? byDay : a.time.compareTo(b.time);
  });
  return planned;
}
