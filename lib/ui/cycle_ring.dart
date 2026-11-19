import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'theme.dart';

/// The cycle as a ring, read clockwise from the top: the period, then the
/// days that follow, then the range in which the next period is expected.
/// A dot marks today, and the day of the cycle is written in the middle.
///
/// A picture of the figures written next to it: it is hidden from screen
/// readers, which read the text instead.
class CycleRing extends StatelessWidget {
  const CycleRing({
    super.key,
    required this.dayOfCycle,
    required this.caption,
    required this.totalDays,
    required this.periodDays,
    required this.expectedFromDay,
    required this.expectedToDay,
    this.fertileFromDay,
    this.fertileToDay,
    this.centerText,
    this.size = 112,
  });

  /// 1 on the first day of the period. Null when nothing is logged: the
  /// ring is then empty.
  final int? dayOfCycle;

  /// The word written over the number, such as "Day".
  final String caption;

  /// Days the whole ring stands for.
  final int totalDays;

  /// Days of the period, from day 1.
  final int periodDays;

  /// First and last day of the cycle in the expected range, if any.
  final int? expectedFromDay;
  final int? expectedToDay;

  /// First and last day of the estimated fertile window, when it is shown.
  final int? fertileFromDay;
  final int? fertileToDay;

  /// Written in the middle instead of the day, for the reference cycle.
  final String? centerText;

  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AccentColors.of(context);
    final day = dayOfCycle;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(
            dayOfCycle: day,
            totalDays: math.max(totalDays, 1),
            periodDays: periodDays,
            expectedFromDay: expectedFromDay,
            expectedToDay: expectedToDay,
            fertileFromDay: fertileFromDay,
            fertileToDay: fertileToDay,
            track: accent.badge,
            period: PeriodColors.of(context).fill,
            expected: accent.mark,
            fertile: accent.onCard,
            marker: accent.onCard,
          ),
          child: Center(
            // The ring has a fixed size: the text inside does not grow with
            // the text size of the phone. The same figure is written beside.
            child: MediaQuery.withNoTextScaling(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    caption,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: accent.onCard,
                    ),
                  ),
                  Text(
                    centerText ?? (day == null ? '–' : '$day'),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: accent.onCard,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
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

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.dayOfCycle,
    required this.totalDays,
    required this.periodDays,
    required this.expectedFromDay,
    required this.expectedToDay,
    required this.fertileFromDay,
    required this.fertileToDay,
    required this.track,
    required this.period,
    required this.expected,
    required this.fertile,
    required this.marker,
  });

  final int? dayOfCycle;
  final int totalDays;
  final int periodDays;
  final int? expectedFromDay;
  final int? expectedToDay;
  final int? fertileFromDay;
  final int? fertileToDay;
  final Color track;
  final Color period;
  final Color expected;
  final Color fertile;
  final Color marker;

  static const double _stroke = 10;

  /// Angle at which day [day] starts (day 1 starts at the top).
  double _angle(num day) => -math.pi / 2 + 2 * math.pi * (day - 1) / totalDays;

  void _arc(
    Canvas canvas,
    Rect rect,
    int from,
    int to,
    Color color, {
    double width = _stroke,
  }) {
    final first = from.clamp(1, totalDays);
    final last = to.clamp(1, totalDays);
    if (last < first) {
      return;
    }
    canvas.drawArc(
      rect,
      _angle(first),
      2 * math.pi * (last - first + 1) / totalDays,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2 + 2);
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..color = track,
    );
    final today = dayOfCycle;
    final fertileFrom = fertileFromDay;
    final fertileTo = fertileToDay;
    if (fertileFrom != null && fertileTo != null) {
      // Thinner, inside the ring: a mark of its own.
      _arc(
        canvas,
        rect.deflate(_stroke / 2 + 4),
        fertileFrom,
        fertileTo,
        fertile,
        width: 3,
      );
    }
    final expectedFrom = expectedFromDay;
    final expectedTo = expectedToDay;
    if (expectedFrom != null && expectedTo != null) {
      _arc(canvas, rect, expectedFrom, expectedTo, expected);
    }
    if (periodDays > 0) {
      _arc(canvas, rect, 1, periodDays, period);
    }

    if (today == null) {
      return;
    }
    // Today: a dot in the middle of its day.
    final angle = _angle(today.clamp(1, totalDays) + 0.5);
    final radius = rect.width / 2;
    final position = Offset(
      rect.center.dx + radius * math.cos(angle),
      rect.center.dy + radius * math.sin(angle),
    );
    canvas
      ..drawCircle(position, _stroke / 2 + 3, Paint()..color = track)
      ..drawCircle(position, _stroke / 2, Paint()..color = marker);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.dayOfCycle != dayOfCycle ||
      old.totalDays != totalDays ||
      old.periodDays != periodDays ||
      old.expectedFromDay != expectedFromDay ||
      old.expectedToDay != expectedToDay ||
      old.fertileFromDay != fertileFromDay ||
      old.fertileToDay != fertileToDay ||
      old.track != track ||
      old.period != period ||
      old.expected != expected ||
      old.fertile != fertile ||
      old.marker != marker;
}
