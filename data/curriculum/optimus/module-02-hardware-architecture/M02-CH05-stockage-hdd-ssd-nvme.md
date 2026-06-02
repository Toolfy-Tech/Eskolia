> **Parcours Optimus — Module 2 · Chapitre 5 sur 12**

# Le stockage (HDD / SSD / NVMe)

Le stockage conserve les données de façon permanente (OS, fichiers, logiciels). Contrairement à la RAM, les données ne sont pas effacées à l'extinction : mémoire **non volatile**.

- **HDD (Hard Disk Drive)** : stockage magnétique composé de plateaux rotatifs et d'une tête de lecture/écriture mécanique. Plus lent (pièces mobiles), grande capacité à faible coût, sensible aux chocs. Vitesses typiques : 5400 à 7200 tr/min.
- **SSD (Solid State Drive)** : stockage à mémoire flash, sans pièce mécanique. Beaucoup plus rapide, plus résistant aux chocs, silencieux, faible consommation. Deux interfaces principales :
  - **SATA** : connectique classique, débits jusqu'à ~550 Mo/s.
  - **NVMe** : utilise le bus PCIe (via le CPU ou le chipset), débits jusqu'à 7000 Mo/s sur les modèles récents.

**Le SAS (Serial Attached SCSI) :**

- **HDD SAS** : disque dur mécanique haute performance conçu pour les serveurs. Utilise le protocole SCSI et tourne à très haute vitesse (10 000 ou 15 000 tr/min). Robuste, fonctionne 24h/24, temps d'accès plus faible qu'un HDD SATA. En résumé : **HDD SAS = Fiabilité mécanique + Rapidité de rotation (usage intensif)**.
- **SSD SAS** : support à mémoire flash utilisant l'interface professionnelle SAS. Se distingue par son **« Dual Port »** (deux chemins de données redondants) et une endurance extrême. Pour les infrastructures de stockage critiques. En résumé : **SSD SAS = Performance flash + Sécurité maximale (redondance)**.
- **NVMe (Non-Volatile Memory Express)** : protocole de transfert ultra-rapide conçu pour la mémoire flash. Utilise l'interface PCI Express pour des débits largement supérieurs au SATA. Communication directe et massivement parallèle avec le processeur, latence minimale. **Attention** : NVMe est le **langage** (protocole), M.2 est la **forme** (connecteur). Il existe des SSD M.2 qui utilisent encore le vieux langage SATA, de plus en plus rares.

## 5.1 Comparatif des technologies

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

## 5.2 Le format M.2 en détail

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

## 5.3 Interfaces SATA

| Composant | Description |
|---|---|
| SATA III | Interface actuelle, débit max 600 Mo/s, câble SATA en L 7 broches |
| SATA II | Ancienne gen, 300 Mo/s max, rétrocompatible avec SATA III |
| eSATA | SATA externe, remplacé par l'USB 3.x dans la plupart des cas |
| Câble SATA | Câble de données 7 broches. Câble d'alimentation SATA 15 broches (du PSU). |

## 5.4 Systèmes de fichiers

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
