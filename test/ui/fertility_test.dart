import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Three made-up periods, 28 days apart. Seen from 20 March 2026, the next
/// one is expected between 25 and 31 March: ovulation is then estimated
/// between 9 and 21 March, and the fertile window between 4 and 22 March.
List<DayEntry> threePeriods() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28)),
];

Future<void> openSettings(WidgetTester tester) =>
    tapVisible(tester, find.byIcon(Icons.settings_outlined));

final _switch = find.byKey(const ValueKey('fertility-estimate'));

void main() {
  testWidgets('the home tab gives two ranges, as estimates, with a warning', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    expect(
      await harness.read((store) => store.database.fertilityEstimateEnabled),
      isTrue,
    );
    expect(find.text('Estimated fertile window'), findsOneWidget);
    expect(find.text('Between Mar 4 and Mar 22'), findsOneWidget);
    // In its own card and in the card at the top.
    expect(
      find.text('Ovulation estimated between Mar 9 and Mar 21'),
      findsNWidgets(2),
    );
    // Always in sight: nothing had to be accepted first.
    expect(
      find.text('An estimate: neither contraception nor a diagnosis.'),
      findsOneWidget,
    );
  });

  testWidgets('the calendar marks the days of the window, and only those', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();
    await openJournal(tester);

    expect(find.text('Fertile window (estimate)'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Tuesday, March 10, fertile window, estimate'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        'Friday, March 20, today, fertile window, estimate',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Monday, March 23'), findsOneWidget);

    // A cycle that ended is marked too, looking back from the next period.
    await tapVisible(tester, find.byTooltip('Previous month'));
    expect(
      find.bySemanticsLabel('Saturday, February 14, fertile window, estimate'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Friday, February 20'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('it can be turned off, and nothing about fertility is left', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();
    await openSettings(tester);

    await tapVisible(tester, _switch);
    // No question to turn it off.
    expect(find.byType(AlertDialog), findsNothing);
    expect(
      await harness.read((store) => store.database.fertilityEstimateEnabled),
      isFalse,
    );

    await openHome(tester);
    expect(find.text('Estimated fertile window'), findsNothing);
    expect(find.textContaining('Ovulation estimated'), findsNothing);
    await openJournal(tester);
    expect(find.text('Fertile window (estimate)'), findsNothing);
    expect(find.bySemanticsLabel('Tuesday, March 10'), findsOneWidget);

    // It stays off at the next launch.
    await harness.pumpApp();
    expect(find.text('Estimated fertile window'), findsNothing);
    semantics.dispose();
  });

  testWidgets('turning it back on first says what it is not', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.read(
      (store) => store.database.fertilityEstimateEnabled = false,
    );
    await harness.pumpApp();
    await openSettings(tester);

    await tapVisible(tester, _switch);
    expect(find.text('An estimate, nothing more'), findsOneWidget);
    expect(find.textContaining('and not a diagnosis'), findsOneWidget);
    expect(find.textContaining('without risk'), findsOneWidget);

    // Cancelling leaves it off.
    await tapVisible(tester, find.text('Cancel'));
    expect(
      await harness.read((store) => store.database.fertilityEstimateEnabled),
      isFalse,
    );

    await tapVisible(tester, _switch);
    await tapVisible(tester, find.text('Turn on'));
    expect(
      await harness.read((store) => store.database.fertilityEstimateEnabled),
      isTrue,
    );
  });

  testWidgets('explains how it is calculated, and repeats the warning', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    await tapVisible(tester, find.text('How it is calculated'));
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('counts back about 13 days'), findsOneWidget);
    expect(find.textContaining('and not a diagnosis'), findsOneWidget);
  });

  testWidgets('with too few cycles, says so instead of estimating', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(
      days: [
        ...periodFrom(CalendarDay(2026, 1, 31)),
        ...periodFrom(CalendarDay(2026, 2, 28)),
      ],
    );
    await harness.pumpApp();

    expect(find.text('Estimated fertile window'), findsOneWidget);
    expect(
      find.text('The estimate appears once two complete cycles are logged.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('fertile-window')), findsNothing);
    expect(find.textContaining('Ovulation estimated'), findsNothing);
  });

  testWidgets('nothing is estimated for a log left aside for months', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    harness.now = DateTime(2026, 9, 1, 12);
    await harness.pumpApp();

    expect(find.text('Estimated fertile window'), findsNothing);
    expect(find.textContaining('Ovulation estimated'), findsNothing);
  });

  testWidgets('is shown in French', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp(locale: 'fr');

    expect(find.text('Fenêtre de fertilité estimée'), findsOneWidget);
    expect(find.text('Entre le 4 mars et le 22 mars'), findsOneWidget);
    expect(
      find.text('Ovulation estimée entre le 9 mars et le 21 mars'),
      findsNWidgets(2),
    );
    expect(
      find.text('Une estimation : ni contraception ni diagnostic.'),
      findsOneWidget,
    );
    await openJournal(tester);
    expect(find.text('Fenêtre de fertilité (estimation)'), findsOneWidget);
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
        await harness.seed(days: threePeriods());
        await harness.pumpApp(
          locale: locale,
          themeMode: ThemeMode.dark,
          textDirection: TextDirection.rtl,
        );

        expect(find.byKey(const ValueKey('fertile-window')), findsOneWidget);
        await tapVisible(
          tester,
          find.descendant(
            of: find.ancestor(
              of: find.byKey(const ValueKey('fertile-window')),
              matching: find.byType(Card),
            ),
            matching: find.byType(TextButton),
          ),
        );
        expect(find.byType(AlertDialog), findsOneWidget);
      });
    }
  }
}
