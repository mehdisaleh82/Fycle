import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/ui/cycle_ring.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Three made-up periods, 28 days apart. Seen from 20 March 2026, today is
/// day 21 of the cycle and the next period is expected in 5 to 11 days.
List<DayEntry> threePeriods() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28)),
];

final _ring = find.byKey(const ValueKey('cycle-ring'));

/// What is written in the middle of the ring: its caption and its figure.
List<String> middle(WidgetTester tester) => [
  for (final text in tester.widgetList<Text>(
    find.descendant(of: find.byType(CycleRing), matching: find.byType(Text)),
  ))
    text.data!,
];

void main() {
  testWidgets('a tap on the ring switches its middle to the days left', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();
    expect(middle(tester), ['Day', '21']);

    final ticks = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        ticks.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tapVisible(tester, _ring);
    // A range, like the estimate it comes from.
    expect(middle(tester), ['Days left', '5–11']);
    expect(
      ticks.where((call) => call.method == 'HapticFeedback.vibrate'),
      isNotEmpty,
    );

    // A second tap brings the day of the cycle back.
    await tapVisible(tester, _ring);
    expect(middle(tester), ['Day', '21']);
  });

  testWidgets('the ring is a named button for screen readers', (tester) async {
    final semantics = tester.ensureSemantics();
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp(locale: 'fr');

    expect(
      find.bySemanticsLabel('Afficher les jours restants'),
      findsOneWidget,
    );
    await tapVisible(tester, _ring);
    expect(middle(tester), ['Jours restants', '5–11']);
    expect(find.bySemanticsLabel('Afficher le jour du cycle'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('it does not switch while a period is going on', (tester) async {
    final harness = Harness(tester, today: CalendarDay(2026, 3, 1));
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    expect(_ring, findsNothing);
    expect(middle(tester), ['Day', '2']);
  });

  testWidgets('nor when nothing is logged', (tester) async {
    final harness = Harness(tester);
    await harness.pumpApp();
    await tapVisible(tester, find.byKey(const ValueKey('onboarding-skip')));

    expect(_ring, findsNothing);
    expect(middle(tester), ['Day', '–']);
  });

  for (final scale in [1.0, 2.5]) {
    testWidgets('holds from right to left, in dark (× $scale)', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final harness = Harness(tester);
      if (scale > 1) {
        // A small phone.
        tester.view.physicalSize = const Size(320, 568);
      }
      await harness.seed(days: threePeriods());
      await harness.pumpApp(
        locale: 'fr',
        themeMode: ThemeMode.dark,
        textDirection: TextDirection.rtl,
      );
      await tapVisible(tester, _ring);
      expect(middle(tester), ['Jours restants', '5–11']);
    });
  }
}
