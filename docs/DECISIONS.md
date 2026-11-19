# Fycle — décisions

À mettre à jour à chaque changement. Une décision, sa raison, sa date.

## Décisions prises (18 novembre 2026)

1. **Nom : Fycle.** Se prononce comme « cycle ». Le F est un clin d'œil, sans sens officiel : ne pas présenter le nom comme « Free + cycle », puisque l'appli comporte un achat.
   Titre en store : « Fycle: Period Tracker ».
   Signature : « Monthly cycle. No monthly fee. » (19 novembre 2026, remplace « Fycle. Rhymes with cycle. »)

2. **Plateformes : iPhone d'abord, Android ensuite, web plus tard.**
   Raison : la première utilisatrice a un iPhone, et l'objectif est une vraie appli de store.

3. **Stack : Flutter / Dart.**
   Raison : rendu natif, un seul code pour les deux mobiles, compilable dans le cloud pour iOS.

4. **Données : local uniquement.** Base chiffrée, pas de compte, pas de serveur.
   Raison : c'est la promesse centrale, et cela supprime tout coût récurrent.

5. **Modèle économique : socle gratuit sans pub, pack Pro à vie en achat unique facultatif** (achat intégré non consommable).
   Historique : décidé le 18 novembre 2026, remplacé le 19 par « payante au téléchargement », rétabli le même jour.
   Raison : la première utilisatrice a abandonné les autres applis à cause du prix et n'a jamais payé pour une appli. Payer avant d'avoir essayé freine le téléchargement et le bouche-à-oreille.
   Le pack Pro est proposé après un ou deux cycles d'utilisation, jamais à l'installation, et sans essai qui se transforme en prélèvement.
   Conséquence technique : un paquet d'achat intégré, seule dépendance autorisée à communiquer, via le store du système. Le code de `lib/` reste sans aucune API réseau.
   Objectif de revenu : 400 € par mois.

6. **Build : développement sous Windows, pas de Mac.**
   iOS est compilé et signé par un service de build cloud, puis distribué par TestFlight.

7. **Positionnement : frontal sur la confidentialité et l'absence d'abonnement.**
   Lignes : « Free. No ads. No account. Pay once if you want more. » et « No leaks. Of any kind. »
   Ne jamais citer de concurrent.

8. **Réglementaire : aucune allégation médicale.**
   Contraception exclue. Avis d'un spécialiste avant toute fonction de fertilité ou de grossesse.

9. **Langues : anglais et français dès la V1.**

## Décisions du jalon 0 (19 novembre 2026)

10. **Architecture en trois couches.** `lib/domain/` (Dart pur : modèles, prédiction, statistiques), `lib/data/` (base chiffrée, clé, export et import), `lib/ui/` (écrans et état). Les textes sont dans `lib/l10n/`.
    Raison : la logique métier se teste sans interface, et un seul dossier touche au disque.

11. **Pas de paquet de gestion d'état, de navigation ni de calendrier au départ.** Les outils intégrés à Flutter suffisent.
    Raison : chaque paquet en moins est un risque réseau en moins. À revoir si l'interface le demande.

12. **Modèle de données.** L'intensité des règles est stockée jour par jour ; le début et la fin des règles en sont déduits. Les dates sont des jours de calendrier, sans heure ni fuseau.
    Raison : saisie en deux gestes, données qui ne peuvent pas se contredire, pas de décalage en voyage.

13. **Identifiant de l'appli : `app.fycle`** (iOS et Android). Définitif une fois l'appli publiée.

14. **Flutter 3.50.0 stable, Dart 3.14.** La télémétrie des outils Flutter et Dart est désactivée, sur le poste de développement et dans l'intégration continue.

15. **Dépendances du jalon 0.** `material_ui` (flutter.dev : les widgets Material ne font plus partie du SDK), `intl` et `flutter_localizations` (traductions), `flutter_lints` (analyse). `cupertino_icons`, ajouté par le modèle de projet, est retiré car inutilisé.
    La liste blanche `tool/allowed_dependencies.txt` couvre aussi les dépendances indirectes.

16. **Trois garde-fous dans `test/guardrails/`.** Dépendances hors liste blanche ; API réseau dans `lib/`, permission INTERNET dans le manifeste Android de production ou exception de sécurité de transport dans la configuration iOS ; import de Flutter, du stockage ou de l'interface depuis `lib/domain/`.

17. **Intégration continue : GitHub Actions.** Le SDK Flutter est cloné depuis son dépôt officiel plutôt qu'installé par une action tierce.
    Raison : chaîne de build plus courte.

18. **Code de traduction généré.** Les fichiers `lib/l10n/app_localizations*.dart` sont générés, commités et exclus de l'analyse. `lib/ui/app.dart` déclare lui-même les délégués de traduction, car la liste générée pointe encore vers les classes d'avant `material_ui`. À simplifier quand le générateur sera à jour.

19. **Objectifs produit** (détail dans `docs/SPEC.md`). Confiance, respect du portefeuille, simplicité, bilan pour le médecin, reprise d'un historique existant. Fycle se présente comme un journal d'observation personnelle, avec un avertissement visible.
    Raison : ce sont les points faibles des applis installées (abonnements, méfiance sur les données, surcharge de contenus).
    Ajouts au socle gratuit : suppression intégrale des données en un geste, avertissement, import d'un historique. La sauvegarde automatique dans un cloud est écartée, car elle contredit la règle 1.

## Décisions du jalon 1 (19 novembre 2026)

20. **Jour de calendrier : `CalendarDay`** (`lib/domain/calendar_day.dart`). Année, mois, jour, sans heure ni fuseau. Les calculs de jours passent par l'UTC en interne.
    Raison : pas de décalage en voyage ni au changement d'heure (applique la décision 12).

21. **Intensité des règles : quatre niveaux**, `spotting` (traces), `light`, `medium`, `heavy`. Un jour sans saignement n'a pas d'entrée.

22. **Début des règles déduit de l'intensité.** Un jour de saignement démarre de nouvelles règles s'il suit au moins 7 jours sans saignement ; sinon il appartient aux règles en cours. Les traces sont ignorées : elles ne démarrent jamais des règles.
    Raison : une pause d'un ou deux jours au milieu des règles ne doit pas créer un faux cycle.

23. **Moteur de prédiction : `PeriodPredictor`.** Entrée : dates de début de règles et, si elle est connue, durée habituelle déclarée. Sortie : fourchette de dates, confiance (`low`, `medium`, `high`), durée estimée, nombre de cycles utilisés. Jamais de date unique. Le moteur ne connaît pas la date du jour : signaler un retard relève de l'interface (jalon 3).
    - **Cycles retenus** : les 6 derniers (environ six mois : assez pour lisser, assez récent pour suivre un changement).
    - **Pondération** : 6, 5, 4, 3, 2, 1 du plus récent au plus ancien.
    - **Cycles écartés** : moins de 15 jours (erreur de saisie) ; plus de 90 jours (trou dans les données) ; plus de 1,7 fois la médiane des autres cycles (règles probablement non saisies : un oubli donne un cycle environ deux fois plus long).
    - **Un oubli est une exception.** Si la moitié des cycles ou plus dépassent ce seuil de 1,7, aucun n'est écarté : c'est le rythme réel, et la fourchette s'élargit. Avec deux cycles seulement, rien n'est donc écarté.
    - **Largeur de la fourchette**, de chaque côté : 1,5 fois l'écart-type pondéré, arrondi au jour supérieur, plafonné à 10 jours. Minimum : 4 jours avec 1 cycle, 3 avec 2, 2 avec 3 à 5, 1 avec 6.
    - **Confiance** : `high` avec au moins 4 cycles et 2 jours ou moins de chaque côté ; `medium` avec au moins 2 cycles et 4 jours ou moins ; `low` sinon.
    - **Peu de données** : aucune date, pas de prédiction. Une seule date : durée déclarée ±5 jours, ou à défaut 28 jours ±7 jours, confiance `low`.
    - **Durée déclarée** : avec 1 ou 2 cycles, elle compte comme un cycle de poids 1 ; avec un seul cycle, elle sert aussi de référence pour le seuil de 1,7. À partir de 3 cycles, elle n'est plus utilisée. Elle doit être comprise entre 15 et 90 jours.
    - Paramètres de départ, à réviser avec les retours des premières utilisatrices.

## Décisions du jalon 2 (19 novembre 2026)

24. **Base chiffrée : paquet `sqlite3` seul, variante SQLite3 Multiple Ciphers** (réglage `hooks: user_defines: sqlite3: source: sqlite3mc` dans `pubspec.yaml`). Chiffrement ChaCha20-Poly1305, clé brute de 256 bits, sans mot de passe.
    - **Téléchargement à la compilation, accepté par l'utilisateur le 19 novembre 2026.** Le paquet télécharge une bibliothèque précompilée depuis les publications GitHub de son dépôt, sur le poste de développement et sur le service de build, jamais sur le téléphone. Le fichier est contrôlé par une empreinte sha256 inscrite dans le paquet. C'est de même nature que `flutter pub get`. La règle 4 de `CLAUDE.md` a été précisée en ce sens : aucun appel réseau depuis l'appli, téléchargement à la compilation admis s'il est vérifié par empreinte.
    - Solution de repli si ce téléchargement devenait inacceptable : compiler SQLite3 Multiple Ciphers depuis des sources rangées dans le dépôt (réglage `source: source`). Non testé.
    - L'appli refuse d'ouvrir la base si la bibliothèque chargée ne sait pas chiffrer.
    - `drift` est écarté : trois petites tables ne justifient pas une soixantaine de paquets d'outillage en plus. À revoir si le schéma grossit.

25. **Clé de la base.** 32 octets tirés au hasard sur l'appareil, rangés par `flutter_secure_storage` dans le Keychain (iOS) ou le Keystore (Android). Sur iOS, la clé ne quitte pas l'appareil : pas de synchronisation iCloud, pas de restauration sur un autre téléphone.
    - Base présente mais clé absente (téléphone restauré depuis une sauvegarde) : le contenu est irrécupérable. L'appli le signale sans rien effacer ; l'interface proposera de repartir de zéro ou d'importer un export.
    - Clé présente mais base absente (iOS conserve le trousseau après désinstallation) : la clé est remplacée par une nouvelle.
    - Android : sauvegarde automatique du système désactivée (`allowBackup="false"`), version minimale Android 7.0 (API 24), exigée par `flutter_secure_storage`.

26. **Schéma de la base, version 1** (`PRAGMA user_version`). `day_entry` (jour, intensité, douleur, humeur, note), `day_symptom` (jour, symptôme), `setting` (nom, valeur ; contient la durée habituelle du cycle). Les jours sont des dates ISO en texte (`2026-03-05`), les choix sont les noms des valeurs en anglais.
    Raison : lisible, triable, et l'ordre des listes peut changer sans casser les données. Conséquence : ne jamais renommer une valeur, seulement en ajouter. Une valeur inconnue, écrite par une version plus récente, est ignorée à la lecture.
    Un jour où rien n'est saisi n'a pas de ligne. Le contenu supprimé est écrasé dans le fichier (`secure_delete`).

27. **Listes de départ**, à revoir au jalon 3 avec l'interface. Douleur : `none`, `mild`, `moderate`, `severe`. Humeur, une par jour : `happy`, `calm`, `sad`, `anxious`, `irritable`. Symptômes : `cramps`, `headache`, `backPain`, `breastTenderness`, `bloating`, `nausea`, `fatigue`, `acne`, `cravings`, `insomnia`.

28. **Fichier d'export chiffré (`.fycle`), format version 1.** Protégé par un mot de passe choisi par l'utilisatrice (8 caractères minimum), car la clé de l'appareil disparaît avec lui. Clé dérivée par Argon2id (19 Mio, 2 passes, réglages écrits dans le fichier), contenu chiffré en AES-256-GCM, en-tête authentifié. Le contenu est du JSON, avec son propre numéro de version. Description octet par octet dans `lib/data/backup_codec.dart`.
    - Mot de passe oublié : fichier perdu, sans récupération. À dire clairement à l'écran.
    - Mauvais mot de passe et fichier abîmé ne se distinguent pas, par construction.
    - Paquet `cryptography` (Dart pur). Le calcul prend environ une demi-seconde sur PC ; à mesurer sur téléphone, et à déplacer hors du fil de l'interface si nécessaire.

29. **Import : il remplace tout**, en une seule opération. Un fichier illisible ou un mauvais mot de passe ne modifie rien.
    Raison : comportement simple et prévisible pour une restauration. Une fusion jour par jour pourra venir avec l'import depuis d'autres applis.

30. **Export CSV.** Une ligne par jour, colonnes `date, flow, pain, mood, symptoms, note`, valeurs en anglais, non chiffré. Une note qui commence comme une formule de tableur est neutralisée par une apostrophe. Traduire les en-têtes et les valeurs relève de l'interface (jalon 3).

31. **Suppression intégrale.** La clé est effacée d'abord, puis le fichier de la base. Sans la clé, ce qui resterait physiquement sur la mémoire du téléphone est illisible.

32. **Dépendances du jalon 2.** `sqlite3`, `flutter_secure_storage`, `path_provider`, `cryptography`, relus le 19 novembre 2026 : aucun code réseau hors du script de compilation de `sqlite3` (décision 24) et de sa partie web, inutilisée ; aucune permission Android. `flutter_secure_storage` embarque la bibliothèque Tink de Google sur Android (chiffrement, sans réseau). Une quarantaine de dépendances indirectes sont ajoutées à la liste blanche.
    `share_plus` et `file_picker` sont reportés au jalon 3 : ils servent à l'interface (fenêtre de partage, choix d'un fichier). `file_picker` seul pourrait suffire, à vérifier.

33. **Ce qui ne se vérifie que sur un vrai téléphone.** Le trousseau (la clé survit à un redémarrage, disparaît à la suppression), le dossier privé de l'appli, et la durée de la dérivation de clé. Tout le reste est couvert par les tests sous Windows, avec un trousseau factice en mémoire.

## Décisions du jalon 3 (19 novembre 2026)

34. **Écrans.** Ouverture (`lib/ui/root_screen.dart`), démarrage, accueil (prédiction, calendrier du mois, bouton « Saisir aujourd'hui »), saisie du jour dans un panneau, réglages. Le démarrage s'affiche tant que la base est vide.
    - **Démarrage** : la date des dernières règles est obligatoire, la durée habituelle facultative. La date est enregistrée comme un jour de règles d'intensité `medium`, modifiable depuis le calendrier (validé par l'utilisateur) : le modèle ne connaît que l'intensité jour par jour (décision 12). Une sauvegarde peut aussi être restaurée dès cet écran.
    - **Saisie** : chaque choix est enregistré aussitôt, sans bouton de validation. Deux gestes suffisent : ouvrir, toucher l'intensité. Toucher de nouveau un choix l'annule. Les jours à venir ne se saisissent pas.
    - **Base illisible** (décision 25) : l'écran l'explique et propose de repartir de zéro ou de restaurer un fichier de sauvegarde. Rien n'est effacé sans confirmation.

