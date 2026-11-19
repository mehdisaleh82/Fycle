import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guardrail: every resolved package, direct or transitive, must be listed in
/// tool/allowed_dependencies.txt. See CLAUDE.md, rule 4.
void main() {
  test('pubspec.lock only contains allowed packages', () {
    final locked = lockedPackages(File('pubspec.lock').readAsStringSync());
    final allowed = allowedPackages(
      File('tool/allowed_dependencies.txt').readAsStringSync(),
    );

    expect(locked, isNotEmpty, reason: 'pubspec.lock could not be parsed');
    expect(
      locked.difference(allowed),
      isEmpty,
      reason:
          'New packages must be proposed and justified, then added to '
          'tool/allowed_dependencies.txt.',
    );
    expect(
      allowed.difference(locked),
      isEmpty,
      reason: 'Remove packages that are no longer used from the allow-list.',
    );
  });

  test('lock file parser reads package names only', () {
    const sample = '''
packages:
  alpha:
    dependency: "direct main"
    version: "1.0.0"
  beta_two:
    dependency: transitive
sdks:
  dart: ">=3.14.0 <4.0.0"
''';
    expect(lockedPackages(sample), {'alpha', 'beta_two'});
  });

  test('allow-list parser ignores comments and blank lines', () {
    expect(allowedPackages('# title\n\nalpha\n  beta # why\n'), {
      'alpha',
      'beta',
    });
  });
}

/// Package names found in the `packages:` section of a pubspec.lock file.
Set<String> lockedPackages(String lockFile) {
  final names = <String>{};
  var inPackages = false;
  for (final line in lockFile.split('\n')) {
    final text = line.trimRight();
    if (text.isNotEmpty && !text.startsWith(' ')) {
      inPackages = text == 'packages:';
      continue;
    }
    final match = RegExp(r'^  ([A-Za-z0-9_]+):$').firstMatch(text);
    if (inPackages && match != null) {
      names.add(match.group(1)!);
    }
  }
  return names;
}

/// Package names in the allow-list, one per line, `#` starts a comment.
Set<String> allowedPackages(String allowList) {
  return allowList
      .split('\n')
      .map((line) => line.split('#').first.trim())
      .where((name) => name.isNotEmpty)
      .toSet();
}
