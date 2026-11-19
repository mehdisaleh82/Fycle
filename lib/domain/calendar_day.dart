/// A day on the calendar, with no time of day and no time zone.
///
/// Two people in different time zones who both logged "3 March" hold the same
/// [CalendarDay]. Travelling never shifts a logged day.
final class CalendarDay implements Comparable<CalendarDay> {
  /// Creates a calendar day. Throws an [ArgumentError] if the date does not
  /// exist (for example 30 February).
  factory CalendarDay(int year, int month, int day) {
    final date = DateTime.utc(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      throw ArgumentError('Not a calendar date: $year-$month-$day');
    }
    return CalendarDay._(date);
  }

  /// Keeps the calendar date of [dateTime] as it reads, dropping the time of
  /// day and the time zone.
  factory CalendarDay.fromDateTime(DateTime dateTime) =>
      CalendarDay(dateTime.year, dateTime.month, dateTime.day);

  /// Reads an ISO 8601 date such as `2026-03-05`, the format produced by
  /// [toString]. Returns null if [text] is not such a date.
  static CalendarDay? tryParse(String text) {
    final match = _isoDate.firstMatch(text);
    if (match == null) {
      return null;
    }
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final date = DateTime.utc(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return CalendarDay._(date);
  }

  const CalendarDay._(this._utcMidnight);

  static final RegExp _isoDate = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  // UTC has no daylight saving time, so every day lasts exactly 24 hours and
  // day arithmetic is exact.
  final DateTime _utcMidnight;

  int get year => _utcMidnight.year;
  int get month => _utcMidnight.month;
  int get day => _utcMidnight.day;

  /// The day [days] after this one (before it if [days] is negative).
  CalendarDay addDays(int days) =>
      CalendarDay._(DateTime.utc(year, month, day + days));

  /// Number of days from [other] to this day. Negative if this day is earlier.
  int daysSince(CalendarDay other) =>
      _utcMidnight.difference(other._utcMidnight).inDays;

  bool isBefore(CalendarDay other) => compareTo(other) < 0;
  bool isAfter(CalendarDay other) => compareTo(other) > 0;

  @override
  int compareTo(CalendarDay other) =>
      _utcMidnight.compareTo(other._utcMidnight);

  @override
  bool operator ==(Object other) =>
      other is CalendarDay && other._utcMidnight == _utcMidnight;

  @override
  int get hashCode => _utcMidnight.hashCode;

  /// ISO 8601 date, for example `2026-03-05`.
  @override
  String toString() {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
