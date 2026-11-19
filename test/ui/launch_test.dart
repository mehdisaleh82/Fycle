import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/ui/launch_animation.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

final _animation = find.byKey(const ValueKey('launch-animation'));

/// Three made-up periods, 28 days apart.
List<DayEntry> threePeriods() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28)),
];

/// Starts the app without waiting for the launch animation to end.
Future<void> launch(WidgetTester tester, Harness harness) =>
    harness.pumpApp(settle: false);

void main() {
  testWidgets('plays once at launch, then leaves the app', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await launch(tester, harness);
    expect(_animation, findsOneWidget);

    await tester.pump(LaunchAnimation.duration ~/ 2);
    expect(_animation, findsOneWidget);
    await tester.pumpAndSettle();
    expect(_animation, findsNothing);
    expect(find.byKey(const ValueKey('cycle-day')), findsOneWidget);
  });

  testWidgets('a tap skips it', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await launch(tester, harness);

    await tester.tap(_animation);
    await tester.pump();
    expect(_animation, findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('is not played when the phone asks for reduced motion', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await launch(tester, harness);
    expect(_animation, findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('does not come back when the app returns to the front', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();
    expect(_animation, findsNothing);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(_animation, findsNothing);
    await tester.pumpAndSettle();
  });
}
