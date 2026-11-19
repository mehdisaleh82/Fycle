import 'package:material_ui/material_ui.dart';

import '../data/device_auth.dart';
import '../l10n/app_localizations.dart';

/// State of the optional app lock: whether the content is locked away until
/// the user proves who she is, and whether it is covered because the app is
/// not in front (so that the app switcher shows nothing).
class AppLock extends ChangeNotifier {
  AppLock(this._auth);

  final DeviceAuth _auth;

  bool _enabled = false;
  bool _locked = false;
  bool _covered = false;
  bool _authenticating = false;
  bool _wasInBackground = false;
  bool _promptWanted = false;
  bool _turnedOffNotice = false;

  /// Called when the phone can no longer check anyone (its passcode was
  /// removed) and the lock had to be turned off.
  VoidCallback? onTurnedOff;

  bool get enabled => _enabled;

  /// True while the content must not be shown at all.
  bool get locked => _locked;

  /// True while the content is hidden because the app is not in front.
  bool get covered => _covered;

  bool get authenticating => _authenticating;

  /// Called when the app starts, once the setting is known: an enabled lock
  /// starts locked.
  void start({required bool enabled}) {
    _enabled = enabled;
    _locked = enabled;
    _promptWanted = enabled;
    _covered = false;
    _wasInBackground = false;
    notifyListeners();
  }

  /// Follows the setting when the user changes it. Turning the lock on does
  /// not lock right away: she has just authenticated to do so.
  void setEnabled(bool enabled) {
    if (enabled == _enabled) {
      return;
    }
    _enabled = enabled;
    if (!enabled) {
      _locked = false;
      _covered = false;
    }
    notifyListeners();
  }

  void handleLifecycle(AppLifecycleState state) {
    if (!_enabled) {
      return;
    }
    switch (state) {
      case AppLifecycleState.resumed:
        _covered = false;
        if (_locked && _wasInBackground) {
          _promptWanted = true;
        }
        _wasInBackground = false;
      case AppLifecycleState.inactive:
        // Also the state of the app while the system prompt is on screen:
        // covering is enough, locking again would never let anyone in.
        _covered = true;
      case AppLifecycleState.hidden ||
          AppLifecycleState.paused ||
          AppLifecycleState.detached:
        _covered = true;
        if (!_authenticating) {
          _locked = true;
          _wasInBackground = true;
        }
    }
    notifyListeners();
  }

  /// True once, when the system prompt should come up by itself: at start
  /// and at each return to the app. After a failure or a cancellation, the
  /// user asks again with the button.
  bool takePromptRequest() {
    final wanted = _promptWanted && _locked && !_authenticating;
    if (wanted) {
      _promptWanted = false;
    }
    return wanted;
  }

  /// True once, after the lock had to be turned off.
  bool takeTurnedOffNotice() {
    final notice = _turnedOffNotice;
    _turnedOffNotice = false;
    return notice;
  }

  /// Shows the system prompt and unlocks if it succeeds.
  Future<void> unlock(String reason) async {
    if (!_locked || _authenticating) {
      return;
    }
    _authenticating = true;
    notifyListeners();
    final outcome = await _auth.authenticate(reason);
    _authenticating = false;
    switch (outcome) {
      case AuthOutcome.success:
        _locked = false;
      case AuthOutcome.failed:
        break;
      case AuthOutcome.unavailable:
        // The passcode of the phone was removed. Whoever did that knew it,
        // and nothing can be checked any more: staying locked would shut
        // the user out of her own data for good.
        _locked = false;
        _covered = false;
        _enabled = false;
        _turnedOffNotice = true;
        onTurnedOff?.call();
    }
    notifyListeners();
  }
}

/// Sits above every screen of the app and puts the lock screen, or a plain
/// cover, in front of them when needed. Whatever is underneath keeps its
/// state: a half-typed note is still there after unlocking.
class LockGate extends StatefulWidget {
  const LockGate({super.key, required this.lock, required this.child});

  final AppLock lock;
  final Widget child;

  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.lock.addListener(_onLockChanged);
  }

  @override
  void dispose() {
    widget.lock.removeListener(_onLockChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.lock.handleLifecycle(state);
  }

  void _onLockChanged() {
    if (!mounted) {
      return;
    }
    final lock = widget.lock;
    if (lock.locked || lock.covered) {
      // No keyboard left open over the lock screen.
      FocusManager.instance.primaryFocus?.unfocus();
    }
    setState(() {});
    final prompt = lock.takePromptRequest();
    final notice = lock.takeTurnedOffNotice();
    if (prompt || notice) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        final l10n = AppLocalizations.of(context);
        if (prompt) {
          lock.unlock(l10n.lockReason);
        }
        if (notice) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.lockTurnedOff)));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lock = widget.lock;
    final hidden = lock.locked || lock.covered;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Kept alive but not drawn, not touchable and silent for the screen
        // reader.
        Offstage(
          offstage: hidden,
          child: ExcludeFocus(excluding: hidden, child: widget.child),
        ),
        if (lock.locked)
          _LockScreen(
            busy: lock.authenticating,
            onUnlock: () =>
                lock.unlock(AppLocalizations.of(context).lockReason),
          )
        else if (lock.covered)
          // What the app switcher shows: nothing.
          ColoredBox(color: Theme.of(context).colorScheme.surface),
      ],
    );
  }
}

class _LockScreen extends StatelessWidget {
  const _LockScreen({required this.busy, required this.onUnlock});

  final bool busy;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.lockScreenTitle,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: busy ? null : onUnlock,
                  child: Text(l10n.lockScreenUnlock),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
