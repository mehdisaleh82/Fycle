import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/file_gateway.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:material_ui/material_ui.dart';

import '../data/fakes.dart';
import 'harness.dart';

void main() {
  testWidgets('first launch asks two things and shows the notice', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    expect(find.text('Welcome to Fycle'), findsOneWidget);
    expect(find.text('When did your last period start?'), findsOneWidget);
    expect(find.text('How long is your cycle usually?'), findsOneWidget);
    expect(
      find.textContaining('not a method of contraception'),
      findsOneWidget,
    );
    // Nothing can start before a date is chosen.
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });

  testWidgets('first launch is shown in French', (tester) async {
    final harness = Harness(tester);
    await harness.pumpApp(locale: 'fr');

    expect(find.text('Bienvenue dans Fycle'), findsOneWidget);
    expect(
      find.textContaining('ni une méthode de contraception'),
      findsOneWidget,
    );
  });

  testWidgets('a date and a cycle length lead to a predicted range', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await tester.tap(find.text('Choose a date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Sunday, March 1, 2026'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '30');
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    // 1 March + 30 days, 5 days on each side: a range, never a single date.
    expect(
      find.text('Period expected between Mar 26 and Apr 5'),
      findsOneWidget,
    );
    final stored = await harness.read(
      (store) => (store.database.flowByDay(), store.database.usualCycleLength),
    );
    expect(stored.$1, {CalendarDay(2026, 3, 1): FlowIntensity.medium});
    expect(stored.$2, 30);
  });

  testWidgets('today or yesterday is chosen in one tap', (tester) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await tester.tap(find.byKey(const ValueKey('last-period-yesterday')));
    await tester.pumpAndSettle();
    expect(find.text('Thursday, March 19, 2026'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('last-period-today')));
    await tester.pumpAndSettle();
    expect(find.text('Friday, March 20, 2026'), findsOneWidget);

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    final flow = await harness.read((store) => store.database.flowByDay());
    expect(flow, {CalendarDay(2026, 3, 20): FlowIntensity.medium});
  });

  testWidgets('the estimate shows as soon as a date is chosen', (tester) async {
    final harness = Harness(tester);
    await harness.pumpApp();
    expect(find.byKey(const ValueKey('estimate-preview')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('last-period-today')));
    await tester.pumpAndSettle();

    // 20 March + 28 days, 7 days on each side: a range, never a single date.
    expect(
      find.text('Next period expected between Apr 10 and Apr 24'),
      findsOneWidget,
    );
    expect(find.textContaining('based on a cycle of 28 days'), findsOneWidget);

    // It follows the usual length as it is typed.
    await tester.enterText(find.byType(TextField), '30');
    await tester.pumpAndSettle();
    expect(
      find.text('Next period expected between Apr 14 and Apr 24'),
      findsOneWidget,
    );
    expect(find.textContaining('you gave (30 days)'), findsOneWidget);

    // Nothing is saved before "Start".
    final days = await harness.read((store) => store.database.readDays());
    expect(days, isEmpty);
  });

  testWidgets('the estimate is shown in French', (tester) async {
    final harness = Harness(tester);
    await harness.pumpApp(locale: 'fr');

    await tester.tap(find.text('Hier'));
    await tester.pumpAndSettle();

    expect(
      find.text('Prochaines règles prévues entre le 9 avr. et le 23 avr.'),
      findsOneWidget,
    );
    expect(find.text('Je ne sais plus'), findsOneWidget);
  });

  testWidgets('a date long past shows no estimate that is already behind', (
    tester,
  ) async {
    final harness = Harness(tester, today: CalendarDay(2026, 6, 20));
    await harness.pumpApp();

    await tester.tap(find.text('Choose a date'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Wednesday, April 1, 2026'), findsOneWidget);
    expect(find.byKey(const ValueKey('estimate-preview')), findsNothing);
  });

  testWidgets('the app can be entered without a date, once and for all', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await tester.tap(find.text("I don't remember"));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Fycle'), findsNothing);
    expect(find.text('No estimate yet'), findsOneWidget);
    expect(find.text('Log today'), findsOneWidget);
    final days = await harness.read((store) => store.database.readDays());
    expect(days, isEmpty);

    // The question is not asked again at the next launch.
    await harness.pumpApp();
    expect(find.text('Welcome to Fycle'), findsNothing);
    expect(find.text('No estimate yet'), findsOneWidget);
  });

  testWidgets('a cycle length out of range is refused', (tester) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await tester.tap(find.text('Choose a date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '9');
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a number between 15 and 90.'), findsOneWidget);
    expect(find.text('Welcome to Fycle'), findsOneWidget);
  });

  testWidgets('the home screen comes straight up once data exists', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: periodFrom(CalendarDay(2026, 3, 1)));
    await harness.pumpApp();

    expect(find.text('Welcome to Fycle'), findsNothing);
    expect(find.text('Log today'), findsOneWidget);
  });

  group('database whose key is gone', () {
    Future<Harness> unreadable(WidgetTester tester) async {
      final harness = Harness(tester);
      await harness.seed(days: periodFrom(CalendarDay(2026, 3, 1)));
      harness.keyStore.key = null; // As after restoring the phone.
      await harness.pumpApp();
      return harness;
    }

    testWidgets('is explained, with two ways out', (tester) async {
      await unreadable(tester);

      expect(find.text('Your data cannot be read'), findsOneWidget);
      expect(find.text('Start fresh'), findsOneWidget);
      expect(find.text('Restore from a backup file'), findsOneWidget);
    });

    testWidgets('nothing is erased without a confirmation', (tester) async {
      final harness = await unreadable(tester);

      await tester.tap(find.text('Start fresh'));
      await tester.pumpAndSettle();
      expect(find.text('Erase the unreadable data?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Your data cannot be read'), findsOneWidget);
      expect(harness.dir.listSync(), isNotEmpty);
    });

    testWidgets('starting fresh leads to the first-launch screen', (
      tester,
    ) async {
      await unreadable(tester);

      await tester.tap(find.text('Start fresh'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Erase'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Fycle'), findsOneWidget);
    });

    testWidgets('a backup file can be restored instead', (tester) async {
      final harness = await unreadable(tester);
      final backup = await tester.runAsync(
        () => fastCodec.encode(sampleData(), 'made-up password'),
      );
      harness.files.nextPick = PickedFile(name: 'old.fycle', bytes: backup!);

      await tester.tap(find.text('Restore from a backup file'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Erase'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogField(), 'made-up password');
      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();

      expect(find.text('Log today'), findsOneWidget);
      final length = await harness.read(
        (store) => store.database.usualCycleLength,
      );
      expect(length, 29);
    });
  });
}
