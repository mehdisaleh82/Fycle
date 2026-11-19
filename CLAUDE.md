# Fycle — règles du projet

Fycle est une appli de suivi du cycle menstruel pour iPhone et Android (web plus tard).
Promesse : gratuite et sans pub, aucun compte, aucune donnée hors du téléphone, achat unique facultatif, jamais d'abonnement.

Avant toute tâche, lire `docs/SPEC.md` (périmètre et jalons) et `docs/DECISIONS.md` (choix et questions ouvertes).

## Règles non négociables

1. Les données de l'utilisatrice restent sur l'appareil. Aucun envoi réseau de données de santé, jamais. Seule sortie admise : un fichier chiffré que l'utilisatrice range elle-même, ou fait ranger automatiquement, dans son propre espace de fichiers (Fichiers, iCloud Drive, équivalent Android). L'appli n'émet aucun appel réseau pour cela.
2. Aucun compte, aucun serveur applicatif.
3. Aucun SDK tiers d'analyse, de publicité, de suivi ou de rapport de plantage distant.
4. Toute nouvelle dépendance est proposée et justifiée avant d'être ajoutée. Elle ne doit émettre aucun appel réseau depuis l’appli. Un téléchargement pendant la compilation est admis s’il est vérifié par empreinte et consigné dans `docs/DECISIONS.md`. Seule exception : le paquet d'achat intégré, qui passe par le store du système.
5. La base locale est chiffrée. La clé est stockée dans le trousseau sécurisé du système (Keychain, Keystore), jamais dans le code ni dans la base.
6. L'export de ses propres données par l'utilisatrice est toujours gratuit.
7. Aucune allégation médicale : pas de contraception, pas de diagnostic, pas de « jours sans risque ». Une prédiction est une estimation, affichée avec une fourchette. Cela vaut pour l'ovulation, la fertilité, la grossesse et la périménopause. Un rappel de contraception est un simple rappel, sans conseil. Tout texte médical est relu par un professionnel de santé avant publication, jamais seulement généré.
8. Ne jamais citer une marque concurrente, ni dans l'appli, ni dans les fiches de store, ni dans le code.
9. Jamais d'abonnement ni de paiement récurrent. Après l'essai, la saisie, le calendrier, la prédiction de base, les rappels, le verrouillage, l'export et l'import restent gratuits pour toujours.
10. Parité iOS / Android stricte : une fonction n'est publiée sur un store que si elle existe sur les deux plateformes avec le même comportement. Équivalences : Apple Santé / Health Connect, iCloud Drive / stockage de fichiers Android, widgets des deux systèmes, achat intégré de chaque store.
11. Internationalisation complète dès la conception : aucun texte en dur, aucune mise en page qui suppose une langue écrite de gauche à droite. Écritures de droite à gauche (arabe, hébreu) avec mise en page miroir, alphabets non latins, diacritiques, formats de date et chiffres locaux, polices du système.
12. La finition de l'interface est un critère d'acceptation, pas un bonus : chaque écran doit soutenir la comparaison avec les meilleures applis du domaine.
13. Aucune ludification : pas de points, de badges, de confettis, de récompenses ni de notifications culpabilisantes. Les seuls mécanismes d'habitude admis sont sobres (série de saisie discrète, bilan de fin de cycle, prédiction qui s'affine).

## Données de test

- Uniquement des données fictives, générées par les tests ou rangées dans `test/fixtures/`.
- Aucune donnée réelle d'utilisatrice dans le dépôt, les captures d'écran ou les conversations.

## Stack

- Flutter / Dart, un seul code pour iOS et Android.
- Développement sous Windows. Android se compile en local. iOS se compile dans le cloud (pas de Mac) et se distribue par TestFlight.
- Première plateforme livrée en essai privé (TestFlight) : iPhone. La publication sur les stores suit la règle 10.

## Commandes

- `flutter pub get` : installer les dépendances
- `dart format .` : formater le code
- `flutter analyze` : analyse statique, zéro avertissement toléré
- `flutter test` : tests unitaires et tests de widgets

## Conventions

- Code, identifiants et commentaires en anglais.
- Textes de l'interface en anglais et en français, dans des fichiers de localisation, jamais en dur dans le code. L'architecture doit accueillir d'autres langues sans retouche du code (règle 11).
- Mise en page avec les variantes « start / end » plutôt que « left / right », pour le sens d'écriture.
- La logique métier (prédiction, statistiques) est écrite en Dart pur, sans dépendance à l'interface, et couverte par des tests.
- Petits commits, un sujet par commit, message en anglais.

## Méthode de travail

- Planifier avant de coder : proposer le plan, attendre la validation.
- Un jalon par session. Ne pas déborder du jalon en cours.
- Une tâche n'est terminée que si `dart format .`, `flutter analyze` et `flutter test` passent.
- Toute décision d'architecture, nouvelle ou modifiée, est consignée dans `docs/DECISIONS.md`.
- En cas de doute sur une règle de ce fichier, demander plutôt que supposer.

## Garde-fous automatiques à créer puis à maintenir

- Un test échoue si une dépendance absente de la liste blanche apparaît (`tool/allowed_dependencies.txt`).
- Un test échoue si du code de `lib/` utilise une API réseau, sans exception. L'achat intégré passe par le paquet officiel et le store du système, jamais par du code réseau maison.
- Un test échoue si `lib/domain/` importe Flutter.
- Ces tests tournent à chaque `flutter test` et dans l'intégration continue.