35. **État de l'appli sans paquet** (décision 11 maintenue). Un seul objet, `CycleModel` (`ChangeNotifier`), relit la base et recalcule la prédiction après chaque saisie. Le calendrier est une grille faite à la main. Ce dont l'interface dépend à l'extérieur (ouverture de la base, fenêtres de fichiers, date du jour) passe par `AppEnvironment`, que les tests remplacent.

36. **Retard et règles en cours : `cycleStatusOn`** (`lib/domain/cycle_status.dart`, Dart pur). La date du jour est un paramètre ; le moteur de prédiction ne la connaît toujours pas (décision 23). Six cas : pas d'estimation, règles en cours (« jour N »), fourchette à venir, fourchette en cours, fourchette dépassée de N jours, estimation périmée au-delà de 90 jours.
    Le texte reste neutre : « période passée depuis N jours », suivi de « ce n'est qu'une estimation ». Aucun conseil, aucune interprétation (règle 7). La carte indique toujours une fourchette, ce sur quoi elle se fonde et sa fiabilité.

37. **Calendrier.** Règles saisies : disque plein. Règles prévues : anneau. Autre saisie ou traces : point. La forme distingue les trois, pas seulement la couleur. L'intensité n'est pas représentée sur le calendrier, pour qu'il reste lisible ; elle se lit en ouvrant le jour. Chaque jour porte un libellé complet pour le lecteur d'écran.

38. **Listes de la décision 27 confirmées** par l'utilisateur, sans ajout. Libellés français : les humeurs sont des noms (« Joie », « Anxiété »…) pour éviter les accords.

39. **Fichiers : `file_picker` seul** (13.4.0), derrière l'interface `FileGateway` (`lib/data/file_gateway.dart`). Relu le 19 novembre 2026.
    - Il couvre les trois besoins : enregistrer le `.fycle`, enregistrer le CSV, choisir un fichier à restaurer. C'est l'utilisatrice qui choisit l'emplacement, dans la fenêtre du système.
    - Aucune permission Android, aucune clé à ajouter sur iOS (iOS 14 minimum ; le projet vise iOS 15). Aucun code réseau sur téléphone.
    - Onze paquets ajoutés à la liste blanche : `file_picker`, `file_picker_platform_interface`, `android_file_picker`, `file_picker_darwin`, `file_picker_linux`, `windows_file_picker`, `file_picker_web`, `cross_file`, `dbus`, `xml`, `petitparser`.
    - Deux réserves, sans effet sur téléphone : `dbus` contient du code de communication locale (socket D-Bus) qui ne tourne que sous Linux ; `file_picker_web` et `cross_file` manipulent des fichiers dans le navigateur, sur le web seulement.
    - Le paquet laisse une copie des fichiers enregistrés ou choisis dans le dossier temporaire de l'appli. `SystemFileGateway` l'efface après chaque opération : le CSV n'est pas chiffré.
    - Le choix d'un fichier n'est pas filtré par extension : ni iOS ni Android ne connaissent `.fycle`. Le contenu est vérifié à la lecture.
    - **`share_plus` est écarté** : dix paquets de plus, dont `url_launcher`, et sa fenêtre de partage (messagerie, envoi à proximité) pousse à faire sortir des données de santé du téléphone.

40. **Export et import à l'écran.**
    - Export chiffré : mot de passe saisi deux fois, 8 caractères minimum, sous un avertissement en rouge : mot de passe oublié, fichier perdu, sans récupération.
    - Import : confirmation avant de tout remplacer (décision 29). Un mauvais mot de passe se corrige sans rechoisir le fichier, et ne modifie rien.
    - CSV : avertissement « fichier non chiffré » avant l'export.
    - Suppression intégrale : un geste dans les réglages, une confirmation, puis retour à l'écran de démarrage avec une clé neuve.

41. **CSV traduit sans texte d'interface dans `lib/data/`.** `daysToCsv` reçoit un objet `CsvLabels` (en-têtes et nom de chaque choix). L'interface le construit depuis ses traductions ; par défaut, ce sont les noms anglais stockés. La date reste au format ISO dans toutes les langues. Complète la décision 30.

42. **Écran qui ne fige pas.** La dérivation de clé de l'export et de l'import s'exécute dans un fil séparé (`Isolate.run`, réglage `codecInBackground`, actif dans l'appli), avec une barre de progression. Les lectures et écritures de la base restent directes : trois petites tables, quelques millisecondes. À mesurer sur iPhone au jalon 5.

43. **Sauvegarde iCloud : le fichier de la base en sera exclu** (validé par l'utilisateur). Raison : sans sa clé, il est inutilisable une fois restauré, et l'exclure applique « rien ne quitte le téléphone » à la lettre. Le code natif (quelques lignes en Swift) sera écrit au jalon 5, avec la première compilation iPhone : il ne se compile ni ne se vérifie sous Windows. D'ici là, le cas de la base restaurée sans clé est géré par l'écran « base illisible ».

44. **Accessibilité.** Mode sombre suivant le réglage du téléphone. Tous les écrans défilent et tiennent avec un texte agrandi 2,5 fois sur un petit écran (320 × 568). Exception : le sélecteur de date du système, à la mise en page fixe, est plafonné à 1,3 fois. Les tests vérifient le contraste des textes, la taille des zones tactiles (44 points) et la présence d'un libellé sur chaque bouton, en anglais et en français, en clair et en sombre.

45. **Ce qui est vérifié, et où.**
    - Sous Windows, par les tests de widgets (base chiffrée réelle dans un dossier temporaire, trousseau et fenêtres de fichiers factices, date fixe, données fictives) : tous les parcours des décisions 34 à 44.
    - **Android n'a pas pu être compilé en local** : aucun SDK Android n'est installé sur le poste de développement (constaté le 19 novembre 2026). À installer avant le passage manuel sur Android.
    - En attente d'un iPhone (jalon 5) : les fenêtres de fichiers d'iOS, VoiceOver, le rendu réel, la durée de la dérivation de clé, l'exclusion iCloud, et tout ce que liste la décision 33.

## Décisions du jalon 4 (19 novembre 2026)

46. **Paquets des rappels et du verrouillage**, relus le 19 novembre 2026 et validés par l'utilisateur : `flutter_local_notifications` 23.0.3, `timezone` 0.11.2, `local_auth` 3.0.2.
    - Aucun code réseau dans les deux premiers ni dans `local_auth`. Aucune permission INTERNET. Permissions Android apportées : afficher des notifications, vibrer, utiliser la biométrie.
    - **Réserve acceptée : `timezone` tire le paquet `http`.** Il est imposé par `flutter_local_notifications` et contient deux fichiers capables de télécharger des données de fuseaux (`standalone.dart`, `browser.dart`). Ni le paquet de notifications ni Fycle ne les importent : ce code n'est pas embarqué dans l'appli. Le garde-fou réseau échoue si `lib/` importe l'un de ces deux fichiers, ou `http`. Même nature que les réserves des décisions 32 et 39.
    - Quatorze paquets ajoutés à la liste blanche : `flutter_local_notifications` et ses variantes `_platform_interface`, `_linux`, `_windows`, `_web` ; `timezone`, `http`, `http_parser` ; `local_auth` et ses variantes `_android`, `_darwin`, `_platform_interface`, `_windows` ; `flutter_plugin_android_lifecycle`.
    - Alternative écartée : écrire nous-mêmes le code natif des notifications, impossible à compiler et à vérifier sous Windows.

47. **Rappels : calculés en Dart pur, un par jour** (`lib/domain/reminders.dart`, fonction `planReminders`). Tous désactivés par défaut.
    - **Règles qui approchent** : une seule notification, 1, 2 ou 3 jours (2 par défaut) avant le premier jour de la fourchette de `PeriodPredictor`, à l'heure choisie (9 h par défaut).
    - **Rappel de saisie** : une notification par jour à l'heure choisie (20 h par défaut), programmée 14 jours à l'avance, sauf les jours déjà saisis. Sans ouverture de l'appli pendant 14 jours, il se tait : pas de relance sans fin.
    - Un rappel dont le moment est passé n'est jamais envoyé en retard.
    - Tout est recalculé et remplacé après chaque saisie, chaque changement de réglage, à l'ouverture et à chaque retour au premier plan.
    - L'autorisation n'est demandée qu'au moment où l'utilisatrice active un rappel. En cas de refus, l'interrupteur reste éteint et un message explique où l'autoriser.

48. **Heure des rappels, voyage et changement d'heure.** `CalendarDay` reste sans fuseau (décision 20). Chaque rappel est un jour et une heure d'horloge, convertis en instant précis au moment de la programmation, avec l'horloge du téléphone ce jour-là. Aucune règle « tous les jours » n'est confiée au système, et aucune base de fuseaux n'est chargée.
    - Changement d'heure : toujours juste, chaque jour étant converti séparément.
    - Voyage : un rappel déjà programmé sonne à l'heure du fuseau de départ jusqu'à la prochaine ouverture de l'appli, qui reprogramme tout.

49. **Texte des notifications : neutre, sans option.** Titre « Fycle ». « Un coup d'œil à votre calendrier ? » pour les règles qui approchent, « Un moment pour noter votre journée ? » pour la saisie. Rien ne mentionne les règles, le cycle, un retard ou la santé : un test le vérifie dans les deux langues. Le nom de l'appli reste visible. Sur Android, le texte est masqué sur l'écran verrouillé.

50. **Réglages propres à l'appareil.** Rappels et verrouillage sont rangés dans une nouvelle table `device_setting` de la base chiffrée (schéma version 2). Ils ne partent pas dans l'export et un import ne les touche pas : sur un nouveau téléphone, tout est éteint. « Tout supprimer » les efface et annule les rappels programmés. Complète la décision 26.

51. **Verrouillage : celui du téléphone, sans code propre à Fycle.** Face ID ou empreinte, avec le code du téléphone en secours (`lib/data/device_auth.dart`).
    - Raison : rien de plus à stocker ni à oublier, et le système limite lui-même les essais. Limite acceptée : qui connaît le code du téléphone ouvre aussi Fycle. Un code propre à l'appli pourra venir plus tard ; son oubli obligerait à tout effacer puis à restaurer un export.
    - Activer ou désactiver le verrou demande de s'authentifier d'abord.
    - Téléphone sans aucun code : le verrou ne s'active pas, un message l'explique.
    - Code du téléphone retiré alors que le verrou est actif : plus rien ne peut être vérifié. L'appli s'ouvre, désactive le verrou et le dit, plutôt que d'enfermer l'utilisatrice hors de ses données.

52. **Quand le verrou s'applique** (`lib/ui/app_lock.dart`). À l'ouverture et à chaque retour après un passage en arrière-plan, sans délai de grâce. La fenêtre du système s'affiche d'elle-même une fois ; après un échec ou une annulation, l'utilisatrice la redemande par un bouton.
    - L'écran de verrouillage est placé au-dessus de tous les écrans, panneaux et fenêtres. Ce qui est dessous n'est ni dessiné, ni touchable, ni lu par le lecteur d'écran, mais garde son état : une note en cours de saisie est retrouvée.
    - **Aperçu du sélecteur d'applis masqué** quand le verrou est actif : le contenu est couvert dès que l'appli quitte le premier plan. Un simple passage par le centre de notifications couvre sans verrouiller.

53. **Ce qui est vérifié, et où (jalon 4).**
    - Sous Windows : le calcul des rappels, le passage de la base à la version 2, l'export sans les réglages d'appareil, et tous les parcours d'écran des décisions 47 à 52 avec des notifications et une authentification factices, en anglais et en français, en clair et en sombre, en grand texte.
    - En attente d'un iPhone (jalon 5) : l'arrivée réelle des notifications et leur heure, la fenêtre d'autorisation, Face ID et le code, l'aperçu réellement masqué dans le sélecteur d'applis, le comportement en voyage. La phrase d'explication de Face ID est dans `Info.plist`, en anglais seulement.
    - Non fait, faute de pouvoir compiler Android : sa configuration native (voir les questions ouvertes).

## Aperçu Windows (19 novembre 2026)

54. **Fenêtre Windows : un aperçu pour le développement, jamais distribué.** Le dossier `windows/` permet de lancer Fycle sur le poste de développement (`flutter run -d windows`) pour voir les écrans et essayer les fonctions. Ce n'est pas une plateforme livrée.
    - **Prérequis** : Visual Studio avec le module « Développement Desktop en C++ » et les outils CMake. Avec Visual Studio 2019, la partie Windows de `flutter_local_notifications` ne se compile qu'avec l'option `/await`, ajoutée dans `windows/CMakeLists.txt`.
    - **Exception à la règle 4, validée par l'utilisateur, limitée à cet aperçu.** La compilation Windows de `local_auth` télécharge `nuget.exe` (vérifié par empreinte), puis deux paquets d'outils Microsoft (`Microsoft.Windows.ImplementationLibrary`, `Microsoft.Windows.CppWinRT`), à version fixée mais sans contrôle d'empreinte. Cela ne se produit que sur le poste de développement : rien n'entre dans l'appli iPhone ou Android, et l'appli n'émet toujours aucun appel réseau.
    - **Différences avec le téléphone** : les rappels ne s'activent pas (la passerelle ne connaît qu'iOS et Android) ; le verrouillage passe par Windows Hello s'il est configuré. Les données de l'aperçu sont rangées, chiffrées, dans `AppData\Roaming\app\fycle` : données fictives uniquement.
    - `windows/` est exclu de l'analyse statique (code généré).

## Décisions du jalon 5 (19 novembre 2026)

55. **Compilation iPhone : GitHub Actions, sur un Mac de GitHub** (`.github/workflows/ios.yml`), validé par l'utilisateur.
    - Raison : le code est déjà chez GitHub, donc aucun nouveau tiers ne le reçoit, et aucun outil n'est ajouté. Solution de repli si la signature résiste : Codemagic (500 minutes gratuites par mois, mais une entreprise de plus reçoit le code et la clé Apple).
    - Lancement à la main (bouton « Run workflow ») ou par un tag `ios-…`, jamais à chaque envoi : le dépôt est privé et les minutes de Mac gratuites sont comptées (environ 200 par mois, à confirmer sur la page de facturation).
    - Le Mac doit fournir Xcode 26 ou plus : Apple l'exige pour tout envoi depuis le 28 avril 2026.
    - Téléchargements pendant la compilation, comme dans `ci.yml` : le SDK Flutter depuis son dépôt officiel, les paquets de `pubspec.lock`, la bibliothèque SQLite vérifiée par empreinte (décision 24). Rien d'autre : pas de CocoaPods, pas d'outil de signature tiers.
    - Le numéro de compilation est le numéro d'exécution du workflow : il augmente tout seul, comme Apple l'exige.

