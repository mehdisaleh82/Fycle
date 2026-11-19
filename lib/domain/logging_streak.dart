import 'calendar_day.dart';

/// How many days in a row something was logged, counting back from [today].
///
/// A day that is not logged yet does not break the run: until it is over, the
/// count goes back from the day before. The result is 0 when neither [today]
/// nor the day before is logged.
///
/// This is a plain count, shown discreetly. Nothing is awarded for a long
/// run and nothing is said when it stops.
int loggingStreak(Set<CalendarDay> loggedDays, CalendarDay today) {
  var day = loggedDays.contains(today) ? today : today.addDays(-1);
  var count = 0;
  while (loggedDays.contains(day)) {
    count++;
    day = day.addDays(-1);
  }
  return count;
}

/// Below this many days in a row, the count is not worth showing.
const int minStreakShown = 2;
