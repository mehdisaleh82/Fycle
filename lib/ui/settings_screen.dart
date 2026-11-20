import 'package:material_ui/material_ui.dart';

import '../data/appearance.dart';
import '../domain/reminders.dart';
import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'auto_backup_flow.dart';
import 'backup_flows.dart';
import 'birth_year_field.dart';
import 'cycle_length_field.dart';
import 'cycle_model.dart';
import 'dialogs.dart';
import 'disclaimer_card.dart';
import 'onboarding_screen.dart';
import 'partner_screens.dart';

/// Settings: the usual cycle length, the reminders, the app lock, the
/// appearance, and
/// everything the user can do with her own data. Export is always free
/// (CLAUDE.md, rule 6).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.header,
    required this.model,
    required this.environment,
    required this.onEraseEverything,
  });

  final CycleModel model;
  final AppEnvironment environment;
  final Future<void> Function() onEraseEverything;

  /// One line saying what the tab is for, shown first and scrolled with
  /// the rest.
  final Widget header;

  Future<void> _editCycleLength(BuildContext context) async {
    final result = await showDialog<({int? days})>(
      context: context,
      builder: (context) => _CycleLengthDialog(initial: model.usualCycleLength),
    );
    if (result != null) {
      model.setUsualCycleLength(result.days);
    }
  }

  Future<void> _editBirthYear(BuildContext context) async {
    final result = await showDialog<({int? year})>(
      context: context,
      builder: (context) => _BirthYearDialog(
        initial: model.birthYear,
        currentYear: environment.today().year,
      ),
    );
    if (result != null) {
      model.setBirthYear(result.year);
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

  Future<void> _setAppLock(BuildContext context, bool enabled) => changeAppLock(
    context,
    model: model,
    auth: environment.deviceAuth,
    enabled: enabled,
  );

  /// Copies into the journal the days of period the phone already knows.
  /// A day she logged herself is never touched.
  Future<void> _importFromHealth(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final days = await environment.health.readPeriodDays(
      now: environment.now(),
    );
    if (!context.mounted) {
      return;
    }
    if (days == null) {
      await showNotice(
        context,
        title: l10n.healthImportTitle,
        body: l10n.healthImportUnavailable,
      );
      return;
    }
    var added = 0;
    for (final MapEntry(key: day, value: flow) in days.entries) {
      final entry = model.entryFor(day);
      if (entry.flow == null) {
        model.saveDay(entry.withFlow(flow));
        added++;
      }
    }
    if (!context.mounted) {
      return;
    }
    await showNotice(
      context,
      title: l10n.healthImportTitle,
      body: l10n.healthImportDone(added),
    );
  }

  /// The questions of the setup again, with what she answered.
  void _editAnswers(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => OnboardingScreen(
        model: model,
        environment: environment,
        editing: true,
        onDone: () => Navigator.of(context).pop(),
      ),
    ),
  );

  /// Turning the estimate on first shows what it is not.
  Future<void> _setFertilityEstimate(BuildContext context, bool enabled) async {
    if (enabled) {
      final l10n = AppLocalizations.of(context);
      final accepted = await confirm(
        context,
        title: l10n.fertilityWarningTitle,
        body: l10n.fertilityWarning,
        action: l10n.fertilityTurnOn,
      );
      if (!accepted) {
        return;
      }
    }
    model.setFertilityEstimateEnabled(enabled);
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
    return ListenableBuilder(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: header,
              ),
              _SectionTitle(l10n.settingsCycleSection),
              _Group(
                children: [
                  ListTile(
                    key: const ValueKey('edit-answers'),
                    leading: const Icon(Icons.person_outline),
                    title: Text(l10n.settingsAnswers),
                    subtitle: Text(l10n.settingsAnswersSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _editAnswers(context),
                  ),
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
                  ListTile(
                    key: const ValueKey('birth-year'),
                    leading: const Icon(Icons.cake_outlined),
                    title: Text(l10n.settingsBirthYear),
                    subtitle: Text(
                      model.birthYear == null
                          ? l10n.settingsBirthYearUnknown
                          : '${model.birthYear}',
                    ),
                    onTap: () => _editBirthYear(context),
                  ),
                  SwitchListTile(
                    key: const ValueKey('fertility-estimate'),
                    secondary: const Icon(Icons.egg_outlined),
                    title: Text(l10n.fertilitySettingTitle),
                    subtitle: Text(l10n.fertilitySettingSubtitle),
                    value: model.fertilityEstimateEnabled,
                    onChanged: (on) => _setFertilityEstimate(context, on),
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
                    secondary: const Icon(Icons.edit_notifications_outlined),
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
                  SwitchListTile(
                    key: const ValueKey('signs-reminder'),
                    secondary: const Icon(Icons.auto_awesome_outlined),
                    title: Text(l10n.reminderSignsTitle),
                    subtitle: Text(l10n.reminderSignsSubtitle),
                    value: reminders.signsEnabled,
                    onChanged: (on) => _setReminders(
                      context,
                      reminders.copyWith(signsEnabled: on),
                      turningOn: on,
                    ),
                  ),
                  if (reminders.signsEnabled)
                    ListTile(
                      key: const ValueKey('signs-time'),
                      leading: const SizedBox(width: 24),
                      title: Text(l10n.reminderTime),
                      subtitle: Text(timeText(reminders.signsTime)),
                      onTap: () async {
                        final time = await _pickTime(
                          context,
                          reminders.signsTime,
                        );
                        if (time != null) {
                          model.setReminderSettings(
                            model.reminderSettings.copyWith(signsTime: time),
                          );
                        }
                      },
                    ),
                  SwitchListTile(
                    key: const ValueKey('contraception-reminder'),
                    secondary: const Icon(Icons.alarm),
                    title: Text(l10n.reminderContraceptionTitle),
                    subtitle: Text(l10n.reminderContraceptionSubtitle),
                    value: reminders.contraceptionEnabled,
                    onChanged: (on) => _setReminders(
                      context,
                      reminders.copyWith(contraceptionEnabled: on),
                      turningOn: on,
                    ),
                  ),
                  if (reminders.contraceptionEnabled)
                    ListTile(
                      key: const ValueKey('contraception-time'),
                      leading: const SizedBox(width: 24),
                      title: Text(l10n.reminderTime),
                      subtitle: Text(timeText(reminders.contraceptionTime)),
                      onTap: () async {
                        final time = await _pickTime(
                          context,
                          reminders.contraceptionTime,
                        );
                        if (time != null) {
                          model.setReminderSettings(
                            model.reminderSettings.copyWith(
                              contraceptionTime: time,
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(32, 12, 32, 0),
                child: Text(
                  l10n.reminderDiscreetNote,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              _SectionTitle(l10n.settingsPrivacySection),
              _Group(
                children: [
                  ListTile(
                    key: const ValueKey('partner-share'),
                    leading: const Icon(Icons.people_outline),
                    title: Text(l10n.partnerShareTitle),
                    subtitle: Text(l10n.partnerShareSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => PartnerShareScreen(
                          model: model,
                          environment: environment,
                        ),
                      ),
                    ),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint),
                    title: Text(l10n.lockTitle),
                    subtitle: Text(l10n.lockSubtitle),
                    value: model.appLockEnabled,
                    onChanged: (on) => _setAppLock(context, on),
                  ),
                  SwitchListTile(
                    key: const ValueKey('widget-enabled'),
                    secondary: const Icon(Icons.widgets_outlined),
                    title: Text(l10n.widgetTitle),
                    subtitle: Text(l10n.widgetSubtitle),
                    value: model.widgetEnabled,
                    onChanged: model.setWidgetEnabled,
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
                    subtitle: Text(_appearanceLabel(l10n, model.appearance)),
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
                  SwitchListTile(
                    key: const ValueKey('auto-backup'),
                    secondary: const Icon(Icons.autorenew),
                    title: Text(l10n.autoBackupTitle),
                    subtitle: Text(l10n.autoBackupSubtitle),
                    value: model.store.database.autoBackupEnabled,
                    onChanged: (on) => setAutoBackup(
                      context,
                      model: model,
                      environment: environment,
                      enabled: on,
                    ),
                  ),
                  ListTile(
                    key: const ValueKey('health-import'),
                    leading: const Icon(Icons.monitor_heart_outlined),
                    title: Text(l10n.healthImportTitle),
                    subtitle: Text(l10n.healthImportSubtitle),
                    onTap: () => _importFromHealth(context),
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

/// Pops with the year of birth typed (null to forget it), or with nothing
/// if cancelled.
class _BirthYearDialog extends StatefulWidget {
  const _BirthYearDialog({required this.initial, required this.currentYear});

  final int? initial;
  final int currentYear;

  @override
  State<_BirthYearDialog> createState() => _BirthYearDialogState();
}

class _BirthYearDialogState extends State<_BirthYearDialog> {
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
    final year = readBirthYear(_controller.text, widget.currentYear);
    if (!year.valid) {
      setState(() => _error = true);
      return;
    }
    Navigator.of(context).pop((year: year.year));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.settingsBirthYear),
      content: BirthYearField(
        controller: _controller,
        currentYear: widget.currentYear,
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
