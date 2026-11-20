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
  String get disclaimer => 'Fycle informe. Ni avis médical, ni contraception.';

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
  String get onboardingCycleLengthQuestion =>
      'Combien de temps dure ton cycle d\'habitude ?';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get onboardingRestore => 'Reprendre ma sauvegarde';

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
  String get settingsExport => 'Enregistrer une sauvegarde protégée';

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
  String get settingsCsvSubtitle => 'Un fichier lisible, sans mot de passe.';

  @override
  String get settingsDelete => 'Tout supprimer';

  @override
  String get settingsDeleteSubtitle =>
      'Efface toutes tes données de ce téléphone.';

  @override
  String get settingsAboutSection => 'À propos';

  @override
  String get exportTitle => 'Sauvegarde protégée';

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
  String get csvWarningTitle => 'Fichier sans protection';

  @override
  String get csvWarningBody =>
      'Ce fichier n\'est pas protégé : toute personne qui l\'obtient peut le lire. Range-le dans un endroit de confiance.';

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
  String get lockSubtitle => 'Face ID, empreinte ou code, à chaque ouverture.';

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

  @override
  String get ringShowUsual =>
      'Afficher ce qui revient d\'habitude vers ce jour';

  @override
  String get ringHint => 'Glisse sur l\'anneau pour parcourir ton cycle.';

  @override
  String ringExploreValue(int day, String date) {
    return 'Jour $day de ton cycle, $date';
  }

  @override
  String exploreToday(String date) {
    return '$date · aujourd\'hui';
  }

  @override
  String exploreLogged(String facts) {
    return 'Noté : $facts';
  }

  @override
  String get exploreNothingLogged => 'Rien de noté ce jour-là.';

  @override
  String get exploreExpected =>
      'Dans la période où tes prochaines règles sont estimées.';

  @override
  String get exploreFertile =>
      'Dans ta fenêtre de fertilité estimée. Une estimation : ni contraception ni diagnostic.';

  @override
  String exploreUsual(String signs) {
    return 'D\'habitude, vers ce jour : $signs';
  }

  @override
  String get exploreNothing =>
      'Rien de marquant vers ce jour dans tes cycles précédents pour l\'instant.';

  @override
  String get exploreOpen => 'Ouvrir cette page';

  @override
  String get exploreBack => 'Revenir à aujourd\'hui';

  @override
  String periodEndRange(int from, int to) {
    return 'Encore $from à $to jours environ, d\'après tes règles précédentes';
  }

  @override
  String periodEndDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Encore $count jours environ, d\'après tes règles précédentes',
      one: 'Encore 1 jour environ, d\'après tes règles précédentes',
    );
    return '$_temp0';
  }

  @override
  String get periodEndToday =>
      'Sans doute le dernier jour, d\'après tes règles précédentes';

  @override
  String get reviewSeeDetail => 'Voir le détail';

  @override
  String get reviewDetailTitle => 'Le détail';

  @override
  String get remindersAskTitle => 'Rappels';

  @override
  String get remindersAskBody =>
      'Fycle peut te prévenir quelques jours avant tes règles, et te rappeler ton journal chaque jour. Rien ne quitte ce téléphone. Activer les deux rappels ?';

  @override
  String get remindersAskBlockedBody =>
      'Les notifications sont coupées pour Fycle dans les réglages de ce téléphone. Sans elles, Fycle ne peut ni te prévenir avant tes règles ni te rappeler ton journal. Tu peux les autoriser dans les réglages du téléphone.';

  @override
  String get remindersAskLater => 'Plus tard';

  @override
  String get setupBegin => 'C\'est parti';

  @override
  String get setupSkipAll => 'Passer la configuration';

  @override
  String get setupSkip => 'Passer';

  @override
  String get setupNext => 'Continuer';

  @override
  String get setupBack => 'Retour';

  @override
  String setupProgress(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String get setupNameTitle => 'Quel est ton prénom ?';

  @override
  String get setupNameHint => 'Facultatif.';

  @override
  String get setupNameLabel => 'Prénom';

  @override
  String get setupBirthTitle => 'En quelle année es-tu née ?';

  @override
  String get setupBirthHint => 'Pour ta première estimation.';

  @override
  String get setupGoalsTitle => 'Qu\'est-ce qui t\'amène ?';

  @override
  String get setupGoalsHint => 'Plusieurs réponses possibles.';

  @override
  String get goalTrackPeriods => 'Suivre mes règles';

  @override
  String get goalUnderstandBody => 'Mieux comprendre mon corps';

  @override
  String get goalConceive => 'Concevoir un enfant';

  @override
  String get goalPerimenopause => 'Suivre une périménopause';

  @override
  String get setupRegularTitle => 'Tes règles sont-elles régulières ?';

  @override
  String get setupRegularHint => 'À peu près le même écart entre deux règles.';

  @override
  String get regularYes => 'Oui';

  @override
  String get regularNo => 'Non';

  @override
  String get regularUnknown => 'Je ne sais pas';

  @override
  String get regularNoPeriods => 'Je n\'ai pas de règles';

  @override
  String get setupLengthsTitle => 'Ton cycle et tes règles, en jours';

  @override
  String get setupLengthsHint => 'Même à peu près. Sinon, passe.';

  @override
  String get setupCycleLength => 'Durée de ton cycle';

  @override
  String get setupCycleLengthHelper => 'Du 1er jour des règles au suivant.';

  @override
  String get setupPeriodLength => 'Durée de tes règles';

  @override
  String get setupPeriodLengthHelper => 'Jours de saignement.';

  @override
  String setupDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get setupFewer => 'Un jour de moins';

  @override
  String get setupMore => 'Un jour de plus';

  @override
  String get setupChangesTitle => 'Tes règles ont-elles changé récemment ?';

  @override
  String get setupChangesHint =>
      'Un changement t\'inquiète ? Parles-en à un médecin.';

  @override
  String get changeHeavier => 'Mon flux est plus abondant';

  @override
  String get changeLighter => 'Mon flux est moins abondant';

  @override
  String get changeLessRegular => 'Mes règles sont moins régulières';

  @override
  String get changeLength => 'La durée de mes règles a changé';

  @override
  String get changeNothing => 'Rien n\'a changé';

  @override
  String get setupLastHint => 'Touche le jour, même approximatif.';

  @override
  String get setupRemindersTitle => 'Veux-tu des rappels ?';

  @override
  String get setupLockTitle => 'Rien que pour toi';

  @override
  String get setupLockHint => 'Personne n\'ouvre l\'appli sans toi.';

  @override
  String get setupReadyTitle => 'Tout est prêt';

  @override
  String setupReadyTitleName(String name) {
    return 'Tout est prêt, $name';
  }

  @override
  String get setupReadyBody => 'Note tes règles dès le premier jour.';

  @override
  String get settingsAnswers => 'Mes réponses';

  @override
  String get settingsAnswersSubtitle =>
      'Prénom, objectifs, régularité, durées habituelles.';

  @override
  String periodEndDeclaredDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Encore $count jours environ, d\'après ce que tu as indiqué',
      one: 'Encore 1 jour environ, d\'après ce que tu as indiqué',
    );
    return '$_temp0';
  }

  @override
  String get periodEndDeclaredToday =>
      'Sans doute le dernier jour, d\'après ce que tu as indiqué';

  @override
  String get symptomHotFlashes => 'Bouffées de chaleur';

  @override
  String get symptomNightSweats => 'Sueurs nocturnes';

  @override
  String get changeTitle => 'Ce qui change';

  @override
  String get changeIntro =>
      'Ce que tes dates montrent d\'un cycle au suivant. Un constat, pas un diagnostic.';

  @override
  String get changeTooFew =>
      'Il faut deux cycles complets pour comparer un cycle au suivant.';

  @override
  String changeNoDifference(int cycles) {
    String _temp0 = intl.Intl.pluralLogic(
      cycles,
      locale: localeName,
      other:
          'Sur tes $cycles derniers cycles, aucun ne diffère du précédent de 7 jours ou plus.',
      one: 'Ton dernier cycle est à moins de 7 jours du précédent.',
    );
    return '$_temp0';
  }

  @override
  String changeDifferences(int count, int cycles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count fois sur tes $cycles derniers cycles, la durée a changé de 7 jours ou plus d\'un cycle au suivant.',
      one:
          'Une fois sur tes $cycles derniers cycles, la durée a changé de 7 jours ou plus d\'un cycle au suivant.',
    );
    return '$_temp0';
  }

  @override
  String changeLongInterval(int days) {
    return 'Un cycle a duré $days jours : 60 jours ou plus entre deux règles.';
  }

  @override
  String changeSinceLast(int days) {
    return '$days jours depuis le début de tes dernières règles : 60 jours ou plus sans règles.';
  }

  @override
  String get changeNoSigns =>
      'Aucun des signes à suivre n\'a été noté ces 90 derniers jours. Tu peux les cocher dans ton journal.';

  @override
  String changeSaid(String changes) {
    return 'Au départ, tu avais indiqué : $changes.';
  }

  @override
  String get changeSaidHeavier => 'flux plus abondant';

  @override
  String get changeSaidLighter => 'flux moins abondant';

  @override
  String get changeSaidLessRegular => 'règles moins régulières';

  @override
  String get changeSaidLength => 'durée des règles changée';

  @override
  String get changeToReport =>
      'À signaler à un médecin ou à une sage-femme : beaucoup de choses peuvent faire bouger un cycle, et seul un professionnel de santé peut dire ce que cela signifie.';

  @override
  String get changeFooter =>
      'Beaucoup de choses peuvent faire bouger un cycle. Seul un professionnel de santé peut dire ce qu\'un changement signifie.';

  @override
  String get setupPrivacyTitle => 'Tes données restent sur ton téléphone';

  @override
  String get privacyNoAccount => 'Aucun compte à créer.';

  @override
  String get privacyOnPhone => 'Tout reste sur ton téléphone, protégé.';

  @override
  String get privacyBackup => 'Rien n\'est envoyé sur Internet.';

  @override
  String get privacyNoAds => 'Ni publicité, ni abonnement.';

  @override
  String setupGreeting(String name) {
    return 'Bienvenue, $name.';
  }

  @override
  String get setupWishesTitle => 'Qu\'attends-tu de Fycle ?';

  @override
  String get setupWishesHint => 'Plusieurs choix possibles.';

  @override
  String get wishKnowWhen => 'Prévoir mes règles';

  @override
  String get wishKnowUsualRanges => 'Me situer par rapport aux repères';

  @override
  String get wishFertileWindow => 'Voir ma fenêtre de fertilité estimée';

  @override
  String get wishAfterContraception =>
      'Comprendre mon cycle après une contraception';

  @override
  String get wishWhatComesBack => 'Voir ce qui revient';

  @override
  String get setupUsualTitle => 'Comment sont tes règles d\'habitude ?';

  @override
  String get setupUsualFlow => 'Abondance';

  @override
  String get setupUsualPain => 'Douleur';

  @override
  String get setupContraceptionTitle => 'Utilises-tu une contraception ?';

  @override
  String get setupContraceptionHint =>
      'Fycle ne donne aucun conseil de contraception.';

  @override
  String get contraceptionNone => 'Non';

  @override
  String get contraceptionHormonal => 'Oui, hormonale';

  @override
  String get contraceptionNonHormonal => 'Oui, sans hormones';

  @override
  String get setupSignsTitle => 'As-tu ces signes pendant ton cycle ?';

  @override
  String get setupSignsHint => 'Coche ceux que tu as.';

  @override
  String get symptomVaginalDryness => 'Sécheresse vaginale';

  @override
  String get symptomJointPain => 'Douleurs articulaires';

  @override
  String get symptomBrainFog => 'Difficulté à se concentrer';

  @override
  String get symptomPalpitations => 'Palpitations';

  @override
  String get setupEarlierTitle => 'Et les règles d\'avant ?';

  @override
  String get setupEarlierHint => 'Touche leur premier jour, trois au plus.';

  @override
  String get setupTrackedTitle => 'Que veux-tu noter chaque jour ?';

  @override
  String get setupTrackedHint => 'Coche ce qui compte pour toi.';

  @override
  String get trackedPain => 'Douleur';

  @override
  String get trackedMood => 'Humeur';

  @override
  String get trackedSleep => 'Sommeil';

  @override
  String get trackedLibido => 'Libido';

  @override
  String get trackedSymptoms => 'Symptômes';

  @override
  String get recapTitle => 'Tes réglages';

  @override
  String recapCycleOwn(int days) {
    return 'Cycle de $days jours, d\'après tes dates.';
  }

  @override
  String recapCycleDeclared(int days) {
    return 'Cycle de $days jours, comme indiqué.';
  }

  @override
  String recapCycleAge(int days) {
    return 'Cycle de $days jours, moyenne de ton âge.';
  }

  @override
  String recapCycleDefault(int days) {
    return 'Cycle de $days jours pour commencer.';
  }

  @override
  String recapRange(int days) {
    return 'Fourchette de $days jours, qui se resserre.';
  }

  @override
  String get recapNoDate => 'Estimation dès tes premières règles notées.';

  @override
  String get recapFertilityOn =>
      'Fenêtre de fertilité estimée affichée. Ni contraception ni diagnostic.';

  @override
  String get recapFertilityHormonal =>
      'Estimation d\'ovulation masquée (contraception hormonale).';

  @override
  String get recapFertilityOff => 'Fenêtre de fertilité masquée.';

  @override
  String recapJournal(String items) {
    return 'Ton journal : $items.';
  }

  @override
  String get recapChanges => 'Bilan des changements d\'un cycle à l\'autre.';

  @override
  String get recapRemindersOn => 'Rappels activés.';

  @override
  String get recapRemindersOff => 'Rappels coupés.';

  @override
  String get recapLockOn => 'Appli verrouillée à l\'ouverture.';

  @override
  String changeSignsList(String signs) {
    return 'Ces 90 derniers jours : $signs.';
  }

  @override
  String changeSignDays(String sign, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '1 jour',
    );
    return '$sign ($_temp0)';
  }

  @override
  String changeStartSigns(String signs) {
    return 'Signes indiqués au départ : $signs.';
  }

  @override
  String get followTitle => 'Ton suivi';

  @override
  String followRow(String name, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '1 jour',
      zero: 'aucun jour',
    );
    return '$name : $_temp0 sur les 7 derniers';
  }

  @override
  String followWeek(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours notés sur les 7 derniers',
      one: '1 jour noté sur les 7 derniers',
      zero: 'Aucun jour noté sur les 7 derniers',
    );
    return '$_temp0';
  }

  @override
  String followMonth(int days, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Ce mois-ci : $days jours notés sur $total',
      one: 'Ce mois-ci : 1 jour noté sur $total',
      zero: 'Ce mois-ci : aucun jour noté sur $total',
    );
    return '$_temp0';
  }

  @override
  String get figureGoodNights => 'Bonnes nuits';

  @override
  String get figurePainDays => 'Jours de douleur';

  @override
  String get reliabilityTitle => 'Fiabilité de l\'estimation';

  @override
  String get reliabilityLow => 'Faible';

  @override
  String get reliabilityMedium => 'Moyenne';

  @override
  String get reliabilityHigh => 'Élevée';

  @override
  String get reliabilityNone =>
      'Note le premier jour de tes règles pour obtenir une estimation.';

  @override
  String reliabilityToMedium(int cycles) {
    String _temp0 = intl.Intl.pluralLogic(
      cycles,
      locale: localeName,
      other:
          'Encore $cycles cycles notés avant qu\'elle puisse passer à moyenne.',
      one: 'Encore 1 cycle noté avant qu\'elle puisse passer à moyenne.',
    );
    return '$_temp0';
  }

  @override
  String reliabilityToHigh(int cycles) {
    String _temp0 = intl.Intl.pluralLogic(
      cycles,
      locale: localeName,
      other:
          'Encore $cycles cycles notés avant qu\'elle puisse passer à élevée.',
      one: 'Encore 1 cycle noté avant qu\'elle puisse passer à élevée.',
    );
    return '$_temp0';
  }

  @override
  String get reliabilityHeldByVariation =>
      'Tes cycles diffèrent d\'une fois à l\'autre : elle montera s\'ils se rapprochent. Rien à voir avec ta façon de noter.';

  @override
  String get reliabilityAtTop =>
      'Le niveau le plus élevé : il tient tant que tes cycles se ressemblent.';

  @override
  String get setupNotGiven => 'Pas indiqué';

  @override
  String get changeMoreRegular => 'Mes règles sont plus régulières';

  @override
  String get changeLonger => 'Mes règles durent plus longtemps';

  @override
  String get changeShorter => 'Mes règles durent moins longtemps';

  @override
  String get changeMorePainful => 'Mes règles sont plus douloureuses';

  @override
  String get changeLessPainful => 'Mes règles sont moins douloureuses';

  @override
  String get changeSaidMoreRegular => 'règles plus régulières';

  @override
  String get changeSaidLonger => 'règles plus longues';

  @override
  String get changeSaidShorter => 'règles plus courtes';

  @override
  String get changeSaidMorePainful => 'règles plus douloureuses';

  @override
  String get changeSaidLessPainful => 'règles moins douloureuses';

  @override
  String get symptomMigraine => 'Migraine';

  @override
  String get symptomMoodSwings => 'Sautes d\'humeur';

  @override
  String get setupRemindersHint => 'Discrets : jamais le mot « règles ».';

  @override
  String get setupPeriodReminder => 'Me prévenir avant mes règles';

  @override
  String get setupPeriodReminderHint => 'Quelques jours avant la date estimée.';

  @override
  String get setupDailyReminder => 'Me rappeler de noter ma journée';

  @override
  String get setupDailyReminderHint =>
      'Une fois par jour, seulement si tu n\'as rien noté.';

  @override
  String get cycleFirstHalf => 'Tu es dans la première moitié de ton cycle.';

  @override
  String get cycleSecondHalf => 'Tu es dans la seconde moitié de ton cycle.';

  @override
  String get legendToday => 'Aujourd\'hui';

  @override
  String get kpiWeek => '7 derniers jours';

  @override
  String get kpiWeekCaption => 'jours notés';

  @override
  String get kpiCycle => 'Ce cycle';

  @override
  String kpiCycleCaption(int days) {
    return 'jours notés sur $days';
  }

  @override
  String get kpiThisCycle => 'ce cycle';

  @override
  String kpiPrevious(String value) {
    return 'cycle précédent : $value';
  }

  @override
  String get kpiMostFrequent => 'la plus fréquente ce cycle';

  @override
  String get weekTitle => 'Tes 7 derniers jours';

  @override
  String get weekIntro => 'Un point plein : c\'est noté ce jour-là.';

  @override
  String get weekAnyNote => 'La journée';

  @override
  String get setupProfileTitle => 'Où en es-tu ?';

  @override
  String get profileDiscovering => 'Je découvre mon cycle';

  @override
  String get profileDiscoveringDetail => 'Je débute';

  @override
  String get profileTracking => 'Je suis mes règles';

  @override
  String get profileTrackingDetail => 'Prévoir et noter';

  @override
  String get profileConceiving => 'Je cherche à concevoir';

  @override
  String get profileConceivingDetail => 'Fenêtre de fertilité estimée';

  @override
  String get profilePregnant => 'Je suis enceinte';

  @override
  String get profilePregnantDetail => 'Compter les semaines';

  @override
  String get profilePostpartum => 'J\'ai accouché';

  @override
  String get profilePostpartumDetail => 'Jusqu\'au retour des règles';

  @override
  String get profilePerimenopause => 'Mon cycle change';

  @override
  String get profilePerimenopauseDetail => 'Préménopause';

  @override
  String get setupPregnancyDateHint =>
      'Les semaines se comptent depuis ce jour.';

  @override
  String get setupBirthDateTitle => 'Quand as-tu accouché ?';

  @override
  String get setupBirthDateHint => 'Pour compter les semaines.';

  @override
  String get setupChooseDate => 'Choisir la date';

  @override
  String get changeDate => 'Changer la date';

  @override
  String get pregnancyTitle => 'Ta grossesse';

  @override
  String pregnancyWeeks(int weeks, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks semaines',
      one: '1 semaine',
      zero: '0 semaine',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '1 jour',
      zero: '0 jour',
    );
    return '$_temp0 et $_temp1';
  }

  @override
  String get pregnancyCounted =>
      'comptés depuis le premier jour de tes dernières règles';

  @override
  String pregnancyTerm(String from, String to) {
    return 'Naissance à terme estimée entre le $from et le $to.';
  }

  @override
  String get pregnancyNote =>
      'Une estimation : seule l\'échographie de datation donne une date fiable.';

  @override
  String get pregnancyNoDate =>
      'Indique le premier jour de tes dernières règles pour compter les semaines.';

  @override
  String get pregnancyPast =>
      'Plus de 42 semaines se sont écoulées depuis cette date. Tu peux changer la date ou quitter le mode grossesse.';

  @override
  String get pregnancyPaused => 'L\'estimation des règles est en pause.';

  @override
  String get pregnancyLeave => 'Quitter le mode grossesse';

  @override
  String get leaveTitle => 'Où en es-tu maintenant ?';

  @override
  String get leaveGaveBirth => 'J\'ai accouché';

  @override
  String get leaveBackToCycle => 'Revenir au suivi de mon cycle';

  @override
  String get postpartumTitle => 'Après ton accouchement';

  @override
  String postpartumWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks semaines',
      one: '1 semaine',
      zero: 'Moins d\'une semaine',
    );
    return '$_temp0 depuis ton accouchement';
  }

  @override
  String get postpartumBody =>
      'Le retour des règles varie beaucoup d\'une femme à l\'autre. Note leur premier jour quand elles reviennent : l\'estimation reprendra à partir de là.';

  @override
  String get postpartumNoDate =>
      'Indique la date de ton accouchement pour compter les semaines.';

  @override
  String get recapPregnancy => 'Mode grossesse : semaines comptées.';

  @override
  String get recapPostpartum => 'Estimation au retour de tes règles.';

  @override
  String get reminderContraceptionTitle => 'Rappel de contraception';

  @override
  String get reminderContraceptionSubtitle =>
      'Chaque jour à l\'heure que tu choisis. Un simple rappel : aucun conseil, et rien n\'est vérifié.';

  @override
  String get notificationContraceptionBody => 'C\'est l\'heure.';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get migraineIntensity => 'Quelle est l\'intensité de la migraine ?';

  @override
  String get migraineDurationTitle => 'Combien de temps a-t-elle duré ?';

  @override
  String get migraineMedicationTitle => 'As-tu pris un médicament ?';

  @override
  String get migraineHours => 'Quelques heures';

  @override
  String get migraineDay => 'Une journée';

  @override
  String get migraineLonger => 'Plus d\'une journée';

  @override
  String get migraineMedicationYes => 'médicament pris';

  @override
  String get migraineMedicationNo => 'sans médicament';

  @override
  String migraineSummaryDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours de migraine ces 90 derniers jours',
      one: '1 jour de migraine ces 90 derniers jours',
    );
    return '$_temp0';
  }

  @override
  String migraineSummaryPeriod(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Dont $days pendant tes règles ou les deux jours avant.',
      one: 'Dont 1 pendant tes règles ou les deux jours avant.',
      zero: 'Aucun pendant tes règles ou les deux jours avant.',
    );
    return '$_temp0';
  }

  @override
  String migraineSummaryMedication(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Un médicament noté $days jours.',
      one: 'Un médicament noté 1 jour.',
    );
    return '$_temp0';
  }

  @override
  String migraineSummaryIntensity(String level) {
    return 'Le plus souvent : $level.';
  }

  @override
  String get migraineSummaryNote =>
      'Un décompte de ce que tu as coché, à montrer à un médecin. Rien n\'est dit des causes ni des traitements.';

  @override
  String get partnerShareTitle => 'Inviter mon partenaire';

  @override
  String get partnerShareSubtitle => 'Un code à scanner. Aucun serveur.';

  @override
  String get partnerShareIntro =>
      'Un fichier protégé par un mot de passe, que tu envoies comme tu veux.';

  @override
  String get partnerShareName => 'Donner mon prénom';

  @override
  String get partnerShareFertility =>
      'Partager ma fenêtre de fertilité estimée';

  @override
  String get partnerFertilityNote =>
      'Une estimation : ni contraception ni diagnostic.';

  @override
  String get partnerPassword => 'Mot de passe du fichier';

  @override
  String get passwordRepeatLabel => 'Répète le mot de passe';

  @override
  String get partnerCreate => 'Créer le fichier';

  @override
  String get partnerSavedTitle => 'Fichier créé';

  @override
  String get partnerSavedBody =>
      'Envoie-le à ton ou ta partenaire, et donne-lui le mot de passe de vive voix ou par un autre moyen que le fichier.';

  @override
  String get partnerOpenEntry => 'Ouvrir le fichier de mon ou ma partenaire';

  @override
  String get partnerOpenTitle => 'Fichier d\'un ou d\'une partenaire';

  @override
  String get partnerOpenAction => 'Ouvrir';

  @override
  String get partnerOpenError =>
      'Ce fichier n\'a pas pu être lu : mot de passe incorrect, ou ce n\'est pas un fichier fait pour un partenaire.';

  @override
  String get partnerHeader => 'Son cycle';

  @override
  String partnerHeaderOf(String name) {
    return 'Le cycle de $name';
  }

  @override
  String get partnerReadOnly =>
      'Ce qu\'elle a choisi de partager avec toi. Rien ici ne quitte ton téléphone.';

  @override
  String partnerDayOfCycle(int day) {
    return 'Jour $day de son cycle';
  }

  @override
  String get partnerPeriodOngoing => 'Ses règles sont en cours';

  @override
  String partnerPeriodIn(int from, int to) {
    String _temp0 = intl.Intl.pluralLogic(
      from,
      locale: localeName,
      other: 'Règles dans $from à $to jours',
      one: 'Règles dans 1 à $to jours',
    );
    return '$_temp0';
  }

  @override
  String get partnerPeriodExpected =>
      'Ses règles peuvent arriver d\'un jour à l\'autre';

  @override
  String partnerRange(String from, String to) {
    return 'Estimées entre le $from et le $to.';
  }

  @override
  String partnerFertileWindow(String from, String to) {
    return 'Fenêtre de fertilité estimée : du $from au $to';
  }

  @override
  String get partnerOutdatedTitle => 'Ces dates sont dépassées';

  @override
  String get partnerOutdatedBody => 'Demande-lui d\'afficher un nouveau code.';

  @override
  String get partnerUnknownTitle => 'Pas encore d\'estimation';

  @override
  String get partnerUnknownBody =>
      'Elle n\'avait pas encore noté de règles. Rescanne son code plus tard.';

  @override
  String get partnerPregnant => 'Elle est enceinte';

  @override
  String get partnerPregnancyCounted =>
      'comptés depuis le premier jour de ses dernières règles';

  @override
  String get partnerAfterBirth => 'Après la naissance';

  @override
  String partnerWeeksSinceBirth(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks semaines depuis la naissance',
      one: '1 semaine depuis la naissance',
      zero: 'Moins d\'une semaine depuis la naissance',
    );
    return '$_temp0';
  }

  @override
  String get partnerAfterBirthBody =>
      'Ses règles ne sont pas encore revenues dans son journal.';

  @override
  String partnerMadeOn(String date) {
    return 'Partagé le $date. Rescanne son code de temps en temps.';
  }

  @override
  String get partnerReplace => 'Ouvrir un fichier';

  @override
  String get partnerLeave => 'Ne plus suivre';

  @override
  String get pdfSave => 'Enregistrer en PDF';

  @override
  String get pdfSaved => 'Rapport enregistré.';

  @override
  String get pdfAveragesTitle => 'Moyennes';

  @override
  String get pdfNoCycle => 'Aucun cycle complet noté pour l\'instant.';

  @override
  String pdfBasis(int cycles) {
    String _temp0 = intl.Intl.pluralLogic(
      cycles,
      locale: localeName,
      other: 'Sur les $cycles derniers cycles complets.',
      one: 'Sur le dernier cycle complet.',
    );
    return '$_temp0';
  }

  @override
  String pdfMeanCycle(String days) {
    return 'Durée moyenne du cycle : $days';
  }

  @override
  String pdfCycleRange(int min, int max) {
    return 'Cycle le plus court : $min jours. Le plus long : $max jours.';
  }

  @override
  String pdfMeanPeriod(String days) {
    return 'Durée moyenne des règles : $days';
  }

  @override
  String get pdfCyclesTitle => 'Cycles';

  @override
  String pdfCycleLine(String from, String to, int length, int period) {
    return 'Du $from au $to : cycle de $length jours, règles de $period jours';
  }

  @override
  String get pdfFooter =>
      'Produit sur le téléphone à partir de ce que l\'utilisatrice a noté elle-même. Une liste de dates et de décomptes : pas un diagnostic.';

  @override
  String get autoBackupTitle => 'Sauvegarde automatique';

  @override
  String get autoBackupSubtitle =>
      'Une fois par jour, un fichier protégé par ton mot de passe est mis à jour dans l\'app Fichiers. Rien n\'est envoyé.';

  @override
  String get autoBackupPasswordTitle =>
      'Mot de passe de la sauvegarde automatique';

  @override
  String get autoBackupPasswordBody =>
      'Tu en auras besoin pour restaurer la sauvegarde. Il n\'existe aucun moyen de le retrouver.';

  @override
  String get todayBleedingTitle => 'Saignement aujourd\'hui';

  @override
  String get kpiFertile => 'Fenêtre de fertilité estimée';

  @override
  String kpiFertileRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get kpiFertileCaption => 'une estimation, pas une certitude';

  @override
  String get learnTitle => 'Ton cycle, en quelques mots';

  @override
  String get learnCycle =>
      'Un cycle va du premier jour de tes règles au premier jour des suivantes.';

  @override
  String get learnLength =>
      'Sa durée change d\'une femme à l\'autre, et d\'un cycle à l\'autre : le plus souvent entre 24 et 38 jours.';

  @override
  String get learnFirstYears =>
      'Les premières années de règles, des cycles irréguliers sont fréquents.';

  @override
  String get learnLogging => 'Plus tu notes, plus l\'estimation te ressemble.';

  @override
  String get healthImportTitle => 'Importer depuis Apple Santé';

  @override
  String get healthImportSubtitle =>
      'Copie les jours de règles que tu y as déjà notés. Lu sur ce téléphone ; rien n\'est envoyé.';

  @override
  String get healthImportUnavailable =>
      'Aucun jour de règles n\'a pu être lu. Tu peux l\'autoriser dans l\'app Santé, rubrique Partage, ou noter tes règles ici.';

  @override
  String healthImportDone(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours de règles copiés dans ton journal.',
      one: '1 jour de règles copié dans ton journal.',
      zero:
          'Rien de nouveau : les jours trouvés étaient déjà dans ton journal.',
    );
    return '$_temp0';
  }

  @override
  String get setupTagline => 'Y voir clair dans ton cycle.';

  @override
  String get setupExisting => 'J\'ai déjà Fycle';

  @override
  String get contraceptionHormonalDetail =>
      'Pilule, implant, stérilet hormonal, anneau, patch';

  @override
  String get contraceptionNonHormonalDetail =>
      'Stérilet au cuivre, préservatif, autre';

  @override
  String get kpiRegularity => 'Ton cycle';

  @override
  String get kpiRegular => 'Régulier';

  @override
  String get kpiVariable => 'Variable';

  @override
  String get kpiRegularitySoon => 'Bientôt';

  @override
  String get kpiRegularityNeed => 'dès 3 cycles complets';

  @override
  String kpiRegularityGap(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours d\'écart',
      one: '1 jour d\'écart',
      zero: 'toujours la même durée',
    );
    return '$_temp0';
  }

  @override
  String get partnerInviteScan => 'À scanner avec l\'appareil photo';

  @override
  String get partnerInviteWhat =>
      'Dates et estimations seulement. Fycle doit être sur son téléphone.';

  @override
  String get partnerInviteFile => 'Envoyer un fichier à la place';

  @override
  String get partnerQrLabel => 'Code à scanner';

  @override
  String get partnerLinkErrorTitle => 'Code illisible';

  @override
  String get partnerLinkErrorBody => 'Demande-lui d\'afficher un nouveau code.';

  @override
  String get partnerLinkBusyTitle => 'Ce téléphone suit déjà un cycle';

  @override
  String get partnerLinkBusyBody =>
      'La vue partenaire s\'ouvre sur un téléphone où Fycle n\'est pas encore configurée.';
}