56. **Signature : faite par Xcode avec une clé d'accès App Store Connect.** L'appli est compilée sans signature, puis `xcodebuild -exportArchive` la signe et l'envoie. Xcode crée lui-même le certificat de distribution et le profil.
    - Quatre secrets, créés et rangés par l'utilisateur dans les secrets du dépôt GitHub, jamais dans le dépôt ni dans une conversation : `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`, `APPLE_TEAM_ID`.
    - La clé est écrite dans le dossier temporaire du Mac le temps de l'envoi, puis effacée. Ces Mac sont détruits après chaque compilation.
    - Sans ces secrets, le workflow compile quand même et le signale, sans rien envoyer.
    - Rôle de la clé : « Admin ». La signature gérée par Apple le demande. À réduire si Apple permet un rôle plus étroit.

57. **Identifiant `app.fycle` confirmé** par l'utilisateur (décision 13). **iPhone seulement** pour l'instant : l'iPad pourra être ajouté plus tard, alors qu'on ne peut plus le retirer après publication.

58. **Code natif iPhone** (`ios/Runner/`).
    - **Sauvegarde iCloud** (applique la décision 43) : au lancement, avant la création de la base, `AppDelegate.swift` exclut des sauvegardes tout le dossier « Application Support ». La base y est seule, avec les fichiers temporaires de SQLite, couverts du même coup. Pas de canal entre Dart et Swift.
    - **Phrase Face ID** en anglais et en français (`en.lproj` et `fr.lproj`, fichier `InfoPlist.strings`).
    - **Notifications quand l'appli est ouverte** : affichées. Le paquet le fait par défaut, à condition que l'appli se déclare destinataire des notifications : une ligne dans `AppDelegate.swift`.
    - **Déclaration de confidentialité** (`PrivacyInfo.xcprivacy`) : aucun suivi, aucun domaine de suivi, aucune donnée collectée. Une seule API « à justifier » : les dates de fichiers (motif C617.1, fichiers du dossier de l'appli), parce que SQLite consulte les siennes. Les paquets ont leur propre déclaration.
    - Des tests de `test/guardrails/platform_config_test.dart` vérifient la présence de ces quatre éléments.

59. **Chiffrement et règles d'exportation : réponse donnée à la main, clé `ITSAppUsesNonExemptEncryption` absente pour l'instant.** Fycle chiffre avec des algorithmes standards qui ne viennent pas du système d'Apple (ChaCha20-Poly1305, AES-256-GCM, Argon2id). D'après l'aide d'App Store Connect, ce cas demande une déclaration française de chiffrement pour distribuer sur l'App Store en France. L'utilisateur répond au questionnaire d'Apple à la première compilation ; la clé sera inscrite dans `Info.plist` une fois la bonne réponse connue.

60. **Réponses au questionnaire de chiffrement d'Apple pour les essais privés.** Choix de l'utilisateur, le 19 novembre 2026, pour la compilation n° 2. Type d'algorithme : « chiffrement standard à la place ou en complément de celui du système d'Apple ». Distribution en France : « non », parce que la compilation ne sert qu'à un essai privé en test interne TestFlight (l'utilisateur seul d'abord, sa compagne ensuite, comme membre du compte). Apple repose la question à chaque compilation : la clé `ITSAppUsesNonExemptEncryption` reste absente. **Condition bloquante : pas de test externe ni de publication en France avant la déclaration de chiffrement auprès de l'ANSSI ; la réponse deviendra alors « oui », justificatif à l'appui.**

## Refonte visuelle (19 novembre 2026)

61. **Apparence : palette « rose poudré » sur fond blanc**, choisie par l'utilisateur parmi trois propositions (rose poudré, pêche et corail, lilas et rose), puis validée sur l'aperçu Windows. Raison : la première version, au thème par défaut, a été jugée peu jolie sur l'iPhone ; la demande était des tons clairs, pastel, féminins sans excès.
    - **Couleurs** (`lib/ui/theme.dart`) : page blanche, cartes blanches à fin contour rosé, un seul rose soutenu pour les actions (`#B83A68`), rose très pâle pour la carte d'estimation, texte prune foncé. Un fond écru clair a été essayé puis écarté par l'utilisateur.
    - **Formes** : boutons en pilule, cartes et champs arrondis (24 et 16 points), pastilles de choix arrondies, roses une fois choisies.
    - **Écrans** : estimation en plus grand, calendrier dans sa carte, aujourd'hui sur un halo rose (et toujours souligné), bouton « Saisir aujourd'hui » centré en bas, réglages regroupés en cartes par section, questions du démarrage réunies dans une carte.
    - **Inchangé** : textes, fonctions, données, prédiction. Les repères du calendrier gardent leur forme (décision 37). Police du système : aucune police ni image embarquée ou téléchargée, aucune dépendance ajoutée.
    - Les tests de contraste, de zones tactiles et de grand texte (décision 44) passent avec la nouvelle palette. Le bouton « Commencer » du démarrage reste visible sans défiler sur un écran de 390 × 844.

62. **Mode clair uniquement pour le moment**, à la demande de l'utilisateur. L'appli ne suit plus le réglage clair ou sombre du téléphone (modifie la décision 44 et reporte le « mode sombre » du point 11 de la V1 dans `docs/SPEC.md`). Le thème sombre, dans la même palette, reste dans le code et dans les tests : le réactiver tient en une ligne de `lib/ui/app.dart`.

## Cadrage de la V2 (19 novembre 2026)

Décisions de l'utilisateur, reprises de sa note de cadrage du 19 novembre 2026. Cette note cite des applis concurrentes : elle n'est pas rangée dans le dépôt (règle 8), son contenu est reporté ici et dans `docs/SPEC.md` sans les noms.

63. **La V1 n'est pas publiée.** Elle reste en TestFlight ; la première version publique est la V2, pour un vrai lancement.

64. **Jamais d'abonnement : c'est le slogan.** Aucun palier récurrent. Devient la règle 9 de `CLAUDE.md`.

65. **Prix de l'achat unique : 14,99 €**, soit environ 10 € nets par vente après TVA et commission. Remplace l'hypothèse de 9,99 €.

66. **Essai : tout est débloqué pendant trois cycles**, sans moyen de paiement (un mois serait trop court pour voir une prédiction se vérifier). Ensuite, achat unique ou retour au socle gratuit, sans publicité, pour toujours. Après l'essai, ni la saisie ni l'export ne sont bloqués.

67. **Répartition gratuit / achat unique.**
    - Gratuit pour toujours : saisie, calendrier, prédiction de base des règles, rappels, verrouillage, export et import.
    - Achat unique : ovulation, fertilité, périménopause, grossesse, journal de symptômes avec tendances, migraines, rapport de consultation PDF, widgets et complication, sauvegarde automatique, partage partenaire (fonction phare).
    - Remplace le « pack Pro » de la V1.x. Le socle gratuit fait le volume ; le premium reste minoritaire par construction.

68. **Pourboire facultatif « soutenir Fycle »** (1,99 € ou 2,99 €) dans les réglages, qui ne débloque rien. Autres leviers gardés en réserve, tous sans abonnement : pack « partenaire » ou « famille », V3 vendue comme nouvel achat unique facultatif.

69. **Sauvegarde : export chiffré manuel gratuit, sauvegarde automatique en premium**, vers l'espace de fichiers de l'utilisatrice (iCloud Drive, Fichiers, équivalent Android), sous son contrôle, sans serveur. Raison : tout en local, un téléphone perdu est tout perdu. Modifie le périmètre (la sauvegarde automatique était exclue) et précise la règle 1. La décision 43 reste : la base elle-même, illisible sans sa clé, n'entre pas dans la sauvegarde iCloud du téléphone ; c'est le fichier d'export chiffré par mot de passe qui est sauvegardé.

70. **Périmètre de la V2 et de la V3** : voir `docs/SPEC.md`. Hors périmètre confirmé : assistant IA, communauté, contenus quotidiens, allégation de contraception ou de diagnostic. Apprentissage fédéré : plus tard, il suppose un serveur.

71. **Données de santé du téléphone : afficher plutôt que recalculer.** Deux niveaux : sans montre, la prédiction statistique de Fycle ; avec une montre, les estimations d'Apple Santé ou de Health Connect, lues sur l'appareil par un paquet local, sans réseau.

72. **Réglages de départ du modèle calés sur des données publiques**, hors ligne, puis embarqués dans l'appli. Aucune donnée d'utilisatrice n'y sert. Pas de détection de signaux faibles à grande échelle. Les signaux à montrer à un médecin viennent de règles cliniques publiées, pas d'un modèle entraîné.

73. **Le volet médical est validé par un professionnel de santé, pas généré.** Vaut pour les seuils, les textes et les alertes « parlez-en à un médecin ».

74. **Parité iOS / Android stricte** (règle 10) et **internationalisation complète dès la conception** (règle 11). Langues : anglais et français en V2, puis espagnol et allemand.

75. **Finition et habitude.** La finition de l'interface est un critère d'acceptation (règle 12). Mécanismes d'habitude sobres uniquement ; points, badges, confettis, récompenses et notifications culpabilisantes sont interdits (règle 13).

76. **Partage partenaire : au sprint 2, conception avant le code.** Deux pistes : échange direct entre téléphones, ou relais chiffré de bout en bout. Voir les questions ouvertes.

77. **Charte graphique.** Bleu nuit (ou bleu pétrole profond) en base, ambre doré en accent unique pour les prédictions et le jour du cycle, blanc cassé et gris anthracite en neutres, bordeaux discret pour les jours de règles. Police géométrique simple (Inter ou Manrope). Icône : un F stylisé dont la barre forme un arc de cercle ouvert, monochrome, un trait épais, fond uni, sans texte ; rien qui évoque les règles, ni rose ni rouge.
    - **Confirmée par l'utilisateur le 19 novembre 2026 : remplace la palette rose poudré de la décision 61.** L'ambre doré reste sobre : un accent, pas un décor. Les formes de la décision 61 (cartes arrondies, boutons en pilule, mise en page des écrans) ne sont pas remises en cause.
    - **Mode clair par défaut, mode sombre de retour** (modifie la décision 62) : l'appli s'ouvre en clair, et l'utilisatrice peut passer en sombre dans les réglages. Le choix est un réglage de l'appareil (table `device_setting`, décision 50).

78. **Planning visé.** Sprint 1, livraison visée le 26 novembre 2026 : V2 hors partage partenaire, en TestFlight. Sprint 2 : partage partenaire. Puis test fermé d'une dizaine de testeuses pendant un à deux mois (cycles réguliers et irréguliers, avec et sans montre), publication App Store, puis Google Play. Point de mesure six mois après le lancement : 500 installations et 15 ventes par mois ; sinon, changer d'angle de communication plutôt qu'ajouter des fonctions.

79. **Lancement et formalités.**
    - À préparer avant la sortie : fiche de store par langue, page web unique avec la politique de confidentialité (obligatoire), page « preuve de confidentialité » expliquant comment vérifier soi-même l'absence de requête réseau, court dossier de presse. Sur les forums : se présenter comme le développeur, répondre aux questions, pas d'autopromotion. Éventuellement publier une partie du code (prédiction, stockage) sous licence restrictive.
    - Marque « Fycle » à déposer (INPI, EUIPO), après avis d'un juriste. Pas de brevet.
    - Stores : déclarer « aucune donnée collectée » ; disponibilité dans tous les pays.
    - Android après Apple : compte Google Play, test fermé de 12 testeurs pendant 14 jours.

80. **Plan du sprint 1, validé par l'utilisateur le 19 novembre 2026.** Un jalon par session, dans cet ordre :
    - A. Thème : charte de la décision 77, clair et sombre, mise en page miroir.
    - B. Démarrage en moins d'une minute, saisie en un geste, série de saisie.
    - C. Journal de symptômes (sommeil, libido), tendances par phase, bilan de fin de cycle.
    - D. Migraines.
    - E. Ovulation et fenêtre de fertilité.
    - F. Signaux « parlez-en à un médecin », périménopause.
    - G. Mode grossesse, rappel de contraception.
    - H. Rapport de consultation PDF (paquet envisagé : `pdf`).
    - I. Sauvegarde manuelle, puis automatique.
    - J. Achat unique, essai de trois cycles, pourboire (`in_app_purchase`).
    - K. Apple Santé, Health Connect préparé (`health`).
    - L. Widgets, icône neutre, complication de montre (`home_widget`).
    - Chaque paquet est relu et proposé au début de son jalon (règle 4). Le total représente 12 à 14 jours de travail : au 26 novembre, les jalons A à G ou H sont réalistes ; J, K et L suivent. Les textes des jalons E, F et G restent marqués « à relire par un professionnel de santé » avant tout test externe. Rien n'est compilé pour Android pendant ce sprint.

81. **Police du système et mode sombre à trois choix.** Police du système plutôt qu'Inter ou Manrope : elle couvre toutes les écritures sans fichier embarqué (règle 11). Réglage d'apparence : clair (par défaut), sombre, comme le téléphone. Précise la décision 77.

## Décisions du jalon A du sprint 1 (19 novembre 2026)

82. **Palette « bleu nuit et ambre »** (`lib/ui/theme.dart`), valeurs proposées puis validées par l'utilisateur. Applique la décision 77 et remplace les couleurs de la décision 61 ; les formes de la décision 61 et les repères de la décision 37 sont inchangés.

    | Rôle | Clair | Sombre |
    |---|---|---|
    | Fond de page | `#F7F5F0` | `#0F1626` |
    | Cartes, champs, pastilles | `#FFFFFF`, contour `#E3E0D8` | `#1A2338` |
    | Base : en-têtes, boutons, interrupteurs, icônes | `#1B2A4A` | `#AFC3EE` |
    | Texte, texte secondaire | `#2B2F36`, `#5A606B` | `#ECE9E2`, `#B4B9C4` |
    | Ambre : anneau des jours prévus, icône de l'estimation | `#B67A14` | `#E3B45C` |
    | Carte d'estimation et son texte | `#FAF0DA`, `#1B2A4A` | `#3A2F17`, `#F6E6C2` |
    | Halo d'aujourd'hui | `#F3DDAE` | `#4A3C1C` |
    | Jours de règles (disque plein, chiffre blanc) | `#7A2E3B` | `#B04E64` |
    | Erreur, suppression | `#A63A2B` | `#F2A99B` |

    - **L'ambre n'apparaît qu'à trois endroits** : la carte d'estimation, l'anneau des jours prévus, le halo d'aujourd'hui (`AccentColors`). Tout le reste est bleu nuit ou neutre.
    - **Bordeaux en sombre** : éclairci pour rester visible sur le bleu nuit (contraste 3:1 avec la carte), sans aller jusqu'au rose. Un premier essai (`#C0617A`) tirait sur le rose et a été écarté.
    - Les erreurs et la suppression sont en rouge brique, pas en rouge vif.

83. **Réglage « Apparence »** (applique les décisions 77 et 81, remplace la décision 62). Trois choix dans les réglages : clair (par défaut, même sur un téléphone en sombre), sombre, comme le téléphone.
    - Rangé dans `device_setting` sous le nom `appearance` (décision 50) : hors export, hors import, effacé par « Tout supprimer ». Le choix « clair » n'est pas écrit : c'est la valeur par défaut, et celle qui s'applique si la valeur lue est inconnue.
    - Le choix est lu à l'ouverture de la base par `lib/ui/root_screen.dart`, qui le transmet à `lib/ui/app.dart`. Avant l'ouverture de la base (quelques millisecondes), la page vide est claire : en mode sombre, un bref éclair clair est possible au lancement. À observer sur l'iPhone ; l'éviter demanderait de ranger ce choix hors de la base chiffrée.

84. **Mise en page miroir** (règle 11). Les marges de `lib/ui/` sont directionnelles (`EdgeInsetsDirectional`), et les flèches du calendrier suivent le sens d'écriture : « mois précédent » est du côté où la ligne commence. Le calendrier se lit alors de droite à gauche, comme le reste.
    - `FycleApp` accepte un sens d'écriture forcé, pour les tests seulement. `test/ui/rtl_test.dart` parcourt chaque écran et chaque fenêtre de droite à gauche, en anglais et en français, en texte normal et agrandi 2,5 fois : un débordement fait échouer le test. Aucune langue n'est ajoutée.
    - Non vérifié : une vraie langue de droite à gauche (longueur des textes, chiffres locaux), faute de traduction.

85. **Ce qui est vérifié, et où (jalon A).** Sous Windows : contraste, zones tactiles et grand texte en clair et en sombre avec la nouvelle palette ; le réglage d'apparence (défaut, choix, relance, suppression, export) ; la mise en page miroir. En attente de l'iPhone : le rendu réel des couleurs sur l'écran du téléphone, la police du système d'iOS, VoiceOver, l'éclair clair éventuel au lancement en mode sombre.

## Décisions du jalon B du sprint 1 (19 novembre 2026)

Plan validé par l'utilisateur le 19 novembre 2026, y compris l'ordre de la suite (décision 89).

86. **Démarrage en moins d'une minute** (`lib/ui/onboarding_screen.dart`). Complète la décision 34.
    - **Deux raccourcis, « Aujourd'hui » et « Hier »**, à côté du choix de date : un appui suffit dans le cas le plus courant.
    - **L'estimation s'affiche sur l'écran de démarrage dès qu'une date est choisie**, avant « Commencer », et suit la durée habituelle à mesure qu'elle est tapée. Toujours une fourchette, avec ce sur quoi elle se fonde. Rien n'est enregistré avant « Commencer ». Si la date est si ancienne que la fourchette est déjà passée, rien n'est affiché.
    - **« Je ne sais plus »** : l'appli s'ouvre sans date, sur « Pas encore d'estimation ». Ferme la question ouverte « démarrage sans date ».
    - **Le passage du démarrage est mémorisé** dans `device_setting` (nom `onboarding_done`, décision 50), avec ou sans réponse : hors export, effacé par « Tout supprimer ». Conséquence : effacer sa seule saisie ne ramène plus à l'écran de démarrage.
    - **« Commencer » est fixé en bas de l'écran**, au-dessus du clavier, quelle que soit la longueur de la page.
    - La carte d'estimation de cet écran est en ambre : c'est le même rôle que la carte d'estimation de l'accueil (décision 82), pas un quatrième usage.

87. **Saisie en un geste** (`lib/ui/today_card.dart`). Sur l'accueil, une carte « Règles aujourd'hui » avec les quatre intensités : un appui enregistre, un second appui annule, le reste de la saisie du jour (douleur, humeur, symptômes, note) est conservé. Complète la décision 34 : le panneau de saisie et son bouton restent pour le détail.
    - **Retour tactile** : un léger « tic » (`HapticFeedback.selectionClick`, fourni par Flutter, aucun paquet ajouté). Il suit le réglage du téléphone ; aucun réglage dans Fycle.
    - La carte ne propose que les règles : c'est la saisie qui nourrit l'estimation. Douleur, humeur et symptômes en un geste pourront venir avec le journal du jalon C.

88. **Série de saisie discrète** (`lib/domain/logging_streak.dart`, Dart pur). Nombre de jours de suite avec une saisie, quelle qu'elle soit.
    - Un jour pas encore saisi n'interrompt pas la série avant d'être fini : le compte repart de la veille.
    - Affichée à partir de 2 jours, en petit, sous la carte « Règles aujourd'hui » : « Saisie 5 jours de suite ».
    - Règle 13 : un simple constat. Ni félicitation, ni palier, ni notification, et rien ne s'affiche quand la série s'interrompt.

89. **Ordre de la suite du sprint 1**, validé par l'utilisateur : C (journal de symptômes, tendances, bilan), puis **E (ovulation et fenêtre de fertilité) avant D (migraines)**, puis F, G, H, I, J, K, L. Modifie l'ordre de la décision 80. Raison : mettre en premier ce que les testeuses attendent le plus. Tant que le jalon J (achat) n'est pas fait, tout est débloqué pour elles.

90. **Ce qui est vérifié, et où (jalon B).** Sous Windows : le calcul de la série ; les parcours du démarrage (raccourcis, estimation immédiate, passage sans date, relance) et de la carte « Règles aujourd'hui » (enregistrement, annulation, retour tactile demandé, saisie du jour conservée), en anglais et en français ; grand texte et mise en page miroir par les parcours existants. Rendu contrôlé sur des captures du moteur de test, en clair et en sombre. En attente de l'iPhone : le retour tactile réel, la place prise par la carte sur l'accueil (le calendrier descend d'autant), le clavier sur l'écran de démarrage.

