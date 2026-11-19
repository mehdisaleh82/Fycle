import 'calendar_day.dart';
import 'flow_intensity.dart';

/// A flow day starts a new period when at least this many days without flow
/// come before it. A shorter pause is treated as a break inside one period.
const int minFlowFreeDaysBetweenPeriods = 7;

/// Finds the first day of each period in a day-by-day flow log.
///
/// Days absent from [flowByDay] are days without flow. Spotting is ignored:
/// it neither starts a period nor belongs to one for this purpose.
///
/// Returns the start days in chronological order.
List<CalendarDay> periodStartsFrom(Map<CalendarDay, FlowIntensity> flowByDay) {
  final flowDays = [
    for (final entry in flowByDay.entries)
      if (entry.value != FlowIntensity.spotting) entry.key,
  ]..sort();

  final starts = <CalendarDay>[];
  CalendarDay? previous;
  for (final day in flowDays) {
    if (previous == null ||
        day.daysSince(previous) > minFlowFreeDaysBetweenPeriods) {
      starts.add(day);
    }
    previous = day;
  }
  return starts;
}
