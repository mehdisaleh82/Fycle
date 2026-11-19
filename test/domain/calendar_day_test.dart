import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';

void main() {
  group('CalendarDay', () {
    test('exposes year, month and day', () {
      final day = CalendarDay(2026, 3, 5);
      expect(day.year, 2026);
      expect(day.month, 3);
      expect(day.day, 5);
    });

    test('rejects dates that do not exist', () {
      expect(() => CalendarDay(2026, 2, 30), throwsArgumentError);
      expect(() => CalendarDay(2026, 13, 1), throwsArgumentError);
      expect(() => CalendarDay(2026, 4, 0), throwsArgumentError);
      expect(() => CalendarDay(2025, 2, 29), throwsArgumentError);
    });

    test('accepts 29 February in a leap year', () {
      expect(CalendarDay(2028, 2, 29).day, 29);
    });

    test('adds days across months, years and leap days', () {
      expect(CalendarDay(2026, 1, 31).addDays(1), CalendarDay(2026, 2, 1));
      expect(CalendarDay(2026, 12, 31).addDays(1), CalendarDay(2027, 1, 1));
      expect(CalendarDay(2028, 2, 28).addDays(1), CalendarDay(2028, 2, 29));
      expect(CalendarDay(2026, 3, 1).addDays(-1), CalendarDay(2026, 2, 28));
      expect(CalendarDay(2026, 1, 1).addDays(365), CalendarDay(2027, 1, 1));
    });

    test('counts days between two days', () {
      final start = CalendarDay(2026, 1, 10);
      expect(CalendarDay(2026, 2, 7).daysSince(start), 28);
      expect(start.daysSince(CalendarDay(2026, 2, 7)), -28);
      expect(start.daysSince(start), 0);
      // Spans a daylight saving change in many time zones.
      expect(CalendarDay(2026, 4, 1).daysSince(CalendarDay(2026, 3, 1)), 31);
    });

    test('compares and sorts chronologically', () {
      final early = CalendarDay(2026, 1, 10);
      final late = CalendarDay(2026, 2, 1);
      expect(early.isBefore(late), isTrue);
      expect(late.isAfter(early), isTrue);
      expect(early.isBefore(early), isFalse);
      expect([late, early]..sort(), [early, late]);
    });

    test('equal days are equal and share a hash code', () {
      final a = CalendarDay(2026, 5, 20);
      final b = CalendarDay(2026, 5, 20);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect({a, b}, hasLength(1));
    });

    test('ignores time of day and time zone of a DateTime', () {
      final lateEvening = DateTime(2026, 5, 20, 23, 59);
      final utcMorning = DateTime.utc(2026, 5, 20, 0, 1);
      expect(CalendarDay.fromDateTime(lateEvening), CalendarDay(2026, 5, 20));
      expect(CalendarDay.fromDateTime(utcMorning), CalendarDay(2026, 5, 20));
    });

    test('prints as an ISO date', () {
      expect(CalendarDay(2026, 3, 5).toString(), '2026-03-05');
    });
    test('reads back its own ISO format', () {
      expect(CalendarDay.tryParse('2026-03-05'), CalendarDay(2026, 3, 5));
      final day = CalendarDay(2024, 2, 29);
      expect(CalendarDay.tryParse(day.toString()), day);
    });

    test('refuses text that is not an existing ISO date', () {
      expect(CalendarDay.tryParse('2026-02-30'), isNull);
      expect(CalendarDay.tryParse('2026-3-5'), isNull);
      expect(CalendarDay.tryParse('05/03/2026'), isNull);
      expect(CalendarDay.tryParse('2026-03-05T10:00:00'), isNull);
      expect(CalendarDay.tryParse(''), isNull);
    });
  });
}
