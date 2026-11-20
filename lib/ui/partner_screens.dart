import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:qr/qr.dart';

import '../data/backup_codec.dart';
import '../domain/calendar_day.dart';
import '../domain/desire_pattern.dart';
import '../domain/guide.dart';
import '../domain/life_stage.dart';
import '../domain/partner_link.dart';
import '../domain/partner_snapshot.dart';
import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'cycle_model.dart';
import 'dialogs.dart';
import 'labels.dart';
import 'theme.dart';

/// The picture of where she is today, with what she agreed to share.
PartnerSnapshot partnerSnapshotOf(
  CycleModel model,
  CalendarDay today, {
  required bool shareName,
  required bool shareFertility,
  bool shareDesire = false,
}) {
  final prediction = model.prediction;
  final fertility = shareFertility ? model.fertilityEstimate : null;
  final cycles = model.cycles;
  final desire = shareDesire ? desireDatesToShare(model, today) : null;
  return PartnerSnapshot(
    madeOn: today,
    name: shareName ? model.firstName : null,
    profile: model.profile,
    cycleStart: cycles.isEmpty ? null : cycles.last.start,
    periodLength: cycles.isEmpty ? 0 : cycles.last.periodLength,
    cycleLength: prediction?.estimatedCycleLength,
    earliestNext: prediction?.earliestStart,
    latestNext: prediction?.latestStart,
    fertileFrom: fertility?.windowStart,
    fertileTo: fertility?.windowEnd,
    desireFrom: desire?.from,
    desireTo: desire?.to,
    pregnancyStart: model.profile == Profile.pregnant
        ? model.pregnancyStart
        : null,
    deliveryDate: model.profile == Profile.postpartum
        ? model.deliveryDate
        : null,
  );
}

/// The coming days her desire is often higher, when there is something to
/// share: she is shown that topic, she logged it over enough cycles, and
/// the days are not behind.
({CalendarDay from, CalendarDay to})? desireDatesToShare(
  CycleModel model,
  CalendarDay today,
) {
  if (model.cycles.isEmpty ||
      !followsACycle(model.profile) ||
      !showsIntimacy(
        sexLifeVisible: model.sexLifeVisible,
        age: model.age,
        profile: model.profile,
      )) {
    return null;
  }
  final window = usualDesireWindow(cycles: model.cycles, days: model.days);
  if (window == null) {
    return null;
  }
  return desireDatesAhead(
    window,
    cycleStart: model.cycles.last.start,
    today: today,
    prediction: model.prediction,
  );
}

/// Her side: a card with a code her partner scans with the camera of the
/// phone, which opens the app on what she shares. From her screen to that
/// camera: the app sends nothing. A protected file stays possible, for a
/// partner who is far away.
class PartnerShareScreen extends StatefulWidget {
  const PartnerShareScreen({
    super.key,
    required this.model,
    required this.environment,
  });

  final CycleModel model;
  final AppEnvironment environment;

  @override
  State<PartnerShareScreen> createState() => _PartnerShareScreenState();
}

class _PartnerShareScreenState extends State<PartnerShareScreen> {
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  late bool _shareName = widget.model.firstName != null;
  late bool _shareFertility = false;
  bool _shareDesire = false;
  String? _passwordError;
  String? _repeatError;
  bool _busy = false;

  /// Whether the way by file is unfolded.
  bool _byFile = false;

