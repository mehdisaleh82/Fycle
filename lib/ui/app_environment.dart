import '../data/device_auth.dart';
import '../data/file_gateway.dart';
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
  });

  /// The real thing: encrypted database, system file dialogs, today's date.
  const AppEnvironment.device()
    : openStore = LocalStore.openForApp,
      wipeStore = LocalStore.wipeForApp,
      files = const SystemFileGateway(),
      reminders = const SystemReminderGateway(),
      deviceAuth = const SystemDeviceAuth(),
      widgets = const SystemWidgetGateway(),
      now = DateTime.now;

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

  /// The current date and time, as the phone shows them.
  final DateTime Function() now;

  /// The current calendar day, as the phone shows it.
  CalendarDay today() => CalendarDay.fromDateTime(now());
}
