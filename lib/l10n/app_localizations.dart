import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Name of the app, shown in the title bar.
  ///
  /// In en, this message translates to:
  /// **'Fycle'**
  String get appTitle;

  /// Mandatory notice, shown at first launch, on the home screen and in the settings.
  ///
  /// In en, this message translates to:
  /// **'Fycle is an information tool. It does not give medical advice and is not a method of contraception.'**
  String get disclaimer;

  /// No description provided for @privacyLine.
  ///
  /// In en, this message translates to:
  /// **'No account. Nothing leaves this phone.'**
  String get privacyLine;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Nothing was changed.'**
  String get errorGeneric;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show the password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide the password'**
  String get hidePassword;

  /// Read by the screen reader while the local database opens.
  ///
  /// In en, this message translates to:
  /// **'Opening'**
  String get openingLabel;

  /// No description provided for @unreadableTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data cannot be read'**
  String get unreadableTitle;

  /// No description provided for @unreadableBody.
  ///
  /// In en, this message translates to:
  /// **'This phone holds Fycle data, but the key that protects it is missing. This happens when a phone is restored from a backup: the key never leaves the original phone. This data cannot be recovered.'**
  String get unreadableBody;

  /// No description provided for @unreadableStartFresh.
  ///
  /// In en, this message translates to:
  /// **'Start fresh'**
  String get unreadableStartFresh;

  /// No description provided for @unreadableRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup file'**
  String get unreadableRestore;

  /// No description provided for @unreadableConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Erase the unreadable data?'**
  String get unreadableConfirmTitle;

  /// No description provided for @unreadableConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The unreadable data will be erased from this phone. This cannot be undone.'**
  String get unreadableConfirmBody;

  /// No description provided for @erase.
  ///
  /// In en, this message translates to:
  /// **'Erase'**
  String get erase;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Fycle'**
  String get onboardingTitle;

  /// No description provided for @onboardingLastPeriodQuestion.
  ///
  /// In en, this message translates to:
  /// **'When did your last period start?'**
  String get onboardingLastPeriodQuestion;

  /// No description provided for @onboardingLastPeriodHint.
  ///
  /// In en, this message translates to:
  /// **'An approximate date is fine. You can correct it later.'**
  String get onboardingLastPeriodHint;

  /// No description provided for @onboardingChooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get onboardingChooseDate;

  /// No description provided for @onboardingCycleLengthQuestion.
  ///
  /// In en, this message translates to:
  /// **'How long is your cycle usually?'**
  String get onboardingCycleLengthQuestion;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStart;

  /// No description provided for @onboardingRestore.
  ///
  /// In en, this message translates to:
  /// **'I have a backup file'**
  String get onboardingRestore;

  /// No description provided for @cycleLengthFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Days (optional)'**
  String get cycleLengthFieldLabel;

  /// No description provided for @cycleLengthHelper.
  ///
  /// In en, this message translates to:
  /// **'From the first day of one period to the first day of the next. Leave empty if you don\'t know.'**
  String get cycleLengthHelper;

  /// No description provided for @cycleLengthError.
  ///
  /// In en, this message translates to:
  /// **'Enter a number between {min} and {max}.'**
  String cycleLengthError(int min, int max);

  /// No description provided for @homeLogToday.
  ///
  /// In en, this message translates to:
  /// **'Log today'**
  String get homeLogToday;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @statusNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No estimate yet'**
  String get statusNoDataTitle;

  /// No description provided for @statusNoDataBody.
  ///
  /// In en, this message translates to:
  /// **'Log the first day of your period to get an estimate.'**
  String get statusNoDataBody;

  /// No description provided for @statusOngoing.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of your period'**
  String statusOngoing(int day);

  /// Always a range of dates, never a single date.
  ///
  /// In en, this message translates to:
  /// **'Next period expected between {start} and {end}'**
  String statusNextRange(String start, String end);

  /// Always a range of dates, never a single date.
  ///
  /// In en, this message translates to:
  /// **'Period expected between {start} and {end}'**
  String statusExpectedRange(String start, String end);

  /// No description provided for @statusExpectedIn.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{This range starts tomorrow.} other{This range starts in {days} days.}}'**
  String statusExpectedIn(int days);

  /// No description provided for @statusDue.
  ///
  /// In en, this message translates to:
  /// **'Today is within this range.'**
  String get statusDue;

  /// No description provided for @statusLate.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day past this range.} other{{days} days past this range.}}'**
  String statusLate(int days);

  /// No description provided for @statusLateNote.
  ///
  /// In en, this message translates to:
  /// **'Cycles vary from one month to the next. This is only an estimate.'**
  String get statusLateNote;

  /// No description provided for @statusOutdatedTitle.
  ///
  /// In en, this message translates to:
  /// **'No recent entry'**
  String get statusOutdatedTitle;

  /// No description provided for @statusOutdatedBody.
  ///
  /// In en, this message translates to:
  /// **'Log your period to get a new estimate.'**
  String get statusOutdatedBody;

  /// No description provided for @estimateBasisCycles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Estimate based on your last cycle.} other{Estimate based on your last {count} cycles.}}'**
  String estimateBasisCycles(int count);

  /// No description provided for @estimateBasisDeclared.
  ///
  /// In en, this message translates to:
  /// **'Estimate based on the usual length you gave ({days} days). It will adjust as you log.'**
  String estimateBasisDeclared(int days);

  /// No description provided for @estimateBasisDefault.
  ///
  /// In en, this message translates to:
  /// **'Estimate based on a cycle of {days} days. It will adjust as you log.'**
  String estimateBasisDefault(int days);

  /// No description provided for @confidenceLow.
  ///
  /// In en, this message translates to:
  /// **'Confidence: low'**
  String get confidenceLow;

  /// No description provided for @confidenceMedium.
  ///
  /// In en, this message translates to:
  /// **'Confidence: medium'**
  String get confidenceMedium;

  /// No description provided for @confidenceHigh.
  ///
  /// In en, this message translates to:
  /// **'Confidence: high'**
  String get confidenceHigh;

  /// No description provided for @calendarPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get calendarPreviousMonth;

  /// No description provided for @calendarNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get calendarNextMonth;

  /// No description provided for @legendPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get legendPeriod;

  /// No description provided for @legendExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected period (estimate)'**
  String get legendExpected;

  /// No description provided for @legendEntry.
  ///
  /// In en, this message translates to:
  /// **'Other entry'**
  String get legendEntry;

  /// No description provided for @calendarDayToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get calendarDayToday;

  /// No description provided for @calendarDayPeriod.
  ///
  /// In en, this message translates to:
  /// **'period logged'**
  String get calendarDayPeriod;

  /// No description provided for @calendarDaySpotting.
  ///
  /// In en, this message translates to:
  /// **'spotting logged'**
  String get calendarDaySpotting;

  /// No description provided for @calendarDayExpected.
  ///
  /// In en, this message translates to:
  /// **'period expected, estimate'**
  String get calendarDayExpected;

  /// No description provided for @calendarDayEntry.
  ///
  /// In en, this message translates to:
  /// **'entry logged'**
  String get calendarDayEntry;

  /// No description provided for @dayFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get dayFlowTitle;

  /// No description provided for @dayPainTitle.
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get dayPainTitle;

  /// No description provided for @dayMoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get dayMoodTitle;

  /// No description provided for @daySymptomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get daySymptomsTitle;

  /// No description provided for @dayNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get dayNoteLabel;

  /// No description provided for @dayNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Anything you want to remember'**
  String get dayNoteHint;

  /// No description provided for @daySavedHint.
  ///
  /// In en, this message translates to:
  /// **'Saved automatically, on this phone only.'**
  String get daySavedHint;

  /// No description provided for @flowSpotting.
  ///
  /// In en, this message translates to:
  /// **'Spotting'**
  String get flowSpotting;

  /// No description provided for @flowLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get flowLight;

  /// No description provided for @flowMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get flowMedium;

  /// No description provided for @flowHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get flowHeavy;

  /// No description provided for @painNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get painNone;

  /// No description provided for @painMild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get painMild;

  /// No description provided for @painModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get painModerate;

  /// No description provided for @painSevere.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get painSevere;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodHappy;

  /// No description provided for @moodCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get moodCalm;

  /// No description provided for @moodSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get moodSad;

  /// No description provided for @moodAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get moodAnxious;

  /// No description provided for @moodIrritable.
  ///
  /// In en, this message translates to:
  /// **'Irritable'**
  String get moodIrritable;

  /// No description provided for @symptomCramps.
  ///
  /// In en, this message translates to:
  /// **'Cramps'**
  String get symptomCramps;

  /// No description provided for @symptomHeadache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get symptomHeadache;

  /// No description provided for @symptomBackPain.
  ///
  /// In en, this message translates to:
  /// **'Back pain'**
  String get symptomBackPain;

  /// No description provided for @symptomBreastTenderness.
  ///
  /// In en, this message translates to:
  /// **'Breast tenderness'**
  String get symptomBreastTenderness;

  /// No description provided for @symptomBloating.
  ///
  /// In en, this message translates to:
  /// **'Bloating'**
  String get symptomBloating;

  /// No description provided for @symptomNausea.
  ///
  /// In en, this message translates to:
  /// **'Nausea'**
  String get symptomNausea;

  /// No description provided for @symptomFatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get symptomFatigue;

  /// No description provided for @symptomAcne.
  ///
  /// In en, this message translates to:
  /// **'Acne'**
  String get symptomAcne;

  /// No description provided for @symptomCravings.
  ///
  /// In en, this message translates to:
  /// **'Cravings'**
  String get symptomCravings;

  /// No description provided for @symptomInsomnia.
  ///
  /// In en, this message translates to:
  /// **'Insomnia'**
  String get symptomInsomnia;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsCycleSection.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get settingsCycleSection;

  /// No description provided for @settingsCycleLength.
  ///
  /// In en, this message translates to:
  /// **'Usual cycle length'**
  String get settingsCycleLength;

  /// No description provided for @settingsCycleLengthValue.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String settingsCycleLengthValue(int days);

  /// No description provided for @settingsCycleLengthUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get settingsCycleLengthUnknown;

  /// No description provided for @settingsDataSection.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get settingsDataSection;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Save an encrypted backup'**
  String get settingsExport;

  /// No description provided for @settingsExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A file protected by a password, to keep wherever you want.'**
  String get settingsExportSubtitle;

  /// No description provided for @settingsImport.
  ///
  /// In en, this message translates to:
  /// **'Restore a backup'**
  String get settingsImport;

  /// No description provided for @settingsImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replaces everything in Fycle on this phone.'**
  String get settingsImportSubtitle;

  /// No description provided for @settingsCsv.
  ///
  /// In en, this message translates to:
  /// **'Export as a spreadsheet (CSV)'**
  String get settingsCsv;

  /// No description provided for @settingsCsvSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A readable file, not encrypted.'**
  String get settingsCsvSubtitle;

  /// No description provided for @settingsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get settingsDelete;

  /// No description provided for @settingsDeleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Erases all your data from this phone.'**
  String get settingsDeleteSubtitle;

  /// No description provided for @settingsAboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutSection;

  /// No description provided for @exportTitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup'**
  String get exportTitle;

  /// No description provided for @exportWarning.
  ///
  /// In en, this message translates to:
  /// **'If you forget this password, nobody can open the file, ever. There is no way to recover it. Write the password down somewhere safe.'**
  String get exportWarning;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat the password'**
  String get passwordConfirmLabel;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least {min} characters.'**
  String passwordTooShort(int min);

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'The two passwords are different.'**
  String get passwordMismatch;

  /// No description provided for @exportAction.
  ///
  /// In en, this message translates to:
  /// **'Create the file'**
  String get exportAction;

  /// No description provided for @exportDone.
  ///
  /// In en, this message translates to:
  /// **'Backup saved.'**
  String get exportDone;

  /// No description provided for @importReplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace everything?'**
  String get importReplaceTitle;

  /// No description provided for @importReplaceBody.
  ///
  /// In en, this message translates to:
  /// **'Restoring a backup replaces everything currently in Fycle on this phone.'**
  String get importReplaceBody;

  /// No description provided for @importReplaceAction.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get importReplaceAction;

  /// No description provided for @importPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Password of the backup'**
  String get importPasswordTitle;

  /// No description provided for @importAction.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get importAction;

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'Backup restored.'**
  String get importDone;

  /// No description provided for @importErrorNotBackup.
  ///
  /// In en, this message translates to:
  /// **'This file is not a Fycle backup. Nothing was changed.'**
  String get importErrorNotBackup;

  /// No description provided for @importErrorVersion.
  ///
  /// In en, this message translates to:
  /// **'This backup comes from a newer version of Fycle. Update the app and try again.'**
  String get importErrorVersion;

  /// No description provided for @importErrorWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong password, or damaged file. Nothing was changed.'**
  String get importErrorWrong;

  /// No description provided for @csvWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Unencrypted file'**
  String get csvWarningTitle;

  /// No description provided for @csvWarningBody.
  ///
  /// In en, this message translates to:
  /// **'This file is not encrypted: anyone who gets it can read it. Keep it in a place you trust.'**
  String get csvWarningBody;

  /// No description provided for @csvAction.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get csvAction;

  /// No description provided for @csvDone.
  ///
  /// In en, this message translates to:
  /// **'File saved.'**
  String get csvDone;

  /// No description provided for @csvDateHeader.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get csvDateHeader;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete everything?'**
  String get deleteTitle;

  /// No description provided for @deleteBody.
  ///
  /// In en, this message translates to:
  /// **'All your data will be erased from this phone, permanently. To keep a copy, save a backup first.'**
  String get deleteBody;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get deleteAction;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @settingsRemindersSection.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsRemindersSection;

  /// No description provided for @reminderPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Period approaching'**
  String get reminderPeriodTitle;

  /// No description provided for @reminderPeriodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One notification a few days before the estimated range.'**
  String get reminderPeriodSubtitle;

  /// No description provided for @reminderDaysBeforeTitle.
  ///
  /// In en, this message translates to:
  /// **'How long before'**
  String get reminderDaysBeforeTitle;

  /// No description provided for @reminderDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day before} other{{days} days before}}'**
  String reminderDaysBefore(int days);

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reminderTime;

  /// No description provided for @reminderDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily entry reminder'**
  String get reminderDailyTitle;

  /// No description provided for @reminderDailySubtitle.
  ///
  /// In en, this message translates to:
  /// **'One notification a day, skipped when the day is already logged.'**
  String get reminderDailySubtitle;

  /// No description provided for @reminderDiscreetNote.
  ///
  /// In en, this message translates to:
  /// **'Notifications stay discreet: they never mention your cycle. They are scheduled on this phone, without any server.'**
  String get reminderDiscreetNote;

  /// No description provided for @reminderPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off'**
  String get reminderPermissionTitle;

  /// No description provided for @reminderPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Fycle is not allowed to show notifications. You can allow them in the settings of your phone, then turn this reminder on.'**
  String get reminderPermissionBody;

  /// Text of a notification, visible on the lock screen. Must stay neutral: no mention of periods, cycles or health.
  ///
  /// In en, this message translates to:
  /// **'A look at your calendar?'**
  String get notificationPeriodBody;

  /// Text of a notification, visible on the lock screen. Must stay neutral: no mention of periods, cycles or health.
  ///
  /// In en, this message translates to:
  /// **'A moment to note your day?'**
  String get notificationDailyBody;

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get notificationChannelName;

  /// No description provided for @settingsPrivacySection.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacySection;

  /// No description provided for @lockTitle.
  ///
  /// In en, this message translates to:
  /// **'Lock Fycle'**
  String get lockTitle;

  /// No description provided for @lockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Face ID, fingerprint or the passcode of this phone, each time Fycle opens.'**
  String get lockSubtitle;

  /// No description provided for @lockUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'No passcode on this phone'**
  String get lockUnavailableTitle;

  /// No description provided for @lockUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Fycle relies on the lock of your phone. Set a passcode in the settings of your phone first.'**
  String get lockUnavailableBody;

  /// Sentence shown in the Face ID / fingerprint / passcode prompt of the system.
  ///
  /// In en, this message translates to:
  /// **'Unlock Fycle'**
  String get lockReason;

  /// No description provided for @lockScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Fycle is locked'**
  String get lockScreenTitle;

  /// No description provided for @lockScreenUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get lockScreenUnlock;

  /// No description provided for @settingsAppearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsAppearance;

  /// No description provided for @appearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDark;

  /// No description provided for @appearanceSystem.
  ///
  /// In en, this message translates to:
  /// **'Same as the phone'**
  String get appearanceSystem;

  /// No description provided for @lockTurnedOff.
  ///
  /// In en, this message translates to:
  /// **'This phone no longer has a passcode: the lock of Fycle was turned off.'**
  String get lockTurnedOff;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
