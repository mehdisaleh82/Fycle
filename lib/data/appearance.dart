/// How the app looks on this phone: light unless she chooses otherwise.
///
/// Stored by name: never rename a value, only add new ones
/// (docs/DECISIONS.md, decision 26).
enum Appearance {
  /// Light, whatever the phone says. The default.
  light,

  /// Dark, whatever the phone says.
  dark,

  /// Light or dark, like the phone.
  system,
}