## Décisions du jalon C du sprint 1 (19 novembre 2026)

Plan validé par l'utilisateur le 19 novembre 2026. Aucun paquet ajouté.

91. **Sommeil et libido dans la saisie du jour** (`lib/domain/sleep_quality.dart`, `lib/domain/libido_level.dart`). Trois choix chacun : sommeil mauvais, moyen, bon ; libido basse, moyenne, haute. Facultatifs, comme le reste.
    - Base : disposition 3, deux colonnes ajoutées à `day_entry`. Une base existante est mise à niveau sans toucher aux données (testé depuis la disposition 2).
    - Sauvegarde chiffrée : deux champs facultatifs de plus, sans changer la version du contenu. Une ancienne sauvegarde se restaure toujours. Limite connue : une version plus ancienne de l'appli qui restaure une sauvegarde récente ignore ces deux champs sans le dire.
    - Export CSV : deux colonnes de plus, entre l'humeur et les symptômes.
    - La saisie en un geste (décision 87) conserve aussi ces deux champs : `DayEntry.withFlow` remplace la recopie champ par champ, qui les aurait perdus.

92. **Historique des cycles** (`lib/domain/cycle_history.dart`, Dart pur). Un cycle va du premier jour des règles à la veille des suivantes ; le dernier est le cycle en cours, sans durée. Mêmes règles que la décision sur les débuts de règles : les traces ne comptent pas, une pause courte reste dans les mêmes règles.
    - Un cycle de moins de 15 jours ou de plus de 90 jours (bornes du moteur de prédiction) est affiché, avec la mention « durée inhabituelle », mais il ne compte ni dans les moyennes ni dans les tendances : il cache le plus souvent une erreur de saisie ou des règles non saisies.
    - Moyennes sur les 6 derniers cycles retenus. Les règles du cycle en cours ne comptent dans la moyenne qu'une fois terminées depuis plus de 7 jours.
    - Complète le point 6 de la V1 (historique et statistiques simples), qui n'existait pas encore.

93. **Trois moments descriptifs, pas de phases médicales** (`CycleMoment`). « Pendant les règles », « la semaine avant les règles » (les 7 derniers jours du cycle), « le reste du cycle ». Raison : nommer une phase folliculaire ou lutéale suppose une estimation de l'ovulation, qui relève du jalon E et de sa relecture médicale (règle 7). Seuls les cycles terminés ont des moments : sans les règles suivantes, « la semaine avant » n'est pas connue.

94. **Tendances** (`lib/domain/cycle_trends.dart`, Dart pur ; `lib/ui/insights_screen.dart`). Pour chaque signe saisi (symptôme, douleur autre que « aucune », humeur, sommeil, libido), le nombre de cycles où il a été noté à chaque moment, sur les 6 derniers cycles retenus.
    - Rien n'est affiché avant deux cycles terminés, et un signe n'apparaît que s'il revient au même moment dans au moins deux cycles : un cycle n'est pas une tendance.
    - Une phrase par signe, pour le moment où il revient le plus (« Pendant les règles, dans 4 de vos 5 derniers cycles »), et une barre qui redit la même proportion. La barre est ignorée par le lecteur d'écran : la phrase suffit.
    - Ce sont des décomptes. Aucune explication, aucune prévision, et une mention fixe sous la liste : « des observations, pas une interprétation médicale » (règle 7).
    - L'écran s'ouvre par une icône de l'accueil, à côté des réglages.

95. **Bilan de fin de cycle** (`lib/ui/cycle_summary_card.dart`). Une carte sur l'accueil quand de nouvelles règles sont saisies : durée du cycle terminé, écart en jours avec la moyenne des cycles précédents, et jusqu'à trois symptômes notés le plus de jours.
    - Elle se ferme d'un appui et ne revient pas (réglage de l'appareil `cycle_summary_dismissed`, hors export) ; sinon elle disparaît d'elle-même 10 jours après le début des nouvelles règles.
    - Aucune notification, aucune félicitation, aucun jugement sur la durée (règle 13). Rien n'est dit d'un cycle de durée inhabituelle.

96. **Gratuit ou payant.** La spec range les tendances dans l'achat unique. Tant que le jalon J n'est pas fait, tout est ouvert aux testeuses (décision 89). À trancher au jalon J : l'historique et les moyennes relèvent du socle gratuit de la V1 ; seules les tendances et le bilan seraient payants.

97. **Ce qui est vérifié, et où (jalon C).** Sous Windows : les calculs (historique, moyennes, moments, tendances, bilan) ; la mise à niveau de la base ; l'aller-retour sauvegarde et CSV ; l'écran Tendances et la carte de bilan en anglais et en français, de droite à gauche, en grand texte sur petit écran. En attente de l'iPhone : le rendu réel de l'écran Tendances, la longueur de la fiche du jour avec deux lignes de plus, VoiceOver.

## Décisions du jalon E du sprint 1 (19 novembre 2026)

Plan validé par l'utilisateur le 19 novembre 2026. Aucun paquet ajouté.

98. **Estimation de l'ovulation et de la fenêtre de fertilité** (`lib/domain/fertility_estimate.dart`, Dart pur). Un calcul de calendrier, sans aucune mesure du corps.
    - Départ : la fourchette estimée des prochaines règles. Ovulation estimée 14 jours avant, avec 2 jours de marge de chaque côté ; la fourchette des règles s'y ajoute. Le résultat est toujours une fourchette.
    - Fenêtre de fertilité estimée : des 5 jours avant le début de cette fourchette au lendemain de sa fin. Elle ne commence jamais avant le premier jour des règles du cycle.
    - Aucune estimation tant que la prédiction des règles repose sur moins de deux cycles saisis. Rien non plus pour un journal délaissé depuis des mois.
    - Cycles terminés : la même estimation, faite après coup depuis la date réelle des règles suivantes. Pas pour un cycle de durée inhabituelle (décision 92).
    - **Les valeurs 14, 2, 5 et 1 sont des hypothèses de départ, à faire confirmer par un professionnel de santé** avant tout test hors du cercle privé.

99. **Désactivée par défaut**, choix de l'utilisateur. Un interrupteur « Estimation de l'ovulation » dans les réglages (réglage de l'appareil `fertility_estimate_enabled`, hors export). L'activer affiche d'abord l'avertissement, à accepter ; le désactiver ne demande rien. Raison : toutes les utilisatrices ne veulent pas voir une information de fertilité, et c'est la fonction la plus exposée à la règle 7.

100. **Affichage** (`lib/ui/fertility_card.dart`, `lib/ui/month_calendar.dart`). Une carte sur l'accueil, sous l'estimation des règles : la fenêtre puis l'ovulation, chacune « entre le … et le … », et une ligne « peu fiable » quand les cycles varient beaucoup. Dans le calendrier, un court trait au-dessus du jour, en bleu nuit : une forme à part, distincte du disque des règles, de l'anneau des règles prévues et du point des autres saisies. La légende et le lecteur d'écran le nomment « fenêtre de fertilité, estimation ».

101. **Avertissement et vocabulaire (règle 7).** Le mot « estimation » partout, jamais « jour fertile » ni « jour sûr ». L'avertissement dit que ce n'est ni une méthode de contraception ni un diagnostic, et que les jours hors de la fenêtre ne sont pas sans risque. Il est affiché à l'activation et répété dans « Comment c'est calculé ».
    - **Textes à relire par un professionnel de santé avant tout test externe**, marqués dans les fichiers de textes : `fertilityWarning`, `fertilityHowBody`. Personne n'est encore désigné.
    - Les trois moments de la décision 93 ne changent pas : pas de noms de phases avant cette relecture.

102. **Ce qui est vérifié, et où (jalon E).** Sous Windows : le calcul ; l'interrupteur (désactivé par défaut, avertissement, annulation, relance) ; la carte et le calendrier en anglais et en français ; mode sombre, de droite à gauche, grand texte sur petit écran. En attente de l'iPhone : la lisibilité du trait dans le calendrier, la place de la carte sur l'accueil, VoiceOver.

## Refonte de l'accueil et de la navigation (19 novembre 2026)

Demandée par l'utilisateur après le premier essai de la testeuse sur iPhone : l'appli ne disait pas ce qu'elle faisait, les fonctions de la V2 étaient cachées, et rien ne donnait envie de saisir. Orientations données par l'utilisateur : des chiffres clés dès la première utilisation, un vrai écran d'accueil, des onglets clairs, une ergonomie de journal intime, l'envie de saisir, l'ovulation mise en avant, tout actif dès le début. Aucun paquet ajouté.

103. **Quatre onglets nommés** (`lib/ui/home_screen.dart`) : Accueil, Journal, Bilan, Réglages, dans une barre en bas. Chaque onglet commence par une phrase qui dit à quoi il sert. Le nom « Fycle », en haut de chaque écran, ramène à l'accueil. Remplace les deux icônes sans nom de l'en-tête et le bouton flottant (décision 34). Les libellés de la barre ne grossissent pas au-delà de 1,3 fois, comme les barres d'onglets du système : la barre a une hauteur fixe.

104. **Accueil centré sur les chiffres** (`lib/ui/today_tab.dart`, `lib/ui/prediction_card.dart`, `lib/ui/cycle_ring.dart`, `lib/ui/home_cards.dart` ; calculs dans `lib/domain/cycle_overview.dart`, Dart pur).
    - En tête, une phrase : le journal est privé et reste sur le téléphone.
    - Un anneau du cycle : règles en bordeaux, période estimée des prochaines règles en ambre, fenêtre de fertilité en trait fin, un point pour aujourd'hui, le jour du cycle au centre. C'est une image des chiffres écrits à côté : le lecteur d'écran lit le texte.
    - Le compte à rebours reste une fourchette (« Règles dans 5 à 11 jours »), conformément à la règle 7.
    - Trois chiffres : durée du cycle, durée des règles, jours saisis. Chacun dit d'où il vient (vos saisies, indiqué par vous, repère).
    - La saisie du jour en un appui par rubrique (règles, douleur, humeur), avec une jauge « 2 rubriques sur 6 remplies aujourd'hui ». Complète la décision 87.
    - « D'habitude, vers ce jour » : ce qui a été noté autour du même jour du cycle dans au moins deux cycles passés. Un décompte, pas une prévision.

105. **Cycle de repère à ajuster.** Tant que rien n'est saisi, l'accueil montre un cycle de repère (28 jours, règles de 5 jours) et dit que les dates de l'utilisatrice le remplaceront. Ensuite, chaque chiffre est affiché à côté du repère (« 32 jours, d'après vos saisies ; repère : 28 jours »).
    - Demande de l'utilisateur : partir d'un modèle courant pour donner envie de l'ajuster.
    - **Refusé : le présenter comme « un cycle à atteindre ».** Une durée de cycle ne s'obtient pas par effort ; en faire un objectif serait une promesse de santé fausse et culpabilisante pour celles dont le cycle est naturellement différent (règles 7 et 13). Le repère est un point de comparaison, jamais une cible ni une norme.
    - Aucune fausse saisie n'est écrite dans le journal : seuls les chiffres affichés partent du repère.
    - Valeurs 28 et 5 **à faire confirmer par un professionnel de santé**, comme celles de la décision 98.

