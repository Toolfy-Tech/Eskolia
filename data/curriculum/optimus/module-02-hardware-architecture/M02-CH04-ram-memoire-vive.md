> **Parcours Optimus — Module 2 · Chapitre 4 sur 12**

# La mémoire vive (RAM)

La RAM (Random Access Memory) est la mémoire de travail du PC. Elle stocke temporairement les données des applications en cours d'utilisation. Elle est **volatile** : son contenu est effacé à chaque extinction.

## 4.1 Structure interne de la RAM

Une barrette est composée de plusieurs puces mémoire (chips), contenant chacune des millions de cellules. Chaque cellule mémoire (1 transistor + 1 condensateur) correspond à 1 bit.

## 4.2 Types de RAM

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

## 4.3 Caractéristiques importantes

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
