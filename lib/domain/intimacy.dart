/// Sex logged on a day, with or without saying whether it was protected.
///
/// A plain note of hers. The app draws nothing from it: no estimate of a
/// pregnancy, no advice (CLAUDE.md, rule 7).
///
/// The names are stored on disk and in export files: never rename a value,
/// only add new ones.
enum Intimacy { unspecified, protected, unprotected }
