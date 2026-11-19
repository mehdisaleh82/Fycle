import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/cycle_status.dart';
import '../domain/day_entry.dart';
import '../domain/fertility_estimate.dart';
import '../domain/monthly_history.dart';
import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'cycle_model.dart';
import 'home_cards.dart';
import 'labels.dart';
import 'month_calendar.dart';

/// At most this many pages are listed under the calendar, most recent
/// first. Older ones open from the calendar.
const int journalPagesShown = 30;

/// The journal tab: the calendar of the month, then the latest pages, each
/// with its date, what was logged and the note. A tap opens a day to write
/// or correct it.
class JournalTab extends StatelessWidget {
  const JournalTab({
    super.key,
    required this.header,
    required this.model,
    required this.environment,
    required this.year,
    required this.month,
    required this.onMoveMonth,
    required this.onOpenDay,
  });

  final CycleModel model;
  final AppEnvironment environment;
  final int year;
  final int month;

  /// Called with -1 or 1 to show the previous or the next month.
  final ValueChanged<int> onMoveMonth;
  final ValueChanged<CalendarDay> onOpenDay;

  /// One line saying what the tab is for, shown first and scrolled with
  /// the rest.
  final Widget header;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final today = environment.today();
        final status = cycleStatusOn(
          today,
          flowByDay: model.flowByDay,
          prediction: model.prediction,
        );
        final fertility = <FertilityEstimate>[
          ...model.pastFertilityEstimates,
          // Nothing is said of a cycle left aside for months.
          if (status is! EstimateOutdated) ?model.fertilityEstimate,
        ];
        final pages = model.days.reversed.take(journalPagesShown).toList();
        return SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              MonthCalendar(
                year: year,
                month: month,
                today: today,
                flowByDay: model.flowByDay,
                loggedDays: model.loggedDays,
                prediction: model.prediction,
                fertility: fertility,
                showFertility: model.fertilityEstimateEnabled,
                onDayTap: onOpenDay,
                onPreviousMonth: () => onMoveMonth(-1),
                onNextMonth: () => onMoveMonth(1),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 0),
                child: Text(
                  l10n.calendarHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const ValueKey('journal-write-today'),
                onPressed: () => onOpenDay(today),
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.journalWriteToday),
              ),
              const SizedBox(height: 16),
              _MonthsCard(
                months: monthlyHistory(days: model.days, today: today),
              ),
              const SizedBox(height: 16),
              TitledCard(
                title: l10n.journalPagesTitle,
                children: [
                  if (pages.isEmpty)
                    Text(l10n.journalEmpty, style: theme.textTheme.bodyMedium),
                  for (final (index, entry) in pages.indexed) ...[
                    if (index > 0) const Divider(height: 24),
                    _Page(entry: entry, onTap: () => onOpenDay(entry.day)),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// One day of the journal: its date, what was ticked, and the note.
class _Page extends StatelessWidget {
  const _Page({required this.entry, required this.onTap});

  final DayEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final facts = entryFacts(l10n, entry);
    final note = entry.note;
    return InkWell(
      key: ValueKey('page-${entry.day}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullDate(l10n, entry.day),
                style: theme.textTheme.titleSmall,
              ),
              if (facts.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  facts.join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (note != null) ...[
                const SizedBox(height: 6),
                Text(
                  note,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The last months, each with how much of it was logged: the history is
/// what every estimate rests on, and its gaps show at a glance.
class _MonthsCard extends StatelessWidget {
  const _MonthsCard({required this.months});

  final List<MonthSummary> months;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return TitledCard(
      key: const ValueKey('months-card'),
      title: l10n.monthsTitle,
      children: [
        Text(l10n.monthsIntro, style: theme.textTheme.bodyMedium),
        for (final month in months)
          Padding(
            key: ValueKey('month-${month.year}-${month.month}'),
            padding: const EdgeInsets.only(top: 14),
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monthTitle(l10n, month.year, month.month),
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  // The line under it says the same thing in words.
                  ExcludeSemantics(child: ShareBar(share: month.share)),
                  const SizedBox(height: 4),
                  Text(
                    [
                      l10n.monthLogged(month.daysLogged),
                      if (month.periodDays > 0)
                        l10n.monthPeriod(month.periodDays),
                    ].join(' · '),
                    style: muted,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
