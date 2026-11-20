/// What a list of outside pages is about.
enum ReadingTopic {
  cycle,
  sexuality,
  contraception,
  fertility,
  perimenopause,
  pregnancy,
}

/// A page of a public health site, opened in the browser of the phone. The
/// app sends nothing: it only hands the address to the system.
final class ReadingLink {
  const ReadingLink({
    required this.title,
    required this.source,
    required this.address,
  });

  final String title;

  /// Who publishes the page.
  final String source;
  final Uri address;

  @override
  String toString() => 'ReadingLink($title, $source, $address)';
}

/// Reads a list of links written one per line as `title|source|address`,
/// the way each language lists its own sources in its localization file.
/// A line that is not a secure web address with a title and a source is
/// left out.
List<ReadingLink> parseReadingLinks(String text) {
  final links = <ReadingLink>[];
  for (final line in text.split('\n')) {
    final parts = [for (final part in line.split('|')) part.trim()];
    if (parts.length != 3 || parts.any((part) => part.isEmpty)) {
      continue;
    }
    final address = Uri.tryParse(parts[2]);
    if (address == null || address.scheme != 'https' || address.host.isEmpty) {
      continue;
    }
    links.add(ReadingLink(title: parts[0], source: parts[1], address: address));
  }
  return links;
}
