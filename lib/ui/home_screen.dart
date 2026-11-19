import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/cycle_status.dart';
import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'cycle_model.dart';
import 'day_sheet.dart';
import 'disclaimer_card.dart';
import 'month_calendar.dart';
import 'prediction_card.dart';
import 'settings_screen.dart';

/// Home: the estimate for the next period, the calendar of the month, and
/// one button to log today.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.model,
    required this.environment,
    required this.onEraseEverything,
  });

  final CycleModel model;
  final AppEnvironment environment;

  /// Deletes all data and returns to the first-launch screen.
  final Future<void> Function() onEraseEverything;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final today = widget.environment.today();
    _year = today.year;
    _month = today.month;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The day may have changed while the app was in the background.
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  void _moveMonth(int delta) {
    final moved = DateTime(_year, _month + delta);
    setState(() {
      _year = moved.year;
      _month = moved.month;
    });
  }

  void _openDay(CalendarDay day) {
    showDaySheet(context, model: widget.model, day: day);
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SettingsScreen(
          model: widget.model,
          environment: widget.environment,
          onEraseEverything: widget.onEraseEverything,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final model = widget.model;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.settingsTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDay(widget.environment.today()),
        icon: const Icon(Icons.edit_outlined),
        label: Text(l10n.homeLogToday),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: model,
          builder: (context, _) {
            final today = widget.environment.today();
            return SingleChildScrollView(
              // Room at the bottom so the button never hides the notice.
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PredictionCard(
                    status: cycleStatusOn(
                      today,
                      flowByDay: model.flowByDay,
                      prediction: model.prediction,
                    ),
                    usualCycleLength: model.usualCycleLength,
                  ),
                  const SizedBox(height: 16),
                  MonthCalendar(
                    year: _year,
                    month: _month,
                    today: today,
                    flowByDay: model.flowByDay,
                    loggedDays: model.loggedDays,
                    prediction: model.prediction,
                    onDayTap: _openDay,
                    onPreviousMonth: () => _moveMonth(-1),
                    onNextMonth: () => _moveMonth(1),
                  ),
                  const SizedBox(height: 16),
                  const DisclaimerCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
