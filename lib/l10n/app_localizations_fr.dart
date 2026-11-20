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

  @override
  String get comingTitleHers => 'Ce qui revient chez toi';

  @override
  String get comingTitleCommon => 'Avant les règles, en général';

  @override
  String get comingNow => 'Ces jours-ci';

  @override
  String comingIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Dans $days jours environ',
      one: 'Dans 1 jour environ',
    );
    return '$_temp0';
  }

  @override
  String comingDaysBefore(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours avant',
      one: 'la veille',
    );
    return '$_temp0';
  }

  @override
  String comingDaysRange(int from, int to) {
    return '$from à $to jours avant';
  }

  @override
  String comingLoggedLine(String when, int count, int total) {
    return '$when · $count cycles sur $total';
  }

  @override
  String get comingDeclared => 'D\'après ce que tu as dit';

  @override
  String comingCommonBody(String signs) {
    return 'Souvent rapporté : $signs.';
  }

  @override
  String get comingCommonHint =>
      'Repère général. Note tes signes pour voir les tiens.';

  @override
  String get comingLogToday => 'Aujourd\'hui';

  @override
  String comingLogTooltip(String sign) {
    return 'Noter aujourd\'hui : $sign';
  }

  @override
  String get setupBeforeTitle => 'Avant tes règles, tu as souvent…';

  @override
  String get setupBeforeHint => 'Coche ce que tu reconnais.';

  @override
  String get reminderSignsTitle => 'Ce qui revient';

  @override
  String get reminderSignsSubtitle =>
      'Une fois par cycle, avant tes signes habituels.';

  @override
  String get notificationSignsBody => 'Un repère pour les jours qui viennent.';

  @override
  String get catchUpStartedTitle => 'Tes règles ont-elles commencé ?';

  @override
  String get catchUpToday => 'Aujourd\'hui';

  @override
  String get catchUpYesterday => 'Hier';

  @override
  String get catchUpOtherDay => 'Un autre jour';

  @override
  String get catchUpNotYet => 'Pas encore';

  @override
  String get catchUpContinuesTitle => 'Tes règles continuent ?';

  @override
  String catchUpContinuesBody(String date) {
    return 'Dernier jour noté : $date.';
  }

  @override
  String get catchUpContinuesYes => 'Oui, encore aujourd\'hui';

  @override
  String get catchUpContinuesNo => 'Elles sont finies';

  @override
  String get catchUpHint => 'Tu peux corriger chaque jour dans le journal.';

  @override
  String get todayLogYesterday => 'Noter hier';

  @override
  String get dayIntimacyTitle => 'Rapport';

  @override
  String get intimacyUnspecified => 'Oui';

  @override
  String get intimacyProtected => 'Protégé';

  @override
  String get intimacyUnprotected => 'Non protégé';

  @override
  String get symptomPainDuringSex => 'Douleur pendant les rapports';

  @override
  String get aheadTitle => 'Les semaines à venir';

  @override
  String get aheadPeriod => 'Règles estimées';

  @override
  String aheadSigns(String signs) {
    return 'Ce qui revient chez toi : $signs';
  }

  @override
  String get aheadFertile => 'Fenêtre fertile estimée';

  @override
  String aheadDesire(int cycles, int considered) {
    return 'Désir souvent plus haut · $cycles cycles sur $considered';
  }

  @override
  String aheadDates(String start, String end) {
    return 'Du $start au $end';
  }

  @override
  String get aheadHint => 'Des estimations, pour t\'organiser.';

  @override
  String get aheadDesireGeneral =>
      'Désir : en général un peu plus haut vers le milieu du cycle, et très différent d\'une personne à l\'autre. Note le tien pour voir ta propre tendance.';

  @override
  String get sexLifeTitle => 'Vie sexuelle';

  @override
  String get sexLifeSubtitle =>
      'Noter les rapports et voir quand ton désir est souvent plus haut.';

  @override
  String get guidesTitle => 'Fiches';

  @override
  String get guidesIntro =>
      'De courtes pages écrites pour toi. Elles ne remplacent aucune consultation.';

  @override
  String get guideTopicPerimenopause => 'Périménopause';

  @override
  String get guideTopicPregnancy => 'Grossesse';

  @override
  String get guideFeaturedTitle => 'Pour toi';

  @override
  String get guideRead => 'Lire';

  @override
  String get guideAll => 'Toutes les fiches';

  @override
  String get guideSeekTitle => 'Quand consulter';

  @override
  String get guidePendingReview =>
      'Texte en attente de relecture par un professionnel de santé.';

  @override
  String get guideNote => 'Une information générale, pas un avis sur toi.';

  @override
  String get guideSourcesPerimenopause =>
      'Rédigé à partir des pages du NHS (Royaume-Uni) sur la ménopause et la périménopause et sur les saignements après la ménopause, lues le 20 novembre 2026.';

  @override
  String get guideSourcesPregnancy =>
      'Rédigé à partir des pages du NHS (Royaume-Uni) sur la grossesse semaine par semaine, le suivi de grossesse, les mouvements du bébé, les saignements pendant la grossesse, la pré-éclampsie et le corps après la naissance, lues le 20 novembre 2026.';

  @override
  String get guidePeriWhatTitle => 'Périménopause : c\'est quoi, ce bazar ?';

  @override
  String get guidePeriWhatBody =>
      'Un cycle qui fait n\'importe quoi, des nuits hachées, une humeur en montagnes russes : et si c\'était ça ? Le mot fait peur, la chose est banale, et personne ne t\'en a parlé.\n\nLa périménopause est la période où les règles deviennent irrégulières, avant de s\'arrêter pour de bon. Elle vient d\'une baisse des hormones.\n\nLa ménopause est atteinte après 12 mois sans règles, sans contraception hormonale. Elle survient en général entre 45 et 55 ans, parfois plus tôt.\n\nLes symptômes durent en général 7 à 9 ans, parfois plus, et changent avec le temps. Ils sont très différents d\'une personne à l\'autre : certaines sont à peine gênées, d\'autres beaucoup.\n\nIl n\'existe pas de test de routine : un médecin se fonde sur l\'âge et les symptômes.';

  @override
  String get guidePeriWhatSeek =>
      'Parles-en à un médecin si tu penses avoir des symptômes et que tu veux connaître tes options.';

  @override
  String get guidePeriPeriodsTitle => 'Mes règles font n\'importe quoi';

  @override
  String get guidePeriPeriodsBody =>
      'Vingt-trois jours, puis quarante, puis un déluge : ton cycle n\'a pas perdu la tête, il change de rythme.\n\nUn changement des règles est en général l\'un des premiers signes de la périménopause.\n\nElles peuvent venir plus souvent ou moins souvent. Les saignements peuvent devenir plus abondants ou plus légers.\n\nÀ la fin, les règles s\'arrêtent complètement.\n\nUne contraception hormonale peut modifier ou arrêter les règles : il est alors plus difficile de savoir où tu en es.\n\nNoter tes règles ici montre comment l\'écart entre elles évolue au fil des mois.';

  @override
  String get guidePeriPeriodsSeek =>
      'Consulte un médecin si tes saignements ont changé et sont plus abondants qu\'avant, ou si tu saignes après 12 mois ou plus sans règles.';

  @override
  String get guidePeriFlushesTitle =>
      'Bouffées de chaleur : le radiateur intérieur';

  @override
  String get guidePeriFlushesBody =>
      'En réunion, au lit, dans le métro : la vague monte sans prévenir. Tu n\'es pas la seule à ouvrir la fenêtre en janvier.\n\nUne bouffée de chaleur est une sensation soudaine de chaleur, ou de froid, au visage, au cou et à la poitrine. Elle dure quelques minutes et peut s\'accompagner de fortes sueurs, de palpitations ou de vertiges.\n\nLa nuit, on parle de sueurs nocturnes : elles peuvent gêner le sommeil.\n\nCe que le NHS cite comme pouvant aider au quotidien : des vêtements légers, une chambre fraîche, une douche fraîche, un ventilateur ou une boisson froide, moins de stress, une activité physique régulière, et moins de déclencheurs comme les plats épicés, la caféine, les boissons chaudes, l\'alcool et le tabac.\n\nDes traitements existent : un médecin peut les passer en revue avec toi.';

  @override
  String get guidePeriFlushesSeek =>
      'Parles-en à un médecin si tu veux connaître tes options, ou si tu as des palpitations.';

  @override
  String get guidePeriSleepTitle =>
      'Nuits hachées, humeur en vrac, mots qui s\'échappent';

  @override
  String get guidePeriSleepBody =>
      'Tu cherches tes clés, puis le mot « clés ». Non, tu ne perds pas la tête.\n\nAvoir du mal à s\'endormir ou à rester endormie est fréquent, et souvent pire avec les sueurs nocturnes.\n\nDes sautes d\'humeur, une humeur basse ou de l\'anxiété peuvent s\'y ajouter, ainsi que des difficultés de mémoire ou de concentration, plus marquées après une mauvaise nuit.\n\nCe que le NHS cite comme pouvant aider : des horaires de sommeil réguliers, autant de repos que possible, une activité physique régulière, des activités relaxantes comme le yoga ou la méditation, et en parler avec des personnes qui vivent la même chose.\n\nUne thérapie par la parole peut aider pour l\'humeur, l\'anxiété et le sommeil. Un médecin peut aussi proposer des traitements.';

  @override
  String get guidePeriSleepSeek =>
      'Parles-en à un médecin si tu veux connaître tes options. Demander conseil tôt peut limiter les effets sur ta santé, tes relations et ton travail.';

  @override
  String get guidePeriSexTitle => 'Le désir qui change, le corps qui traîne';

  @override
  String get guidePeriSexBody =>
      'Plus envie, ou envie mais ça frotte ? Le désir joue à cache-cache, et ça ne dit rien de ton couple ni de toi.\n\nUne baisse du désir fait partie des symptômes possibles de la périménopause.\n\nLe vagin peut être sec, brûler, être irrité ou démanger, ce qui peut rendre les rapports douloureux. Les infections urinaires, ou des signes qui y ressemblent, peuvent aussi être plus fréquents.\n\nCes symptômes peuvent durer après la ménopause. Des solutions existent : un pharmacien ou un médecin peut en proposer, en toute discrétion.\n\nUne grossesse reste possible pendant la périménopause.';

  @override
  String get guidePeriSexSeek =>
      'Parles-en à un pharmacien ou à un médecin pour trouver ce qui te convient. Tu peux noter la sécheresse et la douleur pendant les rapports dans ton journal pour les leur montrer.';

  @override
  String get guidePeriSeekTitle => 'Quand consulter un médecin';

  @override
  String get guidePeriSeekBody =>
      'Consulte un médecin, sans urgence, si :\n\n• tu penses avoir des symptômes de périménopause et tu veux connaître tes options ;\n\n• tu as des palpitations ;\n\n• tu as encore tes règles, mais elles ont changé et tu saignes plus qu\'avant ;\n\n• tu n\'as plus de règles depuis 12 mois ou plus et tu saignes, même une seule fois, même très peu, même sous forme de pertes roses ou brunes.\n\nUn saignement après la ménopause n\'est en général pas grave, mais il doit toujours être vérifié.';

  @override
  String get guidePeriSeekSeek =>
      'Cette fiche ne remplace aucune consultation : dans le doute, demande à un professionnel de santé.';

  @override
  String get guidePregFirstTitle => 'Premier trimestre';

  @override
  String get guidePregFirstBody =>
      'Une grossesse se compte à partir du premier jour des dernières règles. Le premier trimestre va jusqu\'à la semaine 12.\n\nUn retard de règles est souvent l\'un des premiers signes. D\'autres peuvent venir : nausées à tout moment de la journée, seins sensibles, fatigue, envie d\'uriner plus souvent, crampes comme pendant les règles, ballonnements, odorat plus fin. Certaines ne ressentent rien du tout.\n\nUn premier rendez-vous avec une sage-femme ou un médecin a en général lieu pendant ces semaines : demande quand.';

  @override
  String get guidePregFirstSeek =>
      'Tout saignement pendant une grossesse doit être signalé à une sage-femme ou à un médecin, même léger.';

  @override
  String get guidePregSecondTitle => 'Deuxième trimestre';

  @override
  String get guidePregSecondBody =>
      'De la semaine 13 à la semaine 27. Les symptômes les plus pénibles des premières semaines se sont en général calmés.\n\nCe qui peut venir : un ventre qui commence à se voir, des gencives qui gonflent ou saignent, des saignements de nez, des crampes dans les jambes, des vertiges, des maux de tête, des mains et des pieds gonflés.\n\nLes mouvements du bébé se sentent en général pour la première fois entre 16 et 24 semaines, souvent après 20 semaines pour un premier bébé.';

  @override
  String get guidePregSecondSeek =>
      'Préviens ta sage-femme si tu n\'as senti aucun mouvement à 24 semaines. Un fort mal de tête, des troubles de la vue ou un gonflement soudain doivent être vérifiés sans attendre.';

  @override
  String get guidePregThirdTitle => 'Troisième trimestre';

  @override
  String get guidePregThirdBody =>
      'De la semaine 28 à la naissance.\n\nCe qui peut venir : brûlures d\'estomac, mal de dos, crampes, sommeil difficile, sensation de chaleur, chevilles et pieds gonflés.\n\nIl n\'y a pas de nombre de mouvements à compter chaque jour. Ce qui compte, ce sont les habitudes de ton bébé : tu dois sentir des mouvements jusqu\'à la naissance, et pendant.';

  @override
  String get guidePregThirdSeek =>
      'Appelle ta sage-femme ou ta maternité sans attendre, de jour comme de nuit, si ton bébé bouge moins que d\'habitude, si tu ne le sens plus bouger, ou si ses habitudes changent. N\'attends pas le lendemain.';

  @override
  String get guidePregUrgentTitle => 'Les signes qui ne doivent pas attendre';

  @override
  String get guidePregUrgentBody =>
      'Appelle les secours si tu saignes et que tu as aussi : une forte douleur au ventre, une douleur à l\'épaule, des nausées, une sensation de malaise ou de vertige, une perte de connaissance, ou un saignement si abondant qu\'il traverse une protection peu après l\'avoir mise.\n\nContacte sans attendre ta maternité, ta sage-femme ou ton médecin si :\n\n• tu saignes, même légèrement ;\n\n• ton bébé bouge moins que d\'habitude, tu ne le sens plus bouger, ou ses habitudes changent ;\n\n• tu as un fort mal de tête que les antidouleurs courants ne calment pas ;\n\n• ta vue est trouble ou tu vois des éclairs lumineux ;\n\n• tu as une douleur juste sous les côtes ;\n\n• ton visage, tes mains ou tes pieds gonflent soudainement ;\n\n• tu te sens très mal.';

  @override
  String get guidePregUrgentSeek =>
      'Cette liste n\'est pas complète. Si quelque chose t\'inquiète, appelle sans attendre ton prochain rendez-vous.';

  @override
  String get guidePregCareTitle => 'À quoi servent les rendez-vous';

  @override
  String get guidePregCareBody =>
      'Le suivi de grossesse sert à garder ta santé et celle de ton bébé aussi bonnes que possible. Il est en général assuré par une sage-femme, et par un médecin si besoin.\n\nLors d\'un premier rendez-vous, plus long, on t\'interroge sur ta santé, la date de tes dernières règles, tes grossesses précédentes et ta vie quotidienne.\n\nÀ la plupart des rendez-vous : ta tension est prise, tes urines sont analysées, et plus tard ton ventre est mesuré pour suivre la croissance du bébé. Des prises de sang et des échographies sont proposées à des moments précis.\n\nLe nombre de rendez-vous et d\'échographies, et leur date, dépendent du pays et de ta situation.';

  @override
  String get guidePregCareSeek =>
      'Tu peux contacter à tout moment celles et ceux qui suivent ta grossesse si tu es inquiète, sans attendre le prochain rendez-vous.';

  @override
  String get guidePregAfterTitle =>
      'Après la naissance : saignements et règles';

  @override
  String get guidePregAfterBody =>
      'Après la naissance, tu saignes par le vagin : beaucoup au début, puis de moins en moins, avec une couleur qui brunit, pendant quelques semaines. Ces saignements ne sont pas des règles.\n\nLe retour des règles est différent pour chacune. Avec le biberon, ou un allaitement mixte, les premières règles peuvent revenir dès 5 à 6 semaines après la naissance. Avec un allaitement complet, nuits comprises, elles peuvent ne revenir que lorsque tu allaites moins.\n\nUne grossesse est possible dès 3 semaines après la naissance, même en allaitant et avant le retour des règles.\n\nUne visite de contrôle a en général lieu 6 à 8 semaines après la naissance : un bon moment pour parler de ton corps et de ton moral.';

  @override
  String get guidePregAfterSeek =>
      'Préviens sans attendre une sage-femme ou un médecin si tu as : un saignement soudain ou très abondant, de gros caillots, de la fièvre avec un ventre douloureux, un mal de tête avec des troubles de la vue ou des vomissements, une douleur ou un gonflement dans un mollet, une douleur dans la poitrine ou du mal à respirer.';

  @override
  String get readingTitle => 'Pour aller plus loin';

  @override
  String get readingNote =>
      'S\'ouvre dans ton navigateur. Le site verra ta visite, comme pour toute page web.';

  @override
  String get readingTopicCycle => 'Cycle et règles';

  @override
  String get readingTopicSexuality => 'Sexualité et plaisir';

  @override
  String get readingTopicContraception => 'Contraception';

  @override
  String get readingTopicFertility => 'Fertilité';

  @override
  String get linksCycle =>
      'Santé des femmes : cycle et règles|ameli.fr|https://www.ameli.fr/assure/sante/sante-femme\nRègles douloureuses|ameli.fr|https://www.ameli.fr/assure/sante/themes/regles-douloureuses/consultation-traitement\nEndométriose|Santé.fr|https://www.sante.fr/endometriose\nVaginite et mycose vaginale|ameli.fr|https://www.ameli.fr/assure/sante/themes/vaginite/definition-symptomes-facteurs-favorisants';

  @override
  String get linksSexuality =>
      'Orgasme : le dossier|Slate|https://www.slate.fr/dossier/5487/orgasme/tout\n8 questions très simples sur l\'orgasme|Brut|https://www.brut.media/fr/videos/sante/sexualite/8-questions-tres-simples-sur-l-orgasme\nLes parties cachées du clitoris|Paris Match Belgique|https://www.parismatch.be/lifestyle/psychosexo/2025/05/10/une-sexologue-donne-ses-meilleurs-conseils-pour-stimuler-les-parties-cachees-du-clitoris-et-decupler-le-plaisir-PPY62SI57ZFIDM4KAYAS2YMGSY/\nQuand on n\'a pas le même désir|Slate|https://www.slate.fr/story/266372/sexo-couple-inegalite-desir-sexuel-libido-rapports-partenaires-envie-amour-sexualite\nDifférence de libido dans le couple|RTBF|https://www.rtbf.be/article/difference-de-libido-dans-le-couple-comment-gerer-la-balance-11325950\nQuestionSexualité : corps, désir, plaisir, pratiques|Santé publique France|https://questionsexualite.fr/\nSanté sexuelle|Santé.fr|https://www.sante.fr/sinformer/sante-sexuelle';

  @override
  String get linksContraception => '';

  @override
  String get linksFertility =>
      'Fertilité, infertilité et stérilité|ameli.fr|https://www.ameli.fr/assure/sante/themes/sterilite-pma-infertilite\nAvant une grossesse : consultation et mode de vie|ameli.fr|https://www.ameli.fr/assure/sante/devenir-parent/concevoir-un-enfant/consultation-et-mode-de-vie-en-vue-d-une-grossesse\nAssistance médicale à la procréation|Agence de la biomédecine|https://www.procreation-medicale.fr/';

  @override
  String get linksPerimenopause =>
      'Ménopause et périménopause|ameli.fr|https://www.ameli.fr/assure/sante/themes/menopause\nIdées reçues sur la ménopause|Santé.fr|https://www.sante.fr/menopause-perimenopause/idees-recues-sur-menopause';

  @override
  String get linksPregnancy =>
      'Grossesse|ameli.fr|https://www.ameli.fr/assure/sante/devenir-parent/grossesse\nLe retour de la sexualité après un accouchement|RTBF|https://www.rtbf.be/article/le-retour-de-la-sexualite-apres-un-accouchement-une-etape-difficile-pour-de-nombreuses-meres-11291729\nRetrouver une sexualité épanouie après un accouchement|La Libre|https://www.lalibre.be/lifestyle/love-sex/2018/02/23/comment-retrouver-une-sexualite-epanouissante-apres-un-accouchement-NF6JRXVHONFQHLUXAA7O4E4KKY/';

  @override
  String get guideIntOrgasmTitle => 'L\'orgasme : toutes tes questions';

  @override
  String get guideIntOrgasmBody =>
      'Feu d\'artifice pour certaines, vague tranquille pour d\'autres, grand absent pour beaucoup : l\'orgasme a mille visages, et aucun n\'est le bon.\n\nChez la plupart des femmes, tout part du clitoris. Ce qu\'on en voit n\'est que la pointe : il se prolonge à l\'intérieur, de part et d\'autre du vagin. Voilà pourquoi la pénétration seule suffit rarement, et pourquoi une main, une langue ou un jouet en plus changent tout.\n\nVaginal ou clitoridien ? Le débat est dépassé : c\'est le même organe, atteint par des chemins différents. Simultané, multiple, bruyant ? De jolis bonus, pas des objectifs.\n\nCe qui aide vraiment : du temps, de l\'excitation avant d\'y aller, la tête pas trop ailleurs, et quelqu\'un, toi comprise, qui sait où et comment.';

  @override
  String get guideIntOrgasmKeep =>
      'Pas d\'orgasme à chaque fois ne veut pas dire que c\'était raté. Le plaisir ne se mesure pas à la ligne d\'arrivée.';

  @override
  String get guideIntNoOrgasmTitle => 'Je n\'arrive pas à jouir : et alors ?';

  @override
  String get guideIntNoOrgasmBody =>
      'Tu fais semblant, ou tu attends que ça vienne en te demandant ce qui cloche. Divulgâchage : rien, probablement.\n\nBeaucoup de femmes jouissent rarement, ou jamais, par la pénétration seule. Ce n\'est pas un défaut de fabrication : c\'est l\'anatomie.\n\nLes freins les plus courants ne sont pas dans le corps : la pression d\'y arriver, la fatigue, la liste de courses qui défile, un partenaire pressé, l\'habitude de passer après.\n\nPar où commencer : seule, sans enjeu, pour repérer ce qui te fait de l\'effet. Puis le montrer ou le dire. Et rayer l\'orgasme de la liste des choses à réussir : il vient plus volontiers quand on ne l\'attend pas à la porte.';

  @override
  String get guideIntNoOrgasmKeep =>
      'Si ça te pèse, ou si c\'était facile avant et plus du tout maintenant, une sexologue ou une sage-femme sait en parler sans gêne.';

  @override
  String get guideIntSoloTitle =>
      'Se caresser : le mode d\'emploi qu\'on ne t\'a jamais donné';

  @override
  String get guideIntSoloBody =>
      'On en parle peu, presque toutes le font. Se masturber n\'est ni un lot de consolation ni une infidélité : c\'est la façon la plus sûre de savoir ce que tu aimes.\n\nPas de bonne méthode. Les doigts, la paume, le jet de la douche, un coussin, un jouet : le clitoris aime la régularité plus que la force, et souvent le contour plus que le centre.\n\nVarie la pression, le rythme, la position. Ajoute du lubrifiant : ça change tout. Prends ton temps, ou pas : cinq minutes avant de dormir comptent aussi.\n\nPendant les règles ? Oui, et certaines disent que ça calme leurs crampes. En couple ? Oui aussi : l\'un n\'enlève rien à l\'autre.';

  @override
  String get guideIntSoloKeep =>
      'Mains propres, jouets lavés après usage, et un jouet à base évasée s\'il doit aller côté anus. Le reste ne regarde que toi.';

  @override
  String get guideIntPeriodSexTitle =>
      'Faire l\'amour pendant les règles : oui, et voilà comment';

  @override
  String get guideIntPeriodSexBody =>
      'Rien ne l\'interdit, beaucoup en ont envie, et le désir monte parfois pile à ce moment-là. Reste la logistique.\n\nUne serviette foncée sur le lit, la douche à deux, une position où tu es allongée : le flux se fait oublier. Tampon et coupe se retirent avant une pénétration.\n\nLe sang fait glisser, l\'orgasme détend : certaines trouvent leurs règles plus légères à vivre après. D\'autres n\'ont envie de rien, et c\'est tout aussi valable.\n\nDis-le simplement : « j\'ai mes règles, ça te va ? » La plupart des partenaires s\'en fichent bien plus que tu ne le crois.';

  @override
  String get guideIntPeriodSexKeep =>
      'Les règles ne protègent ni d\'une grossesse ni des infections.';

  @override
  String get guideIntAnalTitle =>
      'Sexe anal : l\'envie, la préparation, le confort';

  @override
  String get guideIntAnalBody =>
      'Curieuse, tentée, ou sollicitée sans être sûre d\'en avoir envie ? Première règle : ça ne se fait que si tu le veux, toi.\n\nL\'anus ne lubrifie pas et ne se détend pas sur commande. Donc : beaucoup de lubrifiant, beaucoup de temps, et on commence petit. Un doigt, un petit jouet à base évasée, bien avant quoi que ce soit d\'autre.\n\nRespire, et pousse légèrement au moment de l\'entrée : le muscle s\'ouvre. C\'est toi qui donnes le rythme. Une position où tu contrôles la profondeur aide beaucoup.\n\nÇa ne doit pas faire mal. Une gêne au début, oui. Une douleur : on arrête, on remet du lubrifiant, on reprend plus tard, ou jamais.\n\nCôté propreté, une douche suffit. Le reste fait partie du jeu, et tout le monde le sait.';

  @override
  String get guideIntAnalKeep =>
      'Jamais de l\'anus au vagin sans changer de préservatif ou laver ce qui est entré. Le préservatif protège des infections ; avec lui, pas de lubrifiant gras.';

  @override
  String get guideIntLubeTitle =>
      'Lubrifiant : le meilleur ami qu\'on n\'ose pas acheter';

  @override
  String get guideIntLubeBody =>
      'Ce n\'est pas un aveu de panne. C\'est ce qui transforme « ça va » en « encore ».\n\nÀ base d\'eau : passe-partout, compatible avec tout, sèche plus vite, on en remet. À base de silicone : glisse longtemps, parfait sous la douche et pour l\'anal, mais pas avec les jouets en silicone. Les corps gras, huiles et vaseline : agréables en massage, à tenir loin des préservatifs en latex.\n\nQuand ? Dès que ça accroche, pour les caresses comme pour la pénétration, et toujours pour l\'anal. La lubrification varie avec le cycle, le stress, la fatigue, l\'allaitement, l\'âge : elle ne dit rien de ton envie.\n\nAstuce : sur toi et sur l\'autre, et le flacon à portée de main plutôt qu\'au fond du tiroir.';

  @override
  String get guideIntLubeKeep =>
      'Si un produit pique ou irrite, change de formule : plus simple, sans parfum.';

  @override
  String get guideIntDesireCycleTitle => 'Ton désir a ses saisons';

  @override
  String get guideIntDesireCycleBody =>
      'Certains jours tu grimperais aux rideaux, d\'autres tu préfères ta série. Ton cycle y est souvent pour quelque chose.\n\nBeaucoup de femmes sentent leur envie monter vers le milieu du cycle, et retomber avant les règles. D\'autres ont un pic juste avant, ou pendant. Aucun calendrier n\'est universel.\n\nLe tien se lit dans ton journal : note ton désir quelques cycles, et l\'appli te montre tes jours hauts. Pratique pour caler un week-end à deux, ou pour comprendre un « pas ce soir » sans en faire une affaire.\n\nEt puis il y a tout ce qui n\'est pas hormonal : la fatigue, la charge mentale, une dispute pas réglée. Le cycle raconte une partie de l\'histoire, pas toute.';

  @override
  String get guideIntDesireCycleKeep =>
      'Ton rythme est le bon. Il sert à te connaître, pas à te comparer.';

  @override
  String get guideIntSquirtingTitle =>
      'Squirting : ce qu\'on sait, ce qu\'on fantasme';

  @override
  String get guideIntSquirtingBody =>
      'Star des écrans, mystère des chambres : l\'éjaculation féminine intrigue, et beaucoup se demandent si elles « devraient » y arriver.\n\nCertaines femmes émettent du liquide au moment d\'un plaisir intense, parfois beaucoup, parfois quelques gouttes. D\'autres jamais. Les chercheurs ne sont pas tous d\'accord sur ce qu\'il contient ni d\'où il vient exactement.\n\nCe qui est sûr : ce n\'est ni une preuve d\'orgasme, ni un niveau supérieur, ni une performance à offrir. Et ce qu\'on voit dans le porno est mis en scène.\n\nSi ça t\'arrive : une serviette, et aucune honte. Si ça ne t\'arrive pas : il ne te manque rien.';

  @override
  String get guideIntSquirtingKeep =>
      'Curieuse d\'explorer ? De la détente, du temps, la paroi avant du vagin. Sans objectif, c\'est plus drôle.';

  @override
  String get guideIntPainTitle => 'Quand ça fait mal';

  @override
  String get guideIntPainBody =>
      'Serrer les dents en attendant que ça passe n\'a jamais fait partie du contrat. Un rapport qui fait mal, ça se règle, ça ne se supporte pas.\n\nLe plus souvent, c\'est une affaire de temps et de glisse : pas assez d\'excitation, pas assez de lubrifiant, une pénétration trop tôt ou trop profonde. Ralentir, changer d\'angle, remettre du lubrifiant suffit souvent.\n\nParfois le corps se ferme tout seul, même quand la tête dit oui. Parfois la douleur est profonde, ou revient à certains moments du cycle. Là, ce n\'est plus une question de technique.\n\nDis stop dès que ça fait mal. Quelqu\'un qui tient à toi préfère mille fois s\'arrêter.';

  @override
  String get guideIntPainKeep =>
      'Une douleur qui revient, des brûlures, des saignements après les rapports : parles-en à une sage-femme ou à un médecin. Note-la dans ton journal, ça aide à en parler.';

  @override
  String get guideIntTearsTitle => 'Pleurer après l\'amour';

  @override
  String get guideIntTearsBody =>
      'C\'était bien, et pourtant les larmes montent. Ou un coup de blues tombe d\'un coup, sans raison.\n\nÇa arrive à beaucoup de monde. Après une forte montée, le corps redescend : la tension lâche, et parfois ça déborde.\n\nÇa ne veut pas dire que tu es triste, ni que quelque chose cloche entre toi et l\'autre. Parfois si : le corps sent avant la tête qu\'on n\'avait pas vraiment envie.\n\nSur le moment, dis-le simplement : « je ne sais pas pourquoi, ça va passer ». Demande des bras ou de l\'air, selon ce qui te fait du bien.';

  @override
  String get guideIntTearsKeep =>
      'Si ça revient souvent, ou si ça remue des souvenirs difficiles, en parler à quelqu\'un dont c\'est le métier fait du bien.';

  @override
  String get guideIntSayItTitle =>
      'Dire ce que tu aimes, et ce que tu n\'aimes pas';

  @override
  String get guideIntSayItBody =>
      'Personne ne lit dans les pensées, même au lit. Et « plus à gauche » n\'a jamais tué l\'ambiance.\n\nLe plus simple : guider en direct. Une main sur la sienne, un « oui, comme ça », un « moins fort ». Les mots courts marchent mieux que les longs discours.\n\nPour les sujets plus gros, une envie nouvelle ou un geste que tu n\'aimes plus, choisis un moment habillé : en voiture, en marchant, pas juste après.\n\nCommence par ce qui te plaît : « j\'adore quand tu… ». Puis l\'envie : « j\'aimerais essayer… ». Et un non reste un non, dans les deux sens.';

  @override
  String get guideIntSayItKeep =>
      'Dire non à une pratique n\'est pas dire non à la personne. Tu peux changer d\'avis à tout moment, même en cours de route.';

  @override
  String get guideIntNoDesireTitle => 'Plus envie du tout : par où reprendre';

  @override
  String get guideIntNoDesireBody =>
      'Tu l\'aimes, il ou elle te plaît, et pourtant : rien. Le désir en berne est l\'un des sujets les plus partagés, et les moins avoués.\n\nCherche d\'abord du côté de la vie : sommeil en miettes, charge mentale, rancœur qui traîne, corps qu\'on n\'aime pas ces temps-ci. Le désir a besoin de place, et la place manque.\n\nChez beaucoup de femmes, l\'envie ne tombe pas du ciel : elle vient en chemin, une fois les caresses commencées. Attendre d\'avoir envie pour s\'y mettre, c\'est parfois attendre longtemps.\n\nCe qui relance : du temps à deux sans objectif, des contacts qui ne mènent à rien d\'obligé, de la nouveauté, et des moments seule avec ton propre corps.';

  @override
  String get guideIntNoDesireKeep =>
      'Si la baisse est brutale, ou arrive avec un nouveau médicament, un bébé ou des cycles qui changent, parles-en à un professionnel de santé.';

  @override
  String get guideIntAfterBabyTitle =>
      'Après un bébé : le sexe qui revient, ou pas tout de suite';

  @override
  String get guideIntAfterBabyBody =>
      'Entre les nuits en pointillé, le corps qui a changé et un bébé accroché à toi, le désir a de bonnes raisons de se faire attendre.\n\nIl n\'y a pas de date. Certaines reprennent au bout de quelques semaines, d\'autres de plusieurs mois. La bonne, c\'est quand tu en as envie et que ça ne fait pas mal.\n\nLe corps lubrifie souvent moins, surtout en allaitant : le lubrifiant devient indispensable. Commence par des caresses, et garde la main sur le rythme.\n\nEt le couple ? Dis où tu en es, même si c\'est « pas maintenant ». La tendresse sans suite obligée fait le pont.';

  @override
  String get guideIntAfterBabyKeep =>
      'Une douleur qui dure aux rapports se signale à la sage-femme ou au médecin. Une grossesse est possible avant même le retour des règles.';

  @override
  String get guideIntMidlifeTitle => 'Périménopause : le sexe change de règles';

  @override
  String get guideIntMidlifeBody =>
      'Plus envie, ou envie mais ça frotte ? À la périménopause, le désir joue à cache-cache et le corps lubrifie moins. Ça ne dit rien de ton couple ni de toi.\n\nCe qui change : il faut souvent plus de temps, plus de caresses, et du lubrifiant sans se poser de question. Ce qui ne change pas : ta capacité à prendre du plaisir.\n\nBeaucoup de femmes racontent une sexualité plus libre à cet âge : on sait ce qu\'on aime, on ose le dire, on ne fait plus semblant.\n\nLes nuits hachées et les bouffées de chaleur n\'aident pas l\'envie. S\'en occuper, c\'est aussi s\'occuper de sa vie sexuelle.';

  @override
  String get guideIntMidlifeKeep =>
      'La sécheresse et les douleurs ne sont pas une fatalité : un pharmacien ou un médecin peut t\'en parler. Une grossesse reste possible.';

  @override
  String get guideIntOnScheduleTitle =>
      'Projet bébé : quand faire l\'amour devient un planning';

  @override
  String get guideIntOnScheduleBody =>
      'Au début c\'était excitant. Trois mois plus tard, c\'est « ce soir, il faut ». Le désir sur commande, personne n\'aime ça.\n\nC\'est très courant, et ça ne dit rien de ton couple. La pression coupe l\'envie, chez toi comme chez l\'autre.\n\nCe qui allège : ne pas tout miser sur un seul soir, garder des moments sans enjeu, et de temps en temps ranger le calendrier.\n\nDis-le à l\'autre : « j\'ai envie de toi, pas seulement d\'un bébé ». Ça change l\'ambiance.';

  @override
  String get guideIntOnScheduleKeep =>
      'L\'appli montre une fenêtre estimée, pas un rendez-vous obligatoire : c\'est une fourchette, et elle varie.';

  @override
  String get guideTopicIntimacy => 'Intimité';

  @override
  String get guideKeepTitle => 'À retenir';

  @override
  String get guideSourcesIntimacy =>
      'Écrit pour l\'appli, sur le ton d\'un magazine. Ce qui touche à la sécurité sera relu par un professionnel de santé.';

  @override
  String get kioskTitle => 'Le kiosque du jour';

  @override
  String get kioskBody =>
      'Des articles récents de la presse, choisis chaque jour';

  @override
  String get kioskIntimacyTitle => 'Le kiosque Intimité';

  @override
  String get kioskIntimacyBody =>
      'Sexe, désir, témoignages : ce que la presse écrit en ce moment';

  @override
  String get kioskNote =>
      'Sélection automatique dans la presse : personne n\'a relu ces articles pour toi, et aucun n\'est un avis médical.';

  @override
  String get phaseTitle => 'Ton cycle aujourd\'hui';

  @override
  String phaseEstimated(String phase) {
    return '$phase · estimation';
  }

  @override
  String get phaseHormones => 'Hormones';

  @override
  String get phaseMood => 'Humeur et énergie';

  @override
  String get phaseBody => 'Corps';

  @override
  String get phaseTip => 'Le conseil du jour';

  @override
  String get phaseMore => 'Décrypter';

  @override
  String get phaseLess => 'Réduire';

  @override
  String get phaseNote =>
      'Repères généraux, en attente de relecture par un professionnel de santé. Chaque corps est différent : le tien peut ne pas les suivre.';

  @override
  String phaseYours(String signs) {
    return 'Autour de ce jour, tu as souvent noté : $signs.';
  }

  @override
  String get phasePerimenopause =>
      'Avec un cycle qui change, les hormones suivent ce schéma de moins près : prends-le comme un repère large.';

  @override
  String get phaseConceive =>
      'Ta fenêtre de fertilité estimée est indiquée sur l\'anneau, plus haut.';

  @override
  String get phaseDiscovering =>
      'Les premiers cycles sont souvent irréguliers : ils peuvent mettre quelques années à se régler.';

  @override
  String get phasePeriodName => 'Tes règles';

  @override
  String get phasePeriodHormones =>
      'Œstrogènes et progestérone sont au plus bas. C\'est cette chute qui déclenche les saignements.';

  @override
  String get phasePeriodMood =>
      'L\'énergie est souvent plus basse les premiers jours, puis remonte au fil des jours.';

  @override
  String get phasePeriodBody =>
      'Les crampes dans le ventre ou le bas du dos sont fréquentes, surtout les deux premiers jours : l\'utérus se contracte pour évacuer sa muqueuse.';

  @override
  String get phasePeriodTip1 =>
      'Du chaud sur le ventre, bouillotte ou bain : ça soulage beaucoup de femmes.';

  @override
  String get phasePeriodTip2 =>
      'Bouger doucement, marcher ou s\'étirer, aide souvent plus que rester immobile.';

  @override
  String get phasePeriodTip3 =>
      'Une journée au ralenti n\'est pas une journée perdue. Si tu peux, garde le plus lourd pour plus tard dans la semaine.';

  @override
  String get phaseAfterName => 'Après tes règles';

  @override
  String get phaseAfterHormones =>
      'Les œstrogènes remontent jour après jour, pendant qu\'un ovule mûrit dans un ovaire.';

  @override
  String get phaseAfterMood =>
      'Beaucoup décrivent plus d\'énergie, les idées plus claires et l\'humeur plus légère.';

  @override
  String get phaseAfterBody =>
      'Souvent les jours les plus calmes pour le corps : moins de douleurs, une peau souvent plus nette.';

  @override
  String get phaseAfterTip1 =>
      'Une bonne semaine pour lancer ce que tu repoussais.';

  @override
  String get phaseAfterTip2 =>
      'Si tu aimes le sport, c\'est souvent là que l\'effort paraît le plus facile.';

  @override
  String get phaseAfterTip3 =>
      'Tu te sens bien ? Note-le aussi : le journal n\'est pas réservé aux mauvais jours.';

  @override
  String get phaseMidName => 'Milieu de ton cycle';

  @override
  String get phaseMidHormones =>
      'Les œstrogènes sont au plus haut, puis un pic d\'une autre hormone, la LH, déclenche l\'ovulation. Son jour n\'est ici qu\'une estimation.';

  @override
  String get phaseMidMood =>
      'L\'énergie et la confiance sont souvent au plus haut ces jours-ci. Pas chez toutes, ni à chaque cycle.';

  @override
  String get phaseMidBody =>
      'Des pertes plus claires et filantes sont fréquentes. Certaines sentent un tiraillement d\'un côté du bas-ventre.';

  @override
  String get phaseMidTip1 =>
      'Envie de voir du monde ? Ce sont souvent les jours pour ça.';

  @override
  String get phaseMidTip2 =>
      'Regarde comment tes pertes changent : c\'est l\'un des signaux les plus nets du cycle.';

  @override
  String get phaseMidTip3 =>
      'Un bon moment pour ce qui demande du cran : une discussion, une demande, une première fois.';

  @override
  String get phaseSecondName => 'Deuxième partie de ton cycle';

  @override
  String get phaseSecondHormones =>
      'Après l\'ovulation, la progestérone prend le relais et prépare la muqueuse de l\'utérus. Les œstrogènes restent modérés.';

  @override
  String get phaseSecondMood =>
      'Beaucoup se sentent plus calmes, plus tournées vers l\'intérieur. L\'énergie baisse souvent d\'un cran.';

  @override
  String get phaseSecondBody =>
      'La température du corps est un peu plus haute. Seins sensibles, plus d\'appétit ou sommeil plus léger sont fréquents.';

  @override
  String get phaseSecondTip1 =>
      'Plus faim que d\'habitude ? C\'est fréquent à ce moment du cycle, pas un manque de volonté.';

  @override
  String get phaseSecondTip2 =>
      'Te coucher à heure régulière aide quand le sommeil devient plus léger.';

  @override
  String get phaseSecondTip3 =>
      'Un bon moment pour finir ce qui est en cours plutôt que d\'en lancer.';

  @override
  String get phaseBeforeName => 'Avant tes règles';

  @override
  String get phaseBeforeHormones =>
      'Sans grossesse, progestérone et œstrogènes chutent. Cette chute explique l\'essentiel de ce qu\'on ressent ces jours-ci.';

  @override
  String get phaseBeforeMood =>
      'Irritabilité, moral en baisse, larmes faciles : c\'est fréquent, et ça passe avec l\'arrivée des règles.';

  @override
  String get phaseBeforeBody =>
      'Ballonnements, seins tendus, maux de tête, fatigue, boutons : fréquents aussi.';

  @override
  String get phaseBeforeTip1 =>
      'Ce que tu ressens est réel, et ça a une cause. Pas besoin de te le reprocher.';

  @override
  String get phaseBeforeTip2 =>
      'Prépare ton sac : tes règles sont estimées bientôt.';

  @override
  String get phaseBeforeTip3 =>
      'Agenda allégé, coucher plus tôt : ces jours-là le demandent souvent.';
}
