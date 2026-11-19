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
  String get unreadableTitle => 'Tes données sont illisibles';

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
      'Quand tes dernières règles ont-elles commencé ?';

  @override
  String get onboardingLastPeriodHint =>
      'Une date approximative suffit. Tu pourras la corriger plus tard.';

  @override
  String get onboardingChooseDate => 'Choisir une date';

  @override
  String get onboardingCycleLengthQuestion =>
      'Combien de temps dure ton cycle d\'habitude ?';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get onboardingToday => 'Aujourd\'hui';

  @override
  String get onboardingYesterday => 'Hier';

  @override
  String get onboardingSkip => 'Pas encore : je le noterai le jour venu';

  @override
  String get onboardingRestore => 'J\'ai un fichier de sauvegarde';

  @override
  String get cycleLengthFieldLabel => 'Jours (facultatif)';

  @override
  String get cycleLengthHelper =>
      'Du premier jour des règles au premier jour des suivantes. Laisse vide si tu ne sais pas.';

  @override
  String cycleLengthError(int min, int max) {
    return 'Saisis un nombre entre $min et $max.';
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
      'Saisis le premier jour de tes règles pour obtenir une estimation.';

  @override
  String statusOngoing(int day) {
    return 'Jour $day de tes règles';
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
      'Saisis tes règles pour obtenir une nouvelle estimation.';

  @override
  String estimateBasisCycles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Estimation fondée sur tes $count derniers cycles.',
      one: 'Estimation fondée sur ton dernier cycle.',
    );
    return '$_temp0';
  }

  @override
  String estimateBasisDeclared(int days) {
    return 'Estimation fondée sur la durée habituelle indiquée ($days jours). Elle s\'ajustera au fil de tes saisies.';
  }

  @override
  String estimateBasisDefault(int days) {
    return 'Estimation fondée sur un cycle de $days jours. Elle s\'ajustera au fil de tes saisies.';
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
  String get dayNoteHint => 'Ce que tu veux retenir';

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
  String get settingsDataSection => 'Tes données';

  @override
  String get settingsExport => 'Enregistrer une sauvegarde chiffrée';

  @override
  String get settingsExportSubtitle =>
      'Un fichier protégé par un mot de passe, à ranger où tu veux.';

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
      'Efface toutes tes données de ce téléphone.';

  @override
  String get settingsAboutSection => 'À propos';

  @override
  String get exportTitle => 'Sauvegarde chiffrée';

  @override
  String get exportWarning =>
      'Si tu oublies ce mot de passe, personne ne pourra ouvrir le fichier, jamais. Il n\'existe aucun moyen de le récupérer. Note-le en lieu sûr.';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get passwordConfirmLabel => 'Répète le mot de passe';

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
      'Cette sauvegarde vient d\'une version plus récente de Fycle. Mets l\'appli à jour, puis réessaie.';

  @override
  String get importErrorWrong =>
      'Mot de passe incorrect, ou fichier abîmé. Rien n\'a été modifié.';

  @override
  String get csvWarningTitle => 'Fichier non chiffré';

  @override
  String get csvWarningBody =>
      'Ce fichier n\'est pas chiffré : toute personne qui l\'obtient peut le lire. Range-le dans un endroit de confiance.';

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
      'Toutes tes données seront effacées de ce téléphone, définitivement. Pour en garder une copie, enregistre d\'abord une sauvegarde.';

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
      'Les notifications restent discrètes : elles ne mentionnent jamais ton cycle. Elles sont programmées sur ce téléphone, sans aucun serveur.';

  @override
  String get reminderPermissionTitle => 'Notifications désactivées';

  @override
  String get reminderPermissionBody =>
      'Fycle n\'est pas autorisée à afficher des notifications. Tu peux les autoriser dans les réglages de ton téléphone, puis activer ce rappel.';

  @override
  String get notificationPeriodBody => 'Un coup d\'œil à ton calendrier ?';

  @override
  String get notificationDailyBody => 'Un moment pour noter ta journée ?';

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
      'Fycle s\'appuie sur le verrouillage de ton téléphone. Définis d\'abord un code dans les réglages du téléphone.';

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
  String get insightsCyclesTitle => 'Tes cycles';

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
      other: 'Calculé sur tes $count derniers cycles complets.',
      one: 'Calculé sur ton dernier cycle complet.',
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
      'Ces lignes comptent ce que tu as noté. Ce sont des observations, pas une interprétation médicale.';

  @override
  String trendDuringPeriod(int count, int total) {
    return 'Pendant les règles, dans $count de tes $total derniers cycles';
  }

  @override
  String trendBeforePeriod(int count, int total) {
    return 'La semaine avant les règles, dans $count de tes $total derniers cycles';
  }

  @override
  String trendRest(int count, int total) {
    return 'Le reste du cycle, dans $count de tes $total derniers cycles';
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
  String get summaryTitle => 'Ton dernier cycle';

  @override
  String summaryLength(int days) {
    return 'Il a duré $days jours.';
  }

  @override
  String summaryLonger(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours de plus que tes cycles précédents.',
      one: '1 jour de plus que tes cycles précédents.',
    );
    return '$_temp0';
  }

  @override
  String summaryShorter(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours de moins que tes cycles précédents.',
      one: '1 jour de moins que tes cycles précédents.',
    );
    return '$_temp0';
  }

  @override
  String get summarySame => 'Comme tes cycles précédents.';

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
      'Cette estimation est calculée à partir des dates de tes règles uniquement. Ce n\'est ni une méthode de contraception ni un diagnostic. Elle ne permet pas de savoir quels jours sont sans risque : l\'ovulation peut tomber en dehors des jours affichés.';

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
      'Tes cycles varient beaucoup : cette estimation est peu fiable.';

  @override
  String get fertilityNotEnough =>
      'L\'estimation apparaît dès que deux cycles complets sont saisis.';

  @override
  String get fertilityHow => 'Comment c\'est calculé';

  @override
  String get fertilityHowBody =>
      'Fycle part de l\'estimation de tes prochaines règles et remonte d\'environ 13 jours, avec 3 jours de marge de chaque côté, pour situer l\'ovulation. La fenêtre couvre les 5 jours qui précèdent et le jour qui suit. Les cycles diffèrent d\'une personne à l\'autre et d\'un mois à l\'autre : ce sont des moyennes, pas des mesures de ton corps.';

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
    return 'Jour $day de ton cycle';
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
  String get figuresTitle => 'Tes chiffres';

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
  String get sourceLogged => 'd\'après tes saisies';

  @override
  String get sourceDeclared => 'indiqué par toi';

  @override
  String get sourceAssumed => 'estimation pour l\'instant';

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
    return '$sign : dans $count de tes $total derniers cycles';
  }

  @override
  String get unlockTitle => 'Plus tu saisis, plus tu en vois';

  @override
  String get unlockIntro =>
      'Fycle calcule tout à partir de ce que tu notes. Chaque saisie rend tes chiffres plus justes.';

  @override
  String get unlockEstimate => 'Estimation de tes prochaines règles';

  @override
  String get unlockEstimateNeed => 'Dès tes premières règles saisies';

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
  String get todayEntryTitle => 'Mon journal du jour';

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
  String get calendarHint => 'Touche un jour pour le saisir ou le corriger.';

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
      'Saisis le premier jour de tes règles pour commencer ton bilan.';

  @override
  String get onboardingIntro1 =>
      'Note tes règles et ce que tu ressens, en quelques appuis.';

  @override
  String get onboardingIntro2 =>
      'Vois tes chiffres : jour du cycle, estimation des prochaines règles, ce qui revient.';

  @override
  String get onboardingIntro3 => 'Plus tu saisis, plus c\'est juste.';

  @override
  String get onboardingEarlierTitle => 'Règles précédentes (facultatif)';

  @override
  String get onboardingEarlierHint =>
      'Ajoute le premier jour d\'une ou deux règles précédentes : tes moyennes et tes tendances arrivent plus vite.';

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
      'Une estimation de ta fenêtre de fertilité, calculée sur le calendrier et toujours donnée en fourchette.';

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
  String get tabHomeHint => 'Tes chiffres du jour et la saisie rapide.';

  @override
  String get tabJournalHint => 'Ton calendrier et tes pages, jour après jour.';

  @override
  String get tabReviewHint => 'Tes moyennes, ce qui revient et ton historique.';

  @override
  String get tabSettingsHint =>
      'Rappels, confidentialité, sauvegarde et tes données.';

  @override
  String get journalPagesTitle => 'Tes dernières pages';

  @override
  String get journalEmpty =>
      'Rien d\'écrit pour l\'instant. Ta première page commence aujourd\'hui.';

  @override
  String get journalWriteToday => 'Écrire la page d\'aujourd\'hui';

  @override
  String get todayNoteTitle => 'Ta note';

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
      'Ton journal est privé. Il reste sur ce téléphone, et personne d\'autre ne peut le lire.';

  @override
  String figureReference(int days) {
    return 'repère : $days jours';
  }

  @override
  String referenceLine(int cycle, int period) {
    return 'Affiché pour l\'instant : un cycle de repère de $cycle jours, avec des règles de $period jours. Tes propres dates le remplaceront.';
  }

  @override
  String get referenceCaption => 'Repère';

  @override
  String get studyCardTitle => 'Ce que disent les études';

  @override
  String get factExactly28 =>
      'Seuls 13 % environ des cycles durent exactement 28 jours.';

  @override
  String get factVariesMoreThan7 =>
      'Chez environ 4 femmes sur 10, la durée du cycle varie de plus de 7 jours d\'un cycle à l\'autre.';

  @override
  String get factRange22to36 =>
      '95 % des cycles mesurés ont duré entre 22 et 36 jours.';

  @override
  String get factShortensWithAge =>
      'Entre 25 et 45 ans, le cycle raccourcit d\'environ 0,18 jour par an.';

  @override
  String get factFirstPartVaries =>
      'C\'est la première partie du cycle, avant l\'ovulation, qui varie le plus. La seconde bouge peu.';

  @override
  String get factSixDayWindow =>
      'La conception n\'a été observée que dans les six jours qui se terminent le jour de l\'ovulation.';

  @override
  String get factFigoRanges =>
      'Un cycle de 24 à 38 jours et des règles de 8 jours au plus sont dans la plage habituelle retenue par les gynécologues.';

  @override
  String youMeanCycle(String days) {
    return 'Ton cycle moyen : $days jours.';
  }

  @override
  String youVariation(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          'Chez toi : $days jours d\'écart entre ton cycle le plus court et le plus long.',
      one: 'Chez toi : 1 jour d\'écart entre ton cycle le plus court et le plus long.',
      zero: 'Chez toi : tes cycles ont tous eu la même durée.',
    );
    return '$_temp0';
  }

  @override
  String youAgeReference(int age, int days) {
    return 'À $age ans, le cycle de repère est de $days jours.';
  }

  @override
  String get youAgeUnknown =>
      'Indique ton année de naissance dans les réglages pour partir d\'un repère plus proche de ton âge.';

  @override
  String youFollicular(int min, int max) {
    return 'La vôtre est estimée entre $min et $max jours.';
  }

  @override
  String youWindow(String start, String end) {
    return 'Ta fenêtre estimée : du $start au $end.';
  }

  @override
  String youFigo(String cycle, String period) {
    return 'Ton cycle : $cycle jours. Tes règles : $period jours.';
  }

  @override
  String get youNotYet => 'Saisis deux débuts de règles pour te situer.';

  @override
  String get sourcesTitle => 'Sources';

  @override
  String get sourcesIntro =>
      'Les chiffres de repère viennent de ces études publiées. Elles décrivent des groupes de femmes, pas toi : tes propres saisies prennent toujours le dessus.';

  @override
  String get sourceBull2019 =>
      'Bull et al., npj Digital Medicine, 2019. 612 613 cycles.';

  @override
  String get sourceFehring2006 =>
      'Fehring, Schneider et Raviele, 2006. 1 060 cycles.';

  @override
  String get sourceWilcox1995 =>
      'Wilcox, Weinberg et Baird, New England Journal of Medicine, 1995.';

  @override
  String get sourceFigo2018 =>
      'Munro, Critchley et Fraser pour la FIGO, International Journal of Gynecology & Obstetrics, 2018.';

  @override
  String get clinicalTitle => 'Fiche clinique';

  @override
  String get clinicalIntro =>
      'Ton journal, lu avec les quatre paramètres utilisés par les gynécologues.';

  @override
  String clinicalBasis(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Fondée sur $count cycles complets des 12 derniers mois.',
      one: 'Fondée sur 1 cycle complet des 12 derniers mois.',
    );
    return '$_temp0';
  }

  @override
  String get clinicalEmpty =>
      'Tes propres chiffres arrivent dès qu\'un premier cycle est terminé.';

  @override
  String get clinicalFrequency => 'Fréquence';

  @override
  String clinicalFrequencyValue(String days) {
    return 'Un cycle de $days jours en moyenne';
  }

  @override
  String get clinicalFrequencyRef => 'Plage habituelle : 24 à 38 jours';

  @override
  String get clinicalRegularity => 'Régularité';

  @override
  String clinicalRegularityValue(int min, int max, int variation) {
    String _temp0 = intl.Intl.pluralLogic(
      variation,
      locale: localeName,
      other: 'Des cycles de $min à $max jours, soit $variation jours d\'écart',
      one: 'Des cycles de $min à $max jours, soit 1 jour d\'écart',
      zero: 'Des cycles de $min jours, tous de la même durée',
    );
    return '$_temp0';
  }

  @override
  String clinicalRegularityRef(int limit) {
    return 'Habituel : jusqu\'à $limit jours d\'écart';
  }

  @override
  String get clinicalRegularityTooFew =>
      'Il faut trois cycles complets pour le dire.';

  @override
  String get clinicalDuration => 'Durée des règles';

  @override
  String clinicalDurationValue(String days, int max) {
    return '$days jours en moyenne, $max au plus';
  }

  @override
  String get clinicalDurationRef => 'Habituel : jusqu\'à 8 jours';

  @override
  String get clinicalVolume => 'Abondance';

  @override
  String get clinicalVolumeLight => 'Légère, d\'après tes saisies';

  @override
  String get clinicalVolumeModerate => 'Moyenne, d\'après tes saisies';

  @override
  String get clinicalVolumeHeavy => 'Abondante, d\'après tes saisies';

  @override
  String get clinicalPhases => 'Les deux parties du cycle (estimation)';

  @override
  String clinicalPhasesValue(int min, int max, int luteal) {
    return 'Avant l\'ovulation : $min à $max jours. Après : environ $luteal jours.';
  }

  @override
  String get clinicalSpotting => 'Traces entre les règles';

  @override
  String clinicalSpottingValue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours saisis',
      one: '1 jour saisi',
      zero: 'Aucune saisie',
    );
    return '$_temp0';
  }

  @override
  String get statusWithin => 'Dans la plage habituelle';

  @override
  String get statusOutside => 'Hors de la plage habituelle';

  @override
  String get clinicalOutsideNote =>
      'Une valeur hors de la plage habituelle n\'est pas un diagnostic. Cette fiche mérite d\'être montrée à un médecin.';

  @override
  String get clinicalSource => 'Plages de référence : FIGO, 2018.';

  @override
  String get birthYearLabel => 'Année de naissance (facultatif)';

  @override
  String get birthYearHelper =>
      'Sert à partir d\'un cycle de repère plus proche de ton âge. Elle reste sur ce téléphone.';

  @override
  String birthYearError(int min, int max) {
    return 'Saisis une année entre $min et $max.';
  }

  @override
  String get settingsBirthYear => 'Année de naissance';

  @override
  String get sourceAssumedAge => 'repère pour ton âge, à ajuster';

  @override
  String get settingsBirthYearUnknown => 'Non indiquée';

  @override
  String get doctorReportTitle => 'Rapport pour le médecin';

  @override
  String doctorReportIntro(String date) {
    return 'Établi le $date à partir de tes saisies. Il décrit et compare ; ce n\'est pas un diagnostic.';
  }

  @override
  String doctorReportAge(int age) {
    return 'Âge : $age ans';
  }

  @override
  String get clinicalToFill => 'Ton chiffre remplacera cette ligne';

  @override
  String get clinicalRegularityRefAny =>
      'Habituel : jusqu\'à 7 à 9 jours d\'écart, selon l\'âge';

  @override
  String get periodStartsToday => 'Mes règles commencent aujourd\'hui';

  @override
  String get comparisonTitle => 'Ce cycle et le précédent';

  @override
  String comparisonIntro(int day) {
    String _temp0 = intl.Intl.pluralLogic(
      day,
      locale: localeName,
      other: 'Tous deux pris sur leurs $day premiers jours.',
      one: 'Tous deux pris à leur premier jour.',
    );
    return '$_temp0';
  }

  @override
  String get comparisonPrevious => 'Précédent';

  @override
  String get comparisonPeriod => 'Jours de règles';

  @override
  String get comparisonPain => 'Jours de douleur';

  @override
  String get comparisonSleep => 'Nuits difficiles';

  @override
  String get comparisonLogged => 'Jours saisis';

  @override
  String comparisonRow(String label, int current, int previous) {
    return '$label : $current dans ce cycle, $previous dans le précédent';
  }

  @override
  String get monthsTitle => 'Ton historique, mois par mois';

  @override
  String get monthsIntro =>
      'Tout se joue ici : plus tes mois sont remplis, plus tes estimations sont justes.';

  @override
  String monthLogged(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours saisis',
      one: '1 jour saisi',
      zero: 'Rien de saisi',
    );
    return '$_temp0';
  }

  @override
  String monthPeriod(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours de règles',
      one: '1 jour de règles',
    );
    return '$_temp0';
  }

  @override
  String get onboardingMonths =>
      'Tout se joue dans ce que tu notes, mois après mois.';

  @override
  String get ringCountdownCaption => 'Jours restants';

  @override
  String get ringShowCountdown => 'Afficher les jours restants';

  @override
  String get ringShowDay => 'Afficher le jour du cycle';

  @override
  String get widgetTitle => 'Widget d\'écran d\'accueil';

  @override
  String get widgetSubtitle =>
      'L\'anneau du cycle sur l\'écran d\'accueil de ce téléphone, sans un mot sur les règles. Ajoute-le depuis l\'écran d\'accueil : appui long sur une zone vide, puis le bouton +.';

  @override
  String get lockTurnedOff =>
      'Ce téléphone n\'a plus de code : le verrouillage de Fycle a été désactivé.';
}
