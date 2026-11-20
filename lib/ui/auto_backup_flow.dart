import 'package:material_ui/material_ui.dart';

import '../data/backup_codec.dart';
import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'cycle_model.dart';
import 'dialogs.dart';

/// Asks for the password the automatic backup will be encrypted with, twice.
/// Returns null if she gives up.
Future<String?> askAutoBackupPassword(BuildContext context) =>
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _PasswordDialog(),
    );

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog();

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  String? _passwordError;
  String? _repeatError;

  @override
  void dispose() {
    _password.dispose();
    _repeat.dispose();
    super.dispose();
  }

  void _confirm() {
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
    if (!tooShort && !mismatch) {
      Navigator.of(context).pop(password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.autoBackupPasswordTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.autoBackupPasswordBody),
          const SizedBox(height: 16),
          PasswordField(
            controller: _password,
            label: l10n.passwordLabel,
            errorText: _passwordError,
            autofocus: true,
          ),
          const SizedBox(height: 12),
          PasswordField(
            controller: _repeat,
            label: l10n.passwordRepeatLabel,
            errorText: _repeatError,
            onSubmitted: _confirm,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const ValueKey('auto-backup-confirm'),
          onPressed: _confirm,
          child: Text(l10n.fertilityTurnOn),
        ),
      ],
    );
  }
}

/// Writes the backup of the day if it is turned on and was not written
/// today. Fails quietly: a backup that could not be written must never get
/// in the way of the app, and is tried again the next time.
Future<void> writeAutoBackupIfDue({
  required CycleModel model,
  required AppEnvironment environment,
}) async {
  final database = model.store.database;
  final today = environment.today();
  if (!database.autoBackupEnabled || database.autoBackupDay == today) {
    return;
  }
  // Marked first: the changes that follow today do not start it again.
  database.autoBackupDay = today;
  try {
    final password = await environment.backupPasswords.read();
    if (password == null) {
      // The password is gone, for example after the phone was restored:
      // nothing can be encrypted any more.
      database.autoBackupEnabled = false;
      return;
    }
    final bytes = await model.store.exportEncrypted(password);
    await environment.autoBackup.write(bytes);
  } on Exception {
    database.autoBackupDay = null;
  } on StateError {
    // The store was closed in the meantime.
  }
}

/// Turns the automatic backup on, after asking for its password, or off.
Future<void> setAutoBackup(
  BuildContext context, {
  required CycleModel model,
  required AppEnvironment environment,
  required bool enabled,
}) async {
  final database = model.store.database;
  if (!enabled) {
    database
      ..autoBackupEnabled = false
      ..autoBackupDay = null;
    await environment.backupPasswords.delete();
    model.reload();
    return;
  }
  final password = await askAutoBackupPassword(context);
  if (password == null) {
    return;
  }
  await environment.backupPasswords.write(password);
  database
    ..autoBackupEnabled = true
    ..autoBackupDay = null;
  model.reload();
  await writeAutoBackupIfDue(model: model, environment: environment);
}
