> **Parcours Optimus — Module 2 · Chapitre 12 sur 12**

# Assemblage et dépannage hardware

## 12.1 Ordre de montage d'un PC

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

## 12.2 Précautions ESD (Décharges électrostatiques)

> **Attention — Erreur fréquente à l'examen**
> - L'électricité statique peut détruire les composants instantanément et silencieusement.
> - Toujours porter un bracelet anti-statique ou toucher une partie métallique mise à la terre avant de manipuler.
> - Travailler sur une surface antistatique ou sur la boîte carton du composant. Jamais sur moquette.
> - Tenir les cartes par les bords, jamais par les composants ou les contacts dorés.

## 12.2 (bis) Sécurité électrique et habilitation BS

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

## 12.3 Diagnostic des pannes hardware courantes

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

## 12.4 Outils de diagnostic

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

---

## Fiche récapitulative — Questions d'examen types

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
