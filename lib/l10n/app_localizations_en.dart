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
  String get onboardingLastPeriodHint =>
      'An approximate date is fine. You can correct it later.';

  @override
  String get onboardingChooseDate => 'Choose a date';

  @override
  String get onboardingCycleLengthQuestion => 'How long is your cycle usually?';

  @override
  String get onboardingStart => 'Start';

  @override
  String get onboardingToday => 'Today';

  @override
  String get onboardingYesterday => 'Yesterday';

  @override
  String get onboardingSkip => 'I don\'t remember';

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
  String get lockTurnedOff =>
      'This phone no longer has a passcode: the lock of Fycle was turned off.';
}
