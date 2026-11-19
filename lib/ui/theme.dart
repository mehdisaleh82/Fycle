import 'package:material_ui/material_ui.dart';

/// Light or dark theme of the app.
///
/// Night blue for headers and actions on an off-white page, outlined white
/// cards, generous rounding (docs/DECISIONS.md, decisions 61, 77 and 82).
/// The text uses the font of the system: nothing is bundled or downloaded.
ThemeData fycleTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = dark ? _darkScheme : _lightScheme;
  final base = ThemeData(colorScheme: scheme);
  final text = base.textTheme;
  // Headers are night blue on the light page.
  final header = dark ? scheme.onSurface : scheme.primary;
  const pill = StadiumBorder();
  const buttonSize = Size(64, 52);
  final buttonText = text.labelLarge?.copyWith(fontWeight: FontWeight.w700);

  OutlineInputBorder fieldBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    textTheme: text.copyWith(
      headlineMedium: text.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarThemeData(
      backgroundColor: scheme.surface,
      foregroundColor: header,
      scrolledUnderElevation: 0,
      titleTextStyle: text.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: header,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: FycleSurfaces.cardOf(brightness),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        // On a light page, a thin outline is what shows the card.
        side: dark ? BorderSide.none : BorderSide(color: scheme.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: pill,
        minimumSize: buttonSize,
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: pill,
        minimumSize: buttonSize,
        textStyle: buttonText,
        side: BorderSide(color: scheme.outline),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: pill, textStyle: buttonText),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 2,
      highlightElevation: 2,
      shape: pill,
      extendedTextStyle: buttonText,
      extendedPadding: const EdgeInsets.symmetric(horizontal: 28),
    ),
    chipTheme: ChipThemeData(
      shape: pill,
      side: BorderSide(color: scheme.outlineVariant),
      backgroundColor: FycleSurfaces.cardOf(brightness),
      selectedColor: scheme.primary,
      checkmarkColor: scheme.onPrimary,
      labelStyle: text.labelLarge?.copyWith(
        color: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.onSurface,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: FycleSurfaces.cardOf(brightness),
      border: fieldBorder(scheme.outlineVariant),
      enabledBorder: fieldBorder(scheme.outlineVariant),
      focusedBorder: fieldBorder(scheme.primary, 2),
      errorBorder: fieldBorder(scheme.error),
      focusedErrorBorder: fieldBorder(scheme.error, 2),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      modalBackgroundColor: scheme.surface,
      dragHandleColor: scheme.outlineVariant,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: FycleSurfaces.cardOf(brightness),
    ),
    listTileTheme: ListTileThemeData(iconColor: scheme.primary),
  );
}

// Night blue as the base, one sober amber accent kept for estimates, off-white
// and charcoal as neutrals, a quiet burgundy for period days. Neither pink
// nor bright red (docs/DECISIONS.md, decisions 77 and 82).
final _lightScheme =
    ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B2A4A),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF1B2A4A),
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: const Color(0xFFE3E8F2),
      onPrimaryContainer: const Color(0xFF1B2A4A),
      secondary: const Color(0xFF4A5568),
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: const Color(0xFFECE9E1),
      onSecondaryContainer: const Color(0xFF2B2F36),
      tertiary: const Color(0xFF4A5568),
      onTertiary: const Color(0xFFFFFFFF),
      tertiaryContainer: const Color(0xFFE3E8F2),
      onTertiaryContainer: const Color(0xFF1B2A4A),
      error: const Color(0xFFA63A2B),
      onError: const Color(0xFFFFFFFF),
      errorContainer: const Color(0xFFF9E3DE),
      onErrorContainer: const Color(0xFF5C1A10),
      surface: const Color(0xFFF7F5F0),
      onSurface: const Color(0xFF2B2F36),
      onSurfaceVariant: const Color(0xFF5A606B),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF2EFE9),
      surfaceContainer: const Color(0xFFEDEAE3),
      surfaceContainerHigh: const Color(0xFFE7E4DC),
      surfaceContainerHighest: const Color(0xFFE1DDD4),
      outline: const Color(0xFF7A808C),
      outlineVariant: const Color(0xFFE3E0D8),
    );

