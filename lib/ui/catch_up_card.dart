import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/catch_up.dart';
import '../l10n/app_localizations.dart';
import 'cycle_model.dart';
import 'home_cards.dart';
import 'labels.dart';
import 'life_stage_cards.dart';

/// One question, answered in one tap, to fill in what was left out of the
/// log: a period that started without being logged, or a period logged on
/// its first days only. A neutral question, never a reproach (CLAUDE.md,
/// rule 13); nothing is filled in without her answer, and every answer can
/// be changed in the journal.
class CatchUpCard extends StatelessWidget {
  const CatchUpCard({
    super.key,
    required this.model,
    required this.today,
    required this.ask,
  });

  final CycleModel model;
  final CalendarDay today;
  final CatchUp ask;

  int get _periodLength => periodLengthToFill(
    cycles: model.cycles,
    declaredPeriodLength: model.usualPeriodLength,
  );

  void _startedOn(CalendarDay start) {
    HapticFeedback.selectionClick();
    model.fillPeriodDays(
      daysSinceStart(start, today, periodLength: _periodLength),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final ask = this.ask;
    final String title;
    final String? body;
    final List<Widget> answers;
    switch (ask) {
      case AskPeriodStarted(:final earliestStart):
        final yesterday = today.addDays(-1);
        title = l10n.catchUpStartedTitle;
        body = null;
        answers = [
          FilledButton.tonal(
            key: const ValueKey('catch-up-today'),
            onPressed: () => _startedOn(today),
            child: Text(l10n.catchUpToday),
          ),
          if (!yesterday.isBefore(earliestStart))
            OutlinedButton(
              key: const ValueKey('catch-up-yesterday'),
              onPressed: () => _startedOn(yesterday),
              child: Text(l10n.catchUpYesterday),
            ),
          if (yesterday.isAfter(earliestStart))
            OutlinedButton(
              key: const ValueKey('catch-up-other-day'),
              onPressed: () async {
                final start = await pickPastDay(
                  context,
                  today: today,
                  daysBack: today.daysSince(earliestStart),
                );
                if (start != null) {
                  _startedOn(start);
                }
              },
              child: Text(l10n.catchUpOtherDay),
            ),
          TextButton(
            key: const ValueKey('catch-up-not-yet'),
            onPressed: () => model.answerPeriodNotYet(today),
            child: Text(l10n.catchUpNotYet),
          ),
        ];
      case AskPeriodContinues(:final lastFlowDay):
        title = l10n.catchUpContinuesTitle;
        body = l10n.catchUpContinuesBody(weekdayDate(l10n, lastFlowDay));
        answers = [
          FilledButton.tonal(
            key: const ValueKey('catch-up-continues'),
            onPressed: () {
              HapticFeedback.selectionClick();
              model.fillPeriodDays(daysSinceLastFlow(lastFlowDay, today));
            },
            child: Text(l10n.catchUpContinuesYes),
          ),
          TextButton(
            key: const ValueKey('catch-up-ended'),
            onPressed: () => model.answerPeriodEnded(lastFlowDay),
            child: Text(l10n.catchUpContinuesNo),
          ),
        ];
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TitledCard(
        key: const ValueKey('catch-up'),
        title: title,
        children: [
          if (body != null) ...[
            Text(body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
          ],
          Wrap(spacing: 8, runSpacing: 4, children: answers),
          const SizedBox(height: 8),
          Text(l10n.catchUpHint, style: muted),
        ],
      ),
    );
  }
}
