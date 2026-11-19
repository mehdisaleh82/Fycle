import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/device_auth.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

const _homeText = 'Log today';
const _lockedText = 'Fycle is locked';

/// The app with made-up data, the lock being on or off beforehand.
Future<Harness> prepare(WidgetTester tester, {bool locked = true}) async {
  final harness = Harness(tester);
  await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
  if (locked) {
    await harness.read((store) => store.database.appLockEnabled = true);
  }
  // Whatever a test does, the next one starts with the app in front.
  addTearDown(
    () => tester.binding.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    ),
  );
  return harness;
}

Future<void> send(WidgetTester tester, List<AppLifecycleState> states) async {
  for (final state in states) {
    tester.binding.handleAppLifecycleStateChanged(state);
    await tester.pumpAndSettle();
  }
}

const _toBackground = [
  AppLifecycleState.inactive,
  AppLifecycleState.hidden,
  AppLifecycleState.paused,
];
const _toFront = [
  AppLifecycleState.hidden,
  AppLifecycleState.inactive,
  AppLifecycleState.resumed,
];

Finder get lockSwitch => find.widgetWithText(SwitchListTile, 'Lock Fycle');

Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.settings_outlined));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the app is not locked unless the user asks for it', (
    tester,
  ) async {
    final harness = await prepare(tester, locked: false);
    await harness.pumpApp();
    expect(find.text(_homeText), findsOneWidget);

    await send(tester, _toBackground);
    await send(tester, _toFront);

    expect(find.text(_homeText), findsOneWidget);
    expect(harness.deviceAuth.prompts, isEmpty);
  });

  group('turning the lock on', () {
    testWidgets('asks who is holding the phone first', (tester) async {
      final harness = await prepare(tester, locked: false);
      await harness.pumpApp();
      await openSettings(tester);
      await tapVisible(tester, lockSwitch);

      expect(harness.deviceAuth.prompts, ['Unlock Fycle']);
      expect(tester.widget<SwitchListTile>(lockSwitch).value, isTrue);
      // She has just proved who she is: no lock screen right away.
      expect(find.text(_lockedText), findsNothing);
      final stored = await harness.read(
        (store) => store.database.appLockEnabled,
      );
      expect(stored, isTrue);
    });

    testWidgets('does nothing if she is not recognised', (tester) async {
      final harness = await prepare(tester, locked: false);
      harness.deviceAuth.outcome = AuthOutcome.failed;
      await harness.pumpApp();
      await openSettings(tester);
      await tapVisible(tester, lockSwitch);

      expect(tester.widget<SwitchListTile>(lockSwitch).value, isFalse);
      final stored = await harness.read(
        (store) => store.database.appLockEnabled,
      );
      expect(stored, isFalse);
    });

    testWidgets('is refused, with an explanation, on a phone without a '
        'passcode', (tester) async {
      final harness = await prepare(tester, locked: false);
      harness.deviceAuth.available = false;
      await harness.pumpApp();
      await openSettings(tester);
      await tapVisible(tester, lockSwitch);

      expect(find.text('No passcode on this phone'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(lockSwitch).value, isFalse);
      expect(harness.deviceAuth.prompts, isEmpty);
    });
  });

  group('when the app opens', () {
    testWidgets('the prompt comes up by itself and lets her in', (
      tester,
    ) async {
      final harness = await prepare(tester);
      await harness.pumpApp();

      expect(harness.deviceAuth.prompts, ['Unlock Fycle']);
      expect(find.text(_homeText), findsOneWidget);
      expect(find.text(_lockedText), findsNothing);
    });

    testWidgets('nothing is shown to someone who is not recognised', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final harness = await prepare(tester);
      harness.deviceAuth.outcome = AuthOutcome.failed;
      await harness.pumpApp();

      expect(find.text(_lockedText), findsOneWidget);
      expect(find.text(_homeText), findsNothing);
      expect(find.textContaining('expected'), findsNothing);
      // Nothing for the screen reader either.
      expect(find.bySemanticsLabel(RegExp('expected')), findsNothing);
      // One prompt, not a loop of them.
      expect(harness.deviceAuth.prompts, hasLength(1));

      // She asks again with the button.
      harness.deviceAuth.outcome = AuthOutcome.success;
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();
      expect(harness.deviceAuth.prompts, hasLength(2));
      expect(find.text(_homeText), findsOneWidget);
      expect(find.text(_lockedText), findsNothing);
      semantics.dispose();
    });

    testWidgets('the lock screen is worded in French', (tester) async {
      final harness = await prepare(tester);
      harness.deviceAuth.outcome = AuthOutcome.failed;
      await harness.pumpApp(locale: 'fr');

      expect(find.text('Fycle est verrouillée'), findsOneWidget);
      expect(find.text('Déverrouiller'), findsOneWidget);
      expect(harness.deviceAuth.prompts, ['Déverrouiller Fycle']);
    });
  });

  group('when the app leaves the front', () {
    testWidgets('its content is covered at once, for the app switcher', (
      tester,
    ) async {
      final harness = await prepare(tester);
      await harness.pumpApp();
      expect(find.text(_homeText), findsOneWidget);

      await send(tester, [AppLifecycleState.inactive]);
      expect(find.text(_homeText), findsNothing);

      // A glance at the notification panel is not a reason to lock.
      await send(tester, [AppLifecycleState.resumed]);
      expect(find.text(_homeText), findsOneWidget);
      expect(harness.deviceAuth.prompts, hasLength(1));
    });

    testWidgets('coming back asks again', (tester) async {
      final harness = await prepare(tester);
      await harness.pumpApp();

      await send(tester, _toBackground);
      harness.deviceAuth.outcome = AuthOutcome.failed;
      await send(tester, _toFront);

      expect(harness.deviceAuth.prompts, hasLength(2));
      expect(find.text(_lockedText), findsOneWidget);
      expect(find.text(_homeText), findsNothing);

      harness.deviceAuth.outcome = AuthOutcome.success;
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();
      expect(find.text(_homeText), findsOneWidget);
    });

    testWidgets('every screen is locked, and found again as it was', (
      tester,
    ) async {
      final harness = await prepare(tester);
      await harness.pumpApp();
      // The entry of the day, with a note being typed.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Made-up note');
      await tester.pumpAndSettle();

      await send(tester, _toBackground);
      harness.deviceAuth.outcome = AuthOutcome.failed;
      await send(tester, _toFront);
      expect(find.text(_lockedText), findsOneWidget);
      expect(find.text('Made-up note'), findsNothing);

      harness.deviceAuth.outcome = AuthOutcome.success;
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();
      expect(find.text('Made-up note'), findsOneWidget);
    });
  });

  group('turning the lock off', () {
    testWidgets('asks who is holding the phone first', (tester) async {
      final harness = await prepare(tester);
      await harness.pumpApp();
      await openSettings(tester);

      harness.deviceAuth.outcome = AuthOutcome.failed;
      await tapVisible(tester, lockSwitch);
      expect(tester.widget<SwitchListTile>(lockSwitch).value, isTrue);

      harness.deviceAuth.outcome = AuthOutcome.success;
      await tapVisible(tester, lockSwitch);
      expect(tester.widget<SwitchListTile>(lockSwitch).value, isFalse);

      // No lock any more when coming back.
      final prompts = harness.deviceAuth.prompts.length;
      await send(tester, _toBackground);
      await send(tester, _toFront);
      expect(harness.deviceAuth.prompts, hasLength(prompts));
      expect(find.text(_lockedText), findsNothing);
    });
  });

  testWidgets('a phone whose passcode was removed does not shut her out', (
    tester,
  ) async {
    final harness = await prepare(tester);
    harness.deviceAuth.available = false;
    await harness.pumpApp();

    expect(find.text(_homeText), findsOneWidget);
    expect(find.textContaining('no longer has a passcode'), findsOneWidget);
    final stored = await harness.read((store) => store.database.appLockEnabled);
    expect(stored, isFalse);
  });

  testWidgets('deleting everything removes the lock too', (tester) async {
    final harness = await prepare(tester);
    await harness.pumpApp();
    await openSettings(tester);
    await tapVisible(tester, find.text('Delete everything'));
    await tester.tap(find.widgetWithText(FilledButton, 'Delete everything'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Fycle'), findsOneWidget);

    final prompts = harness.deviceAuth.prompts.length;
    await send(tester, _toBackground);
    await send(tester, _toFront);
    expect(find.text('Welcome to Fycle'), findsOneWidget);
    expect(harness.deviceAuth.prompts, hasLength(prompts));
    final stored = await harness.read((store) => store.database.appLockEnabled);
    expect(stored, isFalse);
  });
}
