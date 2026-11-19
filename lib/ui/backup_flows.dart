import 'dart:convert';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import '../data/backup_codec.dart';
import '../data/file_gateway.dart';
import '../data/local_store.dart';
import '../domain/calendar_day.dart';
import '../l10n/app_localizations.dart';
import 'cycle_model.dart';
import 'dialogs.dart';
import 'labels.dart';

/// The steps of each export and import: questions, warnings, the system file
/// dialog, and the message at the end.

void _say(ScaffoldMessengerState messenger, String message) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Saves an encrypted backup where the user chooses.
Future<void> runExportFlow(
  BuildContext context, {
  required CycleModel model,
  required FileGateway files,
  required CalendarDay today,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final bytes = await showDialog<Uint8List>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _ExportDialog(store: model.store),
  );
  if (bytes == null) {
    return;
  }
  await _save(
    messenger,
    l10n,
    files,
    fileName: 'fycle-backup-$today.$backupFileExtension',
    bytes: bytes,
    doneMessage: l10n.exportDone,
  );
}

/// Saves the readable, unencrypted CSV where the user chooses.
Future<void> runCsvFlow(
  BuildContext context, {
  required CycleModel model,
  required FileGateway files,
  required CalendarDay today,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final accepted = await confirm(
    context,
    title: l10n.csvWarningTitle,
    body: l10n.csvWarningBody,
    action: l10n.csvAction,
  );
  if (!accepted) {
    return;
  }
  final text = model.store.exportCsv(labels: csvLabels(l10n));
  await _save(
    messenger,
    l10n,
    files,
    fileName: 'fycle-$today.csv',
    bytes: utf8.encode(text),
    doneMessage: l10n.csvDone,
  );
}

Future<void> _save(
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  FileGateway files, {
  required String fileName,
  required Uint8List bytes,
  required String doneMessage,
}) async {
  try {
    if (await files.save(fileName: fileName, bytes: bytes)) {
      _say(messenger, doneMessage);
    }
  } on Exception {
    _say(messenger, l10n.errorGeneric);
  }
}

/// Replaces everything with the content of a backup file chosen by the user.
/// Returns true if the backup was restored.
Future<bool> runImportFlow(
  BuildContext context, {
  required CycleModel model,
  required FileGateway files,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  if (!model.isEmpty) {
    final accepted = await confirm(
      context,
      title: l10n.importReplaceTitle,
      body: l10n.importReplaceBody,
      action: l10n.importReplaceAction,
      destructive: true,
    );
    if (!accepted) {
      return false;
    }
  }

  final PickedFile? file;
  try {
    file = await files.pick();
  } on Exception {
    _say(messenger, l10n.errorGeneric);
    return false;
  }
  if (file == null || !context.mounted) {
    return false;
  }

  final restored = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _ImportDialog(store: model.store, bytes: file!.bytes),
  );
  if (restored != true) {
    return false;
  }
  model.reload();
  _say(messenger, l10n.importDone);
  return true;
}

/// Asks for the password of a new backup, twice, under a clear warning, then
/// builds the file. Pops with its bytes.
class _ExportDialog extends StatefulWidget {
  const _ExportDialog({required this.store});

  final LocalStore store;

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  String? _passwordError;
  String? _repeatError;
  bool _busy = false;

  @override
  void dispose() {
    _password.dispose();
    _repeat.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    final password = _password.text;
    final tooShort = password.runes.length < minBackupPasswordLength;
    final mismatch = !tooShort && _repeat.text != password;
    setState(() {
      _passwordError = tooShort
          ? l10n.passwordTooShort(minBackupPasswordLength)
          : null;
      _repeatError = mismatch ? l10n.passwordMismatch : null;
    });
    if (tooShort || mismatch) {
      return;
    }

    setState(() => _busy = true);
    final navigator = Navigator.of(context);
    try {
      navigator.pop(await widget.store.exportEncrypted(password));
    } on Exception {
      if (mounted) {
        setState(() {
          _busy = false;
          _passwordError = l10n.errorGeneric;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.exportTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                l10n.exportWarning,
                style: TextStyle(color: scheme.onErrorContainer),
              ),
            ),
          ),
          const SizedBox(height: 16),
          PasswordField(
            controller: _password,
            label: l10n.passwordLabel,
            errorText: _passwordError,
            enabled: !_busy,
            autofocus: true,
          ),
          const SizedBox(height: 12),
          PasswordField(
            controller: _repeat,
            label: l10n.passwordConfirmLabel,
            errorText: _repeatError,
            enabled: !_busy,
            onSubmitted: _create,
          ),
          if (_busy) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _create,
          child: Text(l10n.exportAction),
        ),
      ],
    );
  }
}

/// Asks for the password of a backup file and restores it. A wrong password
/// can be corrected without choosing the file again. Pops with true once
/// the backup is restored.
class _ImportDialog extends StatefulWidget {
  const _ImportDialog({required this.store, required this.bytes});

  final LocalStore store;
  final Uint8List bytes;

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  final _password = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    String? error;
    try {
      await widget.store.importEncrypted(widget.bytes, _password.text);
    } on BackupException catch (exception) {
      error = switch (exception.problem) {
        BackupProblem.notABackup => l10n.importErrorNotBackup,
        BackupProblem.unsupportedVersion => l10n.importErrorVersion,
        BackupProblem.wrongPasswordOrDamaged => l10n.importErrorWrong,
      };
    } on Exception {
      error = l10n.errorGeneric;
    }
    if (error == null) {
      navigator.pop(true);
    } else if (mounted) {
      setState(() {
        _busy = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.importPasswordTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PasswordField(
            controller: _password,
            label: l10n.passwordLabel,
            errorText: _error,
            enabled: !_busy,
            autofocus: true,
            onSubmitted: _restore,
          ),
          if (_busy) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _restore,
          child: Text(l10n.importAction),
        ),
      ],
    );
  }
}
