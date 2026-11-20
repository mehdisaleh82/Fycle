import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/csv_export.dart';
import 'package:fycle/data/fycle_database.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/intimacy.dart';
import 'package:fycle/domain/libido_level.dart';
import 'package:fycle/domain/life_stage.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Three periods, 28 days apart, the last one on 28 February 2026: the
/// next one is estimated from 25 March.
List<DayEntry> threePeriods() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28)),
];

/// A high desire on the 13th and the 14th day of the two complete cycles.
List<DayEntry> withDesire() => [
  ...threePeriods(),
  DayEntry(day: CalendarDay(2026, 1, 15), libido: LibidoLevel.high),
  DayEntry(day: CalendarDay(2026, 2, 13), libido: LibidoLevel.high),
];

void main() {
  Finder key(String name) => find.byKey(ValueKey(name));
  String textOf(WidgetTester tester, String name) =>
      tester.widget<Text>(key(name)).data!;

  test('sex logged on a day is stored, and exported in its own column', () {
    final db = FycleDatabase.inMemory();
    addTearDown(db.close);
    final day = CalendarDay(2026, 3, 20);
    db.saveDay(DayEntry(day: day, intimacy: Intimacy.protected));

    final stored = db.readDay(day)!;
    expect(stored.intimacy, Intimacy.protected);
    expect(stored.isEmpty, isFalse);
    expect(
      const LineSplitter().convert(daysToCsv([stored])).first,
      endsWith('note,intimacy'),
    );
    // A file without any keeps the columns it always had.
    expect(
      const LineSplitter().convert(daysToCsv([DayEntry(day: day)])).first,
      endsWith('note'),
    );
  });

  testWidgets('sex is logged in one tap, without a word about it', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    await tapVisible(tester, key('log-today'));
    await tapVisible(tester, key('intimacy-unprotected'));

    expect(
      await harness.read(
        (store) => store.database.readDay(harness.today)?.intimacy,
      ),
      Intimacy.unprotected,
    );
    // A plain note: nothing is said of a risk (CLAUDE.md, rule 7).
    expect(find.textContaining('risk'), findsNothing);
    expect(find.textContaining('pregnan'), findsNothing);
  });

  testWidgets('the weeks ahead list what is estimated, in order', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: withDesire());
    await harness.pumpApp();

    expect(find.text('The weeks ahead'), findsOneWidget);
    expect(textOf(tester, 'ahead-period'), 'Period, estimated');
    expect(
      textOf(tester, 'ahead-desire'),
      'Desire often higher · 2 of 2 cycles',
    );
    // The period comes first: her days of higher desire are behind in
    // this cycle, and counted from the next one.
    expect(
      tester.getTopLeft(key('ahead-period')).dy,
      lessThan(tester.getTopLeft(key('ahead-desire')).dy),
    );
    expect(key('ahead-desire-general'), findsNothing);
  });

  testWidgets('without her own pattern, a general one, said as such', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    expect(key('ahead-desire'), findsNothing);
    expect(
      textOf(tester, 'ahead-desire-general'),
      startsWith('Desire: in general'),
    );
  });

  testWidgets('turned off, nothing about sex is offered any more', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: withDesire());
    await harness.pumpApp();

    await tapVisible(tester, find.byIcon(Icons.settings_outlined));
    await tapVisible(tester, key('sex-life'));
    expect(
      await harness.read((store) => store.database.sexLifeVisible),
      isFalse,
    );
    await openHome(tester);

    expect(key('ahead-desire'), findsNothing);
    expect(key('ahead-desire-general'), findsNothing);
    expect(key('ahead-period'), findsOneWidget);
    await tapVisible(tester, key('log-today'));
    expect(key('intimacy-protected'), findsNothing);
  });

  testWidgets('nothing is listed during a pregnancy', (tester) async {
    final harness = Harness(tester);
    await harness.seed(
      days: withDesire(),
      profile: Profile.pregnant,
      pregnancyStart: CalendarDay(2026, 2, 28),
    );
    await harness.pumpApp();
    expect(key('ahead'), findsNothing);
  });
}
