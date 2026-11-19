import 'package:material_ui/material_ui.dart';

import '../data/appearance.dart';
import '../data/fycle_database.dart';
import '../data/local_store.dart';
import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'app_lock.dart';
import 'backup_flows.dart';
import 'cycle_model.dart';
import 'dialogs.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'reminder_sync.dart';

enum _Phase { opening, unreadable, ready }

/// Opens the local store, then shows the right screen: the first-launch
/// screen until it is passed, the home screen afterwards, or an
/// explanation when the stored data can no longer be read. It also keeps the
/// app lock and the reminders of the phone in step with what is stored.
class RootScreen extends StatefulWidget {
  const RootScreen({
    super.key,
    required this.environment,
    required this.lock,
    required this.onAppearance,
  });

  final AppEnvironment environment;
  final AppLock lock;

  /// Called with the appearance stored on this phone, once the store is
  /// open and after every change.
  final ValueChanged<Appearance> onAppearance;

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with WidgetsBindingObserver {
  _Phase _phase = _Phase.opening;
  CycleModel? _model;
  bool _onboarded = false;
  late final ReminderSync _reminders = ReminderSync(
    widget.environment.reminders,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.lock.onTurnedOff = () => _model?.setAppLockEnabled(false);
    _open();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.lock.onTurnedOff = null;
    _closeModel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The day, the hour or the time zone may have changed in the meantime.
    if (state == AppLifecycleState.resumed) {
      _syncReminders();
    }
  }

  void _closeModel() {
    final model = _model;
    _model = null;
    if (model != null) {
      model.removeListener(_onModelChanged);
      model.dispose();
      model.store.close();
    }
  }

  /// After every entry and every change of setting.
  void _onModelChanged() {
    final model = _model;
    if (model == null || !mounted) {
      return;
    }
    widget.lock.setEnabled(model.appLockEnabled);
    widget.onAppearance(model.appearance);
    _syncReminders();
  }

  void _syncReminders() {
    final model = _model;
    if (model == null || !mounted) {
      return;
    }
    _reminders.sync(
      model: model,
      now: widget.environment.now(),
      l10n: AppLocalizations.of(context),
    );
  }

  Future<void> _open() async {
    try {
      final store = await widget.environment.openStore();
      if (!mounted) {
        store.close();
        return;
      }
      final model = CycleModel(store, today: widget.environment.today)
        ..addListener(_onModelChanged);
      // Before the first screen is built: a locked app shows nothing.
      widget.lock.start(enabled: model.appLockEnabled);
      widget.onAppearance(model.appearance);
      setState(() {
        _model = model;
        _onboarded = !model.isEmpty || model.onboardingDone;
        _phase = _Phase.ready;
      });
      _syncReminders();
    } on LocalStoreUnreadableException {
      _showUnreadable();
    } on DatabaseUnreadableException {
      _showUnreadable();
    }
  }

  void _showUnreadable() {
    if (mounted) {
      setState(() => _phase = _Phase.unreadable);
    }
  }

  /// Deletes everything, then starts again from the first-launch screen.
  Future<void> _eraseEverything() async {
    final model = _model;
    setState(() {
      _phase = _Phase.opening;
      _model = null;
    });
    // The settings of the phone go with the data: no reminder is left
    // behind, and the lock is off again.
    _reminders.clear(AppLocalizations.of(context));
    widget.lock.start(enabled: false);
    if (model != null) {
      model.removeListener(_onModelChanged);
      model.dispose();
      await model.store.deleteEverything();
    } else {
      await widget.environment.wipeStore();
    }
    await _open();
  }

  /// From the "unreadable" screen: clears what cannot be read, after a
  /// confirmation, and optionally goes on to restoring a backup file.
  Future<void> _startOver({required bool thenRestore}) async {
    final l10n = AppLocalizations.of(context);
    final accepted = await confirm(
      context,
      title: l10n.unreadableConfirmTitle,
      body: l10n.unreadableConfirmBody,
      action: l10n.erase,
      destructive: true,
    );
    if (!accepted) {
      return;
    }
    await _eraseEverything();
    final model = _model;
    if (thenRestore && model != null && mounted) {
      await _restore(model);
    }
  }

  Future<void> _restore(CycleModel model) async {
    final restored = await runImportFlow(
      context,
      model: model,
      files: widget.environment.files,
    );
    if (restored && mounted) {
      setState(() => _onboarded = true);
    }
  }

  /// At the end of the first launch, both reminders are turned on if the
  /// phone allows notifications. A refusal leaves them off, without a
  /// word: the home tab offers them again once.
  Future<void> _turnRemindersOn(CycleModel model) async {
    bool allowed;
    try {
      allowed = await widget.environment.reminders.requestPermission();
    } on Exception {
      allowed = false;
    }
    if (allowed && mounted && identical(model, _model)) {
      model.setReminderSettings(
        model.reminderSettings.copyWith(
          periodEnabled: true,
          dailyEnabled: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final model = _model;
    if (_phase == _Phase.unreadable) {
      return _UnreadableScreen(
        onStartFresh: () => _startOver(thenRestore: false),
        onRestore: () => _startOver(thenRestore: true),
      );
    }
    if (_phase == _Phase.opening || model == null) {
      // Opening takes a few milliseconds: an empty page, no spinner.
      return Scaffold(
        body: Semantics(label: l10n.openingLabel, child: const SizedBox()),
      );
    }
    if (!_onboarded) {
      return OnboardingScreen(
        model: model,
        today: widget.environment.today,
        onDone: () {
          model.completeOnboarding();
          setState(() => _onboarded = true);
          _turnRemindersOn(model);
        },
        onRestore: () => _restore(model),
      );
    }
    return HomeScreen(
      model: model,
      environment: widget.environment,
      onEraseEverything: _eraseEverything,
    );
  }
}

class _UnreadableScreen extends StatelessWidget {
  const _UnreadableScreen({
    required this.onStartFresh,
    required this.onRestore,
  });

  final VoidCallback onStartFresh;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.unreadableTitle,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.unreadableBody, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: onRestore,
                child: Text(l10n.unreadableRestore),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onStartFresh,
                child: Text(l10n.unreadableStartFresh),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
