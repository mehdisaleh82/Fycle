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

  test('the Face ID sentence exists in English and in French', () {
    for (final language in ['en', 'fr']) {
      final strings = File('ios/Runner/$language.lproj/InfoPlist.strings');
      expect(strings.existsSync(), isTrue, reason: language);
      expect(
        strings.readAsStringSync(),
        contains('"NSFaceIDUsageDescription" = "'),
        reason: language,
      );
    }
    final project = File('ios/Runner.xcodeproj/project.pbxproj')
        .readAsStringSync();
    expect(project, contains('fr.lproj/InfoPlist.strings'));
  });

  test('the iOS privacy declaration says nothing is collected or tracked', () {
    final manifest = File('ios/Runner/PrivacyInfo.xcprivacy');
    expect(manifest.existsSync(), isTrue);
    final text = manifest.readAsStringSync().replaceAll(RegExp(r'\s'), '');
    expect(text, contains('<key>NSPrivacyTracking</key><false/>'));
    expect(text, contains('<key>NSPrivacyTrackingDomains</key><array/>'));
    expect(text, contains('<key>NSPrivacyCollectedDataTypes</key><array/>'));
    final project = File('ios/Runner.xcodeproj/project.pbxproj')
        .readAsStringSync();
    expect(project, contains('PrivacyInfo.xcprivacy in Resources'));
  });

  test('iOS keeps the database folder out of backups', () {
    // Decision 43: nothing leaves the phone, not even to iCloud.
    final delegate = File('ios/Runner/AppDelegate.swift').readAsStringSync();
    expect(delegate, contains('isExcludedFromBackup = true'));
    expect(delegate, contains('.applicationSupportDirectory'));
  });

  test('the iOS widget reaches nothing beyond the shared area', () {
    // It reads a few values left by the app, and nothing else: no network,
    // no file of the app, no keychain.
    final widget = File('ios/FycleWidget/FycleWidget.swift').readAsStringSync();
    for (final api in ['URLSession', 'URLRequest', 'http://', 'https://']) {
      expect(widget, isNot(contains(api)), reason: api);
    }
    expect(widget, contains('UserDefaults(suiteName: appGroup)'));
    for (final path in [
      'ios/FycleWidget/FycleWidget.entitlements',
      'ios/Runner/Runner.entitlements',
    ]) {
      final entitlements = File(path).readAsStringSync();
      expect(entitlements, contains('group.app.fycle'), reason: path);
      // The widget asks for the App Group only. The app also asks to read
      // Health, and nothing else.
      final health = entitlements.contains('com.apple.developer.healthkit');
      expect(health, path.contains('Runner'), reason: path);
      expect(
        RegExp('<key>').allMatches(entitlements),
        hasLength(health ? 2 : 1),
        reason: '$path asks for nothing more',
      );
    }
    final manifest = File('ios/FycleWidget/PrivacyInfo.xcprivacy')
        .readAsStringSync()
        .replaceAll(RegExp(r'\s'), '');
    expect(manifest, contains('<key>NSPrivacyTracking</key><false/>'));
    expect(
      manifest,
      contains('<key>NSPrivacyCollectedDataTypes</key><array/>'),
    );
  });

  test('both phones hand the links of the app to the app', () {
    // The code a partner scans is a link of the app: without this, the
    // camera of the phone does not offer to open it (decision 159).
    final plist = File('ios/Runner/Info.plist')
        .readAsStringSync()
        .replaceAll(RegExp(r'\s'), '');
    expect(
      plist,
      contains(
        '<key>CFBundleURLSchemes</key><array><string>fycle</string></array>',
      ),
    );
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(manifest, contains('android:scheme="fycle"'));
  });

  test('iOS declares no remote notification', () {
    // Reminders are scheduled on the phone. Nothing is pushed by a server.
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(plist, isNot(contains('remote-notification')));
    expect(plist, isNot(contains('aps-environment')));
  });
}
