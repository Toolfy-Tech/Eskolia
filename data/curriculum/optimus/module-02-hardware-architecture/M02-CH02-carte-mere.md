> **Parcours Optimus — Module 2 · Chapitre 2 sur 12**

# La carte mere (Motherboard)

La carte mère est le composant central du PC, c'est le cœur. Tous les autres composants y sont connectés directement ou indirectement. Elle détermine la compatibilité entre les pièces.

## 2.1 Rôles de la carte mère

- Interconnecter tous les composants (CPU, RAM, stockage, GPU...)
- Gérer les communications via les bus de données
- Héberger le BIOS/UEFI qui démarre la machine
- Fournir les ports externes (USB, audio, réseau, vidéo)

## 2.2 Facteurs de forme (Form Factor)

Le facteur de forme définit la taille physique de la carte mère et sa compatibilité avec le boîtier.

| Format | Dimensions | Utilisation typique | Nb slots RAM |
|---|---|---|---|
| Mini-ITX | 170 x 170 mm | PC très compact / HTPC | 2 slots |
| Micro-ATX | 244 x 244 mm | PC compact bureautique | 2-4 slots |
| ATX | 305 x 244 mm | PC de bureau standard / gaming | 4 slots |
| E-ATX | 305 x 330 mm | Workstation / serveur | 8 slots |

## 2.3 Les principaux composants sur la carte mère

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
