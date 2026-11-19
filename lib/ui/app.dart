import 'package:material_ui/material_ui.dart';

import '../data/appearance.dart';
import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'app_lock.dart';
import 'launch_animation.dart';
import 'root_screen.dart';
import 'theme.dart';

/// Root widget: localization, theme, the optional app lock and the first
/// screen.
class FycleApp extends StatefulWidget {
  const FycleApp({
    super.key,
    this.locale,
    this.themeMode,
    this.textDirection,
    this.environment = const AppEnvironment.device(),
  });

  /// Forces a locale. Left null in production so the system language applies.
  final Locale? locale;

  /// Forces light or dark. Left null in production, where the appearance
  /// chosen in the settings applies: light by default.
  final ThemeMode? themeMode;

  /// Forces the writing direction. Left null in production, where it follows
  /// the language.
  final TextDirection? textDirection;

  final AppEnvironment environment;

  @override
  State<FycleApp> createState() => _FycleAppState();
}

class _FycleAppState extends State<FycleApp> {
  late final AppLock _lock = AppLock(widget.environment.deviceAuth);

  /// Light until the store is open and says otherwise.
  Appearance _appearance = Appearance.light;

  void _setAppearance(Appearance appearance) {
    if (appearance != _appearance) {
      setState(() => _appearance = appearance);
    }
  }

  ThemeMode get _themeMode => switch (_appearance) {
    Appearance.light => ThemeMode.light,
    Appearance.dark => ThemeMode.dark,
    Appearance.system => ThemeMode.system,
  };

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
      themeMode: widget.themeMode ?? _themeMode,
      // Above the navigator, so that the lock covers every screen, dialog
      // and panel.
      builder: (context, child) {
        // The launch animation plays over everything, the lock included,
        // while the app gets ready underneath.
        final gate = LaunchAnimation(
          child: LockGate(lock: _lock, child: child!),
        );
        final direction = widget.textDirection;
        return direction == null
            ? gate
            : Directionality(textDirection: direction, child: gate);
      },
      home: RootScreen(
        environment: widget.environment,
        lock: _lock,
        onAppearance: _setAppearance,
      ),
    );
  }
}