106. **« Plus vous saisissez, plus vous en voyez »** (`UnlockCard`). Quatre étapes qui se cochent avec les saisies : estimation des règles (premières règles saisies), durées moyennes (un cycle complet), ce qui revient et estimation de l'ovulation (deux cycles), estimation fiable (quatre cycles réguliers ou plus), avec le compte « 1 sur 2 ». Sur l'accueil tant que tout n'est pas atteint, et toujours dans le bilan.
    - Lecture de la règle 13 : ce sont des informations sur ce que le journal permet, pas des points, des badges ni des récompenses, et rien n'est dit quand on ne saisit pas. L'utilisateur a demandé une appli « addictive » ; la règle 13 n'a pas été modifiée.

107. **Onglet Journal** (`lib/ui/journal_tab.dart`). Le calendrier du mois, un bouton « Écrire la page d'aujourd'hui », puis les trente dernières pages : la date, ce qui a été coché, la note. Un appui ouvre la journée.

108. **Onglet Bilan** (ancien écran « Tendances », décision 94). S'y ajoute en tête le compte rendu du cycle en cours, lisible à tout moment : jour du cycle, date de début, durée des règles, jours saisis, jours de douleur, nuits de mauvais sommeil, symptômes les plus notés (`currentCycleReport`, Dart pur).

109. **Démarrage** (`lib/ui/onboarding_screen.dart`). Trois lignes disent ce que fait l'appli avant la première question. Une fois la date des dernières règles donnée, on peut ajouter le premier jour de règles précédentes : avec deux, les moyennes, les tendances et l'estimation de l'ovulation sont là dès la première minute. Complète les décisions 34 et 86.

110. **Tout actif dès le début**, demande de l'utilisateur.
    - **Estimation de l'ovulation activée par défaut.** Remplace la décision 99. Comme rien n'est plus accepté avant, l'avertissement « une estimation : ni contraception ni diagnostic » est écrit en permanence sur la carte. La réactiver après l'avoir éteinte affiche toujours l'avertissement complet. L'estimation est aussi reprise dans la carte du haut. Risque accepté par l'utilisateur ; les textes restent à relire (décision 101).
    - **Rappels activés à la fin du démarrage**, si le téléphone accepte les notifications : iOS impose sa propre fenêtre d'autorisation. En cas de refus, rien n'est dit, et l'accueil les propose encore une fois.
    - **Verrouillage proposé, pas imposé** : une carte sur l'accueil, en un appui. iOS exige de toute façon Face ID ou le code pour l'activer, et un verrou que l'utilisatrice n'a pas choisi surprendrait.
    - Les propositions (rappels, verrouillage) sont faites une fois ; « plus tard » est retenu (réglage de l'appareil, hors export).

111. **Méthode : essai sur iPhone uniquement.** L'utilisateur ne teste pas sur PC. Chaque tâche terminée est commitée, poussée et compilée pour TestFlight sans qu'il le demande (consigné dans `CLAUDE.md`).

112. **Ce qui est vérifié, et où (refonte).** Sous Windows : les calculs ; les quatre onglets, l'accueil, le journal, le bilan, le démarrage et les propositions, en anglais et en français ; mode sombre, de droite à gauche, grand texte sur petit écran ; rendu contrôlé sur des images du moteur de test. En attente de l'iPhone : le rendu réel de l'anneau, la longueur de l'accueil, la barre d'onglets, VoiceOver.

113. **Valeurs tirées d'études publiées**, demande de l'utilisateur. Vérifiées le 19 novembre 2026 sur les résumés publiés ; elles restent à faire confirmer par un professionnel de santé (décision 101).
    - **Ovulation : 13 jours avant les règles, plus ou moins 3** (au lieu de 14, plus ou moins 2). Source : Bull et al., « Real-world menstrual cycle characteristics of more than 600,000 menstrual cycles », npj Digital Medicine, 2019 (612 613 cycles) : phase lutéale de 12,4 jours en moyenne, la plupart des cycles entre 7 et 17 jours. Modifie la décision 98.
    - **Fenêtre de fertilité : les 5 jours avant l'ovulation et le jour même.** Source : Wilcox, Weinberg et Baird, « Timing of sexual intercourse in relation to ovulation », New England Journal of Medicine, 1995 : conception observée seulement dans les six jours qui se terminent le jour de l'ovulation. Le jour ajouté après est une marge de l'appli, qui ne vient pas de l'étude.
    - **Cycle de repère : 28 jours pour l'instant.** La même étude de 2019 donne 29,3 jours en moyenne, 13 % seulement des cycles durant exactement 28 jours, et une durée qui baisse d'environ 0,18 jour par année d'âge entre 25 et 45 ans. Passer le repère à 29 jours, ou le faire dépendre de l'âge, touche le moteur de prédiction (décision sur la durée par défaut) : à trancher dans un jalon à part.
    - **Règles de repère : 5 jours.** Valeur courante, non sourcée à ce jour comme une moyenne mesurée. Le seul repère vérifié est celui de la FIGO : des règles de 8 jours au plus et un cycle de 24 à 38 jours sont dans les limites habituelles. Ces limites serviront au jalon F (signaux à montrer à un médecin).
    - Le texte « Comment c'est calculé » dit que les chiffres viennent d'études publiées et que ce sont des moyennes, pas des mesures du corps de l'utilisatrice.

## Regard clinique et études publiées (19 novembre 2026)

Demandé par l'utilisateur après la compilation n° 8, jugée correcte : aller au-delà des fonctions de base, penser « gynécologue », s'appuyer sur des études, surprendre dès l'ouverture, rendre le rapport pour le médecin accessible tout de suite, épurer. Aucun paquet ajouté. Tous les textes de cette partie sont marqués « à relire par un professionnel de santé » dans les fichiers de textes.

114. **Fiche clinique** (`lib/domain/clinical_review.dart`, Dart pur ; `lib/ui/clinical_card.dart`). Le journal lu avec les quatre paramètres du référentiel FIGO de 2018 (Munro, Critchley et Fraser, International Journal of Gynecology & Obstetrics), sur les cycles complets des 12 derniers mois.
    - Fréquence : durée moyenne du cycle, plage habituelle de 24 à 38 jours.
    - Régularité : écart entre le cycle le plus court et le plus long. Le référentiel donne 7 à 9 jours ; l'appli retient 7 jours de 26 à 41 ans et 9 jours avant, après, ou quand l'âge n'est pas connu. **Cette répartition par âge vient d'une source secondaire et n'a pas été vérifiée dans l'article d'origine.** Pas de jugement avant trois cycles.
    - Durée des règles : plage habituelle jusqu'à 8 jours.
    - Abondance : d'après les intensités saisies (le jour le plus fort de chaque période), sans plage de référence, comme le prévoit le référentiel.
    - En plus : les deux parties du cycle en estimation (décision 113) et les jours de traces entre les règles.
    - Chaque ligne donne la valeur, la plage publiée, et « dans la plage habituelle » ou « hors de la plage habituelle ». Aucun nom de maladie. Une valeur hors plage ajoute une seule phrase : ce n'est pas un diagnostic, la fiche mérite d'être montrée à un médecin (règle 7). Remplace en partie le jalon F prévu.

115. **« Ce que disent les études »** (`lib/domain/study_facts.dart`, `lib/ui/study_card.dart`). Sur l'accueil, juste sous l'anneau : un résultat publié, différent chaque jour, à côté du chiffre de l'utilisatrice (« Seuls 13 % environ des cycles durent exactement 28 jours. Votre cycle moyen : 31 jours. »), avec sa source. Un bouton ouvre la liste des sources.
    - Sept résultats, tirés de quatre publications vérifiées sur leurs résumés : Bull et al., npj Digital Medicine, 2019 (612 613 cycles) ; Fehring, Schneider et Raviele, 2006 (1 060 cycles ; la revue n'est pas citée, faute de l'avoir vérifiée) ; Wilcox, Weinberg et Baird, New England Journal of Medicine, 1995 ; FIGO, 2018.
    - Les études décrivent des groupes de femmes, pas l'utilisatrice : c'est écrit dans la liste des sources, et ses propres saisies prennent toujours le dessus.

116. **Année de naissance et repère selon l'âge** (`lib/domain/reference_cycle.dart`, Dart pur). Facultative, demandée au démarrage et modifiable dans les réglages ; elle voyage avec la sauvegarde chiffrée.
    - Le cycle de repère suit la pente de l'étude de 2019 : 29,3 jours en moyenne, moins 0,18 jour par année entre 25 et 45 ans, stable avant et après. Soit 30 jours à 25 ans, 29 à 30 ans, 28 à 35 ans, 27 à 45 ans.
    - **Hypothèse de l'appli : la moyenne de l'étude est placée à 30 ans.** L'étude ne donne pas ce point d'ancrage dans son résumé ; à vérifier dans le texte complet.
    - Sans durée indiquée ni cycle saisi, ce repère sert aussi à l'estimation des prochaines règles. Les cycles saisis le remplacent. Sans année de naissance, le repère reste 28 jours (décision 105).
    - L'âge ajuste aussi la limite de régularité de la décision 114.
    - **Poids, taille, sport : pas demandés pour l'instant.** Demande de l'utilisateur, à instruire : n'ajouter une donnée que si une étude vérifiée lui donne un effet utilisé dans un calcul. Un résultat est déjà vérifié (étude de 2019 : variation du cycle un peu plus forte au-delà d'un indice de masse corporelle de 35) ; rien de vérifié à ce jour pour le sport.

117. **Rapport pour le médecin à un appui de l'accueil** (`DoctorReportScreen`). Une page à montrer sur le téléphone : date d'établissement, âge s'il est connu, fiche clinique, cycle en cours, moyennes, ce qui revient, historique. L'export en PDF reste au jalon H : il demande le paquet `pdf`, à relire et à faire approuver (règle 4).

118. **Accueil épuré.** Dans l'ordre : la phrase sur le caractère privé, l'anneau et l'estimation, l'étude du jour, le rapport pour le médecin, les chiffres, « Mon journal du jour », puis les étapes, le bilan de fin de cycle, « d'habitude vers ce jour » et les propositions. Le détail de la fenêtre de fertilité passe dans le Bilan ; l'estimation de l'ovulation reste dans la carte du haut. En haut à gauche, un bouton « Accueil » remplace le nom de l'appli (modifie la décision 103).

119. **Ce qui est vérifié, et où.** Sous Windows : les calculs de la fiche clinique, du repère selon l'âge et de l'étude du jour ; les écrans en anglais et en français, mode sombre, de droite à gauche, grand texte sur petit écran. En attente de l'iPhone : le rendu réel, la longueur de l'accueil, VoiceOver. En attente d'un professionnel de santé : tous les textes et toutes les valeurs de cette partie.

## Épure après le retour de la testeuse (19 novembre 2026)

Retour de la testeuse sur la compilation n° 9, rapporté par l'utilisateur : pouvoir saisir le premier jour de ses règles dès l'installation, ou le saisir le jour où elles arrivent ; ne plus voir les références scientifiques, les modèles devant tourner « derrière, comme un moteur » ; épurer, tout n'ayant pas à être vu. Aucun paquet ajouté.

