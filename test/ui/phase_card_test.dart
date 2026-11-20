import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/cycle_phase.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/life_stage.dart';
import 'package:fycle/domain/start_profile.dart';
import 'package:fycle/domain/symptom.dart';
import 'package:fycle/l10n/app_localizations.dart';
import 'package:fycle/ui/phase_card.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

List<DayEntry> threePeriods() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28)),
];

void main() {
  Finder key(String name) => find.byKey(ValueKey(name));
  String textOf(WidgetTester tester, String name) =>
      tester.widget<Text>(key(name)).data!;

  Future<void> show(WidgetTester tester, String name) =>
      tester.scrollUntilVisible(
        key(name),
        200,
        scrollable: find.byType(Scrollable).first,
      );

  testWidgets('the phase of the day, a tip, and the rest one tap away', (
    tester,
  ) async {
    // 20 March: day 21, the period estimated in 5 to 11 days. With three
    // periods only, the estimated middle is wide and still reaches today:
    // the card says what the ring shows.
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    await show(tester, 'phase-more');
    expect(textOf(tester, 'phase-name'), 'Middle of your cycle · estimate');
    final l10n = lookupAppLocalizations(const Locale('en'));
    final text = phaseText(l10n, CyclePhase.midCycle);
    expect(text.tips, contains(textOf(tester, 'phase-tip')));
    // Closed at first: the home stays short.
    expect(key('phase-hormones'), findsNothing);

    await tapVisible(tester, key('phase-more'));
    await show(tester, 'phase-note');
    expect(textOf(tester, 'phase-hormones'), text.hormones);
    expect(textOf(tester, 'phase-mood'), text.mood);
    expect(textOf(tester, 'phase-body'), text.body);
    // Said to be general, and awaiting review.
    expect(textOf(tester, 'phase-note'), contains('awaiting review'));
    // Nothing about her moment of life: she gave none.
    expect(key('phase-hers'), findsNothing);
  });

  testWidgets('her period is named without "estimate"', (tester) async {
    final harness = Harness(tester, today: CalendarDay(2026, 3, 1));
    await harness.seed(days: threePeriods());
    await harness.pumpApp(locale: 'fr');
    await show(tester, 'phase-name');
    expect(textOf(tester, 'phase-name'), 'Tes règles');
  });

  testWidgets('what she logged around this day is recalled', (tester) async {
    final harness = Harness(tester);
    await harness.seed(
      days: [
        ...threePeriods(),
        // Day 21 of the two cycles that ended.
        DayEntry(day: CalendarDay(2026, 1, 23), symptoms: {Symptom.bloating}),
        DayEntry(day: CalendarDay(2026, 2, 20), symptoms: {Symptom.bloating}),
      ],
    );
    await harness.pumpApp();
    await show(tester, 'phase-yours');
    expect(textOf(tester, 'phase-yours'), contains('Bloating'));
  });

  testWidgets('a cycle that is changing is said to follow it less', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(
      days: threePeriods(),
      profile: Profile.perimenopause,
      goals: {Goal.perimenopause},
      birthYear: 1978,
    );
    await harness.pumpApp();
    await show(tester, 'phase-more');
    await tapVisible(tester, key('phase-more'));
    await show(tester, 'phase-hers');
    expect(textOf(tester, 'phase-hers'), contains('rough guide'));
  });

  testWidgets('nothing during a pregnancy', (tester) async {
    final harness = Harness(tester);
    await harness.seed(
      days: threePeriods(),
      profile: Profile.pregnant,
      pregnancyStart: CalendarDay(2026, 2, 28),
    );
    await harness.pumpApp();
    expect(key('phase-card'), findsNothing);
  });

  testWidgets('nothing with a hormonal contraception', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.read(
      (store) => store.database.contraception = Contraception.hormonal,
    );
    await harness.pumpApp();
    expect(key('phase-card'), findsNothing);
  });

  test('every phase has its texts in both languages, French says "tu"', () {
    final formal = RegExp(r'(?<!rendez-)\b(vous|votre|vos)\b');
    for (final code in ['en', 'fr']) {
      final l10n = lookupAppLocalizations(Locale(code));
      for (final phase in CyclePhase.values) {
        final text = phaseText(l10n, phase);
        expect(text.tips, hasLength(tipsPerPhase), reason: phase.name);
        final all = [
          text.name,
          text.hormones,
          text.mood,
          text.body,
          ...text.tips,
          l10n.phaseNote,
          l10n.phasePerimenopause,
          l10n.phaseConceive,
          l10n.phaseDiscovering,
        ];
        for (final line in all) {
          expect(line.trim(), isNotEmpty, reason: '$code ${phase.name}');
          if (code == 'fr') {
            expect(formal.hasMatch(line.toLowerCase()), isFalse, reason: line);
          }
          // An estimate, never a promise nor a method (rule 7).
          for (final word in [
            'safe',
            'sans risque',
            'contracepti',
            'you will',
            'tu vas ',
          ]) {
            expect(line.toLowerCase(), isNot(contains(word)), reason: line);
          }
        }
      }
    }
  });
}
