import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'backup_codec.dart';
import 'csv_export.dart';
import 'database_key_store.dart';
import 'fycle_database.dart';

/// Thrown when a database file exists but its key is gone, for example after
/// the phone was restored from a backup: the key never leaves the device.
/// The content cannot be recovered; [LocalStore.wipe] clears the way for a
/// fresh start or an import.
final class LocalStoreUnreadableException implements Exception {
  const LocalStoreUnreadableException();

  @override
  String toString() =>
      'LocalStoreUnreadableException: the database key is missing';
}

/// Entry point of the data layer: the encrypted database together with its
/// key, export, import and full deletion.
final class LocalStore {
  LocalStore._(this.database, this._directory, this._keyStore, this._codec);

  /// Opens the store kept in [directory], creating the key and the database
  /// on first use.
  ///
  /// Throws a [LocalStoreUnreadableException] if the database is there but
  /// its key is not, and a [DatabaseUnreadableException] if the key does not
  /// open it.
  static Future<LocalStore> open({
    required Directory directory,
    required DatabaseKeyStore keyStore,
    BackupCodec codec = const BackupCodec(),
  }) async {
    final file = _databaseFile(directory);
    var key = await keyStore.read();
    if (file.existsSync()) {
      if (key == null) {
        throw const LocalStoreUnreadableException();
      }
    } else {
      // First launch. A key left behind by an earlier installation (iOS keeps
      // the Keychain when an app is removed) is replaced by a new one.
      directory.createSync(recursive: true);
      key = generateDatabaseKey();
      await keyStore.write(key);
    }
    final database = FycleDatabase.open(file.path, key);
    return LocalStore._(database, directory, keyStore, codec);
  }

  /// Opens the store of the app: in its private folder, with the key in the
  /// secure store of the system.
  static Future<LocalStore> openForApp() async => open(
    directory: await getApplicationSupportDirectory(),
    keyStore: const SecureDatabaseKeyStore(),
  );

  /// Deletes the database and its key without opening them. After this,
  /// [open] starts again from nothing.
  static Future<void> wipe({
    required Directory directory,
    required DatabaseKeyStore keyStore,
  }) async {
    // The key goes first: without it, whatever is left of the file on the
    // storage chip can no longer be read by anyone.
    await keyStore.delete();
    final path = _databaseFile(directory).path;
    for (final suffix in const ['', '-journal', '-wal', '-shm']) {
      final file = File('$path$suffix');
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }

  static const String _fileName = 'fycle.db';

  static File _databaseFile(Directory directory) =>
      File('${directory.path}${Platform.pathSeparator}$_fileName');

  /// The open database. Unusable after [close] or [deleteEverything].
  final FycleDatabase database;

  final Directory _directory;
  final DatabaseKeyStore _keyStore;
  final BackupCodec _codec;

  /// Everything stored, encrypted with [password], as the content of an
  /// export file. Always free (CLAUDE.md, rule 6).
  Future<Uint8List> exportEncrypted(String password) =>
      _codec.encode(database.readAll(), password);

  /// Replaces everything stored with the content of an export file.
  ///
  /// Throws a [BackupException] and changes nothing if the file cannot be
  /// read or the password is wrong.
  Future<void> importEncrypted(Uint8List bytes, String password) async {
    final data = await _codec.decode(bytes, password);
    database.replaceAll(data);
  }

  /// Everything logged, as readable CSV text. Not encrypted.
  String exportCsv() => daysToCsv(database.readDays());

  /// Deletes all data in one go: the database and its key. This store must
  /// not be used afterwards; call [open] again to start from nothing.
  Future<void> deleteEverything() async {
    database.close();
    await wipe(directory: _directory, keyStore: _keyStore);
  }

  /// Closes the database.
  void close() => database.close();
}
