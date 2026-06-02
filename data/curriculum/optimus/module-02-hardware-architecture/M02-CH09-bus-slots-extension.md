> **Parcours Optimus — Module 2 · Chapitre 9 sur 12**

# Les bus et slots d'extension

## 9.1 Le bus PCIe (PCI Express)

PCIe est le bus d'extension principal des PC modernes. Il connecte GPU, SSD NVMe, cartes réseau, etc.

| Version PCIe | Débit par lane | Slot x16 total | Usage |
|---|---|---|---|
| PCIe 3.0 | ~1 Go/s | ~16 Go/s | Standard encore très répandu |
| PCIe 4.0 | ~2 Go/s | ~32 Go/s | GPU récents, SSD NVMe Gen4 |
| PCIe 5.0 | ~4 Go/s | ~64 Go/s | Plateformes 2023+ (Intel 13e gen, AMD Ryzen 7000) |
| PCIe 6.0 | ~8 Go/s | ~128 Go/s | En cours de déploiement (serveurs) |

## 9.2 Tailles de slots PCIe

- **x1** : petit slot. Cartes réseau, cartes son, cartes d'acquisition. 1 lane.
- **x4** : slot moyen. SSD NVMe en adaptateur, cartes HBA.
- **x8** : slot grand. Cartes RAID, certains GPU secondaires.
- **x16** : le plus grand slot. Réservé au GPU principal.

**Compatibilité** : une carte PCIe peut s'insérer dans un slot plus grand (x1 dans x16) mais tournera à la bande passante du slot de la carte. PCIe est **rétrocompatible** : une carte PCIe 4.0 peut fonctionner sur un port PCIe 3.0 (avec performances réduites).

## 9.3 Anciens bus (à connaître pour les pannes)

| Bus | Période | Description |
|---|---|---|
| PCI | 1992-2010 | Avant PCIe. Slots blancs. Débit faible (133 Mo/s). |
| AGP | 1997-2004 | Slot dédié aux cartes graphiques. Remplacé par PCIe. |
| ISA | 1981-2000 | Très ancien bus 8/16 bits. Machines d'avant 2000. |
