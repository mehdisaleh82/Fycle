import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guardrail: the app never talks to the network. No exception.
/// See CLAUDE.md, rules 1 to 3.
void main() {
  test('no Dart file under lib/ uses a network API', () {
    final problems = <String>[];
    for (final file in dartFilesIn('lib')) {
      for (final hit in networkUsages(file.readAsStringSync())) {
        problems.add('${file.path}: $hit');
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('release Android manifest does not request network access', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml');
    expect(manifest.existsSync(), isTrue);
    final content = manifest.readAsStringSync();
    expect(content, isNot(contains('android.permission.INTERNET')));
    expect(content, isNot(contains('ACCESS_NETWORK_STATE')));
  });

  test('iOS configuration does not relax transport security', () {
    final plist = File('ios/Runner/Info.plist');
    expect(plist.existsSync(), isTrue);
    expect(plist.readAsStringSync(), isNot(contains('NSAppTransportSecurity')));
  });

  group('detector', () {
    test('flags network imports', () {
      expect(networkUsages("import 'package:http/http.dart';"), isNotEmpty);
      expect(networkUsages("import 'package:dio/dio.dart';"), isNotEmpty);
      expect(networkUsages("import 'dart:html';"), isNotEmpty);
      expect(
        networkUsages("import 'package:timezone/standalone.dart';"),
        isNotEmpty,
      );
      expect(
        networkUsages("import 'package:timezone/browser.dart';"),
        isNotEmpty,
      );
      expect(
        networkUsages("import 'package:timezone/timezone.dart';"),
        isEmpty,
      );
    });

    test('flags network classes', () {
      expect(networkUsages('final c = HttpClient();'), isNotEmpty);
      expect(networkUsages('await Socket.connect(host, 80);'), isNotEmpty);
      expect(networkUsages('Image.network(url)'), isNotEmpty);
      expect(networkUsages('NetworkImage(url)'), isNotEmpty);
    });

    test('accepts local file access', () {
      expect(
        networkUsages("import 'dart:io';\nfinal f = File('a.txt');"),
        isEmpty,
      );
    });
  });
}

final _forbidden = <RegExp>[
  RegExp(r'''import\s+['"]dart:(html|js_interop|js)['"]'''),
  RegExp(
    r'''import\s+['"]package:(http|http2|dio|web|web_socket|web_socket_channel|grpc|socket_io_client|chopper|retrofit|graphql|firebase_\w+|sentry\w*)/''',
  ),
  RegExp(
    r'\b(HttpClient|HttpServer|WebSocket|RawSocket|SecureSocket|'
    r'ServerSocket|RawDatagramSocket|Socket|InternetAddress|'
    r'NetworkImage|NetworkAssetBundle)\b',
  ),
  RegExp(r'\bImage\.network\b'),
];

/// Network-related imports or identifiers found in [source].
List<String> networkUsages(String source) {
  final hits = <String>[];
  final lines = source.split('\n');
  for (var i = 0; i < lines.length; i++) {
    for (final pattern in _forbidden) {
      final match = pattern.firstMatch(lines[i]);
      if (match != null) {
        hits.add('line ${i + 1}: ${match.group(0)}');
      }
    }
  }
  return hits;
}

/// All Dart files under [root], or nothing if the folder does not exist.
Iterable<File> dartFilesIn(String root) {
  final dir = Directory(root);
  if (!dir.existsSync()) {
    return const [];
  }
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}
