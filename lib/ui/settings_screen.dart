import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'backup_flows.dart';
import 'cycle_length_field.dart';
import 'cycle_model.dart';
import 'dialogs.dart';
import 'disclaimer_card.dart';

/// Settings: the usual cycle length, and everything the user can do with
/// her own data. Export is always free (CLAUDE.md, rule 6).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.model,
    required this.environment,
    required this.onEraseEverything,
  });

  final CycleModel model;
  final AppEnvironment environment;
  final Future<void> Function() onEraseEverything;

  Future<void> _editCycleLength(BuildContext context) async {
    final result = await showDialog<({int? days})>(
      context: context,
      builder: (context) => _CycleLengthDialog(initial: model.usualCycleLength),
    );
    if (result != null) {
      model.setUsualCycleLength(result.days);
    }
  }

  Future<void> _deleteEverything(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final accepted = await confirm(
      context,
      title: l10n.deleteTitle,
      body: l10n.deleteBody,
      action: l10n.deleteAction,
      destructive: true,
    );
    if (!accepted) {
      return;
    }
    navigator.popUntil((route) => route.isFirst);
    await onEraseEverything();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final files = environment.files;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: model,
          builder: (context, _) {
            final length = model.usualCycleLength;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionTitle(l10n.settingsCycleSection),
                  ListTile(
                    leading: const Icon(Icons.loop),
                    title: Text(l10n.settingsCycleLength),
                    subtitle: Text(
                      length == null
                          ? l10n.settingsCycleLengthUnknown
                          : l10n.settingsCycleLengthValue(length),
                    ),
                    onTap: () => _editCycleLength(context),
                  ),
                  _SectionTitle(l10n.settingsDataSection),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: Text(l10n.settingsExport),
                    subtitle: Text(l10n.settingsExportSubtitle),
                    onTap: () => runExportFlow(
                      context,
                      model: model,
                      files: files,
                      today: environment.today(),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.restore),
                    title: Text(l10n.settingsImport),
                    subtitle: Text(l10n.settingsImportSubtitle),
                    onTap: () =>
                        runImportFlow(context, model: model, files: files),
                  ),
                  ListTile(
                    leading: const Icon(Icons.table_chart_outlined),
                    title: Text(l10n.settingsCsv),
                    subtitle: Text(l10n.settingsCsvSubtitle),
                    onTap: () => runCsvFlow(
                      context,
                      model: model,
                      files: files,
                      today: environment.today(),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.delete_forever, color: scheme.error),
                    title: Text(
                      l10n.settingsDelete,
                      style: TextStyle(color: scheme.error),
                    ),
                    subtitle: Text(l10n.settingsDeleteSubtitle),
                    onTap: () => _deleteEverything(context),
                  ),
                  _SectionTitle(l10n.settingsAboutSection),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(l10n.privacyLine),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: DisclaimerCard(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Pops with the new length (null days to forget it), or with nothing if
/// cancelled.
class _CycleLengthDialog extends StatefulWidget {
  const _CycleLengthDialog({required this.initial});

  final int? initial;

  @override
  State<_CycleLengthDialog> createState() => _CycleLengthDialogState();
}

class _CycleLengthDialogState extends State<_CycleLengthDialog> {
  late final _controller = TextEditingController(
    text: widget.initial?.toString() ?? '',
  );
  bool _error = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final length = readCycleLength(_controller.text);
    if (!length.valid) {
      setState(() => _error = true);
      return;
    }
    Navigator.of(context).pop((days: length.days));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.settingsCycleLength),
      content: CycleLengthField(
        controller: _controller,
        showError: _error,
        autofocus: true,
        onChanged: (_) {
          if (_error) {
            setState(() => _error = false);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}