120. **Démarrage en une question** (`lib/ui/onboarding_screen.dart`). Une seule question, la date des dernières règles (aujourd'hui, hier, ou une date), et deux boutons : commencer, ou « Pas encore : je le noterai le jour venu ». Les trois lignes de présentation, la durée habituelle du cycle, l'année de naissance et les règles précédentes quittent cet écran. La durée du cycle et l'année de naissance se règlent dans les réglages ; des règles passées s'ajoutent depuis le calendrier du journal. Remplace la décision 109 et simplifie les décisions 34 et 86.

121. **Les règles se notent en un appui le jour où elles arrivent.** Tant qu'aucune estimation n'est possible (rien de saisi, ou journal délaissé depuis des mois), la carte du haut porte un bouton « Mes règles commencent aujourd'hui ».

122. **Accueil réduit à deux cartes** : l'anneau avec l'estimation, et « Mon journal du jour ». Peuvent s'y ajouter, seulement quand ils ont quelque chose à dire : le bilan d'un cycle qui vient de finir, « d'habitude, vers ce jour », une proposition (rappels, verrouillage). Quittent l'accueil : la phrase sur le caractère privé (elle reste au démarrage), l'étude du jour, les chiffres, les étapes, le bouton du rapport, l'avertissement, les phrases d'explication des onglets et de la saisie, ainsi que « fondée sur vos N cycles » et la fiabilité. Modifie les décisions 103, 104, 106 et 118.

123. **Le Bilan rassemble le reste**, dans l'ordre : le rapport pour le médecin, les chiffres avec ce sur quoi repose l'estimation et sa fiabilité, le cycle en cours, la fiche clinique, la fenêtre de fertilité, les moyennes, ce qui revient, l'historique, les étapes, l'avertissement. L'avertissement « ni avis médical ni méthode de contraception » reste visible au démarrage, dans le Bilan et dans les réglages.

124. **Les modèles ne se montrent plus.** Supprimés de l'interface : la carte « Ce que disent les études », la liste des sources, la mention de la FIGO, les mots « repère » et « référence », la comparaison de chaque chiffre à un repère, la phrase sur les études dans « Comment c'est calculé ». Remplace la décision 115 et la partie visible des décisions 105 et 113.
    - Rien ne change dans les calculs : l'estimation de l'ovulation (décision 113), les plages habituelles de la fiche clinique (décision 114) et le cycle de départ selon l'âge (décision 116) tournent toujours. Les sources restent consignées ici et dans les commentaires du code.
    - La fiche clinique garde ses plages (« Plage habituelle : 24 à 38 jours »), écrites comme de simples chiffres.
    - Un chiffre qui n'est encore qu'une hypothèse porte la mention « estimation pour l'instant ».

125. **Ludification** : redemandée par l'utilisateur. La règle 13 n'a pas été modifiée ; restent la série de saisie discrète, la jauge du journal du jour et les étapes du Bilan (décision 106).

126. **Ce qui est vérifié, et où.** Sous Windows : le démarrage, le bouton « Mes règles commencent aujourd'hui », l'accueil réduit, le Bilan réorganisé, l'absence de toute mention d'étude ou de référence sur l'accueil et dans le Bilan, en anglais et en français, de droite à gauche et en grand texte. En attente de l'iPhone : le rendu réel.

127. **Comparaison « ce cycle et le précédent »** (`lib/domain/cycle_comparison.dart`, Dart pur ; `lib/ui/comparison_card.dart`). Dans le Bilan et dans le rapport pour le médecin : les deux cycles pris au même stade (les N premiers jours de chacun), quatre décomptes côte à côte (jours de règles, jours de douleur, nuits difficiles, jours saisis) et une flèche pour ce qui a bougé. La flèche dit « plus » ou « moins », jamais « mieux » ou « moins bien » (règles 7 et 13). Pas de comparaison avec un cycle de durée inhabituelle, ni avec d'autres utilisatrices : cela demanderait un serveur (règle 2).

128. **Tutoiement.** Demande de l'utilisateur : en français, l'appli tutoie l'utilisatrice partout, pour un ton plus proche, celui d'un journal intime. Les 81 textes concernés ont été réécrits ; la règle est consignée dans `CLAUDE.md`. L'anglais n'est pas concerné.

129. **Rappels actifs par défaut, une fois par téléphone.** Demande de l'utilisateur : tout doit être actif dès le début, à chaque nouvelle version. Les deux rappels sont activés à la fin du démarrage (décision 110) et, pour une appli installée avant, à la première ouverture après la mise à jour, si le téléphone accepte les notifications (iOS affiche sa fenêtre d'autorisation). Cela n'arrive qu'une fois : un rappel éteint ensuite par l'utilisatrice n'est jamais rallumé par une mise à jour, et un choix déjà fait n'est pas touché. Les widgets demandés au même moment n'existent pas encore (jalon L, paquet `home_widget` à approuver).

130. **Historique mois par mois** (`lib/domain/monthly_history.dart`, Dart pur ; carte dans `lib/ui/journal_tab.dart`). Demande de l'utilisateur : faire comprendre que tout se joue dans ce qui est renseigné mois après mois. Dans le Journal, entre le calendrier et les pages : les six derniers mois, chacun avec une jauge (jours saisis sur jours possibles), le nombre de jours saisis et de jours de règles. Un mois vide est affiché lui aussi, « rien de saisi » : les trous se voient d'un coup d'œil, sans reproche (règle 13). Une phrase le dit au démarrage : « Tout se joue dans ce que tu notes, mois après mois. »

131. **Carte du haut interactive.** Demande de l'utilisateur. Un appui sur l'anneau fait basculer son centre entre le jour du cycle et les jours restants avant les prochaines règles, donnés en fourchette (« 5–11 »), avec un léger retour tactile. L'anneau est un bouton nommé pour le lecteur d'écran. Révisé après le retour sur la compilation 13 (« pas d'interaction sur le premier panneau ») : la bascule ne marchait qu'en attente de règles, donc pas le jour de l'installation, et rien ne la signalait. Désormais toute la carte répond à l'appui, dans tous les cas où une estimation reste devant soi : avant la fourchette, dedans (« 0–3 »), et pendant les règles, pour les suivantes. Deux points sous l'anneau, comme sous des pages qu'on fait défiler, montrent qu'il existe une autre vue et laquelle est affichée. Pas de bascule quand la fourchette est dépassée ou que rien n'est saisi.

132. **Widget d'écran d'accueil : paquet `home_widget` 0.9.2**, validé par l'utilisateur le 19 novembre 2026 (règle 4).
    - Relu avant ajout : licence BSD à 3 clauses ; dépendances `flutter`, `path_provider` et `path_provider_foundation`, déjà autorisées ; aucun appel réseau dans son code Dart, Swift ou Kotlin ; aucune permission Android déclarée. Côté Android il tire `androidx.glance` et `androidx.work`, à relire au jalon Android.
    - **Ce qui sort de la base chiffrée** (`lib/domain/widget_snapshot.dart`) : le premier jour du cycle en cours, la durée estimée du cycle, la durée des règles, et la fourchette estimée des prochaines règles. Rien d'autre : ni symptôme, ni note, ni historique. Ces valeurs vont dans une zone partagée entre l'appli et son widget (« App Group » `group.app.fycle`), protégée par le verrouillage du téléphone et non par le chiffrement de la base. Écart assumé avec la règle 5, limité à ces cinq valeurs. Des dates plutôt que « jour 12 » : le widget doit rester juste les jours où l'appli n'est pas ouverte.
    - Le widget est discret : l'anneau et un nombre, sans le mot « règles » ni le nom de l'appli. Il se voit sans déverrouiller l'appli : c'est dit dans les réglages.
    - Un interrupteur « Widget d'écran d'accueil » dans les réglages (section Confidentialité), actif par défaut à la demande de l'utilisateur ; l'éteindre vide la zone partagée. « Tout supprimer » la vide aussi.
    - iOS ne permet pas à une appli de poser elle-même un widget : l'utilisatrice l'ajoute depuis l'écran d'accueil.
    - Mis à jour aux mêmes moments que les rappels (`lib/ui/widget_sync.dart`) : après chaque saisie, chaque changement de réglage et chaque retour dans l'appli.
    - Android : à faire avant toute publication (règle 10).

133. **Widget natif iOS** (`ios/FycleWidget/`, branche `ios-widget` tant qu'il n'est pas vérifié sur iPhone).
    - Une cible « FycleWidget » (WidgetKit, SwiftUI), ajoutée à la main au projet Xcode faute de Mac. Un seul format, le petit carré : l'anneau (règles en bordeaux, période estimée en ambre) et le jour du cycle au centre. Aucun mot, aucun nom.
    - Il lit les cinq valeurs de la décision 132 et compte les jours lui-même : une entrée par jour sur deux semaines, pour changer à minuit sans ouvrir l'appli. Aucun réseau, aucun accès à la base ni au trousseau (garde-fou dans `test/guardrails/platform_config_test.dart`).
    - Droits demandés : l'App Group `group.app.fycle`, pour l'appli et pour le widget, et rien d'autre. Les deux déclarations de confidentialité mentionnent l'usage des préférences partagées (motif 1C8F.1).
    - **La compilation cloud signe désormais pendant la construction** (`xcodebuild archive` avec la clé App Store Connect), et non plus après coup : le droit d'App Group doit faire partie de la signature de l'appli et du widget. Modifie la décision 56. Sans les secrets, l'appli est seulement compilée sans signature.
    - Non vérifié : tout ce qui précède n'a jamais été compilé avant la première compilation cloud de la branche. L'App Group doit être créé par Xcode avec la clé ; sinon l'utilisateur le crée dans son compte développeur.

134. **L'anneau se parcourt au doigt** (demande de l'utilisateur : « interactions plus plus », « explicite »). Le numéro 133 est pris par le widget natif, sur la branche `ios-widget`.
    - Un doigt posé sur le trait de l'anneau, puis glissé, parcourt le cycle jour par jour, avec un léger retour à chaque jour. Sous l'anneau : la date, le jour du cycle, ce qui a été noté ce jour-là (jours passés), ce qui est estimé (règles à venir, fenêtre de fertilité avec son avertissement, règle 7), et ce qui revient d'habitude vers ce jour dans ses cycles précédents.
    - Un jour passé s'ouvre dans le journal par un bouton. Un jour à venir ne s'ouvre pas. Un appui ailleurs sur la carte, ou le bouton « Revenir à aujourd'hui », referme.
    - Le doigt posé sur le trait est pris par l'anneau seul : la page ne défile pas dessous (`_RingBandRecognizer`). Posé ailleurs, rien ne change : l'appui change de vue, le glissement fait défiler.
    - L'anneau passe de 112 à 168 points et se place au-dessus du texte, centré : il faut la place d'un doigt. Il se lit comme une horloge, dans le même sens quelle que soit la langue.
    - Lecteur d'écran : l'anneau s'ajuste comme un curseur (jour suivant, jour précédent), et annonce le jour et sa date. La phrase « Glisse le doigt… » ne lui est pas lue.
    - L'appui fait défiler jusqu'à trois vues : jour du cycle, jours restants, « d'habitude vers ce jour ». La troisième n'existe que si son journal la nourrit. Elle remplace la carte du même nom sur l'accueil.
