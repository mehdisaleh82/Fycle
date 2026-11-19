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

## Questions ouvertes

- **Paquets Flutter** proposés, à relire (code et permissions) puis à ajouter à la liste blanche au jalon 4 : `flutter_local_notifications` avec `timezone`, `local_auth`.
- **Démarrage sans date** : la date des dernières règles est obligatoire au premier lancement (décision 34). À revoir si des utilisatrices ne s'en souviennent pas : il faudrait alors mémoriser que le démarrage a été passé.
- **SDK Android** à installer sur le poste de développement (décision 45).
- **Exclusion iCloud** : code natif à écrire au jalon 5 (décision 43).
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
