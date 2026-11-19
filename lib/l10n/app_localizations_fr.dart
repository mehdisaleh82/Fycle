// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Fycle';

  @override
  String get disclaimer =>
      'Fycle est un outil d\'information. Ce n\'est ni un avis médical ni une méthode de contraception.';

  @override
  String get privacyLine => 'Aucun compte. Rien ne quitte ce téléphone.';

  @override
  String get cancel => 'Annuler';

  @override
  String get done => 'Terminé';

  @override
  String get save => 'Enregistrer';

  @override
  String get errorGeneric =>
      'Une erreur s\'est produite. Rien n\'a été modifié.';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get openingLabel => 'Ouverture';

  @override
  String get unreadableTitle => 'Vos données sont illisibles';

  @override
  String get unreadableBody =>
      'Ce téléphone contient des données Fycle, mais la clé qui les protège est absente. Cela arrive quand un téléphone est restauré depuis une sauvegarde : la clé ne quitte jamais le téléphone d\'origine. Ces données ne peuvent pas être récupérées.';

  @override
  String get unreadableStartFresh => 'Repartir de zéro';

  @override
  String get unreadableRestore => 'Restaurer un fichier de sauvegarde';

  @override
  String get unreadableConfirmTitle => 'Effacer les données illisibles ?';

  @override
  String get unreadableConfirmBody =>
      'Les données illisibles seront effacées de ce téléphone. Cette action est définitive.';

  @override
  String get erase => 'Effacer';

  @override
  String get onboardingTitle => 'Bienvenue dans Fycle';

  @override
  String get onboardingLastPeriodQuestion =>
      'Quand vos dernières règles ont-elles commencé ?';

  @override
  String get onboardingLastPeriodHint =>
      'Une date approximative suffit. Vous pourrez la corriger plus tard.';

  @override
  String get onboardingChooseDate => 'Choisir une date';

  @override
  String get onboardingCycleLengthQuestion =>
      'Combien de temps dure votre cycle d\'habitude ?';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get onboardingToday => 'Aujourd\'hui';

  @override
  String get onboardingYesterday => 'Hier';

  @override
  String get onboardingSkip => 'Je ne sais plus';

  @override
  String get onboardingRestore => 'J\'ai un fichier de sauvegarde';

  @override
  String get cycleLengthFieldLabel => 'Jours (facultatif)';

  @override
  String get cycleLengthHelper =>
      'Du premier jour des règles au premier jour des suivantes. Laissez vide si vous ne savez pas.';

  @override
  String cycleLengthError(int min, int max) {
    return 'Saisissez un nombre entre $min et $max.';
  }

  @override
  String get homeLogToday => 'Saisir aujourd\'hui';

  @override
  String get todayCardTitle => 'Règles aujourd\'hui';

  @override
  String get todayCardHint => 'Un appui enregistre. Un second appui annule.';

  @override
  String loggingStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Saisie $days jours de suite',
      one: 'Saisie 1 jour de suite',
    );
    return '$_temp0';
  }

  @override
  String get settingsTooltip => 'Réglages';

  @override
  String get statusNoDataTitle => 'Pas encore d\'estimation';

  @override
  String get statusNoDataBody =>
      'Saisissez le premier jour de vos règles pour obtenir une estimation.';

  @override
  String statusOngoing(int day) {
    return 'Jour $day de vos règles';
  }

  @override
  String statusNextRange(String start, String end) {
    return 'Prochaines règles prévues entre le $start et le $end';
  }

  @override
  String statusExpectedRange(String start, String end) {
    return 'Règles prévues entre le $start et le $end';
  }

  @override
  String statusExpectedIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Cette période commence dans $days jours.',
      one: 'Cette période commence demain.',
    );
    return '$_temp0';
  }

  @override
  String get statusDue => 'Aujourd\'hui se situe dans cette période.';

  @override
  String statusLate(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Cette période est passée depuis $days jours.',
      one: 'Cette période est passée depuis 1 jour.',
    );
    return '$_temp0';
  }

  @override
  String get statusLateNote =>
      'Les cycles varient d\'un mois à l\'autre. Ce n\'est qu\'une estimation.';

  @override
  String get statusOutdatedTitle => 'Aucune saisie récente';

  @override
  String get statusOutdatedBody =>
      'Saisissez vos règles pour obtenir une nouvelle estimation.';

  @override
  String estimateBasisCycles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Estimation fondée sur vos $count derniers cycles.',
      one: 'Estimation fondée sur votre dernier cycle.',
    );
    return '$_temp0';
  }

  @override
  String estimateBasisDeclared(int days) {
    return 'Estimation fondée sur la durée habituelle indiquée ($days jours). Elle s\'ajustera au fil de vos saisies.';
  }

  @override
  String estimateBasisDefault(int days) {
    return 'Estimation fondée sur un cycle de $days jours. Elle s\'ajustera au fil de vos saisies.';
  }

  @override
  String get confidenceLow => 'Fiabilité : faible';

  @override
  String get confidenceMedium => 'Fiabilité : moyenne';

  @override
  String get confidenceHigh => 'Fiabilité : élevée';

  @override
  String get calendarPreviousMonth => 'Mois précédent';

  @override
  String get calendarNextMonth => 'Mois suivant';

  @override
  String get legendPeriod => 'Règles';

  @override
  String get legendExpected => 'Règles prévues (estimation)';

  @override
  String get legendEntry => 'Autre saisie';

  @override
  String get calendarDayToday => 'aujourd\'hui';

  @override
  String get calendarDayPeriod => 'règles saisies';

  @override
  String get calendarDaySpotting => 'traces saisies';

  @override
  String get calendarDayExpected => 'règles prévues, estimation';

  @override
  String get calendarDayEntry => 'saisie enregistrée';

  @override
  String get dayFlowTitle => 'Règles';

  @override
  String get dayPainTitle => 'Douleur';

  @override
  String get dayMoodTitle => 'Humeur';

  @override
  String get daySymptomsTitle => 'Symptômes';

  @override
  String get daySleepTitle => 'Sommeil';

  @override
  String get dayLibidoTitle => 'Libido';

  @override
  String get sleepPoor => 'Mauvais';

  @override
  String get sleepFair => 'Moyen';

  @override
  String get sleepGood => 'Bon';

  @override
  String get libidoLow => 'Basse';

  @override
  String get libidoMedium => 'Moyenne';

  @override
  String get libidoHigh => 'Haute';

  @override
  String get dayNoteLabel => 'Note';

  @override
  String get dayNoteHint => 'Ce que vous voulez retenir';

  @override
  String get daySavedHint =>
      'Enregistré automatiquement, sur ce téléphone uniquement.';

  @override
  String get flowSpotting => 'Traces';

  @override
  String get flowLight => 'Légères';

  @override
  String get flowMedium => 'Moyennes';

  @override
  String get flowHeavy => 'Abondantes';

  @override
  String get painNone => 'Aucune';

  @override
  String get painMild => 'Légère';

  @override
  String get painModerate => 'Modérée';

  @override
  String get painSevere => 'Forte';

  @override
  String get moodHappy => 'Joie';

  @override
  String get moodCalm => 'Calme';

  @override
  String get moodSad => 'Tristesse';

  @override
  String get moodAnxious => 'Anxiété';

  @override
  String get moodIrritable => 'Irritabilité';

  @override
  String get symptomCramps => 'Crampes';

  @override
  String get symptomHeadache => 'Maux de tête';

  @override
  String get symptomBackPain => 'Mal de dos';

  @override
  String get symptomBreastTenderness => 'Seins sensibles';

  @override
  String get symptomBloating => 'Ballonnements';

  @override
  String get symptomNausea => 'Nausées';

  @override
  String get symptomFatigue => 'Fatigue';

  @override
  String get symptomAcne => 'Acné';

  @override
  String get symptomCravings => 'Fringales';

  @override
  String get symptomInsomnia => 'Insomnie';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsCycleSection => 'Cycle';

  @override
  String get settingsCycleLength => 'Durée habituelle du cycle';

  @override
  String settingsCycleLengthValue(int days) {
    return '$days jours';
  }

  @override
  String get settingsCycleLengthUnknown => 'Non renseignée';

  @override
  String get settingsDataSection => 'Vos données';

  @override
  String get settingsExport => 'Enregistrer une sauvegarde chiffrée';

  @override
  String get settingsExportSubtitle =>
      'Un fichier protégé par un mot de passe, à ranger où vous voulez.';

  @override
  String get settingsImport => 'Restaurer une sauvegarde';

  @override
  String get settingsImportSubtitle =>
      'Remplace tout le contenu de Fycle sur ce téléphone.';

  @override
  String get settingsCsv => 'Exporter pour un tableur (CSV)';

  @override
  String get settingsCsvSubtitle => 'Un fichier lisible, non chiffré.';

  @override
  String get settingsDelete => 'Tout supprimer';

  @override
  String get settingsDeleteSubtitle =>
      'Efface toutes vos données de ce téléphone.';

  @override
  String get settingsAboutSection => 'À propos';

  @override
  String get exportTitle => 'Sauvegarde chiffrée';

  @override
  String get exportWarning =>
      'Si vous oubliez ce mot de passe, personne ne pourra ouvrir le fichier, jamais. Il n\'existe aucun moyen de le récupérer. Notez-le en lieu sûr.';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get passwordConfirmLabel => 'Répétez le mot de passe';

  @override
  String passwordTooShort(int min) {
    return 'Au moins $min caractères.';
  }

  @override
  String get passwordMismatch => 'Les deux mots de passe sont différents.';

  @override
  String get exportAction => 'Créer le fichier';

  @override
  String get exportDone => 'Sauvegarde enregistrée.';

  @override
  String get importReplaceTitle => 'Tout remplacer ?';

  @override
  String get importReplaceBody =>
      'Restaurer une sauvegarde remplace tout ce que Fycle contient sur ce téléphone.';

  @override
  String get importReplaceAction => 'Remplacer';

  @override
  String get importPasswordTitle => 'Mot de passe de la sauvegarde';

  @override
  String get importAction => 'Restaurer';

  @override
  String get importDone => 'Sauvegarde restaurée.';

  @override
  String get importErrorNotBackup =>
      'Ce fichier n\'est pas une sauvegarde Fycle. Rien n\'a été modifié.';

  @override
  String get importErrorVersion =>
      'Cette sauvegarde vient d\'une version plus récente de Fycle. Mettez l\'appli à jour, puis réessayez.';

  @override
  String get importErrorWrong =>
      'Mot de passe incorrect, ou fichier abîmé. Rien n\'a été modifié.';

  @override
  String get csvWarningTitle => 'Fichier non chiffré';

  @override
  String get csvWarningBody =>
      'Ce fichier n\'est pas chiffré : toute personne qui l\'obtient peut le lire. Rangez-le dans un endroit de confiance.';

  @override
  String get csvAction => 'Exporter';

  @override
  String get csvDone => 'Fichier enregistré.';

  @override
  String get csvDateHeader => 'Date';

  @override
  String get deleteTitle => 'Tout supprimer ?';

  @override
  String get deleteBody =>
      'Toutes vos données seront effacées de ce téléphone, définitivement. Pour en garder une copie, enregistrez d\'abord une sauvegarde.';

  @override
  String get deleteAction => 'Tout supprimer';

  @override
  String get ok => 'OK';

  @override
  String get settingsRemindersSection => 'Rappels';

  @override
  String get reminderPeriodTitle => 'Règles qui approchent';

  @override
  String get reminderPeriodSubtitle =>
      'Une notification quelques jours avant la période estimée.';

  @override
  String get reminderDaysBeforeTitle => 'Combien de temps avant';

  @override
  String reminderDaysBefore(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours avant',
      one: '1 jour avant',
    );
    return '$_temp0';
  }

  @override
  String get reminderTime => 'Heure';

  @override
  String get reminderDailyTitle => 'Rappel de saisie quotidien';

  @override
  String get reminderDailySubtitle =>
      'Une notification par jour, sauf si la journée est déjà notée.';

  @override
  String get reminderDiscreetNote =>
      'Les notifications restent discrètes : elles ne mentionnent jamais votre cycle. Elles sont programmées sur ce téléphone, sans aucun serveur.';

  @override
  String get reminderPermissionTitle => 'Notifications désactivées';

  @override
  String get reminderPermissionBody =>
      'Fycle n\'est pas autorisée à afficher des notifications. Vous pouvez les autoriser dans les réglages de votre téléphone, puis activer ce rappel.';

  @override
  String get notificationPeriodBody => 'Un coup d\'œil à votre calendrier ?';

  @override
  String get notificationDailyBody => 'Un moment pour noter votre journée ?';

  @override
  String get notificationChannelName => 'Rappels';

  @override
  String get settingsPrivacySection => 'Confidentialité';

  @override
  String get lockTitle => 'Verrouiller Fycle';

  @override
  String get lockSubtitle =>
      'Face ID, empreinte ou code de ce téléphone, à chaque ouverture de Fycle.';

  @override
  String get lockUnavailableTitle => 'Aucun code sur ce téléphone';

  @override
  String get lockUnavailableBody =>
      'Fycle s\'appuie sur le verrouillage de votre téléphone. Définissez d\'abord un code dans les réglages du téléphone.';

  @override
  String get lockReason => 'Déverrouiller Fycle';

  @override
  String get lockScreenTitle => 'Fycle est verrouillée';

  @override
  String get lockScreenUnlock => 'Déverrouiller';

  @override
  String get settingsAppearanceSection => 'Apparence';

  @override
  String get settingsAppearance => 'Thème';

  @override
  String get appearanceLight => 'Clair';

  @override
  String get appearanceDark => 'Sombre';

  @override
  String get appearanceSystem => 'Comme le téléphone';

  @override
  String get insightsTitle => 'Bilan';

  @override
  String get insightsCyclesTitle => 'Vos cycles';

  @override
  String insightsAverageCycle(String days) {
    return 'Cycle moyen : $days jours';
  }

  @override
  String insightsAveragePeriod(String days) {
    return 'Règles : $days jours en moyenne';
  }

  @override
  String insightsAverageBasis(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Calculé sur vos $count derniers cycles complets.',
      one: 'Calculé sur votre dernier cycle complet.',
    );
    return '$_temp0';
  }

  @override
  String get insightsNoCycleYet =>
      'Les moyennes apparaissent dès que de secondes règles sont saisies.';

  @override
  String get insightsTrendsTitle => 'Ce qui revient';

  @override
  String get insightsTrendsEmpty =>
      'Rien à afficher pour l\'instant. Une ligne apparaît ici quand la même chose est notée au même moment dans au moins deux cycles complets.';

  @override
  String get insightsTrendsNote =>
      'Ces lignes comptent ce que vous avez noté. Ce sont des observations, pas une interprétation médicale.';

  @override
  String trendDuringPeriod(int count, int total) {
    return 'Pendant les règles, dans $count de vos $total derniers cycles';
  }

  @override
  String trendBeforePeriod(int count, int total) {
    return 'La semaine avant les règles, dans $count de vos $total derniers cycles';
  }

  @override
  String trendRest(int count, int total) {
    return 'Le reste du cycle, dans $count de vos $total derniers cycles';
  }

  @override
  String signWithKind(String kind, String value) {
    return '$kind : $value';
  }

  @override
  String get insightsHistoryTitle => 'Historique';

  @override
  String get historyEmpty => 'Aucunes règles saisies pour l\'instant.';

  @override
  String historyCycleRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String historyCycleDetail(int days, int period) {
    String _temp0 = intl.Intl.pluralLogic(
      period,
      locale: localeName,
      other: '$days jours · règles de $period jours',
      one: '$days jours · règles de 1 jour',
    );
    return '$_temp0';
  }

  @override
  String historyCurrent(String start) {
    return 'En cours depuis le $start';
  }

  @override
  String get historyUnusual =>
      'Durée inhabituelle, non comptée dans les moyennes.';

  @override
  String get summaryTitle => 'Votre dernier cycle';

  @override
  String summaryLength(int days) {
    return 'Il a duré $days jours.';
  }

  @override
  String summaryLonger(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours de plus que vos cycles précédents.',
      one: '1 jour de plus que vos cycles précédents.',
    );
    return '$_temp0';
  }

  @override
  String summaryShorter(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours de moins que vos cycles précédents.',
      one: '1 jour de moins que vos cycles précédents.',
    );
    return '$_temp0';
  }

  @override
  String get summarySame => 'Comme vos cycles précédents.';

  @override
  String summaryMostLogged(String symptoms) {
    return 'Le plus noté : $symptoms.';
  }

  @override
  String get listSeparator => ', ';

  @override
  String get summarySeeTrends => 'Voir les tendances';

  @override
  String get summaryClose => 'Fermer';

  @override
  String get fertilitySettingTitle => 'Estimation de l\'ovulation';

  @override
  String get fertilitySettingSubtitle =>
      'Affiche une fenêtre de fertilité estimée sur l\'accueil et dans le calendrier.';

  @override
  String get fertilityWarningTitle => 'Une estimation, rien de plus';

  @override
  String get fertilityWarning =>
      'Cette estimation est calculée à partir des dates de vos règles uniquement. Ce n\'est ni une méthode de contraception ni un diagnostic. Elle ne permet pas de savoir quels jours sont sans risque : l\'ovulation peut tomber en dehors des jours affichés.';

  @override
  String get fertilityTurnOn => 'Activer';

  @override
  String get fertilityCardTitle => 'Fenêtre de fertilité estimée';

  @override
  String fertilityWindowRange(String start, String end) {
    return 'Entre le $start et le $end';
  }

  @override
  String fertilityOvulationRange(String start, String end) {
    return 'Ovulation estimée entre le $start et le $end';
  }

  @override
  String get fertilityLowConfidence =>
      'Vos cycles varient beaucoup : cette estimation est peu fiable.';

  @override
  String get fertilityNotEnough =>
      'L\'estimation apparaît dès que deux cycles complets sont saisis.';

  @override
  String get fertilityHow => 'Comment c\'est calculé';

  @override
  String get fertilityHowBody =>
      'Fycle part de l\'estimation de vos prochaines règles et remonte d\'environ 14 jours, avec 2 jours de marge de chaque côté, pour situer l\'ovulation. La fenêtre couvre les 5 jours qui précèdent et le jour qui suit. Les cycles diffèrent d\'une personne à l\'autre et d\'un mois à l\'autre : ce sont des hypothèses, pas des mesures.';

  @override
  String get legendFertile => 'Fenêtre de fertilité (estimation)';

  @override
  String get calendarDayFertile => 'fenêtre de fertilité, estimation';

  @override
  String get tabHome => 'Accueil';

  @override
  String get tabCalendar => 'Calendrier';

  @override
  String get tabReview => 'Bilan';

  @override
  String get homeTooltip => 'Retour à l\'accueil';

  @override
  String get cycleDayCaption => 'Jour';

  @override
  String cycleDaySemantics(int day) {
    return 'Jour $day de votre cycle';
  }

  @override
  String countdownRange(int min, int max) {
    return 'Règles dans $min à $max jours';
  }

  @override
  String countdownDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Règles dans $days jours',
      one: 'Règles attendues dès demain',
      zero: 'Règles attendues dès aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String get countdownDue => 'Règles attendues ces jours-ci';

  @override
  String get figuresTitle => 'Vos chiffres';

  @override
  String get figureCycle => 'Cycle';

  @override
  String get figurePeriod => 'Règles';

  @override
  String get figureLogged => 'Jours saisis';

  @override
  String figureDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get figureUnknown => '–';

  @override
  String get sourceLogged => 'd\'après vos saisies';

  @override
  String get sourceDeclared => 'indiqué par vous';

  @override
  String get sourceAssumed => 'repère, à ajuster';

  @override
  String get sourceCurrent => 'pour l\'instant';

  @override
  String sourceCycles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cycles complets',
      one: '1 cycle complet',
      zero: 'aucun cycle complet',
    );
    return '$_temp0';
  }

  @override
  String get usualTitle => 'D\'habitude, vers ce jour';

  @override
  String usualLine(String sign, int count, int total) {
    return '$sign : dans $count de vos $total derniers cycles';
  }

  @override
  String get unlockTitle => 'Plus vous saisissez, plus vous en voyez';

  @override
  String get unlockIntro =>
      'Fycle calcule tout à partir de ce que vous notez. Chaque saisie rend vos chiffres plus justes.';

  @override
  String get unlockEstimate => 'Estimation de vos prochaines règles';

  @override
  String get unlockEstimateNeed => 'Dès vos premières règles saisies';

  @override
  String get unlockAverages => 'Durées moyennes du cycle et des règles';

  @override
  String get unlockAveragesNeed => 'Après un cycle complet';

  @override
  String get unlockTrends => 'Ce qui revient, et l\'estimation de l\'ovulation';

  @override
  String get unlockTrendsNeed => 'Après deux cycles complets';

  @override
  String get unlockReliable => 'Une estimation plus étroite et plus fiable';

  @override
  String get unlockReliableNeed => 'Avec quatre cycles réguliers ou plus';

  @override
  String unlockProgress(int have, int need) {
    return '$have sur $need';
  }

  @override
  String get unlockReached => 'Disponible';

  @override
  String unlockOverall(int reached, int total) {
    return '$reached sur $total disponibles';
  }

  @override
  String get todayEntryTitle => 'Aujourd\'hui';

  @override
  String todayEntryProgress(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      done,
      locale: localeName,
      other: '$done rubriques sur $total remplies aujourd\'hui',
      one: '1 rubrique sur $total remplie aujourd\'hui',
      zero: 'Aucune rubrique sur $total remplie aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String get calendarHint => 'Touchez un jour pour le saisir ou le corriger.';

  @override
  String get reportTitle => 'Ce cycle';

  @override
  String reportStarted(String date) {
    return 'Commencé le $date';
  }

  @override
  String reportPeriod(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Règles : $days jours',
      one: 'Règles : 1 jour',
    );
    return '$_temp0';
  }

  @override
  String reportLogged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours saisis dans ce cycle',
      one: '1 jour saisi dans ce cycle',
      zero: 'Rien de saisi dans ce cycle',
    );
    return '$_temp0';
  }

  @override
  String reportPainDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Douleur $count jours',
      one: 'Douleur 1 jour',
    );
    return '$_temp0';
  }

  @override
  String reportPoorSleep(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mauvais sommeil $count nuits',
      one: 'Mauvais sommeil 1 nuit',
    );
    return '$_temp0';
  }

  @override
  String get reportEmpty =>
      'Saisissez le premier jour de vos règles pour commencer votre bilan.';

  @override
  String get onboardingIntro1 =>
      'Notez vos règles et ce que vous ressentez, en quelques appuis.';

  @override
  String get onboardingIntro2 =>
      'Voyez vos chiffres : jour du cycle, estimation des prochaines règles, ce qui revient.';

  @override
  String get onboardingIntro3 => 'Plus vous saisissez, plus c\'est juste.';

  @override
  String get onboardingEarlierTitle => 'Règles précédentes (facultatif)';

  @override
  String get onboardingEarlierHint =>
      'Ajoutez le premier jour d\'une ou deux règles précédentes : vos moyennes et vos tendances arrivent plus vite.';

  @override
  String get onboardingAddEarlier => 'Ajouter des règles précédentes';

  @override
  String onboardingRemoveDate(String date) {
    return 'Retirer le $date';
  }

  @override
  String get suggestFertilityTitle => 'Voir une estimation de l\'ovulation ?';

  @override
  String get suggestFertilityBody =>
      'Une estimation de votre fenêtre de fertilité, calculée sur le calendrier et toujours donnée en fourchette.';

  @override
  String get suggestReminderTitle => 'Un rappel quotidien pour saisir ?';

  @override
  String get suggestReminderBody =>
      'Une notification discrète par jour, sauf si la journée est déjà notée.';

  @override
  String get suggestNotNow => 'Plus tard';

  @override
  String get tabJournal => 'Journal';

  @override
  String get tabHomeHint => 'Vos chiffres du jour et la saisie rapide.';

  @override
  String get tabJournalHint =>
      'Votre calendrier et vos pages, jour après jour.';

  @override
  String get tabReviewHint =>
      'Vos moyennes, ce qui revient et votre historique.';

  @override
  String get tabSettingsHint =>
      'Rappels, confidentialité, sauvegarde et vos données.';

  @override
  String get journalPagesTitle => 'Vos dernières pages';

  @override
  String get journalEmpty =>
      'Rien d\'écrit pour l\'instant. Votre première page commence aujourd\'hui.';

  @override
  String get journalWriteToday => 'Écrire la page d\'aujourd\'hui';

  @override
  String get todayNoteTitle => 'Votre note';

  @override
  String get suggestLockTitle => 'Verrouiller Fycle par Face ID ou par code ?';

  @override
  String get suggestLockBody =>
      'Comme un journal fermé à clé : demandé à chaque ouverture de Fycle.';

  @override
  String get fertilityShortWarning =>
      'Une estimation : ni contraception ni diagnostic.';

  @override
  String get homeGreeting => 'Bon retour';

  @override
  String get homeReassurance =>
      'Votre journal est privé. Il reste sur ce téléphone, et personne d\'autre ne peut le lire.';

  @override
  String figureReference(int days) {
    return 'repère : $days jours';
  }

  @override
  String referenceLine(int cycle, int period) {
    return 'Affiché pour l\'instant : un cycle de repère de $cycle jours, avec des règles de $period jours. Vos propres dates le remplaceront.';
  }

  @override
  String get referenceCaption => 'Repère';

  @override
  String get lockTurnedOff =>
      'Ce téléphone n\'a plus de code : le verrouillage de Fycle a été désactivé.';
}
