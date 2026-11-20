# Fycle — périmètre

## Pour qui

Première utilisatrice : elle a testé plusieurs applis de suivi de cycle, les a trouvées bien faites, et les a abandonnées parce qu'elles étaient payantes. Elle n'a jamais payé pour une appli. Elle utilise un iPhone.

Conséquence : le cœur de l'appli est gratuit et complet. Fycle doit faire aussi bien que ce qu'elle a testé, sans abonnement.

## Promesse

- Gratuit, sans publicité, sans compte.
- Rien ne quitte le téléphone.
- Un achat unique, facultatif et à vie, pour les fonctions avancées. Jamais d'abonnement.

## Positionnement

Fycle vise la place que personne n'occupe : la confidentialité **et** la finition. Les applis qui protègent vraiment les données sont austères et peu mises à jour ; les applis soignées demandent un abonnement et un compte. Marché international dès le départ. Projet mené à côté d'un travail principal.

## État au 19 novembre 2026

La V1 tourne sur iPhone en essai privé (TestFlight) : saisie, calendrier, prédiction en fourchette avec niveau de confiance, rappels, verrouillage, stockage chiffré, export et import. Elle n'est pas publiée : la première version publique sera la V2.

De la V2, quatre jalons du sprint 1 sont faits :

- **Jalon A** : la nouvelle charte (bleu nuit et ambre), le réglage d'apparence (clair, sombre, comme le téléphone) et la mise en page miroir. C'est ce que contient la compilation TestFlight n° 4.
- **Jalon B** : démarrage en moins d'une minute (raccourcis « Aujourd'hui » et « Hier », estimation affichée dès la date choisie, « Je ne sais plus »), règles du jour en un appui depuis l'accueil avec retour tactile, série de saisie discrète. Codé et testé sous Windows, pas encore dans une compilation TestFlight.
- **Jalon C** : sommeil et libido dans la saisie du jour, écran « Tendances » (durées moyennes, ce qui revient au même moment du cycle, historique des cycles), bilan sobre à la fin de chaque cycle. Codé et testé sous Windows.
- **Jalon E** : estimation de l'ovulation et de la fenêtre de fertilité, en fourchettes, désactivée par défaut et précédée d'un avertissement. Codé et testé sous Windows ; ses textes médicaux restent à relire par un professionnel de santé.

Aucune autre fonction de la V2 n'est encore écrite. Une refonte de l'accueil et de la navigation a suivi le premier essai de la testeuse (décisions 103 à 112) : quatre onglets nommés (Accueil, Journal, Bilan, Réglages), un accueil centré sur les chiffres clés avec un anneau du cycle, un cycle de repère que les saisies ajustent, les étapes que les saisies débloquent, un journal en pages, un compte rendu du cycle lisible à tout moment. L'estimation de l'ovulation et les rappels sont actifs dès le début.

S'y ajoute un regard clinique (décisions 113 à 119) : une fiche clinique fondée sur le référentiel FIGO, un résultat d'étude publié chaque jour à côté du chiffre de l'utilisatrice, un cycle de repère ajusté sur l'année de naissance, et un rapport pour le médecin à un appui de l'accueil.

Après le retour de la testeuse, l'appli a été épurée (décisions 120 à 126) : démarrage en une question, accueil réduit à l'anneau et au journal du jour, tout le reste dans le Bilan, et plus aucune mention d'étude ou de référence à l'écran. Les calculs fondés sur les études tournent toujours.

Puis l'anneau est devenu le centre de l'appli (décisions 134 à 136) : il se parcourt au doigt, jour par jour ; l'accueil tient en deux cartes et le bilan en trois, le reste à un appui ; le moteur distingue la moyenne publiée pour son âge de la durée qu'elle déclare, et estime la fin des règles en cours à partir de ses règles passées.

Le premier lancement est devenu un parcours d'une dizaine d'écrans (décision 141) : prénom, année de naissance, objectifs, régularité, durées, dernières règles, rappels, verrouillage. Les réponses règlent la première estimation et ce que l'appli affiche. Étape suivante : le suivi de la périménopause.

Suite prévue (décision 89) : migraines (D), puis F à L.

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

## V2 — première version publique

Décidé le 19 novembre 2026 (décisions 63 à 78). Remplace l'ancien « pack Pro » de la V1.x.

### Gratuit, pour toujours

Saisie, calendrier, prédiction de base des règles, rappels, verrouillage, export et import, export chiffré manuel vers l'espace de fichiers de l'utilisatrice, suppression. Une utilisatrice gratuite ne perd jamais ses données.

### Achat unique à vie (14,99 €)

Tout est débloqué pendant les trois premiers cycles, sans moyen de paiement. Ensuite : achat unique, ou retour au socle gratuit. La saisie et l'export ne sont jamais bloqués.

1. **Ovulation et fenêtre de fertilité** : estimation en Dart pur sur les données saisies, affichée avec une fourchette, jamais comme une méthode de contraception.
2. **Mode grossesse.**
3. **Suivi de la périménopause.**
4. **Journal de symptômes avec tendances** par phase du cycle : douleurs, humeur, sommeil, libido.
5. **Suivi des migraines** : intensité, durée, médicament pris, rapproché de la phase du cycle. Intégré au journal.
6. **Rapport de consultation en PDF** : un à trois cycles (dates, durées, symptômes, migraines, irrégularités), produit sur le téléphone, à apporter chez le médecin.
7. **Widgets** d'écran d'accueil (jour du cycle, prochaine estimation) sur iOS et Android, et complication de montre.
8. **Sauvegarde automatique** chiffrée vers l'espace de fichiers de l'utilisatrice, sous son contrôle, sans serveur.
9. **Partage avec le partenaire**, sans serveur de Fycle qui puisse lire quoi que ce soit. Fonction phare du premium. Seul chantier qui demande une conception avant le code (sprint 2).

