import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/cycle_history.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/period_end_estimate.dart';

/// Fictional history: periods 28 days apart, each lasting the given number
/// of days. The last one is the period going on.
List<LoggedCycle> cyclesWithPeriods(List<int> periodLengths) {
  final first = CalendarDay(2026, 1, 1);
  return cycleHistory({
    for (final (index, length) in periodLengths.indexed)
      for (var day = 0; day < length; day++)
        first.addDays(28 * index + day): FlowIntensity.medium,
  });
}

void main() {
  test('nothing is estimated before two past periods', () {
    expect(periodEndEstimate(dayOfPeriod: 1, cycles: const []), isNull);
    expect(
      periodEndEstimate(dayOfPeriod: 1, cycles: cyclesWithPeriods([5])),
      isNull,
    );
    expect(
      periodEndEstimate(dayOfPeriod: 1, cycles: cyclesWithPeriods([5, 1])),
      isNull,
    );
  });

  test('the range goes from her shortest to her longest past period', () {
    final estimate = periodEndEstimate(
      dayOfPeriod: 2,
      cycles: cyclesWithPeriods([4, 6, 5, 2]),
    )!;
    expect(estimate.earliestDaysLeft, 2);
    expect(estimate.latestDaysLeft, 4);
    expect(estimate.periodsUsed, 3);
  });

  test('today may be the last day once her shortest period is reached', () {
    final estimate = periodEndEstimate(
      dayOfPeriod: 5,
      cycles: cyclesWithPeriods([4, 6, 5]),
    )!;
    expect(estimate.earliestDaysLeft, 0);
    expect(estimate.latestDaysLeft, 1);
  });

  test('periods that always last the same give a single figure', () {
    final estimate = periodEndEstimate(
      dayOfPeriod: 5,
      cycles: cyclesWithPeriods([5, 5, 5]),
    )!;
    expect(estimate.earliestDaysLeft, 0);
    expect(estimate.latestDaysLeft, 0);
  });

  test('nothing is said once this period outlasts all the others', () {
    expect(
      periodEndEstimate(dayOfPeriod: 7, cycles: cyclesWithPeriods([4, 6, 7])),
      isNull,
    );
  });

  test('only the most recent periods count', () {
    final estimate = periodEndEstimate(
      dayOfPeriod: 1,
      cycles: cyclesWithPeriods([9, 4, 4, 4, 4, 4, 4, 1]),
    )!;
    expect(estimate.latestDaysLeft, 3);
    expect(estimate.periodsUsed, 6);
  });
}
