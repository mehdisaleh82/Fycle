import 'package:url_launcher/url_launcher.dart';

/// Hands an address to the system, which opens it in the browser of the
/// phone. The app itself makes no network call (CLAUDE.md, rule 1).
typedef LinkOpener = Future<void> Function(Uri address);

Future<void> _openInBrowser(Uri address) =>
    launchUrl(address, mode: LaunchMode.externalApplication);

/// Replaced in tests, which open nothing.
LinkOpener openLink = _openInBrowser;
