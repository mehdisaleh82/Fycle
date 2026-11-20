import '../data/auto_backup.dart';
import '../data/device_auth.dart';
import '../data/file_gateway.dart';
import '../data/health_gateway.dart';
import '../data/local_store.dart';
import '../data/reminder_gateway.dart';
import '../data/widget_gateway.dart';
import '../domain/calendar_day.dart';

/// What the interface needs from the outside world. The app uses
/// [AppEnvironment.device]; tests pass an in-memory store, fake file dialogs,
/// fake notifications, a fake Face ID and a fixed date.
final class AppEnvironment {
  const AppEnvironment({
    required this.openStore,
    required this.wipeStore,
    required this.files,
    required this.reminders,
    required this.deviceAuth,
    required this.widgets,
    required this.now,
    this.build = '',
    this.autoBackup = const DocumentsAutoBackupGateway(),
    this.backupPasswords = const SecureBackupPasswordStore(),
    this.health = const SystemHealthGateway(),
  });

  /// The real thing: encrypted database, system file dialogs, today's date.
  const AppEnvironment.device()
    : openStore = LocalStore.openForApp,
      wipeStore = LocalStore.wipeForApp,
      files = const SystemFileGateway(),
      reminders = const SystemReminderGateway(),
      deviceAuth = const SystemDeviceAuth(),
      widgets = const SystemWidgetGateway(),
      now = DateTime.now,
      autoBackup = const DocumentsAutoBackupGateway(),
      backupPasswords = const SecureBackupPasswordStore(),
      health = const SystemHealthGateway(),
      build = const String.fromEnvironment('FYCLE_BUILD');

  /// Opens the local store. May throw when the store cannot be read.
  final Future<LocalStore> Function() openStore;

  /// Deletes the store without opening it.
  final Future<void> Function() wipeStore;

  final FileGateway files;

  /// Notifications scheduled on the phone.
  final ReminderGateway reminders;

  /// Face ID, fingerprint or the phone passcode.
  final DeviceAuth deviceAuth;

  /// The home-screen widget of the phone.
  final WidgetGateway widgets;

  /// Where the automatic backup is written, and where its password is
  /// kept.
  final AutoBackupGateway autoBackup;
  final BackupPasswordStore backupPasswords;

  /// The health data of the phone, read on the phone.
  final HealthGateway health;

  /// The current date and time, as the phone shows them.
  final DateTime Function() now;

  /// The build number of the app that is running, given when it is
  /// compiled. Empty for a build made by hand: nothing then depends on it.
  final String build;

  /// The current calendar day, as the phone shows it.
  CalendarDay today() => CalendarDay.fromDateTime(now());
}
