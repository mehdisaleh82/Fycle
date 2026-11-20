/// The kiosk: a small web site of recent articles from the press, rebuilt
/// every day outside the app (`tool/kiosk/`). The app never reads it: it
/// only hands one of these addresses to the browser of the phone
/// (CLAUDE.md, rule 1). See docs/DECISIONS.md, decision 169.
library;

const String _kioskRoot = 'https://mehdisaleh82.github.io/Fycle/';

/// The languages the kiosk is written in. The others get English.
const Set<String> kioskLanguages = {'en', 'fr'};

/// The page of the kiosk for a language: the general one, or the one about
/// intimacy, which no other page links to.
///
/// Nothing of hers is carried in the address.
Uri kioskAddress({required String languageCode, required bool intimacy}) {
  final language = kioskLanguages.contains(languageCode) ? languageCode : 'en';
  final page = intimacy ? 'intimacy.html' : 'index.html';
  return Uri.parse('$_kioskRoot$language/$page');
}
