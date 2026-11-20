import 'package:material_ui/material_ui.dart';

/// Light or dark theme of the app.
///
/// Plum for headers and actions on a warm off-white page, outlined white
/// cards, generous rounding (docs/DECISIONS.md, decisions 61 and 147).
/// The text uses the font of the system: nothing is bundled or downloaded.
ThemeData fycleTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = dark ? _darkScheme : _lightScheme;
  final base = ThemeData(colorScheme: scheme);
  final text = base.textTheme;
  // Headers are plum on the light page.
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

// The palette chosen on 20 November 2026 (docs/DECISIONS.md, decision 147):
// plum 73435A for headers, actions and what is selected; dusty rose C67F87
// for period days; pale pink F2D5DC for soft grounds; beige D6BCA5 and
// taupe B08F82 for lines and what is estimated. Text is never set in the
// light ones: it is plum, or a darker shade of the same hue, to stay
// readable.
final _lightScheme =
    ColorScheme.fromSeed(
      seedColor: const Color(0xFF73435A),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF73435A),
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: const Color(0xFFF2D5DC),
      onPrimaryContainer: const Color(0xFF4A2638),
      secondary: const Color(0xFF7A5C50),
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: const Color(0xFFEFE3D8),
      onSecondaryContainer: const Color(0xFF3E2C25),
      tertiary: const Color(0xFF9A4F5C),
      onTertiary: const Color(0xFFFFFFFF),
      tertiaryContainer: const Color(0xFFF2D5DC),
      onTertiaryContainer: const Color(0xFF4A2638),
      error: const Color(0xFFA63A2B),
      onError: const Color(0xFFFFFFFF),
      errorContainer: const Color(0xFFF9E3DE),
      onErrorContainer: const Color(0xFF5C1A10),
      surface: const Color(0xFFFBF6F3),
      onSurface: const Color(0xFF33242B),
      onSurfaceVariant: const Color(0xFF6B565D),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF8EEEC),
      surfaceContainer: const Color(0xFFF4E8E4),
      surfaceContainerHigh: const Color(0xFFEFE0DB),
      surfaceContainerHighest: const Color(0xFFEBD9D6),
      outline: const Color(0xFF8E7479),
      outlineVariant: const Color(0xFFE6D5CC),
    );

final _darkScheme =
    ColorScheme.fromSeed(
      seedColor: const Color(0xFF73435A),
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFEDBDC7),
      onPrimary: const Color(0xFF3F2231),
      primaryContainer: const Color(0xFF5A3447),
      onPrimaryContainer: const Color(0xFFF9DDE3),
      secondary: const Color(0xFFD6BCA5),
      onSecondary: const Color(0xFF3A2A20),
      secondaryContainer: const Color(0xFF3A2A30),
      onSecondaryContainer: const Color(0xFFEADBD0),
      tertiary: const Color(0xFFE0A3AB),
      onTertiary: const Color(0xFF41202A),
      tertiaryContainer: const Color(0xFF5A3447),
      onTertiaryContainer: const Color(0xFFF9DDE3),
      error: const Color(0xFFF2A99B),
      onError: const Color(0xFF4A130B),
      errorContainer: const Color(0xFF5C1F14),
      onErrorContainer: const Color(0xFFFFDAD3),
      surface: const Color(0xFF1D1418),
      onSurface: const Color(0xFFF0E6E4),
      onSurfaceVariant: const Color(0xFFC9B6B7),
      surfaceContainerLowest: const Color(0xFF150E11),
      surfaceContainerLow: const Color(0xFF251A1F),
      surfaceContainer: const Color(0xFF2B1F25),
      surfaceContainerHigh: const Color(0xFF34262D),
      surfaceContainerHighest: const Color(0xFF3E2E36),
      outline: const Color(0xFF9D888C),
      outlineVariant: const Color(0xFF4A3840),
    );

/// Colour of the cards, fields and chips: white on the off-white page in
/// light mode, one step lighter than the page in dark mode.
abstract final class FycleSurfaces {
  static Color cardOf(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFF2B1F25)
      : const Color(0xFFFFFFFF);
}

/// Colours of period days on the calendar. A logged period is a filled disc,
/// an expected one a ring: the shape tells them apart, not the colour alone.
final class PeriodColors {
  const PeriodColors._({required this.fill, required this.onFill});

  factory PeriodColors.of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;

  static const _light = PeriodColors._(
    // The rose of the palette, one shade darker so that a white day
    // number reads on it.
    fill: Color(0xFFA9505F),
    onFill: Color(0xFFFFFFFF),
  );
  static const _dark = PeriodColors._(
    fill: Color(0xFFC67F87),
    onFill: Color(0xFF2A1219),
  );

  /// Disc of a logged period day.
  final Color fill;

  /// Day number written on a filled disc.
  final Color onFill;
}

/// The accent of the app, a taupe on pale pink kept for what is estimated and for
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
    mark: Color(0xFF9C7A6B),
    card: Color(0xFFF2D5DC),
    onCard: Color(0xFF73435A),
    badge: Color(0xFFFFFFFF),
    todayHalo: Color(0xFFEBD9C9),
  );
  static const _dark = AccentColors._(
    mark: Color(0xFFD6BCA5),
    card: Color(0xFF4A2B3B),
    onCard: Color(0xFFF2D5DC),
    badge: Color(0xFF1D1418),
    todayHalo: Color(0xFF4A3840),
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
