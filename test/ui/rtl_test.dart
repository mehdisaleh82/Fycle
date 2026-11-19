import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/device_auth.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Right-to-left writing (Arabic, Hebrew): every screen is shown mirrored,
/// with the existing languages, since no right-to-left language is
/// translated yet. A layout that overflows makes these tests fail.
void main() {
  for (final locale in ['en', 'fr']) {
    for (final scale in [1.0, 2.5]) {
      final name = '$locale, text × $scale';

      testWidgets('every screen holds from right to left ($name)', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final harness = Harness(tester);
        if (scale > 1) {
          // A small phone.
          tester.view.physicalSize = const Size(320, 568);
        }
        await harness.pumpApp(locale: locale, textDirection: TextDirection.rtl);
        await walkEveryScreen(tester, harness);
      });

      testWidgets('the lock screen holds from right to left ($name)', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final harness = Harness(tester);
        if (scale > 1) {
          tester.view.physicalSize = const Size(320, 568);
        }
        await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
        await harness.read((store) => store.database.appLockEnabled = true);
        harness.deviceAuth.outcome = AuthOutcome.failed;
        await harness.pumpApp(locale: locale, textDirection: TextDirection.rtl);

        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
        harness.deviceAuth.outcome = AuthOutcome.success;
        await tapVisible(tester, find.byType(FilledButton));
        expect(find.byKey(const ValueKey('log-today')), findsOneWidget);
      });
    }
  }

  testWidgets('the home screen is mirrored from right to left', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
    await harness.pumpApp(textDirection: TextDirection.rtl);
    await openJournal(tester);
    final width = tester.view.physicalSize.width;

    // The settings button sits at the end of the header: on the left.
    expect(
      tester.getCenter(find.byIcon(Icons.settings_outlined)).dx,
      lessThan(width / 2),
    );

    // "Previous month" is where the line starts: on the right, and its
    // arrow points that way.
    final previous = find.byTooltip('Previous month');
    final next = find.byTooltip('Next month');
    expect(
      tester.getCenter(previous).dx,
      greaterThan(tester.getCenter(next).dx),
    );
    expect(
      find.descendant(of: previous, matching: find.byIcon(Icons.chevron_right)),
      findsOneWidget,
    );

    // The first day of the month comes before the second: to its right.
    expect(
      tester.getCenter(find.byKey(const ValueKey('day-2026-03-01'))).dx,
      greaterThan(
        tester.getCenter(find.byKey(const ValueKey('day-2026-03-02'))).dx,
      ),
    );

    // The arrows still change the month the right way.
    await tester.tap(previous);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('day-2026-02-28')), findsOneWidget);
  });

  testWidgets('the home screen keeps its order from left to right', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
    await harness.pumpApp();
    await openJournal(tester);

    final previous = find.byTooltip('Previous month');
    expect(
      tester.getCenter(previous).dx,
      lessThan(tester.getCenter(find.byTooltip('Next month')).dx),
    );
    expect(
      find.descendant(of: previous, matching: find.byIcon(Icons.chevron_left)),
      findsOneWidget,
    );
  });
}
