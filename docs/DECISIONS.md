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

## Questions ouvertes

- **Paquets Flutter** proposés, versions relevées le 19 novembre 2026, à relire (code et permissions) puis à ajouter à la liste blanche au jalon concerné :
  - jalon 2 : `drift` et `sqlite3` en variante chiffrée, `flutter_secure_storage`, `share_plus`, `file_picker`, `path_provider` ;
  - jalon 4 : `flutter_local_notifications` avec `timezone`, `local_auth`.
- **Chiffrement de la base** : `sqlcipher_flutter_libs` est en fin de vie depuis février 2026. Le chiffrement passe par `sqlite3` ; réglage exact à vérifier au jalon 2. Ce paquet télécharge une bibliothèque précompilée à la compilation : à examiner au regard de la règle 4.
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
