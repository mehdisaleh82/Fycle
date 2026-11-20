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
      'Fycle informs. Not medical advice, not contraception.';

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
  String get onboardingRestore => 'Restore my backup';

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
  String get settingsExport => 'Save a protected backup';

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
  String get settingsCsvSubtitle => 'A readable file, without a password.';

  @override
  String get settingsDelete => 'Delete everything';

  @override
  String get settingsDeleteSubtitle => 'Erases all your data from this phone.';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get exportTitle => 'Protected backup';

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
  String get csvWarningTitle => 'Unprotected file';

  @override
  String get csvWarningBody =>
      'This file is not protected: anyone who gets it can read it. Keep it in a place you trust.';

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
      'Face ID, fingerprint or passcode, each time it opens.';

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
  String get setupNameHint => 'Optional.';

  @override
  String get setupNameLabel => 'First name';

  @override
  String get setupBirthTitle => 'What year were you born?';

  @override
  String get setupBirthHint => 'For your first estimate.';

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
  String get setupRegularHint => 'About the same gap between two periods.';

  @override
  String get regularYes => 'Yes';

  @override
  String get regularNo => 'No';

  @override
  String get regularUnknown => 'I don\'t know';

  @override
  String get regularNoPeriods => 'I don\'t have periods';

  @override
  String get setupLengthsTitle => 'Your cycle and your period, in days';

  @override
  String get setupLengthsHint => 'Roughly is fine. Or skip.';

  @override
  String get setupCycleLength => 'Length of your cycle';

  @override
  String get setupCycleLengthHelper => 'From day 1 of a period to the next.';

  @override
  String get setupPeriodLength => 'Length of your period';

  @override
  String get setupPeriodLengthHelper => 'Days of bleeding.';

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
  String get setupChangesTitle => 'Have your periods changed lately?';

  @override
  String get setupChangesHint => 'Worried by a change? Talk to a doctor.';

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
  String get setupLastHint => 'Touch the day, even roughly.';

  @override
  String get setupRemindersTitle => 'Do you want reminders?';

  @override
  String get setupLockTitle => 'For your eyes only';

  @override
  String get setupLockHint => 'Nobody opens the app without you.';

  @override
  String get setupReadyTitle => 'All set';

  @override
  String setupReadyTitleName(String name) {
    return 'All set, $name';
  }

  @override
  String get setupReadyBody => 'Log your period from the first day.';

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
  String get setupPrivacyTitle => 'Your data stays on your phone';

  @override
  String get privacyNoAccount => 'No account to create.';

  @override
  String get privacyOnPhone => 'Everything stays on your phone, protected.';

  @override
  String get privacyBackup => 'Nothing is sent over the Internet.';

  @override
  String get privacyNoAds => 'No advertising, no subscription.';

  @override
  String setupGreeting(String name) {
    return 'Welcome, $name.';
  }

  @override
  String get setupWishesTitle => 'What do you want from Fycle?';

  @override
  String get setupWishesHint => 'Pick as many as you like.';

  @override
  String get wishKnowWhen => 'Predict my period';

  @override
  String get wishKnowUsualRanges => 'Compare with the usual ranges';

  @override
  String get wishFertileWindow => 'See my estimated fertile window';

  @override
  String get wishAfterContraception =>
      'Understand my cycle after contraception';

  @override
  String get wishWhatComesBack => 'See what comes back';

  @override
  String get setupUsualTitle => 'What are your periods usually like?';

  @override
  String get setupUsualFlow => 'Flow';

  @override
  String get setupUsualPain => 'Pain';

  @override
  String get setupContraceptionTitle => 'Do you use contraception?';

  @override
  String get setupContraceptionHint =>
      'Fycle gives no advice on contraception.';

  @override
  String get contraceptionNone => 'No';

  @override
  String get contraceptionHormonal => 'Yes, hormonal';

  @override
  String get contraceptionNonHormonal => 'Yes, without hormones';

  @override
  String get setupSignsTitle => 'Do you get these signs during your cycle?';

  @override
  String get setupSignsHint => 'Tick the ones you have.';

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
  String get setupEarlierHint => 'Touch their first day, three at most.';

  @override
  String get setupTrackedTitle => 'What do you want to log each day?';

  @override
  String get setupTrackedHint => 'Tick what matters to you.';

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
  String get recapTitle => 'Your settings';

  @override
  String recapCycleOwn(int days) {
    return 'A $days-day cycle, from your dates.';
  }

  @override
  String recapCycleDeclared(int days) {
    return 'A $days-day cycle, as you said.';
  }

  @override
  String recapCycleAge(int days) {
    return 'A $days-day cycle, the average at your age.';
  }

  @override
  String recapCycleDefault(int days) {
    return 'A $days-day cycle to start with.';
  }

  @override
  String recapRange(int days) {
    return 'A range of $days days, which narrows.';
  }

  @override
  String get recapNoDate => 'An estimate once you log a period.';

  @override
  String get recapFertilityOn =>
      'Estimated fertile window shown. Neither contraception nor a diagnosis.';

  @override
  String get recapFertilityHormonal =>
      'Ovulation estimate hidden (hormonal contraception).';

  @override
  String get recapFertilityOff => 'Fertile window hidden.';

  @override
  String recapJournal(String items) {
    return 'Your journal: $items.';
  }

  @override
  String get recapChanges => 'A review of changes from cycle to cycle.';

  @override
  String get recapRemindersOn => 'Reminders on.';

  @override
  String get recapRemindersOff => 'Reminders off.';

  @override
  String get recapLockOn => 'App locked when it opens.';

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

  @override
  String get followTitle => 'Your tracking';

  @override
  String followRow(String name, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
      zero: 'no day',
    );
    return '$name: $_temp0 out of the last 7';
  }

  @override
  String followWeek(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days logged out of the last 7',
      one: '1 day logged out of the last 7',
      zero: 'No day logged out of the last 7',
    );
    return '$_temp0';
  }

  @override
  String followMonth(int days, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'This month: $days days logged out of $total',
      one: 'This month: 1 day logged out of $total',
      zero: 'This month: no day logged out of $total',
    );
    return '$_temp0';
  }

  @override
  String get figureGoodNights => 'Good nights';

  @override
  String get figurePainDays => 'Days with pain';

  @override
  String get reliabilityTitle => 'Reliability of the estimate';

  @override
  String get reliabilityLow => 'Low';

  @override
  String get reliabilityMedium => 'Medium';

  @override
  String get reliabilityHigh => 'High';

  @override
  String get reliabilityNone =>
      'Log the first day of a period to get an estimate.';

  @override
  String reliabilityToMedium(int cycles) {
    String _temp0 = intl.Intl.pluralLogic(
      cycles,
      locale: localeName,
      other: '$cycles more logged cycles before it can reach medium.',
      one: '1 more logged cycle before it can reach medium.',
    );
    return '$_temp0';
  }

  @override
  String reliabilityToHigh(int cycles) {
    String _temp0 = intl.Intl.pluralLogic(
      cycles,
      locale: localeName,
      other: '$cycles more logged cycles before it can reach high.',
      one: '1 more logged cycle before it can reach high.',
    );
    return '$_temp0';
  }

  @override
  String get reliabilityHeldByVariation =>
      'Your cycles differ from one another: it will rise if they come closer. Nothing to do with how you log.';

  @override
  String get reliabilityAtTop =>
      'The highest level: it holds as long as your cycles stay alike.';

  @override
  String get setupNotGiven => 'Not given';

  @override
  String get changeMoreRegular => 'My periods are more regular';

  @override
  String get changeLonger => 'My periods last longer';

  @override
  String get changeShorter => 'My periods are shorter';

  @override
  String get changeMorePainful => 'My periods are more painful';

  @override
  String get changeLessPainful => 'My periods are less painful';

  @override
  String get changeSaidMoreRegular => 'more regular periods';

  @override
  String get changeSaidLonger => 'longer periods';

  @override
  String get changeSaidShorter => 'shorter periods';

  @override
  String get changeSaidMorePainful => 'more painful periods';

  @override
  String get changeSaidLessPainful => 'less painful periods';

  @override
  String get symptomMigraine => 'Migraine';

  @override
  String get symptomMoodSwings => 'Mood swings';

  @override
  String get setupRemindersHint => 'Discreet: never the word \"period\".';

  @override
  String get setupPeriodReminder => 'Tell me before my period';

  @override
  String get setupPeriodReminderHint => 'A few days before the estimated date.';

  @override
  String get setupDailyReminder => 'Remind me to log my day';

  @override
  String get setupDailyReminderHint =>
      'Once a day, only if you logged nothing.';

  @override
  String get cycleFirstHalf => 'You are in the first half of your cycle.';

  @override
  String get cycleSecondHalf => 'You are in the second half of your cycle.';

  @override
  String get legendToday => 'Today';

  @override
  String get kpiWeek => 'Last 7 days';

  @override
  String get kpiWeekCaption => 'days logged';

  @override
  String get kpiCycle => 'This cycle';

  @override
  String kpiCycleCaption(int days) {
    return 'days logged out of $days';
  }

  @override
  String get kpiThisCycle => 'this cycle';

  @override
  String kpiPrevious(String value) {
    return 'previous cycle: $value';
  }

  @override
  String get kpiMostFrequent => 'most frequent this cycle';

  @override
  String get weekTitle => 'Your last 7 days';

  @override
  String get weekIntro => 'A full dot: logged that day.';

  @override
  String get weekAnyNote => 'The day';

  @override
  String get setupProfileTitle => 'Where are you at?';

  @override
  String get profileDiscovering => 'I am discovering my cycle';

  @override
  String get profileDiscoveringDetail => 'I\'m starting out';

  @override
  String get profileTracking => 'I track my periods';

  @override
  String get profileTrackingDetail => 'Predict and log';

  @override
  String get profileConceiving => 'I am trying to conceive';

  @override
  String get profileConceivingDetail => 'Estimated fertile window';

  @override
  String get profilePregnant => 'I am pregnant';

  @override
  String get profilePregnantDetail => 'Count the weeks';

  @override
  String get profilePostpartum => 'I gave birth';

  @override
  String get profilePostpartumDetail => 'Until my period returns';

  @override
  String get profilePerimenopause => 'My cycle is changing';

  @override
  String get profilePerimenopauseDetail => 'Perimenopause';

  @override
  String get setupPregnancyDateHint => 'The weeks are counted from that day.';

  @override
  String get setupBirthDateTitle => 'When did you give birth?';

  @override
  String get setupBirthDateHint => 'To count the weeks.';

  @override
  String get setupChooseDate => 'Choose the date';

  @override
  String get changeDate => 'Change the date';

  @override
  String get pregnancyTitle => 'Your pregnancy';

  @override
  String pregnancyWeeks(int weeks, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks',
      one: '1 week',
      zero: '0 weeks',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
      zero: '0 days',
    );
    return '$_temp0 and $_temp1';
  }

  @override
  String get pregnancyCounted =>
      'counted from the first day of your last period';

  @override
  String pregnancyTerm(String from, String to) {
    return 'A birth at term is estimated between $from and $to.';
  }

  @override
  String get pregnancyNote =>
      'An estimate: only a dating scan gives a reliable date.';

  @override
  String get pregnancyNoDate =>
      'Give the first day of your last period to count the weeks.';

  @override
  String get pregnancyPast =>
      'More than 42 weeks have gone by since that date. You can change the date or leave the pregnancy mode.';

  @override
  String get pregnancyPaused => 'The estimate of your periods is paused.';

  @override
  String get pregnancyLeave => 'Leave the pregnancy mode';

  @override
  String get leaveTitle => 'Where are you at now?';

  @override
  String get leaveGaveBirth => 'I gave birth';

  @override
  String get leaveBackToCycle => 'Go back to tracking my cycle';

  @override
  String get postpartumTitle => 'After the birth';

  @override
  String postpartumWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks',
      one: '1 week',
      zero: 'Less than a week',
    );
    return '$_temp0 since you gave birth';
  }

  @override
  String get postpartumBody =>
      'When periods come back varies a lot from one woman to another. Log their first day when they do: the estimate will start again from there.';

  @override
  String get postpartumNoDate =>
      'Give the date of the birth to count the weeks.';

  @override
  String get recapPregnancy => 'Pregnancy mode: weeks counted.';

  @override
  String get recapPostpartum => 'An estimate when your period returns.';

  @override
  String get reminderContraceptionTitle => 'Contraception reminder';

  @override
  String get reminderContraceptionSubtitle =>
      'Every day at the time you choose. A plain reminder: no advice, and nothing is checked.';

  @override
  String get notificationContraceptionBody => 'It is time.';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get migraineIntensity => 'How strong is the migraine?';

  @override
  String get migraineDurationTitle => 'How long did it last?';

  @override
  String get migraineMedicationTitle => 'Did you take a medication?';

  @override
  String get migraineHours => 'A few hours';

  @override
  String get migraineDay => 'A day';

  @override
  String get migraineLonger => 'More than a day';

  @override
  String get migraineMedicationYes => 'medication taken';

  @override
  String get migraineMedicationNo => 'no medication';

  @override
  String migraineSummaryDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days with a migraine in the last 90 days',
      one: '1 day with a migraine in the last 90 days',
    );
    return '$_temp0';
  }

  @override
  String migraineSummaryPeriod(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days of them during your period or the two days before.',
      one: '1 of them during your period or the two days before.',
      zero: 'None during your period or the two days before.',
    );
    return '$_temp0';
  }

  @override
  String migraineSummaryMedication(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'A medication noted on $days days.',
      one: 'A medication noted on 1 day.',
    );
    return '$_temp0';
  }

  @override
  String migraineSummaryIntensity(String level) {
    return 'Most often: $level.';
  }

  @override
  String get migraineSummaryNote =>
      'A count of what you ticked, to show a doctor. Nothing is said of causes or treatments.';

  @override
  String get partnerShareTitle => 'Invite my partner';

  @override
  String get partnerShareSubtitle => 'A code to scan. No server.';

  @override
  String get partnerShareIntro =>
      'A file protected by a password, which you send the way you like.';

  @override
  String get partnerShareName => 'Give my first name';

  @override
  String get partnerShareFertility => 'Share my estimated fertile window';

  @override
  String get partnerFertilityNote =>
      'An estimate: neither contraception nor a diagnosis.';

  @override
  String get partnerPassword => 'Password of the file';

  @override
  String get passwordRepeatLabel => 'Repeat the password';

  @override
  String get partnerCreate => 'Create the file';

  @override
  String get partnerSavedTitle => 'File created';

  @override
  String get partnerSavedBody =>
      'Send it to your partner, and tell them the password in person or by another way than the file.';

  @override
  String get partnerOpenEntry => 'Open my partner\'s file';

  @override
  String get partnerOpenTitle => 'File from a partner';

  @override
  String get partnerOpenAction => 'Open';

  @override
  String get partnerOpenError =>
      'This file could not be read: wrong password, or not a file made for a partner.';

  @override
  String get partnerHeader => 'Her cycle';

  @override
  String partnerHeaderOf(String name) {
    return '$name\'s cycle';
  }

  @override
  String get partnerReadOnly =>
      'What she chose to share with you. Nothing here leaves your phone.';

  @override
  String partnerDayOfCycle(int day) {
    return 'Day $day of her cycle';
  }

  @override
  String get partnerPeriodOngoing => 'Her period is going on';

  @override
  String partnerPeriodIn(int from, int to) {
    String _temp0 = intl.Intl.pluralLogic(
      from,
      locale: localeName,
      other: 'Period in $from to $to days',
      one: 'Period in 1 to $to days',
    );
    return '$_temp0';
  }

  @override
  String get partnerPeriodExpected => 'Her period may come any day now';

  @override
  String partnerRange(String from, String to) {
    return 'Estimated between $from and $to.';
  }

  @override
  String partnerFertileWindow(String from, String to) {
    return 'Estimated fertile window: $from to $to';
  }

  @override
  String get partnerOutdatedTitle => 'These dates are behind';

  @override
  String get partnerOutdatedBody => 'Ask her to show a new code.';

  @override
  String get partnerUnknownTitle => 'No estimate yet';

  @override
  String get partnerUnknownBody =>
      'She had not logged a period yet. Scan her code again later.';

  @override
  String get partnerPregnant => 'She is pregnant';

  @override
  String get partnerPregnancyCounted =>
      'counted from the first day of her last period';

  @override
  String get partnerAfterBirth => 'After the birth';

  @override
  String partnerWeeksSinceBirth(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks since the birth',
      one: '1 week since the birth',
      zero: 'Less than a week since the birth',
    );
    return '$_temp0';
  }

  @override
  String get partnerAfterBirthBody =>
      'Her periods have not come back in her journal yet.';

  @override
  String partnerMadeOn(String date) {
    return 'Shared on $date. Scan her code again now and then.';
  }

  @override
  String get partnerReplace => 'Open a file';

  @override
  String get partnerLeave => 'Stop following';

  @override
  String get pdfSave => 'Save as PDF';

  @override
  String get pdfSaved => 'Report saved.';

  @override
  String get pdfAveragesTitle => 'Averages';

  @override
  String get pdfNoCycle => 'No complete cycle logged yet.';

  @override
  String pdfBasis(int cycles) {
    String _temp0 = intl.Intl.pluralLogic(
      cycles,
      locale: localeName,
      other: 'Over the last $cycles complete cycles.',
      one: 'Over the last complete cycle.',
    );
    return '$_temp0';
  }

  @override
  String pdfMeanCycle(String days) {
    return 'Mean cycle length: $days';
  }

  @override
  String pdfCycleRange(int min, int max) {
    return 'Shortest cycle: $min days. Longest: $max days.';
  }

  @override
  String pdfMeanPeriod(String days) {
    return 'Mean period length: $days';
  }

  @override
  String get pdfCyclesTitle => 'Cycles';

  @override
  String pdfCycleLine(String from, String to, int length, int period) {
    return '$from to $to: cycle of $length days, period of $period days';
  }

  @override
  String get pdfFooter =>
      'Made on the phone from what the user logged herself. A list of dates and counts: not a diagnosis.';

  @override
  String get autoBackupTitle => 'Automatic backup';

  @override
  String get autoBackupSubtitle =>
      'Once a day, a file protected by your password is brought up to date in the Files app. Nothing is sent. The file is removed if you delete the app: keep a copy elsewhere too.';

  @override
  String get autoBackupPasswordTitle => 'Password of the automatic backup';

  @override
  String get autoBackupPasswordBody =>
      'You will need it to restore the backup. There is no way to find it again.';

  @override
  String get todayBleedingTitle => 'Bleeding today';

  @override
  String get kpiFertile => 'Estimated fertile window';

  @override
  String kpiFertileRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get kpiFertileCaption => 'an estimate, not a certainty';

  @override
  String get learnTitle => 'Your cycle, in a few words';

  @override
  String get learnCycle =>
      'A cycle goes from the first day of your period to the first day of the next one.';

  @override
  String get learnLength =>
      'Its length differs from one woman to another, and from one cycle to the next: most often between 24 and 38 days.';

  @override
  String get learnFirstYears =>
      'In the first years of having periods, irregular cycles are common.';

  @override
  String get learnLogging =>
      'The more you log, the more the estimate looks like you.';

  @override
  String get healthImportTitle => 'Import from Apple Health';

  @override
  String get healthImportSubtitle =>
      'Copies the period days you already logged there. Read on this phone; nothing is sent.';

  @override
  String get healthImportUnavailable =>
      'No period days could be read. You can allow it in the Health app, under Sharing, or log your periods here.';

  @override
  String healthImportDone(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days of period copied into your journal.',
      one: '1 day of period copied into your journal.',
      zero: 'Nothing new: the days found were already in your journal.',
    );
    return '$_temp0';
  }

  @override
  String get setupTagline => 'See your cycle clearly.';

  @override
  String get setupExisting => 'I already use Fycle';

  @override
  String get contraceptionHormonalDetail =>
      'Pill, implant, hormonal IUD, ring, patch';

  @override
  String get contraceptionNonHormonalDetail => 'Copper IUD, condoms, other';

  @override
  String get kpiRegularity => 'Your cycle';

  @override
  String get kpiRegular => 'Regular';

  @override
  String get kpiVariable => 'Variable';

  @override
  String get kpiRegularitySoon => 'Soon';

  @override
  String get kpiRegularityNeed => 'from 3 full cycles';

  @override
  String kpiRegularityGap(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days apart',
      one: '1 day apart',
      zero: 'always the same length',
    );
    return '$_temp0';
  }

  @override
  String get partnerInviteScan => 'Scan with the phone camera';

  @override
  String get partnerInviteWhat =>
      'Dates and estimates only. Fycle must be on their phone.';

  @override
  String get partnerInviteFile => 'Send a file instead';

  @override
  String get partnerQrLabel => 'Code to scan';

  @override
  String get partnerLinkErrorTitle => 'Unreadable code';

  @override
  String get partnerLinkErrorBody => 'Ask her to show a new code.';

  @override
  String get partnerLinkBusyTitle => 'This phone already follows a cycle';

  @override
  String get partnerLinkBusyBody =>
      'The partner view opens on a phone where Fycle is not set up yet.';

  @override
  String get comingTitleHers => 'What comes back for you';

  @override
  String get comingTitleCommon => 'Before a period, in general';

  @override
  String get comingNow => 'Around now';

  @override
  String comingIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'In about $days days',
      one: 'In about 1 day',
    );
    return '$_temp0';
  }

  @override
  String comingDaysBefore(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days before',
      one: 'the day before',
    );
    return '$_temp0';
  }

  @override
  String comingDaysRange(int from, int to) {
    return '$from to $to days before';
  }

  @override
  String comingLoggedLine(String when, int count, int total) {
    return '$when · $count of $total cycles';
  }

  @override
  String get comingDeclared => 'From what you said';

  @override
  String comingCommonBody(String signs) {
    return 'Often reported: $signs.';
  }

  @override
  String get comingCommonHint =>
      'A general benchmark. Log your signs to see your own.';

  @override
  String get comingLogToday => 'Today';

  @override
  String comingLogTooltip(String sign) {
    return 'Log today: $sign';
  }

  @override
  String get setupBeforeTitle => 'Before your period, you often get…';

  @override
  String get setupBeforeHint => 'Tick what you recognise.';

  @override
  String get reminderSignsTitle => 'What comes back';

  @override
  String get reminderSignsSubtitle => 'Once a cycle, before your usual signs.';

  @override
  String get notificationSignsBody => 'A note for the days ahead.';

  @override
  String get catchUpStartedTitle => 'Has your period started?';

  @override
  String get catchUpToday => 'Today';

  @override
  String get catchUpYesterday => 'Yesterday';

  @override
  String get catchUpOtherDay => 'Another day';

  @override
  String get catchUpNotYet => 'Not yet';

  @override
  String get catchUpContinuesTitle => 'Is your period still going on?';

  @override
  String catchUpContinuesBody(String date) {
    return 'Last day logged: $date.';
  }

  @override
  String get catchUpContinuesYes => 'Yes, today too';

  @override
  String get catchUpContinuesNo => 'It is over';

  @override
  String get catchUpHint => 'You can change any day in the journal.';

  @override
  String get todayLogYesterday => 'Log yesterday';

  @override
  String get dayIntimacyTitle => 'Sex';

  @override
  String get intimacyUnspecified => 'Yes';

  @override
  String get intimacyProtected => 'Protected';

  @override
  String get intimacyUnprotected => 'Unprotected';

  @override
  String get symptomPainDuringSex => 'Pain during sex';

  @override
  String get aheadTitle => 'The weeks ahead';

  @override
  String get aheadPeriod => 'Period, estimated';

  @override
  String aheadSigns(String signs) {
    return 'What comes back for you: $signs';
  }

  @override
  String get aheadFertile => 'Fertile window, estimated';

  @override
  String aheadDesire(int cycles, int considered) {
    return 'Desire often higher · $cycles of $considered cycles';
  }

  @override
  String aheadDates(String start, String end) {
    return '$start to $end';
  }

  @override
  String get aheadHint => 'Estimates, to help you plan.';

  @override
  String get aheadDesireGeneral =>
      'Desire: in general, a little higher around the middle of the cycle, and very different from one person to the next. Log yours to see your own pattern.';

  @override
  String get sexLifeTitle => 'Sex life';

  @override
  String get sexLifeSubtitle =>
      'Log sex and see when your desire is usually higher.';

  @override
  String get guidesTitle => 'Guides';

  @override
  String get guidesIntro =>
      'Short pages written for you. They replace no appointment.';

  @override
  String get guideTopicPerimenopause => 'Perimenopause';

  @override
  String get guideTopicPregnancy => 'Pregnancy';

  @override
  String get guideFeaturedTitle => 'For you';

  @override
  String get guideRead => 'Read';

  @override
  String get guideAll => 'All guides';

  @override
  String get guideSeekTitle => 'When to seek advice';

  @override
  String get guidePendingReview =>
      'Text awaiting review by a health professional.';

  @override
  String get guideNote => 'General information, not advice about you.';

  @override
  String get guideSourcesPerimenopause =>
      'Written from the pages of the NHS (United Kingdom) on menopause and perimenopause and on bleeding after menopause, read on 20 November 2026.';

  @override
  String get guideSourcesPregnancy =>
      'Written from the pages of the NHS (United Kingdom) on pregnancy week by week, pregnancy care, the baby\'s movements, bleeding in pregnancy, pre-eclampsia and the body after the birth, read on 20 November 2026.';

  @override
  String get guidePeriWhatTitle => 'Perimenopause: what is going on?';

  @override
  String get guidePeriWhatBody =>
      'A cycle doing whatever it likes, broken nights, a mood on a rollercoaster: what if that was it? The word is scary, the thing is ordinary, and nobody told you.\n\nPerimenopause is the time when periods become irregular, before they stop for good. It comes from a fall in hormone levels.\n\nMenopause is reached after 12 months without a period, when no hormonal contraception is used. It usually happens between 45 and 55, sometimes earlier.\n\nSymptoms usually last 7 to 9 years, sometimes longer, and change over time. They differ a lot from one person to the next: some are hardly affected, others a great deal.\n\nThere is no routine test: a doctor goes by age and symptoms.';

  @override
  String get guidePeriWhatSeek =>
      'Talk to a doctor if you think you have symptoms and want to know your options.';

  @override
  String get guidePeriPeriodsTitle => 'My periods are all over the place';

  @override
  String get guidePeriPeriodsBody =>
      'Twenty-three days, then forty, then a flood: your cycle has not lost its mind, it is changing pace.\n\nA change in periods is usually one of the first signs of perimenopause.\n\nThey may come more often or less often. Bleeding may become heavier or lighter.\n\nIn the end, periods stop altogether.\n\nHormonal contraception can change or stop periods, which makes it harder to tell where you are.\n\nLogging your periods here shows how the gap between them changes over the months.';

  @override
  String get guidePeriPeriodsSeek =>
      'See a doctor if your bleeding pattern has changed and you bleed more than before, or if you bleed after 12 months or more without a period.';

  @override
  String get guidePeriFlushesTitle => 'Hot flushes: the inner radiator';

  @override
  String get guidePeriFlushesBody =>
      'In a meeting, in bed, on the train: the wave rises without warning. You are not the only one opening the window in January.\n\nA hot flush is a sudden feeling of heat, or of cold, in the face, neck and chest. It lasts a few minutes and can come with heavy sweating, a racing heart or dizziness.\n\nAt night, they are called night sweats and can disturb sleep.\n\nWhat the NHS lists as helping day to day: light clothing, a cool bedroom, a cool shower, a fan or a cold drink, less stress, regular exercise, and fewer triggers such as spicy food, caffeine, hot drinks, alcohol and smoking.\n\nTreatments exist: a doctor can go through them with you.';

  @override
  String get guidePeriFlushesSeek =>
      'Talk to a doctor if you want to know your options, or if you have palpitations.';

  @override
  String get guidePeriSleepTitle =>
      'Broken nights, wobbly moods, missing words';

  @override
  String get guidePeriSleepBody =>
      'You look for your keys, then for the word \"keys\". No, you are not losing your mind.\n\nTrouble falling asleep or staying asleep is common, and often worse with night sweats.\n\nMood swings, low mood or anxiety may come too. So may trouble with memory or concentration, which feels worse after poor sleep.\n\nWhat the NHS lists as helping: regular sleep times, as much rest as you can, regular exercise, relaxing activities such as yoga or meditation, and talking with people going through the same thing.\n\nA talking therapy can help with low mood, anxiety and sleep. A doctor can also suggest treatments.';

  @override
  String get guidePeriSleepSeek =>
      'Talk to a doctor if you want to know your options. Getting advice early can limit the effects on your health, your relationships and your work.';

  @override
  String get guidePeriSexTitle => 'Desire that shifts, a body that lags';

  @override
  String get guidePeriSexBody =>
      'No desire, or desire but it chafes? Desire plays hide and seek, and it says nothing about your relationship, or about you.\n\nA lower sex drive is one of the possible symptoms of perimenopause.\n\nThe vagina may feel dry, burning, irritated or itchy, which can make sex painful. Urinary infections, or signs that feel like one, may also come more often.\n\nThese symptoms can go on after menopause. Solutions exist: a pharmacist or a doctor can suggest some, in private.\n\nA pregnancy is still possible during perimenopause.';

  @override
  String get guidePeriSexSeek =>
      'Talk to a pharmacist or a doctor to find what suits you. You can log dryness and pain during sex in your journal to show them.';

  @override
  String get guidePeriSeekTitle => 'When to see a doctor';

  @override
  String get guidePeriSeekBody =>
      'See a doctor, without urgency, if:\n\n• you think you have symptoms of perimenopause and want to know your options;\n\n• you have palpitations;\n\n• you still have periods, but the pattern has changed and you bleed more than before;\n\n• you have had no period for 12 months or more and you bleed, even once, even a little, even as pink or brown discharge.\n\nBleeding after menopause is usually not serious, but it always needs checking.';

  @override
  String get guidePeriSeekSeek =>
      'This page replaces no appointment: if in doubt, ask a health professional.';

  @override
  String get guidePregFirstTitle => 'First trimester';

  @override
  String get guidePregFirstBody =>
      'A pregnancy is counted from the first day of the last period. The first trimester runs up to week 12.\n\nA missed period is often one of the first signs. Others may come: nausea at any time of day, sore breasts, tiredness, needing to pee more often, cramps like period pains, bloating, a stronger sense of smell. Some feel nothing at all.\n\nA first appointment with a midwife or a doctor is usually held in these weeks: ask yours when.';

  @override
  String get guidePregFirstSeek =>
      'Any bleeding during a pregnancy should be reported to a midwife or a doctor, even light.';

  @override
  String get guidePregSecondTitle => 'Second trimester';

  @override
  String get guidePregSecondBody =>
      'From week 13 to week 27. The hardest symptoms of the first weeks have usually eased.\n\nWhat may come: a bump that starts to show, gums that swell or bleed, nosebleeds, leg cramps, dizziness, headaches, swollen hands and feet.\n\nThe baby\'s movements are usually first felt between 16 and 24 weeks, often after 20 weeks for a first baby.';

  @override
  String get guidePregSecondSeek =>
      'Tell your midwife if you have felt no movement by 24 weeks. A severe headache, vision problems or sudden swelling must be checked at once.';

  @override
  String get guidePregThirdTitle => 'Third trimester';

  @override
  String get guidePregThirdBody =>
      'From week 28 to the birth.\n\nWhat may come: heartburn, backache, cramps, trouble sleeping, feeling hot, swollen ankles and feet.\n\nThere is no set number of movements to count each day. What matters is your baby\'s usual pattern: you should feel movements right up to the birth, and during it.';

  @override
  String get guidePregThirdSeek =>
      'Call your midwife or maternity unit at once, day or night, if your baby moves less than usual, if you no longer feel it move, or if its pattern changes. Do not wait until the next day.';

  @override
  String get guidePregUrgentTitle => 'Signs not to wait on';

  @override
  String get guidePregUrgentBody =>
      'Call the emergency services if you are bleeding and you also have: severe tummy pain, pain in the shoulder, nausea, feeling faint or dizzy, a loss of consciousness, or bleeding so heavy that it soaks a pad soon after you put it on.\n\nContact your maternity unit, midwife or doctor at once if:\n\n• you bleed, even lightly;\n\n• your baby moves less than usual, you no longer feel it move, or its pattern changes;\n\n• you have a severe headache that simple painkillers do not ease;\n\n• your vision is blurred or you see flashing lights;\n\n• you have pain just below the ribs;\n\n• your face, hands or feet swell suddenly;\n\n• you feel very unwell.';

  @override
  String get guidePregUrgentSeek =>
      'This list is not complete. If something worries you, call without waiting for your next appointment.';

  @override
  String get guidePregCareTitle => 'What the appointments are for';

  @override
  String get guidePregCareBody =>
      'Pregnancy care is there to keep you and your baby as healthy as possible. It is usually given by a midwife, and by a doctor when needed.\n\nAt a first, longer appointment, you are asked about your health, the date of your last period, earlier pregnancies and your daily life.\n\nAt most appointments: your blood pressure is taken, your urine is tested, and later your bump is measured to follow the baby\'s growth. Blood tests and ultrasound scans are offered at set times.\n\nHow many appointments and scans there are, and when, depends on the country and on your situation.';

  @override
  String get guidePregCareSeek =>
      'You can contact those who follow your pregnancy at any time if you are worried, without waiting for the next appointment.';

  @override
  String get guidePregAfterTitle => 'After the birth: bleeding and periods';

  @override
  String get guidePregAfterBody =>
      'After the birth, you bleed from the vagina: heavily at first, then less and less, turning brownish, for a few weeks. This bleeding is not a period.\n\nWhen periods come back differs for everyone. With bottle feeding, or mixed feeding, the first period can come as soon as 5 to 6 weeks after the birth. With full breastfeeding, nights included, periods may not come back until you breastfeed less.\n\nA pregnancy is possible from 3 weeks after the birth, even while breastfeeding and before periods are back.\n\nA check-up is usually held 6 to 8 weeks after the birth: a good time to talk about your body and your mood.';

  @override
  String get guidePregAfterSeek =>
      'Tell a midwife or a doctor at once if you have: sudden or very heavy bleeding, large clots, a fever with a sore tummy, a headache with vision changes or vomiting, pain or swelling in one calf, chest pain or trouble breathing.';

  @override
  String get readingTitle => 'Further reading';

  @override
  String get readingNote =>
      'Opens in your browser. The site will see your visit, as with any web page.';

  @override
  String get readingTopicCycle => 'Cycle and periods';

  @override
  String get readingTopicSexuality => 'Sex and pleasure';

  @override
  String get readingTopicContraception => 'Contraception';

  @override
  String get readingTopicFertility => 'Fertility';

  @override
  String get linksCycle =>
      'Periods|NHS|https://www.nhs.uk/conditions/periods/\nPeriod pain|NHS|https://www.nhs.uk/symptoms/period-pain/\nPMS (premenstrual syndrome)|NHS|https://www.nhs.uk/conditions/pre-menstrual-syndrome/\nEndometriosis|NHS|https://www.nhs.uk/conditions/endometriosis/\nThrush|NHS|https://www.nhs.uk/conditions/thrush-in-men-and-women/';

  @override
  String get linksSexuality =>
      'Orgasms and pleasure|Brook|https://www.brook.org.uk/your-life/orgasms/\nMasturbation|Brook|https://www.brook.org.uk/your-life/masturbation/\nAnal sex|Brook|https://www.brook.org.uk/your-life/anal-sex/\nPainful sex|Brook|https://www.brook.org.uk/your-life/painful-sex/\nLow sex drive|NHS|https://www.nhs.uk/conditions/loss-of-libido/\nVaginal dryness|NHS|https://www.nhs.uk/conditions/vaginal-dryness/\nSexually transmitted infections|NHS|https://www.nhs.uk/conditions/sexually-transmitted-infections-stis/\nSexual health|World Health Organization|https://www.who.int/health-topics/sexual-health';

  @override
  String get linksContraception =>
      'Contraception|NHS|https://www.nhs.uk/contraception/\nEmergency contraception|NHS|https://www.nhs.uk/contraception/emergency-contraception/';

  @override
  String get linksFertility =>
      'Trying for a baby|NHS|https://www.nhs.uk/pregnancy/trying-for-a-baby/\nInfertility|NHS|https://www.nhs.uk/conditions/infertility/';

  @override
  String get linksPerimenopause =>
      'Menopause and perimenopause|NHS|https://www.nhs.uk/conditions/menopause/';

  @override
  String get linksPregnancy =>
      'Pregnancy|NHS|https://www.nhs.uk/pregnancy/\nSex and contraception after birth|NHS|https://www.nhs.uk/conditions/baby/support-and-services/sex-and-contraception-after-birth/';

  @override
  String get guideIntOrgasmTitle => 'Orgasm: all your questions';

  @override
  String get guideIntOrgasmBody =>
      'Fireworks for some, a quiet wave for others, a no-show for many: orgasm has a thousand faces, and none is the right one.\n\nFor most women, it all starts with the clitoris. What you see is only the tip: it runs on inside, on either side of the vagina. That is why penetration alone is rarely enough, and why a hand, a tongue or a toy on top changes everything.\n\nVaginal or clitoral? An old debate: it is the same organ, reached by different roads. Together, multiple, loud? Nice extras, not goals.\n\nWhat really helps: time, being turned on before you start, a head that is not elsewhere, and someone, you included, who knows where and how.';

  @override
  String get guideIntNoOrgasmTitle => 'I can\'t come: so what?';

  @override
  String get guideIntNoOrgasmBody =>
      'You fake it, or you wait for it while wondering what is wrong. Spoiler: probably nothing.\n\nMany women rarely or never come from penetration alone. It is not a manufacturing fault: it is anatomy.\n\nThe usual brakes are not in the body: the pressure to get there, tiredness, the shopping list scrolling by, a partner in a hurry, the habit of coming second.\n\nWhere to start: alone, with nothing at stake, to find what does something for you. Then show it or say it. And take orgasm off the list of things to achieve: it comes more readily when nobody is waiting at the door.';

  @override
  String get guideIntSoloTitle =>
      'Touching yourself: the manual nobody gave you';

  @override
  String get guideIntSoloBody =>
      'Hardly anyone talks about it, nearly everyone does it. Masturbating is neither a consolation prize nor cheating: it is the surest way to know what you like.\n\nThere is no right method. Fingers, the palm, the shower head, a pillow, a toy: the clitoris likes steadiness more than force, and often the edges more than the centre.\n\nChange the pressure, the rhythm, the position. Add lube: it changes everything. Take your time, or not: five minutes before sleep count too.\n\nDuring your period? Yes, and some say it eases their cramps. In a relationship? Yes too: one takes nothing from the other.';

  @override
  String get guideIntPeriodSexTitle =>
      'Sex on your period: yes, and here is how';

  @override
  String get guideIntPeriodSexBody =>
      'Nothing forbids it, many want it, and desire sometimes rises right then. What is left is logistics.\n\nA dark towel on the bed, a shower for two, a position where you lie down: the flow fades into the background. Tampons and cups come out before penetration.\n\nBlood helps things glide, orgasm relaxes: some find their period easier to live with afterwards. Others want nothing at all, and that is just as valid.\n\nSay it plainly: \"I\'m on my period, is that OK with you?\" Most partners care far less than you think.';

  @override
  String get guideIntAnalTitle =>
      'Anal sex: wanting it, getting ready, staying comfortable';

  @override
  String get guideIntAnalBody =>
      'Curious, tempted, or asked without being sure you want to? First rule: it only happens if you want it.\n\nThe anus makes no lubrication and does not relax on command. So: a lot of lube, a lot of time, and start small. A finger, a small toy with a flared base, long before anything else.\n\nBreathe, and push out slightly at the moment of entry: the muscle opens. You set the pace. A position where you control the depth helps a lot.\n\nIt should not hurt. Some discomfort at first, yes. Pain: stop, add lube, try again later, or never.\n\nAs for cleanliness, a shower is enough. The rest is part of the game, and everybody knows it.';

  @override
  String get guideIntLubeTitle => 'Lube: the best friend nobody dares to buy';

  @override
  String get guideIntLubeBody =>
      'It is not an admission of failure. It is what turns \"fine\" into \"more\".\n\nWater-based: goes with everything, dries faster, just add more. Silicone-based: glides for a long time, perfect in the shower and for anal, but not with silicone toys. Oils and petroleum jelly: lovely for a massage, to be kept away from latex condoms.\n\nWhen? As soon as it drags, for touching as for penetration, and always for anal. How wet you get changes with your cycle, stress, tiredness, breastfeeding, age: it says nothing about how much you want it.\n\nA tip: on you and on the other person, and the bottle within reach rather than at the back of the drawer.';

  @override
  String get guideIntDesireCycleTitle => 'Your desire has its seasons';

  @override
  String get guideIntDesireCycleBody =>
      'Some days you would climb the curtains, others you would rather have your series. Your cycle often has something to do with it.\n\nMany women feel their desire rise around the middle of the cycle and drop before their period. Others peak just before, or during. No calendar fits everyone.\n\nYours can be read in your journal: log your desire for a few cycles, and the app shows your high days. Handy to plan a weekend for two, or to understand a \"not tonight\" without making a thing of it.\n\nAnd then there is everything that is not hormonal: tiredness, mental load, an argument left open. The cycle tells part of the story, not all of it.';

  @override
  String get guideIntSquirtingTitle =>
      'Squirting: what is known, what is fantasy';

  @override
  String get guideIntSquirtingBody =>
      'A star on screen, a mystery in bedrooms: female ejaculation intrigues, and many wonder whether they \"should\" manage it.\n\nSome women release fluid at a moment of intense pleasure, sometimes a lot, sometimes a few drops. Others never do. Researchers do not all agree on what it contains or where exactly it comes from.\n\nWhat is certain: it is neither proof of orgasm, nor a higher level, nor a performance to offer. And what you see in porn is staged.\n\nIf it happens to you: a towel, and no shame. If it does not: you are missing nothing.';

  @override
  String get guideIntPainTitle => 'When it hurts';

  @override
  String get guideIntPainBody =>
      'Gritting your teeth until it is over was never part of the deal. Sex that hurts gets sorted, not endured.\n\nMost often it is a matter of time and glide: not turned on enough, not enough lube, penetration too soon or too deep. Slowing down, changing the angle, adding lube is often enough.\n\nSometimes the body closes by itself, even when the head says yes. Sometimes the pain is deep, or comes back at certain times of the cycle. Then it is no longer about technique.\n\nSay stop as soon as it hurts. Someone who cares about you would a thousand times rather stop.';

  @override
  String get guideIntTearsTitle => 'Crying after sex';

  @override
  String get guideIntTearsBody =>
      'It was good, and yet the tears come. Or a low mood drops out of nowhere.\n\nIt happens to a lot of people. After a strong build-up, the body comes down: tension lets go, and sometimes it overflows.\n\nIt does not mean you are sad, or that something is wrong between the two of you. Sometimes it does: the body knows before the head that you did not really want to.\n\nIn the moment, say it plainly: \"I don\'t know why, it will pass\". Ask for arms or for air, whichever does you good.';

  @override
  String get guideIntSayItTitle => 'Saying what you like, and what you don\'t';

  @override
  String get guideIntSayItBody =>
      'Nobody reads minds, not even in bed. And \"a bit to the left\" never killed the mood.\n\nThe simplest: guide as you go. A hand on theirs, a \"yes, like that\", a \"softer\". Short words work better than long speeches.\n\nFor bigger subjects, a new wish or something you no longer like, pick a moment with clothes on: in the car, on a walk, not right after.\n\nStart with what you like: \"I love it when you…\". Then the wish: \"I would like to try…\". And a no stays a no, both ways.';

  @override
  String get guideIntNoDesireTitle => 'No desire at all: where to start again';

  @override
  String get guideIntNoDesireBody =>
      'You love them, you find them attractive, and yet: nothing. Low desire is one of the most shared subjects, and the least admitted.\n\nLook at life first: broken sleep, mental load, a grudge that lingers, a body you do not like these days. Desire needs room, and there is none.\n\nFor many women, wanting does not fall from the sky: it comes along the way, once the touching has started. Waiting to want it before you begin can mean waiting a long time.\n\nWhat restarts it: time together with no goal, touch that leads to nothing required, something new, and moments alone with your own body.';

  @override
  String get guideIntAfterBabyTitle =>
      'After a baby: sex comes back, or not just yet';

  @override
  String get guideIntAfterBabyBody =>
      'Between broken nights, a body that has changed and a baby attached to you, desire has good reasons to keep you waiting.\n\nThere is no date. Some start again after a few weeks, others after several months. The right time is when you want to and it does not hurt.\n\nThe body often makes less lubrication, especially while breastfeeding: lube becomes essential. Start with touching, and keep control of the pace.\n\nAnd the two of you? Say where you are, even if it is \"not now\". Tenderness with nothing required after it bridges the gap.';

  @override
  String get guideIntMidlifeTitle => 'Perimenopause: sex changes its rules';

  @override
  String get guideIntMidlifeBody =>
      'No desire, or desire but it chafes? In perimenopause, desire plays hide and seek and the body makes less lubrication. It says nothing about your relationship, or about you.\n\nWhat changes: it often takes more time, more touching, and lube without a second thought. What does not: your ability to feel pleasure.\n\nMany women describe freer sex at this age: you know what you like, you dare to say it, you no longer pretend.\n\nBroken nights and hot flushes do not help desire. Looking after them is also looking after your sex life.';

  @override
  String get guideIntOnScheduleTitle =>
      'Trying for a baby: when sex becomes a schedule';

  @override
  String get guideIntOnScheduleBody =>
      'At first it was exciting. Three months later it is \"tonight, we have to\". Desire on demand: nobody likes that.\n\nIt is very common, and it says nothing about your relationship. Pressure cuts desire, for you as for the other.\n\nWhat lightens it: not staking everything on one evening, keeping moments with nothing at stake, and now and then putting the calendar away.\n\nTell the other one: \"I want you, not only a baby\". It changes the mood.';

  @override
  String get guideTopicIntimacy => 'Intimacy';

  @override
  String get guideSourcesIntimacy =>
      'Written for the app, in the tone of a magazine. What touches on safety will be reviewed by a health professional.';

  @override
  String get kioskTitle => 'Today\'s newsstand';

  @override
  String get kioskBody => 'Recent articles from the press, picked every day';

  @override
  String get kioskIntimacyTitle => 'The intimacy newsstand';

  @override
  String get kioskIntimacyBody =>
      'Sex, desire, first-person stories: what the press is writing';

  @override
  String get kioskNote =>
      'Picked automatically from the press: nobody has read these articles for you, and none is medical advice.';

  @override
  String get phaseTitle => 'Your cycle today';

  @override
  String phaseEstimated(String phase) {
    return '$phase · estimate';
  }

  @override
  String get phaseHormones => 'Hormones';

  @override
  String get phaseMood => 'Mood and energy';

  @override
  String get phaseBody => 'Body';

  @override
  String get phaseTip => 'Today\'s tip';

  @override
  String get phaseMore => 'Decode';

  @override
  String get phaseLess => 'Show less';

  @override
  String get phaseNote =>
      'General benchmarks, awaiting review by a health professional. Every body is different: yours may not follow them.';

  @override
  String phaseYours(String signs) {
    return 'Around this day, you have often logged: $signs.';
  }

  @override
  String get phasePerimenopause =>
      'With a cycle that is changing, hormones follow this pattern less closely: take it as a rough guide.';

  @override
  String get phaseConceive =>
      'Your estimated fertile window is shown on the ring above.';

  @override
  String get phaseDiscovering =>
      'First cycles are often irregular: they can take a few years to settle.';

  @override
  String get phasePeriodName => 'Your period';

  @override
  String get phasePeriodHormones =>
      'Oestrogen and progesterone are at their lowest. That drop is what starts the bleeding.';

  @override
  String get phasePeriodMood =>
      'Energy is often lower on the first days, then climbs back as the days go by.';

  @override
  String get phasePeriodBody =>
      'Cramps in the belly or the lower back are common, mostly on the first two days: the uterus contracts to shed its lining.';

  @override
  String get phasePeriodTip1 =>
      'Warmth on the belly, a hot-water bottle or a bath: it helps many women.';

  @override
  String get phasePeriodTip2 =>
      'Moving gently, walking or stretching, often helps more than staying still.';

  @override
  String get phasePeriodTip3 =>
      'A slower day is not a wasted day. If you can, keep the heavy stuff for later in the week.';

  @override
  String get phaseAfterName => 'After your period';

  @override
  String get phaseAfterHormones =>
      'Oestrogen rises day after day while an egg matures in an ovary.';

  @override
  String get phaseAfterMood =>
      'Many describe more energy, a clearer head and a lighter mood.';

  @override
  String get phaseAfterBody =>
      'Often the quietest days for the body: fewer aches, skin often clearer.';

  @override
  String get phaseAfterTip1 =>
      'A good week to start what you kept putting off.';

  @override
  String get phaseAfterTip2 =>
      'If you like sport, this is often when effort feels easiest.';

  @override
  String get phaseAfterTip3 =>
      'Feeling good? Log it too: the journal is not only for bad days.';

  @override
  String get phaseMidName => 'Middle of your cycle';

  @override
  String get phaseMidHormones =>
      'Oestrogen is at its highest, then a surge of another hormone, LH, triggers ovulation. Its day is only an estimate here.';

  @override
  String get phaseMidMood =>
      'Energy and confidence are often at their highest around these days. Not for everyone, and not every cycle.';

  @override
  String get phaseMidBody =>
      'Clearer, stretchy discharge is common. Some feel a twinge on one side of the lower belly.';

  @override
  String get phaseMidTip1 =>
      'Feel like seeing people? These are often the days for it.';

  @override
  String get phaseMidTip2 =>
      'Notice how your discharge changes: it is one of the clearest signals of the cycle.';

  @override
  String get phaseMidTip3 =>
      'A good moment for what takes nerve: a talk, a request, a first time at something.';

  @override
  String get phaseSecondName => 'Second part of your cycle';

  @override
  String get phaseSecondHormones =>
      'When ovulation has taken place, progesterone takes over and prepares the lining of the uterus. Oestrogen stays moderate.';

  @override
  String get phaseSecondMood =>
      'Many feel calmer, more inward. Energy often comes down a notch.';

  @override
  String get phaseSecondBody =>
      'Body temperature is often slightly higher. Tender breasts, more appetite or lighter sleep are common.';

  @override
  String get phaseSecondTip1 =>
      'Hungrier than usual? Common in this part of the cycle, and no lack of willpower.';

  @override
  String get phaseSecondTip2 =>
      'A regular bedtime helps when sleep gets lighter.';

  @override
  String get phaseSecondTip3 =>
      'A good time to finish what is under way rather than start something new.';

  @override
  String get phaseBeforeName => 'Before your period';

  @override
  String get phaseBeforeHormones =>
      'Without a pregnancy, progesterone and oestrogen fall. That drop is behind most of what is felt these days.';

  @override
  String get phaseBeforeMood =>
      'Irritability, low mood, tears close to the surface: common, and it passes when the period comes.';

  @override
  String get phaseBeforeBody =>
      'Bloating, tender breasts, headaches, tiredness, spots: common too.';

  @override
  String get phaseBeforeTip1 =>
      'What you feel is real, and it has a cause. No need to blame yourself for it.';

  @override
  String get phaseBeforeTip2 =>
      'Get your bag ready: your period is estimated soon.';

  @override
  String get phaseBeforeTip3 =>
      'Lighter plans, earlier nights: these days often ask for it.';

  @override
  String get partnerShareDesire => 'Share the days my desire is often higher';

  @override
  String get partnerShareDesireNote =>
      'Drawn from what you logged. Only the dates travel.';

  @override
  String get partnerPreview => 'See what my partner will see';

  @override
  String get partnerPreviewBanner =>
      'Preview: this is what your partner will see.';

  @override
  String get partnerAheadTitle => 'The weeks ahead';

  @override
  String partnerAheadPeriod(String from, String to) {
    return 'Period estimated from $from to $to';
  }

  @override
  String partnerAheadDesire(String from, String to) {
    return 'Her desire is often higher from $from to $to';
  }

  @override
  String get partnerDesireNote =>
      'From what she logged in past cycles. A tendency, not a promise: ask her.';

  @override
  String get settingsProfileTitle => 'My profile';

  @override
  String settingsProfileAge(int age) {
    return '$age years old';
  }

  @override
  String get settingsShownSection => 'What I see';

  @override
  String get settingsDoctorReportSubtitle =>
      'What a doctor would look at, as a file';

  @override
  String get devicesTitle => 'My watch and sensors';

  @override
  String get devicesSubtitle => 'Sleep, heart rate, temperature';

  @override
  String get devicesIntro =>
      'Fycle can read, on your phone, what your watch or your sensors keep in the health data of the phone: sleep, heart rate at rest, temperature at the wrist. Nothing is copied into Fycle and nothing leaves your phone.';

  @override
  String get devicesRead => 'Read my measurements';

  @override
  String get devicesReadAgain => 'Read again';

  @override
  String get devicesUnavailable =>
      'Nothing could be read: this phone has no such data to offer, or reading was not allowed. You can allow it in the settings of the phone.';

  @override
  String get devicesNothing =>
      'No measurement found over the last weeks. Either no watch or sensor recorded any, or reading was not allowed: you can allow it in the settings of the phone, under Health.';

  @override
  String devicesRecentTitle(int days) {
    return 'The last $days days';
  }

  @override
  String get devicesHalvesTitle => 'Over your cycles';

  @override
  String get devicesSleep => 'Sleep';

  @override
  String get devicesHeartRate => 'Heart rate at rest';

  @override
  String get devicesTemperature => 'Temperature at the wrist';

  @override
  String devicesSleepValue(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String devicesHeartRateValue(int beats) {
    return '$beats beats per minute';
  }

  @override
  String devicesTemperatureValue(String degrees) {
    return '$degrees °C';
  }

  @override
  String devicesAverageOf(String measure, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$measure, average of $days days',
      one: '$measure, 1 day measured',
    );
    return '$_temp0';
  }

  @override
  String devicesHalvesLine(String first, String second) {
    return 'First half: $first · Second half: $second';
  }

  @override
  String get devicesNote =>
      'Averages of your own measurements, cut in the middle of each cycle by dates. They confirm neither an ovulation nor a pregnancy, and replace no medical advice.';

  @override
  String get openFailedTitle => 'Fycle could not open';

  @override
  String get openFailedBody =>
      'Something on the phone did not answer. Your data has not been touched. Try again; if it keeps happening, restart the phone.';

  @override
  String get openFailedRetry => 'Try again';
}
