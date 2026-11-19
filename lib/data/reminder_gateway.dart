import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// One notification to show at a given moment.
final class ScheduledReminder {
  const ScheduledReminder({
    required this.when,
    required this.title,
    required this.body,
  });

  /// The moment to show it, on the clock of the phone.
  final DateTime when;
  final String title;
  final String body;

  @override
  bool operator ==(Object other) =>
      other is ScheduledReminder &&
      other.when == when &&
      other.title == title &&
      other.body == body;

  @override
  int get hashCode => Object.hash(when, title, body);

  @override
  String toString() => 'ScheduledReminder($when, $title, $body)';
}

/// Reminders shown by the phone itself. Nothing is sent anywhere: the list
/// is handed to the system, which shows each notification at its time even
/// if the app is closed. Tests replace this with a fake.
abstract interface class ReminderGateway {
  /// Asks the user to allow notifications, if she was not asked before.
  /// Returns false if they are not allowed.
  Future<bool> requestPermission();

  /// Cancels everything scheduled earlier, then schedules [reminders].
  /// An empty list cancels everything. [channelName] is the name under
  /// which Android lists these notifications in its settings.
  Future<void> replaceAll(
    List<ScheduledReminder> reminders, {
    required String channelName,
  });
}

/// The notifications of iOS and Android, through flutter_local_notifications.
/// On any other system, nothing is scheduled.
final class SystemReminderGateway implements ReminderGateway {
  const SystemReminderGateway();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static Future<void>? _ready;

  static bool get _supported => Platform.isIOS || Platform.isAndroid;

  Future<void> _initialize() => _ready ??= _plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // Permission is asked only when the user turns a reminder on.
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestSoundPermission: false,
        requestBadgePermission: false,
      ),
    ),
  );

  @override
  Future<bool> requestPermission() async {
    if (!_supported) {
      return false;
    }
    await _initialize();
    if (Platform.isIOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, sound: true);
      return granted ?? false;
    }
    final granted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    return granted ?? false;
  }

  @override
  Future<void> replaceAll(
    List<ScheduledReminder> reminders, {
    required String channelName,
  }) async {
    if (!_supported) {
      return;
    }
    await _initialize();
    await _plugin.cancelAll();
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'reminders',
        channelName,
        // On a locked Android phone, show that there is a notification but
        // not its text.
        visibility: NotificationVisibility.private,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    final now = DateTime.now();
    var id = 0;
    for (final reminder in reminders) {
      if (!reminder.when.isAfter(now)) {
        continue;
      }
      id++;
      await _plugin.zonedSchedule(
        id: id,
        title: reminder.title,
        body: reminder.body,
        // An absolute instant: the phone's own time zone is not known by
        // name here, and each reminder is scheduled for one given day, so
        // no time zone database is needed.
        scheduledDate: tz.TZDateTime.from(reminder.when, tz.UTC),
        notificationDetails: details,
        // No exact alarm: a reminder a few minutes late is fine, and this
        // needs no extra Android permission.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
