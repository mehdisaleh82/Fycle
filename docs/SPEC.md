# Fycle — périmètre

## Pour qui

Première utilisatrice : elle a testé plusieurs applis de suivi de cycle, les a trouvées bien faites, et les a abandonnées parce qu'elles étaient payantes. Elle n'a jamais payé pour une appli. Elle utilise un iPhone.

Conséquence : le cœur de l'appli est gratuit et complet. Fycle doit faire aussi bien que ce qu'elle a testé, sans abonnement.

## Promesse

- Gratuit, sans publicité, sans compte.
- Rien ne quitte le téléphone.
- Un achat unique, facultatif et à vie, pour les fonctions avancées.

## Objectifs

Ce qui doit distinguer Fycle, par ordre de priorité :

1. **Confiance.** Les données sont stockées sur le téléphone, chiffrées, et l'éditeur n'y a techniquement aucun accès. Elles se suppriment intégralement en un geste.
2. **Respect du portefeuille.** Aucun abonnement. Le suivi quotidien ne se retrouve jamais bloqué derrière un paiement.
3. **Simplicité.** Ouverture immédiate, saisie en deux gestes, calendrier lisible. Pas de contenus, de forums ni de coaching.
4. **Utilité médicale sans allégation.** Un bilan clair à montrer à un médecin. Fycle reste un journal d'observation personnelle, pas un outil de diagnostic.
5. **Changement facile.** Reprendre un historique existant, pour ne pas repartir de zéro.

## Ce que Fycle ne fait jamais

- Publicité, revente ou partage de données.
- Essai gratuit qui se transforme en prélèvement.
- Fenêtres promotionnelles répétées ou qui interrompent la saisie.
- Notifications anxiogènes ou culpabilisantes.
- Données de l'utilisatrice rendues inaccessibles faute de paiement.

## V1 — socle gratuit

1. Démarrage sans compte : date des dernières règles, durée habituelle du cycle si elle est connue, rien d'autre.
2. Saisie du jour en deux gestes : règles (début, fin, intensité), symptômes, douleur, humeur, note libre.
3. Calendrier mensuel : règles passées et règles prévues.
4. Prédiction des prochaines règles, affichée comme une fourchette de dates, recalculée à chaque saisie.
5. Rappels locaux : règles qui approchent, rappel de saisie facultatif.
6. Historique et statistiques simples : durée moyenne du cycle et des règles, liste des cycles.
7. Verrouillage de l'appli par Face ID ou par code.
8. Export et import d'un fichier chiffré, plus un export lisible (CSV). L'utilisatrice range ce fichier où elle veut.
9. Suppression intégrale des données en un geste, avec confirmation.
10. Avertissement visible : outil d'information, ni avis médical ni méthode de contraception.
11. Anglais et français, mode sombre, accessibilité (tailles de texte, VoiceOver).

## V1.x — pack Pro à vie (achat unique)

Proposé après un ou deux cycles d'utilisation, jamais à l'installation. Contenu à confirmer avec les premières utilisatrices. Candidats :

- bilan PDF sur 3 ou 6 mois, mis en forme pour le médecin (durée des cycles, intensité des douleurs, symptômes récurrents) ;
- statistiques avancées, tendances et graphiques, rapprochements entre symptômes et moments du cycle ;
- symptômes personnalisés ;
- thèmes et icône d'appli discrète.

Reste gratuit quoi qu'il arrive : l'export de ses propres données (règle 6), la suppression, et l'import d'un historique venu d'une autre appli, parce qu'il conditionne l'adoption.

## V2 — après avis réglementaire

- estimation de l'ovulation et de la fenêtre de fertilité ;
- mode grossesse ;
- suivi de la périménopause ;
- partage avec le partenaire (suppose un relais chiffré de bout en bout) ;
- synchronisation avec Apple Santé.

## Hors périmètre

- assistant IA, communauté, contenus quotidiens ;
- toute fonction présentée comme une contraception ou un diagnostic ;
- sauvegarde automatique dans un cloud, même celui de l'utilisatrice : elle contredit « rien ne quitte le téléphone ». Le fichier d'export chiffré en tient lieu.

## Moteur de prédiction (V1)

- Entrée : les dates de début de règles passées.
- Sortie : une fourchette de dates pour les prochaines règles, et un niveau de confiance.
- Méthode de départ : moyenne pondérée des derniers cycles, fourchette élargie quand les cycles sont irréguliers ou peu nombreux.
- Jamais de date unique présentée comme certaine.
- Cas à couvrir par les tests :
  - aucun historique ;
  - un seul cycle ;
  - cycles réguliers ;
  - cycles irréguliers ;
  - cycle oublié (trou dans les données) ;
  - cycle très long ou très court.

## Jalons

0. Squelette du projet, garde-fous automatiques (dépendances, réseau), intégration continue.
1. Moteur de prédiction en Dart pur, avec ses tests.
2. Stockage local chiffré, export, import et suppression.
3. Interface : démarrage, saisie, calendrier, prédiction.
4. Rappels et verrouillage.
5. Première version TestFlight pour la première utilisatrice.
6. Boucle de retours hebdomadaire, puis pack Pro, puis Android.

## Critères d'acceptation de la V1

- Tout fonctionne en mode avion.
- L'appli n'émet aucune requête réseau (vérifié par test et par observation du trafic).
- L'appli s'ouvre sans attente perceptible.
- Saisir une journée prend moins de dix secondes.
- La première utilisatrice s'en sert seule, sans explication.
