import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/day_entry.dart';
import '../domain/flow_intensity.dart';
import '../domain/libido_level.dart';
import '../domain/mood.dart';
import '../domain/pain_level.dart';
import '../domain/sleep_quality.dart';
import '../domain/symptom.dart';
import '../l10n/app_localizations.dart';
import 'cycle_model.dart';
import 'labels.dart';

/// Opens the entry of [day]. Every tap is saved at once: logging a period
/// day takes two gestures, opening the sheet and choosing an intensity.
Future<void> showDaySheet(
  BuildContext context, {
  required CycleModel model,
  required CalendarDay day,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => _DaySheet(model: model, day: day),
  );
}

class _DaySheet extends StatefulWidget {
  const _DaySheet({required this.model, required this.day});

  final CycleModel model;
  final CalendarDay day;

  @override
  State<_DaySheet> createState() => _DaySheetState();
}

class _DaySheetState extends State<_DaySheet> {
  late DayEntry _entry;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _entry = widget.model.entryFor(widget.day);
    _note = TextEditingController(text: _entry.note ?? '');
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _save({
    FlowIntensity? Function()? flow,
    PainLevel? Function()? pain,
    Mood? Function()? mood,
    SleepQuality? Function()? sleep,
    LibidoLevel? Function()? libido,
    Set<Symptom>? symptoms,
  }) {
    final entry = DayEntry(
      day: widget.day,
      flow: flow == null ? _entry.flow : flow(),
      pain: pain == null ? _entry.pain : pain(),
      mood: mood == null ? _entry.mood : mood(),
      sleep: sleep == null ? _entry.sleep : sleep(),
      libido: libido == null ? _entry.libido : libido(),
      symptoms: symptoms ?? _entry.symptoms,
      note: _note.text,
    );
    widget.model.saveDay(entry);
    setState(() => _entry = entry);
  }

  void _toggleSymptom(Symptom symptom) {
    final symptoms = {..._entry.symptoms};
    if (!symptoms.remove(symptom)) {
      symptoms.add(symptom);
    }
    _save(symptoms: symptoms);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      // Keeps the note field above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      fullDate(l10n, widget.day),
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // At the top, so it stays in reach however long the sheet.
                FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.done),
                ),
              ],
            ),
            _Section(
              title: l10n.dayFlowTitle,
              children: [
                for (final flow in FlowIntensity.values)
                  ChoiceChip(
                    key: ValueKey('flow-${flow.name}'),
                    label: Text(flowLabel(l10n, flow)),
                    selected: _entry.flow == flow,
                    onSelected: (selected) =>
                        _save(flow: () => selected ? flow : null),
                  ),
              ],
            ),
            _Section(
              title: l10n.dayPainTitle,
              children: [
                for (final pain in PainLevel.values)
                  ChoiceChip(
                    key: ValueKey('pain-${pain.name}'),
                    label: Text(painLabel(l10n, pain)),
                    selected: _entry.pain == pain,
                    onSelected: (selected) =>
                        _save(pain: () => selected ? pain : null),
                  ),
              ],
            ),
            _Section(
              title: l10n.dayMoodTitle,
              children: [
                for (final mood in Mood.values)
                  ChoiceChip(
                    key: ValueKey('mood-${mood.name}'),
                    label: Text(moodLabel(l10n, mood)),
                    selected: _entry.mood == mood,
                    onSelected: (selected) =>
                        _save(mood: () => selected ? mood : null),
                  ),
              ],
            ),
            _Section(
              title: l10n.daySleepTitle,
              children: [
                for (final sleep in SleepQuality.values)
                  ChoiceChip(
                    key: ValueKey('sleep-${sleep.name}'),
                    label: Text(sleepLabel(l10n, sleep)),
                    selected: _entry.sleep == sleep,
                    onSelected: (selected) =>
                        _save(sleep: () => selected ? sleep : null),
                  ),
              ],
            ),
            _Section(
              title: l10n.dayLibidoTitle,
              children: [
                for (final libido in LibidoLevel.values)
                  ChoiceChip(
                    key: ValueKey('libido-${libido.name}'),
                    label: Text(libidoLabel(l10n, libido)),
                    selected: _entry.libido == libido,
                    onSelected: (selected) =>
                        _save(libido: () => selected ? libido : null),
                  ),
              ],
            ),
            _Section(
              title: l10n.daySymptomsTitle,
              children: [
                for (final symptom in Symptom.values)
                  FilterChip(
                    key: ValueKey('symptom-${symptom.name}'),
                    label: Text(symptomLabel(l10n, symptom)),
                    selected: _entry.symptoms.contains(symptom),
                    onSelected: (_) => _toggleSymptom(symptom),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _note,
              minLines: 2,
              maxLines: 5,
              maxLength: 2000,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => _save(),
              decoration: InputDecoration(
                labelText: l10n.dayNoteLabel,
                hintText: l10n.dayNoteHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.daySavedHint, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}
