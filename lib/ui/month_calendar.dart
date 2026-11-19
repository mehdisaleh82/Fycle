import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/flow_intensity.dart';
import '../domain/period_prediction.dart';
import '../l10n/app_localizations.dart';
import 'labels.dart';
import 'theme.dart';

/// One month: logged period days as filled discs, the expected period as
/// rings, a dot under days with another entry. Built by hand, without a
/// calendar package (docs/DECISIONS.md, decision 11).
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.year,
    required this.month,
    required this.today,
    required this.flowByDay,
    required this.loggedDays,
    required this.prediction,
    required this.onDayTap,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final int year;
  final int month;
  final CalendarDay today;
  final Map<CalendarDay, FlowIntensity> flowByDay;
  final Set<CalendarDay> loggedDays;
  final PeriodPrediction? prediction;

  /// Called for today and past days. Days to come cannot be logged.
  final ValueChanged<CalendarDay> onDayTap;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  bool _isExpected(CalendarDay day) {
    final prediction = this.prediction;
    return prediction != null &&
        !day.isBefore(prediction.earliestStart) &&
        !day.isAfter(prediction.latestStart);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final theme = Theme.of(context);

    final firstWeekday = material.firstDayOfWeekIndex; // 0 is Sunday.
    final weekdayOfFirst = DateTime(year, month).weekday % 7;
    final leading = (weekdayOfFirst - firstWeekday + 7) % 7;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final rows = ((leading + daysInMonth) / 7).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l10n.calendarPreviousMonth,
              icon: const Icon(Icons.chevron_left),
              onPressed: onPreviousMonth,
            ),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  monthTitle(l10n, year, month),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.calendarNextMonth,
              icon: const Icon(Icons.chevron_right),
              onPressed: onNextMonth,
            ),
          ],
        ),
        const SizedBox(height: 4),
        ExcludeSemantics(
          child: Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        material.narrowWeekdays[(firstWeekday + i) % 7],
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        for (var row = 0; row < rows; row++)
          Row(
            children: [
              for (var column = 0; column < 7; column++)
                Expanded(child: _cell(row * 7 + column - leading + 1)),
            ],
          ),
        const SizedBox(height: 12),
        const _Legend(),
      ],
    );
  }

  Widget _cell(int dayOfMonth) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    if (dayOfMonth < 1 || dayOfMonth > daysInMonth) {
      return const AspectRatio(aspectRatio: 1);
    }
    final day = CalendarDay(year, month, dayOfMonth);
    final flow = flowByDay[day];
    return _DayCell(
      key: ValueKey('day-$day'),
      day: day,
      isToday: day == today,
      flow: flow,
      isExpected: flow == null && _isExpected(day),
      hasEntry: loggedDays.contains(day),
      onTap: day.isAfter(today) ? null : () => onDayTap(day),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    super.key,
    required this.day,
    required this.isToday,
    required this.flow,
    required this.isExpected,
    required this.hasEntry,
    required this.onTap,
  });

  final CalendarDay day;
  final bool isToday;
  final FlowIntensity? flow;
  final bool isExpected;
  final bool hasEntry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final period = PeriodColors.of(context);

    final isPeriod = flow != null && flow != FlowIntensity.spotting;
    final isSpotting = flow == FlowIntensity.spotting;

    final Color textColor;
    if (isPeriod) {
      textColor = period.onFill;
    } else if (onTap == null) {
      textColor = scheme.onSurfaceVariant;
    } else if (isToday) {
      textColor = scheme.primary;
    } else {
      textColor = scheme.onSurface;
    }

    final label = [
      weekdayDate(l10n, day),
      if (isToday) l10n.calendarDayToday,
      if (isPeriod) '${l10n.calendarDayPeriod}: ${flowLabel(l10n, flow!)}',
      if (isSpotting) l10n.calendarDaySpotting,
      if (isExpected) l10n.calendarDayExpected,
      if (hasEntry && flow == null) l10n.calendarDayEntry,
    ].join(', ');

    final Color? dotColor;
    if (isSpotting) {
      dotColor = period.fill;
    } else if (hasEntry && !isPeriod) {
      dotColor = scheme.onSurfaceVariant;
    } else {
      dotColor = null;
    }

    // The whole cell is the touch target; the disc is drawn slightly inside.
    return AspectRatio(
      aspectRatio: 1,
      child: Semantics(
        container: true,
        button: true,
        enabled: onTap != null,
        label: label,
        onTap: onTap,
        excludeSemantics: true,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPeriod ? period.fill : null,
                border: isExpected
                    ? Border.all(color: period.fill, width: 2)
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${day.day}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textColor,
                          fontWeight: isToday ? FontWeight.w900 : null,
                          decoration: isToday ? TextDecoration.underline : null,
                          decorationColor: textColor,
                        ),
                      ),
                    ),
                  ),
                  if (dotColor != null)
                    Align(
                      alignment: const Alignment(0, 0.82),
                      child: _Dot(color: dotColor, size: 5),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}

/// Explains the three marks of the calendar.
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final period = PeriodColors.of(context);
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _LegendItem(
          mark: _Dot(color: period.fill, size: 14),
          label: l10n.legendPeriod,
        ),
        _LegendItem(
          mark: SizedBox.square(
            dimension: 14,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: period.fill, width: 2),
              ),
            ),
          ),
          label: l10n.legendExpected,
        ),
        _LegendItem(
          mark: _Dot(color: scheme.onSurfaceVariant, size: 6),
          label: l10n.legendEntry,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.mark, required this.label});

  final Widget mark;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: mark),
        const SizedBox(width: 6),
        Flexible(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
