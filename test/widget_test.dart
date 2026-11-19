import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/ui/app.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('home screen is shown in English', (tester) async {
    await tester.pumpWidget(const FycleApp(locale: Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Fycle'), findsOneWidget);
    expect(find.text('Nothing leaves this phone.'), findsOneWidget);
  });

  testWidgets('home screen is shown in French', (tester) async {
    await tester.pumpWidget(const FycleApp(locale: Locale('fr')));
    await tester.pumpAndSettle();

    expect(find.text('Fycle'), findsOneWidget);
    expect(find.text('Rien ne quitte ce téléphone.'), findsOneWidget);
  });
}
