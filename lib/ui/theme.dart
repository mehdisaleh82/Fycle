import 'package:material_ui/material_ui.dart';

/// Light or dark theme of the app, following the setting of the phone.
ThemeData fycleTheme(Brightness brightness) => ThemeData(
  colorScheme: .fromSeed(seedColor: Colors.teal, brightness: brightness),
);

/// Colours of period days on the calendar. A logged period is a filled disc,
/// an expected one a ring: the shape tells them apart, not the colour alone.
final class PeriodColors {
  const PeriodColors._({required this.fill, required this.onFill});

  factory PeriodColors.of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;

  static const _light = PeriodColors._(
    fill: Color(0xFFAD1457),
    onFill: Color(0xFFFFFFFF),
  );
  static const _dark = PeriodColors._(
    fill: Color(0xFFF48FB1),
    onFill: Color(0xFF3E0420),
  );

  /// Disc of a logged period day, ring of an expected one.
  final Color fill;

  /// Day number written on a filled disc.
  final Color onFill;
}