135. **Accueil à deux cartes, bilan à trois** (demande de l'utilisateur : « plus épurée »).
    - Accueil : l'anneau et le journal du jour. Le bilan de fin de cycle y passe encore une fois par cycle, jusqu'à ce qu'il soit fermé (règle 13 : mécanisme sobre). Les suggestions « rappels » et « verrouillage » ne s'y affichent plus : les deux se règlent dans les réglages, et les rappels sont déjà proposés au premier lancement (décision 129).
    - Bilan : le rapport pour le médecin, les chiffres, la comparaison avec le cycle précédent, la fenêtre de fertilité estimée. La fiche clinique, le détail du cycle, les moyennes, ce qui revient, la liste des cycles et « plus tu saisis » sont à un appui, sur l'écran « Le détail » (`ReviewDetailScreen`). Rien n'est supprimé.
    - « Voir les tendances », sur le bilan de fin de cycle, ouvre directement cet écran.
136. **Moteur de prédiction : la référence par âge n'est pas une durée déclarée ; fin des règles estimée.**
    - Jusqu'ici, la durée de référence pour son âge (décision 113, Bull et al. 2019) entrait dans le calcul à la place de la durée qu'elle déclare, et donnait donc une marge de 5 jours. Une moyenne publiée ne dit rien d'elle : la marge reste celle d'une population, 7 jours de chaque côté. Dans Fehring et al. 2006, 95 % des cycles tiennent entre 22 et 36 jours, soit 7 jours autour de la moyenne. La durée qu'elle déclare garde sa marge de 5 jours.
    - La référence compte toujours comme un cycle de faible poids tant que moins de trois cycles sont saisis, puis s'efface (`PeriodPredictor.predict`, paramètre `referenceCycleLength`).
    - Pendant les règles, la carte dit combien de jours elles peuvent encore durer, en fourchette : du plus court au plus long de ses six dernières règles (`lib/domain/period_end_estimate.dart`). Rien n'est dit avant deux règles passées, ni quand celles en cours dépassent toutes les autres. Aucune moyenne publiée n'est utilisée ici : seulement ses propres chiffres.
    - Écarté : le poids, la taille et le sport. Aucune étude vérifiée ne donne à ce jour un calcul utilisable ; rien n'est inventé (question ouverte « Profil de départ »).
    - Textes nouveaux à faire relire par un professionnel de santé avant toute diffusion au-delà des deux testeurs (règle 7) : la fourchette de fin des règles et les lignes affichées en parcourant l'anneau.

137. **Les rappels sont redemandés une fois après chaque mise à jour** (demande de l'utilisateur : « à chaque mise à jour, Fycle doit demander les notifications : c'est sa base »). Complète la décision 129.
    - À la première ouverture de chaque nouvelle compilation, si les deux rappels ne sont pas actifs, l'appli pose la question : « Activer les deux rappels ? », avec « Activer » et « Plus tard ». « Plus tard » ne change rien ; la compilation suivante redemandera.
    - Si le téléphone n'a jamais répondu à la demande de notifications, c'est la question du système qui s'affiche. S'il les a refusées, le système ne permet plus de la reposer : l'appli dit alors ce que cela coûte et où les autoriser, avec un seul bouton.
    - **Elle demande, elle ne réactive pas d'elle-même** un rappel que l'utilisatrice a coupé, et **elle ne prétend pas que les notifications sont nécessaires pour fonctionner** : ce serait faux, et les règles de l'App Store interdisent d'exiger les notifications pour utiliser une appli. Le texte dit ce qui est vrai : sans elles, l'appli ne peut ni prévenir avant les règles ni rappeler le journal.
    - Un premier lancement pose déjà la question à sa façon (décision 129) : pas deux fois.
    - L'appli connaît son numéro de compilation par une constante donnée à la compilation (`--dart-define=FYCLE_BUILD`, dans `.github/workflows/ios.yml`), sans nouvelle dépendance. Une compilation faite à la main n'a pas de numéro et ne demande rien. À reprendre à l'identique dans la compilation Android (règle 10).
    - Le téléphone retient la compilation déjà traitée parmi ses réglages propres (`reminders_asked_<numéro>`), hors sauvegarde.
138. **Retouches d'interface après avoir vu les écrans rendus en images.**
    - En tête de l'accueil, la date du jour (« Vendredi 20 mars »), comme en haut d'une page de journal, à la place du bouton « Accueil », qui n'y menait nulle part. Sur les autres onglets, le bouton de retour à l'accueil reste au même endroit.
    - La fenêtre de fertilité estimée est tracée plus claire que le reste de l'anneau : c'est l'estimation la plus large et la moins sûre.
    - La phrase sous l'anneau tient sur une ligne ; les rangées de choix du journal du jour sont resserrées.

139. **Animation de lancement** (demande de l'utilisateur : une signature animée à chaque lancement).
    - À chaque lancement, sur fond bleu nuit, l'anneau du cycle se trace dans le sens des aiguilles d'une montre (les jours de règles d'abord), un point le précède puis se pose, et l'anneau s'ouvre sur l'appli. Un peu plus d'une seconde et demie ; un appui la passe (`lib/ui/launch_animation.dart`).
    - C'est l'anneau de l'accueil qui sert de signe : l'appli n'a pas encore de logo, et le nom n'y figure pas. Dessin original, sans son.
    - Jouée au lancement seulement, pas au retour depuis l'arrière-plan. Elle passe par-dessus tout, verrou compris, pendant que l'appli se prépare dessous : elle n'ajoute pas d'attente à l'ouverture de la base.
    - Pas jouée quand le téléphone demande de réduire les animations. Cachée au lecteur d'écran, qui va droit à l'appli.
    - Mêmes couleurs en clair et en sombre. L'écran de lancement natif d'iOS prend le même bleu nuit, pour qu'il n'y ait pas d'éclair blanc avant l'animation.
    - L'icône de l'appli reprend ce signe (décision 140).
140. **Icône de l'appli** (accord de l'utilisateur du 20 novembre 2026). Remplace l'icône par défaut de Flutter.
    - Le signe de l'animation de lancement (décision 139) : sur fond bleu nuit, l'anneau crème, les jours de règles en rose, le point doré du jour. L'anneau s'arrête sous le point, pour laisser un souffle avant le début des règles. Ni lettre ni nom : l'icône ne dit pas « règles » à qui regarde l'écran par-dessus l'épaule.
    - Dessinée par un script, `tool/make_icon.py` (Python et Pillow, sur le poste seulement : rien de cela n'entre dans l'appli, aucune dépendance ajoutée). Il écrit toutes les tailles demandées par iOS, sans transparence, et celles d'Android. Pour changer l'icône : modifier le script et le relancer, jamais retoucher une image à la main.
    - Android (règle 10) : même icône, plus une icône adaptative (`mipmap-anydpi-v26/ic_launcher.xml`), le signe seul tenant dans la zone qu'aucune forme de lanceur ne coupe. Non vérifiée sur un appareil : Android ne se compile pas encore ici.
    - La question ouverte « Nom et icône neutres » reste entière : une icône alternative au choix n'est pas faite.
141. **Parcours de départ : une question par écran, et des réponses qui servent** (demande de l'utilisateur du 20 novembre 2026 : « bien plus sérieux et ergonomique », après avoir parcouru le démarrage d'une appli du domaine). Remplace l'écran unique du premier lancement, qui ne demandait que la date des dernières règles.
    - Onze écrans au plus (`lib/ui/onboarding_screen.dart`) : bienvenue, prénom, année de naissance (une roue), objectifs, régularité, durées habituelles, changements récents, dernières règles (un calendrier où l'on touche le jour), rappels, verrouillage, « Tout est prêt ». Une barre de progression, un retour, et « Passer » sur chaque question : rien n'est obligatoire. « Passer la configuration », sur le premier écran, entre directement, comme avant.
    - Le parcours dépend des réponses : sans règles, ni durées ni date ne sont demandées ; les changements récents ne sont demandés que si elle a choisi la périménopause ou à partir de 40 ans (seuil choisi par l'appli, pas tiré d'une publication).
    - Rien n'est enregistré avant la fin, sauf les rappels et le verrouillage, qui sont des réglages du téléphone. Une année de naissance n'est une réponse qu'une fois la roue tournée.
    - **Ce que les réponses changent** (`lib/domain/start_profile.dart`) :
        - Régularité. Si elle dit que ses cycles sont irréguliers, la fourchette part de 10 jours de chaque côté, le plus large que l'appli admette, et ne descend pas sous 5 jours avant trois cycles saisis ; ensuite ses propres dates décident, comme pour toutes. Repère : FIGO 2018 (Munro, Critchley, Fraser) appelle irréguliers des cycles dont le plus court et le plus long diffèrent de plus de 7 à 9 jours selon l'âge. Les valeurs 10 et 5 sont un choix de l'appli à partir de ce seuil, pas des chiffres publiés. « Oui » et « Je ne sais pas » ne changent rien au calcul.
        - Durée des règles déclarée. Tant que deux règles passées ne sont pas saisies, elle sert à dire combien de jours les règles en cours peuvent encore durer, avec la mention « d'après ce que tu as indiqué » (complète la décision 136).
        - Objectifs. Si elle répond, la fenêtre de fertilité estimée n'est affichée d'office que pour « Concevoir » ou « Mieux comprendre mon corps » ; l'avertissement de la règle 7 est affiché dès qu'elle touche « Concevoir ». Sans réponse, rien ne change.
        - Âge. Déjà utilisé pour la durée de départ (décision 113). La variabilité selon l'âge n'est pas ajoutée : dans Bull et al. 2019, elle ne bouge que d'un demi-jour entre les plus jeunes et les plus âgées, moins que le pas d'un jour de la fourchette.
    - Le prénom, les objectifs et les changements récents restent des réglages du téléphone, hors sauvegarde. La régularité et la durée des règles, qui changent le calcul, voyagent avec la sauvegarde (champs facultatifs, version de contenu inchangée).
    - Les changements récents sont enregistrés et pas encore utilisés : ils serviront au suivi de la périménopause (étape suivante), sous forme de constat, jamais de score (règle 7).
    - Les mêmes questions se rouvrent depuis les réglages (« Mes réponses »), remplies avec ce qu'elle a répondu.
    - Les rappels choisis pendant le parcours sont ceux qui sont activés ; ceux qu'elle passe restent coupés, et rien n'est réactivé derrière elle (complète les décisions 129 et 137). Le téléphone n'est interrogé que si elle garde au moins un rappel.
    - **Non repris**, volontairement : consentement au suivi publicitaire, « comment as-tu connu l'appli », compte, code partenaire (question ouverte), articles et encarts d'information médicale (à écrire et relire par un professionnel de santé), mode grossesse.
    - Textes nouveaux à faire relire par un professionnel de santé avant toute diffusion au-delà des deux testeurs (règle 7) : la question sur les changements récents et ses réponses, la question sur la régularité.
142. **Suivi d'un cycle qui change : un constat, jamais un score** (étape 2 du parcours de départ, accord de l'utilisateur du 20 novembre 2026).
    - Pour qui : celles qui ont choisi « Suivre une périménopause », ou à partir de 40 ans (même condition que la question du parcours, décision 141). Les autres ne voient rien de tout cela.
    - Deux signes de plus à cocher dans le journal : bouffées de chaleur et sueurs nocturnes. Un signe déjà coché reste affiché même si elle change d'objectif.
    - Une carte « Ce qui change », dans le bilan et dans le rapport pour le médecin (`lib/domain/cycle_change.dart`, `lib/ui/change_card.dart`). Elle compte, sur les dix derniers cycles complets :
        - les cycles dont la durée diffère du précédent de 7 jours ou plus ; à partir de deux, l'écart « revient » ;
        - un cycle de 60 jours ou plus, ou 60 jours ou plus écoulés depuis les dernières règles ;
        - les jours où chaque signe a été noté, sur 90 jours ;
        - et rappelle ce qu'elle avait indiqué au départ.
    - Source des deux seuils : Harlow et al., STRAW + 10, 2012 (écart persistant de 7 jours ou plus entre cycles consécutifs, persistant voulant dire qu'il revient dans les 10 cycles ; intervalle de 60 jours ou plus sans règles). La fenêtre de 90 jours pour les signes est un choix de l'appli.
    - **Ce que la carte ne fait pas** (règle 7) : elle ne nomme aucun stade, n'écrit pas le mot « ménopause », ne donne ni score ni probabilité. Quand un seuil est franchi, elle dit que c'est à signaler à un médecin ou à une sage-femme, et que beaucoup de choses peuvent faire bouger un cycle. Un test vérifie que le mot n'apparaît pas.
    - Un cycle de plus de 90 jours reste traité comme un oubli de saisie, pas comme un changement (décision sur les cycles plausibles).
    - Textes à faire relire par un professionnel de santé avant toute diffusion au-delà des deux testeurs.
    - Non fait : articles d'information sur la périménopause (à écrire et relire par un professionnel de santé), autres signes (humeur et sommeil sont déjà dans le journal).
143. **Parcours de départ complet : dix-huit écrans au plus, et un récapitulatif de ce qui a été réglé** (demande de l'utilisateur du 20 novembre 2026 : « un parcours complet (libido, préménopause, plein de choses) »). Complète la décision 141.
    - Écrans ajoutés : « Tes données restent ici » (quatre phrases vraies, aucune case à cocher), un mot d'accueil avec le prénom, « Dis-m'en plus sur ce que tu veux », « Tes règles, d'habitude » (abondance et douleur), la contraception, les signes du moment (pour celles qui suivent un cycle qui change), les règles d'avant (trois premiers jours au plus, sur un calendrier), « Que veux-tu suivre au quotidien ? ».
    - **Chaque réponse sert, sinon la question n'est pas posée** :
        - Règles d'avant : l'estimation part de ses propres cycles dès le premier jour. C'est la réponse qui pèse le plus dans le calcul.
        - Contraception hormonale : l'estimation d'ovulation et la fenêtre de fertilité sont masquées, car des saignements sous hormones ne suivent pas un cycle naturel. L'appli le dit et ne donne aucun conseil de contraception (règle 7). Le rappel de prise n'est pas fait.
        - « Connaître ma fenêtre de fertilité » : l'affiche, avec son avertissement, sauf sous contraception hormonale.
        - Ce qu'elle veut suivre (douleur, humeur, sommeil, libido, symptômes) : le journal du jour commence par là, après les règles, et l'accueil propose ces rubriques en un appui. Rien n'est caché : le reste suit. Sans réponse, douleur et humeur, comme avant.
        - Abondance habituelle : les premiers jours donnés pendant le parcours sont enregistrés avec cette abondance, moyenne sinon.
        - Signes du moment et changements récents : rappelés dans la carte « Ce qui change » et dans le rapport pour le médecin.
        - Douleur habituelle, et les souhaits « situer mon cycle », « après l'arrêt d'une contraception », « ce qui revient » : enregistrés, sans effet sur le calcul pour l'instant. Aucun chiffre publié et vérifié ne permet aujourd'hui de régler la fourchette après l'arrêt d'une contraception : rien n'est inventé.
    - Le dernier écran dit ce qui a réellement été réglé : d'où part l'estimation (ses dates, sa réponse, la moyenne publiée pour son âge, ou la valeur courante), la fourchette, la fenêtre de fertilité affichée ou non et pourquoi, l'ordre du journal, le suivi des changements, les rappels, le verrouillage. Il remplace l'écran d'attente « personnalisation » des applis du domaine, qui ne calcule rien.
    - Quatre signes de plus pour celles qui suivent un cycle qui change : sécheresse vaginale, douleurs articulaires, difficulté à se concentrer, palpitations. La carte « Ce qui change » compte les jours de chacun (complète la décision 142).
    - Toutes ces réponses sont des réglages du téléphone, hors sauvegarde.
    - Passer une question efface sa réponse : une réponse se confirme par « Continuer ».
    - **Non repris**, volontairement : l'abonnement (règle 9), l'engagement « maintiens le doigt appuyé » (règle 13), le suivi publicitaire, le compte, l'écran d'attente factice.
    - **Pas encore fait**, à cadrer : import depuis Apple Santé et Health Connect (nouvelle dépendance, règle 4), mode grossesse, partage avec un partenaire (règle 2), articles (à faire écrire et relire par un professionnel de santé), rappel de prise de contraception, illustrations.
    - Textes à faire relire par un professionnel de santé avant toute diffusion au-delà des deux testeurs : la phrase sur la contraception hormonale, la liste des signes.
144. **Fichier de sauvegarde fictif pour voir l'appli après un an** (`test/fixtures/demo-one-year.fycle`, écrit par `tool/make_demo_backup.dart`). Quatorze cycles inventés, du 25 septembre 2025 au 20 novembre 2026, année de naissance 1984. Aucune donnée réelle. Son mot de passe est dans le script : il ne protège que des jours inventés.
145. **Carte « Ton suivi » sur l'accueil : des chiffres qui donnent envie de noter chaque jour, sans ludification** (demande de l'utilisateur du 20 novembre 2026 : « plus de KPI qui donnent envie de remplir quotidiennement »). Revient sur la décision 135 : l'accueil a de nouveau trois cartes.
    - Les sept derniers jours, une ligne par chose suivie (le journal dans son ensemble, puis ce qu'elle a choisi au départ ; douleur et humeur sinon) : un point plein quand c'est noté, vide sinon. Les jours vides se voient d'un coup d'œil, sans commentaire.
    - Deux comptes : jours notés sur les 7 derniers, jours notés ce mois-ci sur les jours écoulés.
    - Le cycle en cours en chiffres : jours notés, bonnes nuits, jours de douleur, humeur et libido les plus fréquentes, chacun à côté du cycle précédent pris au même nombre de jours (`lib/domain/daily_figures.dart`). Humeur et libido n'apparaissent que si elles ont été notées.
    - La fiabilité de l'estimation sur trois crans, avec ce qui la ferait monter : le nombre de cycles encore à noter, tiré des règles du moteur (`PeriodPredictor.cyclesForMediumConfidence`, `cyclesForHighConfidence`). Quand ce ne sont pas les cycles qui manquent mais ses cycles qui varient, la carte le dit, et dit que cela ne tient pas à sa façon de noter : aucune promesse fausse.
    - Règle 13 : ni points, ni badge, ni félicitations, ni reproche. Un test vérifie l'absence de ces mots. La série de saisie reste dans la carte du journal du jour.
146. **La fenêtre de fertilité n'est affichée qu'à celle qui la demande** (retour du premier essai, 20 novembre 2026 : elle s'affichait chez une utilisatrice qui ne l'avait pas demandée). Corrige les décisions 141 et 143.
    - Cause : « Mieux comprendre mon corps » suffisait à l'afficher. Ce n'est pas la demander.
    - Règle (`showsFertilityFor`) : affichée si elle veut concevoir, ou si elle a coché « Connaître ma fenêtre de fertilité estimée ». Jamais sous contraception hormonale. Celle qui a répondu sans la demander ne la voit pas. Seule celle qui n'a répondu à rien garde l'affichage par défaut.
    - Les installations déjà faites sont réalignées une fois sur les réponses données, au premier lancement de cette version (`fertility_from_answers`). Ensuite l'interrupteur des réglages lui appartient : l'appli n'y retouche que si elle change ses réponses sur ses objectifs, ses souhaits ou sa contraception.
    - Chaque utilisatrice a donc son propre affichage, selon ses réponses et son interrupteur.
147. **Nouvelle palette : prune, rose, rose pâle, beige, taupe** (choix de l'utilisateur du 20 novembre 2026, sur une palette de cinq couleurs). Remplace le bleu nuit et l'ambre des décisions 77 et 82, y compris leur règle « ni rose ».
    - Prune `#73435A` : en-têtes, boutons, tout ce qui est sélectionné. Rose `#C67F87` : jours de règles (un ton plus foncé, `#A9505F`, là où un chiffre blanc est écrit dessus). Rose pâle `#F2D5DC` : fonds doux, carte de l'estimation. Beige `#D6BCA5` et taupe `#B08F82` : traits, et ce qui est estimé.
    - Aucun texte n'est écrit dans les trois couleurs claires : il est prune, ou dans un ton plus sombre de la même teinte, pour rester lisible. Le thème sombre décline la même palette.
    - **Sélections sans équivoque** : une réponse choisie dans le parcours est remplie en prune avec son texte en blanc, au lieu d'un fond pâle avec un filet.
    - L'icône, l'animation de lancement et l'écran de lancement natif prennent les mêmes couleurs (`tool/make_icon.py`).
    - La typographie ne change pas : police du système.
148. **Retours de la première utilisatrice, 20 novembre 2026.**
    - Textes du parcours réécrits pour dire quoi faire en une phrase : durées, « Comment sont tes règles d'habitude ? », signes, « Que veux-tu noter chaque jour ? », rappels. L'écran de confidentialité devient un argument : « Tes données ne quittent jamais ton téléphone ».
    - Changements récents : un « moins » pour chaque « plus » (flux, durée, douleur, régularité). Deux contraires ne se cochent pas ensemble. L'ancien « la durée a changé » n'est plus proposé mais reste lu s'il a été donné.
    - Signes ajoutés : migraine et sautes d'humeur (proposés à toutes dans le journal), et la liste du parcours reprend aussi insomnie et fatigue.
    - Accueil : une légende sous l'anneau dit ce que ses couleurs représentent, et une phrase dit si elle est dans la première ou la seconde moitié de son cycle.
    - « Ton suivi » devient quelques tuiles à lire d'un coup d'œil, à la manière d'une appli de santé : une grande valeur, ce qu'elle compte, et le cycle précédent. Les tuiles sont celles de ce qu'elle a choisi de suivre : chaque utilisatrice a les siennes. Le détail jour par jour (les 7 derniers jours, le mois) passe dans l'onglet Journal. Corrige la décision 145.
    - **Pas fait** : le mode grossesse, qui est une autre appli dans l'appli (estimation, rappels et bilan à suspendre, repères propres à la grossesse à faire relire par un professionnel de santé). À cadrer à part.
149. **Des profils dès le départ, un mode grossesse et un mode après l'accouchement** (demande de l'utilisateur du 20 novembre 2026 : « on a plusieurs profils de femme », « chaque femme est différente »). Jalon G de la V2, première version.
    - Le parcours demande « Où en es-tu ? », une seule réponse (`lib/domain/life_stage.dart`) : je découvre mon cycle, je suis mes règles, je cherche à concevoir, je suis enceinte, j'ai accouché, mon cycle change. Cette question remplace celle des objectifs ; chaque profil vaut les objectifs que le reste de l'appli lit déjà (`goalsOf`). Le profil se change à tout moment dans « Mes réponses ».
    - Le profil règle ce qui est demandé ensuite : enceinte ou après l'accouchement, plus aucune question sur la régularité, les durées ou les règles d'avant ; à la place, la date qui compte (premier jour des dernières règles, ou jour de l'accouchement).
    - **Mode grossesse** : l'estimation des règles, le rappel avant les règles et la fenêtre de fertilité sont en pause. En tête de l'accueil, les semaines et jours écoulés depuis le premier jour des dernières règles, et la période où une naissance serait à terme (de 37 à 42 semaines révolues, définitions obstétricales usuelles). L'appli compte à partir de la date donnée et le dit ; elle ne date rien : « seule l'échographie de datation donne une date fiable » (règle 7). Le journal du jour reste. Passé 42 semaines, la carte propose de changer la date ou de quitter le mode.
    - Quitter le mode demande seulement « Où en es-tu maintenant ? » : j'ai accouché, ou revenir au suivi de mon cycle. Aucune autre question, aucun commentaire.
    - **Après l'accouchement** : tant qu'aucunes règles ne sont notées depuis la naissance, rien n'est estimé ; l'accueil compte les semaines et dit que l'estimation reprendra au retour des règles. Ensuite, seules les règles revenues comptent (`startsSinceBirth`), et la fourchette reste large pendant les trois premiers cycles, puis ses propres dates décident. Les cycles d'avant la grossesse ne sont pas effacés : ils ne servent plus au calcul.
    - Le profil et ses deux dates sont des réglages du téléphone, hors sauvegarde.
    - Limites connues : pendant la grossesse, la carte du jour propose encore « Règles aujourd'hui » pour noter un saignement, sous ce nom ; aucun contenu propre à la grossesse (symptômes, rendez-vous) ; le profil « je découvre » ne change encore que l'affichage de la fertilité.
    - Textes à faire relire par un professionnel de santé avant toute diffusion au-delà des deux testeurs : toute la carte grossesse et la carte d'après l'accouchement.
150. **Mode partenaire sans serveur : un fichier chiffré qu'elle envoie elle-même** (accord de l'utilisateur du 20 novembre 2026 : « oui, sans serveur »). Tranche la question ouverte de la décision 76 pour cette version.
    - Elle : Réglages → « Partager avec mon partenaire ». Elle choisit ce qu'elle partage (son prénom, sa fenêtre de fertilité estimée ; les règles prévues le sont toujours), donne un mot de passe, et enregistre le fichier. Elle l'envoie par le moyen qu'elle veut : l'appli n'envoie rien (règles 1 et 2).
    - Le fichier (`lib/domain/partner_snapshot.dart`) contient le premier jour du cycle en cours, la durée de ses règles, la fourchette de ses prochaines règles, et selon ses choix la fenêtre de fertilité, la date de début de grossesse ou d'accouchement. **Rien de ce qu'elle note jour après jour.** Même chiffrement que la sauvegarde (`BackupCodec.encodeText`).
    - Lui : sur l'écran de bienvenue, « Mon ou ma partenaire m'a envoyé un fichier ». L'appli passe en lecture seule : où elle en est le jour où il regarde, les règles prévues, la fenêtre de fertilité avec son avertissement (règle 7). Le contenu est gardé sur son téléphone, dans la base chiffrée.
    - Le fichier est une photo d'un jour : il ne se met pas à jour. Passé la fourchette estimée, l'écran dit que les dates sont dépassées et qu'il faut en demander un nouveau. Un partage en direct demanderait un serveur : non fait, et il faudrait changer la règle 2.
    - Limite : un téléphone sert soit à suivre son propre cycle, soit à suivre celui d'une partenaire, pas les deux.
151. **Migraines détaillées** (jalon D). Quand « Migraine » est cochée, trois précisions facultatives : intensité, durée (quelques heures, une journée, plus d'une journée), médicament pris ou non. Stockées avec le jour (base en version 4, trois colonnes ajoutées ; la sauvegarde les emporte ; l'export tableur gagne une colonne seulement s'il y en a). Une carte du bilan et du rapport compte les jours de migraine sur 90 jours, ceux qui tombent pendant les règles ou les deux jours d'avant, et ceux avec un médicament noté. Elle compte ; elle ne dit rien des causes ni des traitements (règle 7).
152. **Rappel de contraception** (jalon G). Un rappel quotidien à l'heure choisie, activé dans les réglages. Texte neutre sur l'écran verrouillé (« C'est l'heure. »). Aucun conseil, et rien n'est vérifié : l'appli ne sait pas si la prise a eu lieu (règle 7).
153. **Rapport pour le médecin en PDF** (jalon H ; paquet `pdf` accepté par l'utilisateur le 20 novembre 2026, règle 4). Fabriqué sur le téléphone, remis à la boîte de dialogue de fichiers du système. Contenu : moyennes et étendue des six derniers cycles, leur liste, ce qui change d'un cycle au suivant pour celles qui le suivent, les migraines comptées, et la mention « pas un diagnostic ». Paquets transitifs ajoutés à la liste blanche : `archive`, `barcode`, `bidi`, `image`, `path_parsing`, `posix`, `qr`, tous en Dart pur, sans réseau. Les polices intégrées aux lecteurs PDF ne couvrent que l'alphabet latin occidental : pour une autre écriture, il faudra embarquer une police (à faire avant la traduction correspondante, règle 11).
154. **Sauvegarde automatique** (jalon I). Activée dans les réglages : elle demande une fois un mot de passe, gardé dans le trousseau du système, sur cet appareil seulement. Une fois par jour, à la première ouverture ou au premier changement, un fichier chiffré `Fycle-backup.fycle` est mis à jour dans le dossier de documents de l'appli, rendu visible dans l'app Fichiers (`UIFileSharingEnabled`, `LSSupportsOpeningDocumentsInPlace`). Aucun appel réseau : ce que le téléphone fait ensuite de ce dossier lui appartient (règle 1). Limites : une fois par jour, donc ce qui est noté plus tard dans la journée part le lendemain ; sur Android, ce dossier n'est pas visible de l'utilisatrice, la parité reste à faire (règle 10).
155. **Touches propres à chaque profil.** Celle qui découvre a sur l'accueil quelques phrases simples sur ce qu'est un cycle. Celle qui cherche à concevoir a la fenêtre de fertilité estimée parmi ses chiffres, avec « une estimation, pas une certitude ». Pendant la grossesse, un saignement ne s'appelle plus « règles ». Phrases à faire relire par un professionnel de santé.
156. **Reporté, sur décision de l'utilisateur du 20 novembre 2026** : l'achat unique et l'essai de trois cycles (jalon J), tant que le produit n'existe pas dans App Store Connect. Le paquet `in_app_purchase` est accepté d'avance mais n'est pas ajouté. « Ludique » s'entend comme agréable et léger : la règle 13 reste telle quelle.

## Questions ouvertes

- **Le nom « Fycle » dans l'appli** : l'utilisateur a demandé qu'il n'apparaisse plus. Fait pour l'en-tête (décision 118). Il reste au démarrage (« Bienvenue dans Fycle »), sur l'écran de verrouillage, dans les réglages et dans l'avertissement : à confirmer avant de le retirer partout.
- **Profil de départ** (demande de l'utilisateur du 19 novembre 2026) : demander la date de naissance, le poids, etc. au démarrage pour partir d'un repère personnalisé et donner une vision à long terme. À cadrer avant tout code : l'année de naissance a un effet publié sur la durée du cycle (décision 113) ; le poids est une donnée sensible, à ne demander que si un effet publié est réellement utilisé ; une « vision à long terme » ne doit jamais devenir une prévision médicale (règle 7).

- **Partage partenaire et règle 2** (décision 76) : un relais, même chiffré de bout en bout, est un serveur et fait sortir des données du téléphone. L'échange direct entre téléphones (code à scanner, fichier) respecte les règles 1 et 2 ; le relais demande de les modifier. À trancher à la conception du sprint 2.
- **Chiffrement et stores** (décisions 59 et 60) : la note de cadrage prévoit de répondre « chiffrement standard du système uniquement ». Ce n'est pas le cas de Fycle, qui embarque ses propres algorithmes standards. La décision 60 tient : déclaration à l'ANSSI avant tout test externe en France.
- **Parité pendant les essais** (règle 10) : comprise comme une condition de publication sur les stores, pas des essais TestFlight, puisque Android ne se compile pas encore sur le poste. À confirmer.
- **Widgets et montre** : ils demandent du code natif (Swift, Kotlin), et une appli de montre séparée. Un widget lit ses données hors de la base chiffrée : que lui confier, et comment le protéger ? La complication de montre ne se vérifie pas sans montre.
- **Essai de trois cycles** (décision 66) : comment le compter sans compte ni serveur, et que se passe-t-il après une réinstallation ?
- **Nom et icône neutres** (mode discret) : icône alternative au choix, ou icône neutre pour toutes ?
- **Données publiques pour caler le modèle** (décision 72) : licences à vérifier avant usage.
- **Relecture médicale** (décision 73) : par qui, et quand ?
- **Paquets de la V2** à proposer et relire avant ajout (règle 4) : achat intégré, données de santé, PDF, widgets.
- **Pourboire** : la note de cadrage dit à la fois « pas de pourboire pour l'instant » et le retient parmi les leviers et dans le sprint 1. Retenu ici (décision 68) ; à confirmer.

- **Rendu sur iPhone** de la nouvelle charte (décision 77) : à voir sur le téléphone, VoiceOver compris, une fois le thème refait.

- **Déclaration française de chiffrement** (décisions 59 et 60) : à déposer auprès de l'ANSSI avant tout test externe et avant la sortie publique en France. Le délai se compte en semaines : à lancer bien avant. À faire confirmer par une personne compétente : cette déclaration est-elle vraiment exigée pour une appli comme Fycle ?
- **Icône de l'appli** : c'est encore celle de Flutter. À dessiner avant la fiche publique.

- **Android, rappels et verrouillage** : à configurer et vérifier au jalon Android. Reprogrammation après redémarrage du téléphone (permission et récepteurs à déclarer dans le manifeste), réglage de compilation exigé par `flutter_local_notifications` (« desugaring »), activité principale à adapter pour `local_auth`, écran masqué dans les applis récentes (`FLAG_SECURE`, quelques lignes natives). Sur Android, le choix d'un fichier fait passer l'appli en arrière-plan : le verrou se redemandera au retour.
- **Code propre à l'appli** pour le verrouillage (décision 51) : à revoir si des utilisatrices partagent le code de leur téléphone.
- **SDK Android** à installer sur le poste de développement (décision 45).
- **Achat intégré** : paquet à retenir (candidat : `in_app_purchase`, de l'équipe Flutter), à relire avant le jalon du pack Pro.
- **Android** : peut-on se passer de la permission INTERNET tout en gardant l'achat intégré ? À vérifier.
- **Objectif de revenu** : 400 € par mois, soit une quarantaine de ventes par mois à 14,99 € (décision 65).
- **Hypothèses de marché, non vérifiées** : 3 à 8 % des utilisatrices achèteraient ; un lancement sans publicité sur le seul marché francophone amènerait 5 000 à 20 000 téléchargements en 12 à 24 mois. À ce niveau, l'objectif de 400 € par mois n'est pas atteint : il suppose le marché anglophone ou un relais par des créatrices de contenu. À mesurer dès les premières utilisatrices.
- **Import depuis d'autres applis** : formats d'export à étudier. Les noms des applis sources n'apparaissent ni dans le code ni dans l'interface (règle 8) ; à voir comment présenter la fonction.
- **Stores** : politique de confidentialité à rédiger, obligatoire pour une appli de santé.
- **Niche d'entrée** (douleurs chroniques, arrêt d'une contraception hormonale…) : à décider après les premiers retours.
- **Validation du modèle** auprès d'autres utilisatrices : à faire une fois la base de l'appli disponible (décidé le 19 novembre 2026).
- **Réservation du nom** : fiches à créer dans App Store Connect et dans la Play Console.
- **Import de l'historique** depuis Apple Santé.
- **Marque** : dépôt INPI et vérification EUIPO à faire. Noms de domaine à réserver.
- **Google Play** : un compte personnel impose un test fermé de 12 testeurs pendant 14 jours avant la mise en production.
