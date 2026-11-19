import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/pain_level.dart';
import 'package:fycle/domain/sleep_quality.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Made-up log, seen from 20 March 2026 (day 21 of the current cycle): a
/// cycle from 31 January with a period of 5 days, one day of pain and one
/// poor night in its first 21 days; then a cycle from 28 February with a
/// period of 4 days and two poor nights.
List<DayEntry> twoCycles() => [
  ...periodFrom(CalendarDay(2026, 1, 31), length: 5),
  DayEntry(day: CalendarDay(2026, 2, 8), pain: PainLevel.mild),
  DayEntry(day: CalendarDay(2026, 2, 10), sleep: SleepQuality.poor),
  // Day 26 of that cycle: after the point compared.
  DayEntry(day: CalendarDay(2026, 2, 25), pain: PainLevel.severe),
  ...periodFrom(CalendarDay(2026, 2, 28)),
  DayEntry(day: CalendarDay(2026, 3, 6), sleep: SleepQuality.poor),
  DayEntry(day: CalendarDay(2026, 3, 12), sleep: SleepQuality.poor),
];

Finder within(String key, String text) =>
    find.descendant(of: find.byKey(ValueKey(key)), matching: find.text(text));

Finder iconIn(String key, IconData icon) =>
    find.descendant(of: find.byKey(ValueKey(key)), matching: find.byIcon(icon));

void main() {
  testWidgets('sets this cycle next to the one before, at the same point', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final harness = Harness(tester);
    await harness.seed(days: twoCycles());
    await harness.pumpApp();
    await openReview(tester);

    expect(find.text('This cycle and the one before'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('comparison-intro'))).data,
      'Both taken over their first 21 days.',
    );
    // Fewer period days, less pain, more poor nights, fewer days logged.
    expect(within('comparison-period', '4'), findsOneWidget);
    expect(within('comparison-period', '5'), findsOneWidget);
    expect(iconIn('comparison-period', Icons.arrow_downward), findsOneWidget);
    expect(within('comparison-pain', '0'), findsOneWidget);
    expect(within('comparison-pain', '1'), findsOneWidget);
    expect(iconIn('comparison-pain', Icons.arrow_downward), findsOneWidget);
    expect(within('comparison-sleep', '2'), findsOneWidget);
    expect(iconIn('comparison-sleep', Icons.arrow_upward), findsOneWidget);
    expect(within('comparison-logged', '6'), findsOneWidget);
    expect(within('comparison-logged', '7'), findsOneWidget);

    // Read aloud as one sentence per line.
    expect(
      find.bySemanticsLabel(
        'Poor nights: 2 in this cycle, 1 in the one before',
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('an equal count is shown as such', (tester) async {
    final harness = Harness(tester);
    await harness.seed(
      days: [
        ...periodFrom(CalendarDay(2026, 1, 31)),
        ...periodFrom(CalendarDay(2026, 2, 28)),
      ],
    );
    await harness.pumpApp();
    await openReview(tester);

    expect(iconIn('comparison-period', Icons.drag_handle), findsOneWidget);
    expect(iconIn('comparison-pain', Icons.drag_handle), findsOneWidget);
  });

  testWidgets('is shown in French', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: twoCycles());
    await harness.pumpApp(locale: 'fr');
    await openReview(tester);

    expect(find.text('Ce cycle et le précédent'), findsOneWidget);
    expect(
      find.text('Tous deux pris sur leurs 21 premiers jours.'),
      findsOneWidget,
    );
    expect(within('comparison-sleep', 'Nuits difficiles'), findsOneWidget);
    expect(within('comparison-card', 'Précédent'), findsOneWidget);
  });

  testWidgets('there is none before a second cycle', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
    await harness.pumpApp();
    await openReview(tester);
    expect(find.byKey(const ValueKey('comparison-card')), findsNothing);
  });

  testWidgets('is part of the report for the doctor', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: twoCycles());
    await harness.pumpApp();
    await openReview(tester);
    await tapVisible(tester, find.byKey(const ValueKey('open-doctor-report')));

    expect(find.byKey(const ValueKey('comparison-card')), findsOneWidget);
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
        await harness.seed(days: twoCycles());
        await harness.pumpApp(
          locale: locale,
          themeMode: ThemeMode.dark,
          textDirection: TextDirection.rtl,
        );
        await openReview(tester);
        await tester.ensureVisible(
          find.byKey(const ValueKey('comparison-logged')),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('comparison-logged')), findsOneWidget);
      });
    }
  }
}
