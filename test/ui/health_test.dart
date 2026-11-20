import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/pain_level.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

void main() {
  Future<void> openImport(WidgetTester tester) async {
    await tapVisible(tester, find.byIcon(Icons.settings_outlined));
    await tapVisible(tester, find.byKey(const ValueKey('health-import')));
  }

  testWidgets('copies the period days the phone knows into the journal', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(
      days: [
        // A day she logged herself, with more than the flow.
        DayEntry(
          day: CalendarDay(2026, 2, 28),
          flow: FlowIntensity.light,
          pain: PainLevel.mild,
        ),
      ],
    );
    harness.health.days = {
      CalendarDay(2026, 1, 31): FlowIntensity.heavy,
      CalendarDay(2026, 2, 1): FlowIntensity.medium,
      // Already in her journal: left as she logged it.
      CalendarDay(2026, 2, 28): FlowIntensity.heavy,
    };
    await harness.pumpApp();

    await openImport(tester);
    expect(
      find.text('2 days of period copied into your journal.'),
      findsOneWidget,
    );
    await tapVisible(tester, find.text('OK'));

    final flow = await harness.read((store) => store.database.flowByDay());
    expect(flow, {
      CalendarDay(2026, 1, 31): FlowIntensity.heavy,
      CalendarDay(2026, 2, 1): FlowIntensity.medium,
      CalendarDay(2026, 2, 28): FlowIntensity.light,
    });
    final kept = await harness.read(
      (store) => store.database.readDay(CalendarDay(2026, 2, 28)),
    );
    expect(kept?.pain, PainLevel.mild);
  });

  testWidgets('says so when nothing can be read, and changes nothing', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
    await harness.pumpApp(locale: 'fr');

    await openImport(tester);
    expect(
      find.textContaining("Aucun jour de règles n'a pu être lu"),
      findsOneWidget,
    );
    await tapVisible(tester, find.text('OK'));
    final days = await harness.read((store) => store.database.readDays());
    expect(days, hasLength(4));
  });
}
