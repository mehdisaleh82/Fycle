import '../data/file_gateway.dart';
import '../data/local_store.dart';
import '../domain/calendar_day.dart';

/// What the interface needs from the outside world. The app uses
/// [AppEnvironment.device]; tests pass an in-memory store, a fake file
/// dialog and a fixed date.
final class AppEnvironment {
  const AppEnvironment({
    required this.openStore,
    required this.wipeStore,
    required this.files,
    required this.today,
  });

  /// The real thing: encrypted database, system file dialogs, today's date.
  const AppEnvironment.device()
    : openStore = LocalStore.openForApp,
      wipeStore = LocalStore.wipeForApp,
      files = const SystemFileGateway(),
      today = _today;

  /// Opens the local store. May throw when the store cannot be read.
  final Future<LocalStore> Function() openStore;

  /// Deletes the store without opening it.
  final Future<void> Function() wipeStore;

  final FileGateway files;

  /// The current calendar day, as the phone shows it.
  final CalendarDay Function() today;

  static CalendarDay _today() => CalendarDay.fromDateTime(DateTime.now());
}