  @override
  void dispose() {
    _password.dispose();
    _repeat.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    final password = _password.text;
    final tooShort = password.runes.length < minBackupPasswordLength;
    final mismatch = !tooShort && _repeat.text != password;
    setState(() {
      _passwordError = tooShort
          ? l10n.passwordTooShort(minBackupPasswordLength)
          : null;
      _repeatError = mismatch ? l10n.passwordMismatch : null;
    });
    if (tooShort || mismatch) {
      return;
    }
    setState(() => _busy = true);
    final today = widget.environment.today();
    var saved = false;
    try {
      final snapshot = partnerSnapshotOf(
        widget.model,
        today,
        shareName: _shareName,
        shareFertility: _shareFertility,
        shareDesire: _shareDesire,
      );
      final bytes = await widget.model.store.encryptText(
        jsonEncode(snapshot.toJson()),
        password,
      );
      saved = await widget.environment.files.save(
        fileName: 'fycle-partner-$today.$backupFileExtension',
        bytes: bytes,
      );
    } on Exception {
      saved = false;
    }
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    if (saved) {
      await showNotice(
        context,
        title: l10n.partnerSavedTitle,
        body: l10n.partnerSavedBody,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = AccentColors.of(context);
    final model = widget.model;
    final name = _shareName ? model.firstName : null;
    final today = widget.environment.today();
    final shown = partnerSnapshotOf(
      model,
      today,
      shareName: _shareName,
      shareFertility: _shareFertility,
      shareDesire: _shareDesire,
    );
    final link = partnerLinkOf(shown);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.partnerShareTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                key: const ValueKey('partner-invite'),
                color: accent.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (name != null) ...[
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: accent.onCard,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: PartnerCode(link: link),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.partnerInviteScan,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: accent.onCard,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.partnerInviteWhat,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              if (model.firstName != null)
                SwitchListTile(
                  key: const ValueKey('partner-share-name'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.partnerShareName),
                  value: _shareName,
                  onChanged: (on) => setState(() => _shareName = on),
                ),
              if (model.fertilityEstimate != null)
                SwitchListTile(
                  key: const ValueKey('partner-share-fertility'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.partnerShareFertility),
                  subtitle: Text(l10n.partnerFertilityNote),
                  value: _shareFertility,
                  onChanged: (on) => setState(() => _shareFertility = on),
                ),
              if (desireDatesToShare(model, today) != null)
                SwitchListTile(
                  key: const ValueKey('partner-share-desire'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.partnerShareDesire),
                  subtitle: Text(l10n.partnerShareDesireNote),
                  value: _shareDesire,
                  onChanged: (on) => setState(() => _shareDesire = on),
                ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  key: const ValueKey('partner-preview'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => PartnerScreen(
                        snapshot: shown,
                        today: today,
                        preview: true,
                        onReplace: () {},
                        onLeave: () {},
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.visibility_outlined),
                  label: Text(l10n.partnerPreview),
                ),
              ),
              if (!_byFile)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    key: const ValueKey('partner-file'),
                    onPressed: () => setState(() => _byFile = true),
                    child: Text(l10n.partnerInviteFile),
                  ),
                )
              else ...[
                const SizedBox(height: 12),
                Text(l10n.partnerShareIntro, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                PasswordField(
                  controller: _password,
                  label: l10n.partnerPassword,
                  errorText: _passwordError,
                  enabled: !_busy,
                ),
                const SizedBox(height: 12),
                PasswordField(
                  controller: _repeat,
                  label: l10n.passwordRepeatLabel,
                  errorText: _repeatError,
                  enabled: !_busy,
                  onSubmitted: _create,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  key: const ValueKey('partner-create'),
                  onPressed: _busy ? null : _create,
                  icon: const Icon(Icons.ios_share),
                  label: Text(l10n.partnerCreate),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The code a partner scans: dark squares on white whatever the theme, with
/// the quiet margin a camera needs around it.
class PartnerCode extends StatelessWidget {
  const PartnerCode({super.key, required this.link});

  final String link;

  @override
  Widget build(BuildContext context) {
    final image = QrImage(
      QrCode.fromData(data: link, errorCorrectLevel: QrErrorCorrectLevel.M),
    );
    return Semantics(
      key: const ValueKey('partner-qr'),
      image: true,
      label: AppLocalizations.of(context).partnerQrLabel,
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: CustomPaint(painter: _CodePainter(image)),
        ),
      ),
    );
  }
}

class _CodePainter extends CustomPainter {
  _CodePainter(this.image);

  final QrImage image;

  /// Empty squares kept around the code.
  static const int _quiet = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final count = image.moduleCount;
    final side = size.shortestSide / (count + 2 * _quiet);
    final paint = Paint()..color = const Color(0xFF2B1A24);
    for (var row = 0; row < count; row++) {
      for (var column = 0; column < count; column++) {
        if (image.isDark(row, column)) {
          // A hair wider than a square, so that no seam shows between two.
          canvas.drawRect(
            Rect.fromLTWH(
              (column + _quiet) * side,
              (row + _quiet) * side,
              side + 0.5,
              side + 0.5,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_CodePainter old) => old.image != image;
}

/// Asks for the password of a partner file. Returns null if cancelled.
Future<String?> askPartnerPassword(BuildContext context) {
  final controller = TextEditingController();
  final l10n = AppLocalizations.of(context);
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      scrollable: true,
      title: Text(l10n.partnerOpenTitle),
      content: PasswordField(
        controller: controller,
        label: l10n.partnerPassword,
        autofocus: true,
        onSubmitted: () => Navigator.of(context).pop(controller.text),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const ValueKey('partner-open-confirm'),
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: Text(l10n.partnerOpenAction),
        ),
      ],
    ),
  );
}

/// His side: what she shared, read on the day he looks at it. Nothing can
/// be changed here, and nothing is sent anywhere.
class PartnerScreen extends StatelessWidget {
  const PartnerScreen({
    super.key,
    required this.snapshot,
    required this.today,
    required this.onReplace,
    required this.onLeave,
    this.preview = false,
  });

  final PartnerSnapshot snapshot;
  final CalendarDay today;

  /// Shown to her, on her own phone, before she shares: says so, can be
  /// left with the back arrow, and offers nothing to replace or stop.
  final bool preview;

  /// Loads a newer file.
  final VoidCallback onReplace;

  /// Leaves the partner view for good.
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = AccentColors.of(context);
    final onCard = accent.onCard;
    final status = partnerStatusOn(today, snapshot);
    final name = snapshot.name;
    final earliest = status.earliest ?? snapshot.earliestNext;
    final latest = status.latest ?? snapshot.latestNext;
    final range = earliest == null || latest == null
        ? null
        : l10n.partnerRange(shortDate(l10n, earliest), shortDate(l10n, latest));
    final pregnancy = snapshot.pregnancyStart;
    final delivery = snapshot.deliveryDate;

    final String title;
    final lines = <String>[];
    switch (status.moment) {
      case PartnerMoment.pregnant:
        final progress = pregnancy == null
            ? null
            : pregnancyProgressOn(today, pregnancy);
        title = progress == null
            ? l10n.partnerPregnant
            : l10n.pregnancyWeeks(progress.weeks, progress.days);
        if (progress != null) {
          lines.add(l10n.partnerPregnancyCounted);
        }
      case PartnerMoment.afterBirth:
        final weeks = delivery == null ? null : weeksSince(today, delivery);
        title = weeks == null
            ? l10n.partnerAfterBirth
            : l10n.partnerWeeksSinceBirth(weeks);
        lines.add(l10n.partnerAfterBirthBody);
      case PartnerMoment.periodOngoing:
        title = l10n.partnerPeriodOngoing;
        if (range != null) {
          lines.add(range);
        }
      case PartnerMoment.beforePeriod:
        title = l10n.partnerPeriodIn(
          status.daysUntilEarliest!,
          status.daysUntilLatest!,
        );
        if (range != null) {
          lines.add(range);
        }
      case PartnerMoment.periodExpected:
        title = l10n.partnerPeriodExpected;
        if (range != null) {
          lines.add(range);
        }
      case PartnerMoment.outdated:
        title = l10n.partnerOutdatedTitle;
        lines.add(l10n.partnerOutdatedBody);
      case PartnerMoment.unknown:
        title = l10n.partnerUnknownTitle;
        lines.add(l10n.partnerUnknownBody);
    }
    final day = status.dayOfCycle;
    final from = snapshot.fertileFrom;
    final to = snapshot.fertileTo;
    final showFertile =
        from != null &&
        to != null &&
        !today.isAfter(to) &&
        status.moment != PartnerMoment.outdated;
    final ahead = status.moment == PartnerMoment.outdated
        ? const <({CalendarDay earliest, CalendarDay latest})>[]
        : partnerPeriodsAhead(today, snapshot);
    final desireFrom = snapshot.desireFrom;
    final desireTo = snapshot.desireTo;
    final showDesire =
        desireFrom != null &&
        desireTo != null &&
        !today.isAfter(desireTo) &&
        status.moment != PartnerMoment.outdated;
    return Scaffold(
      appBar: preview ? AppBar(title: Text(l10n.partnerPreview)) : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (preview) ...[
                Text(
                  l10n.partnerPreviewBanner,
                  key: const ValueKey('partner-preview-banner'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Semantics(
                header: true,
                child: Text(
                  name == null
                      ? l10n.partnerHeader
                      : l10n.partnerHeaderOf(name),
                  key: const ValueKey('partner-header'),
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.partnerReadOnly,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                key: const ValueKey('partner-card'),
                color: accent.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (day != null)
                        Text(
                          l10n.partnerDayOfCycle(day),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: onCard,
                          ),
                        ),
                      Text(
                        title,
                        key: const ValueKey('partner-title'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: onCard,
                        ),
                      ),
                      for (final line in lines) ...[
                        const SizedBox(height: 6),
                        Text(
                          line,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: onCard,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (showFertile) ...[
                const SizedBox(height: 16),
                Card(
                  key: const ValueKey('partner-fertility'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.partnerFertileWindow(
                            shortDate(l10n, from),
                            shortDate(l10n, to),
                          ),
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        // An estimate comes with what it is not (rule 7).
                        Text(
                          l10n.partnerFertilityNote,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (ahead.length > 1 || showDesire) ...[
                const SizedBox(height: 16),
                Card(
                  key: const ValueKey('partner-ahead'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.partnerAheadTitle,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        for (final (index, range) in ahead.indexed) ...[
                          const SizedBox(height: 10),
                          _AheadLine(
                            key: ValueKey('partner-ahead-period-$index'),
                            icon: Icons.water_drop_outlined,
                            text: l10n.partnerAheadPeriod(
                              shortDate(l10n, range.earliest),
                              shortDate(l10n, range.latest),
                            ),
                          ),
                        ],
                        if (showDesire) ...[
                          const SizedBox(height: 10),
                          _AheadLine(
                            key: const ValueKey('partner-ahead-desire'),
                            icon: Icons.favorite_outline,
                            text: l10n.partnerAheadDesire(
                              shortDate(l10n, desireFrom),
                              shortDate(l10n, desireTo),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // A count of past entries, never her answer.
                          Text(
                            l10n.partnerDesireNote,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                l10n.partnerMadeOn(mediumDate(l10n, snapshot.madeOn)),
                key: const ValueKey('partner-made-on'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (!preview) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  key: const ValueKey('partner-replace'),
                  onPressed: onReplace,
                  icon: const Icon(Icons.file_open_outlined),
                  label: Text(l10n.partnerReplace),
                ),
                const SizedBox(height: 8),
                TextButton(
                  key: const ValueKey('partner-leave'),
                  onPressed: onLeave,
                  child: Text(l10n.partnerLeave),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AheadLine extends StatelessWidget {
  const _AheadLine({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
