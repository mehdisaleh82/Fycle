import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import '../domain/widget_snapshot.dart';

/// The home-screen widget of the phone. The app hands it a few values; the
/// system draws the widget from them, without opening the app and without
/// any network. Tests replace this with a fake.
abstract interface class WidgetGateway {
  /// Gives the widget what to show, or clears it when [snapshot] is null.
  Future<void> update(WidgetSnapshot? snapshot);
}

/// The real thing, through the `home_widget` package.
///
/// The values go to a small area shared between the app and its widget (an
/// "App Group" on iOS). That area is protected by the lock of the phone,
/// not by the encryption of the database: it only ever holds what
/// [WidgetSnapshot] lists (docs/DECISIONS.md).
final class SystemWidgetGateway implements WidgetGateway {
  const SystemWidgetGateway();

  /// Shared area of the app and its widget on iOS.
  static const String appGroup = 'group.app.fycle';

  /// Name of the widget in the iOS project.
  static const String iosWidget = 'FycleWidget';

  /// Keys read by the native widget. Never rename one without changing the
  /// widget too.
  static const String cycleStartKey = 'cycle_start';
  static const String cycleLengthKey = 'cycle_length';
  static const String periodLengthKey = 'period_length';
  static const String nextEarliestKey = 'next_earliest';
  static const String nextLatestKey = 'next_latest';

  @override
  Future<void> update(WidgetSnapshot? snapshot) async {
    try {
      await HomeWidget.setAppGroupId(appGroup);
      await HomeWidget.saveWidgetData<String>(
        cycleStartKey,
        snapshot?.cycleStart.toString(),
      );
      await HomeWidget.saveWidgetData<int>(
        cycleLengthKey,
        snapshot?.cycleLength,
      );
      await HomeWidget.saveWidgetData<int>(
        periodLengthKey,
        snapshot?.periodLength,
      );
      await HomeWidget.saveWidgetData<String>(
        nextEarliestKey,
        snapshot?.nextEarliest.toString(),
      );
      await HomeWidget.saveWidgetData<String>(
        nextLatestKey,
        snapshot?.nextLatest.toString(),
      );
      await HomeWidget.updateWidget(iOSName: iosWidget);
    } on MissingPluginException {
      // No widget on this platform (the development window, for example).
    } on PlatformException {
      // The phone has no widget of ours to update: nothing to do.
    }
  }
}
