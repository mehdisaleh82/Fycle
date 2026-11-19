import 'calendar_day.dart';
import 'day_entry.dart';
import 'flow_intensity.dart';

/// What was logged in one calendar month.
final class MonthSummary {
  const MonthSummary({
    required this.year,
    required this.month,
    required this.daysCounted,
    required this.daysLogged,
    required this.periodDays,
  });

  final int year;
  final int month;

  /// Days of the month that could be logged: all of them for a past month,
  /// the days up to today for the current one.
  final int daysCounted;

  /// Days with anything logged.
  final int daysLogged;

  /// Days with flow, spotting left out.
  final int periodDays;

  /// Share of the countable days that were logged, from 0 to 1.
  double get share => daysCounted == 0 ? 0 : daysLogged / daysCounted;

  @override
  bool operator ==(Object other) =>
      other is MonthSummary &&
      other.year == year &&
      other.month == month &&
      other.daysCounted == daysCounted &&
      other.daysLogged == daysLogged &&
      other.periodDays == periodDays;

  @override
  int get hashCode =>
      Object.hash(year, month, daysCounted, daysLogged, periodDays);

  @override
  String toString() =>
      'MonthSummary($year-$month, $daysLogged of $daysCounted logged, '
      '$periodDays period)';
}

/// How many months the history shows by default.
const int monthsOfHistoryShown = 6;

/// The last [months] calendar months up to [today], most recent first, each
/// with what was logged in it. A month with nothing logged is listed too:
/// the gaps are part of the picture.
List<MonthSummary> monthlyHistory({
  required Iterable<DayEntry> days,
  required CalendarDay today,
  int months = monthsOfHistoryShown,
}) {
  final logged = <(int, int), int>{};
  final period = <(int, int), int>{};
  for (final entry in days) {
    if (entry.day.isAfter(today)) {
      continue;
    }
    final key = (entry.day.year, entry.day.month);
    logged[key] = (logged[key] ?? 0) + 1;
    final flow = entry.flow;
    if (flow != null && flow != FlowIntensity.spotting) {
      period[key] = (period[key] ?? 0) + 1;
    }
  }

  final result = <MonthSummary>[];
  for (var back = 0; back < months; back++) {
    // DateTime normalises a month below 1 into the year before.
    final first = DateTime.utc(today.year, today.month - back);
    final key = (first.year, first.month);
    final daysInMonth = DateTime.utc(first.year, first.month + 1, 0).day;
    result.add(
      MonthSummary(
        year: first.year,
        month: first.month,
        daysCounted: back == 0 ? today.day : daysInMonth,
        daysLogged: logged[key] ?? 0,
        periodDays: period[key] ?? 0,
      ),
    );
  }
  return result;
}
