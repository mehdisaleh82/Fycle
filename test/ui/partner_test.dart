import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/file_gateway.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/life_stage.dart';
import 'package:fycle/domain/partner_snapshot.dart';
import 'package:material_ui/material_ui.dart';

import '../data/fakes.dart';
import 'harness.dart';

/// Three periods, 28 days apart, the last one on 28 February 2026.
List<DayEntry> threePeriods() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28)),
];

const String password = 'made-up password';

void main() {
  Finder key(String name) => find.byKey(ValueKey(name));
  Future<void> tap(WidgetTester tester, String name) =>
      tapVisible(tester, key(name));

  group('the snapshot', () {
    final snapshot = PartnerSnapshot(
      madeOn: CalendarDay(2026, 3, 20),
      name: 'Lina',
      profile: Profile.tracking,
      cycleStart: CalendarDay(2026, 2, 28),
      periodLength: 4,
      earliestNext: CalendarDay(2026, 3, 25),
      latestNext: CalendarDay(2026, 3, 31),
      fertileFrom: CalendarDay(2026, 3, 5),
      fertileTo: CalendarDay(2026, 3, 22),
    );

    test('reads back as it was written', () {
      final read = PartnerSnapshot.fromJson(
        jsonDecode(jsonEncode(snapshot.toJson())),
      );
      expect(read.name, 'Lina');
      expect(read.profile, Profile.tracking);
      expect(read.cycleStart, snapshot.cycleStart);
      expect(read.periodLength, 4);
      expect(read.earliestNext, snapshot.earliestNext);
      expect(read.latestNext, snapshot.latestNext);
      expect(read.fertileTo, snapshot.fertileTo);
    });

    test('is not a backup file, and a backup file is not one', () {
      expect(
        () => PartnerSnapshot.fromJson({'content': 1, 'days': <Object>[]}),
        throwsFormatException,
      );
    });

    test('is read on the day it is looked at', () {
      final during = partnerStatusOn(CalendarDay(2026, 3, 1), snapshot);
      expect(during.moment, PartnerMoment.periodOngoing);
      expect(during.dayOfCycle, 2);

      final before = partnerStatusOn(CalendarDay(2026, 3, 20), snapshot);
      expect(before.moment, PartnerMoment.beforePeriod);
      expect(before.dayOfCycle, 21);
      expect((before.daysUntilEarliest, before.daysUntilLatest), (5, 11));
      expect(before.inFertileWindow, isTrue);

      expect(
        partnerStatusOn(CalendarDay(2026, 3, 27), snapshot).moment,
        PartnerMoment.periodExpected,
      );
      // Past its range, it says nothing more.
      expect(
        partnerStatusOn(CalendarDay(2026, 4, 1), snapshot).moment,
        PartnerMoment.outdated,
      );
    });
  });

  testWidgets('she makes a file with what she chooses to share', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    await tapVisible(tester, find.byIcon(Icons.settings_outlined));
    await tap(tester, 'partner-share');
    // The fertile window is not shared unless she says so.
    expect(
      tester.widget<SwitchListTile>(key('partner-share-fertility')).value,
      isFalse,
    );
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), password);
    await tester.enterText(fields.at(1), password);
    await tap(tester, 'partner-create');
    expect(find.text('File created'), findsOneWidget);
    await tapVisible(tester, find.text('OK'));

    final name = harness.files.saved.keys.single;
    expect(name, 'fycle-partner-2026-03-20.fycle');
    final text = await tester.runAsync(
      () => fastCodec.decodeText(harness.files.saved[name]!, password),
    );
    final snapshot = PartnerSnapshot.fromJson(jsonDecode(text!));
    expect(snapshot.cycleStart, CalendarDay(2026, 2, 28));
    expect(snapshot.earliestNext, CalendarDay(2026, 3, 25));
    expect(snapshot.fertileFrom, isNull);
    // Nothing of what she logs day by day is in the file.
    expect(text, isNot(contains('flow')));
    expect(text, isNot(contains('days')));
  });

  testWidgets('a partner opens the file and sees where she is', (tester) async {
    final harness = Harness(tester);
    final bytes = await tester.runAsync(
      () => fastCodec.encodeText(
        jsonEncode(
          PartnerSnapshot(
            madeOn: CalendarDay(2026, 3, 18),
            name: 'Lina',
            profile: Profile.tracking,
            cycleStart: CalendarDay(2026, 2, 28),
            periodLength: 4,
            earliestNext: CalendarDay(2026, 3, 25),
            latestNext: CalendarDay(2026, 3, 31),
          ).toJson(),
        ),
        password,
      ),
    );
    harness.files.nextPick = PickedFile(name: 'x.fycle', bytes: bytes!);
    await harness.pumpApp();

    await tap(tester, 'partner-open');
    await tester.enterText(dialogField(), password);
    await tap(tester, 'partner-open-confirm');

    expect(find.text("Lina's cycle"), findsOneWidget);
    expect(find.text('Day 21 of her cycle'), findsOneWidget);
    expect(find.text('Period in 5 to 11 days'), findsOneWidget);
    expect(find.text('Estimated between Mar 25 and Mar 31.'), findsOneWidget);
    // Read only: nothing to log, no tab.
    expect(key('log-today'), findsNothing);

    // The view is still there at the next launch.
    await harness.pumpApp();
    expect(find.text("Lina's cycle"), findsOneWidget);

    await tap(tester, 'partner-leave');
    expect(find.text('Welcome to Fycle'), findsOneWidget);
  });

  testWidgets('a wrong password opens nothing', (tester) async {
    final harness = Harness(tester);
    final bytes = await tester.runAsync(
      () => fastCodec.encodeText(
        jsonEncode(PartnerSnapshot(madeOn: CalendarDay(2026, 3, 18)).toJson()),
        password,
      ),
    );
    harness.files.nextPick = PickedFile(name: 'x.fycle', bytes: bytes!);
    await harness.pumpApp();

    await tap(tester, 'partner-open');
    await tester.enterText(dialogField(), 'another password');
    await tap(tester, 'partner-open-confirm');

    expect(find.textContaining('could not be read'), findsOneWidget);
    await tapVisible(tester, find.text('OK'));
    expect(find.text('Welcome to Fycle'), findsOneWidget);
  });
}
