// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fycle';

  @override
  String get disclaimer =>
      'Fycle is an information tool. It does not give medical advice and is not a method of contraception.';

  @override
  String get privacyLine => 'No account. Nothing leaves this phone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get save => 'Save';

  @override
  String get errorGeneric => 'Something went wrong. Nothing was changed.';

  @override
  String get showPassword => 'Show the password';

  @override
  String get hidePassword => 'Hide the password';

  @override
  String get openingLabel => 'Opening';

  @override
  String get unreadableTitle => 'Your data cannot be read';

  @override
  String get unreadableBody =>
      'This phone holds Fycle data, but the key that protects it is missing. This happens when a phone is restored from a backup: the key never leaves the original phone. This data cannot be recovered.';

  @override
  String get unreadableStartFresh => 'Start fresh';

  @override
  String get unreadableRestore => 'Restore from a backup file';

  @override
  String get unreadableConfirmTitle => 'Erase the unreadable data?';

  @override
  String get unreadableConfirmBody =>
      'The unreadable data will be erased from this phone. This cannot be undone.';

  @override
  String get erase => 'Erase';

  @override
  String get onboardingTitle => 'Welcome to Fycle';

  @override
  String get onboardingLastPeriodQuestion => 'When did your last period start?';

  @override
  String get onboardingCycleLengthQuestion => 'How long is your cycle usually?';

  @override
  String get onboardingStart => 'Start';

  @override
  String get onboardingSkip => 'Not yet: I\'ll log it the day it starts';

  @override
  String get onboardingRestore => 'I have a backup file';

  @override
  String get cycleLengthFieldLabel => 'Days (optional)';

  @override
  String get cycleLengthHelper =>
      'From the first day of one period to the first day of the next. Leave empty if you don\'t know.';

  @override
  String cycleLengthError(int min, int max) {
    return 'Enter a number between $min and $max.';
  }

  @override
  String get homeLogToday => 'Log today';

  @override
  String get todayCardTitle => 'Period today';

  @override
  String get todayCardHint => 'One tap saves. Tap again to undo.';

  @override
  String loggingStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Logged $days days in a row',
      one: 'Logged 1 day in a row',
    );
    return '$_temp0';
  }

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get statusNoDataTitle => 'No estimate yet';

  @override
  String get statusNoDataBody =>
      'Log the first day of your period to get an estimate.';

  @override
  String statusOngoing(int day) {
    return 'Day $day of your period';
  }

  @override
  String statusNextRange(String start, String end) {
    return 'Next period expected between $start and $end';
  }

  @override
  String statusExpectedRange(String start, String end) {
    return 'Period expected between $start and $end';
  }

  @override
  String statusExpectedIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'This range starts in $days days.',
      one: 'This range starts tomorrow.',
    );
    return '$_temp0';
  }

  @override
  String get statusDue => 'Today is within this range.';

  @override
  String statusLate(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days past this range.',
      one: '1 day past this range.',
    );
    return '$_temp0';
  }

  @override
  String get statusLateNote =>
      'Cycles vary from one month to the next. This is only an estimate.';

  @override
  String get statusOutdatedTitle => 'No recent entry';

  @override
  String get statusOutdatedBody => 'Log your period to get a new estimate.';

  @override
  String estimateBasisCycles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Estimate based on your last $count cycles.',
      one: 'Estimate based on your last cycle.',
    );
    return '$_temp0';
  }

  @override
  String estimateBasisDeclared(int days) {
    return 'Estimate based on the usual length you gave ($days days). It will adjust as you log.';
  }

  @override
  String estimateBasisDefault(int days) {
    return 'Estimate based on a cycle of $days days. It will adjust as you log.';
  }

  @override
  String get confidenceLow => 'Confidence: low';

  @override
  String get confidenceMedium => 'Confidence: medium';

  @override
  String get confidenceHigh => 'Confidence: high';

  @override
  String get calendarPreviousMonth => 'Previous month';

  @override
  String get calendarNextMonth => 'Next month';

  @override
  String get legendPeriod => 'Period';

  @override
  String get legendExpected => 'Expected period (estimate)';

  @override
  String get legendEntry => 'Other entry';

  @override
  String get calendarDayToday => 'today';

  @override
  String get calendarDayPeriod => 'period logged';

  @override
  String get calendarDaySpotting => 'spotting logged';

  @override
  String get calendarDayExpected => 'period expected, estimate';

  @override
  String get calendarDayEntry => 'entry logged';

  @override
  String get dayFlowTitle => 'Period';

  @override
  String get dayPainTitle => 'Pain';

  @override
  String get dayMoodTitle => 'Mood';

  @override
  String get daySymptomsTitle => 'Symptoms';

  @override
  String get daySleepTitle => 'Sleep';

  @override
  String get dayLibidoTitle => 'Libido';

  @override
  String get sleepPoor => 'Poor';

  @override
  String get sleepFair => 'Fair';

  @override
  String get sleepGood => 'Good';

  @override
  String get libidoLow => 'Low';

  @override
  String get libidoMedium => 'Medium';

  @override
  String get libidoHigh => 'High';

  @override
  String get dayNoteLabel => 'Note';

  @override
  String get dayNoteHint => 'Anything you want to remember';

  @override
  String get daySavedHint => 'Saved automatically, on this phone only.';

  @override
  String get flowSpotting => 'Spotting';

  @override
  String get flowLight => 'Light';

  @override
  String get flowMedium => 'Medium';

  @override
  String get flowHeavy => 'Heavy';

  @override
  String get painNone => 'None';

  @override
  String get painMild => 'Mild';

  @override
  String get painModerate => 'Moderate';

  @override
  String get painSevere => 'Severe';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodCalm => 'Calm';

  @override
  String get moodSad => 'Sad';

  @override
  String get moodAnxious => 'Anxious';

  @override
  String get moodIrritable => 'Irritable';

  @override
  String get symptomCramps => 'Cramps';

  @override
  String get symptomHeadache => 'Headache';

  @override
  String get symptomBackPain => 'Back pain';

  @override
  String get symptomBreastTenderness => 'Breast tenderness';

  @override
  String get symptomBloating => 'Bloating';

  @override
  String get symptomNausea => 'Nausea';

  @override
  String get symptomFatigue => 'Fatigue';

  @override
  String get symptomAcne => 'Acne';

  @override
  String get symptomCravings => 'Cravings';

  @override
  String get symptomInsomnia => 'Insomnia';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsCycleSection => 'Cycle';

  @override
  String get settingsCycleLength => 'Usual cycle length';

  @override
  String settingsCycleLengthValue(int days) {
    return '$days days';
  }

  @override
  String get settingsCycleLengthUnknown => 'Not set';

  @override
  String get settingsDataSection => 'Your data';

  @override
  String get settingsExport => 'Save an encrypted backup';

  @override
  String get settingsExportSubtitle =>
      'A file protected by a password, to keep wherever you want.';

  @override
  String get settingsImport => 'Restore a backup';

  @override
  String get settingsImportSubtitle =>
      'Replaces everything in Fycle on this phone.';

  @override
  String get settingsCsv => 'Export as a spreadsheet (CSV)';

  @override
  String get settingsCsvSubtitle => 'A readable file, not encrypted.';

  @override
  String get settingsDelete => 'Delete everything';

  @override
  String get settingsDeleteSubtitle => 'Erases all your data from this phone.';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get exportTitle => 'Encrypted backup';

  @override
  String get exportWarning =>
      'If you forget this password, nobody can open the file, ever. There is no way to recover it. Write the password down somewhere safe.';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordConfirmLabel => 'Repeat the password';

  @override
  String passwordTooShort(int min) {
    return 'At least $min characters.';
  }

  @override
  String get passwordMismatch => 'The two passwords are different.';

  @override
  String get exportAction => 'Create the file';

  @override
  String get exportDone => 'Backup saved.';

  @override
  String get importReplaceTitle => 'Replace everything?';

  @override
  String get importReplaceBody =>
      'Restoring a backup replaces everything currently in Fycle on this phone.';

  @override
  String get importReplaceAction => 'Replace';

  @override
  String get importPasswordTitle => 'Password of the backup';

  @override
  String get importAction => 'Restore';

  @override
  String get importDone => 'Backup restored.';

  @override
  String get importErrorNotBackup =>
      'This file is not a Fycle backup. Nothing was changed.';

  @override
  String get importErrorVersion =>
      'This backup comes from a newer version of Fycle. Update the app and try again.';

  @override
  String get importErrorWrong =>
      'Wrong password, or damaged file. Nothing was changed.';

  @override
  String get csvWarningTitle => 'Unencrypted file';

  @override
  String get csvWarningBody =>
      'This file is not encrypted: anyone who gets it can read it. Keep it in a place you trust.';

  @override
  String get csvAction => 'Export';

  @override
  String get csvDone => 'File saved.';

  @override
  String get csvDateHeader => 'Date';

  @override
  String get deleteTitle => 'Delete everything?';

  @override
  String get deleteBody =>
      'All your data will be erased from this phone, permanently. To keep a copy, save a backup first.';

  @override
  String get deleteAction => 'Delete everything';

  @override
  String get ok => 'OK';

  @override
  String get settingsRemindersSection => 'Reminders';

  @override
  String get reminderPeriodTitle => 'Period approaching';

  @override
  String get reminderPeriodSubtitle =>
      'One notification a few days before the estimated range.';

  @override
  String get reminderDaysBeforeTitle => 'How long before';

  @override
  String reminderDaysBefore(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days before',
      one: '1 day before',
    );
    return '$_temp0';
  }

  @override
  String get reminderTime => 'Time';

  @override
  String get reminderDailyTitle => 'Daily entry reminder';

  @override
  String get reminderDailySubtitle =>
      'One notification a day, skipped when the day is already logged.';

  @override
  String get reminderDiscreetNote =>
      'Notifications stay discreet: they never mention your cycle. They are scheduled on this phone, without any server.';

  @override
  String get reminderPermissionTitle => 'Notifications are turned off';

  @override
  String get reminderPermissionBody =>
      'Fycle is not allowed to show notifications. You can allow them in the settings of your phone, then turn this reminder on.';

  @override
  String get notificationPeriodBody => 'A look at your calendar?';

  @override
  String get notificationDailyBody => 'A moment to note your day?';

  @override
  String get notificationChannelName => 'Reminders';

  @override
  String get settingsPrivacySection => 'Privacy';

  @override
  String get lockTitle => 'Lock Fycle';

  @override
  String get lockSubtitle =>
      'Face ID, fingerprint or the passcode of this phone, each time Fycle opens.';

  @override
  String get lockUnavailableTitle => 'No passcode on this phone';

  @override
  String get lockUnavailableBody =>
      'Fycle relies on the lock of your phone. Set a passcode in the settings of your phone first.';

  @override
  String get lockReason => 'Unlock Fycle';

  @override
  String get lockScreenTitle => 'Fycle is locked';

  @override
  String get lockScreenUnlock => 'Unlock';

  @override
  String get settingsAppearanceSection => 'Appearance';

  @override
  String get settingsAppearance => 'Theme';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get appearanceSystem => 'Same as the phone';

  @override
  String get insightsTitle => 'Review';

  @override
  String get insightsCyclesTitle => 'Your cycles';

  @override
  String insightsAverageCycle(String days) {
    return 'Average cycle: $days days';
  }

  @override
  String insightsAveragePeriod(String days) {
    return 'Average period: $days days';
  }

  @override
  String insightsAverageBasis(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Counted on your last $count complete cycles.',
      one: 'Counted on your last complete cycle.',
    );
    return '$_temp0';
  }

  @override
  String get insightsNoCycleYet =>
      'Averages appear once a second period is logged.';

  @override
  String get insightsTrendsTitle => 'What comes back';

  @override
  String get insightsTrendsEmpty =>
      'Nothing to show yet. A line appears here when the same thing is logged at the same moment in at least two complete cycles.';

  @override
  String get insightsTrendsNote =>
      'These lines count what you logged. They are observations, not a medical interpretation.';

  @override
  String trendDuringPeriod(int count, int total) {
    return 'During your period, in $count of your last $total cycles';
  }

  @override
  String trendBeforePeriod(int count, int total) {
    return 'In the week before your period, in $count of your last $total cycles';
  }

  @override
  String trendRest(int count, int total) {
    return 'In the rest of the cycle, in $count of your last $total cycles';
  }

  @override
  String signWithKind(String kind, String value) {
    return '$kind: $value';
  }

  @override
  String get insightsHistoryTitle => 'History';

  @override
  String get historyEmpty => 'No period logged yet.';

  @override
  String historyCycleRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String historyCycleDetail(int days, int period) {
    String _temp0 = intl.Intl.pluralLogic(
      period,
      locale: localeName,
      other: '$days days · period of $period days',
      one: '$days days · period of 1 day',
    );
    return '$_temp0';
  }

  @override
  String historyCurrent(String start) {
    return 'In progress since $start';
  }

  @override
  String get historyUnusual => 'Unusual length, left out of the averages.';

  @override
  String get summaryTitle => 'Your last cycle';

  @override
  String summaryLength(int days) {
    return 'It lasted $days days.';
  }

  @override
  String summaryLonger(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days longer than your cycles before.',
      one: '1 day longer than your cycles before.',
    );
    return '$_temp0';
  }

  @override
  String summaryShorter(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days shorter than your cycles before.',
      one: '1 day shorter than your cycles before.',
    );
    return '$_temp0';
  }

  @override
  String get summarySame => 'The same as your cycles before.';

  @override
  String summaryMostLogged(String symptoms) {
    return 'Logged most: $symptoms.';
  }

  @override
  String get listSeparator => ', ';

  @override
  String get summarySeeTrends => 'See trends';

  @override
  String get summaryClose => 'Close';

  @override
  String get fertilitySettingTitle => 'Ovulation estimate';

  @override
  String get fertilitySettingSubtitle =>
      'Shows an estimated fertile window on the home screen and in the calendar.';

  @override
  String get fertilityWarningTitle => 'An estimate, nothing more';

  @override
  String get fertilityWarning =>
      'This estimate is calculated from the dates of your periods only. It is not a method of contraception and not a diagnosis. It cannot tell which days are without risk: ovulation may fall outside the days shown.';

  @override
  String get fertilityTurnOn => 'Turn on';

  @override
  String get fertilityCardTitle => 'Estimated fertile window';

  @override
  String fertilityWindowRange(String start, String end) {
    return 'Between $start and $end';
  }

  @override
  String fertilityOvulationRange(String start, String end) {
    return 'Ovulation estimated between $start and $end';
  }

  @override
  String get fertilityLowConfidence =>
      'Your cycles vary a lot: this estimate is not reliable.';

  @override
  String get fertilityNotEnough =>
      'The estimate appears once two complete cycles are logged.';

  @override
  String get fertilityHow => 'How it is calculated';

  @override
  String get fertilityHowBody =>
      'Fycle starts from the estimate of your next period and counts back about 13 days, with 3 days of margin on each side, to place ovulation. The window covers the 5 days before and the day after. Cycles differ from one person to another and from one month to the next: these are averages, not measurements of your body.';

  @override
  String get legendFertile => 'Fertile window (estimate)';

  @override
  String get calendarDayFertile => 'fertile window, estimate';

  @override
  String get tabHome => 'Home';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get tabReview => 'Review';

  @override
  String get homeTooltip => 'Back to home';

  @override
  String get cycleDayCaption => 'Day';

  @override
  String cycleDaySemantics(int day) {
    return 'Day $day of your cycle';
  }

  @override
  String countdownRange(int min, int max) {
    return 'Period in $min to $max days';
  }

  @override
  String countdownDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Period in $days days',
      one: 'Period expected from tomorrow',
      zero: 'Period expected from today',
    );
    return '$_temp0';
  }

  @override
  String get countdownDue => 'Period expected around now';

  @override
  String get figuresTitle => 'Your figures';

  @override
  String get figureCycle => 'Cycle';

  @override
  String get figurePeriod => 'Period';

  @override
  String get figureLogged => 'Days logged';

  @override
  String figureDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get figureUnknown => '–';

  @override
  String get sourceLogged => 'from your entries';

  @override
  String get sourceDeclared => 'as you indicated';

  @override
  String get sourceAssumed => 'estimate for now';

  @override
  String get sourceCurrent => 'so far';

  @override
  String sourceCycles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count complete cycles',
      one: '1 complete cycle',
      zero: 'no complete cycle yet',
    );
    return '$_temp0';
  }

  @override
  String get usualTitle => 'Usually around this day';

  @override
  String usualLine(String sign, int count, int total) {
    return '$sign: in $count of your last $total cycles';
  }

  @override
  String get unlockTitle => 'The more you log, the more you see';

  @override
  String get unlockIntro =>
      'Fycle calculates everything from what you log. Each entry makes your figures more accurate.';

  @override
  String get unlockEstimate => 'Estimate of your next period';

  @override
  String get unlockEstimateNeed => 'From your first logged period';

  @override
  String get unlockAverages => 'Average lengths of your cycle and period';

  @override
  String get unlockAveragesNeed => 'After one complete cycle';

  @override
  String get unlockTrends => 'What comes back, and the ovulation estimate';

  @override
  String get unlockTrendsNeed => 'After two complete cycles';

  @override
  String get unlockReliable => 'A narrower, more reliable estimate';

  @override
  String get unlockReliableNeed => 'With four regular cycles or more';

  @override
  String unlockProgress(int have, int need) {
    return '$have of $need';
  }

  @override
  String get unlockReached => 'Available';

  @override
  String unlockOverall(int reached, int total) {
    return '$reached of $total available';
  }

  @override
  String get todayEntryTitle => 'My journal today';

  @override
  String todayEntryProgress(int done, int total) {
    return '$done of $total sections filled in today';
  }

  @override
  String get calendarHint => 'Tap a day to log it or correct it.';

  @override
  String get reportTitle => 'This cycle';

  @override
  String reportStarted(String date) {
    return 'Started on $date';
  }

  @override
  String reportPeriod(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Period: $days days',
      one: 'Period: 1 day',
    );
    return '$_temp0';
  }

  @override
  String reportLogged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days logged in this cycle',
      one: '1 day logged in this cycle',
      zero: 'Nothing logged yet in this cycle',
    );
    return '$_temp0';
  }

  @override
  String reportPainDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pain on $count days',
      one: 'Pain on 1 day',
    );
    return '$_temp0';
  }

  @override
  String reportPoorSleep(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Poor sleep on $count nights',
      one: 'Poor sleep on 1 night',
    );
    return '$_temp0';
  }

  @override
  String get reportEmpty =>
      'Log the first day of your period to start your review.';

  @override
  String get onboardingIntro1 =>
      'Log your period and how you feel, in a few taps.';

  @override
  String get onboardingIntro2 =>
      'See your figures: day of the cycle, estimate of the next period, what comes back.';

  @override
  String get onboardingIntro3 => 'The more you log, the more accurate it gets.';

  @override
  String get onboardingEarlierTitle => 'Earlier periods (optional)';

  @override
  String get onboardingEarlierHint =>
      'Add the first day of one or two earlier periods: your averages and trends come sooner.';

  @override
  String get onboardingAddEarlier => 'Add an earlier period';

  @override
  String onboardingRemoveDate(String date) {
    return 'Remove $date';
  }

  @override
  String get tabJournal => 'Journal';

  @override
  String get tabHomeHint => 'Your figures today, and a quick entry.';

  @override
  String get tabJournalHint => 'Your calendar and your pages, day after day.';

  @override
  String get tabReviewHint =>
      'Your averages, what comes back, and your history.';

  @override
  String get tabSettingsHint => 'Reminders, privacy, backup and your data.';

  @override
  String get journalPagesTitle => 'Your latest pages';

  @override
  String get journalEmpty =>
      'Nothing written yet. Your first page starts with today.';

  @override
  String get journalWriteToday => 'Write today\'s page';

  @override
  String get todayNoteTitle => 'Your note';

  @override
  String get fertilityShortWarning =>
      'An estimate: neither contraception nor a diagnosis.';

  @override
  String get homeGreeting => 'Welcome back';

  @override
  String get homeReassurance =>
      'Your journal is private. It stays on this phone, and nobody else can read it.';

  @override
  String figureReference(int days) {
    return 'reference: $days days';
  }

  @override
  String referenceLine(int cycle, int period) {
    return 'Shown for now: a reference cycle of $cycle days, with a period of $period days. Your own dates will replace it.';
  }

  @override
  String get referenceCaption => 'Reference';

  @override
  String get studyCardTitle => 'What the studies say';

  @override
  String get factExactly28 => 'Only about 13% of cycles last exactly 28 days.';

  @override
  String get factVariesMoreThan7 =>
      'For about 4 women in 10, the length of the cycle varies by more than 7 days from one cycle to another.';

  @override
  String get factRange22to36 =>
      '95% of the cycles measured lasted between 22 and 36 days.';

  @override
  String get factShortensWithAge =>
      'Between 25 and 45, the cycle shortens by about 0.18 day a year.';

  @override
  String get factFirstPartVaries =>
      'The first part of the cycle, before ovulation, is the one that varies most. The second hardly moves.';

  @override
  String get factSixDayWindow =>
      'Conception was observed only in the six days ending on the day of ovulation.';

  @override
  String get factFigoRanges =>
      'A cycle of 24 to 38 days and a period of up to 8 days are within the usual range used by gynaecologists.';

  @override
  String youMeanCycle(String days) {
    return 'Your average cycle: $days days.';
  }

  @override
  String youVariation(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Yours: $days days between your shortest and your longest cycle.',
      one: 'Yours: 1 day between your shortest and your longest cycle.',
      zero: 'Yours: your cycles all had the same length.',
    );
    return '$_temp0';
  }

  @override
  String youAgeReference(int age, int days) {
    return 'At $age, the reference cycle is $days days.';
  }

  @override
  String get youAgeUnknown =>
      'Give your year of birth in the settings to start from a reference closer to your age.';

  @override
  String youFollicular(int min, int max) {
    return 'Yours is estimated at $min to $max days.';
  }

  @override
  String youWindow(String start, String end) {
    return 'Your estimated window: $start to $end.';
  }

  @override
  String youFigo(String cycle, String period) {
    return 'Your cycle: $cycle days. Your period: $period days.';
  }

  @override
  String get youNotYet => 'Log two periods to see where you stand.';

  @override
  String get sourcesTitle => 'Sources';

  @override
  String get sourcesIntro =>
      'The reference figures come from these published studies. They describe groups of women, not you: your own entries always take over.';

  @override
  String get sourceBull2019 =>
      'Bull et al., npj Digital Medicine, 2019. 612,613 cycles.';

  @override
  String get sourceFehring2006 =>
      'Fehring, Schneider and Raviele, 2006. 1,060 cycles.';

  @override
  String get sourceWilcox1995 =>
      'Wilcox, Weinberg and Baird, New England Journal of Medicine, 1995.';

  @override
  String get sourceFigo2018 =>
      'Munro, Critchley and Fraser for FIGO, International Journal of Gynecology & Obstetrics, 2018.';

  @override
  String get clinicalTitle => 'Clinical sheet';

  @override
  String get clinicalIntro =>
      'Your log, read with the four parameters gynaecologists use.';

  @override
  String clinicalBasis(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Based on $count complete cycles over the last 12 months.',
      one: 'Based on 1 complete cycle over the last 12 months.',
    );
    return '$_temp0';
  }

  @override
  String get clinicalEmpty =>
      'Your own figures come in once a first cycle has ended.';

  @override
  String get clinicalFrequency => 'Frequency';

  @override
  String clinicalFrequencyValue(String days) {
    return 'A cycle of $days days on average';
  }

  @override
  String get clinicalFrequencyRef => 'Usual range: 24 to 38 days';

  @override
  String get clinicalRegularity => 'Regularity';

  @override
  String clinicalRegularityValue(int min, int max, int variation) {
    String _temp0 = intl.Intl.pluralLogic(
      variation,
      locale: localeName,
      other: 'Cycles of $min to $max days, $variation days apart',
      one: 'Cycles of $min to $max days, 1 day apart',
      zero: 'Cycles of $min days, all the same length',
    );
    return '$_temp0';
  }

  @override
  String clinicalRegularityRef(int limit) {
    return 'Usual: up to $limit days apart';
  }

  @override
  String get clinicalRegularityTooFew =>
      'Three complete cycles are needed to tell.';

  @override
  String get clinicalDuration => 'Period length';

  @override
  String clinicalDurationValue(String days, int max) {
    return '$days days on average, $max at most';
  }

  @override
  String get clinicalDurationRef => 'Usual: up to 8 days';

  @override
  String get clinicalVolume => 'Flow';

  @override
  String get clinicalVolumeLight => 'Light, as you logged it';

  @override
  String get clinicalVolumeModerate => 'Moderate, as you logged it';

  @override
  String get clinicalVolumeHeavy => 'Heavy, as you logged it';

  @override
  String get clinicalPhases => 'Two parts of the cycle (estimate)';

  @override
  String clinicalPhasesValue(int min, int max, int luteal) {
    return 'Before ovulation: $min to $max days. After: about $luteal days.';
  }

  @override
  String get clinicalSpotting => 'Spotting between periods';

  @override
  String clinicalSpottingValue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days logged',
      one: '1 day logged',
      zero: 'None logged',
    );
    return '$_temp0';
  }

  @override
  String get statusWithin => 'Within the usual range';

  @override
  String get statusOutside => 'Outside the usual range';

  @override
  String get clinicalOutsideNote =>
      'A value outside the usual range is not a diagnosis. This sheet is worth showing to a doctor.';

  @override
  String get clinicalSource => 'Reference ranges: FIGO, 2018.';

  @override
  String get birthYearLabel => 'Year of birth (optional)';

  @override
  String get birthYearHelper =>
      'Used to start from a reference cycle closer to your age. It stays on this phone.';

  @override
  String birthYearError(int min, int max) {
    return 'Enter a year between $min and $max.';
  }

  @override
  String get settingsBirthYear => 'Year of birth';

  @override
  String get sourceAssumedAge => 'reference for your age, to adjust';

  @override
  String get settingsBirthYearUnknown => 'Not given';

  @override
  String get doctorReportTitle => 'Report for your doctor';

  @override
  String doctorReportIntro(String date) {
    return 'Drawn up on $date from what you logged. It describes and compares; it is not a diagnosis.';
  }

  @override
  String doctorReportAge(int age) {
    return 'Age: $age';
  }

  @override
  String get clinicalToFill => 'Your figure will replace this line';

  @override
  String get clinicalRegularityRefAny =>
      'Usual: up to 7 to 9 days apart, depending on age';

  @override
  String get periodStartsToday => 'My period starts today';

  @override
  String get comparisonTitle => 'This cycle and the one before';

  @override
  String comparisonIntro(int day) {
    String _temp0 = intl.Intl.pluralLogic(
      day,
      locale: localeName,
      other: 'Both taken over their first $day days.',
      one: 'Both taken on their first day.',
    );
    return '$_temp0';
  }

  @override
  String get comparisonPrevious => 'Before';

  @override
  String get comparisonPeriod => 'Period days';

  @override
  String get comparisonPain => 'Days with pain';

  @override
  String get comparisonSleep => 'Poor nights';

  @override
  String get comparisonLogged => 'Days logged';

  @override
  String comparisonRow(String label, int current, int previous) {
    return '$label: $current in this cycle, $previous in the one before';
  }

  @override
  String get monthsTitle => 'Your history, month by month';

  @override
  String get monthsIntro =>
      'Everything rests on it: the fuller your months, the more accurate your estimates.';

  @override
  String monthLogged(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days logged',
      one: '1 day logged',
      zero: 'Nothing logged',
    );
    return '$_temp0';
  }

  @override
  String monthPeriod(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days period days',
      one: '1 period day',
    );
    return '$_temp0';
  }

  @override
  String get ringCountdownCaption => 'Days left';

  @override
  String get ringShowCountdown => 'Show the days left';

  @override
  String get ringShowDay => 'Show the day of the cycle';

  @override
  String get widgetTitle => 'Home-screen widget';

  @override
  String get widgetSubtitle =>
      'The cycle ring on the home screen of this phone, with no word about periods. Add it from the home screen: touch and hold an empty area, then the + button.';

  @override
  String get lockTurnedOff =>
      'This phone no longer has a passcode: the lock of Fycle was turned off.';

  @override
  String get ringShowUsual => 'Show what usually comes around this day';

  @override
  String get ringHint => 'Slide along the ring to go through your cycle.';

  @override
  String ringExploreValue(int day, String date) {
    return 'Day $day of your cycle, $date';
  }

  @override
  String exploreToday(String date) {
    return '$date · today';
  }

  @override
  String exploreLogged(String facts) {
    return 'Logged: $facts';
  }

  @override
  String get exploreNothingLogged => 'Nothing logged on that day.';

  @override
  String get exploreExpected =>
      'Within the range where your next period is estimated.';

  @override
  String get exploreFertile =>
      'Within your estimated fertile window. An estimate: neither contraception nor a diagnosis.';

  @override
  String exploreUsual(String signs) {
    return 'Usually around this day: $signs';
  }

  @override
  String get exploreNothing =>
      'Nothing stands out around this day in your past cycles yet.';

  @override
  String get exploreOpen => 'Open this page';

  @override
  String get exploreBack => 'Back to today';

  @override
  String periodEndRange(int from, int to) {
    return 'About $from to $to more days, going by your past periods';
  }

  @override
  String periodEndDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'About $count more days, going by your past periods',
      one: 'About 1 more day, going by your past periods',
    );
    return '$_temp0';
  }

  @override
  String get periodEndToday =>
      'Likely the last day, going by your past periods';

  @override
  String get reviewSeeDetail => 'See the detail';

  @override
  String get reviewDetailTitle => 'The detail';

  @override
  String get remindersAskTitle => 'Reminders';

  @override
  String get remindersAskBody =>
      'Fycle can tell you a few days before your period, and remind you of your journal each day. Nothing leaves this phone. Turn both reminders on?';

  @override
  String get remindersAskBlockedBody =>
      'Notifications are turned off for Fycle in the settings of this phone. Without them, Fycle cannot tell you before your period or remind you of your journal. You can allow them in the settings of the phone.';

  @override
  String get remindersAskLater => 'Later';

  @override
  String get setupWelcomeBody =>
      'A few questions to start from you, not from an average. Each one can be skipped.';

  @override
  String get setupBegin => 'Let\'s go';

  @override
  String get setupSkipAll => 'Skip the setup';

  @override
  String get setupSkip => 'Skip';

  @override
  String get setupNext => 'Continue';

  @override
  String get setupBack => 'Back';

  @override
  String setupProgress(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get setupNameTitle => 'What is your first name?';

  @override
  String get setupNameHint => 'It stays on this phone. You can leave it empty.';

  @override
  String get setupNameLabel => 'First name';

  @override
  String get setupBirthTitle => 'What year were you born?';

  @override
  String get setupBirthHint =>
      'The length of a cycle changes with age: the first estimate starts from there.';

  @override
  String get setupGoalsTitle => 'What brings you here?';

  @override
  String get setupGoalsHint => 'Several answers are possible.';

  @override
  String get goalTrackPeriods => 'Track my periods';

  @override
  String get goalUnderstandBody => 'Understand my body better';

  @override
  String get goalConceive => 'Conceive a child';

  @override
  String get goalPerimenopause => 'Follow a perimenopause';

  @override
  String get setupRegularTitle => 'Are your periods regular?';

  @override
  String get setupRegularHint =>
      'That is, the number of days between two periods stays about the same.';

  @override
  String get regularYes => 'Yes';

  @override
  String get regularNo => 'No';

  @override
  String get regularUnknown => 'I don\'t know';

  @override
  String get regularNoPeriods => 'I don\'t have periods';

  @override
  String get setupLengthsTitle => 'Your usual lengths';

  @override
  String get setupLengthsHint =>
      'If you know them. Otherwise leave them: your own dates will tell.';

  @override
  String get setupCycleLength => 'Your cycle';

  @override
  String get setupCycleLengthHelper =>
      'From the first day of one period to the first day of the next.';

  @override
  String get setupPeriodLength => 'Your period';

  @override
  String get setupPeriodLengthHelper => 'The number of days your period lasts.';

  @override
  String setupDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get setupFewer => 'One day fewer';

  @override
  String get setupMore => 'One day more';

  @override
  String get setupChangesTitle =>
      'Have you noticed changes in your periods lately?';

  @override
  String get setupChangesHint =>
      'Several answers are possible. If a change worries you, talk to a health professional about it.';

  @override
  String get changeHeavier => 'My flow is heavier';

  @override
  String get changeLighter => 'My flow is lighter';

  @override
  String get changeLessRegular => 'My periods are less regular';

  @override
  String get changeLength => 'The length of my periods has changed';

  @override
  String get changeNothing => 'Nothing has changed';

  @override
  String get setupLastHint =>
      'Touch the day. An approximate date is enough: you can correct it later.';

  @override
  String get setupRemindersTitle => 'Your reminders';

  @override
  String get setupLockTitle => 'For your eyes only';

  @override
  String get setupLockHint =>
      'Nobody opens the app without you. You can change this at any time in the settings.';

  @override
  String get setupReadyTitle => 'All set';

  @override
  String setupReadyTitleName(String name) {
    return 'All set, $name';
  }

  @override
  String get setupReadyBody =>
      'Log your period the day it starts: the estimate gets closer with each cycle.';

  @override
  String get settingsAnswers => 'My answers';

  @override
  String get settingsAnswersSubtitle =>
      'First name, goals, regularity, usual lengths.';

  @override
  String periodEndDeclaredDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'About $count more days, going by what you said',
      one: 'About 1 more day, going by what you said',
    );
    return '$_temp0';
  }

  @override
  String get periodEndDeclaredToday =>
      'Probably the last day, going by what you said';

  @override
  String get symptomHotFlashes => 'Hot flashes';

  @override
  String get symptomNightSweats => 'Night sweats';

  @override
  String get changeTitle => 'What is changing';

  @override
  String get changeIntro =>
      'What your dates show from one cycle to the next. An observation, not a diagnosis.';

  @override
  String get changeTooFew =>
      'Two complete cycles are needed to compare one with the next.';

  @override
  String changeNoDifference(int cycles) {
    String _temp0 = intl.Intl.pluralLogic(
      cycles,
      locale: localeName,
      other:
          'Over your last $cycles cycles, none differs from the one before by 7 days or more.',
      one: 'Your last cycle is within 7 days of the one before.',
    );
    return '$_temp0';
  }

  @override
  String changeDifferences(int count, int cycles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count times over your last $cycles cycles, the length changed by 7 days or more from one cycle to the next.',
      one:
          'Once over your last $cycles cycles, the length changed by 7 days or more from one cycle to the next.',
    );
    return '$_temp0';
  }

  @override
  String changeLongInterval(int days) {
    return 'One cycle lasted $days days: 60 days or more between two periods.';
  }

  @override
  String changeSinceLast(int days) {
    return '$days days since your last period started: 60 days or more without a period.';
  }

  @override
  String get changeNoSigns =>
      'None of the signs to follow was logged in the last 90 days. You can tick them in your journal.';

  @override
  String changeSaid(String changes) {
    return 'When you set the app up, you said: $changes.';
  }

  @override
  String get changeSaidHeavier => 'heavier flow';

  @override
  String get changeSaidLighter => 'lighter flow';

  @override
  String get changeSaidLessRegular => 'less regular periods';

  @override
  String get changeSaidLength => 'periods of a different length';

  @override
  String get changeToReport =>
      'Worth telling a doctor or a midwife about: many things can move a cycle, and only a health professional can say what this means.';

  @override
  String get changeFooter =>
      'Many things can move a cycle. Only a health professional can say what a change means.';

  @override
  String get setupPrivacyTitle => 'Your data stays here';

  @override
  String get setupPrivacyHint =>
      'What sets this app apart, before any question.';

  @override
  String get privacyNoAccount =>
      'No account, no e-mail address, no password to create.';

  @override
  String get privacyOnPhone =>
      'What you log is stored on this phone, encrypted. The app sends nothing over the network.';

  @override
  String get privacyBackup =>
      'A backup is an encrypted file that you keep where you choose.';

  @override
  String get privacyNoAds => 'No advertising, no tracking, no subscription.';

  @override
  String setupGreeting(String name) {
    return 'Welcome, $name.';
  }

  @override
  String get setupWishesTitle => 'Tell me more about what you want';

  @override
  String get setupWishesHint =>
      'Several answers are possible. Each one decides what the app puts forward.';

  @override
  String get wishKnowWhen => 'Know when my period is coming';

  @override
  String get wishKnowUsualRanges =>
      'See how my cycle compares with the usual ranges';

  @override
  String get wishFertileWindow => 'Know my estimated fertile window';

  @override
  String get wishAfterContraception =>
      'Understand my cycle after stopping contraception';

  @override
  String get wishWhatComesBack => 'See what comes back with each cycle';

  @override
  String get setupUsualTitle => 'Your periods, usually';

  @override
  String get setupUsualHint =>
      'It sets what the app starts from. You log the real days afterwards.';

  @override
  String get setupUsualFlow => 'Flow';

  @override
  String get setupUsualPain => 'Pain';

  @override
  String get setupContraceptionTitle => 'Do you use contraception?';

  @override
  String get setupContraceptionHint =>
      'With a hormonal contraception, bleeding does not follow a natural cycle: the app then hides the ovulation estimate. It gives no advice on contraception.';

  @override
  String get contraceptionNone => 'No';

  @override
  String get contraceptionHormonal =>
      'Yes, hormonal (pill, implant, hormonal IUD, ring, patch)';

  @override
  String get contraceptionNonHormonal =>
      'Yes, without hormones (copper IUD, condoms, other)';

  @override
  String get setupSignsTitle => 'Do you have any of these signs these days?';

  @override
  String get setupSignsHint =>
      'Several answers are possible. You will be able to tick them day by day in your journal.';

  @override
  String get symptomVaginalDryness => 'Vaginal dryness';

  @override
  String get symptomJointPain => 'Joint pain';

  @override
  String get symptomBrainFog => 'Trouble concentrating';

  @override
  String get symptomPalpitations => 'Palpitations';

  @override
  String get setupEarlierTitle => 'And the periods before?';

  @override
  String get setupEarlierHint =>
      'Touch the first day of up to three earlier periods, if you remember them. The estimate then starts from your own cycle.';

  @override
  String get setupTrackedTitle => 'What do you want to follow day by day?';

  @override
  String get setupTrackedHint =>
      'Your journal starts with what you choose. The rest stays within reach.';

  @override
  String get trackedPain => 'Pain';

  @override
  String get trackedMood => 'Mood';

  @override
  String get trackedSleep => 'Sleep';

  @override
  String get trackedLibido => 'Libido';

  @override
  String get trackedSymptoms => 'Symptoms';

  @override
  String get recapTitle => 'What I set up for you';

  @override
  String recapCycleOwn(int days) {
    return 'Your estimate starts from your own dates: a cycle of $days days.';
  }

  @override
  String recapCycleDeclared(int days) {
    return 'Your estimate starts from what you said: a cycle of $days days.';
  }

  @override
  String recapCycleAge(int days) {
    return 'Your estimate starts from the published average for your age: $days days.';
  }

  @override
  String recapCycleDefault(int days) {
    return 'Your estimate starts from a common cycle of $days days.';
  }

  @override
  String recapRange(int days) {
    return 'A range of $days days on each side, which narrows as your dates come in.';
  }

  @override
  String get recapNoDate =>
      'No estimate yet: it starts the day you log a period.';

  @override
  String get recapFertilityOn =>
      'The estimated fertile window is shown. An estimate: neither contraception nor a diagnosis.';

  @override
  String get recapFertilityHormonal =>
      'The ovulation estimate is hidden: it means nothing with a hormonal contraception.';

  @override
  String get recapFertilityOff =>
      'The estimated fertile window is hidden. You can turn it on in the settings.';

  @override
  String recapJournal(String items) {
    return 'Your journal starts with: $items.';
  }

  @override
  String get recapChanges =>
      'The review follows what changes from one cycle to the next.';

  @override
  String get recapRemindersOn => 'Reminders are on.';

  @override
  String get recapRemindersOff =>
      'Reminders are off. You can turn them on in the settings.';

  @override
  String get recapLockOn => 'The app is locked when it opens.';

  @override
  String changeSignsList(String signs) {
    return 'In the last 90 days: $signs.';
  }

  @override
  String changeSignDays(String sign, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$sign ($_temp0)';
  }

  @override
  String changeStartSigns(String signs) {
    return 'Signs you named when you set the app up: $signs.';
  }
}
