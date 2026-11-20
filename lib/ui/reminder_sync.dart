import 'package:flutter/foundation.dart';

import '../data/reminder_gateway.dart';
import '../domain/calendar_day.dart';
import '../domain/reminders.dart';
import '../l10n/app_localizations.dart';
import 'cycle_model.dart';

/// Keeps the notifications scheduled on the phone in step with the data:
/// after every entry, every change of setting and every return to the app,
/// the whole schedule is computed again and replaces the previous one.
class ReminderSync {
  ReminderSync(this._gateway);

  final ReminderGateway _gateway;

  /// What was last handed to the phone, to avoid doing it again for nothing.
  List<ScheduledReminder>? _last;
  Future<void> _queue = Future<void>.value();

  /// Computes what should be pending at [now] and hands it to the phone.
  void sync({
    required CycleModel model,
    required DateTime now,
    required AppLocalizations l10n,
  }) {
    final settings = model.reminderSettings;
    final planned = planReminders(
      settings: settings,
      today: CalendarDay.fromDateTime(now),
      now: ClockTime(now.hour, now.minute),
      prediction: model.prediction,
      loggedDays: model.loggedDays,
    );
    final reminders = [
      for (final reminder in planned)
        ScheduledReminder(
          // The clock of the phone as it is today. A change of time zone is
          // picked up the next time the app comes to the front.
          when: DateTime(
            reminder.day.year,
            reminder.day.month,
            reminder.day.day,
            reminder.time.hour,
            reminder.time.minute,
          ),
          title: l10n.appTitle,
          // Neutral on purpose: this text shows on the lock screen.
          body: switch (reminder.kind) {
            ReminderKind.periodApproaching => l10n.notificationPeriodBody,
            ReminderKind.dailyEntry => l10n.notificationDailyBody,
            ReminderKind.contraception => l10n.notificationContraceptionBody,
          },
        ),
    ];
    if (_last == null && !settings.anyEnabled) {
      // Reminders were never turned on: the phone is left alone.
      return;
    }
    if (listEquals(_last, reminders)) {
      return;
    }
    _replace(reminders, l10n.notificationChannelName);
  }

  /// Cancels everything, for example when all data is deleted.
  void clear(AppLocalizations l10n) =>
      _replace(const [], l10n.notificationChannelName);

  void _replace(List<ScheduledReminder> reminders, String channelName) {
    _last = reminders;
    _queue = _queue.then((_) async {
      try {
        await _gateway.replaceAll(reminders, channelName: channelName);
      } on Exception {
        // A reminder that could not be scheduled must never get in the way
        // of the app. It is tried again at the next change.
        _last = null;
      }
    });
  }
}
