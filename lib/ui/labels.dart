import 'package:intl/intl.dart';

import '../data/csv_export.dart';
import '../domain/calendar_day.dart';
import '../domain/day_entry.dart';
import '../domain/flow_intensity.dart';
import '../domain/intimacy.dart';
import '../domain/libido_level.dart';
import '../domain/migraine.dart';
import '../domain/mood.dart';
import '../domain/pain_level.dart';
import '../domain/period_prediction.dart';
import '../domain/sleep_quality.dart';
import '../domain/start_profile.dart';
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
      Symptom.hotFlashes => l10n.symptomHotFlashes,
      Symptom.nightSweats => l10n.symptomNightSweats,
      Symptom.vaginalDryness => l10n.symptomVaginalDryness,
      Symptom.jointPain => l10n.symptomJointPain,
      Symptom.brainFog => l10n.symptomBrainFog,
      Symptom.palpitations => l10n.symptomPalpitations,
      Symptom.migraine => l10n.symptomMigraine,
      Symptom.moodSwings => l10n.symptomMoodSwings,
      Symptom.painDuringSex => l10n.symptomPainDuringSex,
    };

String intimacyLabel(AppLocalizations l10n, Intimacy intimacy) =>
    switch (intimacy) {
      Intimacy.unspecified => l10n.intimacyUnspecified,
      Intimacy.protected => l10n.intimacyProtected,
      Intimacy.unprotected => l10n.intimacyUnprotected,
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
  migraine: l10n.symptomMigraine,
  migraineText: (detail) => migraineFacts(l10n, detail).join('; '),
  intimacy: l10n.dayIntimacyTitle,
  intimacyName: (intimacy) => intimacyLabel(l10n, intimacy),
);

String migraineDurationLabel(AppLocalizations l10n, MigraineDuration d) =>
    switch (d) {
      MigraineDuration.hours => l10n.migraineHours,
      MigraineDuration.day => l10n.migraineDay,
      MigraineDuration.longer => l10n.migraineLonger,
    };

/// What was noted of a migraine, in words.
List<String> migraineFacts(AppLocalizations l10n, MigraineDetail detail) => [
  if (detail.intensity case final intensity?) painLabel(l10n, intensity),
  if (detail.duration case final duration?)
    migraineDurationLabel(l10n, duration),
  if (detail.medication case final taken?)
    taken ? l10n.migraineMedicationYes : l10n.migraineMedicationNo,
];

DateTime _dateTime(CalendarDay day) => DateTime(day.year, day.month, day.day);

/// A recent change, as she says it of herself.
String recentChangeLabel(AppLocalizations l10n, RecentChange change) =>
    switch (change) {
      RecentChange.heavierFlow => l10n.changeHeavier,
      RecentChange.lighterFlow => l10n.changeLighter,
      RecentChange.lessRegular => l10n.changeLessRegular,
      RecentChange.moreRegular => l10n.changeMoreRegular,
      RecentChange.longerPeriods => l10n.changeLonger,
      RecentChange.shorterPeriods => l10n.changeShorter,
      RecentChange.morePainful => l10n.changeMorePainful,
      RecentChange.lessPainful => l10n.changeLessPainful,
      RecentChange.lengthChanged => l10n.changeLength,
      RecentChange.nothing => l10n.changeNothing,
    };

String trackedLabel(AppLocalizations l10n, Tracked tracked) =>
    switch (tracked) {
      Tracked.pain => l10n.trackedPain,
      Tracked.mood => l10n.trackedMood,
      Tracked.sleep => l10n.trackedSleep,
      Tracked.libido => l10n.trackedLibido,
      Tracked.symptoms => l10n.trackedSymptoms,
    };

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

/// The date at the top of the home tab: "Friday, March 20" /
/// "Vendredi 20 mars".
String todayTitle(AppLocalizations l10n, CalendarDay day) =>
    toBeginningOfSentenceCase(weekdayDate(l10n, day), l10n.localeName);

/// "March 2026" / "mars 2026".
String monthTitle(AppLocalizations l10n, int year, int month) {
  final text = DateFormat.yMMMM(l10n.localeName).format(DateTime(year, month));
  return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}

/// What was ticked on a day, in a few words each: the flow, the pain, the
/// mood, the sleep, the libido, then the symptoms in alphabetical order.
List<String> entryFacts(AppLocalizations l10n, DayEntry entry) {
  final flow = entry.flow;
  final pain = entry.pain;
  final mood = entry.mood;
  final sleep = entry.sleep;
  final libido = entry.libido;
  final intimacy = entry.intimacy;
  final symptoms = [
    for (final symptom in entry.symptoms) symptomLabel(l10n, symptom),
  ]..sort();
  return [
    if (flow != null)
      l10n.signWithKind(l10n.dayFlowTitle, flowLabel(l10n, flow)),
    if (pain != null)
      l10n.signWithKind(l10n.dayPainTitle, painLabel(l10n, pain)),
    if (mood != null)
      l10n.signWithKind(l10n.dayMoodTitle, moodLabel(l10n, mood)),
    if (sleep != null)
      l10n.signWithKind(l10n.daySleepTitle, sleepLabel(l10n, sleep)),
    if (libido != null)
      l10n.signWithKind(l10n.dayLibidoTitle, libidoLabel(l10n, libido)),
    if (intimacy != null)
      l10n.signWithKind(l10n.dayIntimacyTitle, intimacyLabel(l10n, intimacy)),
    ...symptoms,
  ];
}
