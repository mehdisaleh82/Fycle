# Fycle — périmètre

## Pour qui

Première utilisatrice : elle a testé plusieurs applis de suivi de cycle, les a trouvées bien faites, et les a abandonnées parce qu'elles étaient payantes. Elle n'a jamais payé pour une appli. Elle utilise un iPhone.

Conséquence : aucun abonnement. Fycle se paie une seule fois, au téléchargement, et doit faire aussi bien que ce qu'elle a testé.

Point à surveiller : un paiement unique reste un paiement. À vérifier auprès d'autres utilisatrices une fois la base de l'appli disponible.

## Promesse

- Un seul paiement, à l'achat. Pas d'abonnement, pas d'achat intégré.
- Sans publicité, sans compte.
- Rien ne quitte le téléphone.

## V1 — tout est inclus dans le prix

1. Démarrage sans compte : date des dernières règles, durée habituelle du cycle si elle est connue, rien d'autre.
2. Saisie du jour en deux gestes : règles (début, fin, intensité), symptômes, humeur, note libre.
3. Calendrier mensuel : règles passées et règles prévues.
4. Prédiction des prochaines règles, affichée comme une fourchette de dates, recalculée à chaque saisie.
5. Rappels locaux : règles qui approchent, rappel de saisie facultatif.
6. Historique et statistiques simples : durée moyenne du cycle et des règles, liste des cycles.
7. Verrouillage de l'appli par Face ID ou par code.
8. Export et import d'un fichier chiffré, plus un export lisible (CSV ou PDF).
9. Anglais et français, mode sombre, accessibilité (tailles de texte, VoiceOver).

## V1.x — ajouts inclus dans le prix

À confirmer avec les premières utilisatrices. Candidats :

- tendances détaillées et graphiques ;
- rapport PDF mis en forme pour le médecin ;
- symptômes personnalisés ;
- thèmes et icônes.

## V2 — après avis réglementaire

- estimation de l'ovulation et de la fenêtre de fertilité ;
- mode grossesse ;
- suivi de la périménopause ;
- partage avec le partenaire (suppose un relais chiffré de bout en bout) ;
- synchronisation avec Apple Santé.

## Hors périmètre

- assistant IA, communauté, contenus quotidiens ;
- toute fonction présentée comme une contraception ou un diagnostic.

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
2. Stockage local chiffré, export et import.
3. Interface : démarrage, saisie, calendrier, prédiction.
4. Rappels et verrouillage.
5. Première version TestFlight pour la première utilisatrice.
6. Boucle de retours hebdomadaire, puis mise en vente sur l'App Store, puis Android.

## Critères d'acceptation de la V1

- Tout fonctionne en mode avion.
- L'appli n'émet aucune requête réseau (vérifié par test et par observation du trafic).
- Saisir une journée prend moins de dix secondes.
- La première utilisatrice s'en sert seule, sans explication.
