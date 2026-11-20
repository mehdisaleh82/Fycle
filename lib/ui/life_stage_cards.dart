import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/life_stage.dart';
import '../l10n/app_localizations.dart';
import 'cycle_model.dart';
import 'labels.dart';
import 'theme.dart';

/// Asks for a day in the past, with the system date picker.
Future<CalendarDay?> pickPastDay(
  BuildContext context, {
  required CalendarDay today,
  required int daysBack,
  CalendarDay? current,
}) async {
  final last = DateTime(today.year, today.month, today.day);
  // Days of the calendar, not 24-hour steps: a clock change in between
  // must not move the limit.
  final first = DateTime(today.year, today.month, today.day - daysBack);
  var initial = current == null
      ? last
      : DateTime(current.year, current.month, current.day);
  if (initial.isAfter(last) || initial.isBefore(first)) {
    initial = last;
  }
  final picked = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: first,
    lastDate: last,
    // The system date picker has a fixed layout.
    builder: (context, child) =>
        MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3, child: child!),
  );
  return picked == null ? null : CalendarDay.fromDateTime(picked);
}

/// How far back the first day of the last period of a pregnancy, and a
/// birth, may be picked.
const int pregnancyDaysBack = 320;
const int birthDaysBack = 730;

/// The top of the home during a pregnancy: the weeks gone by since the
/// first day of the last period, and between which days a birth would be
/// at term. It counts from the date she gave and says so; it dates nothing
/// by itself. The estimate of periods is paused.
class PregnancyCard extends StatelessWidget {
  const PregnancyCard({super.key, required this.model, required this.today});

  final CycleModel model;
  final CalendarDay today;

  Future<void> _changeDate(BuildContext context) async {
    final picked = await pickPastDay(
      context,
      today: today,
      daysBack: pregnancyDaysBack,
      current: model.pregnancyStart,
    );
    if (picked != null) {
      model.setProfile(Profile.pregnant, pregnancyStart: picked);
    }
  }

  /// Leaving asks where she is now, and nothing else.
  Future<void> _leave(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final next = await showDialog<Profile>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.leaveTitle),
        children: [
          SimpleDialogOption(
            key: const ValueKey('leave-gave-birth'),
            onPressed: () => Navigator.of(context).pop(Profile.postpartum),
            child: Text(l10n.leaveGaveBirth),
          ),
          SimpleDialogOption(
            key: const ValueKey('leave-back-to-cycle'),
            onPressed: () => Navigator.of(context).pop(Profile.tracking),
            child: Text(l10n.leaveBackToCycle),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
    if (next == null || !context.mounted) {
      return;
    }
    if (next == Profile.postpartum) {
      final delivery = await pickPastDay(
        context,
        today: today,
        daysBack: birthDaysBack,
      );
      model.setProfile(Profile.postpartum, deliveryDate: delivery);
    } else {
      model.setProfile(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final start = model.pregnancyStart;
    final progress = start == null ? null : pregnancyProgressOn(today, start);
    return _StageCard(
      name: 'pregnancy-card',
      label: l10n.pregnancyTitle,
      title: progress == null
          ? null
          : l10n.pregnancyWeeks(progress.weeks, progress.days),
      lines: [
        if (progress == null)
          l10n.pregnancyNoDate
        else ...[
          l10n.pregnancyCounted,
          if (progress.pastTerm)
            l10n.pregnancyPast
          else ...[
            l10n.pregnancyTerm(
              mediumDate(l10n, progress.termFrom),
              mediumDate(l10n, progress.termTo),
            ),
            l10n.pregnancyNote,
          ],
        ],
        l10n.pregnancyPaused,
      ],
      actions: [
        _StageAction(
          name: 'pregnancy-date',
          label: start == null ? l10n.setupChooseDate : l10n.changeDate,
          onPressed: () => _changeDate(context),
        ),
        _StageAction(
          name: 'pregnancy-leave',
          label: l10n.pregnancyLeave,
          onPressed: () => _leave(context),
        ),
      ],
    );
  }
}

/// The top of the home after a birth, until a period is logged again: the
/// weeks gone by, and what brings the estimate back.
class PostpartumCard extends StatelessWidget {
  const PostpartumCard({super.key, required this.model, required this.today});

  final CycleModel model;
  final CalendarDay today;

  Future<void> _changeDate(BuildContext context) async {
    final picked = await pickPastDay(
      context,
      today: today,
      daysBack: birthDaysBack,
      current: model.deliveryDate,
    );
    if (picked != null) {
      model.setProfile(Profile.postpartum, deliveryDate: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final delivery = model.deliveryDate;
    final weeks = delivery == null ? null : weeksSince(today, delivery);
    return _StageCard(
      name: 'postpartum-card',
      label: l10n.postpartumTitle,
      title: weeks == null ? null : l10n.postpartumWeeks(weeks),
      lines: [if (weeks == null) l10n.postpartumNoDate, l10n.postpartumBody],
      actions: [
        _StageAction(
          name: 'postpartum-date',
          label: delivery == null ? l10n.setupChooseDate : l10n.changeDate,
          onPressed: () => _changeDate(context),
        ),
        _StageAction(
          name: 'postpartum-leave',
          label: l10n.leaveBackToCycle,
          onPressed: () => model.setProfile(Profile.tracking),
        ),
      ],
    );
  }
}

class _StageAction {
  const _StageAction({
    required this.name,
    required this.label,
    required this.onPressed,
  });

  final String name;
  final String label;
  final VoidCallback onPressed;
}

/// The card at the top of the home, in the colours of the estimate card.
class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.name,
    required this.label,
    required this.title,
    required this.lines,
    required this.actions,
  });

  final String name;
  final String label;
  final String? title;
  final List<String> lines;
  final List<_StageAction> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AccentColors.of(context);
    final onCard = accent.onCard;
    final title = this.title;
    return Card(
      key: ValueKey(name),
      color: accent.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(color: onCard),
            ),
            if (title != null) ...[
              const SizedBox(height: 4),
              Semantics(
                header: true,
                child: Text(
                  title,
                  key: ValueKey('$name-title'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(color: onCard),
                ),
              ),
            ],
            for (final (index, line) in lines.indexed) ...[
              SizedBox(height: index == 0 ? 8 : 4),
              Text(
                line,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: onCard),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final action in actions)
                  TextButton(
                    key: ValueKey(action.name),
                    style: TextButton.styleFrom(foregroundColor: onCard),
                    onPressed: action.onPressed,
                    child: Text(action.label),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// For the one who discovers her cycle: a few plain facts, in her words.
/// What a cycle is and how much it varies; nothing about what hers should
/// be.
class LearnCard extends StatelessWidget {
  const LearnCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      key: const ValueKey('learn-card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(l10n.learnTitle, style: theme.textTheme.titleMedium),
            ),
            for (final fact in [
              l10n.learnCycle,
              l10n.learnLength,
              l10n.learnFirstYears,
              l10n.learnLogging,
            ]) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(fact, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
