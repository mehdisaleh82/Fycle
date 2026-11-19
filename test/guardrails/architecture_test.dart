import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guardrail: business logic stays pure Dart, so it can be tested without
/// any user interface. See CLAUDE.md, conventions.
void main() {
  test('lib/domain does not import Flutter, data or UI code', () {
    final dir = Directory('lib/domain');
    if (!dir.existsSync()) {
      return; // Created in milestone 1.
    }
    final problems = <String>[];
    final files = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in files) {
      for (final hit in forbiddenDomainImports(file.readAsStringSync())) {
        problems.add('${file.path}: $hit');
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('detector flags UI and storage imports', () {
    expect(
      forbiddenDomainImports("import 'package:flutter/widgets.dart';"),
      isNotEmpty,
    );
    expect(
      forbiddenDomainImports("import 'package:material_ui/material_ui.dart';"),
      isNotEmpty,
    );
    expect(forbiddenDomainImports("import 'dart:ui';"), isNotEmpty);
    expect(forbiddenDomainImports("import 'dart:io';"), isNotEmpty);
    expect(forbiddenDomainImports("import '../data/db.dart';"), isNotEmpty);
    expect(
      forbiddenDomainImports("import 'package:fycle/ui/app.dart';"),
      isNotEmpty,
    );
  });

  test('detector accepts pure Dart imports', () {
    expect(forbiddenDomainImports("import 'dart:math';"), isEmpty);
    expect(forbiddenDomainImports("import 'cycle.dart';"), isEmpty);
    expect(
      forbiddenDomainImports("import 'package:fycle/domain/cycle.dart';"),
      isEmpty,
    );
  });
}

final _forbidden = <RegExp>[
  RegExp(r'''import\s+['"]dart:(ui|io|html|ffi|isolate)['"]'''),
  RegExp(
    r'''import\s+['"]package:(flutter|flutter_\w+|material_ui|cupertino_ui)/''',
  ),
  RegExp(r'''import\s+['"]package:fycle/(data|ui|l10n)/'''),
  RegExp(r'''import\s+['"](\.\./)+(data|ui|l10n)/'''),
];

/// Imports in [source] that a file under lib/domain must not have.
List<String> forbiddenDomainImports(String source) {
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
