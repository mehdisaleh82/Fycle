import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// A file chosen by the user, read into memory.
final class PickedFile {
  const PickedFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

/// Lets the user put a file where she wants, and choose one to read back.
///
/// The app never decides where an export goes: the system dialog does, under
/// the user's control. Tests replace this with a fake.
abstract interface class FileGateway {
  /// Asks where to save [bytes] under the suggested [fileName].
  /// Returns false if the user cancelled.
  Future<bool> save({required String fileName, required Uint8List bytes});

  /// Asks for a file and reads it. Returns null if the user cancelled.
  Future<PickedFile?> pick();
}

/// The system dialogs: the Files app on iOS, the document picker on Android.
final class SystemFileGateway implements FileGateway {
  const SystemFileGateway();

  @override
  Future<bool> save({
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      final saved = await FilePicker.saveFile(fileName: fileName, bytes: bytes);
      return saved != null;
    } finally {
      await _clearCopies();
    }
  }

  @override
  Future<PickedFile?> pick() async {
    try {
      // No filter: the systems do not know the extension of an export file.
      // The content is checked when the file is read.
      final file = await FilePicker.pickFile();
      if (file == null) {
        return null;
      }
      return PickedFile(name: file.name, bytes: await file.readAsBytes());
    } finally {
      await _clearCopies();
    }
  }

  /// The plugin leaves a copy of saved and picked files in the temporary
  /// folder of the app. A CSV export is not encrypted: never leave it there.
  static Future<void> _clearCopies() async {
    try {
      await FilePicker.clearTemporaryFiles();
    } on Object {
      // Not available on every platform; nothing else to clean then.
    }
  }
}
