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
        await tapVisible(tester, find.byIcon(Icons.calendar_today));
        await tapVisible(tester, find.byType(TextButton).last);
        await tapVisible(tester, find.byType(FilledButton));

        // Home, then the entry of the day.
        expect(find.byType(FloatingActionButton), findsOneWidget);
        await tapVisible(tester, find.byType(FloatingActionButton));
        await tapVisible(tester, find.byKey(const ValueKey('flow-medium')));
        await tapVisible(tester, find.byType(FilledButton));

        // Settings and its dialogs.
        await tapVisible(tester, find.byIcon(Icons.settings_outlined));
        for (final icon in [
          Icons.loop,
          Icons.lock_outline,
          Icons.table_chart_outlined,
          Icons.delete_forever,
        ]) {
          await tapVisible(tester, find.byIcon(icon));
          expect(find.byType(AlertDialog), findsOneWidget);
          await tapVisible(
            tester,
            find.descendant(
              of: find.byType(AlertDialog),
              matching: find.byType(TextButton),
            ),
          );
        }

        // Reminders: both switches, then their dialogs.
        await tapVisible(tester, find.byIcon(Icons.notifications_outlined));
        await tapVisible(
          tester,
          find.byIcon(Icons.edit_notifications_outlined),
        );
        await tapVisible(
          tester,
          find.byKey(const ValueKey('period-days-before')),
        );
        expect(find.byType(AlertDialog), findsOneWidget);
        await tapVisible(
          tester,
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(TextButton),
          ),
        );
        for (final key in ['period-time', 'daily-time']) {
          await tapVisible(tester, find.byKey(ValueKey(key)));
          expect(find.byType(TimePickerDialog), findsOneWidget);
          await tapVisible(
            tester,
            find
                .descendant(
                  of: find.byType(TimePickerDialog),
                  matching: find.byType(TextButton),
                )
                .first,
          );
        }

        // A reminder the phone refuses, then the lock on a phone without a
        // passcode: two notices.
        await tapVisible(tester, find.byIcon(Icons.notifications_outlined));
        harness.reminders.allow = false;
        await tapVisible(tester, find.byIcon(Icons.notifications_outlined));
        expect(find.byType(AlertDialog), findsOneWidget);
        await tapVisible(
          tester,
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(TextButton),
          ),
        );
        harness.deviceAuth.available = false;
        await tapVisible(tester, find.byIcon(Icons.fingerprint));
        expect(find.byType(AlertDialog), findsOneWidget);
        await tapVisible(
          tester,
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(TextButton),
          ),
        );
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
