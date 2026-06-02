> **Parcours Optimus — Module 2 · Chapitre 11 sur 12**

# Le BIOS / UEFI

Le BIOS (Basic Input/Output System) ou UEFI (Unified Extensible Firmware Interface) est le firmware de la carte mère. Il s'exécute avant tout OS et gère l'initialisation du matériel.

## 11.1 BIOS vs UEFI

| Critère | BIOS (legacy) | UEFI (moderne) |
|---|---|---|
| Interface | Texte uniquement, navigation clavier | Graphique, souris supportée |
| Adressage disque | MBR uniquement (max 2 To) | GPT et MBR (disques > 2 To) |
| Temps de démarrage | Lent | Beaucoup plus rapide (Secure Boot, Fast Boot) |
| Secure Boot | Non | Oui (empêche le boot de code non signé) |
| Table de partitions | MBR (4 partitions max) | GPT (128 partitions, disques > 2 To) |
| Présence | Avant 2012 environ | 2012 à aujourd'hui |

## 11.2 Paramètres BIOS/UEFI importants

| Paramètre | Description |
|---|---|
| Boot Order / Priority | Ordre de démarrage : HDD, USB, Réseau (PXE)... |
| Secure Boot | Valide la signature numérique du bootloader. Désactiver pour Linux si nécessaire. |
| Fast Boot | Réduit le temps de POST en sautant certains tests. Peut empêcher d'accéder au BIOS. |
| XMP / EXPO | Active le profil de fréquence haute de la RAM. |
| Virtualisation (VT-x/AMD-V) | Nécessaire pour faire tourner des VM (VMware, VirtualBox). |
| AHCI / NVMe | Mode du contrôleur SATA. AHCI = standard. IDE = ancien mode à ne pas utiliser. |
| TPM 2.0 | Puce de sécurité. Obligatoire pour Windows 11. |

## 11.3 La pile CMOS

- Pile bouton **CR2032** sur la carte mère.
- Maintient la date/heure et les paramètres BIOS quand le PC est débranché.
- Durée de vie : 5-10 ans. Symptômes de pile morte : date/heure réinitialisée à chaque démarrage, perte des réglages BIOS.
- Remplacement : retirer la pile quelques secondes = reset BIOS (CMOS clear).

> **À retenir — BIOS/UEFI**
> - UEFI + GPT = obligatoire pour installer Windows 11 et supporter des disques > 2 To.
> - BIOS + MBR = systèmes anciens, 4 partitions primaires max, disques 2 To max.
> - Secure Boot doit être désactivé pour booter sur certaines distributions Linux (ou activé avec clé tierce).
> - Pile CMOS morte = heure et date incorrectes au démarrage = symptôme caractéristique.
