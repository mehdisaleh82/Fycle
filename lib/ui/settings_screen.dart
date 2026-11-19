import 'package:material_ui/material_ui.dart';

import '../data/appearance.dart';
import '../data/device_auth.dart';
import '../domain/reminders.dart';
import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'backup_flows.dart';
import 'cycle_length_field.dart';
import 'cycle_model.dart';
import 'dialogs.dart';
import 'disclaimer_card.dart';

/// Settings: the usual cycle length, the reminders, the app lock, the
/// appearance, and
/// everything the user can do with her own data. Export is always free
/// (CLAUDE.md, rule 6).
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

  /// Stores [next]. Turning a reminder on first asks the phone for the
  /// permission to show notifications: only then, never at first launch.
  Future<void> _setReminders(
    BuildContext context,
    ReminderSettings next, {
    bool turningOn = false,
  }) async {
    if (turningOn) {
      bool allowed;
      try {
        allowed = await environment.reminders.requestPermission();
      } on Exception {
        allowed = false;
      }
      if (!allowed) {
        if (context.mounted) {
          final l10n = AppLocalizations.of(context);
          await showNotice(
            context,
            title: l10n.reminderPermissionTitle,
            body: l10n.reminderPermissionBody,
          );
        }
        return;
      }
    }
    model.setReminderSettings(next);
  }

  Future<void> _pickDaysBefore(BuildContext context) async {
    final days = await showDialog<int>(
      context: context,
      builder: (context) =>
          _DaysBeforeDialog(current: model.reminderSettings.periodDaysBefore),
    );
    if (days != null) {
      model.setReminderSettings(
        model.reminderSettings.copyWith(periodDaysBefore: days),
      );
    }
  }

  Future<ClockTime?> _pickTime(BuildContext context, ClockTime current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
      // Like the date picker, the system time picker has a fixed layout.
      builder: (context, child) =>
          MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3, child: child!),
    );
    return picked == null ? null : ClockTime(picked.hour, picked.minute);
  }

  Future<void> _pickPeriodTime(BuildContext context) async {
    final time = await _pickTime(context, model.reminderSettings.periodTime);
    if (time != null) {
      model.setReminderSettings(
        model.reminderSettings.copyWith(periodTime: time),
      );
    }
  }

  Future<void> _pickDailyTime(BuildContext context) async {
    final time = await _pickTime(context, model.reminderSettings.dailyTime);
    if (time != null) {
      model.setReminderSettings(
        model.reminderSettings.copyWith(dailyTime: time),
      );
    }
  }

  /// Turning the lock on or off asks who is holding the phone first: a
  /// lock that cannot be opened is never turned on, and a passer-by cannot
  /// turn it off.
  Future<void> _setAppLock(BuildContext context, bool enabled) async {
    final l10n = AppLocalizations.of(context);
    final auth = environment.deviceAuth;
    var outcome = AuthOutcome.unavailable;
    if (await auth.isAvailable()) {
      outcome = await auth.authenticate(l10n.lockReason);
    }
    switch (outcome) {
      case AuthOutcome.success:
        model.setAppLockEnabled(enabled);
      case AuthOutcome.failed:
        break;
      case AuthOutcome.unavailable:
        if (!enabled) {
          // Nothing can check any more: the lock protects nothing.
          model.setAppLockEnabled(false);
        } else if (context.mounted) {
          await showNotice(
            context,
            title: l10n.lockUnavailableTitle,
            body: l10n.lockUnavailableBody,
          );
        }
    }
  }

  Future<void> _pickAppearance(BuildContext context) async {
    final appearance = await showDialog<Appearance>(
      context: context,
      builder: (context) => _AppearanceDialog(current: model.appearance),
    );
    if (appearance != null) {
      model.setAppearance(appearance);
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
            final reminders = model.reminderSettings;
            String timeText(ClockTime time) =>
                TimeOfDay(hour: time.hour, minute: time.minute).format(context);
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionTitle(l10n.settingsCycleSection),
                  _Group(
                    children: [
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
                    ],
                  ),
                  _SectionTitle(l10n.settingsRemindersSection),
                  _Group(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.notifications_outlined),
                        title: Text(l10n.reminderPeriodTitle),
                        subtitle: Text(l10n.reminderPeriodSubtitle),
                        value: reminders.periodEnabled,
                        onChanged: (on) => _setReminders(
                          context,
                          reminders.copyWith(periodEnabled: on),
                          turningOn: on,
                        ),
                      ),
                      if (reminders.periodEnabled) ...[
                        ListTile(
                          key: const ValueKey('period-days-before'),
                          leading: const SizedBox(width: 24),
                          title: Text(l10n.reminderDaysBeforeTitle),
                          subtitle: Text(
                            l10n.reminderDaysBefore(reminders.periodDaysBefore),
                          ),
                          onTap: () => _pickDaysBefore(context),
                        ),
                        ListTile(
                          key: const ValueKey('period-time'),
                          leading: const SizedBox(width: 24),
                          title: Text(l10n.reminderTime),
                          subtitle: Text(timeText(reminders.periodTime)),
                          onTap: () => _pickPeriodTime(context),
                        ),
                      ],
                      SwitchListTile(
                        secondary: const Icon(
                          Icons.edit_notifications_outlined,
                        ),
                        title: Text(l10n.reminderDailyTitle),
                        subtitle: Text(l10n.reminderDailySubtitle),
                        value: reminders.dailyEnabled,
                        onChanged: (on) => _setReminders(
                          context,
                          reminders.copyWith(dailyEnabled: on),
                          turningOn: on,
                        ),
                      ),
                      if (reminders.dailyEnabled)
                        ListTile(
                          key: const ValueKey('daily-time'),
                          leading: const SizedBox(width: 24),
                          title: Text(l10n.reminderTime),
                          subtitle: Text(timeText(reminders.dailyTime)),
                          onTap: () => _pickDailyTime(context),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      32,
                      12,
                      32,
                      0,
                    ),
                    child: Text(
                      l10n.reminderDiscreetNote,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  _SectionTitle(l10n.settingsPrivacySection),
                  _Group(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.fingerprint),
                        title: Text(l10n.lockTitle),
                        subtitle: Text(l10n.lockSubtitle),
                        value: model.appLockEnabled,
                        onChanged: (on) => _setAppLock(context, on),
                      ),
                    ],
                  ),
                  _SectionTitle(l10n.settingsAppearanceSection),
                  _Group(
                    children: [
                      ListTile(
                        key: const ValueKey('appearance'),
                        leading: const Icon(Icons.brightness_6_outlined),
                        title: Text(l10n.settingsAppearance),
                        subtitle: Text(
                          _appearanceLabel(l10n, model.appearance),
                        ),
                        onTap: () => _pickAppearance(context),
                      ),
                    ],
                  ),
                  _SectionTitle(l10n.settingsDataSection),
                  _Group(
                    children: [
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
                        leading: Icon(
                          Icons.delete_forever,
                          color: scheme.error,
                        ),
                        title: Text(
                          l10n.settingsDelete,
                          style: TextStyle(color: scheme.error),
                        ),
                        subtitle: Text(l10n.settingsDeleteSubtitle),
                        onTap: () => _deleteEverything(context),
                      ),
                    ],
                  ),
                  _SectionTitle(l10n.settingsAboutSection),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(32, 0, 32, 8),
                    child: Text(l10n.privacyLine),
                  ),
                  const Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
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

