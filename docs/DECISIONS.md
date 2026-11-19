# Fycle — décisions

À mettre à jour à chaque changement. Une décision, sa raison, sa date.

## Décisions prises (18 novembre 2026)

1. **Nom : Fycle.** Se prononce comme « cycle ». Le F est un clin d'œil, sans sens officiel : ne pas présenter le nom comme « Free + cycle », puisque l'appli est payante.
   Titre en store : « Fycle: Period Tracker ».
   Signature : « Monthly cycle. No monthly fee. » (19 novembre 2026, remplace « Fycle. Rhymes with cycle. »)

2. **Plateformes : iPhone d'abord, Android ensuite, web plus tard.**
   Raison : la première utilisatrice a un iPhone, et l'objectif est une vraie appli de store.

3. **Stack : Flutter / Dart.**
   Raison : rendu natif, un seul code pour les deux mobiles, compilable dans le cloud pour iOS.

4. **Données : local uniquement.** Base chiffrée, pas de compte, pas de serveur.
   Raison : c'est la promesse centrale, et cela supprime tout coût récurrent.

5. **Modèle économique : appli payante au téléchargement, un seul paiement** (19 novembre 2026, remplace « socle gratuit et achat unique facultatif »).
   Pas d'abonnement, pas de publicité, pas d'achat intégré : tout est inclus dans le prix.
   Raison : la première utilisatrice a abandonné les autres applis à cause de l'abonnement.
   Risque connu : elle n'a jamais payé pour une appli, et une appli payante est moins téléchargée qu'une gratuite.
   Conséquence technique : aucun module d'achat intégré en V1, donc aucune bibliothèque réseau nulle part dans le code.
   Objectif de revenu : 400 € par mois.

6. **Build : développement sous Windows, pas de Mac.**
   iOS est compilé et signé par un service de build cloud, puis distribué par TestFlight.

7. **Positionnement : frontal sur la confidentialité et l'absence d'abonnement.**
   Lignes : « Pay once. No account. No cloud. » et « No leaks. Of any kind. »
   Ne jamais citer de concurrent.

8. **Réglementaire : aucune allégation médicale.**
   Contraception exclue. Avis d'un spécialiste avant toute fonction de fertilité ou de grossesse.

9. **Langues : anglais et français dès la V1.**

## Questions ouvertes

- **Paquets Flutter** à retenir pour : base chiffrée, trousseau sécurisé, notifications locales, biométrie. À proposer en session de plan, en vérifiant qu'ils sont maintenus et qu'ils n'émettent aucun appel réseau.
- **Android** : sans achat intégré, l'appli peut se passer de la permission INTERNET. À confirmer au jalon Android.
- **Prix** : hypothèse de travail à 9,99 €, soit environ 57 ventes par mois pour l'objectif de revenu. À valider.
- **Validation du modèle** auprès d'autres utilisatrices : à faire une fois la base de l'appli disponible (décidé le 19 novembre 2026).
- **Réservation du nom** : fiches à créer dans App Store Connect et dans la Play Console.
- **Import de l'historique** depuis Apple Santé.
- **Marque** : dépôt INPI et vérification EUIPO à faire. Noms de domaine à réserver.
- **Google Play** : un compte personnel impose un test fermé de 12 testeurs pendant 14 jours avant la mise en production.
