import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/ui/art.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

void main() {
  test('every picture has its file, and every file is used', () {
    final files = {
      for (final file in Directory('assets/art').listSync())
        file.uri.pathSegments.last,
    };
    expect(files, {for (final art in Art.values) '${art.name}.png'});
  });

  testWidgets('the first questions come with a picture', (tester) async {
    final harness = Harness(tester);
    await harness.pumpApp();
    await tapVisible(tester, find.byKey(const ValueKey('onboarding-next')));
    await setupTo(tester, 'Before your period, you often get…');
    expect(find.byKey(const ValueKey('art-energy')), findsOneWidget);
    await finishSetup(tester, lastPeriod: CalendarDay(2026, 3, 1));
  });
}
