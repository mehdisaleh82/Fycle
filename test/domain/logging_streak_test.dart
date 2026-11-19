import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/logging_streak.dart';

void main() {
  final today = CalendarDay(2026, 3, 20);
  Set<CalendarDay> daysBack(Iterable<int> offsets) => {
    for (final offset in offsets) today.addDays(-offset),
  };

  test('nothing logged gives no streak', () {
    expect(loggingStreak({}, today), 0);
  });

  test('today alone counts for one', () {
    expect(loggingStreak(daysBack([0]), today), 1);
  });

  test('days in a row are counted back from today', () {
    expect(loggingStreak(daysBack([0, 1, 2, 3]), today), 4);
  });

  test('a day not logged yet does not break the run', () {
    expect(loggingStreak(daysBack([1, 2, 3]), today), 3);
  });

  test('a missed day ends the run', () {
    expect(loggingStreak(daysBack([0, 1, 3, 4, 5]), today), 2);
    expect(loggingStreak(daysBack([2, 3, 4]), today), 0);
  });

  test('the run crosses months and years', () {
    final newYear = CalendarDay(2026, 1, 1);
    final days = {for (var i = 0; i < 40; i++) newYear.addDays(-i)};
    expect(loggingStreak(days, newYear), 40);
  });

  test('days to come are ignored', () {
    expect(loggingStreak({today.addDays(1), today.addDays(2)}, today), 0);
  });
}
