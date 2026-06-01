> **Parcours Optimus** - **Module 1** · Chapitre 2 sur 6 · *Memoire et stockage : RAM, HDD, SSD, NVMe*.
>
> Contenu adapte depuis les chapitres Optimus Module 1.

## Source 1 - chapter-04-memoire-vive-ram.md

> **Parcours Optimus** — **Module 1** · Chapitre 4 sur 12 · *Mémoire vive (RAM)*.
>
> Contenu issu du cours Optimus (PDF) ; tableaux extraits du PDF ; illustrations sous `curriculum/optimus/images/`.

## 3. La memoire vive (RAM)

La RAM (Random Access Memory) est la memoire de travail du PC. Elle stocke temporairement les donnees des applications en cours d'utilisation. Elle est volatile : son contenu est efface a chaque extinction.

### 3.1 Structure interne de RAM

Une barrette est composee de plusieurs puces memoire (chips). La RAM est constituee de barrettes contenant plusieurs puces memoire, contenant chacune des millions de cellules. Chaque cellule memoire (1 transistor + 1 condensateur) correspond a 1 bit.

### 3.2 Types de RAM

- La SDRAM (DDR3, DDR4, DDR5) constitue les barrettes de memoire amovibles de l'ordinateur, servant a stocker temporairement les donnees des logiciels et du systeme en cours d'utilisation. Toutes les RAM que tu rencontres aujourd'hui en intervention (DDR3, DDR4, DDR5) sont des SDRAM. La DRAM asynchrone est obsolete - la SDRAM en est l'evolution synchronisee (Pour l'explication : La DRAM (Dynamic RAM asynchrone) fonctionne independamment de l'horloge du processeur. Elle envoie et recoit des donnees quand elle est prete, sans se synchroniser avec le CPU. La SDRAM (Synchronous DRAM) elle se synchronise sur l'horloge du processeur. Elle attend le signal d'horloge pour envoyer ou recevoir des donnees, ce qui permet au CPU de prevoir exactement quand la donnee sera disponible).
- La SRAM (Static RAM), integree directement au processeur sous forme de memoire cache (L1, L2, L3), est beaucoup plus rapide et couteuse, permettant au CPU d'acceder instantanement a ses instructions prioritaires. La SRAM ne necessite pas de rafraichissement (contrairement a la DRAM), ce qui explique le terme "statique" et sa vitesse superieure.
- La VRAM Video RAM (dont la technologie principale est la GDDR) est une memoire specialisee soudee sur la carte graphique, optimisee pour le transport massif de donnees d'image et de textures. Versions actuelles : GDDR5, GDDR6, GDDR6X, GDDR7 - et HBM sur certains GPU haut de gamme.

| Type de RAM | Generation | Vitesse typique | Tension | Usage |
|---|---|---|---|---|
| DDR3 | 3e generation | 800 - 2133 MHz | 1.5V | Anciens PC (2007-2014) |
| DDR4 | 4e generation | 2133 - 3600 MHz | 1.2V | PC courants (2014-2022) |
| DDR5 | 5e generation | 4800 - 6400 MHz+ | 1.1V | PC recents (2021+) |
| LPDDR4/5 | Mobile | Variable | 1.1V | Laptops, ultraportables |
| ECC RAM (Error-Correcting Code) | Serveur | Variable | Variable | Utilisee dans les serveurs et stations de travail critiques. Integre un mecanisme de detection et correction d'erreurs memoire. |

| Caracteristique | Description | Exemple |
|---|---|---|
| Capacite (Go) | Quantite de donnees stockables. 8 Go minimum, 16 Go recommande. | 8 Go, 16 Go, 32 Go, 64 Go |
| Frequence (MHz) | Vitesse de transfert des donnees. Plus = meilleur. | 3200 MHz, 3600 MHz |
| Latence (CL) | Nombre de cycles avant reponse. Moins = meilleur. | CL16, CL18, CL36 |
| Dual Channel | 2 barrettes identiques = bande passante theorique doublee (gain reel variable selon les usages). Slots de meme couleur. | 2x 8 Go > 1x 16 Go |
| Format | DIMM = desktop. SO-DIMM = laptop. Physiquement incompatibles. | DIMM, SO-DIMM |
| XMP / EXPO | Profil d'overclock RAM a activer dans le BIOS pour la vraie frequence. | XMP (Intel), EXPO (AMD) |

