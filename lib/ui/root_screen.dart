import 'dart:async';
import 'dart:convert';

import 'package:material_ui/material_ui.dart';

import '../data/appearance.dart';
import '../data/backup_codec.dart';
import '../data/file_gateway.dart';
import '../data/fycle_database.dart';
import '../data/local_store.dart';
import '../domain/partner_snapshot.dart';
import '../domain/start_profile.dart';
import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'app_lock.dart';
import 'auto_backup_flow.dart';
import 'backup_flows.dart';
import 'cycle_model.dart';
import 'dialogs.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'partner_screens.dart';
import 'reminder_sync.dart';
import 'widget_sync.dart';

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

  /// What a partner shared, when this phone is used to follow her.
  PartnerSnapshot? _partner;
  late final ReminderSync _reminders = ReminderSync(
    widget.environment.reminders,
  );
  late final WidgetSync _widgets = WidgetSync(widget.environment.widgets);

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
    // So does the backup of the day, when it is turned on.
    unawaited(
      writeAutoBackupIfDue(model: model, environment: widget.environment),
    );
    // The widget follows the same moments as the reminders.
    _widgets.sync(model: model, today: widget.environment.today());
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
        _partner = _readPartner(model);
        _phase = _Phase.ready;
      });
      _syncReminders();
      if (_onboarded) {
        _alignFertilityWithAnswers(model);
        // An app set up before reminders were on by default, then the
        // question asked again after each update.
        unawaited(
          _applyReminderDefault(model)
              .then((_) => _askRemindersAfterUpdate(model)),
        );
      } else {
        // A first launch asks in its own way: not twice.
        _markAskedForThisBuild(model);
      }
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
    _widgets.clear();
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

  PartnerSnapshot? _readPartner(CycleModel model) {
    final stored = model.store.database.partnerView;
    if (stored == null) {
      return null;
    }
    try {
      return PartnerSnapshot.fromJson(jsonDecode(stored));
    } on FormatException {
      return null;
    }
  }

  /// Opens a file a partner sent: picked by hand, read with the password
  /// she gave, and kept on this phone. Nothing is sent anywhere.
  Future<void> _openPartnerFile(CycleModel model) async {
    final l10n = AppLocalizations.of(context);
    final PickedFile? file;
    try {
      file = await widget.environment.files.pick();
    } on Exception {
      return;
    }
    if (file == null || !mounted) {
      return;
    }
    final password = await askPartnerPassword(context);
    if (password == null || !mounted) {
      return;
    }
    PartnerSnapshot? snapshot;
    String? text;
    try {
      text = await model.store.decryptText(file.bytes, password);
      snapshot = PartnerSnapshot.fromJson(jsonDecode(text));
    } on BackupException {
      snapshot = null;
    } on FormatException {
      snapshot = null;
    }
    if (!mounted || !identical(model, _model)) {
      return;
    }
    if (snapshot == null || text == null) {
      await showNotice(
        context,
        title: l10n.partnerOpenTitle,
        body: l10n.partnerOpenError,
      );
      return;
    }
    model.store.database.partnerView = text;
    setState(() => _partner = snapshot);
  }

  void _leavePartner(CycleModel model) {
    model.store.database.partnerView = null;
    setState(() => _partner = null);
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

  /// Reminders are on by default: once per phone, both are turned on if the
  /// phone allows notifications. This happens at the end of the first
  /// launch, or at the first opening after an update for an app set up
  /// before. A refusal leaves them off, without a word: the home tab offers
  /// them again once. Whatever the user chooses afterwards is kept.
  /// An app set up with an earlier version showed the estimate of the
  /// fertile window to anyone who wanted to understand her body, asked or
  /// not. Once, it is set again from what she answered (decision 146);
  /// what she changes by hand afterwards is hers.
  void _alignFertilityWithAnswers(CycleModel model) {
    if (model.suggestionDismissed(fertilityFromAnswers)) {
      return;
    }
    model.dismissSuggestion(fertilityFromAnswers);
    if (answeredAboutFertility(
      model.goals,
      wishes: model.wishes,
      contraception: model.contraception,
    )) {
      model.setFertilityEstimateEnabled(
        showsFertilityFor(
          model.goals,
          wishes: model.wishes,
          contraception: model.contraception,
        ),
      );
    }
  }

  Future<void> _applyReminderDefault(CycleModel model) async {
    if (model.suggestionDismissed(reminderDefaultSuggestion)) {
      return;
    }
    model.dismissSuggestion(reminderDefaultSuggestion);
    final current = model.reminderSettings;
    if (current.periodEnabled || current.dailyEnabled) {
      // She already chose.
      return;
    }
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

  /// Name under which the phone remembers that reminders were asked for
  /// with the build that is running. Null for a build made by hand.
  String? get _askedForThisBuild {
    final build = widget.environment.build;
    return build.isEmpty ? null : 'reminders_asked_$build';
  }

  void _markAskedForThisBuild(CycleModel model) {
    final name = _askedForThisBuild;
    if (name != null && !model.suggestionDismissed(name)) {
      model.dismissSuggestion(name);
    }
  }

  /// Reminders are what brings her back to her journal: after each update,
  /// once, the app asks for them again if they are not all on (decision
  /// 137). It asks; it never turns them back on by itself, and it says what
  /// is true: the app works without them, it only cannot tell her anything.
  Future<void> _askRemindersAfterUpdate(CycleModel model) async {
    final name = _askedForThisBuild;
    if (name == null || model.suggestionDismissed(name)) {
      return;
    }
    model.dismissSuggestion(name);
    final current = model.reminderSettings;
    bool allowed;
    try {
      // Shows the question of the system if it was never answered; says
      // what was answered otherwise, without showing anything.
      allowed = await widget.environment.reminders.requestPermission();
    } on Exception {
      allowed = false;
    }
    if (!mounted || !identical(model, _model)) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    if (!allowed) {
      await showNotice(
        context,
        title: l10n.remindersAskTitle,
        body: l10n.remindersAskBlockedBody,
      );
      return;
    }
    if (current.periodEnabled && current.dailyEnabled) {
      return;
    }
    final accepted = await confirm(
      context,
      title: l10n.remindersAskTitle,
      body: l10n.remindersAskBody,
      action: l10n.fertilityTurnOn,
      cancel: l10n.remindersAskLater,
    );
    if (accepted && mounted && identical(model, _model)) {
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
    final partner = _partner;
    if (!_onboarded && partner != null) {
      return PartnerScreen(
        snapshot: partner,
        today: widget.environment.today(),
        onReplace: () => _openPartnerFile(model),
        onLeave: () => _leavePartner(model),
      );
    }
    if (!_onboarded) {
      return OnboardingScreen(
        model: model,
        environment: widget.environment,
        onDone: () {
          model.completeOnboarding();
          setState(() => _onboarded = true);
          _markAskedForThisBuild(model);
          _applyReminderDefault(model);
        },
        onRestore: () => _restore(model),
        onPartner: () => _openPartnerFile(model),
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