### Pour toutes (gratuit ou premium : à trancher fonction par fonction dans le plan du sprint 1)

- **Données de santé du téléphone** (Apple Santé, Health Connect), lues sur l'appareil, sans réseau : quand le système fournit déjà une estimation (ovulation rétrospective par la température du poignet, fréquence cardiaque au repos, sommeil, variabilité cardiaque), Fycle l'affiche au lieu de la recalculer.
- **Signaux à montrer à un médecin** : règles cliniques publiées, pas un modèle entraîné. Cycles trop longs ou trop courts, irrégularité, saignements inhabituels, avec le message « parlez-en à un médecin ». Aucun diagnostic.
- **Rappel de contraception** : prise de pilule, changement d'anneau ou de stérilet. Un rappel, aucun conseil.
- **Démarrage en moins d'une minute** : date des dernières règles et durée habituelle du cycle, jamais un historique complet. Une estimation s'affiche aussitôt.
- **Mode discret** : notifications neutres (déjà en place), nom et icône neutres sur l'écran d'accueil.
- **Habitude, sans ludification** (règle 13) : série de saisie discrète, saisie en un geste avec retour tactile, bilan de fin de cycle comparé aux cycles précédents, prédiction qui s'affine visiblement.
- **Pourboire facultatif** « soutenir Fycle » (1,99 € ou 2,99 €) dans les réglages : ne débloque rien.
- **Langues** : anglais et français, puis espagnol et allemand ; architecture prête pour une trentaine de langues, dont l'arabe, le chinois, le japonais et le vietnamien (règle 11).

### Apparence

Charte du 19 novembre 2026 (décision 77) : bleu nuit en base, ambre doré en accent unique, blanc cassé et gris anthracite en neutres, bordeaux discret pour les jours de règles. Mode clair par défaut, mode sombre au choix dans les réglages, tailles de texte du système, mise en page miroir. Icône : un F dont la barre forme un arc ouvert, monochrome, sans rien qui évoque les règles.

## V3 — plus tard

- Petit modèle embarqué (quelques centaines de ko), entraîné hors ligne sur des données publiques puis affiné sur le téléphone, pour croiser symptômes, sommeil, température et migraines. Zéro réseau. N'a de sens qu'une fois le journal de symptômes rempli. Vendu comme un nouvel achat unique facultatif ; les clientes gardent tout ce qu'elles ont.
- Pistes : syndrome prémenstruel et sa forme sévère, post-partum, journal de préparation de consultation pour l'endométriose ou le SOPK, poids, température, tests d'ovulation.

## Hors périmètre

- assistant IA, communauté, contenus quotidiens ;
- toute fonction présentée comme une contraception ou un diagnostic ;
- abonnement, sous quelque forme que ce soit ;
- points, badges, confettis, récompenses ;
- apprentissage fédéré : il suppose un serveur d'agrégation. À revoir plus tard.

## Moteur de prédiction

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

En V2, deux niveaux : sans montre, la prédiction statistique de Fycle ; avec une montre, les estimations fournies par le système. Les réglages de départ du modèle sont calés hors ligne sur des données publiques (jeux de données de recherche, statistiques publiées sur la longueur des cycles et de la phase lutéale selon l'âge), puis embarqués dans l'appli : aucune donnée d'utilisatrice ne sert à cela et rien ne sort du téléphone. Objectif réaliste : le niveau des applis établies pour les règles, la même zone d'incertitude qu'elles pour l'ovulation.

## Jalons

0. Squelette du projet, garde-fous automatiques (dépendances, réseau), intégration continue.
1. Moteur de prédiction en Dart pur, avec ses tests.
2. Stockage local chiffré, export, import et suppression.
3. Interface : démarrage, saisie, calendrier, prédiction.
4. Rappels et verrouillage.
5. Première version TestFlight pour la première utilisatrice.
6. V2, en deux sprints (décision 78) :
   - sprint 1 : toute la V2 hors partage partenaire, en TestFlight ; jalons détaillés dans le plan du sprint, à valider ;
   - sprint 2 : partage partenaire, conception d'abord ;
   - test fermé d'une dizaine de testeuses pendant un à deux mois, profils variés ;
   - publication sur l'App Store, puis sur Google Play.

## Critères d'acceptation

- Tout fonctionne en mode avion.
- L'appli n'émet aucune requête réseau (vérifié par test et par observation du trafic).
- L'appli s'ouvre sans attente perceptible.
- Saisir une journée prend moins de dix secondes.
- La première utilisatrice s'en sert seule, sans explication.

Ajoutés pour la V2 :

- Une estimation s'affiche moins d'une minute après la première ouverture.
- Chaque écran soutient la comparaison avec les meilleures applis du domaine (règle 12).
- Chaque écran tient en écriture de droite à gauche et en grand texte.
- Chaque fonction existe sur iOS et sur Android avant publication (règle 10).
- Les textes médicaux ont été relus par un professionnel de santé.
