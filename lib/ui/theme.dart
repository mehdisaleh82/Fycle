import 'package:material_ui/material_ui.dart';

/// Light or dark theme of the app, following the setting of the phone.
///
/// A powder-pink palette: a white page, outlined white cards, one rose
/// for actions, generous rounding (docs/DECISIONS.md, decision 61).
ThemeData fycleTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = dark ? _darkScheme : _lightScheme;
  final base = ThemeData(colorScheme: scheme);
  final text = base.textTheme;
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
      foregroundColor: scheme.onSurface,
      scrolledUnderElevation: 0,
      titleTextStyle: text.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: FycleSurfaces.cardOf(brightness),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        // On a white page, a thin outline is what shows the card.
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

final _lightScheme =
    ColorScheme.fromSeed(
      seedColor: const Color(0xFFB83A68),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFFB83A68),
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: const Color(0xFFFDE3EB),
      onPrimaryContainer: const Color(0xFF4A1F2E),
      secondary: const Color(0xFF8A5A6B),
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: const Color(0xFFF9E8EE),
      onSecondaryContainer: const Color(0xFF4A2A36),
      surface: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF3B1A26),
      onSurfaceVariant: const Color(0xFF6E4A57),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF6F2EC),
      surfaceContainer: const Color(0xFFF2EDE6),
      surfaceContainerHigh: const Color(0xFFEDE7DF),
      surfaceContainerHighest: const Color(0xFFE8E1D8),
      outline: const Color(0xFF9A7482),
      outlineVariant: const Color(0xFFEAD9DF),
    );

final _darkScheme =
    ColorScheme.fromSeed(
      seedColor: const Color(0xFFB83A68),
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFFFB1C8),
      onPrimary: const Color(0xFF5C1133),
      primaryContainer: const Color(0xFF4F2436),
      onPrimaryContainer: const Color(0xFFFFD9E3),
      secondary: const Color(0xFFE3BDC9),
      onSecondary: const Color(0xFF422932),
      secondaryContainer: const Color(0xFF3A2A30),
      onSecondaryContainer: const Color(0xFFF2DDE3),
      surface: const Color(0xFF1F1418),
      onSurface: const Color(0xFFF5DDE4),
      onSurfaceVariant: const Color(0xFFD6BEC6),
      surfaceContainerLowest: const Color(0xFF170E12),
      surfaceContainerLow: const Color(0xFF261A1F),
      surfaceContainer: const Color(0xFF2B1E23),
      surfaceContainerHigh: const Color(0xFF36282E),
      surfaceContainerHighest: const Color(0xFF413238),
      outline: const Color(0xFFA08C93),
      outlineVariant: const Color(0xFF524349),
    );

/// Colour of the cards, fields and chips: white like the page in light mode,
/// one step lighter than the page in dark mode.
abstract final class FycleSurfaces {
  static Color cardOf(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFF2B1E23)
      : const Color(0xFFFFFFFF);
}

/// Colours of period days on the calendar. A logged period is a filled disc,
/// an expected one a ring: the shape tells them apart, not the colour alone.
final class PeriodColors {
  const PeriodColors._({
    required this.fill,
    required this.onFill,
    required this.todayHalo,
  });

  factory PeriodColors.of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;

  static const _light = PeriodColors._(
    fill: Color(0xFFC63F70),
    onFill: Color(0xFFFFFFFF),
    todayHalo: Color(0xFFF8C9D8),
  );
  static const _dark = PeriodColors._(
    fill: Color(0xFFF48FB1),
    onFill: Color(0xFF3E0420),
    todayHalo: Color(0xFF5A2C40),
  );

  /// Disc of a logged period day, ring of an expected one.
  final Color fill;

  /// Day number written on a filled disc.
  final Color onFill;

  /// Soft disc behind today when it is not a period day.
  final Color todayHalo;
}
