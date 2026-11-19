import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/reference_cycle.dart';
import '../l10n/app_localizations.dart';

/// What the user typed as her year of birth, read in [currentYear]. An empty
/// field is valid and means "not given".
({bool valid, int? year}) readBirthYear(String text, int currentYear) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    return (valid: true, year: null);
  }
  final year = int.tryParse(trimmed);
  if (year == null || ageIn(currentYear, year) == null) {
    return (valid: false, year: null);
  }
  return (valid: true, year: year);
}

/// Optional year of birth, with what it is used for.
class BirthYearField extends StatelessWidget {
  const BirthYearField({
    super.key,
    required this.controller,
    required this.currentYear,
    required this.showError,
    this.autofocus = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final int currentYear;

  /// Whether to tell that the current text is not an accepted year.
  final bool showError;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      key: const ValueKey('birth-year-field'),
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: l10n.birthYearLabel,
        helperText: l10n.birthYearHelper,
        helperMaxLines: 6,
        errorMaxLines: 4,
        errorText: showError
            ? l10n.birthYearError(
                currentYear - maxProfileAge,
                currentYear - minProfileAge,
              )
            : null,
      ),
    );
  }
}
