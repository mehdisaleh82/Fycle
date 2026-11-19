import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/period_predictor.dart';
import '../l10n/app_localizations.dart';

/// What the user typed as her usual cycle length. An empty field is valid
/// and means "not known".
({bool valid, int? days}) readCycleLength(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    return (valid: true, days: null);
  }
  final days = int.tryParse(trimmed);
  if (days == null ||
      days < PeriodPredictor.minCycleLength ||
      days > PeriodPredictor.maxCycleLength) {
    return (valid: false, days: null);
  }
  return (valid: true, days: days);
}

/// Optional number of days, with an explanation of what a cycle is.
class CycleLengthField extends StatelessWidget {
  const CycleLengthField({
    super.key,
    required this.controller,
    required this.showError,
    this.autofocus = false,
    this.onChanged,
  });

  final TextEditingController controller;

  /// Whether to tell that the current text is not an accepted length.
  final bool showError;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: l10n.cycleLengthFieldLabel,
        helperText: l10n.cycleLengthHelper,
        helperMaxLines: 6,
        errorMaxLines: 4,
        errorText: showError
            ? l10n.cycleLengthError(
                PeriodPredictor.minCycleLength,
                PeriodPredictor.maxCycleLength,
              )
            : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
