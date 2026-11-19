import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Length of the database key, in bytes (256 bits).
const int databaseKeyLength = 32;

/// Where the key of the local database is kept.
///
/// The key never lives in the code or in the database itself. See CLAUDE.md,
/// rule 5.
abstract interface class DatabaseKeyStore {
  /// The stored key, or null if there is none.
  Future<Uint8List?> read();

  /// Stores [key], replacing any previous one.
  Future<void> write(Uint8List key);

  /// Forgets the key. Does nothing if there is none.
  Future<void> delete();
}

/// A new random key, drawn from the secure random generator of the system.
Uint8List generateDatabaseKey() {
  final random = Random.secure();
  return Uint8List.fromList([
    for (var i = 0; i < databaseKeyLength; i++) random.nextInt(256),
  ]);
}

/// Keeps the key in the secure store of the system: the Keychain on iOS, the
/// Keystore on Android.
///
/// On iOS the key stays on this device: it is not synchronised and is not
/// restored onto another phone.
final class SecureDatabaseKeyStore implements DatabaseKeyStore {
  const SecureDatabaseKeyStore();

  static const String _name = 'database_key_v1';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @override
  Future<Uint8List?> read() async {
    final encoded = await _storage.read(key: _name);
    if (encoded == null) {
      return null;
    }
    try {
      final key = base64Decode(encoded);
      return key.length == databaseKeyLength ? key : null;
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> write(Uint8List key) =>
      _storage.write(key: _name, value: base64Encode(key));

  @override
  Future<void> delete() => _storage.delete(key: _name);
}
