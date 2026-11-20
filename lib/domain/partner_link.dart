import 'dart:convert';

import 'partner_snapshot.dart';

/// What a partner's phone opens the app with: the picture she shares, held
/// whole in a link that her phone shows as a QR code. It goes from her
/// screen to his camera; nothing travels over a network and no server sees
/// it (CLAUDE.md, rules 1 and 2).
///
/// The link is not secret by itself: whoever scans the code reads it. It is
/// shown on her screen, when she chooses, and holds dates and estimates
/// only.
const String partnerLinkScheme = 'fycle';
const String _partnerSegment = 'p';

String partnerLinkOf(PartnerSnapshot snapshot) {
  final data = base64Url
      .encode(utf8.encode(jsonEncode(snapshot.toJson())))
      .replaceAll('=', '');
  return '$partnerLinkScheme://$_partnerSegment/$data';
}

/// Reads a link made by [partnerLinkOf]. Null for anything else: another
/// link, a damaged one, or one that is not a partner picture.
PartnerSnapshot? partnerFromLink(String link) {
  final uri = Uri.tryParse(link.trim());
  if (uri == null ||
      uri.scheme != partnerLinkScheme ||
      uri.host != _partnerSegment ||
      uri.pathSegments.length != 1) {
    return null;
  }
  try {
    final data = base64Url.normalize(uri.pathSegments.single);
    return PartnerSnapshot.fromJson(
      jsonDecode(utf8.decode(base64Url.decode(data))),
    );
  } on FormatException {
    return null;
  }
}
