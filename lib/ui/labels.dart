import 'package:intl/intl.dart';

import '../data/csv_export.dart';
import '../domain/calendar_day.dart';
import '../domain/flow_intensity.dart';
import '../domain/libido_level.dart';
import '../domain/mood.dart';
import '../domain/pain_level.dart';
import '../domain/period_prediction.dart';
import '../domain/sleep_quality.dart';
import '../domain/symptom.dart';
import '../l10n/app_localizations.dart';

/// Translated names of the stored choices, and date formatting.

String flowLabel(AppLocalizations l10n, FlowIntensity flow) => switch (flow) {
  FlowIntensity.spotting => l10n.flowSpotting,
  FlowIntensity.light => l10n.flowLight,
  FlowIntensity.medium => l10n.flowMedium,
  FlowIntensity.heavy => l10n.flowHeavy,
};

String painLabel(AppLocalizations l10n, PainLevel pain) => switch (pain) {
  PainLevel.none => l10n.painNone,
  PainLevel.mild => l10n.painMild,
  PainLevel.moderate => l10n.painModerate,
  PainLevel.severe => l10n.painSevere,
};

String moodLabel(AppLocalizations l10n, Mood mood) => switch (mood) {
  Mood.happy => l10n.moodHappy,
  Mood.calm => l10n.moodCalm,
  Mood.sad => l10n.moodSad,
  Mood.anxious => l10n.moodAnxious,
  Mood.irritable => l10n.moodIrritable,
};

String sleepLabel(AppLocalizations l10n, SleepQuality sleep) => switch (sleep) {
  SleepQuality.poor => l10n.sleepPoor,
  SleepQuality.fair => l10n.sleepFair,
  SleepQuality.good => l10n.sleepGood,
};

String libidoLabel(AppLocalizations l10n, LibidoLevel libido) =>
    switch (libido) {
      LibidoLevel.low => l10n.libidoLow,
      LibidoLevel.medium => l10n.libidoMedium,
      LibidoLevel.high => l10n.libidoHigh,
    };

String symptomLabel(AppLocalizations l10n, Symptom symptom) =>
    switch (symptom) {
      Symptom.cramps => l10n.symptomCramps,
      Symptom.headache => l10n.symptomHeadache,
      Symptom.backPain => l10n.symptomBackPain,
      Symptom.breastTenderness => l10n.symptomBreastTenderness,
      Symptom.bloating => l10n.symptomBloating,
      Symptom.nausea => l10n.symptomNausea,
      Symptom.fatigue => l10n.symptomFatigue,
      Symptom.acne => l10n.symptomAcne,
      Symptom.cravings => l10n.symptomCravings,
      Symptom.insomnia => l10n.symptomInsomnia,
    };

/// The name of a sign listed in the trends: a symptom as it is, any other
/// choice with the name of its group, such as "Sleep: Poor".
String signLabel(AppLocalizations l10n, Enum sign) => switch (sign) {
  Symptom() => symptomLabel(l10n, sign),
  PainLevel() => l10n.signWithKind(l10n.dayPainTitle, painLabel(l10n, sign)),
  Mood() => l10n.signWithKind(l10n.dayMoodTitle, moodLabel(l10n, sign)),
  SleepQuality() => l10n.signWithKind(
    l10n.daySleepTitle,
    sleepLabel(l10n, sign),
  ),
  LibidoLevel() => l10n.signWithKind(
    l10n.dayLibidoTitle,
    libidoLabel(l10n, sign),
  ),
  _ => sign.name,
};

/// What the estimate of the next period rests on.
String estimateBasis(
  AppLocalizations l10n,
  PeriodPrediction prediction, {
  required int? declaredLength,
  required int assumedLength,
}) {
  if (prediction.cyclesUsed > 0) {
    return l10n.estimateBasisCycles(prediction.cyclesUsed);
  }
  return declaredLength != null
      ? l10n.estimateBasisDeclared(declaredLength)
      : l10n.estimateBasisDefault(assumedLength);
}

String confidenceLabel(AppLocalizations l10n, PeriodPrediction prediction) =>
    switch (prediction.confidence) {
      PredictionConfidence.low => l10n.confidenceLow,
      PredictionConfidence.medium => l10n.confidenceMedium,
      PredictionConfidence.high => l10n.confidenceHigh,
    };

/// The words of the CSV export in the language of the interface.
CsvLabels csvLabels(AppLocalizations l10n) => CsvLabels(
  date: l10n.csvDateHeader,
  flow: l10n.dayFlowTitle,
  pain: l10n.dayPainTitle,
  mood: l10n.dayMoodTitle,
  sleep: l10n.daySleepTitle,
  libido: l10n.dayLibidoTitle,
  symptoms: l10n.daySymptomsTitle,
  note: l10n.dayNoteLabel,
  flowName: (flow) => flowLabel(l10n, flow),
  painName: (pain) => painLabel(l10n, pain),
  moodName: (mood) => moodLabel(l10n, mood),
  sleepName: (sleep) => sleepLabel(l10n, sleep),
  libidoName: (libido) => libidoLabel(l10n, libido),
  symptomName: (symptom) => symptomLabel(l10n, symptom),
);

DateTime _dateTime(CalendarDay day) => DateTime(day.year, day.month, day.day);

/// "Mar 5" / "5 mars".
String shortDate(AppLocalizations l10n, CalendarDay day) =>
    DateFormat.MMMd(l10n.localeName).format(_dateTime(day));

/// "Mar 5, 2026" / "5 mars 2026".
String mediumDate(AppLocalizations l10n, CalendarDay day) =>
    DateFormat.yMMMd(l10n.localeName).format(_dateTime(day));

/// A number of days with at most one decimal: "28", "28.5" / "28,5".
String dayCount(AppLocalizations l10n, double days) =>
    NumberFormat('0.#', l10n.localeName).format(days);

/// "Thursday, March 5, 2026" / "jeudi 5 mars 2026".
String fullDate(AppLocalizations l10n, CalendarDay day) =>
    DateFormat.yMMMMEEEEd(l10n.localeName).format(_dateTime(day));

/// "Thursday, March 5" / "jeudi 5 mars".
String weekdayDate(AppLocalizations l10n, CalendarDay day) =>
    DateFormat.MMMMEEEEd(l10n.localeName).format(_dateTime(day));

/// "March 2026" / "mars 2026".
String monthTitle(AppLocalizations l10n, int year, int month) {
  final text = DateFormat.yMMMM(l10n.localeName).format(DateTime(year, month));
  return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}