/// The rows of one section, gathered on a card.
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
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
      padding: const EdgeInsetsDirectional.fromSTEB(32, 24, 32, 8),
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

String _appearanceLabel(AppLocalizations l10n, Appearance appearance) =>
    switch (appearance) {
      Appearance.light => l10n.appearanceLight,
      Appearance.dark => l10n.appearanceDark,
      Appearance.system => l10n.appearanceSystem,
    };

/// Pops with the chosen appearance, or with nothing if cancelled.
class _AppearanceDialog extends StatelessWidget {
  const _AppearanceDialog({required this.current});

  final Appearance current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.settingsAppearance),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final appearance in Appearance.values)
            ListTile(
              key: ValueKey('appearance-${appearance.name}'),
              title: Text(_appearanceLabel(l10n, appearance)),
              selected: appearance == current,
              trailing: appearance == current ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(context).pop(appearance),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}

/// Pops with the chosen number of days, or with nothing if cancelled.
class _DaysBeforeDialog extends StatelessWidget {
  const _DaysBeforeDialog({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.reminderDaysBeforeTitle),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final days in ReminderSettings.periodDaysBeforeChoices)
            ListTile(
              title: Text(l10n.reminderDaysBefore(days)),
              selected: days == current,
              trailing: days == current ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(context).pop(days),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
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
