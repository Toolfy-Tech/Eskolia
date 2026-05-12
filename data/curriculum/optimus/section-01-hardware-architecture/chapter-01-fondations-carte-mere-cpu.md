> **Parcours Optimus** - **Module 1** · Chapitre 1 sur 6 · *Fondations hardware : boitier, carte mere, CPU*.
>
> Contenu adapte depuis les chapitres Optimus Module 1.

## Source 1 - chapter-01-intro-peripheriques-boitiers.md

> **Parcours Optimus** — **Module 1** · Chapitre 1 sur 12 · *Introduction, périphériques et boîtiers*.
>
> Contenu issu du cours Optimus (PDF) ; tableaux extraits du PDF ; illustrations sous `curriculum/optimus/images/`.

COURS OPTIMUS

METTRE EN SERVICE DES EQUIPEMENTS NUMERIQUES ET ASSURER LE
SUPPORT UTILISATEUR

MODULE 1 : HARDWARE & ARCHITECTURE DES
SYSTEMES INFORMATIQUES
Dans le système informatique on distingue :

- Le matériel ou hardware
- Le logiciel ou software
On distingue également les périphériques d’entrée : clavier, souris, manette, caméra, microphone. Les
périphériques de sortie : écran, imprimante, haut-parleurs, casque audio. Certains périphériques sont
mixtes (entrée/sortie) : par exemple un casque-micro.

## 0. Les boîtiers

Le choix d'un boîtier repose sur trois critères majeurs :

- L'ergonomie et le design : Encombrement sur le bureau et esthétique.
- La compatibilité matérielle : Il doit pouvoir accueillir la taille de la carte mère, la longueur de la
carte graphique et la hauteur du refroidisseur CPU.
- Le flux d'air (Airflow) : Le flux d’air (airflow) correspond à la capacité du boîtier à évacuer
efficacement la chaleur. Il dépend notamment du nombre, de l’emplacement et du sens des
ventilateurs (aspiration / extraction), ainsi que de la circulation de l’air à l’intérieur du boîtier. Le
push-pull est surtout utilisé sur certains radiateurs pour améliorer le refroidissement.

On distingue principalement quatre formats physiques : Desktop (horizontal), Tour (le plus commun),
Mini-PC et Serveur (rackable). La taille est dictée par la norme ATX (créée par Intel), qui définit les
dimensions standards des cartes mères : Mini-ITX < Micro-ATX < ATX < E-ATX.
Cable Management : un bon boîtier possède des espaces derrière la carte mère pour cacher les câbles,
ce qui n'est pas seulement esthétique, mais améliore grandement la circulation de l'air.

## Source 2 - chapter-02-carte-mere.md

> **Parcours Optimus** — **Module 1** · Chapitre 2 sur 12 · *Carte mere (Motherboard)*.
>
> Contenu issu du cours Optimus (PDF) ; tableaux extraits du PDF ; illustrations sous `curriculum/optimus/images/`.

## 1. La carte mere (Motherboard)

La carte mere est le composant central du PC, c'est le coeur. Tous les autres composants y sont connectes directement ou indirectement. Elle determine la compatibilite entre les pieces.

### 1.1 Roles de la carte mere

- Interconnecter tous les composants (CPU, RAM, stockage, GPU...)
- Gerer les communications via les bus de donnees
- Heberger le BIOS/UEFI qui demarre la machine
- Fournir les ports externes (USB, audio, reseau, video)

### 1.2 Facteurs de forme (Form Factor)

Le facteur de forme definit la taille physique de la carte mere et sa compatibilite avec le boitier.

| Format | Dimensions | Utilisation typique | Nb slots RAM |
|---|---|---|---|
| Mini-ITX | 170 x 170 mm | PC tres compact / HTPC | 2 slots |
| Micro-ATX | 244 x 244 mm | PC compact bureautique | 2-4 slots |
| ATX | 305 x 244 mm | PC de bureau standard / gaming | 4 slots |
| E-ATX | 305 x 330 mm | Workstation / serveur | 8 slots |

### 1.3 Les principaux composants sur la carte mere

