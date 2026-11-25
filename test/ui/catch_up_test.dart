import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/life_stage.dart';
import 'package:fycle/domain/symptom.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Three periods, 28 days apart, the last one on 28 February 2026: the
/// next one is estimated from 25 March.
List<DayEntry> threePeriods() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28)),
];

/// The same, the last period logged on its first day only.
List<DayEntry> lastOneCutShort() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28), length: 1),
];

void main() {
  Finder key(String name) => find.byKey(ValueKey(name));

  Future<List<CalendarDay>> flowDaysFrom(Harness harness, CalendarDay from) =>
      harness.read(
        (store) => [
          for (final entry in store.database.readDays())
            if (entry.flow != null && !entry.day.isBefore(from)) entry.day,
        ],
      );

  testWidgets('nothing is asked before the estimated range', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();
    expect(key('catch-up'), findsNothing);
  });

  testWidgets('a period that started yesterday is logged in one tap', (
    tester,
  ) async {
    final harness = Harness(tester, today: CalendarDay(2026, 3, 27));
    await harness.seed(
      days: [
        ...threePeriods(),
        // What she logged yesterday is kept.
        DayEntry(
          day: CalendarDay(2026, 3, 26),
          symptoms: const {Symptom.cramps},
        ),
      ],
    );
    await harness.pumpApp();

    expect(find.text('Has your period started?'), findsOneWidget);
    await tapVisible(tester, key('catch-up-yesterday'));

    expect(await flowDaysFrom(harness, CalendarDay(2026, 3, 10)), [
      CalendarDay(2026, 3, 26),
      CalendarDay(2026, 3, 27),
    ]);
    final yesterday = await harness.read(
      (store) => store.database.readDay(CalendarDay(2026, 3, 26))!,
    );
    expect(yesterday.flow, FlowIntensity.medium);
    expect(yesterday.symptoms, {Symptom.cramps});
    expect(key('catch-up'), findsNothing);
  });

  testWidgets('"not yet" closes the question for the day, and logs nothing', (
    tester,
  ) async {
    final harness = Harness(tester, today: CalendarDay(2026, 3, 27));
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    await tapVisible(tester, key('catch-up-not-yet'));

    expect(key('catch-up'), findsNothing);
    expect(await flowDaysFrom(harness, CalendarDay(2026, 3, 10)), isEmpty);
    expect(
      await harness.read((store) => store.database.periodNotYetOn),
      CalendarDay(2026, 3, 27),
    );
  });

  testWidgets('a period logged on its first day only is carried on', (
    tester,
  ) async {
    final harness = Harness(tester, today: CalendarDay(2026, 3, 2));
    await harness.seed(days: lastOneCutShort());
    await harness.pumpApp();

    expect(find.text('Is your period still going on?'), findsOneWidget);
    await tapVisible(tester, key('catch-up-continues'));

    expect(await flowDaysFrom(harness, CalendarDay(2026, 2, 28)), [
      CalendarDay(2026, 2, 28),
      CalendarDay(2026, 3, 1),
      CalendarDay(2026, 3, 2),
    ]);
    expect(key('catch-up'), findsNothing);
  });

  testWidgets('"it is over" closes the question, and logs nothing', (
    tester,
  ) async {
    final harness = Harness(tester, today: CalendarDay(2026, 3, 2));
    await harness.seed(days: lastOneCutShort());
    await harness.pumpApp();

    await tapVisible(tester, key('catch-up-ended'));

    expect(key('catch-up'), findsNothing);
    expect(await flowDaysFrom(harness, CalendarDay(2026, 2, 28)), [
      CalendarDay(2026, 2, 28),
    ]);
  });

  testWidgets('nothing is asked during a pregnancy', (tester) async {
    final harness = Harness(tester, today: CalendarDay(2026, 3, 27));
    await harness.seed(
      days: threePeriods(),
      profile: Profile.pregnant,
      pregnancyStart: CalendarDay(2026, 2, 28),
    );
    await harness.pumpApp();
    expect(key('catch-up'), findsNothing);
  });

  testWidgets('the question is asked in French without "vous"', (tester) async {
    final harness = Harness(tester, today: CalendarDay(2026, 3, 27));
    await harness.seed(days: threePeriods());
    await harness.pumpApp(locale: 'fr');
    expect(find.text('Tes règles ont-elles commencé ?'), findsOneWidget);
    expect(find.text('Pas encore'), findsOneWidget);
  });

  testWidgets('yesterday, left empty, is one tap away', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    await openJournal(tester);
    await tapVisible(tester, key('log-yesterday'));
    // The page of the day opens over the home screen.
    expect(key('day-done'), findsOneWidget);
  });

  testWidgets('yesterday is not offered once it is logged', (tester) async {
    final logged = Harness(tester);
    await logged.seed(
      days: [
        ...threePeriods(),
        DayEntry(
          day: CalendarDay(2026, 3, 19),
          symptoms: const {Symptom.cramps},
        ),
      ],
    );
    await logged.pumpApp();
    await openJournal(tester);
    expect(key('log-yesterday'), findsNothing);
  });
}
