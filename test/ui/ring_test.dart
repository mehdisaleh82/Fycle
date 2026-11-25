import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/pain_level.dart';
import 'package:fycle/domain/sleep_quality.dart';
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

/// Whether the cycle is shown as a line, with its steps, instead of a ring.
bool flat(WidgetTester tester) =>
    find.byKey(const ValueKey('cycle-strip')).evaluate().isNotEmpty &&
    find.byType(CycleRing).evaluate().isEmpty;

void main() {
  testWidgets('a tap on the ring lays the cycle flat, with its steps', (
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
    // The same cycle as a line, and under it its steps with their dates:
    // ranges, like the estimates they come from.
    expect(flat(tester), isTrue);
    expect(find.text('Period in 5 to 11 days'), findsOneWidget);
    expect(find.text('Period started on Feb 28'), findsOneWidget);
    expect(
      find.text('Period expected between Mar 25 and Mar 31'),
      findsOneWidget,
    );
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
      find.bySemanticsLabel('Afficher le cycle en ligne, avec ses étapes'),
      findsOneWidget,
    );
    await tapVisible(tester, _ring);
    expect(flat(tester), isTrue);
    expect(find.bySemanticsLabel('Afficher le jour du cycle'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('it switches during a period too, for the one after', (
    tester,
  ) async {
    final harness = Harness(tester, today: CalendarDay(2026, 3, 1));
    await harness.seed(days: threePeriods());
    await harness.pumpApp();
    expect(middle(tester), ['Day', '2']);

    await tapVisible(tester, _ring);
    expect(flat(tester), isTrue);
    expect(find.text('Period in 24 to 30 days'), findsOneWidget);
    expect(find.textContaining('Next period expected between'), findsOneWidget);
  });

  testWidgets('from the first day after the first launch', (tester) async {
    final harness = Harness(tester);
    await harness.pumpApp();
    await finishSetup(tester, lastPeriod: harness.today);
    expect(middle(tester), ['Day', '1']);

    await tapVisible(tester, _ring);
    expect(flat(tester), isTrue);
    expect(find.text('Period in 21 to 35 days'), findsOneWidget);
  });

  testWidgets('a tap anywhere on the card does it, not only on the ring', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    await tapVisible(tester, find.text('Period in 5 to 11 days'));
    expect(flat(tester), isTrue);
    await tapVisible(tester, find.byKey(const ValueKey('cycle-day')));
    expect(middle(tester), ['Day', '21']);
  });

  testWidgets('two dots show that there is another view', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();
    expect(find.byKey(const ValueKey('ring-dots')), findsOneWidget);

    // None when there is nothing to switch to.
    harness.now = DateTime(2026, 11, 19, 12);
    await harness.pumpApp();
    expect(find.byKey(const ValueKey('ring-dots')), findsNothing);
  });

  testWidgets('nor when nothing is logged', (tester) async {
    final harness = Harness(tester);
    await harness.pumpApp();
    await tapVisible(tester, find.byKey(const ValueKey('onboarding-skip')));

    expect(_ring, findsNothing);
    expect(middle(tester), ['Day', '–']);
  });

  group('going around the ring', () {
    /// A finger put on the line of the ring at [day], and lifted.
    Future<void> touchDay(WidgetTester tester, int day, int totalDays) async {
      final ring = find.byType(CycleRing);
      await tester.ensureVisible(ring);
      await tester.pumpAndSettle();
      final size = tester.getSize(ring).width;
      await tester.tapAt(
        tester.getTopLeft(ring) + CycleRing.positionOf(day, size, totalDays),
      );
      await tester.pumpAndSettle();
    }

    final panel = find.byKey(const ValueKey('explore-panel'));
    Finder inPanel(String text) =>
        find.descendant(of: panel, matching: find.text(text));

    testWidgets('a finger on a past day shows its date and what was logged', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();
      expect(find.byKey(const ValueKey('ring-hint')), findsOneWidget);

      // The ring stands for 32 days: 21 gone by, and up to 11 to come.
      await touchDay(tester, 2, 32);
      expect(middle(tester), ['Day', '2']);
      expect(inPanel('Sunday, March 1'), findsOneWidget);
      expect(inPanel('Day 2 of your cycle'), findsOneWidget);
      expect(inPanel('Logged: Period: Medium'), findsOneWidget);
      expect(find.byKey(const ValueKey('ring-hint')), findsNothing);
    });

    testWidgets('a day to come says what is estimated, and cannot be opened', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();

      await touchDay(tester, 28, 32);
      expect(inPanel('Friday, March 27'), findsOneWidget);
      expect(
        inPanel('Within the range where your next period is estimated.'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('explore-open')), findsNothing);

      // The estimated fertile window comes with its warning.
      await touchDay(tester, 15, 32);
      expect(
        inPanel(
          'Within your estimated fertile window. An estimate: neither '
          'contraception nor a diagnosis.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('sliding goes from day to day, with a tick at each', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();
      final ring = find.byType(CycleRing);
      final size = tester.getSize(ring).width;
      final origin = tester.getTopLeft(ring);

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

      final finger = await tester.startGesture(
        origin + CycleRing.positionOf(5, size, 32),
      );
      await tester.pump();
      expect(middle(tester), ['Day', '5']);
      for (final day in [6, 7, 8]) {
        await finger.moveTo(origin + CycleRing.positionOf(day, size, 32));
        await tester.pump();
        expect(middle(tester), ['Day', '$day']);
      }
      await finger.up();
      await tester.pumpAndSettle();
      expect(ticks, hasLength(4));
      // The day stays shown once the finger is lifted.
      expect(middle(tester), ['Day', '8']);
    });

    testWidgets('a past day opens its page of the journal', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();

      await touchDay(tester, 10, 32);
      expect(inPanel('Nothing logged on that day.'), findsOneWidget);
      await tapVisible(tester, find.byKey(const ValueKey('explore-open')));
      await tapVisible(tester, find.byKey(const ValueKey('pain-mild')));
      await tapVisible(tester, find.byKey(const ValueKey('day-done')));
      expect(
        await harness.read(
          (store) => store.database.readDay(CalendarDay(2026, 3, 9))?.pain,
        ),
        PainLevel.mild,
      );
      expect(inPanel('Logged: Pain: Mild'), findsOneWidget);
    });

    testWidgets('a tap elsewhere, or the button, comes back to today', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();

      await touchDay(tester, 10, 32);
      await tapVisible(tester, find.byKey(const ValueKey('explore-back')));
      expect(panel, findsNothing);
      expect(middle(tester), ['Day', '21']);

      await touchDay(tester, 10, 32);
      await tapVisible(tester, find.text('Day 10 of your cycle'));
      expect(panel, findsNothing);
      expect(find.text('Period in 5 to 11 days'), findsOneWidget);
    });

    testWidgets('recalls what usually comes around the day touched', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(
        days: [
          ...threePeriods(),
          // Day 25 of the two complete cycles.
          DayEntry(day: CalendarDay(2026, 1, 27), sleep: SleepQuality.poor),
          DayEntry(day: CalendarDay(2026, 2, 24), sleep: SleepQuality.poor),
        ],
      );
      await harness.pumpApp();

      await touchDay(tester, 25, 32);
      expect(inPanel('Usually around this day: Sleep: Poor'), findsOneWidget);
    });

    testWidgets('a screen reader goes through it like a slider', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp(locale: 'fr');

      final node = tester.getSemantics(_ring);
      expect(node.value, 'Jour 21 de ton cycle, vendredi 20 mars');
      tester.binding.performSemanticsAction(
        SemanticsActionEvent(
          type: SemanticsAction.decrease,
          nodeId: node.id,
          viewId: tester.view.viewId,
        ),
      );
      await tester.pumpAndSettle();
      expect(middle(tester), ['Jour', '20']);
      expect(
        tester.getSemantics(_ring).value,
        'Jour 20 de ton cycle, jeudi 19 mars',
      );
      semantics.dispose();
    });
  });

  testWidgets('during a period, says how long it may still last', (
    tester,
  ) async {
    final harness = Harness(tester, today: CalendarDay(2026, 3, 1));
    await harness.seed(days: threePeriods());
    await harness.pumpApp();
    expect(find.textContaining('going by your past periods'), findsOneWidget);
  });

  testWidgets('and says nothing of it before two past periods', (tester) async {
    final harness = Harness(tester);
    await harness.pumpApp();
    await finishSetup(tester, lastPeriod: harness.today);
    expect(find.textContaining('past periods'), findsNothing);
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
      expect(flat(tester), isTrue);
      await tapVisible(tester, _ring);

      // And with a day of the ring looked at.
      final ring = find.byType(CycleRing);
      await tester.ensureVisible(ring);
      await tester.pumpAndSettle();
      await tester.tapAt(
        tester.getTopLeft(ring) +
            CycleRing.positionOf(15, tester.getSize(ring).width, 32),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('explore-panel')), findsOneWidget);
    });
  }

  group('the ring is open at the top', () {
    const size = 168.0;

    test('every day is found again where it is drawn', () {
      for (final total in [21, 28, 35, 45]) {
        for (var day = 1; day <= total; day++) {
          expect(
            CycleRing.dayAt(
              CycleRing.positionOf(day, size, total),
              size,
              total,
            ),
            day,
          );
        }
      }
    });

    test('the cycle starts on one side of the opening, ends on the other', () {
      // Day 1 is right of the top, the last day left of it: the end of the
      // cycle is not drawn against its start.
      expect(CycleRing.positionOf(1, size, 28).dx, greaterThan(size / 2));
      expect(CycleRing.positionOf(28, size, 28).dx, lessThan(size / 2));
      // A finger in the opening gets the nearest end.
      final radius = CycleRing.radiusFor(size);
      expect(
        CycleRing.dayAt(Offset(size / 2 + 2, size / 2 - radius), size, 28),
        1,
      );
      expect(
        CycleRing.dayAt(Offset(size / 2 - 2, size / 2 - radius), size, 28),
        28,
      );
    });
  });

  testWidgets('the line shows how long the period going on may last', (
    tester,
  ) async {
    final harness = Harness(tester, today: CalendarDay(2026, 3, 1));
    await harness.seed(days: threePeriods());
    await harness.pumpApp(locale: 'fr');

    await tapVisible(tester, _ring);
    expect(flat(tester), isTrue);
    expect(find.text('Règles commencées le 28 févr.'), findsOneWidget);
    expect(find.text('Règles dans 24 à 30 jours'), findsOneWidget);
  });
}
