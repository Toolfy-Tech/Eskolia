> **Parcours Optimus** - **Module 1** · Chapitre 5 sur 6 · *Firmware, BIOS et UEFI*.
>
> Contenu adapte depuis les chapitres Optimus Module 1.

## Source 1 - chapter-11-bios-uefi.md

> **Parcours Optimus** — **Module 1** · Chapitre 11 sur 12 · *BIOS / UEFI*.
>
> Contenu issu du cours Optimus (PDF) ; tableaux extraits du PDF ; illustrations sous `curriculum/optimus/images/`.

## 10. Le BIOS / UEFI

Le BIOS (Basic Input/Output System) ou UEFI (Unified Extensible Firmware Interface) est le firmware de la
carte mere. Il s'execute avant tout OS et gere l'initialisation du materiel.
### 10.1. BIOS vs UEFI

- **Critere** | **BIOS (legacy)** | **UEFI (moderne)**
- Interface | Texte uniquement, navigation | Graphique, souris supportee
- Interface | clavier
- Adressage disque | MBR uniquement (max 2 To) | GPT et MBR (disques > 2 To supportes)
- Temps de demarrage | Lent | Beaucoup plus rapide (Secure Boot,
- Temps de demarrage | Lent | Fast Boot)
- Secure Boot | Non | Oui (empeche boot de code non signe)
- Table de partitions | MBR (4 partitions max) | GPT (128 partitions, disques >2 To)
- Presence sur machines | Avant 2012 environ | 2012 a aujourd'hui

### 10.2. Parametres BIOS/UEFI importants

- **Parametre** | **Description**
- Boot Order / Boot Priority | Ordre de demarrage : HDD, USB, Reseau (PXE)...
- Secure Boot | Valide la signature numerique du bootloader. Desactiver pour Linux si necessaire.

- Fast Boot | Reduit le temps de POST en sautant certains tests. Peut empecher d'acceder au BIOS.
- XMP / EXPO | Active le profil de frequence haute de la RAM.
- Virtualisation (VT-x/AMD-V) | Necesaire pour faire tourner des VM (VMware, VirtualBox).
- AHCI / NVMe | Mode du controleur SATA. AHCI = standard. IDE = ancien mode a ne pas utiliser.
- TPM 2.0 | Puce de securite. Obligatoire pour Windows 11.

### 10.3. La pile CMOS

- Pile bouton CR2032 sur la carte mere.
- Maintient la date/heure et les parametres BIOS quand le PC est debranche.
- Duree de vie : 5-10 ans. Symptomes de pile morte : date/heure reinitialisee a chaque demarrage,
perte des reglages BIOS.
- Remplacement : retirer la pile quelques secondes = reset BIOS (CMOS clear).

### A retenir - BIOS/UEFI

- UEFI + GPT = obligatoire pour installer Windows 11 et supporter des disques de plus de 2 To.
- BIOS + MBR = systemes anciens, 4 partitions primaires max, disques 2 To max.
- Secure Boot doit etre desactive pour booter sur certaines distributions Linux (ou activer avec cle tierce).
- Pile CMOS morte = heure et date incorrectes au demarrage = symptome caracteristique.
