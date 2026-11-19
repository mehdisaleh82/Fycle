import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Three made-up periods, 28 days apart. Seen from 20 March 2026, the next
/// one is expected between 25 and 31 March: ovulation is then estimated
/// between 9 and 19 March, and the fertile window between 4 and 20 March.
List<DayEntry> threePeriods() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28)),
];

Future<void> openSettings(WidgetTester tester) =>
    tapVisible(tester, find.byIcon(Icons.settings_outlined));

/// Turns the estimate on from the settings, then comes back to the home
/// screen.
Future<void> turnOn(WidgetTester tester, {String action = 'Turn on'}) async {
  await openSettings(tester);
  await tapVisible(tester, find.byKey(const ValueKey('fertility-estimate')));
  await tapVisible(tester, find.text(action));
  await tapVisible(tester, find.byType(BackButton));
}

void main() {
  testWidgets('nothing about fertility is shown unless it is turned on', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    expect(find.text('Estimated fertile window'), findsNothing);
    expect(find.text('Fertile window (estimate)'), findsNothing);
    expect(find.bySemanticsLabel('Tuesday, March 10'), findsOneWidget);
    expect(
      await harness.read((store) => store.database.fertilityEstimateEnabled),
      isFalse,
    );
    semantics.dispose();
  });

  testWidgets('turning it on first says what it is not', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();
    await openSettings(tester);

    await tapVisible(tester, find.byKey(const ValueKey('fertility-estimate')));
    expect(find.text('An estimate, nothing more'), findsOneWidget);
    expect(find.textContaining('and not a diagnosis'), findsOneWidget);
    expect(find.textContaining('without risk'), findsOneWidget);

    // Cancelling leaves it off.
    await tapVisible(tester, find.text('Cancel'));
    expect(
      await harness.read((store) => store.database.fertilityEstimateEnabled),
      isFalse,
    );

    await tapVisible(tester, find.byKey(const ValueKey('fertility-estimate')));
    await tapVisible(tester, find.text('Turn on'));
    expect(
      await harness.read((store) => store.database.fertilityEstimateEnabled),
      isTrue,
    );
  });

  testWidgets('once on, the home screen gives two ranges, as estimates', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();
    await turnOn(tester);

    expect(find.text('Estimated fertile window'), findsOneWidget);
    expect(find.text('Between Mar 4 and Mar 20'), findsOneWidget);
    expect(
      find.text('Ovulation estimated between Mar 9 and Mar 19'),
      findsOneWidget,
    );

    // The calendar marks the days of the window, and only those.
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
    expect(find.bySemanticsLabel('Saturday, March 21'), findsOneWidget);

    // A cycle that ended is marked too, looking back from the next period.
    await tapVisible(tester, find.byTooltip('Previous month'));
    expect(
      find.bySemanticsLabel('Saturday, February 14, fertile window, estimate'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Friday, February 20'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('it stays on at the next launch, and can be turned off', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();
    await turnOn(tester);

    await harness.pumpApp();
    expect(find.text('Estimated fertile window'), findsOneWidget);

    await openSettings(tester);
    await tapVisible(tester, find.byKey(const ValueKey('fertility-estimate')));
    // No question to turn it off.
    expect(find.byType(AlertDialog), findsNothing);
    await tapVisible(tester, find.byType(BackButton));
    expect(find.text('Estimated fertile window'), findsNothing);
    expect(find.text('Fertile window (estimate)'), findsNothing);
  });

  testWidgets('explains how it is calculated, and repeats the warning', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();
    await turnOn(tester);

    await tapVisible(tester, find.text('How it is calculated'));
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('counts back about 14 days'), findsOneWidget);
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
    await turnOn(tester);

    expect(find.text('Estimated fertile window'), findsOneWidget);
    expect(
      find.text('The estimate appears once two complete cycles are logged.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('fertile-window')), findsNothing);
  });

  testWidgets('nothing is estimated for a log left aside for months', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.read(
      (store) => store.database.fertilityEstimateEnabled = true,
    );
    harness.now = DateTime(2026, 9, 1, 12);
    await harness.pumpApp();

    expect(find.text('Estimated fertile window'), findsNothing);
  });

  testWidgets('is shown in French', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp(locale: 'fr');
    await openSettings(tester);
    await tapVisible(tester, find.byKey(const ValueKey('fertility-estimate')));
    expect(find.text('Une estimation, rien de plus'), findsOneWidget);
    expect(find.textContaining('ni un diagnostic'), findsOneWidget);
    await tapVisible(tester, find.text('Activer'));
    await tapVisible(tester, find.byType(BackButton));

    expect(find.text('Fenêtre de fertilité estimée'), findsOneWidget);
    expect(find.text('Entre le 4 mars et le 20 mars'), findsOneWidget);
    expect(
      find.text('Ovulation estimée entre le 9 mars et le 19 mars'),
      findsOneWidget,
    );
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
        await harness.read(
          (store) => store.database.fertilityEstimateEnabled = true,
        );
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