### A retenir - RAM

- DDR3, DDR4 et DDR5 sont physiquement incompatibles (encoches differentes) : toujours verifier la compatibilite avec la carte mere.
- Le dual channel peut augmenter fortement la bande passante (jusqu'a ~2x) selon les usages : toujours installer les barrettes par paires dans les bons slots.
- La capacite minimale pour Windows 11 : 4 Go (Microsoft), mais 8 Go recommande en pratique pour un usage bureautique.
- XMP/EXPO doit etre active dans le BIOS pour que la RAM tourne a sa vraie frequence annoncee.

## Source 2 - chapter-05-stockage-hdd-ssd-nvme.md

> **Parcours Optimus** — **Module 1** · Chapitre 5 sur 12 · *Stockage (HDD / SSD / NVMe)*.
>
> Contenu issu du cours Optimus (PDF) ; tableaux extraits du PDF ; illustrations sous `curriculum/optimus/images/`.

## 4. Stockage (HDD / SSD / NVMe)

Le stockage conserve les donnees de facon permanente (OS, fichiers, logiciels). Contrairement a la RAM, les donnees ne sont pas effacees a l'extinction : on parle de memoire non volatile.

On distingue deux types de disques :

- **HDD (Hard Disk Drive)** : stockage magnetique compose de plateaux rotatifs et d'une tete de lecture/ecriture mecanique. Plus lent en raison des pieces mobiles, mais offre une grande capacite a faible cout. Sensible aux chocs. Vitesses typiques : 5400 a 7200 tr/min.
- **SSD (Solid State Drive)** : stockage a memoire flash, sans piece mecanique. Beaucoup plus rapide que le HDD, plus resistant aux chocs, silencieux et a faible consommation. Deux interfaces principales : SATA (debits jusqu'a ~550 Mo/s) et NVMe (via PCIe, debits jusqu'a 7000 Mo/s sur les modeles recents).

Le **SAS (Serial Attached SCSI)** :

- Le HDD SAS est un disque dur mecanique haute performance concu pour les serveurs. Contrairement au SATA, il utilise le protocole SCSI et tourne a des vitesses tres elevees (10 000 ou 15 000 tr/min). Il est privilegie pour sa robustesse, sa capacite a fonctionner 24 h/24 sans interruption et son temps d'acces generalement plus faible qu'un HDD SATA classique.
- Le SSD SAS est un support de stockage a memoire flash utilisant l'interface professionnelle SAS au lieu du SATA ou du NVMe. Il se distingue par son "Dual Port" (deux chemins de donnees redondants) et une endurance extreme.
- **NVMe (Non-Volatile Memory Express)** : protocole de transfert ultra-rapide pour SSD flash. Il utilise l'interface PCI Express, reduit fortement la latence et constitue aujourd'hui le standard de performance. Attention : NVMe est le protocole, M.2 est le format physique.

### 4.1 Comparatif des technologies

| Type | Interface | Vitesse lecture | Forme | Prix/Go | Usage ideal |
|---|---|---|---|---|---|
| HDD | SATA | 80-160 Mo/s | 3.5" (desktop) / 2.5" (laptop) | Faible | Stockage de masse, NAS, archivage |
| HDD SAS | SAS | 200-300 Mo/s | 3.5" ou 2.5" (SFF*) | Moyen | Serveurs, bases de donnees, haute disponibilite (24h/7j) |
| SSD SATA | SATA | 500-560 Mo/s | 2.5" ou M.2 | Moyen | Disque systeme, remplacement HDD |
| SSD NVMe (PCIe 3.0) | M.2 NVMe | 3000-3500 Mo/s | M.2 | Moyen-eleve | Disque systeme rapide |
| SSD NVMe (PCIe 4.0) | M.2 NVMe | 5000-7000 Mo/s | M.2 | Eleve | Workstation, gaming haute perf. |
| SSD NVMe (PCIe 5.0) | M.2 NVMe | 10 000+ Mo/s | M.2 | Tres eleve | Pro / serveurs |
| SSD SAS | SAS | 1000-4000 Mo/s | 2.5" (SFF) | Tres eleve | Infrastructures critiques, centres de donnees, stockage SAN |

![Image 2](../images/image_002.jpeg)

![Image 3](../images/image_003.jpeg)

\* En entreprise, le format 2.5" s'appelle le SFF (Small Form Factor) et le 3.5" le LFF (Large Form Factor).

### 4.2 Le format M.2 en detail

Le slot M.2 est un connecteur physique present sur la carte mere qui peut accueillir deux types de SSD aux performances tres differentes. C'est une source frequente d'erreur en intervention.

- **M.2 SATA** : utilise le protocole SATA, meme logique que les disques 2,5 pouces. Vitesse limitee a ~560 Mo/s. Encoche de type cle B ou B+M.
- **M.2 NVMe** : utilise le protocole NVMe via le bus PCIe, communication directe avec le CPU. De 3 a 20 fois plus rapide que le SATA. Encoche de type cle M.

Point critique en intervention : un slot M.2 NVMe n'accepte pas forcement un SSD M.2 SATA, et inversement. Un SSD peut rentrer physiquement dans le slot sans etre compatible avec le protocole supporte par la carte mere. Toujours consulter la documentation de la carte mere avant tout remplacement ou upgrade.

Tailles physiques disponibles :

| Format | Longueur | Usage |
|---|---|---|
| 2240 | 42 mm | Petits PC, tablettes |
| 2260 | 60 mm | Rare |
| 2280 | 80 mm | Le plus courant |
| 22110 | 110 mm | Serveurs |

![Image 4](../images/image_004.jpeg)

### 4.3 Interfaces SATA

| Composant | Description |
|---|---|
| SATA III | Interface actuelle, debit max 600 Mo/s, cable SATA en L 7 broches |
| SATA II | Ancienne generation, 300 Mo/s max, retrocompatible avec SATA III |
| eSATA | SATA externe, remplace par l'USB 3.x dans la plupart des cas |
| Cable SATA | Cable de donnees 7 broches. Cable d'alimentation SATA 15 broches (du PSU). |

### 4.4 Systemes de fichiers

C'est l'element logiciel indispensable qui fait le pont entre les composants physiques (HDD, SSD) et les donnees (fichiers, dossiers). Sans lui, le disque n'est qu'une suite de "0" et de "1" illisible.

Le systeme de fichiers est la methode utilisee par un systeme d'exploitation (Windows, macOS, Linux) pour organiser, stocker et recuperer les donnees sur un support de stockage.

Roles principaux :

- Gestion de l'espace : il divise le disque en blocs (clusters) et attribue ces blocs aux fichiers.
- Indexation : il conserve le nom, la taille et l'emplacement exact de chaque fichier (Metadata).
- Securite et permissions : il definit qui a le droit de lire, modifier ou supprimer un fichier.
- Journalisation : il enregistre les modifications en cours pour eviter la perte de donnees en cas de coupure de courant brutale.

| Systeme | OS compatible | Caracteristiques |
|---|---|---|
| NTFS | Windows (natif) | Journalisation, permissions, chiffrement. Standard Windows. |
| FAT32 | Windows/Linux/macOS | Compatible universel mais limite a 4 Go par fichier |
| exFAT | Windows/Linux/macOS | Cles USB/cartes SD. Pas de limite pratique. |
| ext4 | Linux (natif) | Journalisation, permissions Linux. Standard Linux. |
| APFS | macOS (natif) | SSD optimise, chiffrement natif. Exclusif Apple. |

> **Attention - Erreur frequente a l'examen**
> Un fichier de plus de 4 Go (ex : ISO, film 4K) ne peut PAS etre copie sur une cle USB formatee en FAT32.

> NVMe et SATA M.2 ont le meme connecteur physique M.2 mais des protocoles differents : ils ne sont pas toujours interchangeables.
