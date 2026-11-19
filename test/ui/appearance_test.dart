import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/appearance.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/ui/home_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// The appearance setting: light by default, dark or like the phone on
/// request, kept on this phone only.
void main() {
  Brightness shownBrightness(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness;

  Future<Harness> seeded(WidgetTester tester) async {
    final harness = Harness(tester);
    await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
    return harness;
  }

  Future<void> choose(WidgetTester tester, Appearance appearance) async {
    await tapVisible(tester, find.byKey(const ValueKey('appearance')));
    await tester.tap(find.byKey(ValueKey('appearance-${appearance.name}')));
    await tester.pumpAndSettle();
  }

  void darkPhone(WidgetTester tester) {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  }

  testWidgets('the app is light by default, even on a dark phone', (
    tester,
  ) async {
    darkPhone(tester);
    final harness = await seeded(tester);
    await harness.pumpApp();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(shownBrightness(tester), Brightness.light);
  });

  testWidgets('dark is applied at once and kept at the next launch', (
    tester,
  ) async {
    final harness = await seeded(tester);
    await harness.pumpApp();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Light'), findsOneWidget);

    await choose(tester, Appearance.dark);
    expect(shownBrightness(tester), Brightness.dark);
    expect(find.text('Dark'), findsOneWidget);
    expect(
      await harness.read((store) => store.database.appearance),
      Appearance.dark,
    );

    await harness.pumpApp();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(shownBrightness(tester), Brightness.dark);
  });

  testWidgets('"same as the phone" follows the phone', (tester) async {
    final harness = await seeded(tester);
    await harness.read(
      (store) => store.database.appearance = Appearance.system,
    );
    await harness.pumpApp();
    expect(shownBrightness(tester), Brightness.light);

    darkPhone(tester);
    await tester.pumpAndSettle();
    expect(shownBrightness(tester), Brightness.dark);
  });

  testWidgets('cancelling the choice changes nothing', (tester) async {
    final harness = await seeded(tester);
    await harness.pumpApp();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('appearance')));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(shownBrightness(tester), Brightness.light);
    expect(
      await harness.read((store) => store.database.appearance),
      Appearance.light,
    );
  });

  testWidgets('deleting everything brings the light appearance back', (
    tester,
  ) async {
    final harness = await seeded(tester);
    await harness.read((store) => store.database.appearance = Appearance.dark);
    await harness.pumpApp();
    expect(shownBrightness(tester), Brightness.dark);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byIcon(Icons.delete_forever));
    await tester.tap(find.byType(FilledButton).last);
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsNothing);
    expect(shownBrightness(tester), Brightness.light);
  });

  testWidgets('the choices are worded in French', (tester) async {
    final harness = await seeded(tester);
    await harness.pumpApp(locale: 'fr');
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Apparence'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('appearance')));

    for (final label in ['Clair', 'Sombre', 'Comme le téléphone']) {
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(label),
        ),
        findsOneWidget,
      );
    }
  });
}
