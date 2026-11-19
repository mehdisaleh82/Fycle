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

  /// No description provided for @onboardingToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get onboardingToday;

  /// No description provided for @onboardingYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get onboardingYesterday;

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

  /// No description provided for @suggestFertilityTitle.
  ///
  /// In en, this message translates to:
  /// **'See an ovulation estimate?'**
  String get suggestFertilityTitle;

  /// No description provided for @suggestFertilityBody.
  ///
  /// In en, this message translates to:
  /// **'A calendar estimate of your fertile window, always shown as a range.'**
  String get suggestFertilityBody;

  /// No description provided for @suggestReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'A daily reminder to log?'**
  String get suggestReminderTitle;

  /// No description provided for @suggestReminderBody.
  ///
  /// In en, this message translates to:
  /// **'One discreet notification a day, skipped when the day is already logged.'**
  String get suggestReminderBody;

  /// No description provided for @suggestNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get suggestNotNow;

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

  /// No description provided for @suggestLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Lock Fycle with Face ID or your passcode?'**
  String get suggestLockTitle;

  /// No description provided for @suggestLockBody.
  ///
  /// In en, this message translates to:
  /// **'Like a diary with a key: asked each time Fycle opens.'**
  String get suggestLockBody;

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
