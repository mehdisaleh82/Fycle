import '../data/widget_gateway.dart';
import '../domain/calendar_day.dart';
import '../domain/widget_snapshot.dart';
import 'cycle_model.dart';

/// Keeps the home-screen widget in step with the data: after every entry,
/// every change of setting and every return to the app, what it should show
/// is computed again and handed to the phone if it changed.
class WidgetSync {
  WidgetSync(this._gateway);

  final WidgetGateway _gateway;

  /// What was last handed to the phone, to avoid doing it again for nothing.
  WidgetSnapshot? _last;
  bool _handedOnce = false;
  Future<void> _queue = Future<void>.value();

  /// Computes what the widget should show on [today] and hands it over.
  /// Nothing is handed over while the user keeps the widget turned off.
  void sync({required CycleModel model, required CalendarDay today}) {
    _hand(
      model.widgetEnabled
          ? widgetSnapshotOn(
              today,
              cycles: model.cycles,
              flowByDay: model.flowByDay,
              prediction: model.prediction,
            )
          : null,
    );
  }

  /// Empties the widget, for example when all data is deleted.
  void clear() => _hand(null);

  void _hand(WidgetSnapshot? snapshot) {
    if (_handedOnce && snapshot == _last) {
      return;
    }
    _handedOnce = true;
    _last = snapshot;
    _queue = _queue.then((_) async {
      try {
        await _gateway.update(snapshot);
      } on Exception {
        // A widget that could not be updated must never get in the way of
        // the app. It is tried again at the next change.
        _handedOnce = false;
      }
    });
  }
}
