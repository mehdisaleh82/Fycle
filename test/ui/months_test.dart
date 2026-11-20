import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/mood.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Made-up log, seen from 20 March 2026: a period of 4 days from
/// 27 February (two days in each month) and one other entry in March.
List<DayEntry> log() => [
  ...periodFrom(CalendarDay(2026, 2, 27)),
  DayEntry(day: CalendarDay(2026, 3, 10), mood: Mood.calm),
];

Finder within(String key, String text) =>
    find.descendant(of: find.byKey(ValueKey(key)), matching: find.text(text));

void main() {
  testWidgets('the journal shows the last months, and how full each one is', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: log());
    await harness.pumpApp();
    await openJournal(tester);

    expect(find.text('Your history, month by month'), findsOneWidget);
    expect(
      find.textContaining('the fuller your months, the more accurate'),
      findsOneWidget,
    );
    expect(within('month-2026-3', 'March 2026'), findsOneWidget);
    expect(
      within('month-2026-3', '3 days logged · 2 period days'),
      findsOneWidget,
    );
    expect(
      within('month-2026-2', '2 days logged · 2 period days'),
      findsOneWidget,
    );
    // A month with nothing is shown too, without a word of reproach.
    expect(within('month-2026-1', 'Nothing logged'), findsOneWidget);
    expect(find.byKey(const ValueKey('month-2025-10')), findsOneWidget);
    expect(find.byKey(const ValueKey('month-2025-9')), findsNothing);
  });

  testWidgets('it fills in as a day is logged', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: log());
    await harness.pumpApp();
    await openJournal(tester);

    await tapVisible(tester, find.byKey(const ValueKey('journal-write-today')));
    await tapVisible(tester, find.byKey(const ValueKey('mood-calm')));
    await tapVisible(tester, find.byKey(const ValueKey('day-done')));

    expect(
      within('month-2026-3', '4 days logged · 2 period days'),
      findsOneWidget,
    );
  });

  testWidgets('is shown in French', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: log());
    await harness.pumpApp(locale: 'fr');
    await openJournal(tester);

    expect(find.text('Ton historique, mois par mois'), findsOneWidget);
    expect(
      within('month-2026-3', '3 jours saisis · 2 jours de règles'),
      findsOneWidget,
    );
    expect(within('month-2026-1', 'Rien de saisi'), findsOneWidget);
  });

  testWidgets('the setup ends on what it all rests on: what is logged', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.pumpApp(locale: 'fr');
    await setupTo(tester, 'Tout est prêt');
    expect(
      find.text(
        "Note tes règles le jour où elles commencent : l'estimation "
        "s'affine à chaque cycle.",
      ),
      findsOneWidget,
    );
  });

  for (final locale in ['en', 'fr']) {
    for (final scale in [1.0, 2.5]) {
      testWidgets('holds from right to left, in dark ($locale, × $scale)', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final harness = Harness(tester);
        if (scale > 1) {
          // A small phone.
          tester.view.physicalSize = const Size(320, 568);
        }
        await harness.seed(days: log());
        await harness.pumpApp(
          locale: locale,
          themeMode: ThemeMode.dark,
          textDirection: TextDirection.rtl,
        );
        await openJournal(tester);
        await tester.ensureVisible(find.byKey(const ValueKey('month-2025-10')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('month-2025-10')), findsOneWidget);
      });
    }
  }
}
