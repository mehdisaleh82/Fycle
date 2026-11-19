import 'package:material_ui/material_ui.dart';

import '../data/fycle_database.dart';
import '../data/local_store.dart';
import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'backup_flows.dart';
import 'cycle_model.dart';
import 'dialogs.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

enum _Phase { opening, unreadable, ready }

/// Opens the local store, then shows the right screen: the first-launch
/// screen while nothing is entered, the home screen afterwards, or an
/// explanation when the stored data can no longer be read.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key, required this.environment});

  final AppEnvironment environment;

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  _Phase _phase = _Phase.opening;
  CycleModel? _model;
  bool _onboarded = false;

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void dispose() {
    _closeModel();
    super.dispose();
  }

  void _closeModel() {
    final model = _model;
    _model = null;
    if (model != null) {
      model.dispose();
      model.store.close();
    }
  }

  Future<void> _open() async {
    try {
      final store = await widget.environment.openStore();
      if (!mounted) {
        store.close();
        return;
      }
      final model = CycleModel(store);
      setState(() {
        _model = model;
        _onboarded = !model.isEmpty;
        _phase = _Phase.ready;
      });
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
    if (model != null) {
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
        onDone: () => setState(() => _onboarded = true),
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
