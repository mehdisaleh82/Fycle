import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'app_lock.dart';
import 'root_screen.dart';
import 'theme.dart';

/// Root widget: localization, theme, the optional app lock and the first
/// screen.
class FycleApp extends StatefulWidget {
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
  State<FycleApp> createState() => _FycleAppState();
}

class _FycleAppState extends State<FycleApp> {
  late final AppLock _lock = AppLock(widget.environment.deviceAuth);

  @override
  void dispose() {
    _lock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: widget.locale,
      // The generated delegate list still points at the pre-material_ui
      // classes, so the list is spelled out here.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: fycleTheme(Brightness.light),
      darkTheme: fycleTheme(Brightness.dark),
      themeMode: widget.themeMode ?? ThemeMode.system,
      // Above the navigator, so that the lock covers every screen, dialog
      // and panel.
      builder: (context, child) => LockGate(lock: _lock, child: child!),
      home: RootScreen(environment: widget.environment, lock: _lock),
    );
  }
}