final _darkScheme =
    ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B2A4A),
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFAFC3EE),
      onPrimary: const Color(0xFF12203F),
      primaryContainer: const Color(0xFF26324F),
      onPrimaryContainer: const Color(0xFFDCE5F8),
      secondary: const Color(0xFFB9C1D1),
      onSecondary: const Color(0xFF232B3B),
      secondaryContainer: const Color(0xFF222C44),
      onSecondaryContainer: const Color(0xFFD5D9E2),
      tertiary: const Color(0xFFB9C1D1),
      onTertiary: const Color(0xFF232B3B),
      tertiaryContainer: const Color(0xFF26324F),
      onTertiaryContainer: const Color(0xFFDCE5F8),
      error: const Color(0xFFF2A99B),
      onError: const Color(0xFF4A130B),
      errorContainer: const Color(0xFF5C1F14),
      onErrorContainer: const Color(0xFFFFDAD3),
      surface: const Color(0xFF0F1626),
      onSurface: const Color(0xFFECE9E2),
      onSurfaceVariant: const Color(0xFFB4B9C4),
      surfaceContainerLowest: const Color(0xFF0A101D),
      surfaceContainerLow: const Color(0xFF151D30),
      surfaceContainer: const Color(0xFF1A2338),
      surfaceContainerHigh: const Color(0xFF222C44),
      surfaceContainerHighest: const Color(0xFF2B3650),
      outline: const Color(0xFF8C93A3),
      outlineVariant: const Color(0xFF38425A),
    );

/// Colour of the cards, fields and chips: white on the off-white page in
/// light mode, one step lighter than the page in dark mode.
abstract final class FycleSurfaces {
  static Color cardOf(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFF1A2338)
      : const Color(0xFFFFFFFF);
}

/// Colours of period days on the calendar. A logged period is a filled disc,
/// an expected one a ring: the shape tells them apart, not the colour alone.
final class PeriodColors {
  const PeriodColors._({required this.fill, required this.onFill});

  factory PeriodColors.of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;

  static const _light = PeriodColors._(
    fill: Color(0xFF7A2E3B),
    onFill: Color(0xFFFFFFFF),
  );
  static const _dark = PeriodColors._(
    fill: Color(0xFFC0617A),
    onFill: Color(0xFF1F0A10),
  );

  /// Disc of a logged period day.
  final Color fill;

  /// Day number written on a filled disc.
  final Color onFill;
}

/// The single accent of the app, an amber kept for what is estimated and for
/// the day of the cycle: the estimate card, the ring of expected days, the
/// halo of today. An accent, not a decoration: nothing else uses it.
final class AccentColors {
  const AccentColors._({
    required this.mark,
    required this.card,
    required this.onCard,
    required this.badge,
    required this.todayHalo,
  });

  factory AccentColors.of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;

  static const _light = AccentColors._(
    mark: Color(0xFFB67A14),
    card: Color(0xFFFAF0DA),
    onCard: Color(0xFF1B2A4A),
    badge: Color(0xFFFFFFFF),
    todayHalo: Color(0xFFF3DDAE),
  );
  static const _dark = AccentColors._(
    mark: Color(0xFFE3B45C),
    card: Color(0xFF3A2F17),
    onCard: Color(0xFFF6E6C2),
    badge: Color(0xFF0F1626),
    todayHalo: Color(0xFF4A3C1C),
  );

  /// Ring of an expected period day, icon of the estimate card.
  final Color mark;

  /// Background of the estimate card.
  final Color card;

  /// Text written on the estimate card.
  final Color onCard;

  /// Small disc behind the icon of the estimate card.
  final Color badge;

  /// Soft disc behind today when it is not a period day.
  final Color todayHalo;
}
