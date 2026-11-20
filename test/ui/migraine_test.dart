import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/csv_export.dart';
import 'package:fycle/data/fycle_data.dart';
import 'package:fycle/data/fycle_database.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/cycle_history.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/migraine.dart';
import 'package:fycle/domain/pain_level.dart';
import 'package:fycle/domain/reminders.dart';
import 'package:fycle/domain/symptom.dart';
import 'package:material_ui/material_ui.dart';

import '../data/fakes.dart';
import 'harness.dart';

void main() {
  const detail = MigraineDetail(
    intensity: PainLevel.severe,
    duration: MigraineDuration.day,
    medication: true,
  );
  final day = CalendarDay(2026, 3, 10);

  group('the detail of a migraine', () {
    test('goes with the migraine ticked, and only with it', () {
      final ticked = DayEntry(
        day: day,
        symptoms: const {Symptom.migraine},
        migraine: detail,
      );
      expect(ticked.migraine, detail);
      expect(
        DayEntry(day: day, symptoms: const {}, migraine: detail).migraine,
        isNull,
      );
      expect(ticked.withSymptoms(const {}).migraine, isNull);
    });

    test('is kept in the database', () {
      final database = FycleDatabase.inMemory();
      addTearDown(database.close);
      database.saveDay(
        DayEntry(
          day: day,
          symptoms: const {Symptom.migraine},
          migraine: detail,
        ),
      );
      expect(database.readDay(day)?.migraine, detail);
    });

    test('travels with a backup', () async {
      final data = FycleData(
        days: [
          DayEntry(
            day: day,
            symptoms: const {Symptom.migraine},
            migraine: detail,
          ),
        ],
      );
      final bytes = await fastCodec.encode(data, 'made-up password');
      final read = await fastCodec.decode(bytes, 'made-up password');
      expect(read.days.single.migraine, detail);
    });

    test('adds a column to the spreadsheet export only when there is one', () {
      final plain = daysToCsv([DayEntry(day: day, pain: PainLevel.mild)]);
      expect(plain, isNot(contains('migraine')));
      final withOne = daysToCsv([
        DayEntry(
          day: day,
          symptoms: const {Symptom.migraine},
          migraine: detail,
        ),
      ]);
      expect(withOne, contains('note,migraine'));
      expect(withOne, contains('severe; day; medication'));
    });
  });

  test('migraines are counted and set against the periods', () {
    final today = CalendarDay(2026, 3, 20);
    final flow = {
      for (var i = 0; i < 4; i++)
        CalendarDay(2026, 2, 28).addDays(i): FlowIntensity.medium,
    };
    DayEntry migraine(CalendarDay on, [MigraineDetail? noted]) => DayEntry(
      day: on,
      flow: flow[on],
      symptoms: const {Symptom.migraine},
      migraine: noted,
    );
    final summary = migraineSummaryOn(
      today,
      cycles: cycleHistory(flow),
      days: [
        // Two days before the period, then during it, then far from it.
        migraine(CalendarDay(2026, 2, 26), detail),
        migraine(CalendarDay(2026, 3, 1)),
        migraine(
          CalendarDay(2026, 3, 12),
          const MigraineDetail(intensity: PainLevel.severe),
        ),
        DayEntry(day: CalendarDay(2026, 3, 13), pain: PainLevel.mild),
      ],
    )!;
    expect(summary.days, 3);
    expect(summary.duringPeriod, 2);
    expect(summary.withMedication, 1);
    expect(summary.commonIntensity, PainLevel.severe);
    expect(migraineSummaryOn(today, cycles: const [], days: const []), isNull);
  });

  testWidgets('ticking a migraine offers to say more about it', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
    await harness.pumpApp();
    await tapVisible(tester, find.byKey(const ValueKey('log-today')));

    expect(find.byKey(const ValueKey('migraine-severe')), findsNothing);
    await tapVisible(tester, find.byKey(const ValueKey('symptom-migraine')));
    await tapVisible(tester, find.byKey(const ValueKey('migraine-severe')));
    await tapVisible(tester, find.byKey(const ValueKey('migraine-day')));
    await tapVisible(
      tester,
      find.byKey(const ValueKey('migraine-medication-true')),
    );
    await tapVisible(tester, find.byKey(const ValueKey('day-done')));

    final entry = await harness.read(
      (store) => store.database.readDay(harness.today),
    );
    expect(entry?.migraine, detail);

    await openReviewDetail(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('migraine-card')));
    expect(
      find.text('1 day with a migraine in the last 90 days'),
      findsOneWidget,
    );
    // It counts; it says nothing of treatments.
    expect(find.textContaining('should'), findsNothing);
  });

  group('the contraception reminder', () {
    test('comes every day at the time chosen, logged or not', () {
      final today = CalendarDay(2026, 3, 20);
      final planned = planReminders(
        settings: ReminderSettings(
          contraceptionEnabled: true,
          contraceptionTime: ClockTime(7, 30),
        ),
        today: today,
        now: ClockTime(8, 0),
        loggedDays: {today.addDays(1)},
      );
      // Today's time has gone by: it starts tomorrow.
      expect(planned.first.day, today.addDays(1));
      expect(planned.first.kind, ReminderKind.contraception);
      expect(planned.first.time, ClockTime(7, 30));
      expect(planned, hasLength(dailyReminderHorizonDays - 1));
    });

    testWidgets('is turned on from the settings, with neutral words', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
      await harness.pumpApp();
      await tapVisible(tester, find.byIcon(Icons.settings_outlined));
      await tapVisible(
        tester,
        find.byKey(const ValueKey('contraception-reminder')),
      );

      final settings = await harness.read(
        (store) => store.database.reminderSettings,
      );
      expect(settings.contraceptionEnabled, isTrue);
      // What shows on the lock screen says nothing of what it is for.
      expect(harness.reminders.scheduled, isNotEmpty);
      for (final reminder in harness.reminders.scheduled) {
        expect(reminder.body, 'It is time.');
      }
    });
  });
}
