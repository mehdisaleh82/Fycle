/// The kiosk: a small web site of recent articles from the press, rebuilt
/// every day outside the app, in a repository of its own. The app never
/// reads it: it only hands one of these addresses to the browser of the
/// phone (CLAUDE.md, rule 1). See docs/DECISIONS.md, decisions 169 and
/// 175.
library;

const String _kioskRoot = 'https://mehdisaleh82.github.io/fycle-kiosk/';

/// The countries with pages of their own, by language the kiosk is written
/// in. A page of a country lists the media of that country only, however
/// few articles that makes. The same list is in the kiosk, which builds
/// the pages: the two change together.
const Map<String, Set<String>> kioskCountries = {
  'en': {'gb', 'us'},
  'fr': {'be', 'ca', 'ch', 'fr'},
};

/// The page of the kiosk for a language and the country of the phone: the
/// general one, or the one about intimacy, which no other page links to.
///
/// A language the kiosk is not written in gets English. A country without
/// pages of its own gets the pages of the language, which mix its media
/// from everywhere.
///
/// Nothing of hers is carried in the address: only the language and the
/// region the phone is set to, as any web page she opens is told.
Uri kioskAddress({
  required String languageCode,
  required bool intimacy,
  String? countryCode,
}) {
  final language = kioskCountries.containsKey(languageCode)
      ? languageCode
      : 'en';
  final country = countryCode?.toLowerCase();
  final folder = kioskCountries[language]!.contains(country)
      ? '$language/$country'
      : language;
  final page = intimacy ? 'intimacy.html' : 'index.html';
  return Uri.parse('$_kioskRoot$folder/$page');
}
