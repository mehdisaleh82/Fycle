import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'home_screen.dart';

/// Root widget: localization, theme and the first screen.
class FycleApp extends StatelessWidget {
  const FycleApp({super.key, this.locale});

  /// Forces a locale. Left null in production so the system language applies.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: locale,
      // The generated delegate list still points at the pre-material_ui
      // classes, so the list is spelled out here.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.teal)),
      darkTheme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
