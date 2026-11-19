# Fycle sur iPhone par TestFlight — marche à suivre

Les libellés des sites d'Apple et de GitHub changent parfois un peu. En cas de doute, s'arrêter et demander.

**Règle d'or : la clé d'accès (fichier `.p8`) et les identifiants ne se collent que dans les secrets de GitHub. Jamais dans une conversation, un e-mail ou le dépôt.**

## A. Enregistrer l'identifiant de l'appli

1. Ouvrir <https://developer.apple.com/account>, puis « Certificats, identifiants et profils » → « Identifiants ».
2. Bouton « + » → « App IDs » → « App ».
3. Description : `Fycle`. Bundle ID : « Explicit », valeur `app.fycle`.
4. Ne cocher aucune capacité. « Continue », puis « Register ».

Si Apple répond que l'identifiant est déjà pris, s'arrêter : il faudra en choisir un autre avant d'aller plus loin.

## B. Créer la fiche de l'appli (elle reste privée)

1. Ouvrir <https://appstoreconnect.apple.com> → « Apps » → « + » → « Nouvelle app ».
2. Plateforme : iOS. Nom : `Fycle` (s'il est refusé : `Fycle: Period Tracker`).
3. Langue principale : Anglais (États-Unis). Identifiant de lot : `app.fycle`. SKU : `fycle-ios`. Accès utilisateur : complet.

## C. Créer la clé d'accès

1. App Store Connect → « Utilisateurs et accès » → onglet « Intégrations » → « API App Store Connect » → « Clés d'équipe ».
2. Générer une clé. Nom : `GitHub Actions`. Accès : `Admin`.
3. Noter, sans les partager : l'« Issuer ID » (en haut de la page) et l'« identifiant de clé ».
4. Télécharger le fichier `.p8`. **Apple ne le propose qu'une seule fois.**
5. Relever le « Team ID » : <https://developer.apple.com/account>, rubrique « Détails de l'adhésion ».

## D. Ranger les quatre secrets dans GitHub

Dépôt Fycle sur GitHub → « Settings » → « Secrets and variables » → « Actions » → « New repository secret », quatre fois :

| Nom du secret | Valeur |
|---|---|
| `ASC_KEY_ID` | l'identifiant de clé |
| `ASC_ISSUER_ID` | l'Issuer ID |
| `ASC_KEY_P8` | tout le contenu du fichier `.p8`, ouvert avec le Bloc-notes, lignes `BEGIN` et `END` comprises |
| `APPLE_TEAM_ID` | le Team ID |

Ensuite, ranger le fichier `.p8` en lieu sûr hors du dossier du projet, ou le supprimer.

## E. Compiler et installer

1. GitHub → onglet « Actions » → « iOS TestFlight » → « Run workflow » → « Run workflow ». Compter 15 à 25 minutes.
2. Coche verte : la compilation est partie chez Apple. Croix rouge : copier le message d'erreur (sans aucun secret) et le transmettre.
3. App Store Connect → l'appli Fycle → onglet « TestFlight ». La compilation apparaît après quelques minutes de traitement.
4. Si Apple pose une question sur le chiffrement (« conformité manquante ») : **s'arrêter et transmettre la question avant de répondre** (décision 59).
5. « Tests internes » → créer un groupe → s'y ajouter comme testeur.
6. Sur l'iPhone : installer l'appli « TestFlight » d'Apple, s'y connecter avec le même compte Apple, installer Fycle.

Pour une nouvelle version : refaire seulement l'étape E.1.

## F. À vérifier sur l'iPhone

Uniquement avec des données inventées. Noter « oui », « non » ou une remarque pour chaque ligne.

### Données et confidentialité
- [ ] En mode avion, tout fonctionne : démarrage, saisie, calendrier, réglages.
- [ ] L'appli s'ouvre sans attente perceptible ; saisir une journée prend moins de dix secondes.
- [ ] Après un redémarrage du téléphone, les données sont toujours là.
- [ ] « Tout supprimer » ramène à l'écran de démarrage ; après fermeture et réouverture, rien n'est revenu.
- [ ] Réglages de l'iPhone → votre nom → iCloud → Sauvegarde iCloud → cet iPhone : la taille indiquée pour Fycle reste minime après plusieurs saisies.

### Export et import
- [ ] Export chiffré : la fenêtre « Fichiers » s'ouvre, le fichier `.fycle` s'enregistre où vous voulez.
- [ ] Durée de l'attente pendant l'export, en secondes : ____ (l'écran ne doit pas se figer).
- [ ] Import de ce fichier avec le bon mot de passe : les données reviennent. Avec un mauvais : rien ne change.
- [ ] Export CSV : le fichier s'ouvre dans « Fichiers ».
- [ ] Verrou actif : choisir un fichier ne redemande pas Face ID au retour.

### Rappels
- [ ] Activer un rappel affiche la fenêtre d'autorisation d'iOS, une seule fois.
- [ ] En cas de refus, l'interrupteur reste éteint et un message explique où autoriser.
- [ ] Rappel de saisie réglé quelques minutes plus tard : il arrive à la bonne heure, appli fermée.
- [ ] Même essai, appli ouverte : la notification s'affiche aussi.
- [ ] Le texte ne mentionne ni règles, ni cycle, ni santé.
- [ ] Un jour déjà saisi ne reçoit pas de rappel de saisie.

### Verrouillage
- [ ] Activer le verrou demande Face ID. La phrase d'explication est en français (téléphone en français).
- [ ] À l'ouverture et à chaque retour dans l'appli, Face ID est demandé.
- [ ] Après un échec de Face ID, le code du téléphone est proposé.
- [ ] Dans le sélecteur d'applis, l'aperçu de Fycle est masqué.
- [ ] Faire descendre le centre de notifications puis le remonter ne verrouille pas.

### Confort et accessibilité
- [ ] Mode sombre : tout reste lisible.
- [ ] Texte au maximum (Réglages → Accessibilité → Affichage et taille du texte → Police plus grande) : rien n'est coupé, tout défile.
- [ ] VoiceOver : chaque bouton et chaque jour du calendrier est annoncé clairement.
- [ ] Téléphone en anglais : l'appli passe en anglais.
