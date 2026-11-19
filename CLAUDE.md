# Fycle — règles du projet

Fycle est une appli de suivi du cycle menstruel pour iPhone et Android (web plus tard).
Promesse : gratuite et sans pub, aucun compte, aucune donnée hors du téléphone, achat unique facultatif.

Avant toute tâche, lire `docs/SPEC.md` (périmètre et jalons) et `docs/DECISIONS.md` (choix et questions ouvertes).

## Règles non négociables

1. Les données de l'utilisatrice restent sur l'appareil. Aucun envoi réseau de données de santé, jamais.
2. Aucun compte, aucun serveur applicatif.
3. Aucun SDK tiers d'analyse, de publicité, de suivi ou de rapport de plantage distant.
4. Toute nouvelle dépendance est proposée et justifiée avant d'être ajoutée. Elle ne doit émettre aucun appel réseau depuis l’appli. Un téléchargement pendant la compilation est admis s’il est vérifié par empreinte et consigné dans `docs/DECISIONS.md`. Seule exception : le paquet d'achat intégré, qui passe par le store du système.
5. La base locale est chiffrée. La clé est stockée dans le trousseau sécurisé du système (Keychain, Keystore), jamais dans le code ni dans la base.
6. L'export de ses propres données par l'utilisatrice est toujours gratuit.
7. Aucune allégation médicale : pas de contraception, pas de diagnostic, pas de « jours sans risque ». Une prédiction est une estimation, affichée avec une fourchette.
8. Ne jamais citer une marque concurrente, ni dans l'appli, ni dans les fiches de store, ni dans le code.

## Données de test

- Uniquement des données fictives, générées par les tests ou rangées dans `test/fixtures/`.
- Aucune donnée réelle d'utilisatrice dans le dépôt, les captures d'écran ou les conversations.

## Stack

- Flutter / Dart, un seul code pour iOS et Android.
- Développement sous Windows. Android se compile en local. iOS se compile dans le cloud (pas de Mac) et se distribue par TestFlight.
- Première plateforme livrée : iPhone.

## Commandes

- `flutter pub get` : installer les dépendances
- `dart format .` : formater le code
- `flutter analyze` : analyse statique, zéro avertissement toléré
- `flutter test` : tests unitaires et tests de widgets

## Conventions

- Code, identifiants et commentaires en anglais.
- Textes de l'interface en anglais et en français, dans des fichiers de localisation, jamais en dur dans le code.
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
