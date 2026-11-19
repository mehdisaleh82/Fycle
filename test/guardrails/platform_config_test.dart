import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guardrail: what the phone must be told for the app lock and the
/// reminders to work, and nothing that would reach beyond the phone.
void main() {
  test('iOS explains why the app uses Face ID', () {
    // Without this sentence, iOS closes the app at the first Face ID prompt.
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(plist, contains('NSFaceIDUsageDescription'));
  });

  test('iOS declares no remote notification', () {
    // Reminders are scheduled on the phone. Nothing is pushed by a server.
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(plist, isNot(contains('remote-notification')));
    expect(plist, isNot(contains('aps-environment')));
  });
}
