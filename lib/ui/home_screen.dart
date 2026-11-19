import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'cycle_model.dart';
import 'day_sheet.dart';
import 'insights_screen.dart';
import 'journal_tab.dart';
import 'settings_screen.dart';
import 'today_tab.dart';

/// The four parts of the app.
enum HomeTab { home, journal, review, settings }

/// The frame of the app once it is set up: a home button at the top, and
/// four named tabs at the bottom.
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
  HomeTab _tab = HomeTab.home;
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

  void _select(HomeTab tab) => setState(() => _tab = tab);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final model = widget.model;
    final environment = widget.environment;
    const header = SizedBox(height: 4);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        // Always in the same place: the way back to the home tab.
        title: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Tooltip(
            message: l10n.homeTooltip,
            child: TextButton.icon(
              key: const ValueKey('app-title'),
              onPressed: () => _select(HomeTab.home),
              icon: const Icon(Icons.home_rounded),
              label: Text(
                l10n.tabHome,
                style: theme.appBarTheme.titleTextStyle,
              ),
            ),
          ),
        ),
      ),
      // The bar has a fixed height: its labels stop growing past a point,
      // as the tab bars of the system do.
      bottomNavigationBar: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: NavigationBar(
          selectedIndex: _tab.index,
          onDestinationSelected: (index) => _select(HomeTab.values[index]),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l10n.tabHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: const Icon(Icons.menu_book),
              label: l10n.tabJournal,
            ),
            NavigationDestination(
              icon: const Icon(Icons.insights_outlined),
              selectedIcon: const Icon(Icons.insights),
              label: l10n.tabReview,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l10n.settingsTitle,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: switch (_tab) {
          HomeTab.home => TodayTab(
            header: header,
            model: model,
            environment: environment,
            onOpenDay: _openDay,
            onOpenTab: _select,
          ),
          HomeTab.journal => JournalTab(
            header: header,
            model: model,
            environment: environment,
            year: _year,
            month: _month,
            onMoveMonth: _moveMonth,
            onOpenDay: _openDay,
          ),
          HomeTab.review => InsightsScreen(
            header: header,
            model: model,
            environment: environment,
          ),
          HomeTab.settings => SettingsScreen(
            header: header,
            model: model,
            environment: environment,
            onEraseEverything: widget.onEraseEverything,
          ),
        },
      ),
    );
  }
}
