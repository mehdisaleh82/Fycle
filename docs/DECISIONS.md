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

## Questions ouvertes

- **Déclaration française de chiffrement** (décisions 59 et 60) : à déposer auprès de l'ANSSI avant tout test externe et avant la sortie publique en France. Le délai se compte en semaines : à lancer bien avant. À faire confirmer par une personne compétente : cette déclaration est-elle vraiment exigée pour une appli comme Fycle ?
- **Icône de l'appli** : c'est encore celle de Flutter. À dessiner avant la fiche publique.

- **Android, rappels et verrouillage** : à configurer et vérifier au jalon Android. Reprogrammation après redémarrage du téléphone (permission et récepteurs à déclarer dans le manifeste), réglage de compilation exigé par `flutter_local_notifications` (« desugaring »), activité principale à adapter pour `local_auth`, écran masqué dans les applis récentes (`FLAG_SECURE`, quelques lignes natives). Sur Android, le choix d'un fichier fait passer l'appli en arrière-plan : le verrou se redemandera au retour.
- **Code propre à l'appli** pour le verrouillage (décision 51) : à revoir si des utilisatrices partagent le code de leur téléphone.
- **Démarrage sans date** : la date des dernières règles est obligatoire au premier lancement (décision 34). À revoir si des utilisatrices ne s'en souviennent pas : il faudrait alors mémoriser que le démarrage a été passé.
- **SDK Android** à installer sur le poste de développement (décision 45).
- **Achat intégré** : paquet à retenir (candidat : `in_app_purchase`, de l'équipe Flutter), à relire avant le jalon du pack Pro.
- **Android** : peut-on se passer de la permission INTERNET tout en gardant l'achat intégré ? À vérifier.
- **Pack Pro** : contenu exact et prix. Hypothèse de travail : 9,99 €, soit environ 7 € nets par vente après TVA et commission du store, donc environ 57 ventes par mois pour l'objectif de revenu.
- **Hypothèses de marché, non vérifiées** : 3 à 8 % des utilisatrices achèteraient ; un lancement sans publicité sur le seul marché francophone amènerait 5 000 à 20 000 téléchargements en 12 à 24 mois. À ce niveau, l'objectif de 400 € par mois n'est pas atteint : il suppose le marché anglophone ou un relais par des créatrices de contenu. À mesurer dès les premières utilisatrices.
- **Import depuis d'autres applis** : formats d'export à étudier. Les noms des applis sources n'apparaissent ni dans le code ni dans l'interface (règle 8) ; à voir comment présenter la fonction.
- **Stores** : politique de confidentialité à rédiger, obligatoire pour une appli de santé.
- **Niche d'entrée** (douleurs chroniques, arrêt d'une contraception hormonale…) : à décider après les premiers retours.
- **Validation du modèle** auprès d'autres utilisatrices : à faire une fois la base de l'appli disponible (décidé le 19 novembre 2026).
- **Réservation du nom** : fiches à créer dans App Store Connect et dans la Play Console.
- **Import de l'historique** depuis Apple Santé.
- **Marque** : dépôt INPI et vérification EUIPO à faire. Noms de domaine à réserver.
- **Google Play** : un compte personnel impose un test fermé de 12 testeurs pendant 14 jours avant la mise en production.
