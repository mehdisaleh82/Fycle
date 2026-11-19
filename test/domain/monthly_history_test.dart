import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/monthly_history.dart';
import 'package:fycle/domain/mood.dart';

void main() {
  final today = CalendarDay(2026, 3, 20);

  test('lists the last six months, most recent first, empty ones too', () {
    final history = monthlyHistory(days: const [], today: today);
    expect(
      [for (final month in history) (month.year, month.month)],
      [(2026, 3), (2026, 2), (2026, 1), (2025, 12), (2025, 11), (2025, 10)],
    );
    expect(history.every((month) => month.daysLogged == 0), isTrue);
    expect(history.every((month) => month.share == 0), isTrue);
  });

  test('counts the days logged and the period days of each month', () {
    final days = [
      for (var i = 0; i < 4; i++)
        DayEntry(
          day: CalendarDay(2026, 2, 27).addDays(i),
          flow: FlowIntensity.medium,
        ),
      DayEntry(day: CalendarDay(2026, 3, 10), mood: Mood.calm),
      DayEntry(day: CalendarDay(2026, 3, 11), flow: FlowIntensity.spotting),
    ];
    final history = monthlyHistory(days: days, today: today);
    // 27 and 28 February, then 1 and 2 March.
    expect(
      history[0],
      const MonthSummary(
        year: 2026,
        month: 3,
        daysCounted: 20,
        daysLogged: 4,
        periodDays: 2,
      ),
    );
    expect(
      history[1],
      const MonthSummary(
        year: 2026,
        month: 2,
        daysCounted: 28,
        daysLogged: 2,
        periodDays: 2,
      ),
    );
  });

  test('a past month counts all its days, the current one up to today', () {
    final history = monthlyHistory(days: const [], today: today);
    expect(history[0].daysCounted, 20);
    expect(history[1].daysCounted, 28);
    expect(history[2].daysCounted, 31);
    final leap = monthlyHistory(days: const [], today: CalendarDay(2028, 3, 1));
    expect(leap[0].daysCounted, 1);
    expect(leap[1].daysCounted, 29);
  });

  test('the share of a month is what was logged out of what could be', () {
    final days = [
      for (var day = 1; day <= 10; day++)
        DayEntry(day: CalendarDay(2026, 3, day), mood: Mood.calm),
    ];
    final history = monthlyHistory(days: days, today: today);
    expect(history[0].share, 0.5);
  });

  test('days after today and months outside the range are left out', () {
    final days = [
      DayEntry(day: CalendarDay(2026, 3, 25), mood: Mood.calm),
      DayEntry(day: CalendarDay(2025, 6, 1), mood: Mood.calm),
    ];
    final history = monthlyHistory(days: days, today: today);
    expect(history.every((month) => month.daysLogged == 0), isTrue);
  });

  test('the number of months can be chosen', () {
    expect(
      monthlyHistory(days: const [], today: today, months: 3),
      hasLength(3),
    );
  });
}