| Composant | Description |
|---|---|
| **Socket** | C'est le connecteur specifique situe sur la carte mere permettant d'accueillir et de fixer le processeur (CPU). Il assure la liaison electrique et la communication entre le processeur et les autres composants (RAM, stockage, GPU). Chaque socket est concu pour une famille precise de processeurs. Il est non interchangeable : un processeur Intel ne rentrera jamais dans un socket AMD (et vice-versa). |
| Slots RAM (DIMM) | Emplacements pour les barrettes de RAM. La couleur indique les paires (dual channel). |
| **Chipset (jeu de puces)** | Ensemble de composants electroniques integres a la carte mere qui coordonne les flux de donnees entre le processeur et les differents peripheriques (stockage, USB, reseau). Il determine les capacites de la carte mere (nombre de ports USB, vitesse du disque dur, possibilite d'overclocking). En resume : puce qui gere les communications entre CPU, RAM, stockage et peripheriques. |
| Slots PCIe | Emplacements pour GPU, cartes reseau, cartes son, SSD NVMe... |
| Connecteurs SATA | Branchement des disques durs et SSD SATA (cable en L). |
| Slot M.2 | Emplacement pour SSD NVMe ou SATA en format compact (pas de cable). |
| Connecteur 24 broches | Alimentation principale de la carte mere depuis le PSU. |
| Connecteur CPU (4/8 broches) | Alimentation specifique du processeur. |
| CMOS / Pile bouton | Maintient la date/heure et les parametres BIOS quand le PC est eteint. |
| Headers facade | Connecteurs pour bouton power, reset, LEDs, USB facade, audio facade. |

### A retenir - Carte mere

- Le socket doit etre compatible avec le CPU : socket Intel LGA (broches sur la carte) vs AMD AM4 (broches sur le CPU) mais AM5 s'est aligne sur Intel avec LGA.
- Le chipset determine les fonctionnalites : overclocking, nombre de ports USB/SATA, PCIe...
- ATX = standard le plus courant. Mini-ITX = le plus petit.
- Ne jamais forcer un format incompatible dans un boitier.

![Image 1](../images/image_001.jpeg)

## Source 3 - chapter-03-processeur-cpu.md

> **Parcours Optimus** — **Module 1** · Chapitre 3 sur 12 · *Processeur (CPU)*.
>
> Contenu issu du cours Optimus (PDF) ; tableaux extraits du PDF ; illustrations sous `curriculum/optimus/images/`.

## 2. Le processeur (CPU)

Le CPU (Central Processing Unit) est le cerveau de l'ordinateur. Il interprete et execute les instructions des programmes selon un cycle perpetuel en 4 etapes :

1. Fetch (Recherche) : Recuperation de l'instruction en memoire.
2. Decode (Interpretation) : Decodage du code operation et des operandes par l'unite de controle.

3. Execute (Execution) : Realisation de l'operation par l'UAL.
4. Writeback (Ecriture) : Enregistrement du resultat en registre ou en RAM.

Architecture interne :

- Unite de controle : Dirige le flux de donnees et coordonne les autres unites.
- UAL (Unite Arithmetique et Logique) : Effectue les calculs (+, -, x) et les comparaisons logiques.
- Registres (32/64 bits) : Zones de stockage ultra-rapides (ex: Compteur Ordinal, Registre d'etat).
- Horloge : Genere des impulsions pour synchroniser et cadencer les traitements (mesuree en GHz).
- Bus : Canaux de communication (Donnees, Adresses et Controle).

Technologies modernes : Les processeurs actuels integrent egalement de la memoire cache (SRAM) pour reduire les temps d'acces, ainsi que le pipelining et l'unite de prediction de branchement pour optimiser l'execution des instructions en anticipant les besoins du programme.

### 2.1 Caracteristiques cles

| Caracteristique | Definition | Exemple |
|---|---|---|
| Nombre de coeurs (cores) | Le processeur avec un coeur traite une seule consigne a la fois. S'il recoit plusieurs instructions, il va les traiter en serie. Un CPU multi-coeurs possede plusieurs coeurs physiques independants qui peuvent donc executer des taches en simultanee. Plus de coeurs = meilleur multitache. | 4 coeurs, 8 coeurs, 16 coeurs... |
| Nombre de threads | Coeurs logiques. Avec HyperThreading = 2x coeurs physiques. (chez AMD on appelle cela le SMT (_Simultaneous Multi-Threading_)) | 8 coeurs = 16 threads |
| Frequence (GHz) | Nombre de cycles par seconde. Plus = calculs plus rapides. | 3.6 GHz (3.6 milliards de cycles par seconde / 1 cycle != 1 instruction (IPC variable)), 5.0 GHz... |
| Cache L1 / L2 / L3 | Memoire ultra-rapide integree au CPU. L1 < L2 < L3 (taille) = technologie SRAM (voir ci-apres). | L3 = 12 Mo, 32 Mo... |
| TDP (Watts) | Chaleur dissipee = consommation indicative. Important pour le choix du ventirad. | 65W, 95W, 125W... |
| Architecture (nm) | La finesse de gravure (les nanometres) impacte surtout la chauffe et la consommation. Plus c'est fin, plus on peut mettre de transistors dans le meme espace sans que le CPU ne fonde. | 7nm, 5nm, 4nm... |

### 2.2 Principaux fabricants et sockets

| Fabricant | Gamme | Socket | Particularite |
|---|---|---|---|
| Intel | Core i3 / i5 / i7 / i9 | LGA 1700 (12e/13e/14e gen), LGA 1851 destine a la nouvelle architecture (Core Ultra / Arrow Lake) | Broches sur la carte mere (LGA) |
| AMD | Ryzen 3 / 5 / 7 / 9 | AM4, AM5 | Broches sur le CPU (PGA pour AM4, LGA pour AM5) |
| Intel | Xeon | LGA 3647 / 4677 | Serveurs et workstations |
| AMD | EPYC / Threadripper | TR4 / SP3 / SP5 | Serveurs et workstations |

### 2.3 Refroidissement CPU

- Ventirad (air cooler) : radiateur + ventilateur. Suffisant pour la majorite des usages.
- Watercooling AIO : radiateur + pompe + ventilateurs. Plus efficace pour CPU chauds.
- Pate thermique : indispensable entre le CPU et le ventirad pour conduire la chaleur.

> **Attention - Erreur frequente a l'examen**
> LGA et PGA ne sont pas les memes : LGA = broches sur le socket de la carte mere, PGA = broches sur le CPU.

> Un CPU Intel ne s'installe pas sur un socket AMD et vice versa.
> Ne jamais oublier la pate thermique lors du montage : sans elle, le CPU surchauffe en quelques secondes.
