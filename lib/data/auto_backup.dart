import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

import 'backup_codec.dart';

/// Name of the file the automatic backup keeps up to date.
const String autoBackupFileName = 'Fycle-backup.$backupFileExtension';

/// Where the automatic backup is written: a folder of the phone that the
/// user sees in her own file manager. No network is involved; what the phone
/// does with that folder afterwards (its own backup, her cloud drive) is
/// hers to decide (CLAUDE.md, rule 1).
abstract interface class AutoBackupGateway {
  /// Replaces the backup file with [bytes].
  Future<void> write(Uint8List bytes);

  /// Removes the backup file, if there is one: "delete everything" leaves
  /// no copy behind on the phone.
  Future<void> delete();
}

/// The documents folder of the app: shown in the Files app on iOS, under
/// the name of the app.
final class DocumentsAutoBackupGateway implements AutoBackupGateway {
  const DocumentsAutoBackupGateway();

  @override
  Future<void> write(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}${Platform.pathSeparator}';
    // Written beside, then moved over: a backup cut short never replaces a
    // good one.
    final temporary = File('$path$autoBackupFileName.tmp');
    await temporary.writeAsBytes(bytes, flush: true);
    await temporary.rename('$path$autoBackupFileName');
  }

  @override
  Future<void> delete() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}${Platform.pathSeparator}';
    for (final name in const [autoBackupFileName, '$autoBackupFileName.tmp']) {
      final file = File('$path$name');
      if (file.existsSync()) {
        await file.delete();
      }
    }
  }
}

/// Where the password of the automatic backup is kept: she types it once,
/// and the phone must be able to encrypt without asking again.
abstract interface class BackupPasswordStore {
  Future<String?> read();
  Future<void> write(String password);
  Future<void> delete();
}

/// Keeps it in the secure store of the system, on this device only, like
/// the key of the database (CLAUDE.md, rule 5).
final class SecureBackupPasswordStore implements BackupPasswordStore {
  const SecureBackupPasswordStore();

  static const String _name = 'auto_backup_password_v1';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @override
  Future<String?> read() => _storage.read(key: _name);

  @override
  Future<void> write(String password) =>
      _storage.write(key: _name, value: password);

  @override
  Future<void> delete() => _storage.delete(key: _name);
}
