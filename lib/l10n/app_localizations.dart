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

  /// Button of the first-launch screen: enters the app without giving the date of the last period.
  ///
  /// In en, this message translates to:
  /// **'Not yet: I\'ll log it the day it starts'**
  String get onboardingSkip;

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

  /// Title of the card of the home screen where one tap on an intensity logs today's period.
  ///
  /// In en, this message translates to:
  /// **'Period today'**
  String get todayCardTitle;

  /// No description provided for @todayCardHint.
  ///
  /// In en, this message translates to:
  /// **'One tap saves. Tap again to undo.'**
  String get todayCardHint;

  /// Discreet count of consecutive days with an entry. A plain fact: no praise, no reward.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Logged 1 day in a row} other{Logged {days} days in a row}}'**
  String loggingStreak(int days);

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

  /// No description provided for @daySleepTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get daySleepTitle;

  /// No description provided for @dayLibidoTitle.
  ///
  /// In en, this message translates to:
  /// **'Libido'**
  String get dayLibidoTitle;

  /// No description provided for @sleepPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get sleepPoor;

  /// No description provided for @sleepFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get sleepFair;

  /// No description provided for @sleepGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get sleepGood;

  /// No description provided for @libidoLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get libidoLow;

  /// No description provided for @libidoMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get libidoMedium;

  /// No description provided for @libidoHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get libidoHigh;

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

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get insightsTitle;

  /// No description provided for @insightsCyclesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cycles'**
  String get insightsCyclesTitle;

  /// No description provided for @insightsAverageCycle.
  ///
  /// In en, this message translates to:
  /// **'Average cycle: {days} days'**
  String insightsAverageCycle(String days);

  /// No description provided for @insightsAveragePeriod.
  ///
  /// In en, this message translates to:
  /// **'Average period: {days} days'**
  String insightsAveragePeriod(String days);

  /// No description provided for @insightsAverageBasis.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Counted on your last complete cycle.} other{Counted on your last {count} complete cycles.}}'**
  String insightsAverageBasis(int count);

  /// No description provided for @insightsNoCycleYet.
  ///
  /// In en, this message translates to:
  /// **'Averages appear once a second period is logged.'**
  String get insightsNoCycleYet;

  /// No description provided for @insightsTrendsTitle.
  ///
  /// In en, this message translates to:
  /// **'What comes back'**
  String get insightsTrendsTitle;

  /// No description provided for @insightsTrendsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show yet. A line appears here when the same thing is logged at the same moment in at least two complete cycles.'**
  String get insightsTrendsEmpty;

  /// No description provided for @insightsTrendsNote.
  ///
  /// In en, this message translates to:
  /// **'These lines count what you logged. They are observations, not a medical interpretation.'**
  String get insightsTrendsNote;

  /// No description provided for @trendDuringPeriod.
  ///
  /// In en, this message translates to:
  /// **'During your period, in {count} of your last {total} cycles'**
  String trendDuringPeriod(int count, int total);

  /// No description provided for @trendBeforePeriod.
  ///
  /// In en, this message translates to:
  /// **'In the week before your period, in {count} of your last {total} cycles'**
  String trendBeforePeriod(int count, int total);

  /// No description provided for @trendRest.
  ///
  /// In en, this message translates to:
  /// **'In the rest of the cycle, in {count} of your last {total} cycles'**
  String trendRest(int count, int total);

  /// No description provided for @signWithKind.
  ///
  /// In en, this message translates to:
  /// **'{kind}: {value}'**
  String signWithKind(String kind, String value);

  /// No description provided for @insightsHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get insightsHistoryTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No period logged yet.'**
  String get historyEmpty;

  /// No description provided for @historyCycleRange.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String historyCycleRange(String start, String end);

  /// No description provided for @historyCycleDetail.
  ///
  /// In en, this message translates to:
  /// **'{period, plural, =1{{days} days · period of 1 day} other{{days} days · period of {period} days}}'**
  String historyCycleDetail(int days, int period);

  /// No description provided for @historyCurrent.
  ///
  /// In en, this message translates to:
  /// **'In progress since {start}'**
  String historyCurrent(String start);

  /// No description provided for @historyUnusual.
  ///
  /// In en, this message translates to:
  /// **'Unusual length, left out of the averages.'**
  String get historyUnusual;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your last cycle'**
  String get summaryTitle;

  /// No description provided for @summaryLength.
  ///
  /// In en, this message translates to:
  /// **'It lasted {days} days.'**
  String summaryLength(int days);

  /// No description provided for @summaryLonger.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day longer than your cycles before.} other{{days} days longer than your cycles before.}}'**
  String summaryLonger(int days);

  /// No description provided for @summaryShorter.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day shorter than your cycles before.} other{{days} days shorter than your cycles before.}}'**
  String summaryShorter(int days);

  /// No description provided for @summarySame.
  ///
  /// In en, this message translates to:
  /// **'The same as your cycles before.'**
  String get summarySame;

  /// No description provided for @summaryMostLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged most: {symptoms}.'**
  String summaryMostLogged(String symptoms);

  /// No description provided for @listSeparator.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get listSeparator;

  /// No description provided for @summarySeeTrends.
  ///
  /// In en, this message translates to:
  /// **'See trends'**
  String get summarySeeTrends;

  /// No description provided for @summaryClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get summaryClose;

  /// No description provided for @fertilitySettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Ovulation estimate'**
  String get fertilitySettingTitle;

  /// No description provided for @fertilitySettingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shows an estimated fertile window on the home screen and in the calendar.'**
  String get fertilitySettingSubtitle;

  /// No description provided for @fertilityWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'An estimate, nothing more'**
  String get fertilityWarningTitle;

  /// Medical wording: to be reviewed by a health professional before any release outside private testing.
  ///
  /// In en, this message translates to:
  /// **'This estimate is calculated from the dates of your periods only. It is not a method of contraception and not a diagnosis. It cannot tell which days are without risk: ovulation may fall outside the days shown.'**
  String get fertilityWarning;

  /// No description provided for @fertilityTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get fertilityTurnOn;

  /// No description provided for @fertilityCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Estimated fertile window'**
  String get fertilityCardTitle;

  /// No description provided for @fertilityWindowRange.
  ///
  /// In en, this message translates to:
  /// **'Between {start} and {end}'**
  String fertilityWindowRange(String start, String end);

  /// No description provided for @fertilityOvulationRange.
  ///
  /// In en, this message translates to:
  /// **'Ovulation estimated between {start} and {end}'**
  String fertilityOvulationRange(String start, String end);

  /// No description provided for @fertilityLowConfidence.
  ///
  /// In en, this message translates to:
  /// **'Your cycles vary a lot: this estimate is not reliable.'**
  String get fertilityLowConfidence;

  /// No description provided for @fertilityNotEnough.
  ///
  /// In en, this message translates to:
  /// **'The estimate appears once two complete cycles are logged.'**
  String get fertilityNotEnough;

  /// No description provided for @fertilityHow.
  ///
  /// In en, this message translates to:
  /// **'How it is calculated'**
  String get fertilityHow;

  /// Medical wording: to be reviewed by a health professional before any release outside private testing.
  ///
  /// In en, this message translates to:
  /// **'Fycle starts from the estimate of your next period and counts back about 13 days, with 3 days of margin on each side, to place ovulation. The window covers the 5 days before and the day after. Cycles differ from one person to another and from one month to the next: these are averages, not measurements of your body.'**
  String get fertilityHowBody;

  /// No description provided for @legendFertile.
  ///
  /// In en, this message translates to:
  /// **'Fertile window (estimate)'**
  String get legendFertile;

  /// No description provided for @calendarDayFertile.
  ///
  /// In en, this message translates to:
  /// **'fertile window, estimate'**
  String get calendarDayFertile;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get tabCalendar;

  /// No description provided for @tabReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get tabReview;

  /// No description provided for @homeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get homeTooltip;

  /// No description provided for @cycleDayCaption.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get cycleDayCaption;

  /// No description provided for @cycleDaySemantics.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of your cycle'**
  String cycleDaySemantics(int day);

  /// No description provided for @countdownRange.
  ///
  /// In en, this message translates to:
  /// **'Period in {min} to {max} days'**
  String countdownRange(int min, int max);

  /// No description provided for @countdownDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Period expected from today} =1{Period expected from tomorrow} other{Period in {days} days}}'**
  String countdownDays(int days);

  /// No description provided for @countdownDue.
  ///
  /// In en, this message translates to:
  /// **'Period expected around now'**
  String get countdownDue;

  /// No description provided for @figuresTitle.
  ///
  /// In en, this message translates to:
  /// **'Your figures'**
  String get figuresTitle;

  /// No description provided for @figureCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get figureCycle;

  /// No description provided for @figurePeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get figurePeriod;

  /// No description provided for @figureLogged.
  ///
  /// In en, this message translates to:
  /// **'Days logged'**
  String get figureLogged;

  /// No description provided for @figureDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}}'**
  String figureDays(int days);

  /// No description provided for @figureUnknown.
  ///
  /// In en, this message translates to:
  /// **'–'**
  String get figureUnknown;

  /// No description provided for @sourceLogged.
  ///
  /// In en, this message translates to:
  /// **'from your entries'**
  String get sourceLogged;

  /// No description provided for @sourceDeclared.
  ///
  /// In en, this message translates to:
  /// **'as you indicated'**
  String get sourceDeclared;

  /// No description provided for @sourceAssumed.
  ///
  /// In en, this message translates to:
  /// **'estimate for now'**
  String get sourceAssumed;

  /// No description provided for @sourceCurrent.
  ///
  /// In en, this message translates to:
  /// **'so far'**
  String get sourceCurrent;

  /// No description provided for @sourceCycles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no complete cycle yet} =1{1 complete cycle} other{{count} complete cycles}}'**
  String sourceCycles(int count);

  /// No description provided for @usualTitle.
  ///
  /// In en, this message translates to:
  /// **'Usually around this day'**
  String get usualTitle;

  /// No description provided for @usualLine.
  ///
  /// In en, this message translates to:
  /// **'{sign}: in {count} of your last {total} cycles'**
  String usualLine(String sign, int count, int total);

  /// No description provided for @unlockTitle.
  ///
  /// In en, this message translates to:
  /// **'The more you log, the more you see'**
  String get unlockTitle;

  /// No description provided for @unlockIntro.
  ///
  /// In en, this message translates to:
  /// **'Fycle calculates everything from what you log. Each entry makes your figures more accurate.'**
  String get unlockIntro;

  /// No description provided for @unlockEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate of your next period'**
  String get unlockEstimate;

  /// No description provided for @unlockEstimateNeed.
  ///
  /// In en, this message translates to:
  /// **'From your first logged period'**
  String get unlockEstimateNeed;

  /// No description provided for @unlockAverages.
  ///
  /// In en, this message translates to:
  /// **'Average lengths of your cycle and period'**
  String get unlockAverages;

  /// No description provided for @unlockAveragesNeed.
  ///
  /// In en, this message translates to:
  /// **'After one complete cycle'**
  String get unlockAveragesNeed;

  /// No description provided for @unlockTrends.
  ///
  /// In en, this message translates to:
  /// **'What comes back, and the ovulation estimate'**
  String get unlockTrends;

  /// No description provided for @unlockTrendsNeed.
  ///
  /// In en, this message translates to:
  /// **'After two complete cycles'**
  String get unlockTrendsNeed;

  /// No description provided for @unlockReliable.
  ///
  /// In en, this message translates to:
  /// **'A narrower, more reliable estimate'**
  String get unlockReliable;

  /// No description provided for @unlockReliableNeed.
  ///
  /// In en, this message translates to:
  /// **'With four regular cycles or more'**
  String get unlockReliableNeed;

  /// No description provided for @unlockProgress.
  ///
  /// In en, this message translates to:
  /// **'{have} of {need}'**
  String unlockProgress(int have, int need);

  /// No description provided for @unlockReached.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get unlockReached;

  /// No description provided for @unlockOverall.
  ///
  /// In en, this message translates to:
  /// **'{reached} of {total} available'**
  String unlockOverall(int reached, int total);

  /// No description provided for @todayEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'My journal today'**
  String get todayEntryTitle;

  /// No description provided for @todayEntryProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} sections filled in today'**
  String todayEntryProgress(int done, int total);

  /// No description provided for @calendarHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a day to log it or correct it.'**
  String get calendarHint;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'This cycle'**
  String get reportTitle;

  /// No description provided for @reportStarted.
  ///
  /// In en, this message translates to:
  /// **'Started on {date}'**
  String reportStarted(String date);

  /// No description provided for @reportPeriod.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Period: 1 day} other{Period: {days} days}}'**
  String reportPeriod(int days);

  /// No description provided for @reportLogged.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing logged yet in this cycle} =1{1 day logged in this cycle} other{{count} days logged in this cycle}}'**
  String reportLogged(int count);

  /// No description provided for @reportPainDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Pain on 1 day} other{Pain on {count} days}}'**
  String reportPainDays(int count);

  /// No description provided for @reportPoorSleep.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Poor sleep on 1 night} other{Poor sleep on {count} nights}}'**
  String reportPoorSleep(int count);

  /// No description provided for @reportEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log the first day of your period to start your review.'**
  String get reportEmpty;

  /// No description provided for @onboardingIntro1.
  ///
  /// In en, this message translates to:
  /// **'Log your period and how you feel, in a few taps.'**
  String get onboardingIntro1;

  /// No description provided for @onboardingIntro2.
  ///
  /// In en, this message translates to:
  /// **'See your figures: day of the cycle, estimate of the next period, what comes back.'**
  String get onboardingIntro2;

  /// No description provided for @onboardingIntro3.
  ///
  /// In en, this message translates to:
  /// **'The more you log, the more accurate it gets.'**
  String get onboardingIntro3;

  /// No description provided for @onboardingEarlierTitle.
  ///
  /// In en, this message translates to:
  /// **'Earlier periods (optional)'**
  String get onboardingEarlierTitle;

  /// No description provided for @onboardingEarlierHint.
  ///
  /// In en, this message translates to:
  /// **'Add the first day of one or two earlier periods: your averages and trends come sooner.'**
  String get onboardingEarlierHint;

  /// No description provided for @onboardingAddEarlier.
  ///
  /// In en, this message translates to:
  /// **'Add an earlier period'**
  String get onboardingAddEarlier;

  /// No description provided for @onboardingRemoveDate.
  ///
  /// In en, this message translates to:
  /// **'Remove {date}'**
  String onboardingRemoveDate(String date);

  /// No description provided for @tabJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get tabJournal;

  /// No description provided for @tabHomeHint.
  ///
  /// In en, this message translates to:
  /// **'Your figures today, and a quick entry.'**
  String get tabHomeHint;

  /// No description provided for @tabJournalHint.
  ///
  /// In en, this message translates to:
  /// **'Your calendar and your pages, day after day.'**
  String get tabJournalHint;

  /// No description provided for @tabReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Your averages, what comes back, and your history.'**
  String get tabReviewHint;

  /// No description provided for @tabSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Reminders, privacy, backup and your data.'**
  String get tabSettingsHint;

  /// No description provided for @journalPagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your latest pages'**
  String get journalPagesTitle;

  /// No description provided for @journalEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing written yet. Your first page starts with today.'**
  String get journalEmpty;

  /// No description provided for @journalWriteToday.
  ///
  /// In en, this message translates to:
  /// **'Write today\'s page'**
  String get journalWriteToday;

  /// No description provided for @todayNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Your note'**
  String get todayNoteTitle;

  /// No description provided for @fertilityShortWarning.
  ///
  /// In en, this message translates to:
  /// **'An estimate: neither contraception nor a diagnosis.'**
  String get fertilityShortWarning;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get homeGreeting;

  /// No description provided for @homeReassurance.
  ///
  /// In en, this message translates to:
  /// **'Your journal is private. It stays on this phone, and nobody else can read it.'**
  String get homeReassurance;

  /// No description provided for @figureReference.
  ///
  /// In en, this message translates to:
  /// **'reference: {days} days'**
  String figureReference(int days);

  /// Reference values: to be reviewed by a health professional before any release outside private testing.
  ///
  /// In en, this message translates to:
  /// **'Shown for now: a reference cycle of {cycle} days, with a period of {period} days. Your own dates will replace it.'**
  String referenceLine(int cycle, int period);

  /// No description provided for @referenceCaption.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get referenceCaption;

  /// No description provided for @studyCardTitle.
  ///
  /// In en, this message translates to:
  /// **'What the studies say'**
  String get studyCardTitle;

  /// Medical wording drawn from a published study: to be reviewed by a health professional before any release outside private testing.
  ///
  /// In en, this message translates to:
  /// **'Only about 13% of cycles last exactly 28 days.'**
  String get factExactly28;

  /// Medical wording drawn from a published study: to be reviewed by a health professional before any release outside private testing.
  ///
  /// In en, this message translates to:
  /// **'For about 4 women in 10, the length of the cycle varies by more than 7 days from one cycle to another.'**
  String get factVariesMoreThan7;

  /// Medical wording drawn from a published study: to be reviewed by a health professional before any release outside private testing.
  ///
  /// In en, this message translates to:
  /// **'95% of the cycles measured lasted between 22 and 36 days.'**
  String get factRange22to36;

  /// Medical wording drawn from a published study: to be reviewed by a health professional before any release outside private testing.
  ///
  /// In en, this message translates to:
  /// **'Between 25 and 45, the cycle shortens by about 0.18 day a year.'**
  String get factShortensWithAge;

  /// Medical wording drawn from a published study: to be reviewed by a health professional before any release outside private testing.
  ///
  /// In en, this message translates to:
  /// **'The first part of the cycle, before ovulation, is the one that varies most. The second hardly moves.'**
  String get factFirstPartVaries;

  /// Medical wording drawn from a published study: to be reviewed by a health professional before any release outside private testing.
  ///
  /// In en, this message translates to:
  /// **'Conception was observed only in the six days ending on the day of ovulation.'**
  String get factSixDayWindow;

  /// Medical wording drawn from a published study: to be reviewed by a health professional before any release outside private testing.
  ///
  /// In en, this message translates to:
  /// **'A cycle of 24 to 38 days and a period of up to 8 days are within the usual range used by gynaecologists.'**
  String get factFigoRanges;

  /// No description provided for @youMeanCycle.
  ///
  /// In en, this message translates to:
  /// **'Your average cycle: {days} days.'**
  String youMeanCycle(String days);

  /// No description provided for @youVariation.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Yours: your cycles all had the same length.} =1{Yours: 1 day between your shortest and your longest cycle.} other{Yours: {days} days between your shortest and your longest cycle.}}'**
  String youVariation(int days);

  /// No description provided for @youAgeReference.
  ///
  /// In en, this message translates to:
  /// **'At {age}, the reference cycle is {days} days.'**
  String youAgeReference(int age, int days);

  /// No description provided for @youAgeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Give your year of birth in the settings to start from a reference closer to your age.'**
  String get youAgeUnknown;

  /// No description provided for @youFollicular.
  ///
  /// In en, this message translates to:
  /// **'Yours is estimated at {min} to {max} days.'**
  String youFollicular(int min, int max);

  /// No description provided for @youWindow.
  ///
  /// In en, this message translates to:
  /// **'Your estimated window: {start} to {end}.'**
  String youWindow(String start, String end);

  /// No description provided for @youFigo.
  ///
  /// In en, this message translates to:
  /// **'Your cycle: {cycle} days. Your period: {period} days.'**
  String youFigo(String cycle, String period);

  /// No description provided for @youNotYet.
  ///
  /// In en, this message translates to:
  /// **'Log two periods to see where you stand.'**
  String get youNotYet;

  /// No description provided for @sourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sourcesTitle;

  /// No description provided for @sourcesIntro.
  ///
  /// In en, this message translates to:
  /// **'The reference figures come from these published studies. They describe groups of women, not you: your own entries always take over.'**
  String get sourcesIntro;

  /// No description provided for @sourceBull2019.
  ///
  /// In en, this message translates to:
  /// **'Bull et al., npj Digital Medicine, 2019. 612,613 cycles.'**
  String get sourceBull2019;

  /// No description provided for @sourceFehring2006.
  ///
  /// In en, this message translates to:
  /// **'Fehring, Schneider and Raviele, 2006. 1,060 cycles.'**
  String get sourceFehring2006;

  /// No description provided for @sourceWilcox1995.
  ///
  /// In en, this message translates to:
  /// **'Wilcox, Weinberg and Baird, New England Journal of Medicine, 1995.'**
  String get sourceWilcox1995;

  /// No description provided for @sourceFigo2018.
  ///
  /// In en, this message translates to:
  /// **'Munro, Critchley and Fraser for FIGO, International Journal of Gynecology & Obstetrics, 2018.'**
  String get sourceFigo2018;

  /// No description provided for @clinicalTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinical sheet'**
  String get clinicalTitle;

  /// No description provided for @clinicalIntro.
  ///
  /// In en, this message translates to:
  /// **'Your log, read with the four parameters gynaecologists use.'**
  String get clinicalIntro;

  /// No description provided for @clinicalBasis.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Based on 1 complete cycle over the last 12 months.} other{Based on {count} complete cycles over the last 12 months.}}'**
  String clinicalBasis(int count);

  /// No description provided for @clinicalEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your own figures come in once a first cycle has ended.'**
  String get clinicalEmpty;

  /// No description provided for @clinicalFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get clinicalFrequency;

  /// No description provided for @clinicalFrequencyValue.
  ///
  /// In en, this message translates to:
  /// **'A cycle of {days} days on average'**
  String clinicalFrequencyValue(String days);

  /// No description provided for @clinicalFrequencyRef.
  ///
  /// In en, this message translates to:
  /// **'Usual range: 24 to 38 days'**
  String get clinicalFrequencyRef;

  /// No description provided for @clinicalRegularity.
  ///
  /// In en, this message translates to:
  /// **'Regularity'**
  String get clinicalRegularity;

  /// No description provided for @clinicalRegularityValue.
  ///
  /// In en, this message translates to:
  /// **'{variation, plural, =0{Cycles of {min} days, all the same length} =1{Cycles of {min} to {max} days, 1 day apart} other{Cycles of {min} to {max} days, {variation} days apart}}'**
  String clinicalRegularityValue(int min, int max, int variation);

  /// No description provided for @clinicalRegularityRef.
  ///
  /// In en, this message translates to:
  /// **'Usual: up to {limit} days apart'**
  String clinicalRegularityRef(int limit);

  /// No description provided for @clinicalRegularityTooFew.
  ///
  /// In en, this message translates to:
  /// **'Three complete cycles are needed to tell.'**
  String get clinicalRegularityTooFew;

  /// No description provided for @clinicalDuration.
  ///
  /// In en, this message translates to:
  /// **'Period length'**
  String get clinicalDuration;

  /// No description provided for @clinicalDurationValue.
  ///
  /// In en, this message translates to:
  /// **'{days} days on average, {max} at most'**
  String clinicalDurationValue(String days, int max);

  /// No description provided for @clinicalDurationRef.
  ///
  /// In en, this message translates to:
  /// **'Usual: up to 8 days'**
  String get clinicalDurationRef;

  /// No description provided for @clinicalVolume.
  ///
  /// In en, this message translates to:
  /// **'Flow'**
  String get clinicalVolume;

  /// No description provided for @clinicalVolumeLight.
  ///
  /// In en, this message translates to:
  /// **'Light, as you logged it'**
  String get clinicalVolumeLight;

  /// No description provided for @clinicalVolumeModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate, as you logged it'**
  String get clinicalVolumeModerate;

  /// No description provided for @clinicalVolumeHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy, as you logged it'**
  String get clinicalVolumeHeavy;

  /// No description provided for @clinicalPhases.
  ///
  /// In en, this message translates to:
  /// **'Two parts of the cycle (estimate)'**
  String get clinicalPhases;

  /// No description provided for @clinicalPhasesValue.
  ///
  /// In en, this message translates to:
  /// **'Before ovulation: {min} to {max} days. After: about {luteal} days.'**
  String clinicalPhasesValue(int min, int max, int luteal);

  /// No description provided for @clinicalSpotting.
  ///
  /// In en, this message translates to:
  /// **'Spotting between periods'**
  String get clinicalSpotting;

  /// No description provided for @clinicalSpottingValue.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{None logged} =1{1 day logged} other{{days} days logged}}'**
  String clinicalSpottingValue(int days);

  /// No description provided for @statusWithin.
  ///
  /// In en, this message translates to:
  /// **'Within the usual range'**
  String get statusWithin;

  /// No description provided for @statusOutside.
  ///
  /// In en, this message translates to:
  /// **'Outside the usual range'**
  String get statusOutside;

  /// Medical wording drawn from a published study: to be reviewed by a health professional before any release outside private testing.
  ///
  /// In en, this message translates to:
  /// **'A value outside the usual range is not a diagnosis. This sheet is worth showing to a doctor.'**
  String get clinicalOutsideNote;

  /// No description provided for @clinicalSource.
  ///
  /// In en, this message translates to:
  /// **'Reference ranges: FIGO, 2018.'**
  String get clinicalSource;

  /// No description provided for @birthYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year of birth (optional)'**
  String get birthYearLabel;

  /// No description provided for @birthYearHelper.
  ///
  /// In en, this message translates to:
  /// **'Used to start from a reference cycle closer to your age. It stays on this phone.'**
  String get birthYearHelper;

  /// No description provided for @birthYearError.
  ///
  /// In en, this message translates to:
  /// **'Enter a year between {min} and {max}.'**
  String birthYearError(int min, int max);

  /// No description provided for @settingsBirthYear.
  ///
  /// In en, this message translates to:
  /// **'Year of birth'**
  String get settingsBirthYear;

  /// No description provided for @sourceAssumedAge.
  ///
  /// In en, this message translates to:
  /// **'reference for your age, to adjust'**
  String get sourceAssumedAge;

  /// No description provided for @settingsBirthYearUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not given'**
  String get settingsBirthYearUnknown;

  /// No description provided for @doctorReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report for your doctor'**
  String get doctorReportTitle;

  /// No description provided for @doctorReportIntro.
  ///
  /// In en, this message translates to:
  /// **'Drawn up on {date} from what you logged. It describes and compares; it is not a diagnosis.'**
  String doctorReportIntro(String date);

  /// No description provided for @doctorReportAge.
  ///
  /// In en, this message translates to:
  /// **'Age: {age}'**
  String doctorReportAge(int age);

  /// No description provided for @clinicalToFill.
  ///
  /// In en, this message translates to:
  /// **'Your figure will replace this line'**
  String get clinicalToFill;

  /// No description provided for @clinicalRegularityRefAny.
  ///
  /// In en, this message translates to:
  /// **'Usual: up to 7 to 9 days apart, depending on age'**
  String get clinicalRegularityRefAny;

  /// No description provided for @periodStartsToday.
  ///
  /// In en, this message translates to:
  /// **'My period starts today'**
  String get periodStartsToday;

  /// No description provided for @comparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'This cycle and the one before'**
  String get comparisonTitle;

  /// No description provided for @comparisonIntro.
  ///
  /// In en, this message translates to:
  /// **'{day, plural, =1{Both taken on their first day.} other{Both taken over their first {day} days.}}'**
  String comparisonIntro(int day);

  /// No description provided for @comparisonPrevious.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get comparisonPrevious;

  /// No description provided for @comparisonPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period days'**
  String get comparisonPeriod;

  /// No description provided for @comparisonPain.
  ///
  /// In en, this message translates to:
  /// **'Days with pain'**
  String get comparisonPain;

  /// No description provided for @comparisonSleep.
  ///
  /// In en, this message translates to:
  /// **'Poor nights'**
  String get comparisonSleep;

  /// No description provided for @comparisonLogged.
  ///
  /// In en, this message translates to:
  /// **'Days logged'**
  String get comparisonLogged;

  /// No description provided for @comparisonRow.
  ///
  /// In en, this message translates to:
  /// **'{label}: {current} in this cycle, {previous} in the one before'**
  String comparisonRow(String label, int current, int previous);

  /// No description provided for @monthsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your history, month by month'**
  String get monthsTitle;

  /// No description provided for @monthsIntro.
  ///
  /// In en, this message translates to:
  /// **'Everything rests on it: the fuller your months, the more accurate your estimates.'**
  String get monthsIntro;

  /// No description provided for @monthLogged.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Nothing logged} =1{1 day logged} other{{days} days logged}}'**
  String monthLogged(int days);

  /// No description provided for @monthPeriod.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 period day} other{{days} period days}}'**
  String monthPeriod(int days);

  /// No description provided for @ringCountdownCaption.
  ///
  /// In en, this message translates to:
  /// **'Days left'**
  String get ringCountdownCaption;

  /// No description provided for @ringShowCountdown.
  ///
  /// In en, this message translates to:
  /// **'Show the days left'**
  String get ringShowCountdown;

  /// No description provided for @ringShowDay.
  ///
  /// In en, this message translates to:
  /// **'Show the day of the cycle'**
  String get ringShowDay;

  /// No description provided for @widgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Home-screen widget'**
  String get widgetTitle;

  /// No description provided for @widgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The cycle ring on the home screen of this phone, with no word about periods. Add it from the home screen: touch and hold an empty area, then the + button.'**
  String get widgetSubtitle;

  /// No description provided for @lockTurnedOff.
  ///
  /// In en, this message translates to:
  /// **'This phone no longer has a passcode: the lock of Fycle was turned off.'**
  String get lockTurnedOff;

  /// No description provided for @ringShowUsual.
  ///
  /// In en, this message translates to:
  /// **'Show what usually comes around this day'**
  String get ringShowUsual;

  /// No description provided for @ringHint.
  ///
  /// In en, this message translates to:
  /// **'Slide along the ring to go through your cycle.'**
  String get ringHint;

  /// No description provided for @ringExploreValue.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of your cycle, {date}'**
  String ringExploreValue(int day, String date);

  /// No description provided for @exploreToday.
  ///
  /// In en, this message translates to:
  /// **'{date} · today'**
  String exploreToday(String date);

  /// No description provided for @exploreLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged: {facts}'**
  String exploreLogged(String facts);

  /// No description provided for @exploreNothingLogged.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged on that day.'**
  String get exploreNothingLogged;

  /// No description provided for @exploreExpected.
  ///
  /// In en, this message translates to:
  /// **'Within the range where your next period is estimated.'**
  String get exploreExpected;

  /// No description provided for @exploreFertile.
  ///
  /// In en, this message translates to:
  /// **'Within your estimated fertile window. An estimate: neither contraception nor a diagnosis.'**
  String get exploreFertile;

  /// No description provided for @exploreUsual.
  ///
  /// In en, this message translates to:
  /// **'Usually around this day: {signs}'**
  String exploreUsual(String signs);

  /// No description provided for @exploreNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing stands out around this day in your past cycles yet.'**
  String get exploreNothing;

  /// No description provided for @exploreOpen.
  ///
  /// In en, this message translates to:
  /// **'Open this page'**
  String get exploreOpen;

  /// No description provided for @exploreBack.
  ///
  /// In en, this message translates to:
  /// **'Back to today'**
  String get exploreBack;

  /// No description provided for @periodEndRange.
  ///
  /// In en, this message translates to:
  /// **'About {from} to {to} more days, going by your past periods'**
  String periodEndRange(int from, int to);

  /// No description provided for @periodEndDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{About 1 more day, going by your past periods} other{About {count} more days, going by your past periods}}'**
  String periodEndDays(int count);

  /// No description provided for @periodEndToday.
  ///
  /// In en, this message translates to:
  /// **'Likely the last day, going by your past periods'**
  String get periodEndToday;

  /// No description provided for @reviewSeeDetail.
  ///
  /// In en, this message translates to:
  /// **'See the detail'**
  String get reviewSeeDetail;

  /// No description provided for @reviewDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'The detail'**
  String get reviewDetailTitle;

  /// No description provided for @remindersAskTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersAskTitle;

  /// No description provided for @remindersAskBody.
  ///
  /// In en, this message translates to:
  /// **'Fycle can tell you a few days before your period, and remind you of your journal each day. Nothing leaves this phone. Turn both reminders on?'**
  String get remindersAskBody;

  /// No description provided for @remindersAskBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for Fycle in the settings of this phone. Without them, Fycle cannot tell you before your period or remind you of your journal. You can allow them in the settings of the phone.'**
  String get remindersAskBlockedBody;

  /// No description provided for @remindersAskLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get remindersAskLater;

  /// No description provided for @setupWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'A few questions to start from you, not from an average. Each one can be skipped.'**
  String get setupWelcomeBody;

  /// No description provided for @setupBegin.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get setupBegin;

  /// No description provided for @setupSkipAll.
  ///
  /// In en, this message translates to:
  /// **'Skip the setup'**
  String get setupSkipAll;

  /// No description provided for @setupSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get setupSkip;

  /// No description provided for @setupNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get setupNext;

  /// No description provided for @setupBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get setupBack;

  /// No description provided for @setupProgress.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String setupProgress(int step, int total);

  /// No description provided for @setupNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your first name?'**
  String get setupNameTitle;

  /// No description provided for @setupNameHint.
  ///
  /// In en, this message translates to:
  /// **'It stays on this phone. You can leave it empty.'**
  String get setupNameHint;

  /// No description provided for @setupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get setupNameLabel;

  /// No description provided for @setupBirthTitle.
  ///
  /// In en, this message translates to:
  /// **'What year were you born?'**
  String get setupBirthTitle;

  /// No description provided for @setupBirthHint.
  ///
  /// In en, this message translates to:
  /// **'The length of a cycle changes with age: the first estimate starts from there.'**
  String get setupBirthHint;

  /// No description provided for @setupGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'What brings you here?'**
  String get setupGoalsTitle;

  /// No description provided for @setupGoalsHint.
  ///
  /// In en, this message translates to:
  /// **'Several answers are possible.'**
  String get setupGoalsHint;

  /// No description provided for @goalTrackPeriods.
  ///
  /// In en, this message translates to:
  /// **'Track my periods'**
  String get goalTrackPeriods;

  /// No description provided for @goalUnderstandBody.
  ///
  /// In en, this message translates to:
  /// **'Understand my body better'**
  String get goalUnderstandBody;

  /// No description provided for @goalConceive.
  ///
  /// In en, this message translates to:
  /// **'Conceive a child'**
  String get goalConceive;

  /// No description provided for @goalPerimenopause.
  ///
  /// In en, this message translates to:
  /// **'Follow a perimenopause'**
  String get goalPerimenopause;

  /// No description provided for @setupRegularTitle.
  ///
  /// In en, this message translates to:
  /// **'Are your periods regular?'**
  String get setupRegularTitle;

  /// No description provided for @setupRegularHint.
  ///
  /// In en, this message translates to:
  /// **'That is, the number of days between two periods stays about the same.'**
  String get setupRegularHint;

  /// No description provided for @regularYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get regularYes;

  /// No description provided for @regularNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get regularNo;

  /// No description provided for @regularUnknown.
  ///
  /// In en, this message translates to:
  /// **'I don\'t know'**
  String get regularUnknown;

  /// No description provided for @regularNoPeriods.
  ///
  /// In en, this message translates to:
  /// **'I don\'t have periods'**
  String get regularNoPeriods;

  /// No description provided for @setupLengthsTitle.
  ///
  /// In en, this message translates to:
  /// **'How many days do your cycle and your period last?'**
  String get setupLengthsTitle;

  /// No description provided for @setupLengthsHint.
  ///
  /// In en, this message translates to:
  /// **'Give a number of days, even a rough one, with the − and + buttons. If you don\'t know, tap \"Skip\": the app will work it out from what you log.'**
  String get setupLengthsHint;

  /// No description provided for @setupCycleLength.
  ///
  /// In en, this message translates to:
  /// **'Length of your cycle'**
  String get setupCycleLength;

  /// No description provided for @setupCycleLengthHelper.
  ///
  /// In en, this message translates to:
  /// **'From the first day of your period to the first day of the next one.'**
  String get setupCycleLengthHelper;

  /// No description provided for @setupPeriodLength.
  ///
  /// In en, this message translates to:
  /// **'Length of your period'**
  String get setupPeriodLength;

  /// No description provided for @setupPeriodLengthHelper.
  ///
  /// In en, this message translates to:
  /// **'The number of days your period lasts.'**
  String get setupPeriodLengthHelper;

  /// No description provided for @setupDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String setupDays(int count);

  /// No description provided for @setupFewer.
  ///
  /// In en, this message translates to:
  /// **'One day fewer'**
  String get setupFewer;

  /// No description provided for @setupMore.
  ///
  /// In en, this message translates to:
  /// **'One day more'**
  String get setupMore;

  /// No description provided for @setupChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Have your periods changed in the last few months?'**
  String get setupChangesTitle;

  /// No description provided for @setupChangesHint.
  ///
  /// In en, this message translates to:
  /// **'Tick what has changed. If a change worries you, talk to a doctor or a midwife about it.'**
  String get setupChangesHint;

  /// No description provided for @changeHeavier.
  ///
  /// In en, this message translates to:
  /// **'My flow is heavier'**
  String get changeHeavier;

  /// No description provided for @changeLighter.
  ///
  /// In en, this message translates to:
  /// **'My flow is lighter'**
  String get changeLighter;

  /// No description provided for @changeLessRegular.
  ///
  /// In en, this message translates to:
  /// **'My periods are less regular'**
  String get changeLessRegular;

  /// No description provided for @changeLength.
  ///
  /// In en, this message translates to:
  /// **'The length of my periods has changed'**
  String get changeLength;

  /// No description provided for @changeNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing has changed'**
  String get changeNothing;

  /// No description provided for @setupLastHint.
  ///
  /// In en, this message translates to:
  /// **'Touch the day. An approximate date is enough: you can correct it later.'**
  String get setupLastHint;

  /// No description provided for @setupRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you want reminders?'**
  String get setupRemindersTitle;

  /// No description provided for @setupLockTitle.
  ///
  /// In en, this message translates to:
  /// **'For your eyes only'**
  String get setupLockTitle;

  /// No description provided for @setupLockHint.
  ///
  /// In en, this message translates to:
  /// **'Nobody opens the app without you. You can change this at any time in the settings.'**
  String get setupLockHint;

  /// No description provided for @setupReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'All set'**
  String get setupReadyTitle;

  /// No description provided for @setupReadyTitleName.
  ///
  /// In en, this message translates to:
  /// **'All set, {name}'**
  String setupReadyTitleName(String name);

  /// No description provided for @setupReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Log your period the day it starts: the estimate gets closer with each cycle.'**
  String get setupReadyBody;

  /// No description provided for @settingsAnswers.
  ///
  /// In en, this message translates to:
  /// **'My answers'**
  String get settingsAnswers;

  /// No description provided for @settingsAnswersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'First name, goals, regularity, usual lengths.'**
  String get settingsAnswersSubtitle;

  /// No description provided for @periodEndDeclaredDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{About 1 more day, going by what you said} other{About {count} more days, going by what you said}}'**
  String periodEndDeclaredDays(int count);

  /// No description provided for @periodEndDeclaredToday.
  ///
  /// In en, this message translates to:
  /// **'Probably the last day, going by what you said'**
  String get periodEndDeclaredToday;

  /// No description provided for @symptomHotFlashes.
  ///
  /// In en, this message translates to:
  /// **'Hot flashes'**
  String get symptomHotFlashes;

  /// No description provided for @symptomNightSweats.
  ///
  /// In en, this message translates to:
  /// **'Night sweats'**
  String get symptomNightSweats;

  /// No description provided for @changeTitle.
  ///
  /// In en, this message translates to:
  /// **'What is changing'**
  String get changeTitle;

  /// No description provided for @changeIntro.
  ///
  /// In en, this message translates to:
  /// **'What your dates show from one cycle to the next. An observation, not a diagnosis.'**
  String get changeIntro;

  /// No description provided for @changeTooFew.
  ///
  /// In en, this message translates to:
  /// **'Two complete cycles are needed to compare one with the next.'**
  String get changeTooFew;

  /// No description provided for @changeNoDifference.
  ///
  /// In en, this message translates to:
  /// **'{cycles, plural, =1{Your last cycle is within 7 days of the one before.} other{Over your last {cycles} cycles, none differs from the one before by 7 days or more.}}'**
  String changeNoDifference(int cycles);

  /// No description provided for @changeDifferences.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Once over your last {cycles} cycles, the length changed by 7 days or more from one cycle to the next.} other{{count} times over your last {cycles} cycles, the length changed by 7 days or more from one cycle to the next.}}'**
  String changeDifferences(int count, int cycles);

  /// No description provided for @changeLongInterval.
  ///
  /// In en, this message translates to:
  /// **'One cycle lasted {days} days: 60 days or more between two periods.'**
  String changeLongInterval(int days);

  /// No description provided for @changeSinceLast.
  ///
  /// In en, this message translates to:
  /// **'{days} days since your last period started: 60 days or more without a period.'**
  String changeSinceLast(int days);

  /// No description provided for @changeNoSigns.
  ///
  /// In en, this message translates to:
  /// **'None of the signs to follow was logged in the last 90 days. You can tick them in your journal.'**
  String get changeNoSigns;

  /// No description provided for @changeSaid.
  ///
  /// In en, this message translates to:
  /// **'When you set the app up, you said: {changes}.'**
  String changeSaid(String changes);

  /// No description provided for @changeSaidHeavier.
  ///
  /// In en, this message translates to:
  /// **'heavier flow'**
  String get changeSaidHeavier;

  /// No description provided for @changeSaidLighter.
  ///
  /// In en, this message translates to:
  /// **'lighter flow'**
  String get changeSaidLighter;

  /// No description provided for @changeSaidLessRegular.
  ///
  /// In en, this message translates to:
  /// **'less regular periods'**
  String get changeSaidLessRegular;

  /// No description provided for @changeSaidLength.
  ///
  /// In en, this message translates to:
  /// **'periods of a different length'**
  String get changeSaidLength;

  /// No description provided for @changeToReport.
  ///
  /// In en, this message translates to:
  /// **'Worth telling a doctor or a midwife about: many things can move a cycle, and only a health professional can say what this means.'**
  String get changeToReport;

  /// No description provided for @changeFooter.
  ///
  /// In en, this message translates to:
  /// **'Many things can move a cycle. Only a health professional can say what a change means.'**
  String get changeFooter;

  /// No description provided for @setupPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data never leaves your phone'**
  String get setupPrivacyTitle;

  /// No description provided for @setupPrivacyHint.
  ///
  /// In en, this message translates to:
  /// **'What you log here is nobody\'s business but yours.'**
  String get setupPrivacyHint;

  /// No description provided for @privacyNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account to create.'**
  String get privacyNoAccount;

  /// No description provided for @privacyOnPhone.
  ///
  /// In en, this message translates to:
  /// **'Everything is stored on your phone, encrypted.'**
  String get privacyOnPhone;

  /// No description provided for @privacyBackup.
  ///
  /// In en, this message translates to:
  /// **'Nothing is sent over the Internet.'**
  String get privacyBackup;

  /// No description provided for @privacyNoAds.
  ///
  /// In en, this message translates to:
  /// **'No advertising, no subscription.'**
  String get privacyNoAds;

  /// No description provided for @setupGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}.'**
  String setupGreeting(String name);

  /// No description provided for @setupWishesTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell me more about what you want'**
  String get setupWishesTitle;

  /// No description provided for @setupWishesHint.
  ///
  /// In en, this message translates to:
  /// **'Several answers are possible. Each one decides what the app puts forward.'**
  String get setupWishesHint;

  /// No description provided for @wishKnowWhen.
  ///
  /// In en, this message translates to:
  /// **'Know when my period is coming'**
  String get wishKnowWhen;

  /// No description provided for @wishKnowUsualRanges.
  ///
  /// In en, this message translates to:
  /// **'See how my cycle compares with the usual ranges'**
  String get wishKnowUsualRanges;

  /// No description provided for @wishFertileWindow.
  ///
  /// In en, this message translates to:
  /// **'Know my estimated fertile window'**
  String get wishFertileWindow;

  /// No description provided for @wishAfterContraception.
  ///
  /// In en, this message translates to:
  /// **'Understand my cycle after stopping contraception'**
  String get wishAfterContraception;

  /// No description provided for @wishWhatComesBack.
  ///
  /// In en, this message translates to:
  /// **'See what comes back with each cycle'**
  String get wishWhatComesBack;

  /// No description provided for @setupUsualTitle.
  ///
  /// In en, this message translates to:
  /// **'What are your periods usually like?'**
  String get setupUsualTitle;

  /// No description provided for @setupUsualHint.
  ///
  /// In en, this message translates to:
  /// **'Choose what fits you best.'**
  String get setupUsualHint;

  /// No description provided for @setupUsualFlow.
  ///
  /// In en, this message translates to:
  /// **'Flow'**
  String get setupUsualFlow;

  /// No description provided for @setupUsualPain.
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get setupUsualPain;

  /// No description provided for @setupContraceptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you use contraception?'**
  String get setupContraceptionTitle;

  /// No description provided for @setupContraceptionHint.
  ///
  /// In en, this message translates to:
  /// **'With a hormonal contraception, bleeding does not follow a natural cycle: the app then hides the ovulation estimate. It gives no advice on contraception.'**
  String get setupContraceptionHint;

  /// No description provided for @contraceptionNone.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get contraceptionNone;

  /// No description provided for @contraceptionHormonal.
  ///
  /// In en, this message translates to:
  /// **'Yes, hormonal (pill, implant, hormonal IUD, ring, patch)'**
  String get contraceptionHormonal;

  /// No description provided for @contraceptionNonHormonal.
  ///
  /// In en, this message translates to:
  /// **'Yes, without hormones (copper IUD, condoms, other)'**
  String get contraceptionNonHormonal;

  /// No description provided for @setupSignsTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you have these signs these days?'**
  String get setupSignsTitle;

  /// No description provided for @setupSignsHint.
  ///
  /// In en, this message translates to:
  /// **'Tick the ones you have. You will then be able to log them each day in your journal.'**
  String get setupSignsHint;

  /// No description provided for @symptomVaginalDryness.
  ///
  /// In en, this message translates to:
  /// **'Vaginal dryness'**
  String get symptomVaginalDryness;

  /// No description provided for @symptomJointPain.
  ///
  /// In en, this message translates to:
  /// **'Joint pain'**
  String get symptomJointPain;

  /// No description provided for @symptomBrainFog.
  ///
  /// In en, this message translates to:
  /// **'Trouble concentrating'**
  String get symptomBrainFog;

  /// No description provided for @symptomPalpitations.
  ///
  /// In en, this message translates to:
  /// **'Palpitations'**
  String get symptomPalpitations;

  /// No description provided for @setupEarlierTitle.
  ///
  /// In en, this message translates to:
  /// **'And the periods before?'**
  String get setupEarlierTitle;

  /// No description provided for @setupEarlierHint.
  ///
  /// In en, this message translates to:
  /// **'Touch the first day of up to three earlier periods, if you remember them. The estimate then starts from your own cycle.'**
  String get setupEarlierHint;

  /// No description provided for @setupTrackedTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you want to log each day?'**
  String get setupTrackedTitle;

  /// No description provided for @setupTrackedHint.
  ///
  /// In en, this message translates to:
  /// **'Tick what matters to you. These sections will come first in your journal.'**
  String get setupTrackedHint;

  /// No description provided for @trackedPain.
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get trackedPain;

  /// No description provided for @trackedMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get trackedMood;

  /// No description provided for @trackedSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get trackedSleep;

  /// No description provided for @trackedLibido.
  ///
  /// In en, this message translates to:
  /// **'Libido'**
  String get trackedLibido;

  /// No description provided for @trackedSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get trackedSymptoms;

  /// No description provided for @recapTitle.
  ///
  /// In en, this message translates to:
  /// **'What I set up for you'**
  String get recapTitle;

  /// No description provided for @recapCycleOwn.
  ///
  /// In en, this message translates to:
  /// **'Your estimate starts from your own dates: a cycle of {days} days.'**
  String recapCycleOwn(int days);

  /// No description provided for @recapCycleDeclared.
  ///
  /// In en, this message translates to:
  /// **'Your estimate starts from what you said: a cycle of {days} days.'**
  String recapCycleDeclared(int days);

  /// No description provided for @recapCycleAge.
  ///
  /// In en, this message translates to:
  /// **'Your estimate starts from the published average for your age: {days} days.'**
  String recapCycleAge(int days);

  /// No description provided for @recapCycleDefault.
  ///
  /// In en, this message translates to:
  /// **'Your estimate starts from a common cycle of {days} days.'**
  String recapCycleDefault(int days);

  /// No description provided for @recapRange.
  ///
  /// In en, this message translates to:
  /// **'A range of {days} days on each side, which narrows as your dates come in.'**
  String recapRange(int days);

  /// No description provided for @recapNoDate.
  ///
  /// In en, this message translates to:
  /// **'No estimate yet: it starts the day you log a period.'**
  String get recapNoDate;

  /// No description provided for @recapFertilityOn.
  ///
  /// In en, this message translates to:
  /// **'The estimated fertile window is shown. An estimate: neither contraception nor a diagnosis.'**
  String get recapFertilityOn;

  /// No description provided for @recapFertilityHormonal.
  ///
  /// In en, this message translates to:
  /// **'The ovulation estimate is hidden: it means nothing with a hormonal contraception.'**
  String get recapFertilityHormonal;

  /// No description provided for @recapFertilityOff.
  ///
  /// In en, this message translates to:
  /// **'The estimated fertile window is hidden. You can turn it on in the settings.'**
  String get recapFertilityOff;

  /// No description provided for @recapJournal.
  ///
  /// In en, this message translates to:
  /// **'Your journal starts with: {items}.'**
  String recapJournal(String items);

  /// No description provided for @recapChanges.
  ///
  /// In en, this message translates to:
  /// **'The review follows what changes from one cycle to the next.'**
  String get recapChanges;

  /// No description provided for @recapRemindersOn.
  ///
  /// In en, this message translates to:
  /// **'Reminders are on.'**
  String get recapRemindersOn;

  /// No description provided for @recapRemindersOff.
  ///
  /// In en, this message translates to:
  /// **'Reminders are off. You can turn them on in the settings.'**
  String get recapRemindersOff;

  /// No description provided for @recapLockOn.
  ///
  /// In en, this message translates to:
  /// **'The app is locked when it opens.'**
  String get recapLockOn;

  /// No description provided for @changeSignsList.
  ///
  /// In en, this message translates to:
  /// **'In the last 90 days: {signs}.'**
  String changeSignsList(String signs);

  /// No description provided for @changeSignDays.
  ///
  /// In en, this message translates to:
  /// **'{sign} ({days, plural, =1{1 day} other{{days} days}})'**
  String changeSignDays(String sign, int days);

  /// No description provided for @changeStartSigns.
  ///
  /// In en, this message translates to:
  /// **'Signs you named when you set the app up: {signs}.'**
  String changeStartSigns(String signs);

  /// No description provided for @followTitle.
  ///
  /// In en, this message translates to:
  /// **'Your tracking'**
  String get followTitle;

  /// No description provided for @followRow.
  ///
  /// In en, this message translates to:
  /// **'{name}: {days, plural, =0{no day} =1{1 day} other{{days} days}} out of the last 7'**
  String followRow(String name, int days);

  /// No description provided for @followWeek.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{No day logged out of the last 7} =1{1 day logged out of the last 7} other{{days} days logged out of the last 7}}'**
  String followWeek(int days);

  /// No description provided for @followMonth.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{This month: no day logged out of {total}} =1{This month: 1 day logged out of {total}} other{This month: {days} days logged out of {total}}}'**
  String followMonth(int days, int total);

  /// No description provided for @figureGoodNights.
  ///
  /// In en, this message translates to:
  /// **'Good nights'**
  String get figureGoodNights;

  /// No description provided for @figurePainDays.
  ///
  /// In en, this message translates to:
  /// **'Days with pain'**
  String get figurePainDays;

  /// No description provided for @reliabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Reliability of the estimate'**
  String get reliabilityTitle;

  /// No description provided for @reliabilityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get reliabilityLow;

  /// No description provided for @reliabilityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get reliabilityMedium;

  /// No description provided for @reliabilityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get reliabilityHigh;

  /// No description provided for @reliabilityNone.
  ///
  /// In en, this message translates to:
  /// **'Log the first day of a period to get an estimate.'**
  String get reliabilityNone;

  /// No description provided for @reliabilityToMedium.
  ///
  /// In en, this message translates to:
  /// **'{cycles, plural, =1{1 more logged cycle before it can reach medium.} other{{cycles} more logged cycles before it can reach medium.}}'**
  String reliabilityToMedium(int cycles);

  /// No description provided for @reliabilityToHigh.
  ///
  /// In en, this message translates to:
  /// **'{cycles, plural, =1{1 more logged cycle before it can reach high.} other{{cycles} more logged cycles before it can reach high.}}'**
  String reliabilityToHigh(int cycles);

  /// No description provided for @reliabilityHeldByVariation.
  ///
  /// In en, this message translates to:
  /// **'Your cycles differ from one another: it will rise if they come closer. Nothing to do with how you log.'**
  String get reliabilityHeldByVariation;

  /// No description provided for @reliabilityAtTop.
  ///
  /// In en, this message translates to:
  /// **'The highest level: it holds as long as your cycles stay alike.'**
  String get reliabilityAtTop;

  /// No description provided for @setupNotGiven.
  ///
  /// In en, this message translates to:
  /// **'Not given'**
  String get setupNotGiven;

  /// No description provided for @changeMoreRegular.
  ///
  /// In en, this message translates to:
  /// **'My periods are more regular'**
  String get changeMoreRegular;

  /// No description provided for @changeLonger.
  ///
  /// In en, this message translates to:
  /// **'My periods last longer'**
  String get changeLonger;

  /// No description provided for @changeShorter.
  ///
  /// In en, this message translates to:
  /// **'My periods are shorter'**
  String get changeShorter;

  /// No description provided for @changeMorePainful.
  ///
  /// In en, this message translates to:
  /// **'My periods are more painful'**
  String get changeMorePainful;

  /// No description provided for @changeLessPainful.
  ///
  /// In en, this message translates to:
  /// **'My periods are less painful'**
  String get changeLessPainful;

  /// No description provided for @changeSaidMoreRegular.
  ///
  /// In en, this message translates to:
  /// **'more regular periods'**
  String get changeSaidMoreRegular;

  /// No description provided for @changeSaidLonger.
  ///
  /// In en, this message translates to:
  /// **'longer periods'**
  String get changeSaidLonger;

  /// No description provided for @changeSaidShorter.
  ///
  /// In en, this message translates to:
  /// **'shorter periods'**
  String get changeSaidShorter;

  /// No description provided for @changeSaidMorePainful.
  ///
  /// In en, this message translates to:
  /// **'more painful periods'**
  String get changeSaidMorePainful;

  /// No description provided for @changeSaidLessPainful.
  ///
  /// In en, this message translates to:
  /// **'less painful periods'**
  String get changeSaidLessPainful;

  /// No description provided for @symptomMigraine.
  ///
  /// In en, this message translates to:
  /// **'Migraine'**
  String get symptomMigraine;

  /// No description provided for @symptomMoodSwings.
  ///
  /// In en, this message translates to:
  /// **'Mood swings'**
  String get symptomMoodSwings;

  /// No description provided for @setupRemindersHint.
  ///
  /// In en, this message translates to:
  /// **'Discreet: they never mention your period. Everything happens on your phone.'**
  String get setupRemindersHint;

  /// No description provided for @setupPeriodReminder.
  ///
  /// In en, this message translates to:
  /// **'Tell me before my period'**
  String get setupPeriodReminder;

  /// No description provided for @setupPeriodReminderHint.
  ///
  /// In en, this message translates to:
  /// **'A few days before the estimated date.'**
  String get setupPeriodReminderHint;

  /// No description provided for @setupDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Remind me to log my day'**
  String get setupDailyReminder;

  /// No description provided for @setupDailyReminderHint.
  ///
  /// In en, this message translates to:
  /// **'Once a day, only if you logged nothing.'**
  String get setupDailyReminderHint;

  /// No description provided for @cycleFirstHalf.
  ///
  /// In en, this message translates to:
  /// **'You are in the first half of your cycle.'**
  String get cycleFirstHalf;

  /// No description provided for @cycleSecondHalf.
  ///
  /// In en, this message translates to:
  /// **'You are in the second half of your cycle.'**
  String get cycleSecondHalf;

  /// No description provided for @legendToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get legendToday;

  /// No description provided for @kpiWeek.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get kpiWeek;

  /// No description provided for @kpiWeekCaption.
  ///
  /// In en, this message translates to:
  /// **'days logged'**
  String get kpiWeekCaption;

  /// No description provided for @kpiCycle.
  ///
  /// In en, this message translates to:
  /// **'This cycle'**
  String get kpiCycle;

  /// No description provided for @kpiCycleCaption.
  ///
  /// In en, this message translates to:
  /// **'days logged out of {days}'**
  String kpiCycleCaption(int days);

  /// No description provided for @kpiThisCycle.
  ///
  /// In en, this message translates to:
  /// **'this cycle'**
  String get kpiThisCycle;

  /// No description provided for @kpiPrevious.
  ///
  /// In en, this message translates to:
  /// **'previous cycle: {value}'**
  String kpiPrevious(String value);

  /// No description provided for @kpiMostFrequent.
  ///
  /// In en, this message translates to:
  /// **'most frequent this cycle'**
  String get kpiMostFrequent;

  /// No description provided for @weekTitle.
  ///
  /// In en, this message translates to:
  /// **'Your last 7 days'**
  String get weekTitle;

  /// No description provided for @weekIntro.
  ///
  /// In en, this message translates to:
  /// **'A full dot: logged that day.'**
  String get weekIntro;

  /// No description provided for @weekAnyNote.
  ///
  /// In en, this message translates to:
  /// **'The day'**
  String get weekAnyNote;

  /// No description provided for @setupProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you at?'**
  String get setupProfileTitle;

  /// No description provided for @setupProfileHint.
  ///
  /// In en, this message translates to:
  /// **'The app adapts to your answer. You can change it at any time in the settings.'**
  String get setupProfileHint;

  /// No description provided for @profileDiscovering.
  ///
  /// In en, this message translates to:
  /// **'I am discovering my cycle'**
  String get profileDiscovering;

  /// No description provided for @profileDiscoveringDetail.
  ///
  /// In en, this message translates to:
  /// **'My first periods, or I am starting to track them.'**
  String get profileDiscoveringDetail;

  /// No description provided for @profileTracking.
  ///
  /// In en, this message translates to:
  /// **'I track my periods'**
  String get profileTracking;

  /// No description provided for @profileTrackingDetail.
  ///
  /// In en, this message translates to:
  /// **'Know when they come and log my days.'**
  String get profileTrackingDetail;

  /// No description provided for @profileConceiving.
  ///
  /// In en, this message translates to:
  /// **'I am trying to conceive'**
  String get profileConceiving;

  /// No description provided for @profileConceivingDetail.
  ///
  /// In en, this message translates to:
  /// **'Find my estimated fertile window.'**
  String get profileConceivingDetail;

  /// No description provided for @profilePregnant.
  ///
  /// In en, this message translates to:
  /// **'I am pregnant'**
  String get profilePregnant;

  /// No description provided for @profilePregnantDetail.
  ///
  /// In en, this message translates to:
  /// **'Count the weeks and log my days.'**
  String get profilePregnantDetail;

  /// No description provided for @profilePostpartum.
  ///
  /// In en, this message translates to:
  /// **'I gave birth'**
  String get profilePostpartum;

  /// No description provided for @profilePostpartumDetail.
  ///
  /// In en, this message translates to:
  /// **'Waiting for my periods to come back.'**
  String get profilePostpartumDetail;

  /// No description provided for @profilePerimenopause.
  ///
  /// In en, this message translates to:
  /// **'My cycle is changing'**
  String get profilePerimenopause;

  /// No description provided for @profilePerimenopauseDetail.
  ///
  /// In en, this message translates to:
  /// **'Perimenopause: follow what moves.'**
  String get profilePerimenopauseDetail;

  /// No description provided for @setupPregnancyDateHint.
  ///
  /// In en, this message translates to:
  /// **'The weeks of pregnancy are counted from that day. An approximate date is enough.'**
  String get setupPregnancyDateHint;

  /// No description provided for @setupBirthDateTitle.
  ///
  /// In en, this message translates to:
  /// **'When did you give birth?'**
  String get setupBirthDateTitle;

  /// No description provided for @setupBirthDateHint.
  ///
  /// In en, this message translates to:
  /// **'To count the weeks since the birth, and start afresh when your periods come back.'**
  String get setupBirthDateHint;

  /// No description provided for @setupChooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose the date'**
  String get setupChooseDate;

  /// No description provided for @changeDate.
  ///
  /// In en, this message translates to:
  /// **'Change the date'**
  String get changeDate;

  /// No description provided for @pregnancyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your pregnancy'**
  String get pregnancyTitle;

  /// No description provided for @pregnancyWeeks.
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, =0{0 weeks} =1{1 week} other{{weeks} weeks}} and {days, plural, =0{0 days} =1{1 day} other{{days} days}}'**
  String pregnancyWeeks(int weeks, int days);

  /// No description provided for @pregnancyCounted.
  ///
  /// In en, this message translates to:
  /// **'counted from the first day of your last period'**
  String get pregnancyCounted;

  /// No description provided for @pregnancyTerm.
  ///
  /// In en, this message translates to:
  /// **'A birth at term is estimated between {from} and {to}.'**
  String pregnancyTerm(String from, String to);

  /// No description provided for @pregnancyNote.
  ///
  /// In en, this message translates to:
  /// **'An estimate: only a dating scan gives a reliable date.'**
  String get pregnancyNote;

  /// No description provided for @pregnancyNoDate.
  ///
  /// In en, this message translates to:
  /// **'Give the first day of your last period to count the weeks.'**
  String get pregnancyNoDate;

  /// No description provided for @pregnancyPast.
  ///
  /// In en, this message translates to:
  /// **'More than 42 weeks have gone by since that date. You can change the date or leave the pregnancy mode.'**
  String get pregnancyPast;

  /// No description provided for @pregnancyPaused.
  ///
  /// In en, this message translates to:
  /// **'The estimate of your periods is paused.'**
  String get pregnancyPaused;

  /// No description provided for @pregnancyLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave the pregnancy mode'**
  String get pregnancyLeave;

  /// No description provided for @leaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you at now?'**
  String get leaveTitle;

  /// No description provided for @leaveGaveBirth.
  ///
  /// In en, this message translates to:
  /// **'I gave birth'**
  String get leaveGaveBirth;

  /// No description provided for @leaveBackToCycle.
  ///
  /// In en, this message translates to:
  /// **'Go back to tracking my cycle'**
  String get leaveBackToCycle;

  /// No description provided for @postpartumTitle.
  ///
  /// In en, this message translates to:
  /// **'After the birth'**
  String get postpartumTitle;

  /// No description provided for @postpartumWeeks.
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, =0{Less than a week} =1{1 week} other{{weeks} weeks}} since you gave birth'**
  String postpartumWeeks(int weeks);

  /// No description provided for @postpartumBody.
  ///
  /// In en, this message translates to:
  /// **'When periods come back varies a lot from one woman to another. Log their first day when they do: the estimate will start again from there.'**
  String get postpartumBody;

  /// No description provided for @postpartumNoDate.
  ///
  /// In en, this message translates to:
  /// **'Give the date of the birth to count the weeks.'**
  String get postpartumNoDate;

  /// No description provided for @recapPregnancy.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy mode: the weeks are counted, the estimate of your periods is paused.'**
  String get recapPregnancy;

  /// No description provided for @recapPostpartum.
  ///
  /// In en, this message translates to:
  /// **'After the birth: the estimate will start again when your periods come back.'**
  String get recapPostpartum;
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
