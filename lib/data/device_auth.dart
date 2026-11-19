import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

enum AuthOutcome {
  /// The user proved who she is.
  success,

  /// She did not: cancelled, not recognised, or too many attempts.
  failed,

  /// The phone has no way to check: no passcode and no biometrics.
  unavailable,
}

/// Checks that the person holding the phone is its owner, with what the
/// phone already has: Face ID, fingerprint, or its passcode as a fallback.
/// The app keeps no code of its own. Tests replace this with a fake.
abstract interface class DeviceAuth {
  /// Whether this phone can check at all.
  Future<bool> isAvailable();

  /// Shows the system prompt. [reason] is the sentence displayed in it.
  Future<AuthOutcome> authenticate(String reason);
}

/// The system prompt, through local_auth.
final class SystemDeviceAuth implements DeviceAuth {
  const SystemDeviceAuth();

  static final LocalAuthentication _auth = LocalAuthentication();

  @override
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<AuthOutcome> authenticate(String reason) async {
    try {
      final ok = await _auth.authenticate(localizedReason: reason);
      return ok ? AuthOutcome.success : AuthOutcome.failed;
    } on LocalAuthException catch (error) {
      return switch (error.code) {
        LocalAuthExceptionCode.noCredentialsSet => AuthOutcome.unavailable,
        _ => AuthOutcome.failed,
      };
    } on PlatformException {
      return AuthOutcome.failed;
    } on MissingPluginException {
      return AuthOutcome.unavailable;
    }
  }
}
