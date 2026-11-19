import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/day_entry.dart';
import '../domain/flow_intensity.dart';
import '../domain/logging_streak.dart';
import '../l10n/app_localizations.dart';
import 'cycle_model.dart';
import 'labels.dart';

/// Logging today's period in one gesture, from the home screen: a tap on an
/// intensity saves it, a second tap takes it back. Whatever else is logged
/// for the day is kept.
///
/// Also shows, discreetly, how many days in a row were logged: a plain
/// count, without praise, and nothing at all when the run stops.
class TodayCard extends StatelessWidget {
  const TodayCard({super.key, required this.model, required this.today});

  final CycleModel model;
  final CalendarDay today;

  void _setFlow(FlowIntensity? flow) {
    final entry = model.entryFor(today);
    // A light tick under the finger: the tap was taken into account.
    HapticFeedback.selectionClick();
    model.saveDay(
      DayEntry(
        day: today,
        flow: flow,
        pain: entry.pain,
        mood: entry.mood,
        symptoms: entry.symptoms,
        note: entry.note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final current = model.flowByDay[today];
    final streak = loggingStreak(model.loggedDays, today);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.todayCardTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final flow in FlowIntensity.values)
                  ChoiceChip(
                    key: ValueKey('quick-flow-${flow.name}'),
                    label: Text(flowLabel(l10n, flow)),
                    selected: current == flow,
                    onSelected: (selected) => _setFlow(selected ? flow : null),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.todayCardHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (streak >= minStreakShown) ...[
              const SizedBox(height: 4),
              Text(
                l10n.loggingStreak(streak),
                key: const ValueKey('logging-streak'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
