import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'root_screen.dart';
import 'theme.dart';

/// Root widget: localization, theme and the first screen.
class FycleApp extends StatelessWidget {
  const FycleApp({
    super.key,
    this.locale,
    this.themeMode,
    this.environment = const AppEnvironment.device(),
  });

  /// Forces a locale. Left null in production so the system language applies.
  final Locale? locale;

  /// Forces light or dark. Left null in production so the phone decides.
  final ThemeMode? themeMode;

  final AppEnvironment environment;

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
      theme: fycleTheme(Brightness.light),
      darkTheme: fycleTheme(Brightness.dark),
      themeMode: themeMode ?? ThemeMode.system,
      home: RootScreen(environment: environment),
    );
  }
}
