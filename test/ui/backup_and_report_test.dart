import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/cycle_history.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/life_stage.dart';
import 'package:fycle/domain/symptom.dart';
import 'package:fycle/l10n/app_localizations.dart';
import 'package:fycle/ui/doctor_pdf.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import '../data/fakes.dart';
import 'harness.dart';

/// Three periods, 28 days apart, the last one on 28 February 2026.
List<DayEntry> threePeriods() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28)),
];

void main() {
  Finder key(String name) => find.byKey(ValueKey(name));
  Future<void> tap(WidgetTester tester, String name) =>
      tapVisible(tester, key(name));

  group('the report for the doctor, as a PDF', () {
    // Outside the app, the formats of dates are loaded by hand.
    setUpAll(initializeDateFormatting);

    for (final locale in ['en', 'fr']) {
      test('is made on the phone, accents included ($locale)', () async {
        final days = [
          ...threePeriods(),
          DayEntry(
            day: CalendarDay(2026, 3, 10),
            symptoms: const {Symptom.migraine, Symptom.hotFlashes},
          ),
        ];
        final flow = {
          for (final entry in days)
            if (entry.flow != null) entry.day: FlowIntensity.medium,
        };
        final bytes = await buildDoctorPdf(
          lookupAppLocalizations(Locale(locale)),
          today: CalendarDay(2026, 3, 20),
          cycles: cycleHistory(flow),
          days: days,
          followsChanges: true,
          age: 42,
        );
        expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
        expect(bytes.length, greaterThan(800));
      });
    }

    test('holds with nothing logged', () async {
      final bytes = await buildDoctorPdf(
        lookupAppLocalizations(const Locale('fr')),
        today: CalendarDay(2026, 3, 20),
        cycles: const [],
        days: const [],
        followsChanges: false,
      );
      expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
    });
  });

  group('the automatic backup', () {
    testWidgets('asks for its password once, then writes by itself', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();

      await tapVisible(tester, find.byIcon(Icons.settings_outlined));
      await tap(tester, 'auto-backup');
      await tester.enterText(dialogField(), 'made-up password');
      await tester.enterText(dialogField(1), 'made-up password');
      await tap(tester, 'auto-backup-confirm');

      // Written at once, encrypted with the password she gave.
      expect(harness.autoBackup.written, hasLength(1));
      final data = await tester.runAsync(
        () => fastCodec.decode(
          harness.autoBackup.written.single,
          'made-up password',
        ),
      );
      expect(data!.days, hasLength(threePeriods().length));

      // Not again the same day, whatever she logs.
      await openHome(tester);
      await tap(tester, 'quick-pain-mild');
      expect(harness.autoBackup.written, hasLength(1));

      // The next day, at the first launch.
      harness.now = harness.now.add(const Duration(days: 1));
      await harness.pumpApp();
      expect(harness.autoBackup.written, hasLength(2));
    });

    testWidgets('turned off, forgets its password and writes nothing', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();

      await tapVisible(tester, find.byIcon(Icons.settings_outlined));
      await tap(tester, 'auto-backup');
      await tester.enterText(dialogField(), 'made-up password');
      await tester.enterText(dialogField(1), 'made-up password');
      await tap(tester, 'auto-backup-confirm');
      await tap(tester, 'auto-backup');

      expect(harness.backupPasswords.password, isNull);
      harness.now = harness.now.add(const Duration(days: 1));
      await harness.pumpApp();
      expect(harness.autoBackup.written, hasLength(1));
    });

    testWidgets('is off until she turns it on', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();

      expect(harness.autoBackup.written, isEmpty);
    });
  });

  group('each profile has its own home', () {
    testWidgets('discovering: a few plain facts', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods(), profile: Profile.discovering);
      await harness.pumpApp(locale: 'fr');

      expect(key('learn-card'), findsOneWidget);
      expect(find.text('Ton cycle, en quelques mots'), findsOneWidget);
    });

    testWidgets('tracking: none of that', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods(), profile: Profile.tracking);
      await harness.pumpApp();

      expect(key('learn-card'), findsNothing);
      expect(key('kpi-fertile'), findsNothing);
    });

    testWidgets('conceiving: the estimated fertile window among her figures', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods(), profile: Profile.conceiving);
      await harness.pumpApp();

      expect(key('kpi-fertile'), findsOneWidget);
      expect(
        tester.widget<Text>(key('kpi-fertile-caption')).data,
        'an estimate, not a certainty',
      );
    });

    testWidgets('pregnant: a bleeding is not called a period', (tester) async {
      final harness = Harness(tester);
      await harness.seed(
        days: threePeriods(),
        profile: Profile.pregnant,
        pregnancyStart: CalendarDay(2026, 2, 28),
      );
      await harness.pumpApp();

      expect(find.text('Bleeding today'), findsOneWidget);
    });
  });
}
