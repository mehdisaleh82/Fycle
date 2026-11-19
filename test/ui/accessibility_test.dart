import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/device_auth.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/reminders.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Dark mode, large text and screen reader. A layout that overflows makes
/// these tests fail.
void main() {
  for (final locale in ['en', 'fr']) {
    for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
      final name = '$locale, ${themeMode.name}';

      testWidgets('every screen holds with very large text ($name)', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2.5;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final harness = Harness(tester);
        // A small phone.
        tester.view.physicalSize = const Size(320, 568);

        // First launch.
        await harness.pumpApp(locale: locale, themeMode: themeMode);
        await walkEveryScreen(tester, harness);
      });

      testWidgets('the lock screen holds with very large text ($name)', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2.5;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final harness = Harness(tester);
        tester.view.physicalSize = const Size(320, 568);
        await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
        await harness.read((store) => store.database.appLockEnabled = true);
        harness.deviceAuth.outcome = AuthOutcome.failed;
        await harness.pumpApp(locale: locale, themeMode: themeMode);

        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
        harness.deviceAuth.outcome = AuthOutcome.success;
        await tapVisible(tester, find.byType(FilledButton));
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('the lock screen is readable and reachable ($name)', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        final harness = Harness(tester);
        await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
        await harness.read((store) => store.database.appLockEnabled = true);
        harness.deviceAuth.outcome = AuthOutcome.failed;
        await harness.pumpApp(locale: locale, themeMode: themeMode);

        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        semantics.dispose();
      });

      testWidgets('the settings are readable and reachable ($name)', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        final harness = Harness(tester);
        await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
        await harness.read(
          (store) => store.database.reminderSettings = ReminderSettings(
            periodEnabled: true,
            dailyEnabled: true,
          ),
        );
        await harness.pumpApp(locale: locale, themeMode: themeMode);
        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        semantics.dispose();
      });

      testWidgets('the home screen is readable and reachable ($name)', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        final harness = Harness(tester);
        await harness.seed(
          days: [
            ...periodFrom(CalendarDay(2026, 1, 31)),
            ...periodFrom(CalendarDay(2026, 2, 28)),
          ],
        );
        await harness.pumpApp(locale: locale, themeMode: themeMode);

        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        semantics.dispose();
      });

      testWidgets('the entry of a day is readable and reachable ($name)', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        final harness = Harness(tester);
        await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
        await harness.pumpApp(locale: locale, themeMode: themeMode);
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        semantics.dispose();
      });
    }
  }
}
