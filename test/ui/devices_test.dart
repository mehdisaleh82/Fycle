import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/device_readings.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

List<DayEntry> threePeriods() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28)),
];

void main() {
  Finder key(String name) => find.byKey(ValueKey(name));

  Future<void> openDevices(WidgetTester tester) async {
    await openReview(tester);
    await tester.scrollUntilVisible(
      key('open-devices'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tapVisible(tester, key('open-devices'));
  }

  testWidgets('her measures are read when she asks, and shown as averages', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    // Made-up nights since 3 January: the heart a little faster in the
    // second half of each cycle of 28 days.
    harness.health.deviceDays = [
      for (var i = 0; i <= 76; i++)
        DeviceDay(
          day: CalendarDay(2026, 1, 3).addDays(i),
          sleepMinutes: 435,
          restingHeartRate: i % 28 < 14 ? 58 : 62,
        ),
    ];
    await harness.pumpApp();
    await openDevices(tester);

    // Nothing is read before she asks.
    expect(key('devices-recent'), findsNothing);
    await tapVisible(tester, key('devices-read'));

    expect(find.text('7 h 15 min'), findsOneWidget);
    expect(find.text('Sleep, average of 30 days'), findsOneWidget);
    await tester.scrollUntilVisible(
      key('devices-note'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(
      find.text(
        'First half: 58 beats per minute · Second half: 62 beats per minute',
      ),
      findsOneWidget,
    );
    // No temperature was measured: it is not listed.
    expect(key('devices-halves-wristTemperature'), findsNothing);
    // The figures confirm nothing, and say so.
    expect(find.textContaining('neither an ovulation'), findsOneWidget);
  });

  testWidgets('a phone that offers nothing says so', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp(locale: 'fr');
    await openDevices(tester);
    await tapVisible(tester, key('devices-read'));
    expect(find.textContaining("Rien n'a pu être lu"), findsOneWidget);
    expect(key('devices-recent'), findsNothing);
  });

  testWidgets('a watch that recorded nothing says so', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    harness.health.deviceDays = [];
    await harness.pumpApp();
    await openDevices(tester);
    await tapVisible(tester, key('devices-read'));
    expect(find.textContaining('No measurement'), findsOneWidget);
  });
}
