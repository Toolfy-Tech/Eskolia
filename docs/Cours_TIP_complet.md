# COURS TIP

> Technicien d'Intervention de Proximité — Support IT
> Retranscription complète des modules de cours.

## Sommaire

1. [Module 1 : Support utilisateur & gestion de services](#module-1--support-utilisateur--gestion-de-services)
2. [Module 2 : Hardware & architecture des systèmes informatiques](#module-2--hardware--architecture-des-systèmes-informatiques)
3. [Module 3 : Système d'exploitation](#module-3--système-dexploitation)
4. [Module 4 : Réseaux & infrastructure](#module-4--réseaux--infrastructure)
5. [Module 5 : Maintenance, sauvegarde et protection du système](#module-5--maintenance-sauvegarde-et-protection-du-système)
6. [Module 6 : Administration de Windows](#module-6--administration-de-windows)
7. [Module 7 : Cybersécurité](#module-7--cybersécurité)
8. [Module 8 : Utiliser l'IA](#module-8--utiliser-lia)

---

# MODULE 1 : SUPPORT UTILISATEUR & GESTION DE SERVICES

> 🤖 *Module rédigé avec l'assistance d'une IA — à relire et vérifier avant usage.*

Le technicien informatique de proximité est le **point d'entrée** des utilisateurs vers le service informatique. Avant même de toucher au matériel ou au réseau, son métier commence par une demande : un appel, un email, un ticket. Ce module pose le cadre méthodologique de l'assistance — comment une demande est reçue, qualifiée, priorisée, résolue ou escaladée, puis tracée. C'est la colonne vertébrale de tout le reste : les modules techniques suivants sont les outils, celui-ci est la méthode.

## 1. ITIL — Le cadre de gestion des services

**ITIL (Information Technology Infrastructure Library)** est un ensemble de bonnes pratiques pour gérer les services informatiques. Ce n'est pas un logiciel ni une norme obligatoire, mais un **référentiel** adopté par la majorité des entreprises pour organiser le support. La version actuelle est **ITIL 4** (éditée par AXELOS).

L'idée centrale : l'informatique ne « répare pas des machines », elle **rend un service** à des utilisateurs. Tout est donc pensé en termes de valeur rendue, de délais et de qualité.

### 1.1 Les trois types de sollicitations

Une erreur fréquente du débutant est de tout appeler « problème ». ITIL distingue précisément :

| Terme | Définition | Exemple |
|---|---|---|
| **Demande de service** (Service Request) | Requête normale, prévue, sans dysfonctionnement | « J'ai besoin d'un accès au dossier Compta », « installez-moi Teams » |
| **Incident** | Interruption non planifiée ou dégradation d'un service | « Mon PC ne démarre plus », « l'imprimante est hors ligne » |
| **Problème** | La **cause racine** sous-jacente à un ou plusieurs incidents | 12 PC plantent → cause = une mise à jour défectueuse déployée la nuit |

> **À retenir** : un incident, c'est le *symptôme* (« ça ne marche pas »). Le problème, c'est la *maladie* (« pourquoi ça ne marche pas »). On résout un incident pour rétablir le service vite ; on traite un problème pour que ça ne se reproduise plus.

### 1.2 Le centre de services (Service Desk)

Le **centre de services** est le **point de contact unique** (SPOC — *Single Point of Contact*) entre les utilisateurs et l'informatique. Toutes les demandes y transitent, ce qui évite que les utilisateurs appellent directement « leur » technicien préféré et garantit que rien ne se perd.

On distingue souvent des **niveaux de support** :

| Niveau | Rôle | Qui |
|---|---|---|
| **N1** | Réception, qualification, résolution des cas courants (mots de passe, périphériques, questions logicielles) | Technicien de proximity / Helpdesk |
| **N2** | Incidents techniques plus complexes nécessitant une expertise | Techniciens spécialisés, admins |
| **N3** | Expertise pointue, éditeurs, constructeurs | Experts, ingénieurs, support éditeur |

Le technicien informatique de proximité opère majoritairement en **N1**, et escalade vers le N2/N3 ce qui dépasse son périmètre.

## 2. Le cycle de vie d'un ticket

Un **ticket** est l'enregistrement d'une demande ou d'un incident dans un outil dédié. Il suit un parcours standardisé, de l'ouverture à la clôture.

```
1. Détection / Signalement   → l'utilisateur contacte le support
2. Enregistrement            → création du ticket (qui, quoi, quand)
3. Qualification             → demande ou incident ? catégorie ?
4. Priorisation              → urgence × impact
5. Diagnostic                → recueil d'infos, tests
6. Résolution OU Escalade    → on résout, ou on transmet au N2/N3
7. Clôture                   → validation par l'utilisateur, documentation
```

> **Réflexe terrain** : on ne clôt **jamais** un ticket sans confirmation que l'utilisateur peut de nouveau travailler. Un ticket clôturé trop vite rouvre — et fausse les statistiques du service.

### 2.1 Les informations à enregistrer

Un bon ticket contient au minimum : l'identité et le contact de l'utilisateur, la date/heure, une description claire du symptôme (les **mots de l'utilisateur** + la reformulation technique), l'équipement concerné (numéro d'inventaire), la catégorie, la priorité, et l'historique des actions menées.

> **À retenir** : « Le PC marche pas » n'est pas une description. « Au démarrage, écran noir, aucun bip, voyant d'alimentation allumé » en est une. La qualité du ticket conditionne la rapidité de résolution — y compris par un collègue qui reprendrait le dossier.

## 3. Priorisation : urgence × impact

On ne traite pas les tickets dans l'ordre d'arrivée, mais selon leur **priorité**, calculée en croisant deux critères :

- **L'urgence** : à quelle vitesse le problème doit-il être résolu ? (délai avant conséquence)
- **L'impact** : combien de personnes / quelle criticité métier sont touchées ?

| | Impact fort (service entier) | Impact moyen (un service) | Impact faible (1 personne) |
|---|---|---|---|
| **Urgence forte** | 🔴 Critique (P1) | 🟠 Haute (P2) | 🟡 Moyenne (P3) |
| **Urgence moyenne** | 🟠 Haute (P2) | 🟡 Moyenne (P3) | 🟢 Basse (P4) |
| **Urgence faible** | 🟡 Moyenne (P3) | 🟢 Basse (P4) | 🟢 Basse (P4) |

**Exemple** : le serveur de production de toute l'usine est à l'arrêt = impact fort + urgence forte = **P1**, on lâche tout. Une souris à remplacer pour une personne = **P4**, ça attend.

## 4. SLA — Les engagements de service

Le **SLA (Service Level Agreement)**, ou « contrat de niveau de service », est l'accord qui définit **ce que le service informatique s'engage à tenir** : délais de prise en charge et de résolution selon la priorité.

| Priorité | Délai de prise en charge (exemple) | Délai de résolution (exemple) |
|---|---|---|
| P1 — Critique | 15 min | 4 h |
| P2 — Haute | 1 h | 8 h |
| P3 — Moyenne | 4 h | 2 jours |
| P4 — Basse | 1 jour | 5 jours |

Deux indicateurs clés à ne pas confondre :
- **GTI (Garantie de Temps d'Intervention)** : délai max avant que le technicien *prenne en charge* le ticket.
- **GTR (Garantie de Temps de Rétablissement)** : délai max avant que le service soit *rétabli*.

> **Attention — Erreur fréquente** : « prise en charge » ≠ « résolution ». Décrocher le téléphone dans les 15 minutes respecte la GTI, même si la réparation prend 3 heures. Le non-respect d'un SLA peut entraîner des pénalités contractuelles, surtout en ESN (prestation externalisée).

## 5. Outils de ticketing et de gestion de parc

### 5.1 Les outils de ticketing

La gestion des tickets s'appuie sur un logiciel dédié (ITSM — *IT Service Management*). Exemples courants :

| Outil | Particularité |
|---|---|
| **GLPI** | Open source, gratuit, très répandu en PME et collectivités. Gère tickets **ET** inventaire de parc. |
| **GLPI + FusionInventory / OCS** | Ajoute l'inventaire automatique du matériel et des logiciels. |
| **ServiceNow** | Solution entreprise haut de gamme, grands comptes. |
| **Jira Service Management** | Orienté équipes techniques et DevOps. |
| **Zendesk, Freshdesk** | Orientés support client / helpdesk. |

**GLPI** est le fil rouge du métier : il centralise les tickets, la base de connaissances, l'inventaire matériel et logiciel, et la gestion des contrats/licences. C'est souvent le premier outil qu'un technicien apprend en entreprise.

### 5.2 La gestion de parc (inventaire)

Gérer le **parc**, c'est tenir à jour l'inventaire de tout le matériel et tous les logiciels de l'entreprise : qui possède quoi, quelle configuration, quelle date d'achat, quelle fin de garantie, quelle licence.

Utilité concrète :
- Savoir **quand renouveler** un matériel vieillissant (anticipation des pannes).
- Suivre les **licences logicielles** (conformité légale, éviter le sous- ou sur-licenciement).
- Associer chaque ticket à un **équipement identifié** (numéro d'inventaire / numéro de série).
- Produire des statistiques (matériels les plus en panne, coûts).

> **Réflexe terrain** : un parc à jour permet de répondre en 10 secondes à « ce PC a quelle config et il est sous garantie jusqu'à quand ? ». Un parc non tenu, c'est des heures perdues à chaque intervention.

### 5.3 La base de connaissances (Knowledge Base)

La **base de connaissances** regroupe les procédures de résolution des incidents récurrents. Quand un même incident revient, on ne redécouvre pas la solution : on consulte (et on enrichit) la base.

Bonne pratique : après avoir résolu un incident nouveau ou complexe, **rédiger une fiche** (symptôme → cause → solution étape par étape). Le service entier gagne en rapidité, et les cas courants deviennent traitables par n'importe quel membre de l'équipe.

## 6. Diagnostic, résolution et escalade

### 6.1 Les phases d'une intervention d'assistance

Une intervention suit toujours le même fil, qu'elle soit sur site ou à distance :

1. **Accueil et écoute** : recueillir la demande, mettre l'utilisateur en confiance.
2. **Questionnement et reformulation** : poser des questions précises, reformuler pour vérifier la compréhension mutuelle.
3. **Qualification** : demande ou incident ? catégorie, priorité.
4. **Diagnostic** : tests, hypothèses, recherche dans la base de connaissances.
5. **Résolution** (si dans son périmètre) **ou escalade**.
6. **Vérification** : s'assurer avec l'utilisateur que tout fonctionne.
7. **Traçabilité** : mettre à jour le ticket, documenter, clôturer.

### 6.2 La prise en main à distance

Une grande partie du support se fait **à distance**, via des outils de prise de contrôle (TeamViewer, AnyDesk, le Bureau à distance Windows / RDP, Quick Assist...).

> **Règle de déontologie** : ne **jamais** prendre la main sur un poste sans l'**accord explicite** de l'utilisateur, et l'informer de ce qu'on fait en temps réel. Formuler des consignes claires (« cliquez sur le bouton en bas à gauche ») et confirmer chaque étape. La prise à distance ne dispense pas de la pédagogie.

### 6.3 L'escalade

Quand un incident **dépasse son périmètre de compétence ou ses droits**, le technicien ne s'acharne pas : il **escalade** vers l'équipe dédiée (N2/N3, éditeur, constructeur).

Une escalade réussie suppose un **rapport de transmission** clair : ce qui a été constaté, les tests déjà réalisés, les hypothèses écartées, l'urgence et l'impact. L'objectif est que l'équipe suivante ne reparte pas de zéro.

> **À retenir** : savoir escalader **n'est pas** un échec, c'est une compétence. S'acharner au-delà de ses droits (ex. : modifier un serveur de production) peut aggraver la situation. Le bon réflexe : résoudre ce qui est dans son périmètre, transmettre proprement le reste.

### 6.4 La fiche d'intervention / compte rendu

Après une intervention (surtout sur site), le technicien **rend compte** via une fiche d'intervention : date, durée, équipement, actions menées, pièces remplacées, résultat. Elle sert de preuve de service rendu, alimente l'historique du parc, et peut être contractuelle en ESN.

## 7. Communiquer avec l'utilisateur

La communication est une **compétence transversale** du référentiel, mobilisée dans chaque intervention. Le technicien adapte en permanence son langage au profil de son interlocuteur.

### 7.1 Adapter son vocabulaire

| À éviter (jargon) | À privilégier (langage adapté) |
|---|---|
| « Votre DNS ne résout pas » | « Votre ordinateur n'arrive pas à retrouver le site, on va vérifier un réglage » |
| « Faites un hard reset » | « On va éteindre complètement puis rallumer » |
| « Il faut purger le cache » | « On va vider les fichiers temporaires qui encombrent » |

> **Règle** : l'utilisateur n'a pas à comprendre la technique. C'est au technicien d'adapter ses mots, son élocution et son débit — pas l'inverse. On vérifie régulièrement la compréhension (« est-ce que c'est clair jusqu'ici ? »).

### 7.2 Patience et pédagogie

Faire preuve de patience, ne jamais culpabiliser l'utilisateur (« vous avez encore cliqué sur ce lien ? »), créer un climat de confiance. Un utilisateur en confiance signale plus vite ses erreurs — ce qui accélère le diagnostic et réduit les risques (notamment en sécurité).

### 7.3 Prise en compte du handicap

Le technicien adapte sa communication et l'environnement de travail aux **situations de handicap** : ralentir et articuler pour une personne malentendante, décrire à voix haute pour une personne malvoyante, simplifier pour un trouble cognitif, etc. Les **outils d'accessibilité** du système (loupe, narrateur, contraste élevé, sous-titres) sont détaillés dans le module Système d'exploitation ; ici, l'essentiel est l'**attitude** : s'adapter à la personne, sans la presser ni la mettre en difficulté.

### 7.4 Les canaux de communication

Le support s'exerce par téléphone, email, chat, outil de ticketing, visioconférence ou en présentiel. Chaque canal a ses contraintes : au téléphone, tout passe par la voix (pas de visuel partagé) ; par email, l'écrit doit être autosuffisant ; en présentiel, le langage non verbal compte. Le technicien adapte sa communication au canal **et** à la situation.

## 7 (bis). Le paysage logiciel de l'utilisateur

> 🤖 *Section ajoutée avec l'assistance d'une IA — à relire et vérifier avant usage.*

Assister un utilisateur suppose de connaître les **familles de logiciels** qu'il utilise. Le technicien n'a pas à tous les maîtriser en expert, mais il doit savoir les identifier, les installer/configurer et orienter le diagnostic.

| Famille | Exemples | Rôle |
|---|---|---|
| **Suites bureautiques** | Microsoft Office (Word, Excel, PowerPoint), LibreOffice | Traitement de texte, tableur, présentation |
| **Outils collaboratifs** | Microsoft 365 (Teams, SharePoint, OneDrive), Google Workspace | Travail en équipe, partage de fichiers, visioconférence |
| **Logiciels de communication** | Outlook, Teams, Zoom, Slack | Messagerie, appels, réunions |
| **Logiciels métiers** | ERP (SAP, Sage...), CRM (Salesforce...), logiciels spécialisés | Cœur d'activité de l'entreprise — souvent critiques |
| **Outils en mode SaaS** | Applications hébergées dans le Cloud, accessibles via navigateur | Pas d'installation locale ; dépendent de la connexion et d'une licence |

> **Réflexe terrain** : pour un **logiciel métier** (ERP, CRM), le technicien de proximité gère l'**accès, l'installation et les pannes courantes**, mais l'expertise fonctionnelle relève souvent d'un éditeur ou d'une équipe dédiée → savoir **escalader** (cf. §6). Pour les outils **SaaS** et **collaboratifs** (Microsoft 365), la première vérification en cas de panne est presque toujours la **licence** et la **connexion** (cf. Module 6, §1.6).

## 8. Confidentialité et posture professionnelle

Le technicien accède à des postes, des fichiers, des messageries : il est tenu à une **stricte confidentialité**. Il applique les politiques internes et les règles de protection des données (le cadre RGPD est traité dans le module Cybersécurité).

Points de vigilance :
- Ne jamais consulter de données sans nécessité liée à l'intervention.
- Ne jamais divulguer d'informations sur un utilisateur ou l'entreprise.
- Vérifier l'**identité** d'un demandeur avant toute action sensible (réinitialisation de mot de passe, suppression d'un facteur MFA) — c'est un vecteur classique d'ingénierie sociale (voir module Cybersécurité).

## 9. Veille et amélioration continue

« Apprendre en continu » est l'autre compétence transversale du référentiel. Le domaine évolue vite (cybersécurité, IA, nouveaux OS) : le technicien assure une **veille régulière**, y compris en **anglais** (la majorité de la documentation technique et des notices constructeur est anglophone).

Moyens : forums professionnels (où l'on pose **et** répond à des questions précises), documentation éditeur, sites spécialisés francophones et anglophones, échanges avec les pairs. En cas de problème récurrent ou d'observation inhabituelle, en faire part à son responsable et à l'équipe.

## 10. Fiche récapitulative — Questions d'examen types

**Q : Différence entre un incident et un problème ?**
R : L'incident est l'interruption de service constatée (le symptôme). Le problème est la cause racine à l'origine d'un ou plusieurs incidents.

**Q : Qu'est-ce qu'un SPOC ?**
R : *Single Point of Contact* — le point de contact unique (le centre de services) par lequel passent toutes les demandes.

**Q : Comment calcule-t-on la priorité d'un ticket ?**
R : En croisant l'**urgence** (délai avant conséquence) et l'**impact** (nombre de personnes / criticité métier touchés).

**Q : Que signifie un SLA, et la différence GTI / GTR ?**
R : Le SLA est l'engagement de niveau de service (délais garantis). La GTI = délai de prise en charge ; la GTR = délai de rétablissement du service.

**Q : Quand faut-il escalader un incident ?**
R : Quand il dépasse son périmètre de compétence ou ses droits. On transmet alors un rapport clair (constats, tests faits, hypothèses) à l'équipe dédiée.

**Q : Peut-on prendre la main à distance sans prévenir l'utilisateur ?**
R : Non. L'accord explicite est obligatoire, et on informe l'utilisateur de chaque action.

**Q : À quoi sert une base de connaissances ?**
R : À capitaliser les procédures de résolution des incidents récurrents, pour gagner en rapidité et permettre à toute l'équipe de traiter les cas courants.

> **Chiffres et repères clés à connaître**
> - SPOC = point de contact unique = le centre de services.
> - Priorité = Urgence × Impact.
> - GTI = prise en charge ; GTR = rétablissement.
> - N1 (proximité) → N2 (spécialistes) → N3 (experts/éditeurs).
> - GLPI = outil de référence (tickets + parc + base de connaissances), open source.
> - Incident = symptôme ; Problème = cause racine.

---

# MODULE 2 : HARDWARE & ARCHITECTURE DES SYSTÈMES INFORMATIQUES

Dans le système informatique on distingue :

- Le matériel ou **hardware**
- Le logiciel ou **software**

On distingue également les **périphériques d'entrée** (clavier, souris, manette, caméra, microphone), les **périphériques de sortie** (écran, imprimante, haut-parleurs, casque audio) et les périphériques **mixtes** entrée/sortie (par exemple un casque-micro).

## 1. Les boîtiers

Le choix d'un boîtier repose sur trois critères majeurs :

- **L'ergonomie et le design** : encombrement sur le bureau et esthétique.
- **La compatibilité matérielle** : il doit pouvoir accueillir la taille de la carte mère, la longueur de la carte graphique et la hauteur du refroidisseur CPU.
- **Le flux d'air (Airflow)** : capacité du boîtier à évacuer efficacement la chaleur. Il dépend du nombre, de l'emplacement et du sens des ventilateurs (aspiration / extraction), ainsi que de la circulation de l'air à l'intérieur du boîtier. Le push-pull est surtout utilisé sur certains radiateurs pour améliorer le refroidissement.

On distingue principalement quatre formats physiques : **Desktop** (horizontal), **Tour** (le plus commun), **Mini-PC** et **Serveur** (rackable). La taille est dictée par la norme **ATX** (créée par Intel), qui définit les dimensions standards des cartes mères : Mini-ITX < Micro-ATX < ATX < E-ATX.

**Cable Management** : un bon boîtier possède des espaces derrière la carte mère pour cacher les câbles, ce qui n'est pas seulement esthétique mais améliore grandement la circulation de l'air.

## 2. La carte mère (Motherboard)

La carte mère est le composant central du PC, c'est le cœur. Tous les autres composants y sont connectés directement ou indirectement. Elle détermine la compatibilité entre les pièces.

### 2.1 Rôles de la carte mère

- Interconnecter tous les composants (CPU, RAM, stockage, GPU...)
- Gérer les communications via les bus de données
- Héberger le BIOS/UEFI qui démarre la machine
- Fournir les ports externes (USB, audio, réseau, vidéo)

### 2.2 Facteurs de forme (Form Factor)

Le facteur de forme définit la taille physique de la carte mère et sa compatibilité avec le boîtier.

| Format | Dimensions | Utilisation typique | Nb slots RAM |
|---|---|---|---|
| Mini-ITX | 170 x 170 mm | PC très compact / HTPC | 2 slots |
| Micro-ATX | 244 x 244 mm | PC compact bureautique | 2-4 slots |
| ATX | 305 x 244 mm | PC de bureau standard / gaming | 4 slots |
| E-ATX | 305 x 330 mm | Workstation / serveur | 8 slots |

### 2.3 Les principaux composants sur la carte mère

| Composant | Description |
|---|---|
| **Socket** | Connecteur spécifique situé sur la carte mère permettant d'accueillir et de fixer le processeur (CPU). Il assure la liaison électrique et la communication entre le processeur et les autres composants (RAM, stockage, GPU). Chaque socket est conçu pour une famille précise de processeurs. Il est **non-interchangeable** : un processeur Intel ne rentrera jamais dans un socket AMD (et vice-versa). Apparence : plaque carrée recouverte de points. |
| Slots RAM (DIMM) | Emplacements pour les barrettes de RAM. La couleur indique les paires (dual channel). |
| **Chipset (jeu de puces)** | Ensemble de composants électroniques intégrés à la carte mère qui coordonne les flux de données entre le processeur et les différents périphériques (stockage, USB, réseau). Il détermine les capacités de la carte mère (nombre de ports USB, vitesse du disque dur, possibilité d'overclocking). En résumé : puce qui gère les communications entre CPU, RAM, stockage et périphériques. |
| Slots PCIe | Emplacements pour GPU, cartes réseau, cartes son, SSD NVMe... |
| Connecteurs SATA | Branchement des disques durs et SSD SATA (câble en L). |
| Slot M.2 | Emplacement pour SSD NVMe ou SATA en format compact (pas de câble). |
| Connecteur 24 broches | Alimentation principale de la carte mère depuis le PSU. |
| Connecteur CPU (4/8 broches) | Alimentation spécifique du processeur. |
| CMOS / Pile bouton | Maintient la date/heure et les paramètres BIOS quand le PC est éteint. |
| Headers façade | Connecteurs pour bouton power, reset, LEDs, USB façade, audio façade. |

> **À retenir — Carte mère**
> - Le socket doit être compatible avec le CPU : socket Intel LGA (broches sur la carte) vs AMD AM4 (broches sur le CPU), mais AM5 s'est aligné sur Intel avec LGA.
> - Le chipset détermine les fonctionnalités : overclocking, nombre de ports USB/SATA, PCIe...
> - ATX = standard le plus courant. Mini-ITX = le plus petit. Ne jamais forcer un format incompatible dans un boîtier.

## 3. Le processeur (CPU)

Le CPU (Central Processing Unit) est le cerveau de l'ordinateur. Il interprète et exécute les instructions des programmes selon un cycle perpétuel en 4 étapes :

1. **Fetch (Recherche)** : récupération de l'instruction en mémoire.
2. **Decode (Interprétation)** : décodage du code opération et des opérandes par l'unité de contrôle.
3. **Execute (Exécution)** : réalisation de l'opération par l'UAL.
4. **Writeback (Écriture)** : enregistrement du résultat en registre ou en RAM.

**Architecture interne :**

- **Unité de contrôle** : dirige le flux de données et coordonne les autres unités.
- **UAL (Unité Arithmétique et Logique)** : effectue les calculs (+, -, ×) et les comparaisons logiques.
- **Registres (32/64 bits)** : zones de stockage ultra-rapides (ex : Compteur Ordinal, Registre d'état).
- **Horloge** : génère des impulsions pour synchroniser et cadencer les traitements (mesurée en GHz).
- **Bus** : canaux de communication (Données, Adresses et Contrôle).

**Technologies modernes** : les processeurs actuels intègrent de la mémoire cache (SRAM) pour réduire les temps d'accès, ainsi que le pipelining et l'unité de prédiction de branchement pour optimiser l'exécution des instructions en anticipant les besoins du programme.

### 3.1 Caractéristiques clés

| Caractéristique | Définition | Exemple |
|---|---|---|
| Nombre de cœurs (cores) | Un processeur à un cœur traite une seule consigne à la fois (en série). Un CPU multi-cœurs possède plusieurs cœurs physiques indépendants pouvant exécuter des tâches simultanément. Plus de cœurs = meilleur multitâche. | 4, 8, 16 cœurs... |
| Nombre de threads | Cœurs logiques. Avec HyperThreading = 2× cœurs physiques (chez AMD : SMT, Simultaneous Multi-Threading). | 8 cœurs = 16 threads |
| Fréquence (GHz) | Nombre de cycles par seconde. Plus = calculs plus rapides. | 3.6 GHz (3,6 milliards de cycles/s ; 1 cycle ≠ 1 instruction, IPC variable), 5.0 GHz... |
| Cache L1 / L2 / L3 | Mémoire ultra-rapide intégrée au CPU. L1 < L2 < L3 (taille) — technologie SRAM. | L3 = 12 Mo, 32 Mo... |
| TDP (Watts) | Chaleur dissipée = consommation indicative. Important pour le choix du ventirad. | 65W, 95W, 125W... |
| Architecture (nm) | Finesse de gravure : impacte surtout la chauffe et la consommation. Plus c'est fin, plus on peut mettre de transistors dans le même espace. | 7nm, 5nm, 4nm... |

### 3.2 Principaux fabricants et sockets

| Fabricant | Gamme | Socket | Particularité |
|---|---|---|---|
| Intel | Core i3 / i5 / i7 / i9 | LGA 1700 (12e/13e/14e gen) ; LGA 1851 (Core Ultra / Arrow Lake) | Broches sur la carte mère (LGA) |
| AMD | Ryzen 3 / 5 / 7 / 9 | AM4, AM5 | Broches sur le CPU (PGA pour AM4, LGA pour AM5) |
| Intel | Xeon | LGA 3647 / 4677 | Serveurs et workstations |
| AMD | EPYC / Threadripper | TR4 / SP3 / SP5 | Serveurs et workstations |

### 3.3 Refroidissement CPU

- **Ventirad (air cooler)** : radiateur + ventilateur. Suffisant pour la majorité des usages.
- **Watercooling AIO** : radiateur + pompe + ventilateurs. Plus efficace pour CPU chauds.
- **Pâte thermique** : indispensable entre le CPU et le ventirad pour conduire la chaleur.

> **Attention — Erreur fréquente à l'examen**
> - LGA et PGA ne sont pas identiques : LGA = broches sur le socket de la carte mère, PGA = broches sur le CPU.
> - Un CPU Intel ne s'installe pas sur un socket AMD et vice versa.
> - Ne jamais oublier la pâte thermique lors du montage : sans elle, le CPU surchauffe en quelques secondes.

## 4. La mémoire vive (RAM)

La RAM (Random Access Memory) est la mémoire de travail du PC. Elle stocke temporairement les données des applications en cours d'utilisation. Elle est **volatile** : son contenu est effacé à chaque extinction.

### 4.1 Structure interne de la RAM

Une barrette est composée de plusieurs puces mémoire (chips), contenant chacune des millions de cellules. Chaque cellule mémoire (1 transistor + 1 condensateur) correspond à 1 bit.

### 4.2 Types de RAM

- **SDRAM (DDR3, DDR4, DDR5)** : constitue les barrettes de mémoire amovibles, servant à stocker temporairement les données des logiciels et du système. Toutes les RAM rencontrées aujourd'hui (DDR3/4/5) sont des SDRAM. La DRAM asynchrone est obsolète ; la SDRAM est son évolution synchronisée (la SDRAM se synchronise sur l'horloge du processeur).
- **SRAM (Static RAM)** : intégrée directement au processeur sous forme de mémoire cache (L1, L2, L3). Beaucoup plus rapide et coûteuse. Ne nécessite pas de rafraîchissement (d'où le terme « statique »).
- **VRAM / Vidéo RAM (technologie principale GDDR)** : mémoire spécialisée soudée sur la carte graphique, optimisée pour le transport massif de données d'image et de textures. Versions actuelles : GDDR5, GDDR6, GDDR6X, GDDR7 — et HBM sur certains GPU haut de gamme.

| Type de RAM | Génération | Vitesse typique | Tension | Usage |
|---|---|---|---|---|
| DDR3 | 3e gen | 800 - 2133 MHz | 1.5V | Anciens PC (2007-2014) |
| DDR4 | 4e gen | 2133 - 3600 MHz | 1.2V | PC courants (2014-2022) |
| DDR5 | 5e gen | 4800 - 6400 MHz+ | 1.1V | PC récents (2021+) |
| LPDDR4/5 | Mobile | Variable | 1.1V | Laptops, ultraportables |
| ECC RAM | Serveur | Variable | Variable | Serveurs et stations de travail critiques (Error-Correcting Code : détection et correction d'erreurs mémoire) |

### 4.3 Caractéristiques importantes

| Caractéristique | Description | Exemple |
|---|---|---|
| Capacité (Go) | Quantité de données stockables. 8 Go minimum, 16 Go recommandé. | 8, 16, 32, 64 Go |
| Fréquence (MHz) | Vitesse de transfert. Plus = meilleur. | 3200, 3600 MHz |
| Latence (CL) | Nombre de cycles avant réponse. Moins = meilleur. | CL16, CL18, CL36 |
| Dual Channel | 2 barrettes identiques = bande passante théorique doublée (gain réel variable). Slots de même couleur. | 2× 8 Go > 1× 16 Go |
| Format | DIMM = desktop. SO-DIMM = laptop. Physiquement incompatibles. | DIMM, SO-DIMM |
| XMP / EXPO | Profil d'overclock RAM à activer dans le BIOS pour la vraie fréquence. | XMP (Intel), EXPO (AMD) |

> **À retenir — RAM**
> - DDR3, DDR4 et DDR5 sont physiquement incompatibles (encoches différentes) : toujours vérifier la compatibilité avec la carte mère.
> - Le dual channel peut augmenter fortement la bande passante (jusqu'à ~2×) : installer les barrettes par paires dans les bons slots.
> - Capacité minimale pour Windows 11 : 4 Go (Microsoft), mais 8 Go recommandé en pratique.
> - XMP/EXPO doit être activé dans le BIOS pour que la RAM tourne à sa vraie fréquence annoncée.

## 5. Le stockage (HDD / SSD / NVMe)

Le stockage conserve les données de façon permanente (OS, fichiers, logiciels). Contrairement à la RAM, les données ne sont pas effacées à l'extinction : mémoire **non volatile**.

- **HDD (Hard Disk Drive)** : stockage magnétique composé de plateaux rotatifs et d'une tête de lecture/écriture mécanique. Plus lent (pièces mobiles), grande capacité à faible coût, sensible aux chocs. Vitesses typiques : 5400 à 7200 tr/min.
- **SSD (Solid State Drive)** : stockage à mémoire flash, sans pièce mécanique. Beaucoup plus rapide, plus résistant aux chocs, silencieux, faible consommation. Deux interfaces principales :
  - **SATA** : connectique classique, débits jusqu'à ~550 Mo/s.
  - **NVMe** : utilise le bus PCIe (via le CPU ou le chipset), débits jusqu'à 7000 Mo/s sur les modèles récents.

**Le SAS (Serial Attached SCSI) :**

- **HDD SAS** : disque dur mécanique haute performance conçu pour les serveurs. Utilise le protocole SCSI et tourne à très haute vitesse (10 000 ou 15 000 tr/min). Robuste, fonctionne 24h/24, temps d'accès plus faible qu'un HDD SATA. En résumé : **HDD SAS = Fiabilité mécanique + Rapidité de rotation (usage intensif)**.
- **SSD SAS** : support à mémoire flash utilisant l'interface professionnelle SAS. Se distingue par son **« Dual Port »** (deux chemins de données redondants) et une endurance extrême. Pour les infrastructures de stockage critiques. En résumé : **SSD SAS = Performance flash + Sécurité maximale (redondance)**.
- **NVMe (Non-Volatile Memory Express)** : protocole de transfert ultra-rapide conçu pour la mémoire flash. Utilise l'interface PCI Express pour des débits largement supérieurs au SATA. Communication directe et massivement parallèle avec le processeur, latence minimale. **Attention** : NVMe est le **langage** (protocole), M.2 est la **forme** (connecteur). Il existe des SSD M.2 qui utilisent encore le vieux langage SATA, de plus en plus rares.

### 5.1 Comparatif des technologies

| Type | Interface | Vitesse lecture | Forme | Prix/Go | Usage idéal |
|---|---|---|---|---|---|
| HDD | SATA | 80-160 Mo/s | 3.5" (desktop) / 2.5" (laptop) | Faible | Stockage de masse, NAS, archivage |
| HDD SAS | SAS | 200-300 Mo/s | 3.5" ou 2.5" (SFF) | Moyen | Serveurs, bases de données, haute dispo (24h/7j) |
| SSD SATA | SATA | 500-560 Mo/s | 2.5" ou M.2 | Moyen | Disque système, remplacement HDD |
| SSD NVMe (PCIe 3.0) | M.2 NVMe | 3000-3500 Mo/s | M.2 | Moyen-élevé | Disque système rapide |
| SSD NVMe (PCIe 4.0) | M.2 NVMe | 5000-7000 Mo/s | M.2 | Élevé | Workstation, gaming haute perf. |
| SSD NVMe (PCIe 5.0) | M.2 NVMe | 10 000+ Mo/s | M.2 | Très élevé | Pro / serveurs |
| SSD SAS | SAS | 1000-4000 Mo/s | 2.5" (SFF) | Très élevé | Infrastructures critiques, data centers, stockage SAN |

> En entreprise, le format 2.5" s'appelle le **SFF** (Small Form Factor) et le 3.5" le **LFF** (Large Form Factor).

### 5.2 Le format M.2 en détail

Le slot M.2 est un connecteur physique présent sur la carte mère qui peut accueillir deux types de SSD aux performances très différentes — source fréquente d'erreur en intervention.

- **M.2 SATA** : utilise le protocole SATA, vitesse limitée à ~560 Mo/s. Encoche de type clé B ou B+M.
- **M.2 NVMe** : utilise le protocole NVMe via le bus PCIe, communication directe avec le CPU. De 3 à 20× plus rapide que le SATA. Encoche de type clé M.

> **Point critique en intervention** : un slot M.2 NVMe n'accepte pas forcément un SSD M.2 SATA, et inversement. Un SSD peut rentrer physiquement sans être compatible avec le protocole supporté. Toujours consulter la documentation de la carte mère avant remplacement ou upgrade.

**Tailles physiques disponibles** (largeur puis longueur en mm) :

| Format | Longueur | Usage |
|---|---|---|
| 2240 | 42 mm | Petits PC, tablettes |
| 2260 | 60 mm | Rare |
| 2280 | 80 mm | Le plus courant |
| 22110 | 110 mm | Serveurs |

### 5.3 Interfaces SATA

| Composant | Description |
|---|---|
| SATA III | Interface actuelle, débit max 600 Mo/s, câble SATA en L 7 broches |
| SATA II | Ancienne gen, 300 Mo/s max, rétrocompatible avec SATA III |
| eSATA | SATA externe, remplacé par l'USB 3.x dans la plupart des cas |
| Câble SATA | Câble de données 7 broches. Câble d'alimentation SATA 15 broches (du PSU). |

### 5.4 Systèmes de fichiers

C'est l'élément logiciel qui fait le pont entre les composants physiques (HDD, SSD) et les données (fichiers, dossiers). Sans lui, le disque n'est qu'une suite de « 0 » et de « 1 » illisible. Comparable à un **bibliothécaire** qui décide où ranger chaque livre et tient un index précis. Rôles principaux :

- **Gestion de l'espace** : divise le disque en blocs (clusters) et les attribue aux fichiers.
- **Indexation** : conserve nom, taille et emplacement exact de chaque fichier (Metadata).
- **Sécurité et Permissions** : définit qui a le droit de lire, modifier ou supprimer.
- **Journalisation** : enregistre les modifications en cours pour éviter la perte de données en cas de coupure brutale.

| Système | OS compatible | Caractéristiques |
|---|---|---|
| NTFS | Windows (natif) | Journalisation, permissions, chiffrement. Standard Windows. |
| FAT32 | Windows/Linux/macOS | Compatible universel mais limité à 4 Go par fichier. |
| exFAT | Windows/Linux/macOS | Clés USB/cartes SD. Pas de limite pratique. |
| ext4 | Linux (natif) | Journalisation, permissions Linux. Standard Linux. |
| APFS | macOS (natif) | SSD optimisé, chiffrement natif. Exclusif Apple. |

> **Attention — Erreur fréquente à l'examen**
> - Un fichier de plus de 4 Go (ISO, film 4K) ne peut PAS être copié sur une clé USB formatée en FAT32.
> - NVMe et SATA M.2 ont le même connecteur physique M.2 mais des protocoles différents : pas toujours interchangeables.

## 6. La carte graphique (GPU)... et NPU

Le GPU (Graphics Processing Unit) gère l'affichage. Deux types : les **GPU dédiés** (carte graphique indépendante) et les **GPU intégrés (iGPU)** intégrés au processeur (Intel UHD / Iris Xe, AMD Radeon). Les GPU intégrés aux chipsets de carte mère sont obsolètes depuis ~2010.

### 6.1 GPU intégré vs GPU dédié

| Critère | GPU intégré (iGPU) | GPU dédié (dGPU) |
|---|---|---|
| Localisation | Dans le CPU (sur carte mère = ancien, avant ~2010) | Carte PCIe indépendante |
| Mémoire | Utilise la RAM système | VRAM dédiée (4, 8, 16 Go...) |
| Performances | Suffisant pour bureau/vidéo/2D | Indispensable pour gaming/3D/IA |
| Consommation | Très faible (intégré au CPU) | Élevée (100W à 400W+) |
| Exemples | Intel UHD, AMD Radeon Vega | NVIDIA GeForce, AMD Radeon RX |

### 6.2 Connexion et alimentation

- **Interface** : slot PCIe x16 sur la carte mère (le plus grand slot).
- **Alimentation** : connecteur PCIe 6 ou 8 broches (ou 12 broches pour les puissantes).
- **Sorties vidéo** : HDMI, DisplayPort, DVI, VGA (obsolète).

### 6.3 Sorties vidéo — Comparatif

| Connecteur | Résolution max | Audio | Remarques |
|---|---|---|---|
| HDMI 2.1 | 10K / 8K@120Hz | Oui | Standard TV et moniteurs récents |
| DisplayPort 2.1 | 16K | Oui | Standard PC gaming, écrans haut de gamme |
| DVI-D | 2560×1600 | Non | Ancien standard, encore présent sur certains écrans |
| VGA (D-Sub) | Analogique | Non | Obsolète. À éviter. Ne supporte pas la HD sans dégradation. |
| USB-C / Thunderbolt | 8K | Oui | Laptops et moniteurs modernes |

> **À retenir — GPU**
> - Sans GPU dédié, jeux 3D et logiciels de conception sont possibles mais avec performances limitées. La VRAM est séparée de la RAM système sur les GPU dédiés.
> - VGA est un signal analogique : qualité inférieure. Toujours privilégier HDMI ou DisplayPort.

### 6.4 Les NPU (Neural Processing Units) : l'accélérateur d'IA

Le NPU est une unité matérielle spécialisée dans certains calculs liés à l'intelligence artificielle, notamment les calculs matriciels. Il exécute localement certaines tâches d'IA de manière plus efficace énergétiquement que le CPU ou le GPU. Son but : décharger le CPU et le GPU pour préserver l'autonomie et la réactivité.

Principaux acteurs : Intel (Core Ultra), AMD (Ryzen AI), Apple (Neural Engine), Qualcomm (Snapdragon X Elite). Intégré directement au processeur central (SoC). Fréquent sur les PC récents, surtout les portables milieu/haut de gamme.

- **Performance** : mesurée en TOPS (Trillions d'Opérations Par Seconde).
- **Usage concret** : reconnaissance vocale, amélioration d'image en temps réel, réduction de bruit intelligente, sécurité des données (traitement local sans cloud).
- **Maintenance** : surveiller les pilotes spécifiques ; l'activité du NPU peut être visible dans le Gestionnaire des tâches de Windows 11, onglet Performance.

Les trois composants (CPU, GPU, NPU) partagent le même bus mémoire RAM : le NPU ne remplace pas le CPU ou le GPU, ils coopèrent au sein du même SoC.

> L'intégration des NPU nécessite un minimum de 16 Go de RAM (norme Copilot+) pour gérer les modèles d'IA localement. Cette demande, couplée à la priorité donnée par les fabricants aux serveurs d'IA, a fait bondir le prix des puces DDR5 de plus de 50 % depuis 2025.

## 7. L'alimentation (PSU - Power Supply Unit)

Le PSU convertit le courant secteur (220V alternatif) en courant continu de faible tension (12V, 5V, 3.3V). Il distribue l'énergie et protège contre surtensions, court-circuit, etc. Un PSU sous-dimensionné provoque instabilité et pannes.

### 7.1 Caractéristiques principales

| Caractéristique | Description |
|---|---|
| Puissance (Watts) | Règle des 20-30 % : choisir 20-30 % de marge au-dessus de la consommation réelle. |
| Certification 80 Plus | Rendement énergétique : White < Bronze < Silver < Gold < Platinum < Titanium. Garantit qu'au moins 80 % du courant est converti (le reste perdu en chaleur). |
| Modulaire | Full (tous câbles détachables), Semi (câbles vitaux fixes) ou Non-modulaire. Facilite le cable management et le flux d'air. |
| Format | ATX (standard), SFX (compact), TFX (slim). Doit correspondre au format supporté par le boîtier. |
| PFC actif | Power Factor Correction. Optimise la consommation électrique. Présent sur tous les modèles de qualité moderne. |

> Câble IEC : câble secteur qui entre dans le PSU.

### 7.2 Connecteurs du PSU

| Connecteur | Broches | Tensions | Destination | Remarques |
|---|---|---|---|---|
| ATX 24 broches | 24 pins | +3.3V, +5V, +12V, -12V, +5Vsb | Alimentation principale carte mère | Indispensable, toujours présent |
| EPS / CPU | 4+4 ou 8 broches | +12V | Alimentation du processeur (près du socket CPU) | Le 4+4 permet l'adaptation selon le socket |
| PCIe | 6 ou 8 broches (6+2) | +12V | Alimentation carte graphique | Nouveau connecteur 16 broches (12VHPWR) sur GPU haut de gamme RTX 4000/5000+ |
| SATA | 15 broches en L | +3.3V, +5V, +12V | Alimentation HDD / SSD SATA / lecteurs optiques | Distinct du connecteur SATA données (7 broches) |
| Molex | 4 broches | +5V, +12V | Anciens périphériques, ventilateurs, éclairage | Progressivement remplacé par SATA alimentation |
| Floppy | 4 broches petit | +5V | Obsolète. Parfois pour certains boîtiers/contrôleurs | 5V uniquement |

### 7.3 Calcul de la puissance nécessaire

1. Relever la consommation GPU (ex : 200W sous charge) et le **TDP** du CPU (ex : 65W). *TDP (Thermal Design Power) = quantité maximale de chaleur qu'un système de refroidissement doit dissiper pour que le processeur fonctionne correctement à sa fréquence de base.*
2. Ajouter les autres composants : RAM (~5W), SSD (~5W), HDD (~8W), carte mère (~50W).
3. Total estimatif : 65 + 200 + 5 + 5 + 8 + 50 = **333W**.
4. Ajouter 20-30 % de marge : 333 × 1.25 = **~416W**.
5. Choisir un PSU de **500W minimum** dans cet exemple.

Outils utiles : PCPartPicker.com, OuterVision PSU Calculator.

> **Attention — Erreur fréquente à l'examen**
> - PSU pas assez puissant = redémarrages aléatoires, coupures sous charge, corruption de données.
> - PSU de mauvaise qualité sans certification 80 Plus peut endommager les autres composants en cas de surtension.
> - Ne jamais ouvrir un PSU : les condensateurs gardent une charge électrique dangereuse même PC éteint et débranché.

### 7.4 L'onduleur (UPS) — protéger les équipements critiques

> 🤖 *Section ajoutée avec l'assistance d'une IA — à relire et vérifier avant usage.*

Le PSU protège un poste contre les défauts internes, mais pas contre les **problèmes du secteur** (coupure, micro-coupure, surtension, baisse de tension). L'**onduleur** (UPS — *Uninterruptible Power Supply*) s'intercale entre la prise murale et l'équipement : il contient une **batterie** qui prend instantanément le relais en cas de coupure, et **filtre** les perturbations électriques.

Son rôle n'est pas de faire fonctionner longtemps la machine sans courant, mais de **laisser le temps d'un arrêt propre** (ou de tenir le temps qu'un groupe électrogène prenne le relais), évitant ainsi corruption de données et redémarrages brutaux.

**Pour qui ?** Les **équipements critiques** : serveurs, NAS/stockage, équipements réseau (switch, routeur, box), poste de supervision. Un onduleur sur un serveur de production ou un NAS d'entreprise est indispensable.

| Type d'onduleur | Principe | Usage |
|---|---|---|
| **Off-line (standby)** | Bascule sur batterie au moment de la coupure | Postes individuels, petits équipements |
| **Line-interactive** | Régule en continu les variations de tension + batterie | PME, petits serveurs (bon compromis) |
| **Online (double conversion)** | L'équipement est toujours alimenté par la batterie (zéro coupure de bascule) | Datacenters, serveurs critiques |

**Critères de choix** : la **puissance** (en VA / Watts, à dimensionner selon les équipements branchés), l'**autonomie** (durée sur batterie), le nombre et le type de prises, et la **communication** (port USB/réseau pour déclencher un **arrêt automatique propre** des serveurs via un logiciel dédié).

> **Réflexe terrain** : la batterie d'un onduleur **s'use** (durée de vie ~3 à 5 ans). Un onduleur dont la batterie est morte ne protège plus rien, alors qu'il semble fonctionner. Tester/remplacer les batteries fait partie de la maintenance préventive. Ne pas brancher d'imprimante laser sur un onduleur (appel de courant trop élevé).

## 8. Les connecteurs et ports externes

### 8.1 Ports USB

| Standard | Débit max | Couleur connecteur | Forme | Remarques |
|---|---|---|---|---|
| USB 2.0 | 480 Mb/s (60 Mo/s) | Noir / blanc | Type-A | Standard ancien, toujours répandu |
| USB 3.0 / 3.1 Gen1 | 5 Gb/s (625 Mo/s) | Bleu | Type-A ou C | Aussi appelé USB 3.2 Gen1 |
| USB 3.1 Gen2 | 10 Gb/s (1.25 Go/s) | Rouge / bleu | Type-A ou C | Aussi appelé USB 3.2 Gen2 |
| USB 3.2 Gen2x2 | 20 Gb/s | Généralement C | Type-C | Rare, spécifique |
| USB4 / Thunderbolt 4 | 40 Gb/s | Type-C | Type-C | Compatible vidéo, daisy chain, alimentation |

### 8.2 Formes des connecteurs USB

| Forme | Usage |
|---|---|
| Type-A (rectangle plat) | PC, chargeurs, hubs. Le plus courant côté « host ». |
| Type-B (carré coins coupés) | Imprimantes, scanners, anciens périphériques. |
| Mini-USB (trapèze petit) | Anciens appareils photo, GPS, disques externes. Obsolète. |
| Micro-USB (trapèze très plat) | Smartphones anciens, manettes. En voie d'obsolescence. |
| Type-C (ovale symétrique) | Standard actuel : smartphones, laptops, moniteurs, accessoires. |

### 8.3 Ports réseau et audio

| Port | Description |
|---|---|
| RJ-45 (Ethernet) | Réseau filaire. 8 broches. 100 Mb/s (Fast), 1 Gb/s (Gigabit), 2.5/10 Gb/s (haute perf). |
| Jack 3.5mm | Audio analogique. Vert = sortie audio. Rose = entrée micro. Bleu = entrée ligne. |
| Optique TOSLINK | Audio numérique optique. Qualité supérieure au Jack. |
| HDMI (type A) | 19 broches. Vidéo + audio numérique. Standard TV/moniteur. |
| DisplayPort | 20 broches. Vidéo + audio. Standard PC gaming. |

### 8.4 Ports d'affichage legacy

| Port | Broches | Signal | Statut |
|---|---|---|---|
| VGA (D-Sub 15) | 15 | Analogique | Obsolète. Encore présent sur anciens écrans. |
| DVI-I | 29 | Analogique + Numérique | Ancien standard |
| DVI-D Single Link | 19 | Numérique | Max 1920×1200 |
| DVI-D Dual Link | 25 | Numérique | Max 2560×1600 |

> **À retenir — Connecteurs USB**
> - Couleur BLEUE d'un port USB-A = USB 3.0 minimum. Port NOIR ou BLANC = USB 2.0.
> - USB Type-C ne signifie pas forcément USB 4 ou Thunderbolt : même forme, débits variables.
> - VGA = signal analogique dégradable. Toujours préférer HDMI ou DisplayPort.
>
> *Legacy = technologie ancienne, conservée pour compatibilité, mais technologiquement dépassée, plus développée activement, remplacée par des standards plus récents. Legacy ≠ inutilisable, mais non recommandée pour du matériel moderne.*

## 9. Les bus et slots d'extension

### 9.1 Le bus PCIe (PCI Express)

PCIe est le bus d'extension principal des PC modernes. Il connecte GPU, SSD NVMe, cartes réseau, etc.

| Version PCIe | Débit par lane | Slot x16 total | Usage |
|---|---|---|---|
| PCIe 3.0 | ~1 Go/s | ~16 Go/s | Standard encore très répandu |
| PCIe 4.0 | ~2 Go/s | ~32 Go/s | GPU récents, SSD NVMe Gen4 |
| PCIe 5.0 | ~4 Go/s | ~64 Go/s | Plateformes 2023+ (Intel 13e gen, AMD Ryzen 7000) |
| PCIe 6.0 | ~8 Go/s | ~128 Go/s | En cours de déploiement (serveurs) |

### 9.2 Tailles de slots PCIe

- **x1** : petit slot. Cartes réseau, cartes son, cartes d'acquisition. 1 lane.
- **x4** : slot moyen. SSD NVMe en adaptateur, cartes HBA.
- **x8** : slot grand. Cartes RAID, certains GPU secondaires.
- **x16** : le plus grand slot. Réservé au GPU principal.

**Compatibilité** : une carte PCIe peut s'insérer dans un slot plus grand (x1 dans x16) mais tournera à la bande passante du slot de la carte. PCIe est **rétrocompatible** : une carte PCIe 4.0 peut fonctionner sur un port PCIe 3.0 (avec performances réduites).

### 9.3 Anciens bus (à connaître pour les pannes)

| Bus | Période | Description |
|---|---|---|
| PCI | 1992-2010 | Avant PCIe. Slots blancs. Débit faible (133 Mo/s). |
| AGP | 1997-2004 | Slot dédié aux cartes graphiques. Remplacé par PCIe. |
| ISA | 1981-2000 | Très ancien bus 8/16 bits. Machines d'avant 2000. |

## 10. Refroidissement

### 10.1 Pourquoi refroidir ?

Les composants (CPU, GPU, VRM, RAM) produisent de la chaleur par effet Joule. Sans évacuation thermique :

- les performances baissent (**throttling** = réduction automatique de fréquence) ;
- la durée de vie des composants diminue ;
- dans les cas extrêmes : arrêt d'urgence ou dommages permanents.

### 10.2 Les types de refroidissement

- **Refroidissement par air** (le plus courant) : deux éléments indissociables :
  - Le **dissipateur thermique (heatsink)** : bloc de métal (aluminium/cuivre) qui absorbe la chaleur et augmente la surface de dissipation via ses ailettes.
  - Le **ventilateur (fan)** : fait circuler l'air à travers les ailettes. Contrôlé par la carte mère via le signal **PWM** (régulation de vitesse selon la température).
  - **Pâte thermique** : comble les micro-irrégularités de surface qui emprisonneraient de l'air. En intervention : ne jamais remonter un ventirad sans renouveler la pâte si elle est sèche ou craquelée.
- **Watercooling (refroidissement liquide)** : l'eau conduit mieux la chaleur que l'air.
  - **AIO (All-In-One)** : circuit fermé prêt à l'emploi (pompe + radiateur + ventilateurs). Facile à installer, entretien minimal. Standard sur PC gaming et workstations.
  - **Custom loop** : circuit ouvert configurable (réservoir, pompe séparée, waterblocks GPU/RAM). Très performant, très coûteux, maintenance régulière. Niche (overclocking extrême).
- **Refroidissement passif** : aucun ventilateur, dissipateur seul (convection naturelle). Silencieux, zéro panne mécanique. Limité aux composants basse consommation (mini-PC, NAS, embarqué).

### 10.3 La circulation d'air dans le boîtier

Règle de base : ventilateurs d'entrée (**intake**) en façade/bas, ventilateurs de sortie (**exhaust**) en arrière/haut (la chaleur monte). **Pression positive** (plus d'entrée que de sortie) → moins de poussière, recommandé avec filtres. **Pression négative** (plus de sortie que d'entrée) → aspire la poussière, déconseillé.

### 10.4 Températures de référence (au repos / en charge)

| Composant | Normal repos | Normal charge | Seuil d'alerte |
|---|---|---|---|
| CPU (moderne) | 30–45 °C | 70–85 °C | > 95 °C |
| GPU | 35–50 °C | 75–85 °C | > 95 °C |
| SSD NVMe | 35–50 °C | 60–70 °C | > 80 °C |
| HDD | 30–40 °C | 40–50 °C | > 55 °C |

*Certains CPU modernes atteignent 95 °C en fonctionnement normal.*

### 10.5 Outils de diagnostic en intervention

| Outil | Usage |
|---|---|
| HWMonitor | Températures, vitesses ventilateurs, tensions |
| MSI Afterburner | Monitoring GPU en temps réel |
| CrystalDiskInfo | Température SSD/HDD via SMART |
| BIOS/UEFI | Températures CPU, vitesses fans sans OS |

> **À retenir pour le support IT :**
> - PC qui s'éteint seul sous charge → vérifier les températures en premier.
> - CPU à 100 % sans raison → peut être du throttling thermique, pas un problème logiciel.
> - Nettoyage des filtres et radiateurs = maintenance préventive essentielle (poussière = isolation thermique).
> - Renouveler la pâte thermique tous les 3–5 ans sur un laptop, moins souvent sur desktop.

## 11. Le BIOS / UEFI

Le BIOS (Basic Input/Output System) ou UEFI (Unified Extensible Firmware Interface) est le firmware de la carte mère. Il s'exécute avant tout OS et gère l'initialisation du matériel.

### 11.1 BIOS vs UEFI

| Critère | BIOS (legacy) | UEFI (moderne) |
|---|---|---|
| Interface | Texte uniquement, navigation clavier | Graphique, souris supportée |
| Adressage disque | MBR uniquement (max 2 To) | GPT et MBR (disques > 2 To) |
| Temps de démarrage | Lent | Beaucoup plus rapide (Secure Boot, Fast Boot) |
| Secure Boot | Non | Oui (empêche le boot de code non signé) |
| Table de partitions | MBR (4 partitions max) | GPT (128 partitions, disques > 2 To) |
| Présence | Avant 2012 environ | 2012 à aujourd'hui |

### 11.2 Paramètres BIOS/UEFI importants

| Paramètre | Description |
|---|---|
| Boot Order / Priority | Ordre de démarrage : HDD, USB, Réseau (PXE)... |
| Secure Boot | Valide la signature numérique du bootloader. Désactiver pour Linux si nécessaire. |
| Fast Boot | Réduit le temps de POST en sautant certains tests. Peut empêcher d'accéder au BIOS. |
| XMP / EXPO | Active le profil de fréquence haute de la RAM. |
| Virtualisation (VT-x/AMD-V) | Nécessaire pour faire tourner des VM (VMware, VirtualBox). |
| AHCI / NVMe | Mode du contrôleur SATA. AHCI = standard. IDE = ancien mode à ne pas utiliser. |
| TPM 2.0 | Puce de sécurité. Obligatoire pour Windows 11. |

### 11.3 La pile CMOS

- Pile bouton **CR2032** sur la carte mère.
- Maintient la date/heure et les paramètres BIOS quand le PC est débranché.
- Durée de vie : 5-10 ans. Symptômes de pile morte : date/heure réinitialisée à chaque démarrage, perte des réglages BIOS.
- Remplacement : retirer la pile quelques secondes = reset BIOS (CMOS clear).

> **À retenir — BIOS/UEFI**
> - UEFI + GPT = obligatoire pour installer Windows 11 et supporter des disques > 2 To.
> - BIOS + MBR = systèmes anciens, 4 partitions primaires max, disques 2 To max.
> - Secure Boot doit être désactivé pour booter sur certaines distributions Linux (ou activé avec clé tierce).
> - Pile CMOS morte = heure et date incorrectes au démarrage = symptôme caractéristique.

## 12. Assemblage et dépannage hardware

### 12.1 Ordre de montage d'un PC

1. Installer le CPU sur la carte mère (sans forcer, aligner le triangle).
2. Appliquer la pâte thermique (grain de riz au centre).
3. Fixer le ventirad / watercooling.
4. Installer la/les barrettes RAM dans les bons slots (dual channel).
5. Monter les entretoises dans le boîtier (standoffs).
6. Installer la plaque I/O de la carte mère dans le boîtier.
7. Visser la carte mère sur les entretoises.
8. Installer le PSU dans le boîtier.
9. Installer les SSD/HDD (M.2 directement, SATA avec câble).
10. Installer la carte graphique dans le slot PCIe x16.
11. Brancher tous les câbles (24 broches, CPU, PCIe, SATA, headers façade).
12. Premier démarrage : entrer dans le BIOS et vérifier que tout est détecté.

### 12.2 Précautions ESD (Décharges électrostatiques)

> **Attention — Erreur fréquente à l'examen**
> - L'électricité statique peut détruire les composants instantanément et silencieusement.
> - Toujours porter un bracelet anti-statique ou toucher une partie métallique mise à la terre avant de manipuler.
> - Travailler sur une surface antistatique ou sur la boîte carton du composant. Jamais sur moquette.
> - Tenir les cartes par les bords, jamais par les composants ou les contacts dorés.

### 12.2 (bis) Sécurité électrique et habilitation BS

> 🤖 *Section ajoutée avec l'assistance d'une IA — à relire et vérifier avant usage.*

Au-delà du risque électrostatique (qui menace le **matériel**), le technicien doit se protéger du **risque électrique** (qui menace la **personne**). Travailler sur des équipements alimentés expose à l'électrisation, voire à l'électrocution.

**Les règles de base avant toute intervention matérielle :**
- **Mettre hors tension et débrancher** l'équipement avant d'ouvrir le boîtier.
- Ne **jamais ouvrir un bloc d'alimentation (PSU) ni un écran/onduleur** : leurs condensateurs conservent une charge dangereuse même débranchés.
- Retirer bagues, montre, bracelets métalliques ; travailler avec des mains sèches.
- Utiliser des outils isolés et une zone de travail dégagée et sèche.

**L'habilitation électrique BS**

L'**habilitation électrique** est une reconnaissance, délivrée par l'employeur après une **formation** (cadre de la norme NF C 18-510), de la capacité d'une personne à accomplir des tâches en présence de risque électrique. Elle est **obligatoire** pour ces opérations et se matérialise par un titre d'habilitation.

Le niveau pertinent pour le technicien informatique est le **BS** (« Basse tension, interventions élémentaires ») : il autorise des opérations simples comme **remplacer ou raccorder** un matériel en basse tension (ex. : remplacement à l'identique, réarmement d'une protection, branchement sur un circuit dédié), après consignation/mise hors tension.

| Symbole | Signification |
|---|---|
| **B** | Domaine **basse tension** (BT) |
| **S** | Interventions **élémentaires** (remplacement, raccordement simple) |
| (autres : BR, BE, H...) | Niveaux pour d'autres types d'opérations ou la haute tension (HT) |

> **À retenir** : l'habilitation **n'est pas un diplôme** mais une autorisation de l'employeur, à **renouveler** périodiquement (recyclage conseillé tous les 3 ans). Elle ne dispense jamais des règles de base : on travaille sur un équipement **hors tension et consigné**. ESD = on protège le matériel ; habilitation BS = on protège la personne.

### 12.3 Diagnostic des pannes hardware courantes

| Symptôme | Causes possibles | Vérifications |
|---|---|---|
| PC ne démarre pas (aucun bip, aucun affichage) | Câble 24 broches/CPU débranché, RAM mal insérée, court-circuit | Revérifier câbles, remettre la RAM, tester avec 1 seule barrette |
| PC démarre mais aucun affichage | Mauvaise sortie vidéo, GPU mal inséré, écran éteint | Tester sortie vidéo carte mère si iGPU, réinsérer GPU, autre câble vidéo |
| PC s'éteint aléatoirement sous charge | PSU sous-dimensionné, surchauffe CPU/GPU, RAM instable | Vérifier températures (HWiNFO64), tester PSU, vérifier XMP/EXPO |
| PC très lent | Disque presque plein, RAM saturée, pilotes obsolètes, virus | Gestionnaire des tâches, libérer espace, MAJ pilotes |
| Écran bleu (BSOD) | RAM défectueuse, pilote corrompu, SSD défaillant, surchauffe | Memtest86 (RAM), CrystalDiskInfo (SSD), DDU (pilotes GPU) |
| Bruits de clic HDD | HDD en fin de vie (head crash) | Sauvegarder immédiatement. Remplacer le disque. Ne pas attendre. |
| PC ne détecte pas un SSD/HDD | Câble SATA défaillant, slot M.2 incompatible, mode contrôleur SATA | Changer câble SATA, vérifier mode AHCI dans BIOS, vérifier slot M.2 |
| Date/heure incorrecte à chaque démarrage | Pile CMOS morte | Remplacer pile CR2032 |

### 12.4 Outils de diagnostic

| Outil | Type | Utilisation |
|---|---|---|
| HWiNFO64 | Logiciel | Monitoring températures, tensions, vitesses ventilateurs |
| CPU-Z | Logiciel | Infos détaillées CPU, RAM, carte mère. ⚠️ L'outil officiel (cpuid.com) est légitime mais de fausses versions ont été diffusées via Google Ads en 2023. |
| GPU-Z | Logiciel | Infos détaillées GPU, VRAM, températures |
| CrystalDiskInfo | Logiciel | Santé des disques SMART, températures SSD/HDD |
| Memtest86 | Bootable | Test RAM hors OS. À faire tourner 2+ passes. |
| CrystalDiskMark | Logiciel | Benchmark vitesses SSD/HDD lecture/écriture |
| Prime95 | Logiciel | Test de stabilité CPU / stress test sous charge maximale |
| FurMark | Logiciel | Stress test GPU. Vérifie stabilité et refroidissement. |

## 13. Fiche récapitulative — Questions d'examen types

**Carte mère**

- *Différence ATX / Micro-ATX ?* → Taille et nombre de slots. ATX = plus grand, plus de slots. Micro-ATX = plus compact.
- *À quoi sert le chipset ?* → Gérer les communications entre CPU, RAM, stockage et périphériques.
- *Pile CMOS morte ?* → Date/heure remise à zéro à chaque démarrage, paramètres BIOS perdus.

**CPU et RAM**

- *Différence cœurs / threads ?* → Cœurs = unités physiques. Threads = cœurs logiques (HyperThreading = 2 threads/cœur).
- *DDR4 et DDR5 compatibles ?* → Non. Encoches différentes, non interchangeables.
- *Dual channel ?* → Installer 2 barrettes identiques dans les bons slots pour doubler la bande passante.
- *RAM ne tourne pas à sa fréquence annoncée ?* → Activer XMP (Intel) ou EXPO (AMD) dans le BIOS.

**Stockage**

- *SSD SATA vs NVMe ?* → SATA max ~560 Mo/s. NVMe via PCIe : 3000 à 7000 Mo/s. NVMe beaucoup plus rapide.
- *Pourquoi ne peut-on pas copier un fichier de 10 Go sur une clé USB ?* → Clé en FAT32 (limite 4 Go/fichier). Reformater en exFAT.
- *Table de partitions pour un disque de 3 To sous Windows ?* → GPT. MBR limité à 2 To.

**Connecteurs**

- *Identifier un port USB 3.0 ?* → Languette intérieure bleue. Débit : 5 Gb/s minimum.
- *HDMI vs DisplayPort ?* → HDMI : TV/consoles/grand public. DisplayPort : PC gaming, résolutions/rafraîchissements plus élevés.
- *VGA encore utilisé ?* → Oui sur vieux écrans/PC, mais signal analogique dégradé. À remplacer par HDMI/DP.

**PSU et BIOS**

- *Certification 80 Plus Gold ?* → Rendement énergétique d'au moins 87 % en charge. Moins de chaleur et d'électricité gaspillée.
- *BIOS vs UEFI ?* → BIOS = ancien firmware texte, MBR, max 2 To. UEFI = moderne, graphique, GPT, Secure Boot, plus rapide.
- *Pourquoi activer la virtualisation dans le BIOS ?* → Faire tourner des VM (VMware, VirtualBox, Hyper-V).
- *Secure Boot ?* → Fonction UEFI qui vérifie la signature du bootloader pour empêcher le démarrage de code malveillant.

### Récapitulatif — Chiffres clés à connaître

| Composant | Valeur clé | À retenir |
|---|---|---|
| ATX | 305 × 244 mm | Format standard desktop |
| Mini-ITX | 170 × 170 mm | Format mini |
| USB 2.0 | 480 Mb/s | Languette noire/blanche |
| USB 3.0 | 5 Gb/s | Languette bleue |
| SATA III | 600 Mo/s max | 7 broches données + 15 alimentation |
| SSD NVMe Gen3 | 3500 Mo/s | 6× plus rapide que SATA |
| SSD NVMe Gen4 | 7000 Mo/s | 12× plus rapide que SATA |
| FAT32 limite | 4 Go / fichier | Attention clés USB |
| DDR4 tension | 1.2V | DDR3 = 1.5V, DDR5 = 1.1V |
| Pile CMOS | CR2032 | Pile bouton 3V |
| MBR limite disque | 2 To | Au-delà = GPT obligatoire |
| PCIe x16 | Slot GPU | Le plus long slot de la carte mère |
| Pâte thermique | Grain de riz | Quantité et emplacement centre CPU |
| TPM 2.0 | Windows 11 requis | Puce sécurité |

---

# MODULE 3 : SYSTÈME D'EXPLOITATION

## 1. Les différents systèmes d'exploitation

**OS** : ensemble des programmes qui dirigent l'utilisation des ressources d'un ordinateur par des logiciels applicatifs. Il constitue l'interface entre le matériel (hardware) et les logiciels utilisateurs.

### 1.1 Familles d'OS

**OS de bureau :**

- **Windows** (Microsoft) — dominant en entreprise et grand public
- **macOS** (Apple) — exclusif au matériel Apple
- **Linux** (open source) — distributions : Ubuntu, Debian, Fedora, etc.

**OS mobile :**

- **Android** (Google) — basé sur Linux, domine le marché smartphone (~72 % de parts de marché)
- **iOS** (Apple) — exclusif iPhone/iPad, fermé et propriétaire
- **HarmonyOS** (Huawei) — en développement, marché principalement asiatique

**OS pour serveur :**

- **Linux** (Ubuntu Server, Debian, RHEL, CentOS) — majoritaire sur les serveurs web
- **Windows Server** (Microsoft) — dominant en environnement Active Directory / entreprise

**OS embarqué** : conçu pour des systèmes dédiés avec ressources limitées (firmware des routeurs, systèmes industriels, caisses enregistreuses, voitures connectées). Basés souvent sur Linux allégé ou RTOS (Real Time OS).

### 1.2 Fonctionnalités de l'OS

- **Gestion des processus** : crée, ordonnance et termine les processus. Alloue du temps CPU via un **scheduler** (ordonnanceur). Gère le multitâche. Concepts clés : processus, thread, état (actif / en attente / suspendu).
- **Gestion de la mémoire** : alloue et libère la RAM. Empêche un processus d'accéder à la mémoire d'un autre (**isolation mémoire**). Gère la **mémoire virtuelle** : une partie du disque (swap / pagefile) sert d'extension de la RAM quand elle est saturée.
- **Gestion des fichiers** : organise les données via un système de fichiers (NTFS, ext4, APFS). Gère l'arborescence, les droits d'accès, la lecture/écriture, les métadonnées.
- **Gestion des périphériques** : communique avec le matériel via des **pilotes (drivers)**. Le Gestionnaire de périphériques permet d'identifier et surveiller les composants connectés.
- **Sécurité et gestion des utilisateurs** : comptes, droits d'accès, permissions. Niveaux de privilèges :

| Niveau | Windows | Linux/macOS |
|---|---|---|
| Administrateur complet | Administrateur | root |
| Utilisateur standard | Utilisateur | user |
| Élévation temporaire | UAC | sudo |

L'OS assure aussi le chiffrement, le pare-feu natif et les journaux d'événements (logs).

### 1.3 Structure du système de fichiers Windows

| Dossier | Rôle |
|---|---|
| `C:\Windows\System32` | Fichiers système critiques |
| `C:\Users` | Profils utilisateurs |
| `C:\Program Files` | Applications 64 bits |
| `C:\Program Files (x86)` | Applications 32 bits |
| `C:\ProgramData` | Données applications (dossier caché) |
| `AppData\Roaming` | Profil itinérant utilisateur |
| `AppData\Local` | Données locales utilisateur |

### 1.4 Le registre Windows

Base de données hiérarchique qui stocke la configuration de Windows et des applications. Accès : `Win+R → regedit`

| Ruche | Contenu |
|---|---|
| HKEY_LOCAL_MACHINE (HKLM) | Configuration matérielle et système |
| HKEY_CURRENT_USER (HKCU) | Paramètres de l'utilisateur connecté |
| HKEY_CLASSES_ROOT (HKCR) | Associations de fichiers |
| HKEY_USERS | Profils de tous les utilisateurs |

> ⚠️ Toujours exporter une sauvegarde avant modification du registre (Fichier → Exporter).

### 1.5 Comptes et groupes locaux

Accès : `Win+R → lusrmgr.msc`

- Groupes locaux importants : Administrateurs, Utilisateurs, Invités.
- Désactiver le compte Invité par défaut en environnement entreprise.
- Renommer le compte Administrateur intégré (bonne pratique sécurité).

### 1.6 Services Windows

Un service est un programme qui tourne en arrière-plan sans interface utilisateur. Accès : `Win+R → services.msc`

| État / Type | Description |
|---|---|
| Démarré | Service actif en mémoire |
| Arrêté | Service inactif |
| Désactivé | Ne peut pas démarrer |
| Démarrage automatique | Lance au démarrage de Windows |
| Démarrage manuel | Lance à la demande |

Exemples critiques : **Print Spooler** (impression), **DHCP Client** (attribution IP), **Windows Update** (mises à jour).

### 1.7 Gestion des disques

Accès : `Win+R → diskmgmt.msc`. Créer/supprimer/formater des partitions, attribuer des lettres, `diskpart` en CLI pour cas avancés.

| | MBR | GPT |
|---|---|---|
| Partitions max | 4 primaires | 128 |
| Taille disque max | 2 To | 18 Eo |
| Compatibilité | BIOS legacy | UEFI |
| Statut | Ancien | Actuel (standard) |

### 1.8 Journaux et observateur d'événements

Accès : `Win+R → eventvwr.msc` — première consultation lors d'un crash ou dysfonctionnement inexpliqué.

| Journal | Contenu |
|---|---|
| Application | Événements générés par les logiciels |
| Système | Événements du noyau Windows et des pilotes |
| Sécurité | Connexions, échecs d'authentification, modifications de droits |

| Niveau | Signification |
|---|---|
| Information | Événement normal |
| Avertissement | Problème potentiel non bloquant |
| Erreur | Problème ayant causé un dysfonctionnement |
| Critique | Défaillance grave — action requise |

### 1.9 Sauvegarde et restauration

| Outil | Accès | Usage |
|---|---|---|
| Points de restauration | `rstrui.exe` | Restaure la config système sans affecter les données utilisateur |
| Historique des fichiers | Paramètres → Mise à jour | Sauvegarde automatique des données utilisateur |
| Image système | Panneau de configuration | Sauvegarde complète du disque |
| Snapshot VM | VirtualBox / VMware | Cliché d'état — PAS une sauvegarde long terme |

> ⚠️ Snapshot VM ≠ sauvegarde. Un snapshot occupe de l'espace disque et ne protège pas contre une défaillance matérielle.

### 1.10 À retenir — Support IT

- L'OS est la couche logicielle sans laquelle aucun logiciel applicatif ne peut fonctionner.
- Un problème matériel se diagnostique souvent depuis l'OS (gestionnaire de périphériques, logs système).
- La gestion des droits est centrale en entreprise : un utilisateur standard ne peut généralement pas installer de logiciels système ni modifier les paramètres sensibles sans élévation de privilèges.
- Le swap/pagefile excessif est un indicateur de RAM insuffisante — signe d'un besoin d'upgrade mémoire.

## 2. Installer Windows

### 2.1 Installer Windows depuis une clé bootable

- **Étape 1 — Créer la clé bootable avec Ventoy** : télécharger Ventoy sur https://www.ventoy.net et l'installer sur la clé USB (la clé sera formatée — sauvegarder les données). Copier ensuite les images (.iso) des OS sur la clé.
- **Étape 2 — Démarrer sur la clé** : brancher la clé et démarrer en appuyant sur F9 ou Échap. Si nécessaire, modifier l'ordre de démarrage dans le BIOS/UEFI.
- **Étape 3 — Installation** : sélectionner l'ISO Windows dans Ventoy. Débrancher le câble Ethernet (pour éviter certaines contraintes en environnement de test : compte Microsoft, MAJ immédiates, isolement). Choisir la langue. Cliquer « Je n'ai pas de clé de produit ». Sélectionner une partition d'au moins 64 Go (200 Go préférable). « Configurer pour une utilisation personnelle ». Renseigner nom du PC + mot de passe. Questions de sécurité : mettre 1 en environnement de test uniquement. Répondre Non à tous les paramètres de personnalisation.

**Contourner l'obligation de compte Microsoft** : ouvrir l'invite de commande avec `Maj+F10` (`Fn+Maj+F10` sur laptop) et taper :

```
OOBE\BYPASSNRO
```

(Le système redémarre.) Si cela ne fonctionne pas :

```
start ms-cxh:localonly
```

### 2.2 Paramétrage et optimisation

**Informations système** : clic droit sur Démarrer → Système (ou `Win+Pause`). Vérifier : nom du PC, version Windows, RAM, type de système.

| | 32 bits | 64 bits |
|---|---|---|
| Traitement | 32 bits à la fois | 64 bits à la fois |
| RAM max | Limité à ~4 Go | Beaucoup plus de RAM |
| Performances | Moins performant | Plus performant |

**Mises à jour et pilotes** : Paramètres → Système → Windows Update. Pour les pilotes, privilégier le site du constructeur du PC, puis le site du fabricant du composant. Windows Update propose certains pilotes mais pas toujours les plus récents. Sites tiers en recours complémentaire (ex : touslesdrivers.com). Extensions de fichiers pilotes : `.inf` ou `.sys`. Un point d'exclamation dans `devmgmt.msc` signale un pilote manquant.

Mise à jour via PowerShell (admin) : `winget upgrade` puis `winget upgrade --all`. (Ne remplace pas Windows Update et ne met pas à jour tous les pilotes.)

**Configuration réseau :**

| Commande / Accès | Action |
|---|---|
| `Win+R → PowerShell → ipconfig` | Affiche les infos réseau (IP, masque, passerelle) |
| `ping 172.16.3.X` / `ping 9.9.9.9` | Test de connectivité réseau |
| `Win+R → ncpa.cpl` | Ouvre les connexions réseau |
| IPv4 → Propriétés | Fixer l'IP, passerelle (.1 par convention), DNS (ex : 9.9.9.9) |

> ⚠️ Activer la découverte réseau uniquement lorsque c'est nécessaire et sur un réseau de confiance. Désactiver/réactiver la connexion si problème de connectivité.

**Personnalisation** : Affichage (résolution, mise à l'échelle, mode clair/sombre). GodMode : créer un dossier nommé exactement `GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}`. Explorateur : Accueil → ... → Options → Affichage → afficher fichiers cachés + extensions.

### 2.3 Raccourcis et commandes essentiels

| Raccourci / Commande | Action |
|---|---|
| `Win + X` | Menu de liens rapides (Mode admin) |
| `Win + Tab` / `Alt + Tab` | Vue des tâches |
| `Tab` | Se déplacer entre les onglets |
| `Alt + F4` | Fermer une fenêtre |
| `Win + R` | Boîte de dialogue Exécuter |
| `Win + I` | Ouvrir les Paramètres |
| `Win + Pause` | Informations système |
| `Ctrl + Shift + Esc` / `Ctrl + Alt + Suppr` | Gestionnaire des tâches |
| `powershell` | Console PowerShell (via Win+R) |
| `services.msc` | Gestion des services Windows |
| `eventvwr.msc` | Observateur d'événements |
| `secpol.msc` | Stratégie de sécurité locale |
| `wf.msc` | Pare-feu Windows avancé |
| `ncpa.cpl` | Connexions réseau |
| `msconfig` | Configuration du système / démarrage |
| `optionalfeatures` | Fonctionnalités Windows |
| `devmgmt.msc` | Gestionnaire de périphériques |
| `diskmgmt.msc` | Gestion des disques |
| `lusrmgr.msc` | Comptes et groupes locaux |
| `regedit` | Éditeur du registre |
| `diskpart` | Gestion avancée des disques (CLI) |
| `gpupdate /force` | Forcer l'application des stratégies de groupe |
| `netstat -an` | Voir connexions réseau actives et ports ouverts |
| `sfc /scannow` | Réparation des fichiers système |
| `chkdsk` | Vérification du disque |

## 3. La virtualisation

La virtualisation crée des représentations virtuelles de machines physiques (serveurs, stockage, réseaux), d'applications, de bureaux ou de données.

### 3.1 Les avantages de la virtualisation pour l'infrastructure

- **Réduction des coûts** : utilisation efficace des ressources coûteuses (allocation dynamique CPU/mémoire/stockage aux VM), consolidation de plusieurs charges sur moins de serveurs physiques (moins de consommation d'énergie).
- **Flexibilité** : déplacer les VM d'un serveur à un autre sans modification (équilibrage de charge, maintenance, reprise après sinistre avec peu d'arrêt). VM facilement créées, clonées, supprimées.
- **Complexité réduite** : moins de serveurs physiques à gérer ; snapshots pour retours arrière rapides (⚠️ un snapshot ne remplace pas une vraie sauvegarde) ; contrôle centralisé.
- **Sécurité** : VM isolées les unes des autres (les pannes/failles d'une VM n'affectent pas les autres).
- **Indépendance matérielle** : faire tourner d'anciens OS/applications sur du matériel moderne (systèmes patrimoniaux).
- **Efficacité** : limites de ressources par VM, clustering de basculement, migration en direct.

| Usage | Description |
|---|---|
| Multi-OS | Faire cohabiter plusieurs OS sans redémarrer ni partitionner |
| Isolation / Sandboxing | Tester un script/logiciel suspect sans affecter la machine physique |
| Snapshots | Cliché avant une manipulation risquée pour revenir à l'état précédent |
| Cloud / Économie | Diviser un serveur physique en plusieurs VM, réduisant coûts et consommation |

### 3.2 Machine Virtuelle (VM)

Une VM est une version logicielle d'un ordinateur physique : son propre OS, processeur virtuel, RAM, stockage, alors qu'elle n'est qu'un ensemble de fichiers tournant sur une machine physique appelée l'**hôte**. Le cœur du système est l'**hyperviseur** : le logiciel qui fait le pont entre le matériel physique et les VM.

| Type | Description | Exemples |
|---|---|---|
| Type 1 (Bare Metal) | S'installe directement sur le matériel. Serveurs et Cloud. | VMware ESXi, Proxmox, Hyper-V |
| Type 2 (Hosted) | S'installe comme un logiciel sur l'OS hôte. Utilisé en TP. | VirtualBox, VMware Workstation |

Applications de VirtualBox : développement et tests, formation/éducation, compatibilité logicielle, sécurité (analyse de malwares isolée), migration de systèmes, démonstrations logicielles.

### 3.3 Installer Windows 11 en VM

Configuration minimale : 4 Go de RAM, 2 cœurs, 60 Go de stockage. Cocher « Skip unattended installation » et activer UEFI. Débrancher le câble Ethernet avant installation.

**Bypass des prérequis Windows 11 (TPM, RAM, etc.)** : lors de l'installation, ouvrir `regedit` et naviguer jusqu'à :

```
HKEY_LOCAL_MACHINE\SYSTEM\Setup
```

Clic droit sur « Setup » → Nouveau → Clé → nommer « LabConfig » (respecter la casse). Dans LabConfig, créer les valeurs DWORD 32 bits suivantes (valeur = 1) :

- `BypassTPMCheck`
- `BypassSecureBootCheck`
- `BypassRAMCheck`
- `BypassStorageCheck`
- `BypassCPUCheck`

Pour passer l'étape de connexion internet : `Maj+F10 → OOBE\BYPASSNRO`. Après installation : installer les **VirtualBox Guest Additions** pour activer le copier-coller hôte/invité.

> ⚠️ Ne jamais installer deux hyperviseurs sur un même PC !

### 3.4 Récapitulatif

| Terme | Définition |
|---|---|
| Hôte (Host) | La machine physique réelle |
| Invité (Guest) | La machine virtuelle |
| Hyperviseur | Distribue les ressources CPU/RAM entre les VM |
| Snapshot | Cliché d'état — n'est PAS une sauvegarde long terme |
| Guest Additions | Pilotes VirtualBox pour copier-coller et résolution d'écran |

## 4. Linux — l'essentiel pour le technicien

> 🤖 *Section ajoutée avec l'assistance d'une IA — à relire et vérifier avant usage.*

Le technicien de proximité est majoritairement sur Windows, mais Linux est partout en entreprise : serveurs web, NAS, équipements réseau, box, et de plus en plus de postes. Savoir se repérer dans un terminal Linux fait partie des bases attendues. Linux est **open source** et se décline en **distributions** (Ubuntu, Debian, Fedora, RHEL...), toutes bâties sur le même noyau Linux.

### 4.1 Le terminal et le shell

Sous Linux, l'outil central n'est pas l'interface graphique mais le **terminal**, qui exécute des commandes via un **shell** (le plus courant est **Bash**). L'invite de commande affiche typiquement :

```
utilisateur@machine:~$
```

- `~` représente le dossier personnel de l'utilisateur (`/home/utilisateur`).
- `$` indique un utilisateur standard ; `#` indique l'utilisateur **root** (administrateur).

### 4.2 L'arborescence des fichiers

Contrairement à Windows (lecteurs `C:`, `D:`...), Linux a une **arborescence unique** partant de la racine `/`. Pas de lettres de lecteur : tout est rattaché à `/`.

| Dossier | Rôle |
|---|---|
| `/` | Racine de tout le système |
| `/home` | Dossiers personnels des utilisateurs (équivalent de `C:\Users`) |
| `/etc` | Fichiers de **configuration** du système et des services |
| `/var` | Données variables : **logs** (`/var/log`), bases, files d'attente |
| `/bin`, `/usr/bin` | Programmes et commandes exécutables |
| `/tmp` | Fichiers temporaires (vidés au redémarrage) |
| `/dev` | Périphériques (disques, etc.) vus comme des fichiers |
| `/mnt`, `/media` | Points de montage des disques/clés USB externes |

> **À retenir** : sous Linux, « tout est fichier » — un disque, un périphérique, une configuration sont tous représentés par des fichiers. La config d'un service se trouve quasi toujours dans `/etc`, les journaux dans `/var/log`.

### 4.3 Les commandes essentielles (~15 à connaître)

| Commande | Rôle |
|---|---|
| `pwd` | Afficher le dossier courant (*print working directory*) |
| `ls` / `ls -l` / `ls -la` | Lister les fichiers (`-l` détaillé, `-a` inclut les cachés) |
| `cd <dossier>` | Se déplacer (`cd ..` remonte, `cd ~` va au dossier perso) |
| `mkdir <nom>` | Créer un dossier |
| `touch <fichier>` | Créer un fichier vide |
| `cp <src> <dest>` | Copier |
| `mv <src> <dest>` | Déplacer ou renommer |
| `rm <fichier>` / `rm -r <dossier>` | Supprimer (`-r` récursif pour un dossier) |
| `cat <fichier>` | Afficher le contenu d'un fichier |
| `less <fichier>` | Lire un fichier page par page (quitter avec `q`) |
| `nano <fichier>` | Éditer un fichier (éditeur simple) |
| `grep "texte" <fichier>` | Rechercher une chaîne dans un fichier |
| `find /chemin -name "nom"` | Rechercher un fichier dans l'arborescence |
| `ps aux` / `top` | Lister les processus / monitoring temps réel |
| `man <commande>` | Manuel d'aide d'une commande |

> **Attention — la suppression est définitive** : `rm` ne met **pas** à la corbeille. `rm -rf /` (en root) détruit le système entier. La commande `rm -rf` est à manipuler avec une extrême prudence.

### 4.4 Les droits et la commande sudo

Linux repose sur un système de **permissions** strict. Chaque fichier a un propriétaire, un groupe, et trois niveaux de droits : **r** (read/lecture), **w** (write/écriture), **x** (execute/exécution), pour trois catégories : propriétaire / groupe / autres.

Exemple affiché par `ls -l` :
```
-rwxr-xr--  1 alice equipe  4096  ...  script.sh
 │└┬┘└┬┘└┬┘
 │ │  │  └─ autres : r-- (lecture seule)
 │ │  └──── groupe : r-x (lecture + exécution)
 │ └─────── propriétaire : rwx (tous les droits)
 └───────── type (- = fichier, d = dossier)
```

Commandes de gestion des droits :

| Commande | Rôle |
|---|---|
| `chmod <droits> <fichier>` | Modifier les permissions (ex : `chmod 755 script.sh`) |
| `chown <user>:<groupe> <fichier>` | Changer le propriétaire/groupe |
| `sudo <commande>` | Exécuter une commande avec les droits administrateur (root) |

La notation **octale** de `chmod` : chaque chiffre = somme de r(4) + w(2) + x(1). Ainsi `755` = `rwx`(7) pour le propriétaire, `r-x`(5) pour le groupe, `r-x`(5) pour les autres.

> **Équivalences Windows ↔ Linux** : l'administrateur Windows correspond à **root** ; l'élévation temporaire via **UAC** correspond à **sudo** (cf. tableau des privilèges en section 1).

### 4.5 La gestion des paquets (installer un logiciel)

Sous Linux, on n'installe pas un logiciel en téléchargeant un `.exe` : on utilise un **gestionnaire de paquets** qui récupère le logiciel depuis des dépôts officiels. Sur les distributions **Debian/Ubuntu**, c'est **APT** (*Advanced Package Tool*).

| Commande (Debian/Ubuntu) | Rôle |
|---|---|
| `sudo apt update` | Mettre à jour la liste des paquets disponibles |
| `sudo apt upgrade` | Mettre à jour les logiciels installés |
| `sudo apt install <paquet>` | Installer un logiciel (ex : `sudo apt install firefox`) |
| `sudo apt remove <paquet>` | Désinstaller un logiciel |
| `apt search <terme>` | Rechercher un paquet |

> **Réflexe terrain** : avant toute installation, toujours lancer `sudo apt update`. Sur les distributions Red Hat/Fedora, le gestionnaire est **dnf** (ou l'ancien `yum`) — la logique est identique, seules les commandes changent (`sudo dnf install <paquet>`).

> **À retenir — Linux essentiel**
> - Arborescence unique partant de `/` (pas de `C:`). Config dans `/etc`, logs dans `/var/log`.
> - `sudo` = exécuter en administrateur (équivalent de l'élévation UAC).
> - Droits **rwx** sur 3 niveaux (propriétaire/groupe/autres), gérés par `chmod` / `chown`.
> - Installation de logiciels via le gestionnaire de paquets : **apt** (Debian/Ubuntu), **dnf** (Fedora/RHEL).
> - `rm` supprime définitivement, sans corbeille.

## 5. L'accessibilité numérique

> 🤖 *Section ajoutée avec l'assistance d'une IA — à relire et vérifier avant usage.*

Le technicien de proximité doit savoir adapter l'environnement de travail aux **situations de handicap** (cf. Module 1, §7.3 pour le volet relationnel). Au-delà de l'attitude, les systèmes d'exploitation embarquent des **outils d'accessibilité** intégrés qu'il faut savoir activer et paramétrer. C'est une attente explicite du métier et un enjeu d'inclusion.

### 5.1 Les outils d'accessibilité Windows

Accès centralisé : **Paramètres → Accessibilité** (ou `Win + U`).

| Outil | Raccourci | Pour qui / quel usage |
|---|---|---|
| **Loupe** | `Win` + `+` (et `Win` + `Échap` pour quitter) | Malvoyance : agrandit tout ou partie de l'écran |
| **Narrateur** | `Win` + `Ctrl` + `Entrée` | Cécité : lit à voix haute le contenu de l'écran |
| **Contraste élevé / Thèmes de contraste** | `Alt gauche` + `Maj gauche` + `Impr écran` | Basse vision : renforce le contraste des couleurs |
| **Filtres de couleurs** | — | Daltonisme : adapte les couleurs affichées |
| **Sous-titres** | — | Surdité : sous-titres système pour les contenus audio |
| **Clavier visuel** | — | Mobilité réduite : saisie à la souris/écran tactile |
| **Touches rémanentes / filtres** | 5× `Maj` | Difficulté à appuyer sur plusieurs touches à la fois |
| **Reconnaissance vocale / Dictée** | `Win` + `H` | Mobilité réduite : piloter et dicter à la voix |
| **Taille du texte / du curseur** | — | Confort visuel global |

> **Réflexe terrain** : devant un utilisateur en difficulté, ne jamais présumer. On demande comment il préfère travailler, puis on active l'outil adapté. Le narrateur et la loupe sont les deux premiers réflexes pour la vue ; les touches rémanentes pour la motricité.

### 5.2 Sur les autres systèmes

Les outils équivalents existent partout : **macOS** propose VoiceOver (lecteur d'écran), Zoom et le contrôle vocal ; **iOS** intègre VoiceOver et AssistiveTouch ; **Android** propose TalkBack et l'agrandissement. Le principe est identique — seul l'emplacement du réglage change.

> **À retenir — Accessibilité**
> - Windows : tout est dans **Paramètres → Accessibilité** (`Win + U`).
> - Vue → Loupe (`Win + +`) et Narrateur (`Win + Ctrl + Entrée`).
> - Motricité → Touches rémanentes, clavier visuel, dictée vocale (`Win + H`).
> - L'accessibilité n'est pas une option de confort : c'est une obligation d'inclusion et une attente du métier.

## 6. macOS — aperçu pour le technicien

> 🤖 *Section ajoutée avec l'assistance d'une IA — à relire et vérifier avant usage.*

**macOS** est le système d'exploitation d'Apple, **exclusif au matériel Apple** (Mac, MacBook). Il repose sur une base **Unix**, ce qui le rapproche de Linux pour la logique de fichiers et le terminal (commandes `ls`, `cd`, `sudo`... identiques). On le rencontre de plus en plus en entreprise, notamment dans les services création, communication et direction.

### 6.1 Repères d'interface et équivalences

| Élément macOS | Rôle | Équivalent Windows |
|---|---|---|
| **Finder** | Gestionnaire de fichiers | Explorateur de fichiers |
| **Dock** | Barre de lancement des apps | Barre des tâches |
| **Barre de menus** (haut) | Menus de l'app active | Menus de la fenêtre |
| **Spotlight** (`Cmd + Espace`) | Recherche rapide | Recherche Windows |
| **Réglages Système** | Configuration | Paramètres / Panneau de config. |
| **Trousseau (Keychain)** | Gestion des mots de passe | Gestionnaire d'identifiants |
| **Time Machine** | Sauvegarde automatique | Historique des fichiers / Image système |
| **Terminal** | Ligne de commande (Unix) | PowerShell / cmd |

### 6.2 Points clés en intervention

- **Système de fichiers** : **APFS** (Apple File System) — optimisé SSD, chiffrement natif (cf. tableau des systèmes de fichiers, Module 2).
- **Droits administrateur** : via `sudo` dans le Terminal (logique Unix, comme Linux).
- **Touche `Cmd`** : remplace le `Ctrl` de Windows pour la plupart des raccourcis (`Cmd + C`, `Cmd + V`...).
- **Gestion en parc** : les Mac s'administrent via un **MDM** compatible Apple (Apple Business Manager + solution MDM), pas via les GPO Active Directory classiques.

> **À retenir — macOS** : base Unix (terminal proche de Linux), exclusif au matériel Apple, fichiers en APFS, administration par MDM plutôt que par GPO. La touche `Cmd` y joue le rôle du `Ctrl` Windows.

## 7. Les systèmes d'exploitation mobiles (Android & iOS)

> 🤖 *Section ajoutée avec l'assistance d'une IA — à relire et vérifier avant usage.*

Le technicien de proximité intervient aussi sur les **smartphones et tablettes** professionnels. Deux OS dominent le marché :

| OS | Éditeur | Particularités |
|---|---|---|
| **Android** | Google | Basé sur Linux, **ouvert**, domine le marché (~72 %), nombreux fabricants (Samsung, Xiaomi...), magasin Play Store |
| **iOS / iPadOS** | Apple | **Fermé et propriétaire**, exclusif iPhone/iPad, écosystème verrouillé, magasin App Store |

### 7.1 Les tâches de support courantes

- **Comptes** : un compte central conditionne tout — **compte Google** (Android) ou **Apple ID / identifiant Apple** (iOS). Beaucoup d'incidents viennent d'un mauvais compte ou d'un mot de passe oublié.
- **Sauvegarde** : **Google One / Google Drive** (Android), **iCloud** (iOS). Vérifier qu'elle est active avant toute manipulation.
- **Mises à jour** : système et applications, à maintenir pour la sécurité.
- **Connectivité** : configuration Wi-Fi, données mobiles, et **VPN** pour l'accès aux ressources de l'entreprise (cf. Module 4).
- **Sécurité** : code PIN, biométrie (empreinte/visage), chiffrement du stockage (activé par défaut sur les versions récentes).

### 7.2 La gestion de flotte mobile (MDM)

En entreprise, on ne configure pas les mobiles un par un : on utilise un **MDM (Mobile Device Management)** qui permet de déployer des applications, appliquer des règles de sécurité, et surtout **effacer un appareil à distance** en cas de perte ou de vol. La mise en œuvre du MDM (Microsoft Intune) est détaillée dans le Module 6.

> **Réflexe terrain** : un mobile professionnel perdu ou volé = priorité à l'**effacement à distance** via le MDM (ou Localiser/Find My pour un appareil isolé), pour protéger les données de l'entreprise.

> **À retenir — OS mobiles**
> - Android (Google, ouvert, basé Linux) vs iOS (Apple, fermé). Comptes pivots : Google vs Apple ID.
> - Sauvegarde : Google One/Drive vs iCloud.
> - En entreprise, gestion centralisée par **MDM** (voir Module 6), avec effacement à distance.
> - Accessibilité mobile : TalkBack (Android), VoiceOver (iOS).

---

# MODULE 4 : RÉSEAUX & INFRASTRUCTURE

## Partie 1 : Les composants du réseau (switch, routeur, wifi, MAC) et binaire

### 1. Réseau

Un réseau est un ensemble de machines et d'équipements (switch, routeurs, points d'accès, câbles RJ45, cartes réseau/NIC) qui peuvent communiquer et s'échanger des données.

**Définitions :**

- **Adresse MAC** : propre à chaque carte réseau, codée en hexadécimal sur 48 bits. Les 24 premiers bits identifient le fabricant, les 24 suivants identifient la carte de façon unique.
- **Hub** : équipement de couche 1 (Physique, OSI). Répète le signal reçu vers TOUS ses ports simultanément, sans intelligence (broadcast physique permanent). Toutes les machines « entendent » tout le trafic, bande passante partagée. Obsolète, remplacé par le switch.
- **Switch (commutateur)** : équipement de couche 2 (Liaison). Analyse les adresses MAC de chaque trame et les envoie uniquement au port destinataire grâce à sa **table SAT** (port physique ↔ adresse MAC). La bande passante est dédiée à chaque paire de communicants.
- **Modem** : MOdulateur-DEModulateur. Convertit signaux numériques ↔ analogiques. La box contient toujours un modem, intégré dans un appareil tout-en-un (Modem + Routeur + Switch + Point d'accès).
- **Routeur** : fait communiquer plusieurs réseaux entre eux, route les paquets en s'appuyant sur les adresses IP.
- **Passerelle (Gateway)** : adresse IP du routeur côté réseau local. Point de sortie obligatoire pour tout trafic à destination d'un autre réseau. Finit souvent par .1 (convention, non obligatoire). Si la passerelle est mal configurée, le PC peut communiquer avec ses voisins (VLAN local) mais ne pourra jamais sortir sur Internet, même si IP et DNS sont bons.
- **NAT (Network Address Translation)** : permet à plusieurs appareils d'un réseau local de partager une seule IP publique. À la maison on utilise plutôt le **PAT** (Port Address Translation) : plusieurs IP privées via une seule IP publique grâce aux numéros de ports.
- **Point d'accès Wi-Fi** : crée une cellule sans fil (BSS) identifiée par un SSID. La box est un appareil 3-en-1 : Routeur + Switch + Point d'accès.
- **Adresse IP** : identifiant logique unique de chaque appareil. Fixe (static) ou dynamique (DHCP). IP privées (réseau local, non routables) vs IP publiques (routables sur Internet).
- **Masque de sous-réseau** : valeur sur 32 bits associée à une adresse IP. Distingue la partie réseau de la partie hôte. Ex : 255.255.255.0 (/24).
- **Adresse de réseau** : première adresse d'une plage IP. Identifie le réseau, non assignable. Ex : 192.168.1.0.
- **Adresse de broadcast** : dernière adresse d'une plage IP. Envoie un message à tous les appareils. Ex : 192.168.1.255.
- **DNS (Domain Name System)** : convertit les noms de domaine en adresses IP (et inversement via le DNS inversé).
- **DDNS (Dynamic DNS)** : met à jour automatiquement un enregistrement DNS lorsque l'IP publique change. Utile pour l'accès distant.
- **DHCP (Dynamic Host Configuration Protocol)** : attribue automatiquement une configuration réseau (IP, masque, passerelle, DNS).
- **VPN (Virtual Private Network)** : tunnel sécurisé et chiffré entre un appareil et un réseau distant. Masque l'IP réelle. VPN nomade vs VPN site-à-site.
- **VLAN (Virtual Local Area Network)** : réseau local virtuel créé par segmentation logique d'un switch. Isole des groupes d'appareils sur la même infrastructure physique.
- **Protocole réseau** : ensemble de règles définissant l'échange de données. Ex : TCP (fiable) et UDP (rapide).
- **Ping / ICMP** : outil de diagnostic. Envoie un paquet ICMP et mesure le temps de réponse (ms). Vérifie qu'un appareil est joignable et estime la latence.

### 2. Supports de transmission : Filaire (Ethernet) vs Sans-fil (Wi-Fi)

#### 2.1 Ethernet — L'accès filaire (IEEE 802.3)

Ethernet est une norme réseau dédiée principalement aux LAN, mais aussi MAN et WAN. Standard universel des réseaux locaux. Utilisé aux couches Physique (1) et Liaison de données (2) du modèle OSI. Base de la norme IEEE 802.3. Première version (1980) : 10 Mb/s ; versions récentes : 400 Gb/s à 1,6 Tb/s sur fibre.

> ⚠️ Ethernet ne se limite pas au cuivre : il s'applique aussi aux liaisons fibre optique (10GBASE-SR, 100GBASE-LR…).

**Normes Ethernet :**

| Norme | Débit | Support | Distance max | Connecteur | Remarques |
|---|---|---|---|---|---|
| 10BASE-T | 10 Mb/s | Cat 3 / Cat 5 | 100 m | RJ45 | Obsolète |
| 100BASE-TX (Fast Eth.) | 100 Mb/s | Cat 5 / 5e | 100 m | RJ45 | Encore sur vieux équipements |
| 1000BASE-T (Gigabit) | 1 Gb/s | Cat 5e / 6 | 100 m | RJ45 | Standard actuel minimum |
| 10GBASE-T (10 Gigabit) | 10 Gb/s | Cat 6 (55 m) / Cat 6a | 55–100 m | RJ45 | Existe en cuivre, pas seulement fibre |
| 10GBASE-SR / LR | 10 Gb/s | Fibre multimode/monomode | Plusieurs km | LC/SC | Interconnexion switchs |
| 40G / 100G Ethernet | 40–100 Gb/s | Fibre optique | Variable | QSFP / MPO | Data centers, backbone |
| 200G / 400G / 800G / 1.6T | Très haut débit | Fibre optique | Variable | QSFP-DD | Réseaux opérateurs / hyperscale |

**Câbles et catégories** : le connecteur RJ45 reste identique pour toutes les catégories de cuivre. Ce qui change : qualité du cuivre, isolation interne, protection contre les interférences.

| Catégorie | Débit max | Fréquence | Blindage | Usage typique |
|---|---|---|---|---|
| Cat 5e | 1 Gb/s | 100 MHz | UTP (non blindé) | LAN bureautique — standard minimum |
| Cat 6 | 1 Gb/s (10 Gb/s sur 55 m) | 250 MHz | UTP ou FTP | LAN entreprise, interconnexion courte |
| Cat 6a | 10 Gb/s | 500 MHz | FTP / SFTP (blindé) | Infrastructure entreprise actuelle recommandée |
| Cat 7 | 10 Gb/s | 600 MHz | SFTP (blindage par paire) | Environnements industriels à fortes perturbations |
| Cat 8 | 40 Gb/s | 2000 MHz | SFTP | Data centers, liaisons très courtes (30 m max) |

**Le blindage :**

- **UTP** (Unshielded Twisted Pair) : pas de blindage — suffit en bureautique.
- **FTP** (Foiled Twisted Pair) : feuille d'aluminium autour de toutes les paires — bon rapport qualité/prix.
- **STP** (Shielded Twisted Pair) : blindage autour de chaque paire individuelle.
- **SFTP / S/FTP** : feuille par paire + blindage global — niveau maximum, milieu industriel.

> Application terrain : dans une usine avec de gros moteurs (CNC, variateurs), choisir du Cat 6a SFTP pour éviter que les parasites électromagnétiques fassent tomber le réseau.

**Rétrocompatibilité** : un câble Cat 6a fonctionne sur une vieille carte Fast Ethernet (bridé). L'inverse n'est pas vrai : un Cat 5e ne permettra jamais du 10 Gb/s stable sur 100 m.

**PoE — Power over Ethernet** : alimente électriquement un équipement réseau via le câble Ethernet, sans prise secteur séparée.

| Standard | Puissance max | Usage typique |
|---|---|---|
| PoE (802.3af) | 15,4 W | Téléphones IP, petites caméras IP, AP Wi-Fi basiques |
| PoE+ (802.3at) | 30 W | AP Wi-Fi 6, caméras PTZ, écrans d'affichage |
| PoE++ (802.3bt) | 60–90 W | PC légers, écrans, bornes de recharge, vidéo haute qualité |

> Pour qu'un équipement soit alimenté en PoE : le switch doit être un switch PoE ET l'équipement doit être compatible PoE. Un équipement non-PoE branché sur un port PoE ne sera pas endommagé (le switch détecte la compatibilité avant d'envoyer le courant).

**Le CPL (Courant Porteur en Ligne)**

> 🤖 *Passage ajouté avec l'assistance d'une IA — à relire et vérifier avant usage.*

Le **CPL** transporte le signal réseau **à travers le câblage électrique** existant du bâtiment. On branche un boîtier (adaptateur CPL) sur une prise secteur près de la box, relié en RJ45, et un second boîtier sur une prise dans une autre pièce : les données circulent par le réseau électrique. C'est une solution de **dépannage** quand on ne peut ni tirer de câble Ethernet, ni obtenir un Wi-Fi stable (mur épais, étage éloigné).

| Liaison | Principe | Quand l'utiliser |
|---|---|---|
| **Filaire (Ethernet)** | Câble RJ45 dédié | Référence : tout équipement fixe, débit garanti |
| **CPL** | Données via le réseau électrique | Dépannage quand le câble est impossible et le Wi-Fi insuffisant |
| **PoE** | Alimentation **via** le câble Ethernet | Alimenter caméra/AP/téléphone IP sans prise secteur à proximité |

> **Attention — ne pas confondre PoE et CPL.** Le **PoE** fait passer le *courant* sur un câble *réseau* (Ethernet → alimente l'équipement). Le **CPL** fait l'inverse : il fait passer le *réseau* sur le câblage *électrique* (prise secteur → transporte les données). Limites du CPL : performances variables selon la qualité et l'âge de l'installation électrique, dégradation si les deux prises sont sur des circuits/phases différents, et déconseillé sur multiprise parasurtenseur.

**Ethernet vs Wi-Fi :**

| Caractéristique | Ethernet (Câble) | Wi-Fi (Ondes) |
|---|---|---|
| Débit | Constant et dédié (Full-Duplex) | Partagé entre tous les appareils |
| Latence | Très faible — idéal VoIP, jeux, RDP | Variable — interférences et charge |
| Sécurité | Physique | Ondes dans l'air — plus exposé |
| Mobilité | Nulle | Totale |
| Fiabilité | Très élevée | Dépend de l'environnement |
| Installation | Tirage de câbles | Rapide |
| Usage recommandé | Postes fixes, serveurs, imprimantes | Téléphones, laptops, IoT |

> Règle terrain : pour tout équipement fixe (PC de bureau, imprimante, serveur, caméra fixe, téléphone IP), préférer le câble. Limite des 100 mètres : si l'imprimante est à 120 m → switch intermédiaire ou fibre.

#### 2.2 Wi-Fi — Fonctionnement et normes

Né en 1997 avec l'IEEE 802.11 (2 Mb/s). Fonctionne via les ondes hertziennes sur les bandes 2,4 GHz, 5 GHz et 6 GHz.

| Génération | Norme IEEE | Année | Fréquences | Débit max théorique | Nouveauté clé |
|---|---|---|---|---|---|
| Wi-Fi 1 | 802.11b | 1999 | 2,4 GHz | 11 Mb/s | Première démocratisation |
| Wi-Fi 2 | 802.11a | 1999 | 5 GHz | 54 Mb/s | 5 GHz (moins de congestion) |
| Wi-Fi 3 | 802.11g | 2003 | 2,4 GHz | 54 Mb/s | Unification 2,4 GHz |
| Wi-Fi 4 | 802.11n | 2009 | 2,4 + 5 GHz | 600 Mb/s | MIMO (antennes multiples) |
| Wi-Fi 5 | 802.11ac | 2013 | 5 GHz | 3,5 Gb/s | MU-MIMO, beamforming |
| Wi-Fi 6 | 802.11ax | 2019 | 2,4 + 5 GHz | 9,6 Gb/s | OFDMA — gestion dense (IoT, open space) |
| Wi-Fi 6E | 802.11ax | 2021 | 2,4 + 5 + 6 GHz | 9,6 Gb/s | Bande 6 GHz non congestionnée |
| Wi-Fi 7 | 802.11be | 2024 | 2,4 + 5 + 6 GHz | 46 Gb/s max (5–10 Gb/s utiles en réalité) | Multi-Link Operation (plusieurs bandes simultanées) |

**Fréquences et canaux :**

| Fréquence | Portée | Débit max (pratique) | Interférences | Usage recommandé |
|---|---|---|---|---|
| 2,4 GHz | Longue (traverse mieux les murs) | ~300 Mb/s | Nombreuses (micro-ondes, Bluetooth, voisins, 3 canaux) | IoT, appareils éloignés |
| 5 GHz | Courte (s'atténue avec les murs) | ~1,3 Gb/s | Peu denses (25 canaux non-chevauchants) | PC, smartphones, TV proches |
| 6 GHz (Wi-Fi 6E/7) | Très courte | > 2 Gb/s | Quasi inexistantes | Équipements récents, très haut débit |

> Canaux 2,4 GHz : seuls 3 canaux sont non-chevauchants : **1, 6 et 11**. Deux points d'accès voisins sur le même canal se perturbent — principale cause de Wi-Fi lent en immeuble. Conseil : inspecter avec Wi-Fi Analyzer (Android) ou inSSIDer (PC). En environnement dense, passer sur du 5 GHz.

#### 2.3 Wi-Fi — Sécurisation

Deux objectifs : **Authentification** (seul l'utilisateur autorisé se connecte) et **Chiffrement** (personne ne peut lire les données qui circulent).

| Protocole | Chiffrement | Statut | Niveau de sécurité |
|---|---|---|---|
| WEP | RC4 (cassé) | Obsolète, à bannir | Nul — se pirate en minutes |
| WPA | TKIP | Obsolète | Faible |
| WPA2 | AES-CCMP + PSK (Pre-Shared Key) | Standard actuel | Bon — le plus répandu en entreprise |
| WPA3 | AES-GCM + SAE (Simultaneous Authentication of Equals) | Recommandé | Excellent — résiste aux attaques par dictionnaire et brute-force offline |

> ⚠️ WEP est cassé depuis 2001. S'il est encore présent en production, c'est une faille de sécurité ouverte.

**Modes d'authentification : Personal vs Enterprise**

| Mode | Fonctionnement | Avantage | Inconvénient | Usage |
|---|---|---|---|---|
| WPA2/WPA3 Personal (PSK) | Un seul mot de passe partagé | Simple à configurer | Si un employé part, changer le mot de passe sur TOUS les appareils | Maison, PME sans AD |
| WPA2/WPA3 Enterprise (802.1X) | Chaque utilisateur se connecte avec son identifiant AD (via serveur RADIUS) | Révocation individuelle | Nécessite un serveur RADIUS + infra AD | Entreprises avec AD — recommandé |

> **Serveur RADIUS** : protocole AAA qui centralise l'authentification des accès réseau en s'appuyant sur Active Directory. Le NAS envoie les credentials au serveur RADIUS (ex : NPS sur Windows Server), qui les vérifie auprès de l'AD et répond Accept ou Reject.

**Bonnes pratiques de sécurisation :**

| Pratique | Description | Priorité |
|---|---|---|
| Utiliser WPA2 ou WPA3 | Ne jamais utiliser WEP ou WPA1 | Critique |
| Désactiver le WPS | Bouton WPS = faille connue (brute-force en quelques heures) | Critique |
| VLANs Wi-Fi dédiés | Réseau Invité isolé, Production séparé | Critique |
| Masquer le SSID | Fausse bonne idée : un scanner détecte le réseau même masqué | Inutile |
| Filtrage MAC | Limite : une MAC se spoofe facilement. Couche complémentaire | Complémentaire |
| Isolation des clients | Empêche les appareils Wi-Fi de communiquer entre eux. Obligatoire pour Wi-Fi Visiteurs | Recommandé |
| Changer le mot de passe admin par défaut | Les identifiants par défaut sont publics en ligne | Critique |

#### 2.4 Récapitulatif

**Ethernet** : norme IEEE 802.3 (cuivre RJ45 et fibre) ; Cat 6a = standard recommandé en entreprise ; PoE pour caméras/téléphones IP/AP Wi-Fi ; pour tout équipement fixe, câble > Wi-Fi.

**Wi-Fi** : Wi-Fi 6 (802.11ax) = standard actuel recommandé ; 2,4 GHz portée longue/interférences vs 5 GHz portée courte/moins encombré ; 3 canaux non-chevauchants en 2,4 GHz (1, 6, 11) ; WPA3 > WPA2 > WPA > WEP (à bannir) ; Enterprise (802.1X) = seule vraie solution pro avec AD ; désactiver le WPS ; Réseau Invité = VLAN isolé.

> Règle d'or du terrain : « On câble tout ce qui ne bouge pas, on met en Wi-Fi tout ce qui se déplace. On n'autorise jamais un VoIP ou une caméra de sécurité sur le Wi-Fi si on peut l'éviter. »

### 3. Typologie des réseaux

| Type | Portée | Usage | Technologie |
|---|---|---|---|
| PAN | 1-10 m | Montre connectée, écouteurs | Bluetooth, USB |
| LAN | 100 m - 1 km | Réseau d'entreprise, maison | Wi-Fi, Ethernet |
| MAN | 10-50 km | Plusieurs sites d'une ville | Fibre optique |
| WAN | Illimité | Internet | Satellites, câbles sous-marins |

**Topologies réseau :**

| Topologie | Avantage | Inconvénient | Usage |
|---|---|---|---|
| Étoile | Panne isolée à un seul poste | Si nœud central tombe, tout tombe | Bureaux, foyers (la plus utilisée) |
| Maillée | Ultra-robuste, chemins alternatifs | Très coûteux | Internet, systèmes militaires |
| Hybride | Flexible, adaptable | Complexe | Grandes entreprises, campus |
| Bus | Simple et peu coûteux | Câble central = point unique de défaillance | Obsolète |
| Anneau | Pas de collision | Une panne = tout le réseau tombe | Réseaux industriels anciens |

### 4. Binaire et hexadécimal

| 2⁷ | 2⁶ | 2⁵ | 2⁴ | 2³ | 2² | 2¹ | 2⁰ |
|---|---|---|---|---|---|---|---|
| 128 | 64 | 32 | 16 | 8 | 4 | 2 | 1 |

**Binaire** (base 2). Exemple : 222 par divisions successives par 2 (lire les restes de bas en haut) :
222/2=111(0) → 111/2=55(1) → 55/2=27(1) → 27/2=13(1) → 13/2=6(1) → 6/2=3(0) → 3/2=1(1) → 1/2=0(1)
→ **222 = 1101 1110** (vérification : 128+64+16+8+4+2 = 222).

Méthode décimal → binaire : soustraire successivement les puissances de 2 en partant de 128. Décimal pair → finit par 0 ; impair → finit par 1.

**Hexadécimal** (base 16, symboles 0-9 et A-F). Un octet (8 bits) = 2 caractères hexa. Exemple : 255 (décimal) = **FF** (hexa) car F=15 → 15×16⁰ + 15×16¹ = 15 + 240 = 255.

## Partie 2 : Adressage et segmentation réseau

### 1. Classes d'adresses IP

#### 1.1 IPv4

| Classe | Plage publique | Plage privée | Masque par défaut |
|---|---|---|---|
| A | 1.0.0.0 → 126.255.255.255 | 10.0.0.0 → 10.255.255.255 | /8 |
| B | 128.0.0.0 → 191.255.255.255 | 172.16.0.0 → 172.31.255.255 | /16 |
| C | 192.0.0.0 → 223.255.255.255 | 192.168.0.0 → 192.168.255.255 | /24 |
| D & E | 224.0.0.0 → 255.255.255.255 | — | Réservées |

Adresse **loopback/localhost** : 127.0.0.1 (réservée pour tester la pile réseau locale). Ces classes sont obsolètes depuis 1993 au profit du **CIDR** (le fameux /24). Aujourd'hui, on regarde le préfixe, pas la classe.

#### 1.2 IPv6 — L'adressage de demain

IPv4 = 32 bits (4 valeurs décimales pointées de 0 à 255), soit ~4,3 milliards d'adresses (stock épuisé depuis 2011). IPv6 utilise 128 bits.

Format IPv6 : 8 groupes de 4 chiffres hexadécimaux séparés par des deux-points.
- Forme longue : `2001:0db8:0000:0000:0000:0000:0000:0001`
- Simplification : les groupes de zéros consécutifs remplacés par `::` (une seule fois par adresse)
- Forme simplifiée : `2001:db8::1`
- 128 bits → 340 sextillions d'adresses

| Caractéristique | IPv4 | IPv6 |
|---|---|---|
| Taille | 32 bits | 128 bits |
| Exemple | 192.168.1.1 | 2001:db8::1 |
| Adresses disponibles | ~4,3 milliards | 340 sextillions |
| NAT nécessaire ? | Oui (pénurie) | Non |
| Config. automatique | DHCP | SLAAC (auto-config native, sans serveur) |
| Déploiement | Standard dominant | Remplacement progressif |

> Avec IPv6, le NAT devient inutile. La coexistence IPv4/IPv6 (mode dual-stack) est la norme sur les équipements récents.

### 2. Masque de sous-réseau et calculs

Le masque sert à identifier la partie réseau (Net ID) et la partie hôte (Host ID).

**Méthode ET logique** : 1 ET 1 = 1 / 0 ET 1 = 0 / 1 ET 0 = 0 / 0 ET 0 = 0

**Exemple complet avec 192.168.1.2 /24 :**

| Étape | Calcul | Résultat |
|---|---|---|
| Adresse IP en binaire | 192.168.1.2 | 11000000.10101000.00000001.00000010 |
| Masque en binaire | 255.255.255.0 | 11111111.11111111.11111111.00000000 |
| Adresse réseau (ET logique) | | 11000000.10101000.00000001.00000000 → 192.168.1.0 |
| Adresse broadcast | Remplacer 0 hôte par des 1 | 11000000.10101000.00000001.11111111 → 192.168.1.255 |
| 1ère IP utilisable | Adresse réseau + 1 | 192.168.1.1 |
| Dernière IP utilisable | Broadcast - 1 | 192.168.1.254 |
| Nombre d'hôtes | 2⁸ - 2 = 254 | 254 IP adressables |

Notation CIDR : `192.168.0.133/24` → nombre d'hôtes = 2^(32-24) - 2 = 254.

### 2.2 Notation CIDR

Le **CIDR (Classless Inter-Domain Routing)** remplace l'ancien système rigide des classes (A, B, C) par une approche flexible. Le **préfixe** (ex : /24) indique le nombre de bits réservés à la partie réseau. Grâce au CIDR, les routeurs peuvent regrouper plusieurs routes en une seule (**agrégation de routes**), allégeant les tables de routage mondiales. Standard universel qui permet de calculer dynamiquement le masque et d'étendre la durée de vie d'IPv4.

### 2.3 Découpage en sous-réseaux (exemple 44.224.191.17 /15)

Objectif : créer **32 sous-réseaux**.

**Étape 1 — Bits à emprunter** : chercher n tel que 2ⁿ ≥ 32. 2⁵ = 32 → **n = 5 bits**. Règle : prendre toujours la puissance de 2 supérieure ou égale au nombre de sous-réseaux voulus.
Masque actuel /15 + 5 bits empruntés = **nouveau masque /20**.

**Étape 2 — Nouveau masque /20** : 20 premiers bits à 1, 12 suivants à 0 → `11111111.11111111.11110000.00000000` = **255.255.240.0**. (3e octet : 4 bits à 1 + 4 bits à 0 = 11110000 = 240.)

**Étape 3 — Adresse réseau (ET logique)** : appliquer le masque sur l'IP → adresse réseau de départ confirmée : **44.224.0.0/20**.

**Étape 4 — Calcul du pas (incrément)** : le pas = poids du dernier bit à 1 dans le masque /20 (3e octet = 240). Dernier bit à 1 en position 4 → **poids = 16**. Vérification : 256 - 240 = 16. **PAS = 16**. Hôtes/sous-réseau = 2¹² - 2 = **4094 hôtes**.

**Étape 5 — Tableau des sous-réseaux** : le pas de 16 fait « sauter » de 16 dans le 3e octet (0, 16, 32, 48 … jusqu'à 240). Quand l'octet dépasse 255, on incrémente le 2e octet (224 → 225).

| # | Adresse réseau | 1ère adresse utile | Dernière adresse utile | Broadcast |
|---|---|---|---|---|
| SR 1 | 44.224.0.0/20 | 44.224.0.1 | 44.224.15.254 | 44.224.15.255 |
| SR 2 | 44.224.16.0/20 | 44.224.16.1 | 44.224.31.254 | 44.224.31.255 |
| SR 3 | 44.224.32.0/20 | 44.224.32.1 | 44.224.47.254 | 44.224.47.255 |
| ... | ... | ... | ... | ... |
| SR 31 | 44.225.224.0/20 | 44.225.224.1 | 44.225.239.254 | 44.225.239.255 |
| SR 32 | 44.225.240.0/20 | 44.225.240.1 | 44.225.255.254 | 44.225.255.255 |

> Pourquoi 224 → 225 au SR17 ? Après SR16, le 3e octet atteindrait 240 + 16 = 256 (dépasse 255). On le remet à 0 et on incrémente le 2e octet : 224 → 225.

### 2.4 Route par défaut (Default Route)

Dans une table de routage, un routeur cherche la route la plus précise correspondant à l'IP destination. Si aucune ne correspond, il utilise la route par défaut. `0.0.0.0/0` = **Default Route** : « toutes les destinations », préfixe le moins spécifique possible.

| Route | Signification | Exemple d'usage |
|---|---|---|
| 10.10.20.0/24 | Route spécifique | Réseau de l'atelier |
| 10.10.50.0/24 | Route spécifique | Réseau des serveurs |
| 0.0.0.0/0 | Default route (catch-all) | Route vers Internet (via le FAI) |

```
Routeur# show ip route
C  10.10.20.0/24 via Gi0/0   ← réseau local atelier
C  10.10.50.0/24 via Gi0/1   ← réseau serveurs
S* 0.0.0.0/0     via 91.200.1.1  ← default route (vers Internet)
```

> Sur un PC Windows, la « Default Gateway » (manuelle ou DHCP) est l'équivalent de la default route.

## Partie 3 : Comment tout communique (OSI, encapsulation, TCP/IP)

### 1. Modèle OSI — 7 couches

| Couche | Nom | Rôle | Équipements/Protocoles |
|---|---|---|---|
| 7 | Application | Données à transmettre | HTTP, FTP, DNS, SMTP |
| 6 | Présentation | Mise en forme, chiffrement/déchiffrement | SSL/TLS |
| 5 | Session | Synchroniser la connexion entre deux machines | Rarement isolée (ex. historique : NetBIOS) |
| 4 | Transport | Communication de bout en bout | TCP (fiable) / UDP (rapide). DNS : UDP 53 (requêtes), TCP 53 (transferts de zone / réponses volumineuses) |
| 3 | Réseau | Adressage et routage | IP, Routeur, mécanisme ARP |
| 2 | Liaison des données | Adressage physique | Adresse MAC, Switch |
| 1 | Physique | Transmission des signaux | Câbles (Cat 5e ~1 Gbps, Cat 6/6a ~10 Gbps), Fibre, Wi-Fi |

> Moyen mnémotechnique (1 à 7) : « **P**our **l**e **r**éseau **t**out **s**e **p**asse **a**utomatiquement ».
> Conseil : 50 % des pannes se résolvent en vérifiant la Couche 1 (câble ou alimentation) !

**ARP — Address Resolution Protocol (pont couche 2/3)** : sans ARP, une machine ne peut pas envoyer de paquet sur le réseau local même si elle connaît l'IP. Principe : « Je connais l'IP 192.168.1.50, mais quelle est son adresse MAC ? »

| Étape | Type de trame | Destination | Contenu |
|---|---|---|---|
| 1 | ARP Request | Broadcast `ff:ff:ff:ff:ff:ff` | « Qui a l'IP 192.168.1.50 ? Réponds à aa:bb:cc:dd:ee:ff » |
| 2 | ARP Reply | Unicast vers l'expéditeur | « C'est moi ! Mon adresse MAC est 11:22:33:44:55:66 » |
| 3 | Mise en cache | (local) | IP 192.168.1.50 ↔ MAC 11:22:33:44:55:66 (durée limitée) |

Cache ARP (timeout) : Windows ~2 min, Linux/Cisco ~5 min. Commandes : `arp -a` (Windows), `ip neigh show` (Linux), `show ip arp` (Cisco IOS).

> Si deux machines ont la même IP, leurs ARP Reply se concurrencent → **conflit ARP** → interruptions aléatoires.

**TLS / SSL — Chiffrement des communications** : TLS (Transport Layer Security) chiffre les données entre client et serveur (cadenas du navigateur). SSL est son prédécesseur, abandonné depuis 2015. Versions : TLS 1.2 (répandu, acceptable), TLS 1.3 (actuelle/recommandée), SSL / TLS 1.0 / 1.1 (obsolètes, à désactiver).

Le **handshake TLS** en 4 étapes :
1. Le client annonce les algorithmes de chiffrement qu'il supporte.
2. Le serveur répond et envoie son certificat (preuve d'identité).
3. Le client vérifie le certificat auprès d'une autorité de certification (CA).
4. Une clé de session chiffrée est générée → la communication commence.

> Certificat expiré ou non reconnu → le navigateur bloque avec « Votre connexion n'est pas privée » (problème de couche 6).
> Lien avec les ports : Port 80 → HTTP (non chiffré) ; Port 443 → HTTPS (chiffré via TLS).

### 2. L'encapsulation

Les données sont encapsulées de la couche 7 vers la couche 1 : on ajoute un en-tête à chaque couche (comme une lettre dans une enveloppe).

| Couche | Analogie postale |
|---|---|
| Application | Tu écris ton message (la donnée) |
| Transport | Tu mets la lettre dans une enveloppe (TCP = recommandé, UDP = simple) |
| Réseau | Tu écris les adresses IP expéditeur/destinataire |
| Accès Réseau | La lettre est mise dans le camion (câble ou Wi-Fi) |

Dépannage : « plus d'internet » → vérifier le câble (couche 1), puis les paramètres réseau (couche 3), puis l'application (couche 7).

### 3. Le modèle TCP/IP — 4 couches

| Couche | Rôle | Protocoles |
|---|---|---|
| 4 - Application | Interface utilisateur, prépare les données | HTTP, FTP, SMTP, DNS |
| 3 - Transport | Communication bout en bout, vérification | TCP (fiable) / UDP (rapide) |
| 2 - Réseau (Internet) | Adresse et route les paquets | IP (IPv4/IPv6), ICMP (Ping) |
| 1 - Liaison (Accès réseau) | Transforme les données en signaux physiques | Ethernet, Wi-Fi (802.11), Fibre |

### 4. Notion de port — Identification des applications

L'adresse IP identifie une machine ; le **numéro de port** distingue quel service est concerné. **IP + Port = Socket** (ex : `192.168.1.10:443` = machine + service HTTPS).

- Ports 0-1023 : ports bien connus (HTTP=80, HTTPS=443, SSH=22).
- Ports 1024-49151 : ports enregistrés (RDP=3389, ERP custom...).
- Ports 49152-65535 : ports dynamiques/éphémères (côté client).

| Protocole | Port(s) | Description | TCP / UDP |
|---|---|---|---|
| HTTP | 80 | Navigation web non sécurisée | TCP |
| HTTPS | 443 | Navigation web sécurisée (TLS) | TCP |
| DNS | 53 | Résolution de noms | UDP (requêtes) / TCP (transferts) |
| DHCP | 67/68 | Attribution automatique des IP | UDP |
| SSH | 22 | Connexion à distance sécurisée | TCP |
| FTP | 20-21 | Transfert de fichiers | TCP |
| SFTP | 22 | FTP sécurisé (via SSH) | TCP |
| RDP | 3389 | Bureau à distance Windows | TCP |
| SMTP | 25 | Envoi d'emails | TCP |
| POP3 | 110 | Réception d'emails (téléchargement) | TCP |
| IMAP | 143 | Réception d'emails (synchronisation) | TCP |
| SNMP | 161 | Supervision et monitoring réseau | UDP |

**TCP vs UDP :**

| Caractéristique | TCP | UDP |
|---|---|---|
| Fiabilité | Très élevée (accusés de réception) | Faible (pas de vérification) |
| Vitesse | Plus lent | Très rapide |
| Ordre des paquets | Garanti | Non garanti |
| Analogie | Lettre recommandée | Mégaphone dans la rue |
| Exemple d'usage | Téléchargement, web, RDP | Streaming, jeux en ligne, VoIP |

### 4 (bis). Le modèle OSI — Application terrain (cas Aérotec)

**Contexte** : Sonia, admin réseau chez Aérotec (200 postes), reçoit une alerte : l'ERP est inaccessible depuis tous les postes de l'atelier. Méthode : le modèle OSI couche par couche, de bas en haut (**bottom-up**). Règle d'or : « On ne saute jamais une marche. »

| Couche | Nom | Commande clé (Cisco) | Ce qu'on vérifie |
|---|---|---|---|
| 1 | Physique | `show interfaces status`, `show interface Gi0/3` | Ports connectés, vitesse, compteurs CRC/erreurs |
| 2 | Liaison | `show mac address-table`, `show cdp neighbors` | MAC apprises, topologie voisins, erreurs L2 |
| 3 | Réseau | `show ip interface brief`, `ping <IP>`, `show ip route`, `show ip arp` | Interfaces UP/DOWN, joignabilité IP, routes, ARP |
| 4 | Transport | `telnet <IP> <PORT>`, `netstat -an` | Port TCP ouvert/fermé, service en écoute |
| 5-6-7 | Session / Présent. / App. | Test applicatif direct | L'application répond-elle ? |

**Déroulé** : Couche 1 (zéro erreur CRC) ✅, Couche 2 (MAC apprises, voisins visibles) ✅, Couche 3 (routage OK, ping 5/5) ✅… et pourtant l'ERP reste inaccessible. La couche 4 révèle le problème : `telnet 10.10.50.10 8080` → Connection refused. `netstat -an | findstr LISTENING` montre que l'ERP écoute sur **9090** (pas 8080).

**Cause** : une mise à jour de l'ERP a changé le port par défaut 8080 → 9090. Le pare-feu autorisait toujours TCP/8080 mais bloquait TCP/9090. **Résolution** (pare-feu Cisco) : ouvrir le port 9090, fermer l'ancien 8080.

```
Routeur(config)# access-list 101 permit tcp 10.10.20.0 0.0.0.255 host 10.10.50.10 eq 9090
Routeur(config)# no access-list 101 permit tcp 10.10.20.0 0.0.0.255 host 10.10.50.10 eq 8080
```

**Pourquoi les couches 5, 6, 7 ne sont pas diagnostiquées séparément** : sur le terrain, elles sont quasiment toujours fusionnées dans les protocoles modernes (ex. HTTPS gère session + chiffrement TLS + HTTP). Les couches 1 à 4 se diagnostiquent une par une ; les couches 5-6-7 se vérifient ensemble en testant l'application.

**La Couche 8 — L'Interface Chaise-Clavier (ICC)** : erreur humaine entre l'utilisateur et la machine. Aucun protocole, pare-feu ou MAJ ne peut la corriger. Statistiquement, elle génère le plus grand nombre de tickets. Avant tout diagnostic OSI, vérifier l'évidence physique (câble branché ?).

> Morale : « Un réseau qui tombe, c'est rarement un drame, c'est un puzzle. Le modèle OSI, c'est la boîte qui contient toutes les pièces rangées par catégorie. »

## Partie 4 : Organisation avancée (VLANs)

**Mise en situation — Cas AéroSud** : Nadia (admin réseau, 120 employés, 4 étages) découvre qu'un stagiaire marketing a accédé aux fiches de paie de toute l'entreprise — réseau non segmenté depuis 3 ans. `show vlan brief` révèle 48 ports tous dans le VLAN 1 (réseau « plat », un seul domaine de broadcast). Second incident : les caisses du showroom tombent car un technicien R&D transfère 40 Go qui saturent tout le réseau.

### 1. Définition et intérêt des VLANs

Un VLAN (Virtual Local Area Network) est un réseau local logique créé par configuration logicielle sur un ou plusieurs switchs physiques. Sans acheter de matériel, on crée des « murs virtuels » qui isolent les flux entre services.

### 2. Les 3 piliers des VLANs

| Pilier | Bénéfice | Exemple AéroSud |
|---|---|---|
| Sécurité | Isolation par défaut entre VLANs | Le stagiaire marketing ne peut plus accéder au serveur comptabilité |
| Réduction des broadcasts | Chaque VLAN = son propre domaine de broadcast | Le transfert R&D de 40 Go ne noie plus les caisses |
| Flexibilité | Regroupement logique indépendant de la position physique | Pas besoin de tirer de nouveaux câbles |

### 3. Sans VLAN vs Avec VLAN

| Caractéristique | Sans VLAN | Avec VLAN |
|---|---|---|
| Sécurité | Faible — tout le monde voit tout | Élevée — isolation par défaut |
| Broadcast | Un seul gros domaine | Plusieurs petits domaines indépendants |
| Gestion | Physique — dépend des câbles | Logique — logicielle et flexible |
| Maintenance | Difficile — tout est lié | Facilitée — on touche un VLAN sans impacter les autres |

### 4. Ports Access et Ports Trunk

- **Port Access** : appartient à un seul VLAN, connecté à un équipement final (PC, imprimante, serveur). Trafic non taggué.

```
SW1(config)# interface range FastEthernet 0/1-12
SW1(config-if-range)# switchport mode access
SW1(config-if-range)# switchport access vlan 10
```

- **Port Trunk** : transporte le trafic de PLUSIEURS VLANs (liens inter-switch). Standard **802.1Q** : chaque trame reçoit un tag de 4 octets indiquant son VLAN.

```
SW1(config)# interface GigabitEthernet 0/1
SW1(config-if)# switchport trunk encapsulation dot1q
SW1(config-if)# switchport mode trunk
```

> Analogie du centre de tri postal : chaque colis (trame) porte une étiquette (tag VLAN) ; le convoyeur (trunk) l'achemine dans le bon bac.

### 5. Plan de VLAN — Application pratique

Numérotation par intervalles de 10 (convention pro permettant d'insérer de nouveaux VLANs).

| VLAN | Nom | Service | Ports (Switch 1) |
|---|---|---|---|
| VLAN 10 | COMPTA | Comptabilité / Finance — 1er étage | Fa0/1 → Fa0/12 |
| VLAN 20 | RD | Recherche & Développement — 2e étage | Fa0/13 → Fa0/24 |
| VLAN 30 | MARKETING | Marketing — 3e étage | Fa0/25 → Fa0/36 |
| VLAN 40 | DIRECTION | Direction — 4e étage | Fa0/37 → Fa0/42 |
| VLAN 50 | SHOWROOM | Caisses & bornes — RDC | Fa0/43 → Fa0/48 |

### 6. Séquence complète de configuration

**Étape 1 — Créer les VLANs :**

```
SW1# configure terminal
SW1(config)# vlan 10
SW1(config-vlan)# name COMPTA
SW1(config-vlan)# exit
... (idem 20/RD, 30/MARKETING, 40/DIRECTION, 50/SHOWROOM)
```

> Toujours nommer ses VLANs : sans nom, `show vlan brief` affiche `VLAN0010` au lieu de `COMPTA`.

**Étape 2 — Assigner les ports (mode Access)** : voir Port Access ci-dessus.

**Étape 3 — Configurer les trunks inter-switch** : à répéter sur CHAQUE côté du lien (4 switchs = 3 liens trunk = 6 interfaces).

**Étape 4 — Sauvegarder (INDISPENSABLE)** :

```
SW1# copy running-config startup-config
```

> Sur Cisco : la running-config est en RAM (perdue au reboot), la startup-config est en NVRAM (persistante).

**Vérification :**

| Commande | Ce qu'elle vérifie |
|---|---|
| `show vlan brief` | VLANs créés, noms, ports assignés |
| `show interfaces trunk` | Ports trunk, encapsulation 802.1Q, VLANs actifs |
| `show mac address-table` | Quelle MAC est sur quel port |
| `ping <IP_destination>` | Tester l'isolation : un ping en timeout entre deux VLANs = succès de la segmentation |

### 7. Communication inter-VLAN

Par défaut, deux VLANs ne peuvent pas communiquer. Pour autoriser des échanges contrôlés, il faut un équipement de **couche 3** :
- Un routeur (méthode « Router-on-a-stick »)
- Un switch de niveau 3 (switch L3) avec interfaces virtuelles (SVI)

> Métaphore : « Les VLANs, c'est poser les murs. Le routage inter-VLAN, c'est installer les portes à badge. »

### 8. Active Directory et les VLANs

AD gère les utilisateurs et leurs droits, les VLANs gèrent la segmentation réseau — deux couches complémentaires. Un utilisateur s'authentifie via AD, et selon son groupe AD, il peut être automatiquement placé dans le bon VLAN (ex. groupe « Comptabilité » → VLAN 10) grâce au protocole **802.1X** couplé à un serveur **RADIUS**. Sans 802.1X, l'assignation est statique (le VLAN dépend du port physique).

### 9. Sécurité des ports (Port-Security)

Restreint l'accès à un port du switch en fonction de l'adresse MAC. Première barrière contre l'intrusion physique.

**Les 3 modes de réaction (Violation) :**
- **Protect** : les paquets de l'intrus sont jetés, le port reste actif pour les autres.
- **Restrict** : idem + alerte (log/SNMP) et incrémente un compteur.
- **Shutdown (défaut)** : le port se désactive (err-disable). Réactivation manuelle nécessaire (`shutdown` puis `no shutdown`).

```
SW1(config)# interface fastEthernet 0/5
SW1(config-if)# switchport mode access
SW1(config-if)# switchport port-security
SW1(config-if)# switchport port-security maximum 1
SW1(config-if)# switchport port-security mac-address sticky
SW1(config-if)# switchport port-security violation shutdown
```

> L'option **sticky** : le switch apprend automatiquement la MAC autorisée et l'enregistre dans la configuration. Vérification : `show port-security interface fastEthernet 0/5`.

### Résumé VLANs

- Un VLAN = un réseau logique isolé sur un équipement physique.
- VLAN 1 = VLAN d'usine sur Cisco → ne jamais laisser des postes en production dessus.
- Port Access = un seul VLAN, trafic non taggué. Port Trunk = plusieurs VLANs, trafic taggué 802.1Q.
- Toujours nommer ses VLANs et sauvegarder.
- Pour faire communiquer deux VLANs → routeur ou switch L3 obligatoire.
- Les VLANs ne coûtent rien en matériel : c'est de la configuration pure.

## Partie 5 : Services et Protocoles Critiques

### 1. Serveur DHCP

Distribue automatiquement les adresses IP et paramètres réseau. Processus **DORA** :

| Étape | Description |
|---|---|
| **D** - Discover | Le client diffuse une requête pour trouver un serveur DHCP (paquet UDP) |
| **O** - Offer | Le serveur propose une adresse IP avec durée de bail |
| **R** - Request | Le client accepte l'offre et demande à louer l'IP |
| **A** - Acknowledge | Le serveur confirme l'attribution |

Ports DHCP : **67 (serveur) et 68 (client)**.

**APIPA (Automatic Private IP Addressing)** : si un appareil ne parvient pas à contacter un serveur DHCP, il s'attribue automatiquement une adresse de la plage **169.254.0.0/16** (169.254.x.x). C'est le signe d'un problème réseau (DHCP inaccessible, câble débranché, Wi-Fi déconnecté, service DHCP en panne). Permet la communication locale uniquement, pas d'Internet (pas de passerelle). « Mode secours » du PC.

### 2. Serveur DNS

Convertit les noms de domaine en adresses IP. Hiérarchie :

| Niveau | Exemple |
|---|---|
| Domaine racine | . |
| TLD (premier niveau) | .fr .com .org |
| Second niveau | wikipedia |
| Sous-domaine | fr (→ fr.wikipedia.org) |

Fonctionnement : `fr.wikipedia.org` → DNS récursif → DNS racine → DNS .org → DNS wikipedia.org → adresse IP. Port DNS : **53**.

### 3. Pare-feu (Firewall)

Équipement (matériel ou logiciel) qui contrôle et filtre le trafic entrant/sortant selon des règles. Analyse chaque paquet et l'autorise (PERMIT) ou le bloque (DENY) selon : IP source/destination, numéro de port, protocole (TCP/UDP/ICMP), direction.

**Stateless vs Stateful :**

| Type | Fonctionnement | Avantage | Inconvénient | Exemple |
|---|---|---|---|---|
| Stateless (sans état) | Analyse chaque paquet indépendamment, sans mémoire | Très rapide, peu gourmand | Ne voit pas le contexte | ACL Cisco classique (access-list) |
| Stateful (avec état) | Suit l'état de chaque connexion TCP. Autorise automatiquement les réponses aux connexions initiées de l'intérieur | Plus intelligent, meilleure sécurité | Plus gourmand (table de connexions) | Cisco ASA, pfSense, pare-feu Windows |

> Analogie : Stateless = vigile qui vérifie chaque carte sans mémoire. Stateful = vigile qui tient un registre.

**Règle d'or** : principe du moindre privilège. On autorise uniquement le nécessaire (whitelist), on bloque tout le reste par défaut.

```
access-list 101 permit tcp 10.10.20.0 0.0.0.255 host 10.10.50.10 eq 9090
access-list 101 deny ip any any   ← bloque tout le reste
```

### 4. Configuration d'un routeur

**Accéder à l'interface d'un routeur inconnu :**
- Brancher le routeur via un câble RJ45 (port LAN). Le routeur attribue une IP via son DHCP → vérifier avec `ipconfig`.
- Si pas de DHCP : configurer une IP fixe dans le même sous-réseau (ex : 192.168.1.50 si le routeur est en 192.168.1.1).
- Trouver l'interface web : regarder la Passerelle par défaut dans `ipconfig` → taper cette adresse dans le navigateur. Adresses courantes : 192.168.0.1 / 192.168.1.1. Identifiants par défaut : admin / admin (à changer immédiatement).

```
ipconfig /release   → Libère l'adresse IP actuelle
ipconfig /renew     → Demande une nouvelle IP via DHCP
ipconfig            → Affiche IP, masque, passerelle
```

**Paramètres essentiels** : SSID + mot de passe Wi-Fi (WPA2 min, WPA3 si dispo) ; mode Wi-Fi (routeur / AP / répéteur) ; DHCP ; NAT/PAT (redirection de ports) ; DNS et WAN ; désactiver le WPS.

### 5. NAT / PAT — Redirection de ports (Port Forwarding)

- **NAT** : traduit une IP privée en IP publique. Permet à tout un réseau local de sortir avec une seule IP publique.
- **PAT** : version du NAT incluant les numéros de port. Permet de rediriger un port public précis vers une machine interne.

**Exemple** : rendre un serveur GLPI accessible depuis Internet. Règle PAT : Port externe (WAN) 4444 → machine interne 192.168.1.10:443. En tapant `IP_publique:4444` on arrive sur le serveur GLPI.

Trouver son IP publique : monip.org ou whatismyip.com.

### 6. DMZ — Zone démilitarisée

Zone réseau isolée entre Internet et le réseau interne. Expose un serveur à Internet sans mettre en danger le reste.

| | DMZ | NAT/PAT |
|---|---|---|
| Exposition | Totale (tous ports ouverts) | Ciblée (un ou plusieurs ports) |
| Sécurité | Faible | Meilleure |
| Usage | Serveur web public, reverse proxy | Accès distant ciblé (GLPI, RDP…) |

> Placer un serveur en DMZ l'expose à TOUT Internet sur TOUS les ports. Préférer le NAT/PAT ciblé sauf cas spécifique.

### 7. SSH — Accès à distance sécurisé

SSH (Secure Shell) administre à distance un équipement (routeur, switch, serveur Linux) en ligne de commande. Chiffre intégralement la communication (contrairement à Telnet, en clair). Port : **22 (TCP)**.

| Mode | Fonctionnement | Sécurité |
|---|---|---|
| Par mot de passe | Login + mot de passe à chaque connexion | Correct mais vulnérable au brute-force |
| Par clé (recommandé) | Paire clé publique / clé privée (la privée ne quitte jamais le client) | Élevée |

```
ssh admin@192.168.1.1            → Connexion SSH
ssh -p 2222 admin@192.168.1.1    → SSH sur un port non standard
exit                             → Fermer la session
```

Configuration SSH sur Cisco :

```
Router(config)# hostname RTR-Principal
Router(config)# ip domain-name aerosud.local
Router(config)# crypto key generate rsa modulus 2048
Router(config)# ip ssh version 2
Router(config)# line vty 0 4
Router(config-line)# transport input ssh
Router(config-line)# login local
```

> Telnet (port 23) envoie les mots de passe en clair. SSH est son remplacement obligatoire. En production, utiliser Telnet est une faute professionnelle. Couplé à un **jump server (bastion SSH)**, SSH sécurise tous les accès d'administration depuis un point unique.

### 7 (bis). VPN — configuration de l'accès distant (côté client)

> 🤖 *Section ajoutée avec l'assistance d'une IA — à relire et vérifier avant usage.*

Le **VPN (Virtual Private Network)** crée un **tunnel chiffré** entre l'appareil de l'utilisateur et le réseau de l'entreprise, à travers Internet. Une fois connecté, le poste se comporte comme s'il était physiquement dans les locaux : il accède aux serveurs, partages et applications internes, et son trafic est protégé contre l'interception. C'est la solution standard du **télétravail** et des interventions à distance. Configurer le client VPN sur le poste de l'utilisateur est une tâche courante du technicien.

**Les deux usages à distinguer :**

| Type | Principe | Usage |
|---|---|---|
| **VPN nomade** (client-à-site) | Un poste isolé se connecte au réseau de l'entreprise | Télétravail, déplacement |
| **VPN site-à-site** | Tunnel permanent entre deux réseaux (deux sites) | Relier deux agences en continu |

Le technicien de proximité configure surtout le **VPN nomade** côté poste utilisateur.

**Protocoles courants :** **IPsec**, **OpenVPN**, **WireGuard** (moderne, rapide), et **L2TP/IPsec**. Le choix et les paramètres sont fournis par l'administrateur réseau.

**Configurer un client VPN — démarche type :**

1. Récupérer auprès de l'administrateur : le **type/protocole**, l'**adresse du serveur VPN** (IP ou nom de domaine public de l'entreprise), et les **identifiants** (login/mot de passe, certificat, ou fichier de configuration `.ovpn`).
2. Installer le **client** adapté (client VPN natif Windows, ou logiciel éditeur : OpenVPN Connect, FortiClient, Cisco AnyConnect...).
3. Saisir les paramètres (ou importer le fichier de configuration fourni).
4. Activer le **MFA** si l'entreprise l'impose (cf. Module 6).
5. Se connecter, puis **tester l'accès** à une ressource interne (partage, intranet) pour valider.

*Sous Windows, un VPN simple s'ajoute via :* Paramètres → Réseau et Internet → VPN → Ajouter un VPN (nom de connexion, serveur, type, identifiants).

> **Réflexe terrain** : « le VPN ne connecte pas » → vérifier dans l'ordre : connexion Internet du poste OK ? adresse du serveur VPN correcte ? identifiants/certificat valides (non expirés) ? MFA validé ? Et côté entreprise, le **pare-feu** autorise-t-il le port du VPN ? Une fois connecté mais « pas d'accès aux serveurs » : souvent un problème de **route** ou de **DNS** poussé par le VPN (cf. passerelle/DNS, Partie 2).

> **À retenir — VPN client**
> - Tunnel chiffré → le poste distant accède au réseau interne comme s'il était sur place.
> - Nomade (un poste → l'entreprise) vs site-à-site (deux réseaux reliés en permanence).
> - Toujours **tester l'accès à une ressource interne** après connexion.
> - Le VPN protège aussi les accès sensibles : **ne jamais exposer RDP directement sur Internet**, le faire passer par le VPN (cf. Module 6).

### 8. Commandes réseau essentielles

| Commande | Description |
|---|---|
| `ipconfig` | Configuration réseau (IP, masque, passerelle, DNS) |
| `ipconfig /all` | Version détaillée (MAC, serveur DHCP, etc.) |
| `ipconfig /release` | Abandonne l'adresse IP actuelle |
| `ipconfig /renew` | Demande une nouvelle IP via DHCP |
| `ping [IP/site]` | Teste la connectivité et la latence (ms) |
| `tracert [IP/site]` | Trace le chemin saut par saut |
| `pathping [IP/site]` | Combine Ping et Tracert |
| `netstat -an` | Liste les ports ouverts et connexions actives |
| `arp -a` | Affiche le cache ARP (table IP ↔ MAC) |
| `nslookup [nom]` | Teste la résolution DNS |
| `Test-NetConnection` | Teste la connectivité réseau (PowerShell) |
| `systeminfo` | Configurations machine et réseau |

> Diagnostic terrain, dans l'ordre : 1) `ping 127.0.0.1` (pile IP locale ?) → 2) `ping passerelle` (LAN ?) → 3) `ping 8.8.8.8` (Internet ?) → 4) `ping google.fr` (DNS ?).

### 8 (bis). Documenter le réseau

> 🤖 *Section ajoutée avec l'assistance d'une IA — à relire et vérifier avant usage.*

Déployer un réseau ne suffit pas : il faut **maintenir sa documentation à jour**. Un réseau non documenté devient ingérable dès qu'une panne survient ou qu'un autre technicien doit intervenir.

Ce qu'on documente : le **plan d'adressage IP** (plages, VLANs, IP fixes des équipements), le **schéma réseau** (topologie, équipements, liaisons), l'**inventaire des équipements** (switchs, routeurs, AP — modèle, emplacement, configuration), le **plan de câblage** et l'**étiquetage** des prises/baies de brassage, ainsi que les **identifiants et configurations** (de façon sécurisée).

> **Réflexe terrain** : une baie de brassage et des prises murales **étiquetées** font gagner un temps considérable en intervention. Mettre à jour la documentation **après chaque modification** (et non « plus tard ») : une doc fausse est pire qu'une doc absente, car elle induit en erreur.

### Fiche récapitulative — Erreurs courantes réseau

**Erreurs critiques :**
1. **Wi-Fi ≠ Ethernet** : Wi-Fi = débit partagé/interférences ; Ethernet = débit dédié/stable. Tout ce qui ne bouge pas → câble.
2. **IP 169.254.x.x** : APIPA → DHCP inaccessible (pas « Internet lent »).
3. **Ping ≠ Appli OK** : Ping = ICMP (L3) ; Application = TCP/UDP (L4+). Tester aussi les ports.
4. **Passerelle oubliée** : IP + masque + DNS OK mais pas de gateway = pas d'Internet. Vérifier `ipconfig /all`.
5. **VLAN sans routage** : VLAN = isolement logique, pas de communication auto. Inter-VLAN = routeur ou switch L3.

**Erreurs fréquentes :**
6. **Switch (couche 2/MAC) vs Routeur (couche 3/IP)** : identifier le matériel d'abord.
7. **SSID masqué ≠ sécurité** : un scanner détecte quand même. Utiliser WPA2/WPA3 + mot de passe fort.
8. **Filtrage MAC ≠ sécurité** : une MAC se spoofe. Couche complémentaire seulement.
9. **WPA2 « cassé » ?** : faux, WPA2 reste sûr avec mot de passe fort, mais peu adapté à l'entreprise (secret partagé). WPA3 = meilleur, pas obligatoire partout.

**Méthode OSI :**
10. **Ordre OSI non respecté** : méthode jury attendue (1→Câble/LED/alim ; 2→MAC/switch ; 3→IP/gateway/ping ; 4→Ports ; 5+→Application).
11. **Chercher trop haut trop vite** : 50 % des pannes = Couche 1. Vérifier le physique d'abord.
12. **Ports/protocoles oubliés** : HTTPS (443) ≠ HTTP (80) ; DNS (53) ≠ DHCP (67/68) ; TCP (fiable) ≠ UDP (rapide).

### Quizz Réseau (corrigé)

1. Adresse 169.254.X.X → **B)** Le PC n'a pas pu contacter de serveur DHCP (APIPA).
2. Équipement couche 2 utilisant les MAC → **B)** Le switch.
3. Utilité d'un VLAN → **B)** Segmenter logiquement (sécurité + réduction broadcast).
4. Ping IP OK mais google.fr inaccessible → **B)** Le DNS.
5. Port HTTPS → **C)** 443.
6. `ipconfig /release` → **B)** Abandonner l'adresse IP actuelle.
7. Masque 255.255.255.0 → **C)** /24.
8. Routage des paquets IP → **B)** Couche 3 (Réseau).
9. « Couche 8 » → **B)** L'utilisateur (erreur humaine).
10. Voir VLANs/ports sur Cisco → **B)** `show vlan brief`.

**Correction : 1-B | 2-B | 3-B | 4-B | 5-C | 6-B | 7-C | 8-B | 9-B | 10-B**

---

# MODULE 5 : MAINTENANCE, SAUVEGARDE ET PROTECTION DU SYSTÈME

## 1. Backup / Sauvegarde : définition

Un backup est la copie et l'archivage de données informatiques en vue de leur restauration en cas de perte, corruption ou destruction. En entreprise, on établit un plan de sauvegarde avec une fréquence définie.

**Règle 3-2-1-1-0 :**

| Principe | Détail |
|---|---|
| 3 copies | Au moins 3 exemplaires des données |
| 2 supports différents | Ex : disque dur + cloud |
| 1 hors site | Contre les sinistres physiques (incendie). Ex : coffre ignifugé ou site distant |
| 1 hors ligne | Contre les ransomwares : une copie non connectée au réseau |
| 0 échec | Les sauvegardes doivent être testées régulièrement |

## 2. Supports de sauvegarde

- Support physique : HDD, SSD
- Cloud : Azure, etc.
- Serveur de fichiers : NAS
- Bande magnétique LTO

## 3. Typologie des sauvegardes

| Type | Description | Restauration | Espace disque |
|---|---|---|---|
| Totale (Full) | Copie complète du disque à chaque fois | Simple (1 seule source) | Très élevé |
| Différentielle | Full puis sauvegarde ce qui a changé depuis le Full | Moyen (2 sources : Full + dernière différentielle) | Moyen |
| Incrémentale | Full puis chaque sauvegarde ne capture que les changements depuis la précédente | Long (toutes les sauvegardes) | Faible |

> Conserver au minimum 1 an les sauvegardes totales (un malware peut rester dormant plusieurs mois).

## 4. Paramètres du plan de sauvegarde

| Concept | Définition |
|---|---|
| PCA / PCI | Plan de Continuité de l'Activité/Informatique : redondance pour éviter toute interruption |
| PRA / PRI | Plan de Reprise de l'Activité/Informatique : comment restaurer après un sinistre |
| RPO (Recovery Point Objective) | Quantité de données maximum acceptable à perdre (en temps) |
| RTO (Recovery Time Objective) | Durée maximum acceptable sans production |

**Snapshot** : cliché instantané de l'état d'une machine (différent d'une sauvegarde : il copie l'état, pas les données). Restauration quasi-immédiate. Trop de snapshots peut ralentir la VM.

> 🔁 Réflexe : prendre un snapshot avant toute manipulation risquée !

## 5. Solutions de sauvegarde

| Catégorie | Outils |
|---|---|
| Windows natif | Sauvegarde de fichiers Windows |
| Logiciels spécialisés | VEEAM Backup & Replication, Proxmox Backup Server |
| Cloud | Azure |
| Serveur | Windows Server Backup |

> Windows Server permet de centraliser les mises à jour (**WSUS**) : un seul serveur récupère les MAJ et les distribue à tous les postes, avec validation et planification (mise à jour le 2e mardi du mois — **Patch Tuesday**).

## 6. Protection du système : le RAID

La sauvegarde protège contre la perte logique (suppression, ransomware, corruption). Le **RAID** protège contre la panne matérielle — il maintient le système en fonctionnement même si un disque physique lâche. Deux couches complémentaires, jamais interchangeables.

**Définition** : le RAID (Redundant Array of Independent Disks) combine plusieurs disques durs en un seul volume logique. Selon le niveau : performance, sécurité, ou les deux.

> Le RAID n'est pas une sauvegarde. Si un fichier est supprimé ou corrompu, le RAID ne le récupère pas — il réplique aussi la suppression.

### 6.1 RAID 0, RAID 1 et RAID 5

**RAID 0 — Performance** (striping : données découpées et réparties sur plusieurs disques simultanément)
- Disques minimum : 2
- Performance : élevée
- Tolérance aux pannes : aucune (un disque tombe = tout est perdu)
- Capacité utile : 100 % (2× 1 To = 2 To)
- Usage : montage vidéo, jeux (vitesse > sécurité)

**RAID 1 — Sécurité** (mirroring : données copiées à l'identique sur deux disques)
- Disques minimum : 2
- Performance : lecture rapide / écriture légèrement plus lente
- Tolérance aux pannes : un disque peut tomber sans perte
- Capacité utile : 50 % (2× 1 To = 1 To)
- Usage : serveurs critiques, postes comptables

**RAID 5 — Équilibre performance / sécurité** (données + parité réparties sur tous les disques)
- Disques minimum : 3
- Performance : bonne en lecture / écriture plus lente (calcul de parité)
- Tolérance aux pannes : un disque peut tomber sans perte
- Capacité utile : (n-1) disques (3× 1 To = 2 To)
- Usage : serveurs de fichiers d'entreprise — le compromis le plus utilisé en production

> Moyen mnémotechnique : RAID **0** = zéro sécurité ; RAID **1** = 1 copie miroir ; RAID **5** = le 5 étoiles des serveurs d'entreprise.

### 6.2 Mise en place et déploiement d'un RAID

La mise en place se réfléchit dès la conception de la machine, car elle conditionne l'installation de l'OS.

**Quand ?** Le moment idéal est avant d'installer l'OS et avant d'y mettre des données (la création d'un volume RAID efface intégralement les disques).
1. Brancher les disques vierges.
2. Créer le volume RAID (via BIOS/UEFI ou carte RAID).
3. Installer l'OS sur le volume virtuel créé.

> Possible de créer un RAID logiciel après coup sur des disques secondaires. Mais pour le disque système principal, le RAID se configure toujours au démarrage initial.

**RAID Matériel (Hardware) — Entreprise** : carte contrôleur RAID dédiée avec son propre processeur et mémoire.
1. Brancher les disques sur la carte RAID.
2. Au démarrage, touche dédiée (Ctrl+R, F2 selon le fabricant).
3. Sélectionner les disques, choisir le niveau RAID, valider.
4. La carte fusionne les disques → l'OS ne voit qu'un seul volume → installer l'OS.

| Avantage | Inconvénient |
|---|---|
| Performances maximales (processeur dédié) | Coût élevé (carte RAID = 150 € à plusieurs milliers €) |
| Transparent pour l'OS | Si la carte tombe, les disques sont illisibles sans carte identique |
| Gestion du cache en écriture | — |

**RAID Logiciel (Software) — Particuliers / NAS** : pas de carte dédiée, c'est le processeur et l'OS qui gèrent.
1. Brancher les disques secondaires vierges.
2. Ouvrir la Gestion des disques (`diskmgmt.msc`).
3. Clic droit → Nouveau volume agrégé par bandes (RAID 0) ou Nouveau volume en miroir (RAID 1).
4. L'OS gère le RAID en arrière-plan.

| Avantage | Inconvénient |
|---|---|
| Gratuit (intégré à l'OS) | Consomme des ressources CPU |
| Simple à mettre en place | Moins performant que le matériel |
| Portable (pas dépendant d'une carte) | — |

> C'est cette couche intermédiaire (matérielle ou logicielle) qui « ment intelligemment » à l'OS : il croit qu'il n'y a qu'un seul disque, alors qu'en arrière-plan les données sont dupliquées ou découpées.

**Chaîne complète de déploiement :**
```
[Achat des disques identiques]
        ↓
[Installation physique dans les baies]
        ↓
[Boot BIOS / Contrôleur RAID]  →  Choix du niveau (0, 1, 5…)
        ↓
[Création de la grappe virtuelle]  →  N disques physiques = 1 volume logique
        ↓
[Installation de l'OS / Formatage]
```

## 7. Gestion responsable du matériel — DEEE et fin de vie

> 🤖 *Section ajoutée avec l'assistance d'une IA — à relire et vérifier avant usage.*

La maintenance ne s'arrête pas à la réparation : elle inclut la **gestion responsable du matériel en fin de vie**. Les équipements informatiques contiennent des composants polluants (métaux lourds, plastiques) et des données sensibles : on ne les jette pas à la poubelle.

**Les DEEE** (Déchets d'Équipements Électriques et Électroniques) sont encadrés par une **directive européenne**. Le principe : ces déchets doivent être **collectés et recyclés** via des filières dédiées, pas mélangés aux ordures ménagères. Les équipements concernés portent souvent le pictogramme de la **poubelle barrée**.

**Les bonnes pratiques du technicien :**
- **Effacer les données avant mise au rebut** : un disque dur jeté contient des données récupérables. Procéder à un **effacement sécurisé** (logiciel d'effacement, ou destruction physique du disque pour les données sensibles). Un simple formatage ne suffit pas.
- **Réemploi avant recyclage** : un matériel encore fonctionnel peut être reconditionné, donné (associations) ou revendu, ce qui prolonge sa durée de vie. Le réemploi prime sur le recyclage.
- **Recycler via les filières agréées** : reprise par le fournisseur (obligation « 1 pour 1 » lors d'un achat équivalent), déchèterie, ou éco-organismes spécialisés.
- **Tracer** la sortie du matériel dans l'inventaire de parc (cf. Module 1).

> **À retenir — DEEE**
> - Les équipements électroniques ne se jettent pas avec les ordures : filière de recyclage dédiée (directive européenne, pictogramme poubelle barrée).
> - **Toujours effacer/détruire les données** d'un support avant mise au rebut — un formatage simple ne suffit pas.
> - Hiérarchie : réemploi > recyclage > élimination. C'est un enjeu à la fois écologique, légal et de sécurité des données.

---

# MODULE 6 : ADMINISTRATION DE WINDOWS

## 1. Microsoft 365 et Entra ID (Le Cloud)

La majorité des entreprises utilise des services hébergés dans le Cloud (messagerie, fichiers partagés, outils collaboratifs). Le serveur local (On-Premise) a souvent été remplacé ou complété par le Cloud.

**Entra ID (anciennement Azure AD)** : l'équivalent de l'Active Directory local, mais hébergé sur les serveurs de Microsoft. Service d'identité qui gère les connexions à Microsoft 365 (Outlook, Teams, SharePoint, OneDrive).

| Caractéristique | Active Directory Local (On-Premise) | Microsoft Entra ID (Cloud) |
|---|---|---|
| Emplacement | Serveur physique dans l'entreprise (DC) | Serveurs Microsoft (Cloud) |
| Gestion des PC | Jonction de domaine + GPO | Jonction Entra ID + Microsoft Intune (MDM) |
| Authentification | Kerberos / NTLM | Protocoles web (SAML, OAuth 2.0) |
| Usage typique | PME traditionnelles, usines, réseaux fermés | Télétravail, startups, entreprises modernes |

**L'environnement Hybride** : souvent l'entreprise possède les deux (vieux serveur local ET licences Microsoft 365). On installe **Entra Connect (Azure AD Connect)** sur le serveur local : il synchronise les utilisateurs de l'AD local vers le Cloud toutes les 30 minutes.

> Réflexe terrain : en hybride, l'AD local est « le maître ». Si un utilisateur oublie son mot de passe, le réinitialiser sur le serveur local (`dsa.msc`). La modification montera dans le Cloud quelques minutes plus tard.

### 1.1 Réinitialiser un mot de passe AD en PowerShell

```powershell
# Réinitialiser le mot de passe
Set-ADAccountPassword -Identity "m.dupont" `
  -NewPassword (ConvertTo-SecureString "NouveauMdp2024!" -AsPlainText -Force) `
  -Reset
# Obliger l'utilisateur à changer son mot de passe
Set-ADUser "m.dupont" -ChangePasswordAtLogon $true
# Forcer une synchronisation immédiate vers Microsoft 365
Start-ADSyncSyncCycle -PolicyType Delta
```

> `Start-ADSyncSyncCycle` doit être exécutée sur le serveur où Entra Connect est installé.

### 1.2 Joindre un PC à Microsoft Entra ID

Paramètres > Comptes > Accès professionnel ou scolaire > Se connecter > Joindre cet appareil à Microsoft Entra ID. (Ne pas simplement ajouter l'adresse mail, sinon le PC reste local.)

### 1.3 Microsoft Intune

Administre les postes joints à Entra ID : déploiement de logiciels, stratégies de sécurité, chiffrement BitLocker, inventaire matériel, conformité des appareils, effacement à distance. Intune remplace progressivement les GPO dans les environnements Cloud modernes.

### 1.3 (bis) MDM mobile — gérer smartphones et tablettes

> 🤖 *Section ajoutée avec l'assistance d'une IA — à relire et vérifier avant usage.*

Le **MDM (Mobile Device Management)** étend la gestion centralisée aux **smartphones et tablettes** professionnels (cf. OS mobiles, Module 3 §7). Microsoft Intune est la solution MDM de l'écosystème Microsoft, mais le principe vaut pour toutes (VMware Workspace ONE, Jamf pour Apple...).

**Ce que permet un MDM sur mobile :**
- **Enrôler** un appareil (l'inscrire pour qu'il soit géré par l'entreprise).
- **Déployer des applications** métier et des configurations (Wi-Fi, VPN, messagerie) à distance.
- **Appliquer des règles de sécurité** : code de verrouillage obligatoire, chiffrement, blocage de fonctions à risque.
- **Effacer à distance** un appareil perdu ou volé — totalement, ou seulement les données professionnelles (**wipe sélectif**).
- **Contrôler la conformité** : un appareil non conforme (jailbreaké, OS obsolète) peut se voir refuser l'accès aux ressources (lien avec l'accès conditionnel).

**Deux approches de parc mobile :**

| Modèle | Principe | Usage |
|---|---|---|
| **COPE / appareil d'entreprise** | Mobile fourni et entièrement géré par l'entreprise | Postes nomades, terrain |
| **BYOD** (*Bring Your Own Device*) | Appareil personnel de l'employé, seules les données pro sont gérées | Souplesse, mais frontière vie privée/pro à respecter |

> **Réflexe terrain** : pour un mobile pro **perdu ou volé**, la priorité absolue est l'**effacement à distance** via le MDM, pour protéger les données de l'entreprise. En BYOD, on privilégie le **wipe sélectif** (effacer le compartiment professionnel sans toucher aux photos/contacts personnels de l'employé).

### 1.4 Le MFA (Authentification multifacteur)

Ajoute une seconde vérification : application Microsoft Authenticator, SMS, appel téléphonique, clé de sécurité. Même si un mot de passe est volé, le pirate ne peut pas se connecter sans le second facteur.

### 1.5 Ticket classique : « J'ai changé de téléphone »

- Portail Entra ID → rechercher l'utilisateur → Méthodes d'authentification → **Exiger le réenregistrement MFA**.
- **Cas critique (téléphone perdu/cassé)** : Portail Entra ID → Utilisateurs → Méthodes d'authentification → Supprimer les anciennes méthodes MFA → Exiger le réenregistrement.

> Toujours vérifier l'identité de l'utilisateur avant cette opération (scénario classique de social engineering).

### 1.6 Les licences Microsoft 365

Outlook, Teams, OneDrive, Office, Exchange Online ne fonctionnent pas sans licence. Chemin : Portail admin M365 > Utilisateurs > Utilisateurs actifs > Licences et applications.

| Licence | Contenu principal |
|---|---|
| Microsoft 365 Business Basic | Outlook web, Teams, OneDrive, SharePoint |
| Microsoft 365 Business Standard | + applications Office desktop |
| Microsoft 365 Business Premium | + Intune, Defender, gestion sécurité avancée |

> Ticket « Je n'ai pas Teams » : souvent une licence absente, mauvaise, ou un service décoché. Toujours vérifier les licences avant un diagnostic technique complexe.

### 1.7 Les portails d'administration

| Portail | Usage |
|---|---|
| Admin Microsoft 365 | Gestion utilisateurs, licences, mots de passe |
| Entra Admin Center | MFA, accès conditionnel, appareils |
| Intune Admin Center | Gestion des postes |
| Exchange Admin Center | Boîtes mail, redirections, groupes |
| SharePoint Admin Center | Sites SharePoint et OneDrive |

**Conditional Access (Accès conditionnel)** : bloque ou autorise les connexions selon des critères (pays, appareil conforme, MFA, niveau de risque, type d'application). Si un utilisateur est bloqué « sans raison », vérifier les politiques d'accès conditionnel dans Entra ID.

### 1.8 Réflexes support à retenir

Toujours vérifier : 1) la licence M365, 2) le statut MFA, 3) la synchronisation Entra Connect, 4) l'accès conditionnel, 5) l'état du compte dans l'AD local, 6) la conformité du poste dans Intune.

## 2. Windows Server et Active Directory

### 2.1 Qu'est-ce que Windows Server ?

OS Microsoft optimisé pour les serveurs. Rôle : gérer le matériel et fournir des services (fichiers, sites web, bases de données). Conçu pour rester allumé 24h/24 et gérer des centaines de connexions simultanées. C'est la **plateforme logicielle**.

### 2.2 Installer Windows Server sur VirtualBox (grandes étapes)

Matériel : 4 Go de RAM minimum, 60 Go de stockage, 2 cœurs de CPU. Installer en **Windows Server Standard en mode expérience de bureau** (interface graphique, pas seulement CLI).

- **Étape 1** : renommer le PC selon la convention (ex : SRV_AD_01). À faire **impérativement avant** de promouvoir le serveur en Contrôleur de Domaine.
- **Étape 2 (TP)** : créer un réseau NAT pour faire communiquer les machines. Mode expert sur VirtualBox > onglet Réseaux > Nat Network > Créer > nommer et donner l'adresse IP. Puis affecter ce réseau à la VM. *(L'adresse du NAT est une adresse réseau.)*
- **Étape 3** : FIXER L'IP (adresse privée). Un contrôleur de domaine ne doit jamais changer d'IP. Pour Serveur DNS préféré, taper l'IP du propre serveur (ou 127.0.0.1) : le serveur devient son propre serveur DNS. Redémarrer la VM.

### 2.3 Active Directory (AD) : Le Service d'Annuaire

AD n'est pas un OS, c'est un **rôle** que l'on installe sur Windows Server. Rôle : centraliser la gestion des utilisateurs, ordinateurs et droits d'accès. Au lieu de créer un compte sur chaque PC, on crée un compte une seule fois dans l'AD. Quand un Windows Server héberge la base AD, on l'appelle un **Contrôleur de Domaine (DC)**.

> Windows Server est le bâtiment, Active Directory est le service de sécurité à l'entrée avec l'annuaire des occupants.

**Objets d'AD** : Users, Groups (où l'on met les utilisateurs), PC (permissions/autorisations), GPO (Group Policy Object).

**Structure d'AD** (forêt et arbres) :

| Niveau | Ex | Relation |
|---|---|---|
| Forêt | Google | L'ensemble du groupe |
| Arbre 1 | Google.fr | Domaine racine de l'arbre principal |
| Branche (sous-domaine) | Maps.google.fr | Enfant de l'arbre 1 |
| Feuille (unité d'organisation) | OU « Communication » | Dossier où l'on classe les utilisateurs |
| Arbre 2 | Youtube.com | Un autre arbre de la même forêt |

Grâce à la hiérarchie Forêt > Arbre > Domaine > OU : gestion fine des permissions, et les **GPO sont héritées** (une GPO sur le Domaine s'applique à toutes les OU en dessous).

**Pas d'Active Directory sans DNS** : installer AD installe un serveur DNS en même temps (besoin de traduire les noms de domaines). Déverrouillage de session : Ctrl droit + Suppr.

### 2.4 Installer Active Directory dans VirtualBox

- **Étape 1 — Installer AD DS** : désactiver IPv6 (`ncpa.cpl` > Propriétés > décocher IPv6 — astuce de TP, déconseillé par Microsoft en production). Tableau de bord > Rôles et fonctionnalités > AD DS (Active Directory Domain Services).
- **Étape 2** : Notifications > Promouvoir ce serveur en contrôleur de domaine > Créer la forêt. Mettre un nom avec une extension. Recommandation Microsoft actuelle : utiliser un sous-domaine réel possédé (ex : `ad.entreprise.com`) plutôt que `.local`/`.lan`.

### 2.5 Créer les OU, groupes et utilisateurs

**Étape 1 — l'Unité d'Organisation** : avant les groupes, créer une OU (avec le nom de domaine), puis des sous-OU avec les services.

| Terme Anglais | Terme Français | Définition |
|---|---|---|
| Forest | Forêt | Entité de plus haut niveau regroupant tous les domaines |
| Tree | Arbre | Ensemble de domaines partageant un espace de noms contigu |
| Domain Controller (DC) | Contrôleur de Domaine | Serveur qui gère les authentifications |
| Organizational Unit (OU) | Unité d'Organisation (UO) | « Dossier » où l'on range les objets pour leur appliquer des GPO |
| Group Policy Object (GPO) | Stratégie de Groupe | Règles de configuration appliquées aux UO |
| Security Group | Groupe de sécurité | Donner des droits sur des dossiers/ressources |
| Workstation | Poste de travail | Ordinateurs des utilisateurs |
| Trust Relationship | Approbation | Lien permettant aux utilisateurs d'un site d'accéder aux ressources d'un autre |

**Étape 2 — les groupes** : principe du **moindre privilège** (droits minimums).

**Méthode AGDLP** : Account (Users) > Global group > Domain Local group > Permissions.
- Un compte utilisateur est membre d'un **groupe de sécurité global (GG_)**.
- Ce groupe global est membre d'un **groupe de sécurité domaine local (GDL_)** (portée sur le domaine d'appartenance).
- Ce groupe domaine local sert à ajuster les **permissions NTFS** sur le répertoire partagé.

Exemple : pour 3 groupes (Comptabilité, Direction, Marketing), avec Direction qui lit tout et édite le sien, Compta qui édite le sien et consulte le marketing, Marketing qui édite le sien :

| Dossier Cible | Groupe pour LIRE (RO) | Groupe pour ÉDITER (RW) |
|---|---|---|
| Compta | GDL_Compta_RO | GDL_Compta_RW |
| Direction | GDL_Direction_RO | GDL_Direction_RW |
| Marketing | GDL_Marketing_RO | GDL_Marketing_RW |

On n'ajoute pas les utilisateurs dans les GDL, mais les Groupes Globaux (GG_Compta, etc.) dans les GDL. Ex : GG_Compta membre de GDL_Compta_RW ; GG_Direction membre de GDL_Compta_RO.

**Étape 3 — les utilisateurs** : créer les utilisateurs dans chaque groupe correspondant, vérifier les règles de mot de passe.

**En résumé AGDLP** : A (Account) tu crées l'utilisateur dans l'OU ; G (Global Group) tu crées GG_Secretariat et tu y mets l'utilisateur ; DL (Domain Local Group) tu crées GDL_Secretariat_RW et GDL_Secretariat_RO ; P (Permissions) tu appliques les droits NTFS aux groupes GDL.

**Créer un utilisateur (procédure)** :
1. Ouvrir `dsa.msc`
2. Naviguer vers l'OU cible
3. Clic droit → Nouvel utilisateur
4. Remplir : prénom, nom, logon (m.dupont@aerosud.local)
5. Définir un mot de passe temporaire
6. Cocher « L'utilisateur doit changer son mot de passe à la prochaine ouverture de session »
7. Ajouter l'utilisateur au groupe de sécurité correspondant

**Départ d'un employé (ordre des actions)** :
1. Désactiver le compte (ne pas supprimer immédiatement)
2. Révoquer les sessions actives (RDP, VPN)
3. Transférer les emails vers le manager
4. Déplacer le compte dans OU=Désactivés
5. Supprimer des groupes de sécurité
6. Après 30 jours : suppression définitive selon politique interne

### 2.6 Créer un partage de fichiers (File server)

**Étape 1 — disque dur dédié aux données** :
- *Option 1* : créer un disque virtuel sur VirtualBox (Configuration VM > Stockage > Add hard drive > VDI). Redémarrer > Gestion des disques > Initialiser > attribuer une lettre > Formater en NTFS.
- *Option 2* : partitionner le disque (réduire le disque, etc.).

**Étape 2 — dossiers + paramétrage NTFS** :
- Créer les dossiers correspondant aux sous-OU (dans un dossier « partages » : compta, direction, etc.) sur le disque D:.
- Pour chaque dossier, paramétrer les autorisations : Clic droit > Propriétés > Onglet **Sécurité** (droits NTFS, le plus important) > Modifier > Ajouter les GDL.
- **Bonne pratique** : dans l'onglet **Partage**, donner « Contrôle Total » à « Tout le monde ». La vraie sécurité se gère uniquement dans l'onglet **Sécurité (NTFS)** avec les groupes GDL (le système applique toujours l'autorisation la plus restrictive des deux).
- Ne pas oublier de **désactiver l'héritage** : Clic droit > Sécurité > Avancé > Désactiver l'héritage > « Convertir les autorisations héritées en autorisations explicites ».

### 2.7 Créer les GPO

- **Étape 1** : Outils > Gestion des stratégies de groupe > dérouler jusqu'à Objets de stratégie de groupe > Clic droit > Nouveau > nommer selon convention (`U_mappage_commercial`, U pour user / O pour ordinateur).
- **Étape 2** : la lier à une OU (glisser dessus) puis clic droit > APPLIQUER.
- **Étape 3** : Clic droit > Modifier > choisir et paramétrer la GPO.

**GPO à connaître** :
- *Mappage de lecteurs* : Configuration utilisateur └ Préférences └ Paramètres Windows └ Mappage de lecteurs (Drive Maps).
- *Stratégie de mot de passe* : Configuration Ordinateur └ Stratégies └ Paramètres Windows └ Paramètres de sécurité └ Stratégies de comptes └ Stratégie de mots de passe. (L'ANSSI recommande minimum 14 caractères robustes + complexes.)
- *Firewall* : Paramètres Windows > Paramètres de sécurité > Pare-feu Windows Defender (bloquer/autoriser port/IP).

**Mapper les lecteurs** : Clic droit sur la GPO > Modifier > Utilisateur > Préférences > Paramètres Windows > Mappage de lecteur > Nouveau lecteur mappé > coller l'adresse du dossier (Propriétés > Partage > Chemin réseau) > choisir une lettre en commençant par la fin (Z) > Afficher ce lecteur et Afficher tous les lecteurs. Sur le PC client : `gpupdate /force`. Tester en créant un document dans le dossier. *(Si un document créé par l'admin pose problème en édition RW, changer le propriétaire du fichier.)*

### 2.8 Connecter le PC client au domaine

- **Étape 1 (réseau)** : les deux VM (Serveur et Client) sur le même réseau NAT.
- **Étape 2 (DNS du client)** : se connecter avec l'utilisateur local, renommer le PC (ex : PC-client-01), `Win+R > ncpa.cpl > Propriétés > IPv4` > serveur DNS préféré = adresse IP du serveur. (Le client doit pointer vers le DNS du DC.) Activer la découverte de réseaux. Tester avec un ping serveur/client. Si problème : vérifier le pare-feu (`wf.msc` > Règles de trafic entrant > « Partage de fichiers et d'imprimantes (Demande d'écho - ICMPv4-Entrant) » > Autoriser).
- **Étape 3 (jonction au domaine)** : Clic droit Démarrer > Système > Paramètres système avancés > onglet Nom de l'ordinateur > Modifier > sélectionner Domaine et taper le nom (ex : tip.ofiaq ; si échec, nom NetBIOS court : TIP). Taper l'identifiant Administrateur + mot de passe du serveur. Redémarrer. Vérifier : se connecter avec un compte utilisateur, copier le chemin d'un dossier partagé (ex : `\\SRV-AD-01\commercial`) et le coller via Win+R sur le client.

### 2.9 Récapitulatif AD

| Terme | Définition simple |
|---|---|
| Domaine | Ensemble d'utilisateurs et d'ordinateurs gérés par un même AD (ex : aerosud.local) |
| Contrôleur de domaine (DC) | Serveur Windows Server qui héberge l'AD — cerveau du réseau |
| Unité d'organisation (OU) | Dossier virtuel pour organiser les objets AD |
| Groupe de sécurité | Ensemble d'utilisateurs auxquels on attribue les mêmes droits |
| GPO | Règle appliquée automatiquement à des utilisateurs/ordinateurs |

> Sans contrôleur de domaine fonctionnel, les utilisateurs ne peuvent plus s'authentifier. Toujours avoir au minimum 2 DC (redondance).

**Commandes essentielles AD :**

```
dsa.msc                              → Active Directory Users & Computers
gpmc.msc                             → Console de gestion des GPO
gpupdate /force                      → Forcer l'application immédiate des GPO
gpresult /r                          → Afficher les GPO appliquées au poste
dcdiag                               → Diagnostiquer l'état du contrôleur de domaine
nltest /sc_query:aerosud.local       → Vérifier la connexion au DC
```

## 3. Le déploiement et Windows Deployment Services

### 3.1 Introduction au déploiement et concepts clés

Le déploiement de postes consiste à installer et configurer rapidement plusieurs ordinateurs avec un système d'exploitation et des logiciels identiques. C'est essentiel en environnement professionnel pour gagner du temps et éviter les erreurs humaines, assurer l'homogénéité du parc informatique, et faciliter la maintenance et le support.

**Master vs Clone** — distinction cruciale :

- **Le Master (image de référence)** : système préparé spécifiquement pour être réutilisé et déployé à grande échelle proprement. Il est « dépersonnalisé » (généralisé).
- **Le Clone** : duplication brute (secteur par secteur) d'une machine existante. Il copie tout, y compris l'identité unique du PC. Moins adapté à un parc en réseau, sauf si la machine a été préalablement préparée.

> On **clone** une machine, on **déploie** un master. Le master est fait pour être réutilisé à grande échelle proprement ; le clone est une duplication brute, moins adaptée à un parc en réseau.

**Le clonage (outils locaux)** : copie intégralement un système (OS, logiciels, paramètres) d'une machine vers une ou plusieurs autres.
- **Clonezilla** : logiciel libre de référence pour cloner des disques ou des partitions. Très utilisé pour créer des images système locales et les restaurer.

### 3.2 Les méthodes de déploiement

Le choix de la méthode dépend du contexte (taille du parc, infrastructure réseau, flexibilité).

**Déploiement via supports bootables (petit parc / hors réseau)** — on utilise souvent une clé USB bootable :

| Outil | Caractéristiques |
|---|---|
| **Ventoy** | Clé USB multi-ISO : glisser-déposer plusieurs `.iso` pour avoir un menu de choix au démarrage. Idéal pour la boîte à outils d'un technicien. |
| **Rufus** | Simple et rapide pour créer une clé bootable d'un seul OS. Les versions récentes contournent les restrictions de Windows 11 (TPM 2.0, compte Microsoft) et suppriment les bloatwares. |
| **Easy2Boot** | Alternative à Ventoy pour clé multi-boot. Plus complexe à configurer mais plus flexible (supporte plus de formats : ISO, IMG, VHD...). Principalement hors réseau, sur clé USB. |

> Distinction clé : **Rufus** pour une clé simple et rapide, **Ventoy** et **Easy2Boot** pour une clé multi-ISO. Easy2Boot se différencie de Ventoy par sa compatibilité étendue avec les formats, au prix d'une configuration plus technique.

**Déploiement réseau via PXE (parc moyen à grand)** — le **PXE (Preboot Execution Environment)** permet de démarrer un ordinateur directement via la carte réseau, sans aucun support physique.

Principe du PXE :
1. Le poste démarre, la carte réseau est prioritaire.
2. Il envoie une requête en broadcast pour trouver un serveur DHCP et obtenir une adresse IP.
3. Le serveur DHCP lui fournit une IP et lui indique l'adresse du serveur de déploiement (**option DHCP 66**) et le fichier d'amorce (**option DHCP 67**). Pour que les options 66 et 67 fonctionnent, il faut souvent que le service DHCP et le service WDS ne soient pas sur le même serveur (conflit sur les ports), nécessitant de cocher des options spécifiques dans WDS (ne pas écouter sur le port 67).
4. Le poste télécharge le programme de démarrage via le protocole **TFTP**.
5. Il lance l'installation de l'OS via le réseau.

**Protocole TFTP** : quand une machine boote en PXE, elle obtient une IP via DHCP, puis télécharge le fichier de démarrage (`boot.wim`) depuis le serveur WDS via TFTP (Trivial File Transfer Protocol). C'est un protocole de transfert simplifié sur le port **UDP 69**, sans authentification. Utile pour le dépannage : si le boot PXE échoue après l'attribution IP, le problème vient souvent du TFTP (pare-feu qui bloque le port, mauvais chemin de fichier).

Avantages du PXE : déploiement simultané de dizaines de machines, gain de temps considérable, centralisation, aucune manipulation physique de clés USB.

**Automatisation du déploiement** : grâce à des fichiers de réponses (`unattended.xml`), on peut répondre automatiquement aux questions de l'installation (langue, partitionnement, nom du poste, etc.), permettant un déploiement sans intervention humaine (**Zero Touch Deployment**).

### 3.3 Les serveurs de déploiement

Ce sont les machines qui stockent et distribuent les images système sur le réseau.

| Outil | Description |
|---|---|
| **WDS (Windows Deployment Services)** | Solution native Microsoft. Très efficace pour les environnements Windows purs. Permet l'installation simultanée (multicast) de nombreuses machines. |
| **FOG Project** | Solution open-source : capture d'images système, déploiement multi-plateformes, gestion centralisée du parc (renommage auto, intégration domaine...). |
| **DISM** | *Deployment Image Servicing and Management*. Outil CLI intégré nativement à Windows pour manipuler les `.wim` : monter une image, ajouter drivers/MAJ, nettoyer, capturer, appliquer. C'est la brique technique sur laquelle WDS s'appuie en arrière-plan. |

**Unicast vs Multicast** : en *unicast*, WDS envoie l'image séparément à chaque machine — 20 postes = 20 flux distincts, beaucoup de bande passante consommée. En *multicast*, le serveur envoie un seul flux que toutes les machines reçoivent simultanément (comme une diffusion). C'est l'intérêt principal de WDS sur un grand parc : 50 machines reçoivent la même image en même temps sans saturer le réseau.

**DISM en TIP** intervient principalement dans deux situations : maintenir un master sans tout reconstruire (ajout de drivers, mises à jour) et diagnostiquer/réparer un Windows endommagé.

### 3.4 Le Master : création, stratégie et Sysprep

Le master conditionne la qualité de tout le parc. S'il est défaillant, tous les postes le seront.

**Choix de la version de Windows** :
- **Mises à jour (Updates)** : correctifs de sécurité et de bugs. Obligatoires, n'impactent pas la version de base.
- **Versions (Upgrades)** : changements majeurs (Windows 10 → 11, ou 21H2 → 22H2). Modifient les prérequis matériels.

Faut-il toujours le dernier Windows ? **Non.** Raisons : compatibilité matérielle (Windows 11 exige TPM 2.0 et un CPU récent), compatibilité logicielle (logiciels métiers certifiés), stabilité (attendre quelques mois après une sortie majeure), support (fin de vie — Windows 10 s'arrête en octobre 2025).

**Conseils avant de commencer le master** :
- Utiliser une machine virtuelle (VirtualBox, VMware) plutôt qu'une machine physique — plus facile à snapshotter, recommencer, transporter.
- Partir d'une ISO officielle Microsoft (VLSC ou Media Creation Tool), jamais d'une ISO téléchargée ailleurs.
- Choisir la bonne édition : Windows **Pro** ou **Entreprise**, jamais Home (pas de jonction de domaine, pas de GPO).

**Le cycle de vie du Master** :

1. **Installation de base** : installer un Windows propre sur une VM (recommandé) ou physique.
2. **Mode Audit** (`sysprep /audit`) : démarre Windows directement en administrateur sans passer par l'assistant OOBE. Exécutable : `C:\Windows\System32\Sysprep\sysprep.exe`. C'est dans ce mode qu'on finalise le contenu du master : logiciels, drivers, personnalisations. Tant qu'on est en mode audit, le système n'est pas généralisé (le SID est toujours présent).
3. **La Généralisation** (`sysprep /generalize /oobe /shutdown`) : étape **OBLIGATOIRE**. Sysprep dépersonnalise l'image et supprime le **SID** (identifiant de sécurité unique). Sans Sysprep, toutes les machines déployées auront le même SID → conflits dans un domaine Active Directory et problèmes d'authentification. La machine s'éteint d'elle-même à la fin.
4. **La Capture** : quand la machine est éteinte suite au Sysprep, on boote en PXE ou sur USB pour capturer l'image (via WDS ou Clonezilla).

> **Attention — Mode audit** : ne créez aucun compte utilisateur local en mode audit. Son profil serait capturé dans le master et se retrouverait sur toutes les machines déployées.

**Bonnes pratiques en mode audit** :
- Installer les logiciels dans l'ordre : drivers → mises à jour Windows → logiciels métier → **antivirus en dernier** (il peut bloquer les étapes suivantes).
- Le fond d'écran et les raccourcis du bureau de la session admin ne sont **pas** conservés (Sysprep efface les personnalisations de la session en cours). Pour contourner : placer les raccourcis dans le dossier public (`C:\Users\Public\Desktop`). Appliquer un fond d'écran après déploiement via GPO ou scripts.
- Ne jamais se connecter avec un compte Microsoft, ne jamais activer Windows à ce stade.
- Désactiver les applications inutiles (Cortana, OneDrive, Xbox...) et services non nécessaires — allège le master et réduit la surface d'attaque.
- Faire les mises à jour complètement avant Sysprep, redémarrer autant que nécessaire jusqu'à « Votre appareil est à jour ».

**Avant la capture** : vider les dossiers temporaires (`%temp%`, `C:\Windows\Temp`), vider la corbeille, désinstaller les logiciels de test, lancer un nettoyage de disque avec suppression des fichiers système, et vérifier qu'aucune mise à jour n'est en attente.

> **Première cause d'échec de Sysprep** : des mises à jour en attente. Windows considère le système comme instable et refuse la généralisation. Symptôme classique : Sysprep se lance puis s'interrompt avec une erreur dans `C:\Windows\System32\Sysprep\Panther\setupact.log`. Solution : laisser toutes les MAJ se terminer, redémarrer, vérifier qu'aucune n'est en attente, puis relancer Sysprep.

**Bonnes pratiques du master** :
- Créer un master par « profil » (Administratif, Technique). Ne pas tout mettre dans un seul master.
- Tester le master sur 2-3 machines avant déploiement en masse.
- Documenter ce qui est installé et sa version.
- Assurer la maintenance des postes déployés (MAJ, supervision, incidents, renouvellement). Mettre à jour le master régulièrement.
- Fixer une date de reconstruction : un master de plus de 12-18 mois accumule trop de dette technique. Mieux vaut en reconstruire un propre.

**Sécurité dans le master** : appliquer les MAJ, configurer le pare-feu, installer un antivirus, désactiver les services inutiles. Ne pas intégrer de données sensibles (comptes utilisateurs, mots de passe, certificats).

### 3.5 Flux PXE détaillé

**Étape 1 — le PC démarre en PXE**

Accès au BIOS au démarrage (selon fabricant : F2, F10, F12, Suppr ou Échap, souvent affiché brièvement au POST). Dans l'onglet **Boot** : trouver *Boot Device Priority* / *Boot Order*, activer *Network Boot / PXE Boot / LAN Boot* et le placer en première position. Dans *Advanced* / *Integrated Peripherals* : *Onboard LAN* sur Enabled, *Boot ROM / PXE ROM* activé.

**UEFI vs Legacy BIOS** :
- En mode UEFI, le boot PXE fonctionne nativement, mais le `boot.wim` de Windows 11 ne supporte que l'UEFI.
- En mode Legacy/BIOS, il faut utiliser un `boot.wim` de Windows 10 ou Windows Server.
- Si le parc est mixte, mieux vaut rester en Legacy ou activer le **CSM** (Compatibility Support Module) dans l'UEFI pour couvrir les deux cas.

**Secure Boot** : dans certains environnements, le Secure Boot bloque le démarrage PXE. Si le boot réseau échoue malgré une config correcte : *Security → Secure Boot → Disabled*. Sauvegarder (F10) et quitter.

**Étape 2 — le PC envoie une requête DHCP en broadcast**

Au démarrage en PXE, la machine n'a pas encore d'adresse IP : elle envoie un **broadcast** (message à tout le réseau, `255.255.255.255`).

La requête `DHCPDISCOVER` est un paquet UDP avec :
- IP source : `0.0.0.0` (pas encore d'IP)
- IP destination : `255.255.255.255` (broadcast)
- Port source : 68 (client DHCP) / Port destination : 67 (serveur DHCP)
- **Option 60** avec la valeur `PXEClient` : signale au serveur DHCP que la requête vient d'une machine PXE qui a besoin d'infos supplémentaires.

Le serveur répond (`DHCPOFFER`) avec : une IP disponible, le masque/passerelle/DNS, l'**option 66** (IP du serveur WDS / Next Server) et l'**option 67** (nom du fichier à télécharger : `boot.wim` ou `boot\x64\wdsnbp.com`). Le client confirme (`DHCPREQUEST → DHCPACK`) puis utilise les options 66/67 pour contacter le serveur TFTP.

> **Dépannage fréquent** — si le client PXE affiche `DHCP...` puis échoue sans obtenir d'IP : le serveur DHCP n'est pas démarré ou pas sur le même réseau ; les options 66/67 ne sont pas configurées ; un pare-feu bloque les ports 67/68 ; le serveur DHCP est sur un autre sous-réseau sans IP Helper (agent relais DHCP) sur le routeur.

**Les options DHCP 66 et 67 en PXE** :
- **Option 66 — Next Server** : adresse IP du serveur TFTP (en WDS, l'IP du serveur WDS). « Va chercher ton fichier de boot chez cette machine. » Ex : `192.168.1.1`.
- **Option 67 — Boot File Name** : nom et chemin du fichier de démarrage à télécharger via TFTP. « Le fichier à télécharger s'appelle ça. » Ex : `boot\x64\wdsnbp.com` ou `boot.wim`.

Sans l'option 66 → le client ne sait pas à qui parler. Sans l'option 67 → il ne sait pas quoi demander. Les deux sont obligatoires.

*Configuration dans Windows Server* : console DHCP → clic droit sur l'étendue → Options d'étendue → Configurer les options → cocher 066 et 067, renseigner les valeurs. Si le client obtient une IP mais que le boot PXE échoue avec un timeout TFTP, vérifier d'abord les options 66/67.

**Étape 3 — pourquoi TFTP utilise UDP et pas TCP**

TFTP est conçu pour être le plus simple possible : il doit fonctionner dans un environnement contraint (machine qui vient de s'allumer, sans OS, sans pile réseau complète, seulement le firmware de la carte réseau). TCP est trop lourd (handshake 3 étapes, retransmission, contrôle de flux, séquençage) — trop de mémoire et de code que le firmware n'a pas. UDP est sans connexion : on envoie un paquet, point. TFTP gère lui-même les accusés de réception (ACK) bloc par bloc.

> En résumé : UDP est choisi non pas parce que c'est optimal, mais parce que c'est le minimum viable pour un contexte aussi bas niveau.

**Si le port UDP 69 est bloqué** : le client a déjà son IP et les options 66/67, mais ne peut pas joindre le serveur TFTP. Symptôme à l'écran :
```
PXE-E32: TFTP open timeout   ou   PXE-E35: TFTP read timeout
```
Diagnostic (sur le serveur Windows) :
```
netsh advfirewall firewall show rule name=all | findstr TFTP
```
Si aucune règle n'apparaît, créer une règle entrante :
```
netsh advfirewall firewall add rule name="TFTP PXE" protocol=UDP dir=in localport=69 action=allow
```
WDS crée normalement cette règle automatiquement, mais elle peut être désactivée/supprimée par une GPO. Autre cause : si le chemin du fichier (option 67) est incorrect, TFTP s'ouvre mais répond `PXE-E23: Client received TFTP error from server` (problème de chemin du `boot.wim`, pas de pare-feu).

**Étape 4 — le rôle de Windows PE**

**Windows PE (Preinstallation Environment)** est un OS minimal basé sur Windows, contenu dans le `boot.wim`. Il ne sert pas à travailler au quotidien — uniquement à préparer et lancer le déploiement. Une fois chargé en RAM, la machine a un OS minimaliste qui peut : parler au réseau (récupérer `install.wim`), accéder aux disques (partitionner, formater, écrire), exécuter des scripts (`unattend.xml`), charger des drivers.

Il embarque : **DISM** (appliquer `install.wim`), **diskpart** (partitionner/formater), **wpeinit** (initialise le réseau), **wpeutil** (utilitaires de base), un shell CMD minimal. Pas d'interface graphique complète, pas de navigateur.

**boot.wim vs install.wim** — confusion fréquente :

| | boot.wim | install.wim |
|---|---|---|
| Contient | Windows PE | Windows complet |
| Rôle | Lance le déploiement | Est déployé sur le poste |
| Taille | ~500 Mo | 3 à 5 Go |
| Chargé via | TFTP | WDS (réseau) |

> Le `boot.wim` est le **livreur**, l'`install.wim` est le **colis**.

Windows PE tourne uniquement en RAM pendant le déploiement. Une fois `install.wim` appliqué et la machine redémarrée, Windows PE disparaît — il n'est jamais installé sur le poste final.

**Étape 5 — le multicast WDS pour envoyer install.wim**

Sans multicast, WDS fonctionne en *unicast* : une copie séparée de `install.wim` par client (20 machines = 20 flux = saturation). Le **multicast** fonctionne comme une diffusion TV : le serveur envoie un seul flux, toutes les machines abonnées le reçoivent simultanément.

```
Unicast    → Serveur ──► Client 1
             Serveur ──► Client 2
             Serveur ──► Client 3   (3 flux distincts)

Multicast  → Serveur ──► [groupe multicast] ──► Client 1
                                              ──► Client 2
                                              ──► Client 3   (1 seul flux)
```

Techniquement : le serveur crée une session multicast associée à une image. Les clients qui bootent en PXE rejoignent la session via une **adresse IP multicast** (plage `224.0.0.0` à `239.255.255.255`). Le serveur envoie les blocs de `install.wim` une seule fois vers cette adresse.

**Deux modes de transfert multicast** :
- **Auto-Cast** : le transfert démarre dès qu'un premier client est prêt, les suivants rejoignent le flux en cours. Les retardataires ratent les blocs déjà envoyés et doivent les récupérer séparément.
- **Scheduled-Cast** : le serveur attend un nombre minimum de clients ou une heure précise avant de démarrer. Tous reçoivent l'image depuis le début. **Mode recommandé** pour déployer un parc entier en une fois.

**Prérequis réseau** : le multicast nécessite que les switchs supportent l'**IGMP** (Internet Group Management Protocol), qui permet aux switchs de savoir quels ports appartiennent au groupe multicast. Sans IGMP, le flux multicast se comporte comme un broadcast et surcharge le réseau (l'effet inverse recherché).

*Configuration* : console WDS → clic droit sur *Transmissions par multidiffusion* → Nouvelle transmission → choisir l'image → Auto-Cast ou Scheduled-Cast.

### 3.6 Cas pratique : mise en place d'un serveur WDS

Pour faire du déploiement PXE avec Windows Server, on a besoin de deux rôles : **DHCP** et **WDS**.

> **Conflit de port 67** : si DHCP et WDS sont sur la même machine, ils se battent pour écouter le port UDP 67. Dans les propriétés du serveur WDS, onglet *DHCP*, cocher impérativement : « Ne pas écouter sur le port DHCP (67) » ET « Configurer l'option DHCP 60 » (indique que ce serveur est aussi un serveur PXE). Cette config s'applique partout, y compris en production. Ce n'est pas une limitation de VirtualBox : un port réseau ne peut pas être utilisé par deux applications en même temps.

**Étape 1 — le prérequis (serveur DHCP)** :
1. Préparation : renommer le PC (ex : `SRV-DEPLOIEMENT`), IP fixe, vérifier le raccordement réseau.
2. Installation : ajouter le rôle « Serveur DHCP ».
3. Configuration (nouvelle étendue IPv4) : DHCP → clic IPv4 → Actions → Nouvelle étendue.
   - Définir une plage d'IP (ex : `192.168.1.50` à `192.168.1.150`).
   - Exclure l'IP du serveur lui-même.
   - Renseigner la passerelle (le routeur).
   - Le DHCP distribuera aussi les options 66 (IP du serveur WDS) et 67 (nom du fichier de boot).

**Étape 2 — installation et configuration de WDS** :
1. Ajouter le rôle « Services de déploiement Windows » (WDS).
2. Configuration : clic droit sur le serveur → Configurer le serveur.
   - Créer le dossier d'installation (ex : `E:\RemoteInstall`) sur un **second disque dur** (50 Go min) formaté en NTFS, pas sur le C:.
   - Choisir « Serveur autonome » sans Active Directory. (En production, les postes sont généralement intégrés à un domaine AD pour la gestion centralisée — le déploiement peut intégrer automatiquement les machines au domaine après installation.)
   - Sélectionner « Répondre à tous les ordinateurs clients (connus et inconnus) ».
3. Démarrage : clic droit sur le serveur → Toutes les tâches → Démarrer.

**Étape 3 — ajout des images système (.wim)** : monter une ISO de Windows pour récupérer deux fichiers du dossier `Sources` :
1. **L'image de démarrage (`boot.wim`)** : le mini-système (Windows PE) qui charge l'assistant via le réseau.
   - *Le `boot.wim` de Windows 11 ne supporte pas le PXE en mode Legacy/BIOS, uniquement l'UEFI. Utiliser un `boot.wim` de Windows 10 ou Windows Server pour de vieilles machines BIOS ou sur VirtualBox.*
   - Trouver le `boot.wim` : clic droit sur l'ISO → ouvrir avec l'explorateur → dossier `Sources` → copier le fichier → l'importer depuis *Images de démarrage* du serveur WDS.
2. **L'image d'installation (`install.wim`)** *(à ne pas faire dans le cadre de la capture du Master)* : le système d'exploitation complet à déployer. Même emplacement (`Sources` de l'ISO). Dans WDS, s'ajoute séparément dans *Images d'installation*. Sans lui, WDS peut booter les machines mais n'a rien à installer.

*Option pour éviter d'appuyer sur F12 :* clic droit sur le serveur WDS → Propriétés → Démarrer → « Continuer le démarrage PXE sauf si l'utilisateur appuie sur Échap ».

**Étape 4 — capturer un master avec WDS** : le PC client a été préparé et `sysprep /generalize /oobe /shutdown` lancé, la machine est éteinte.
1. Console WDS → *Images de démarrage*.
2. Clic droit sur le `boot.wim` existant → Créer une image de capture.
3. Parcourir jusqu'à `E:\RemoteInstall\Boot\x64\Images\` → sélectionner `boot.wim`.
4. Le renommer `capture.wim` et valider. WDS l'ajoute à la liste des images de démarrage.
5. Désactiver le `boot.wim` (ou « Microsoft Windows Setup ») pour éviter toute confusion au boot PXE.
6. Modifier l'ordre de boot du PC client (réseau en premier).
7. Allumer le PC client (sysprepé) et booter en PXE → il boote directement sur `capture.wim`.
8. Un assistant « aspire » le disque dur du PC client et l'envoie sur le serveur WDS comme nouvelle image d'installation. Connexion au serveur : nom de l'ordinateur du serveur, utilisateur `nomduserveur\Administrateur`, mot de passe. Le groupe d'images doit avoir été créé au préalable (vide) dans *Images d'installation*.

> **L'image de capture se crée à partir du `boot.wim` existant sur le serveur — pas à partir d'un `install.wim` d'ISO Windows 11.** La capture peut prendre 20 à 45 minutes (voire plusieurs heures) selon la taille. Ne pas interrompre.

**Étape 5 — déployer le master** :
- Réactiver l'image de démarrage originale (clic droit sur l'image « Setup » → Activer) ; désactiver l'image « Capture » pour ne pas avoir à choisir.
- Créer une VM vide (sans ISO) avec les besoins classiques de Windows 11 : 4 Go de RAM, 50 Go de stockage, 2 cœurs. Sur le même réseau NAT que le serveur. Ordre de boot : Disque dur puis réseau.
- Lancer la VM : elle boote en PXE et charge le `boot.wim`.
- Se connecter (`nomdeserveur\Compte`), sélectionner le bon master.
- Définir le partitionnement et procéder à l'installation classique (OOBE...).

> *En production, prévoir un utilisateur dédié au déploiement plutôt que le compte administrateur, surtout pour automatiser ensuite.*

**Étape 6 — automatisation du déploiement WDS via fichiers de réponses (XML)** : supprimer toute intervention humaine grâce à des fichiers de réponses générés par **Windows ADK**.
- Ouvrir le Gestionnaire d'installation (Windows System Image Manager). Placer l'ISO de Windows 11 (pas du master) dans un dossier, copier le `install.wim` dans un dossier local, l'ajouter via Fichier → Sélectionner l'image Windows. Créer un « fichier catalogue » quand demandé.
- **Automatisation de WinPE (passe 1 : windowsPE)** : langue de l'interface d'installation (fr-FR), partitionnement (disque cible ID 0, `WillWipeDisk`, partition principale, lettre C:), identifiants de connexion WDS et sélection de l'image.
- **Automatisation de l'OOBE (passe 7 : oobeSystem)** : masquer les pages de config (EULA, Cortana, vie privée, publicités), création automatique d'un compte local et mot de passe, fuseau horaire et langue.
- **Application** : le fichier XML est lié dans les Propriétés de l'image d'installation (clic droit dans la console WDS).

> **Note UEFI** : pour les parcs UEFI, la structure du partitionnement dans le XML diffère (partition EFI en FAT32 de 100 Mo avant la partition principale). Vérifier UEFI vs BIOS via `msinfo32` ou la config de la VM.

## 4. Gestion des mises à jour — WSUS

**WSUS (Windows Server Update Services)** est un rôle Windows Server qui centralise la gestion des mises à jour de tous les postes du parc.

- **Sans WSUS** : chaque PC télécharge ses MAJ directement depuis Microsoft → bande passante saturée, MAJ non contrôlées, postes hétérogènes.
- **Avec WSUS** : un seul serveur récupère les MAJ, l'administrateur les valide, puis les distribue de façon planifiée.

```
Serveurs Microsoft
     ↓
Serveur WSUS (télécharge et stocke les MAJ)
     ↓ (après validation par l'admin)
Tous les postes du domaine
```

**Patch Tuesday** : Microsoft publie ses MAJ de sécurité le **2ᵉ mardi de chaque mois**. C'est la référence pour planifier les déploiements WSUS.

> **Bonne pratique** : tester les MAJ sur un groupe pilote (5-10 postes) avant de les déployer à tout le parc. Une MAJ mal testée peut casser une application métier.

**Paramétrage via GPO** :
```
Configuration Ordinateur
 → Modèles d'administration
 → Composants Windows
 → Windows Update
 → Spécifier l'emplacement intranet du service de mise à jour Microsoft
   → http://nom-serveur-wsus:8530
```

**Ciblage côté client (Client-Side Targeting)** : option GPO qui indique à un PC de se connecter au serveur WSUS en se déclarant membre d'un groupe (ex : « Comptabilité ») pour recevoir les MAJ validées pour ce groupe. Indispensable pour gérer les groupes pilotes.

## 5. Bureau à distance — RDP

**RDP (Remote Desktop Protocol)** permet de prendre le contrôle graphique d'un PC ou serveur Windows à distance. **Port : 3389 (TCP)**.

**Activer le bureau à distance** : Paramètres → Système → Bureau à distance → Activer. Ou via PowerShell :
```powershell
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Bureau à distance"
```

**Se connecter** :
```
mstsc                          → Ouvre le client Bureau à distance
mstsc /v:192.168.1.10          → Connexion directe à une IP
mstsc /v:192.168.1.10 /admin   → Mode administration (session console)
```

**Sécurisation RDP** :

| Bonne pratique | Pourquoi |
|---|---|
| Changer le port 3389 | Réduit les scans automatiques (bots cherchent le 3389) |
| Activer le NLA (Network Level Authentication) | Authentification avant ouverture de session |
| Passer par un VPN | RDP ne doit jamais être exposé directement sur Internet |
| Limiter les utilisateurs autorisés | Groupe « Utilisateurs du Bureau à distance » uniquement |

> **RDP directement exposé sur Internet = cible n°1 des ransomwares.** En 2024, c'est encore la première porte d'entrée des attaques. Toujours passer par un VPN ou un bastion SSH.

## 6. BitLocker — Chiffrement des postes

**BitLocker** est l'outil de chiffrement intégré à Windows (éditions Pro, Entreprise et Éducation). Il chiffre intégralement le contenu d'un disque dur. Si un PC est volé ou le disque extrait physiquement, les données sont illisibles sans la clé de déchiffrement.

> BitLocker n'est **pas** disponible sur Windows Home.

**Prérequis matériel** :
- Puce **TPM 2.0** (Trusted Platform Module) — présente sur la quasi-totalité des machines depuis 2016.
- Sans TPM : BitLocker peut fonctionner avec une clé USB de démarrage, mais c'est moins pratique.

**Activer BitLocker** : Panneau de configuration → Système et sécurité → Chiffrement de lecteur BitLocker → Activer sur C: → choisir le mode de déverrouillage (TPM automatique recommandé) → **sauvegarder la clé de récupération (obligatoire)**. Ou via PowerShell :
```powershell
Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256 -TpmProtector
```

**La clé de récupération** — point critique : code à 48 chiffres généré à l'activation. Indispensable si le TPM détecte une modification matérielle (changement de carte mère, BIOS mis à jour), si l'utilisateur a oublié son PIN, ou si le disque est branché sur une autre machine.

| Où stocker la clé | Recommandation |
|---|---|
| Compte Microsoft | Acceptable pour les particuliers |
| Active Directory (AD) | Standard entreprise — clé centralisée sur le DC |
| Fichier local sur le même PC | Inutile — si le PC est volé, la clé aussi |
| Impression papier dans un coffre | Acceptable en complément |

**Sauvegarde automatique dans Active Directory** (via GPO) :
```
Configuration Ordinateur
 → Modèles d'administration
 → Composants Windows
 → Chiffrement de lecteur BitLocker
 → Lecteurs du système d'exploitation
 → « Choisir comment les lecteurs OS protégés par BitLocker peuvent être récupérés »
   → Cocher « Sauvegarder les informations de récupération BitLocker dans les services AD »
```
Résultat : dès qu'un poste active BitLocker, la clé est stockée dans l'objet ordinateur dans l'AD. Récupération : `dsa.msc` → clic droit sur le PC → Propriétés → onglet Récupération BitLocker.

**Vérifier l'état du chiffrement** :
```
manage-bde -status        → État de tous les lecteurs
manage-bde -status C:     → État du lecteur C: uniquement
```

> **Terrain** : « Mon PC me demande une clé de récupération BitLocker au démarrage. » Causes fréquentes : MAJ du BIOS la nuit précédente, changement de composant matériel, modification de l'ordre de boot. Réflexe : récupérer la clé dans l'AD (`dsa.msc`) → la communiquer → investiguer pourquoi le TPM a été déclenché.

## 7. Gestion des droits et partages (NTFS)

**NTFS vs Partage réseau** — deux niveaux de permissions :

| | Permissions NTFS | Permissions de partage |
|---|---|---|
| S'appliquent | Sur le disque local ET en réseau | Uniquement en accès réseau |
| Granularité | Très fine (lecture, écriture, modification, contrôle total...) | Simple (Lecture, Modification, Contrôle total) |
| En cas de conflit | La permission la plus restrictive gagne | La permission la plus restrictive gagne |
| Recommandation | Gérer finement via NTFS | Mettre « Contrôle total » au partage, affiner via NTFS |

> **Règle terrain** : donner « Contrôle total » au niveau du partage réseau, puis tout gérer via les permissions NTFS. Une seule couche à maintenir.

**Créer un partage réseau** : Clic droit sur le dossier → Propriétés → Partage → Partage avancé → cocher « Partager ce dossier » → nommer le partage (ex : `Compta$` — le `$` le rend invisible dans l'explorateur) → onglet Sécurité → modifier les permissions NTFS.

**Permissions NTFS essentielles** :

| Permission | Ce qu'elle permet |
|---|---|
| Lecture | Voir et ouvrir les fichiers |
| Lecture et exécution | + lancer les programmes |
| Modification | + créer, modifier, supprimer |
| Contrôle total | Tout + modifier les permissions |

> Ne jamais donner le Contrôle total à « Tout le monde ». Toujours assigner les droits aux **groupes AD**, jamais aux utilisateurs individuels.

## 8. Observateur d'événements

L'**Observateur d'événements** (`eventvwr.msc`) est le journal centralisé de Windows. Il enregistre tout ce qui se passe : connexions, erreurs, avertissements, installations, pannes. Ouvrir via `Win+R` → `eventvwr.msc`.

**Les journaux essentiels** :

| Journal | Contenu |
|---|---|
| Système | Erreurs matérielles, pilotes, services Windows |
| Application | Erreurs des logiciels installés |
| Sécurité | Connexions réussies/échouées, modifications de comptes (audit) |
| Installation | Historique des MAJ et installations |

**Niveaux d'événements** : Information (événement normal) / Avertissement (problème potentiel à surveiller) / Erreur (service ou application en échec) / Critique (panne grave, crash système, perte de données).

**IDs d'événements à connaître** :

| ID | Journal | Signification |
|---|---|---|
| 4624 | Sécurité | Connexion réussie |
| 4625 | Sécurité | Échec de connexion (mauvais mot de passe) |
| 4740 | Sécurité | Compte verrouillé |
| 4648 | Sécurité | Tentative de connexion avec identifiants explicites |
| 41 | Système | Redémarrage inattendu (crash, coupure) |
| 6008 | Système | Arrêt brutal précédent |
| 1074 | Système | Redémarrage planifié (qui a redémarré et pourquoi) |

> **Réflexe terrain** : « mon PC a redémarré tout seul » → `eventvwr.msc` → Journal Système → filtrer sur les ID 41 et 6008 → la cause en 2 minutes.

## 9. Gestionnaire de tâches et performances

Raccourci : **Ctrl+Maj+Échap** (ou clic droit sur la barre des tâches).

| Onglet | Usage terrain |
|---|---|
| Processus | Identifier quel programme consomme CPU/RAM — tuer un processus bloqué |
| Performances | Vue graphique CPU, RAM, disque, réseau en temps réel |
| Démarrage | Gérer les programmes lancés au démarrage (ralentissement au boot) |
| Utilisateurs | Voir les sessions actives — déconnecter un utilisateur fantôme |
| Détails | PID, priorité des processus — niveau avancé |

**Moniteur de ressources** (`resmon`) : plus précis que le Gestionnaire de tâches. Permet de voir exactement quels fichiers sont ouverts par quel processus, quelle IP est contactée par quelle application — indispensable pour diagnostiquer un ralentissement ou un comportement suspect.

**Seuils d'alerte terrain** :

| Ressource | Normal | À surveiller | Critique |
|---|---|---|---|
| CPU | < 30 % | 30-70 % | > 80 % en continu |
| RAM | < 70 % | 70-85 % | > 90 % (pagination disque) |
| Disque | < 20 % | 20-50 % | > 80 % en continu |

> Un disque à 100 % en continu sur un HDD = symptôme classique d'un disque mourant ou d'un malware. Premier réflexe : Gestionnaire de tâches → Performances → Disque → identifier le processus responsable.

## 10. Registre Windows

Le **registre Windows** (`regedit`) est la base de données centrale de configuration du système : tous les paramètres de Windows, des logiciels et des utilisateurs. Ouvrir via `Win+R` → `regedit` (droits admin requis).

> Le registre est sensible. Une mauvaise modification peut rendre Windows inutilisable. **Toujours exporter une sauvegarde avant toute modification** : Fichier → Exporter.

**Les 5 ruches principales** :

| Ruche | Contenu |
|---|---|
| HKEY_LOCAL_MACHINE (HKLM) | Configuration matérielle et logicielle de la machine (tous utilisateurs) |
| HKEY_CURRENT_USER (HKCU) | Configuration spécifique à l'utilisateur connecté |
| HKEY_CLASSES_ROOT (HKCR) | Associations de fichiers et COM (extensions → logiciels) |
| HKEY_USERS (HKU) | Profils de tous les utilisateurs du système |
| HKEY_CURRENT_CONFIG (HKCC) | Configuration matérielle active au démarrage |

**Clés utiles** :
```
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
  → Programmes lancés au démarrage pour tous les utilisateurs
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
  → Programmes lancés au démarrage pour l'utilisateur courant
HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\fDenyTSConnections
  → Activer/désactiver RDP (0 = activé, 1 = désactivé)
```

> Le registre est souvent utilisé par les malwares pour assurer leur persistance (clé Run). C'est l'un des premiers endroits à vérifier lors d'une analyse de poste suspect.

## 11. Réparation Windows — SFC et DISM

Deux outils natifs permettent de détecter et réparer les fichiers système corrompus sans réinstaller l'OS. Ils sont complémentaires et s'utilisent dans un ordre précis.

**SFC — System File Checker** : analyse et répare les fichiers système Windows corrompus en les comparant à une copie de référence.
```
sfc /scannow
```
À exécuter dans un terminal en tant qu'administrateur (5 à 15 minutes).

| Résultat affiché | Signification |
|---|---|
| « Aucune violation d'intégrité détectée » | Fichiers système OK |
| « WRP a trouvé des fichiers corrompus et les a réparés » | Réparation réussie |
| « WRP a trouvé des fichiers corrompus mais n'a pas pu les réparer » | L'image de référence est corrompue → utiliser DISM |

**DISM — Deployment Image Servicing and Management** : répare l'image Windows elle-même (le store de composants). À utiliser quand SFC échoue.
```powershell
DISM /Online /Cleanup-Image /CheckHealth     → Vérification rapide (non destructive)
DISM /Online /Cleanup-Image /ScanHealth      → Analyse complète (10-20 min)
DISM /Online /Cleanup-Image /RestoreHealth   → Réparation (télécharge depuis Windows Update)
```
> `/RestoreHealth` nécessite une connexion Internet (il télécharge les fichiers de remplacement depuis Microsoft).

**Ordre d'utilisation correct** :
```
Étape 1 : sfc /scannow
   ↓ Si échec ou erreurs non réparées
Étape 2 : DISM /Online /Cleanup-Image /RestoreHealth
   ↓ Une fois DISM terminé
Étape 3 : sfc /scannow (relancer pour vérifier)
   ↓ Si toujours des erreurs
Étape 4 : Réparer Windows via ISO (démarrage sur support)
```

> **Terrain** : un PC qui plante aléatoirement, des erreurs au démarrage, des applications qui crashent → commencer par `sfc /scannow` avant toute réinstallation. Résout environ 30 % des cas sans intervention lourde.

## 12. Planificateur de tâches — Task Scheduler

Le **Planificateur de tâches** (`taskschd.msc`) exécute automatiquement des programmes, scripts ou commandes selon un déclencheur : heure fixe, événement système, connexion d'un utilisateur, démarrage de Windows.

| Déclencheur | Usage typique |
|---|---|
| À une heure précise | Lancer une sauvegarde chaque nuit à 2h |
| Au démarrage de Windows | Lancer un script de configuration réseau |
| À la connexion d'un utilisateur | Mapper des lecteurs, synchroniser des fichiers |
| Sur événement Windows | Déclencher une alerte si l'ID 4625 est détecté |
| À la création d'une session | Nettoyer les fichiers temporaires |

**Créer une tâche planifiée** : `taskschd.msc` → Bibliothèque → Clic droit → Créer une tâche de base (assistant) ou Créer une tâche (options complètes) → onglet Général (nom, compte d'exécution) → Déclencheurs → Actions (programme/script) → Conditions (réseau, batterie) → Paramètres (relance si échec).

**Via PowerShell** :
```powershell
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File C:\scripts\sauvegarde.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At "02:00"
Register-ScheduledTask -TaskName "Sauvegarde nocturne" -Action $action -Trigger $trigger -RunLevel Highest -User "SYSTEM"
```

**Bonnes pratiques** :
- Exécuter les tâches sensibles sous le compte **SYSTEM** ou un compte de service dédié — jamais sous un compte utilisateur nominatif (si le compte est désactivé, la tâche ne s'exécute plus).
- Activer la journalisation (onglet Paramètres).
- Tester manuellement avant de planifier : clic droit sur la tâche → Exécuter.

> Les malwares utilisent fréquemment le Planificateur de tâches pour la persistance — comme la clé Run du registre. C'est le deuxième endroit à vérifier lors d'une analyse de poste suspect.

**Vérifier en ligne de commande** :
```powershell
Get-ScheduledTask                                              → Lister toutes les tâches
Get-ScheduledTask | Where-Object {$_.State -eq "Ready"}        → Tâches actives
Get-ScheduledTaskInfo -TaskName "Sauvegarde nocturne"          → Dernière exécution et résultat
Unregister-ScheduledTask -TaskName "Tâche suspecte" -Confirm:$false
```

## 13. PowerShell — Introduction

**PowerShell** est le shell et langage de script de Microsoft. Il remplace l'invite de commandes (`cmd`) pour l'administration système. Tout ce qui se fait en interface graphique peut se faire en PowerShell — souvent plus vite, et sur 1000 machines à la fois.

Ouvrir en administrateur : `Win+X` → Windows PowerShell (Admin), ou rechercher « powershell » → Exécuter en tant qu'administrateur.

**Commandes essentielles** :
```powershell
Get-Command                                       → Lister toutes les commandes disponibles
Get-Help <commande>                               → Aide sur une commande
Get-Help Get-Process -Examples                    → Exemples d'utilisation
Get-Process                                       → Lister les processus actifs
Stop-Process -Name "notepad"                      → Tuer un processus par nom
Stop-Process -Id 1234                             → Tuer un processus par PID
Get-Service                                        → Lister les services Windows
Start-Service -Name "wuauserv"                    → Démarrer le service Windows Update
Stop-Service -Name "wuauserv"                      → Arrêter un service
Restart-Service -Name "spooler"                   → Redémarrer le spouleur d'impression
Get-EventLog -LogName System -Newest 20           → 20 derniers événements système
Get-EventLog -LogName Security -InstanceId 4625   → Tous les échecs de connexion
Test-NetConnection -ComputerName google.fr -Port 443  → Tester un port réseau
Get-NetIPConfiguration                            → Équivalent de ipconfig /all
Resolve-DnsName google.fr                         → Résolution DNS
Restart-Computer                                   → Redémarrer
Stop-Computer                                      → Éteindre
```

**Automatisation — exemple** (rapport des comptes AD désactivés) :
```powershell
Import-Module ActiveDirectory
Get-ADUser -Filter {Enabled -eq $false} -Properties * |
  Select-Object Name, SamAccountName, LastLogonDate |
  Export-Csv -Path "C:\rapports\comptes_desactives.csv" -Encoding UTF8
```

> **PowerShell + Active Directory** = combinaison la plus puissante pour l'administration Windows. Un script de 5 lignes peut créer 200 comptes utilisateurs en quelques secondes là où l'interface graphique prendrait des heures.

**Récapitulatif — commandes et outils d'administration Windows** :

| Outil / Commande | Rôle |
|---|---|
| `dsa.msc` | Active Directory Users & Computers |
| `gpmc.msc` | Console GPO |
| `gpupdate /force` | Forcer les GPO |
| `eventvwr.msc` | Observateur d'événements |
| `regedit` | Registre Windows |
| `resmon` | Moniteur de ressources |
| `mstsc` | Bureau à distance (RDP) |
| `services.msc` | Gestionnaire de services |
| `compmgmt.msc` | Gestion de l'ordinateur (tout-en-un) |
| `taskmgr` | Gestionnaire de tâches |
| `msconfig` | Configuration du système (démarrage) |
| `diskmgmt.msc` | Gestion des disques |
| `taskschd.msc` | Planificateur de tâches |
| `sfc /scannow` | Réparation fichiers système |
| `manage-bde` | Gestion BitLocker |

> **Réflexe diagnostic Windows** : `eventvwr` → Gestionnaire des tâches → `resmon`. Dans cet ordre, on couvre 80 % des pannes courantes.

## 14. Gestion et dépannage des imprimantes

Le dépannage des imprimantes (et copieurs multifonctions — MFP) représente environ **20 à 30 % des tickets** en support de proximité.

### 14.1 Imprimante locale vs imprimante réseau

- **Imprimante locale** : branchée directement en USB sur un PC. Seul ce PC peut imprimer. Si le PC est éteint, personne d'autre ne peut l'utiliser, même « partagée », car c'est le PC hôte qui gère le spouleur.
- **Imprimante réseau** : branchée en RJ45 (ou Wi-Fi) directement sur le switch. Elle possède sa propre adresse IP. C'est le standard en entreprise.

### 14.2 Le spouleur d'impression (Print Spooler)

Service Windows qui met les documents en file d'attente, les traduit dans un langage compréhensible par l'imprimante, et les envoie un par un. S'il plante, toute l'impression sur le PC est paralysée.

> **Réflexe terrain (débloquer une file coincée)** : si un document affiche « En cours de suppression... » pendant des heures et bloque tout le reste, redémarrer l'imprimante ne sert à rien (le blocage est sur le PC). Un simple redémarrage du service échoue souvent sur les files corrompues. Il faut vider manuellement le dossier de spool (PowerShell admin) :
> ```powershell
> Stop-Service -Name Spooler -Force
> Remove-Item -Path "C:\Windows\System32\spool\PRINTERS\*" -Force
> Start-Service -Name Spooler
> ```

### 14.3 Le piège du port WSD

Lorsqu'on ajoute une imprimante réseau via les « Paramètres Windows », Windows crée souvent un port **WSD (Web Services for Devices)** au lieu d'un port TCP/IP standard.

- **Le problème** : le WSD est instable. Si l'imprimante se met en veille, Windows perd la connexion et l'imprimante apparaît « Hors connexion », même si elle fonctionne très bien.

**Bonne pratique de déploiement** :
1. **Fixer l'IP** de l'imprimante (via son interface web en IP statique, ou via une réservation DHCP — plus facile à gérer centralement).
2. **Installer manuellement** via Panneau de configuration → Périphériques et imprimantes → Ajouter une imprimante → Ajouter manuellement → Créer un nouveau port → **Standard TCP/IP Port** → renseigner l'IP fixe. Cela ne plantera jamais.

**Méthodes pour trouver l'IP d'une imprimante réseau** :
1. Imprimer la page de configuration (bouton physique).
2. Panneau de l'imprimante → Menu réseau → Infos TCP/IP.
3. Scanner le réseau : `arp -a` dans cmd → chercher l'adresse MAC du fabricant.
4. Logiciels constructeurs (HP Device Manager, Xerox CentreWare, Ricoh Web Image Monitor).

### 14.4 Langages d'impression et pilotes (Drivers)

Pour qu'un PC parle à une imprimante, il lui faut un pilote.

- **PCL (Printer Command Language)** : standard universel (souvent PCL6). Rapide, excellent pour la bureautique (Word, Excel, PDF texte).
- **PostScript (PS)** : traitement plus complexe, mais qualité de rendu supérieure pour les éléments graphiques et la colorimétrie. Indispensable pour les services communication/marketing (suite Adobe : Illustrator, InDesign).

**L'Universal Print Driver (UPD)** : en entreprise, on n'installe généralement pas le driver complet du fabricant (lourd, bloatwares). On utilise un UPD (HP UPD, Xerox Global Print Driver...) : un driver générique compatible avec tous les modèles d'une même marque. Avantage : un seul driver léger pour tout le parc.

### 14.5 Déploiement d'imprimantes via GPO

En environnement Active Directory, on ne déploie pas les imprimantes manuellement poste par poste. On utilise une GPO :
- **Chemin** : Configuration utilisateur → Préférences → Paramètres Windows → Imprimantes.
- **Résultat** : l'imprimante apparaît automatiquement à la connexion de l'utilisateur selon son OU.

### 14.6 Configurer la numérisation (Scan)

**Option A — Scan vers dossier (Scan to SMB)** : permettre aux utilisateurs de scanner un document depuis le copieur pour qu'il arrive directement sur leur PC ou le serveur.
1. *Côté PC/Serveur* : créer un dossier (ex : `C:\Scans`), le partager, s'assurer que l'utilisateur a les droits NTFS et de Partage en Modification.
2. *Côté copieur* : interface web → carnet d'adresses → ajouter un profil « Scan to SMB » → renseigner le chemin réseau (`\\NomDuPC\Scans`), l'identifiant Windows et le mot de passe.

> **Bonne pratique** : utiliser un compte de service dédié (ex : `svc_scanner@entreprise.local`) avec un mot de passe qui n'expire pas. Si on utilise le compte personnel de l'utilisateur, chaque changement de mot de passe cassera le scan.

> **Attention au SMBv1** : désactivé aujourd'hui pour des raisons de sécurité (faille WannaCry). Si le copieur est trop vieux pour SMBv2/v3, mettre à jour son firmware peut corriger cela ; sinon, le **Scan to Email** ou le **Scan vers FTP/SFTP** sont les alternatives sécurisées.

**Option B — Scan to Email (SMTP)** : solution de contournement la plus fiable face aux problèmes SMB. Le copieur envoie les scans comme pièces jointes par email.
1. Interface web du copieur → Paramètres réseau → SMTP.
2. Renseigner l'adresse du serveur mail (ou le relais SMTP de l'entreprise), le port (25 ou 587), et un compte expéditeur dédié (ex : `scanner@entreprise.com`).

---

# MODULE 7 : CYBERSÉCURITÉ

## 1. Malwares (logiciels malveillants)

| Malware | Description |
|---|---|
| **Ransomware (rançongiciel)** | Chiffre les données pour exiger une rançon. Seule défense efficace : sauvegarde hors-ligne. |
| **Spyware** | Vole des données ou espionne l'activité de l'utilisateur |
| **RAT (Remote Access Tool)** | Permet de prendre le contrôle à distance de la machine |
| **Trojan (Cheval de Troie)** | Logiciel qui se fait passer pour légitime afin d'exécuter une charge malveillante (vol de données, RAT, ransomware...) |
| **Keylogger** | Enregistre toutes les frappes au clavier |
| **Virus** | Se greffe à une application et se multiplie à l'exécution |
| **Ver (Worm)** | Malware autonome qui se propage de poste en poste via le réseau |
| **Rootkit** | Malware conçu pour se cacher dans le système et maintenir un accès privilégié |
| **Bootkit** | Variante de rootkit qui infecte le démarrage (MBR ou UEFI) pour se lancer avant l'OS |
| **Rogue** | Fausse application (souvent faux antivirus) pour tromper l'utilisateur |
| **DDoS** | Surcharge d'un serveur par des milliers de requêtes (souvent via PC zombies / botnets) |

**Faille Zero-day** : faille inconnue du fabricant, donc sans correctif disponible. Pendant la fenêtre entre la découverte et le patch, aucun antivirus ne la détecte — seule une analyse comportementale (EDR) peut en limiter l'impact.

## 2. Détection et analyse

**VirusTotal** (virustotal.com) : soumettre un fichier pour l'analyser avec plusieurs antivirus simultanément.

**Fonctionnement de l'antivirus** :
- **Base de signatures** : compare les fichiers à une base d'empreintes connues.
- **Analyse comportementale (heuristique)** : surveille les actions suspectes. Attention aux faux positifs.
- **Actions** : mise en quarantaine ou suppression.
- Redémarrage souvent nécessaire si le malware est chargé en RAM.

### Réflexes en cas d'incident

Si un poste semble compromis :
1. Déconnecter le PC du réseau immédiatement.
2. Ne pas éteindre brutalement si une analyse mémoire est prévue.
3. Prévenir le responsable IT / RSSI.
4. Identifier l'étendue de la compromission.
5. Réinitialiser les mots de passe potentiellement exposés.
6. Vérifier les autres postes.
7. Restaurer depuis une sauvegarde saine si nécessaire.

> Ne jamais payer une rançon sans validation de la direction et des autorités compétentes.

## 3. Défense et maintenance du technicien

| Outil / Concept | Description |
|---|---|
| **Pare-feu (Firewall)** | Règle d'or : tout bloquer par défaut, n'autoriser que le nécessaire (ex : port 443 HTTPS). Créer des règles entrantes ET sortantes. |
| **Antivirus + Malwarebytes** | Malwarebytes est un complément efficace à l'antivirus classique, notamment en post-infection. |
| **Process Explorer (Sysinternals)** | Visualiser les processus, y compris les processus cachés. |
| **Autoruns (Sysinternals)** | Identifier les programmes suspects au démarrage. |
| **CCleaner** | À limiter aux fichiers temporaires. Ne jamais utiliser le nettoyage de registre. |
| **Haveibeenpwned.com** | Vérifier si une adresse mail a été compromise. |
| **Tails OS** | OS chargé en RAM, ne laisse aucune trace sur la machine. |
| **Snapshots VM** | Prendre un snapshot avant toute manipulation risquée. |

**Mot de passe** :
- **Un mot de passe unique par service.** 80 % des compromissions exploitent la réutilisation du même mot de passe. Si LinkedIn fuite et que l'agent utilise le même mot de passe pour sa messagerie pro, le pirate accède aux deux en quelques secondes.
- **Long plutôt que complexe.** L'ANSSI recommande 12 caractères minimum pour un accès standard, 16 pour un accès sensible. Une phrase de passe (`LeChatBleuDanseSousLaPluie!`) est plus robuste qu'un mot court bardé de caractères spéciaux.
- **Ne jamais le communiquer** (ni email, ni téléphone, ni à un collègue, ni au support). Un service légitime ne demande jamais votre mot de passe.

**Gestionnaire de mots de passe** : **Bitwarden** (open source, gratuit — recommandé particuliers/PME) ou **KeePass** (local, sans Cloud — recommandé quand les données ne doivent pas quitter le SI). Génèrent et stockent un mot de passe unique et complexe par service ; l'utilisateur ne retient qu'un mot de passe maître. Recommandé par l'ANSSI.

| Technologie | Description |
|---|---|
| **EDR (Endpoint Detection & Response)** | Surveillance avancée des comportements suspects sur les postes |
| **XDR (Extended Detection & Response)** | Corrélation des événements de sécurité entre postes, emails, Cloud et réseau pour détecter des attaques complexes |

**Commandes utiles (Win+R)** :

| Commande | Action |
|---|---|
| `optionalfeatures` | Activer la Sandbox Windows |
| `wf.msc` | Accès direct au pare-feu avancé (règles entrantes et sortantes) |
| `mrt` | Outil de suppression de logiciels malveillants intégré à Windows |

**Anonymat sur Internet — les limites** :
- Un VPN masque uniquement l'adresse IP. Le fournisseur VPN conserve des logs et peut les transmettre sur réquisition judiciaire.
- Chaque machine possède une signature numérique (cookies, empreinte navigateur). On n'est jamais réellement anonyme.

## 4. Ingénierie sociale (Social Engineering)

Les outils précédents protègent contre les attaques techniques. Mais la menace la plus difficile à contrer ne vient pas d'un logiciel — elle vient de la manipulation directe des utilisateurs.

**Définition** : ensemble des techniques de manipulation psychologique visant à obtenir d'une personne qu'elle divulgue des informations confidentielles ou effectue une action compromettante. C'est la cyberattaque la plus efficace et la plus difficile à contrer, car elle cible l'humain, pas la machine.

> Un pare-feu bloque les paquets. Un antivirus détecte les fichiers malveillants. Aucun des deux ne détecte un employé qui donne son mot de passe de son plein gré.

**Pourquoi c'est redoutable** : selon plusieurs études de référence (IBM, Verizon DBIR), entre **74 et 95 % des incidents impliquent une erreur humaine**. Le social engineering exploite des mécanismes psychologiques universels (autorité, urgence, peur, confiance, curiosité, serviabilité) qui fonctionnent indépendamment du niveau technique de la victime.

### Les techniques principales

**Phishing (hameçonnage)** : email frauduleux imitant un expéditeur légitime (banque, Microsoft, DRH, direction) pour pousser la victime à cliquer sur un lien ou ouvrir une pièce jointe.

| Variante | Description |
|---|---|
| Phishing classique | Email de masse non ciblé — filet large |
| Spear Phishing | Email ciblé sur une personne précise avec des infos personnalisées (nom, poste, collègues) — bien plus convaincant |
| Whaling | Spear phishing ciblant spécifiquement les dirigeants (PDG, DAF, DSI) |
| Smishing | Phishing par SMS |
| Vishing | Phishing par appel téléphonique |
| Clone Phishing | Copie exacte d'un email légitime déjà reçu, avec le lien remplacé par un lien malveillant |

**Reconnaître un email de phishing** :
- Adresse expéditeur avec un domaine proche mais faux (ex : `support@micros0ft.com`, `rh@aerosud-groupe.fr`).
- Ton d'urgence artificielle (« Votre compte sera suspendu dans 24h »).
- Lien dont l'URL ne correspond pas au texte affiché — survoler sans cliquer pour voir la vraie destination.
- Pièce jointe inattendue (`.docx`, `.pdf`, `.zip`) d'un expéditeur connu.
- Demande inhabituelle de la part d'un supérieur par email.

> **Réflexe terrain** : un email demande des identifiants ou un virement ? Toujours vérifier par un autre canal (téléphone, en personne). Jamais répondre directement à l'email suspect.

**Pretexting (prétexte)** : le pirate crée un scénario fictif crédible (technicien IT, auditeur, prestataire, collègue) pour justifier sa demande. Exemple : « Bonjour, je suis du support informatique. Votre compte a été compromis, j'ai besoin de votre mot de passe pour sécuriser votre session immédiatement. »

> Un service informatique légitime ne demande jamais votre mot de passe. Ni en personne, ni par téléphone, ni par email.

**Baiting (appât)** : laisser intentionnellement une clé USB infectée dans un lieu fréquenté (parking, salle de réunion, hall). La curiosité pousse quelqu'un à la brancher.

> **Étude terrain** : en 2016, des chercheurs ont abandonné 297 clés USB sur le campus de l'Université de l'Illinois. **48 %** ont été branchées dans les 24 heures.

*Contre-mesure* : désactiver l'exécution automatique des supports USB via GPO. Former les employés à ne jamais brancher une clé USB inconnue.

**Quid Pro Quo** : le pirate propose un service en échange d'une information (ex : appeler des employés en se faisant passer pour le support IT et proposer d'accélérer leur PC contre leurs identifiants).

**Tailgating / Piggybacking (filature physique)** : suivre physiquement une personne autorisée pour entrer dans une zone sécurisée sans badge, en entrant dans son sillage au moment où elle passe une porte.

*Contre-mesure* : politique de ne jamais laisser entrer quelqu'un sans qu'il bade lui-même, même si c'est socialement gênant.

**Fraude au Président (BEC — Business Email Compromise)** : usurpation de l'identité d'un dirigeant (PDG, DAF) pour ordonner un virement urgent ou une action sensible. L'email semble venir du dirigeant mais utilise un domaine légèrement différent. **C'est l'attaque qui coûte le plus cher** : 43 milliards de dollars de pertes estimées entre 2016 et 2021 (FBI IC3).

Scénario type :
```
De : p.dupont@aerosud-direction.fr  (faux domaine)
À  : comptabilite@aerosud.fr
Objet : Virement urgent — confidentiel

Bonjour,
Je suis actuellement en déplacement. Merci d'effectuer un virement
de 45 000 € vers le compte ci-dessous avant 17h.
Affaire confidentielle, ne pas en parler avant ma validation.
Pierre Dupont, PDG
```
*Contre-mesures* : procédure de double validation pour tout virement, jamais de virement sur simple email sans confirmation téléphonique sur un numéro connu.

### Les mécanismes psychologiques exploités

| Levier | Comment il est exploité |
|---|---|
| Autorité | Se faire passer pour la direction, l'IT, la police, Microsoft |
| Urgence | « Agissez maintenant ou votre compte est supprimé » |
| Peur | « Votre PC est infecté, appelez ce numéro immédiatement » |
| Confiance | Usurper l'identité d'un collègue ou prestataire connu |
| Curiosité | Clé USB abandonnée, email avec objet intrigant |
| Serviabilité | Exploiter la politesse (« je ne veux pas créer de problèmes ») |
| Réciprocité | Rendre service d'abord, puis demander quelque chose en retour |

### OSINT — la collecte d'informations avant l'attaque

Avant une attaque, un pirate réalise souvent une phase de reconnaissance via l'**OSINT (Open Source Intelligence)** : collecte d'informations publiquement disponibles.

Sources exploitées : **LinkedIn** (organigramme, dirigeants, postes, prestataires), **site web de l'entreprise** (emails, téléphones, technologies), **réseaux sociaux personnels** (habitudes, voyages, relations), **WHOIS** (infos sur les noms de domaine), **Google** (documents internes accidentellement publiés, offres d'emploi révélant les technologies).

> **Réflexe terrain** : googler le nom de votre entreprise + `filetype:pdf` ou `filetype:xlsx` — vous seriez surpris de ce qui est indexé.

### Se protéger — les mesures concrètes

**Côté utilisateur** :
- Ne jamais communiquer son mot de passe, quel que soit l'interlocuteur.
- Vérifier systématiquement l'adresse email complète de l'expéditeur (pas juste le nom affiché).
- En cas de doute, rappeler le numéro officiel — jamais celui fourni dans l'email suspect.
- Signaler immédiatement tout email ou appel suspect au service IT.

**Côté technique** :
- Activer **SPF, DKIM et DMARC** sur les domaines de messagerie — ces protocoles permettent aux serveurs de vérifier qu'un email vient bien du domaine qu'il prétend utiliser, empêchant l'usurpation d'expéditeur à la source.
- Mettre en place un filtre anti-phishing sur le serveur de messagerie.
- Désactiver l'exécution automatique des supports USB (GPO).
- Implémenter la double authentification (**MFA**) — même si un mot de passe est volé, l'accès reste bloqué.

**Côté organisationnel** :
- Former régulièrement les employés — la sensibilisation est la meilleure défense.
- Mener des campagnes de phishing simulées (GoPhish, KnowBe4) pour tester la vigilance.
- Définir des procédures claires pour les virements et demandes sensibles.
- Appliquer le principe du moindre privilège — limiter ce qu'un compte compromis peut faire.

**Tableau récapitulatif** :

| Attaque | Vecteur | Levier psychologique | Contre-mesure principale |
|---|---|---|---|
| Phishing | Email | Urgence, peur | Formation, filtre email, MFA |
| Spear Phishing | Email ciblé | Confiance, autorité | Vérification hors-canal |
| Vishing | Téléphone | Autorité, urgence | Ne jamais donner son MDP par téléphone |
| Baiting | Clé USB | Curiosité | GPO blocage USB, formation |
| Pretexting | Téléphone / présentiel | Confiance, autorité | Procédures de vérification d'identité |
| Fraude au Président | Email | Autorité, urgence | Double validation, procédure virement |
| Tailgating | Physique | Serviabilité, politesse | Badge obligatoire, formation |

> **La règle d'or du social engineering** : « Une demande urgente, confidentielle et inhabituelle est presque toujours une tentative de manipulation. Plus on vous presse, plus il faut ralentir. »

## 5. Sécurité physique des équipements

> 🤖 *Section ajoutée avec l'assistance d'une IA — à relire et vérifier avant usage.*

La cybersécurité protège les données contre les attaques logicielles, mais un équipement peut aussi être **volé ou dérobé physiquement**. La sécurité physique est la première couche, souvent négligée : un PC portable volé, c'est potentiellement toutes ses données exposées.

**Les mesures de verrouillage physique :**

| Mesure | Rôle |
|---|---|
| **Antivol Kensington** (câble + serrure) | Attache physiquement un PC portable ou fixe à un point fixe (bureau) via le **port Kensington** dédié. Dissuade le vol opportuniste. |
| **Verrouillage des baies / armoires** | Les serveurs, switchs et équipements réseau sont enfermés dans une **baie verrouillée**, en local technique à accès restreint. |
| **Verrouillage de session** | `Win + L` à chaque fois qu'on quitte son poste, verrouillage automatique après inactivité (via GPO). |
| **Sécurisation des ports** | Désactivation des ports USB par GPO (cf. baiting, §4), blocage du boot sur support externe dans le BIOS. |
| **Contrôle d'accès physique** | Badges, locaux à accès restreint pour les salles serveurs (lien avec le tailgating, §4). |

**La complémentarité physique + logique** : le verrouillage physique dissuade le vol ; le **chiffrement** (BitLocker, cf. Module 6) garantit que même si le matériel est volé, les données restent illisibles. Les deux se combinent toujours.

> **Réflexe terrain** : sur un parc de portables, la combinaison gagnante = **BitLocker activé** (données illisibles si vol) **+ antivol Kensington** (dissuasion du vol) **+ verrouillage de session automatique** (protection si le poste reste sans surveillance). Aucune des trois ne suffit seule.

## 6. RGPD et protection des données personnelles

> 🤖 *Section ajoutée avec l'assistance d'une IA — à relire et vérifier avant usage.*

Le **RGPD** (Règlement Général sur la Protection des Données) est le règlement européen qui encadre le **traitement des données personnelles**, en application depuis le 25 mai 2018. En France, c'est la **CNIL** (Commission Nationale de l'Informatique et des Libertés) qui veille à son respect. Le technicien de proximité, qui manipule au quotidien des postes et des données d'utilisateurs, est directement concerné.

**Qu'est-ce qu'une donnée personnelle ?** Toute information se rapportant à une personne physique identifiable : nom, email, téléphone, adresse, mais aussi adresse IP, identifiant de connexion, photo, données de santé... Certaines sont dites **sensibles** (santé, opinions, biométrie) et bénéficient d'une protection renforcée.

**Les principes clés à connaître :**
- **Minimisation** : ne collecter et ne conserver que les données strictement nécessaires.
- **Finalité** : les données ne servent qu'à l'usage prévu, pas à autre chose.
- **Durée de conservation limitée** : on ne garde pas les données indéfiniment.
- **Sécurité** : protéger les données contre l'accès non autorisé, la perte, le vol (chiffrement, sauvegardes, contrôle d'accès).
- **Droits des personnes** : accès, rectification, suppression (« droit à l'oubli ») de leurs données.

**Ce que cela implique concrètement pour le technicien :**
- **Confidentialité absolue** : ne jamais consulter, copier ou divulguer les données d'un utilisateur en dehors de la stricte nécessité d'une intervention (cf. Module 1, §8).
- **Effacement sécurisé** avant mise au rebut ou réaffectation d'un matériel (cf. DEEE, Module 5 §7) — un disque mal effacé est une fuite de données personnelles.
- **Signaler une violation de données** (perte, vol, fuite) à sa hiérarchie : le RGPD impose une notification à la CNIL sous **72 heures** dans certains cas.
- **Vigilance sur les transferts** : ne pas envoyer de données personnelles par des canaux non sécurisés (email non chiffré, clé USB non protégée).

> **À retenir — RGPD**
> - Encadre le traitement des **données personnelles** (UE, depuis 2018 ; en France, autorité = **CNIL**).
> - Principes : minimisation, finalité, durée limitée, sécurité, droits des personnes.
> - Pour le technicien : **confidentialité stricte**, effacement sécurisé des supports, signalement rapide de toute fuite.
> - Une violation de données peut devoir être notifiée à la CNIL sous **72 h** — d'où l'importance de remonter l'information immédiatement.

---

# MODULE 8 : UTILISER L'IA

## 1. La règle d'or : le contexte (R.O.C.T.)

Pour obtenir une bonne réponse, un bon prompt est indispensable. Méthode **R.O.C.T.** :

| Lettre | Élément | Exemple |
|---|---|---|
| **R** | Rôle | « Agis comme un expert en Python » |
| **O** | Objectif | « Explique-moi les boucles while » |
| **C** | Contexte | « Je suis en 1ʳᵉ année de BTS SIO et je ne comprends pas la différence avec la boucle for » |
| **T** | Format (Type de réponse) | « Donne-moi une définition, un exemple de code et un petit exercice » |

## 2. Comment l'utiliser en informatique ?

| Cas d'usage | Exemple de prompt |
|---|---|
| Explication de concepts abstraits | « Explique la POO avec une analogie simple (voiture, recette...) » |
| Rubber Duck Debugging | « Voici mon code [...]. Il renvoie une erreur IndexError. Explique pourquoi sans me donner la solution directe. » |
| Génération de données de test | « Génère un JSON de 10 faux utilisateurs avec nom, email et âge. » |
| Documentation / commentaires | « Ajoute des commentaires pédagogiques à ce script pour que je puisse le réviser plus tard. » |

## 3. Pièges à éviter

- **L'hallucination** : l'IA peut affirmer des choses fausses avec assurance, surtout sur des bibliothèques récentes. Toujours vérifier dans la documentation officielle.
- **Le copier-coller aveugle** : utiliser l'IA pour comprendre le *pourquoi* du code, pas pour le générer en entier sans comprendre.
- **La sécurité** : ne jamais donner de mots de passe réels, clés d'API ou données sensibles.

## 4. Veille, apprentissage continu et anglais

> 🤖 *Section ajoutée avec l'assistance d'une IA — à relire et vérifier avant usage.*

L'IA n'est qu'un outil parmi ceux de la **montée en compétence continue**, qui est une compétence à part entière du métier (« Apprendre en continu »). Le domaine évolue vite — sécurité, IA, nouveaux OS, nouveaux matériels — et le technicien doit rester à jour pour anticiper les besoins des utilisateurs.

> **Veille et anglais — une compétence du métier**
> Le technicien assure une **veille régulière** : sites spécialisés, forums professionnels, documentation éditeur, échanges avec ses pairs et avec son responsable (notamment en cas de problème récurrent). La majorité de la **documentation technique et des notices constructeur est en anglais** — savoir la lire fait partie du métier. Réflexe utile : copier un **message d'erreur tel quel** dans un moteur de recherche mène souvent directement à la solution (documentation officielle, forums).

> **À retenir — Module 8**
> - Un bon prompt suit la méthode **R.O.C.T.** (Rôle, Objectif, Contexte, Type de réponse).
> - L'IA aide à comprendre, pas à remplacer la compréhension : toujours vérifier (hallucinations) et ne jamais lui confier de données sensibles.
> - L'IA s'inscrit dans une démarche plus large de **veille** et d'**apprentissage continu**, anglais compris.
