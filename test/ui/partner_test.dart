import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/file_gateway.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/libido_level.dart';
import 'package:fycle/domain/life_stage.dart';
import 'package:fycle/domain/partner_link.dart';
import 'package:fycle/domain/partner_snapshot.dart';
import 'package:fycle/ui/partner_screens.dart';
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

  /// What the phone does when its camera reads a code of the app.
  Future<void> scan(WidgetTester tester, String link) async {
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/navigation',
      const JSONMethodCodec().encodeMethodCall(
        MethodCall('pushRouteInformation', {'location': link}),
      ),
      (_) {},
    );
    await tester.pumpAndSettle();
  }

  final lina = PartnerSnapshot(
    madeOn: CalendarDay(2026, 3, 18),
    name: 'Lina',
    profile: Profile.tracking,
    cycleStart: CalendarDay(2026, 2, 28),
    periodLength: 4,
    cycleLength: 28,
    earliestNext: CalendarDay(2026, 3, 25),
    latestNext: CalendarDay(2026, 3, 31),
  );

  testWidgets('she shows a code that holds what she chooses to share', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    await tapVisible(tester, find.byIcon(Icons.settings_outlined));
    await tap(tester, 'partner-share');
    final link = tester.widget<PartnerCode>(find.byType(PartnerCode)).link;
    final snapshot = partnerFromLink(link)!;
    expect(snapshot.cycleStart, CalendarDay(2026, 2, 28));
    expect(snapshot.earliestNext, CalendarDay(2026, 3, 25));
    expect(snapshot.cycleLength, 28);
    // The fertile window is not shared unless she says so.
    expect(snapshot.fertileFrom, isNull);
    // No password is asked for a code.
    expect(find.byType(TextField), findsNothing);
    expect(harness.files.saved, isEmpty);
  });

  test('the periods ahead are the next one and two more, each wider', () {
    final ranges = partnerPeriodsAhead(CalendarDay(2026, 3, 20), lina);
    expect(ranges, [
      (earliest: CalendarDay(2026, 3, 25), latest: CalendarDay(2026, 3, 31)),
      (earliest: CalendarDay(2026, 4, 21), latest: CalendarDay(2026, 4, 29)),
      (earliest: CalendarDay(2026, 5, 18), latest: CalendarDay(2026, 5, 28)),
    ]);
    // What is behind is left out.
    expect(partnerPeriodsAhead(CalendarDay(2026, 4, 10), lina), hasLength(2));
    // Nothing during a pregnancy.
    expect(
      partnerPeriodsAhead(
        CalendarDay(2026, 3, 20),
        PartnerSnapshot(
          madeOn: CalendarDay(2026, 3, 20),
          profile: Profile.pregnant,
        ),
      ),
      isEmpty,
    );
  });

  testWidgets('she may share the days her desire is often higher, and sees '
      'first what her partner will see', (tester) async {
    // 5 March: day 6. Desire logged high around day 13 of two cycles.
    final harness = Harness(tester, today: CalendarDay(2026, 3, 5));
    await harness.seed(
      days: [
        ...threePeriods(),
        DayEntry(day: CalendarDay(2026, 1, 15), libido: LibidoLevel.high),
        DayEntry(day: CalendarDay(2026, 2, 12), libido: LibidoLevel.high),
      ],
    );
    await harness.pumpApp();
    await tapVisible(tester, find.byIcon(Icons.settings_outlined));
    await tap(tester, 'partner-share');

    PartnerSnapshot shared() => partnerFromLink(
      tester.widget<PartnerCode>(find.byType(PartnerCode)).link,
    )!;
    // Not shared unless she says so.
    expect(shared().desireFrom, isNull);
    await tap(tester, 'partner-share-desire');
    expect(shared().desireFrom, CalendarDay(2026, 3, 12));
    expect(shared().desireTo, CalendarDay(2026, 3, 12));

    await tap(tester, 'partner-preview');
    expect(key('partner-preview-banner'), findsOneWidget);
    await tester.scrollUntilVisible(
      key('partner-ahead-desire'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(key('partner-ahead-period-0'), findsOneWidget);
    expect(find.textContaining('not a promise'), findsOneWidget);
    // A preview offers nothing to replace nor to stop.
    expect(key('partner-leave'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(PartnerCode), findsOneWidget);
  });

  testWidgets('nothing about desire is offered once she turned it off', (
    tester,
  ) async {
    final harness = Harness(tester, today: CalendarDay(2026, 3, 5));
    await harness.seed(
      days: [
        ...threePeriods(),
        DayEntry(day: CalendarDay(2026, 1, 15), libido: LibidoLevel.high),
        DayEntry(day: CalendarDay(2026, 2, 12), libido: LibidoLevel.high),
      ],
    );
    await harness.read((store) => store.database.sexLifeVisible = false);
    await harness.pumpApp();
    await tapVisible(tester, find.byIcon(Icons.settings_outlined));
    await tap(tester, 'partner-share');
    expect(key('partner-share-desire'), findsNothing);
  });

  testWidgets('a partner sees the weeks ahead', (tester) async {
    final harness = Harness(tester);
    await harness.pumpApp();
    await scan(
      tester,
      partnerLinkOf(
        PartnerSnapshot(
          madeOn: CalendarDay(2026, 3, 20),
          name: 'Lina',
          profile: Profile.tracking,
          cycleStart: CalendarDay(2026, 2, 28),
          periodLength: 4,
          cycleLength: 28,
          earliestNext: CalendarDay(2026, 3, 25),
          latestNext: CalendarDay(2026, 3, 31),
          desireFrom: CalendarDay(2026, 3, 21),
          desireTo: CalendarDay(2026, 3, 23),
        ),
      ),
    );
    await tester.scrollUntilVisible(
      key('partner-ahead-desire'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(key('partner-ahead-period-2'), findsOneWidget);
    expect(
      find.text('Her desire is often higher from Mar 21 to Mar 23'),
      findsOneWidget,
    );
  });

  testWidgets('a partner scans the code and sees where she is', (tester) async {
    final harness = Harness(tester);
    await harness.pumpApp();
    expect(find.text('Welcome to Fycle'), findsOneWidget);

    await scan(tester, partnerLinkOf(lina));

    expect(find.text("Lina's cycle"), findsOneWidget);
    expect(find.text('Period in 5 to 11 days'), findsOneWidget);

    // The view is still there at the next launch.
    await harness.pumpApp();
    expect(find.text("Lina's cycle"), findsOneWidget);
  });

  testWidgets('a code scanned again replaces the one before', (tester) async {
    final harness = Harness(tester);
    await harness.pumpApp();
    await scan(tester, partnerLinkOf(lina));
    await scan(
      tester,
      partnerLinkOf(
        PartnerSnapshot(
          madeOn: CalendarDay(2026, 3, 20),
          name: 'Lina',
          profile: Profile.tracking,
          cycleStart: CalendarDay(2026, 3, 19),
          periodLength: 4,
        ),
      ),
    );
    expect(find.text('Her period is going on'), findsOneWidget);
  });

  testWidgets('a code that is not one opens nothing', (tester) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await scan(tester, 'fycle://p/not-a-code');

    expect(find.text('Unreadable code'), findsOneWidget);
    await tapVisible(tester, find.text('OK'));
    expect(find.text('Welcome to Fycle'), findsOneWidget);
  });

  testWidgets('a phone that follows a cycle of its own keeps it', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    await scan(tester, partnerLinkOf(lina));

    expect(find.text('This phone already follows a cycle'), findsOneWidget);
    await tapVisible(tester, find.text('OK'));
    expect(find.text("Lina's cycle"), findsNothing);
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
    await tap(tester, 'partner-file');
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

    await tap(tester, 'onboarding-existing');
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

    await tap(tester, 'onboarding-existing');
    await tap(tester, 'partner-open');
    await tester.enterText(dialogField(), 'another password');
    await tap(tester, 'partner-open-confirm');

    expect(find.textContaining('could not be read'), findsOneWidget);
    await tapVisible(tester, find.text('OK'));
    expect(find.text('Welcome to Fycle'), findsOneWidget);
  });
}
