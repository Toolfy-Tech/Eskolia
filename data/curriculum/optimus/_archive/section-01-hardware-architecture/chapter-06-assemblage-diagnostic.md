> **Parcours Optimus** - **Module 1** · Chapitre 6 sur 6 · *Assemblage et diagnostic hardware*.
>
> Contenu adapte depuis les chapitres Optimus Module 1.

## Source 1 - chapter-12-assemblage-depannage.md

> **Parcours Optimus** — **Module 1** · Chapitre 12 sur 12 · *Assemblage et dépannage hardware*.
>
> Contenu issu du cours Optimus (PDF) ; tableaux extraits du PDF ; illustrations sous `curriculum/optimus/images/`.

### 11.1. Ordre de montage d'un PC

- 1. Installer le CPU sur la carte mere (sans forcer, aligner le triangle)
- 2. Appliquer la pate thermique (grain de riz au centre)
- 3. Fixer le ventirad/watercooling
- 4. Installer la/les barrettes RAM dans les bons slots (dual channel)
- 5. Monter les entretoises dans le boitier (standoffs)
- 6. Installer la plaque I/O de la carte mere dans le boitier
- 7. Visser la carte mere sur les entretoises
- 8. Installer le PSU dans le boitier
- 9. Installer les SSD/HDD (M.2 directement, SATA avec cable)
- 10. Installer la carte graphique dans le slot PCIe x16
- 11. Brancher tous les cables (24 broches, CPU, PCIe, SATA, headers facade)
- 12. Premier demarrage : entrer dans le BIOS et verifier que tout est detecte
### 11.2. Precautions ESD (Decharges electrostatiques)

|         |**Attention - Erreur frequente a l'examen** L'electricite statique peut detruire les composants instantanement et silencieusement. Toujours porter un bracelet anti-statique ou toucher une partie metallique mise a la terre avant de manipuler des composants. Travailler sur une surface antistatique ou sur la boite carton du composant. Ne jamais sur moquette. Tenir les cartes par les bords, jamais par les composants ou les contacts dores.|

### 11.3. Diagnostic des pannes hardware courantes

- **Symptome** | **Causes possibles** | **Verifications a faire**
- PC ne demarre pas (aucun | Cable 24 broches ou CPU debranche, | Reverifier tous les cables, remettre la
- bip, aucun affichage) | RAM mal inseree, court-circuit | RAM, tester avec 1 seule barrette

- PC demarre mais aucun affichage | Mauvaise sortie video, GPU mal insere, ecran eteint | Tester la sortie vidéo de la carte mère si
- PC demarre mais aucun affichage | Mauvaise sortie video, GPU mal insere, ecran eteint | le processeur dispose d’un iGPU,
- PC demarre mais aucun affichage | Mauvaise sortie video, GPU mal insere, ecran eteint | reinserrer le GPU, tester un autre cable
- PC demarre mais aucun affichage | Mauvaise sortie video, GPU mal insere, ecran eteint | video
- PC s'eteint aleatoirement sous | PSU sous-dimensionne, surchauffe | Verifier temperatures (HWiNFO64),
- charge | CPU/GPU, RAM instable | tester PSU, verifier XMP/EXPO
- PC tres lent | Disque presque plein, RAM saturee, | Analyser avec gestionnaire des taches,
- PC tres lent | pilotes obsoletes, virus | liberer espace, mettre a jour pilotes
- Ecran bleu (BSOD) | RAM defectueuse, pilote corrompu, SSD | Memtest86 pour RAM, CrystalDiskInfo
- Ecran bleu (BSOD) | defaillant, surchauffe | pour SSD, DDU pour pilotes GPU
- Bruits de clic HDD | HDD en fin de vie (head crash) | Sauvegarder immediatement.
- Bruits de clic HDD | HDD en fin de vie (head crash) | Remplacer le disque. Ne pas attendre.
- PC ne detecte pas un SSD/HDD | Cable SATA defaillant, slot M.2 | Changer cable SATA, verifier mode AHCI dans BIOS, verifier slot M.2
- PC ne detecte pas un SSD/HDD | incompatible, vérifier le mode du
- PC ne detecte pas un SSD/HDD | contrôleur SATA (AHCI/RAID) dans
- PC ne detecte pas un SSD/HDD | l’UEFI/BIOS
- Date/heure incorrecte a | Pile CMOS morte | Remplacer pile CR2032
- chaque demarrage

### 11.4. Outils de diagnostic

- **Outil** | **Type** | **Utilisation**
- HWiNFO64 | Logiciel | Monitoring temperatures, tensions, vitesses ventilateurs
- ~~CPU-Z~~ne pas utiliser | Logiciel | Infos detaillees CPU, RAM, carte mere L'outil officiel (cpuid.com) est légitime mais de fausses versions ont été diffusées via Google Ads en 2023.
- GPU-Z | Logiciel | Infos detaillees GPU, VRAM, temperatures
- CrystalDiskInfo | Logiciel | Sante des disques SMART, temperatures SSD/HDD
- Memtest86 | Bootable | Test RAM hors OS. A faire tourner 2+ passes.
- CrystalDiskMark | Logiciel | Benchmark vitesses SSD/HDD en lecture/ecriture
- Prime95 | Logiciel | Test de stabilite CPU / stress test sous charge maximale
- FurMark | Logiciel | Stress test GPU. Verifie stabilite et refroidissement.

- **Questions frequentes sur la carte mere**
- Q : Quelle est la difference entre ATX et Micro-ATX ?
- R : Taille et nombre de slots d'extension. ATX = plus grand, plus de slots. Micro-ATX = plus compact.
- Q : A quoi sert le chipset ?
- R : A gerer les communications entre le CPU, la RAM, le stockage et les peripheriques.
- Q : Que se passe-t-il si la pile CMOS est morte ?
- R : La date/heure se remet a zero a chaque demarrage et les parametres BIOS sont perdus.

- **Questions frequentes sur le CPU et la RAM**
- Q : Quelle est la difference entre coeurs et threads ?
- R : Coeurs = unites physiques de calcul. Threads = coeurs logiques (HyperThreading = 2 threads/coeur).
- Q : DDR4 et DDR5 sont-ils compatibles ?
- R : Non. Ils ont des encoches differentes et ne sont pas physiquement interchangeables.
- Q : Qu'est-ce que le dual channel ?
- R : Installer 2 barrettes identiques dans les bons slots pour doubler la bande passante memoire.
- Q : Pourquoi la RAM ne tourne pas a sa frequence annoncee ?
- R : Il faut activer le profil XMP (Intel) ou EXPO (AMD) dans le BIOS.

- **Questions frequentes sur le stockage**
- Q : Quelle est la difference entre SSD SATA et SSD NVMe ?
- R : SATA max ~560 Mo/s. NVMe via PCIe : 3000 a 7000 Mo/s selon generation. NVMe beaucoup plus
- rapide.
- Q : Pourquoi ne peut-on pas copier un fichier de 10 Go sur une cle USB ?
- R : La cle est probablement formatee en FAT32, limite a 4 Go par fichier. Reformater en exFAT.
- Q : Quelle table de partitions utiliser pour un disque de 3 To sous Windows ?
- R : GPT. MBR est limite a 2 To.

- **Questions frequentes sur les connecteurs**
- Q : Comment identifier un port USB 3.0 ?
- R : La languette interieure du port est bleue. Debit : 5 Gb/s minimum.
- Q : Quelle est la difference entre HDMI et DisplayPort ?
- R : HDMI : standard TV/consoles/moniteurs grand public. DisplayPort : standard PC gaming, supporte des
- resolutions et taux de rafraichissement plus eleves.
- Q : VGA est-il encore utilise ?
- R : Oui, sur de vieux ecrans et PC. Mais c'est un signal analogique degrade. A remplacer par HDMI/DP si
- possible.

- **Questions frequentes sur le PSU et le BIOS**
- Q : Que signifie la certification 80 Plus Gold ?
- R : Le PSU a un rendement energetique d'au moins 87% en charge. Moins de chaleur et d'electricite
- gaspillee.
- Q : Quelle est la difference entre BIOS et UEFI ?
- R : BIOS = ancien firmware texte, MBR, max 2 To. UEFI = moderne, graphique, GPT, Secure Boot, plus
- rapide.
- Q : Pourquoi activer la virtualisation dans le BIOS ?
- R : Pour pouvoir faire tourner des machines virtuelles avec VMware, VirtualBox ou Hyper-V.
- Q : Qu'est-ce que le Secure Boot ?

| |R : Fonction UEFI qui verifie la signature numerique du bootloader pour empecher le demarrage de code|
| |malveillant.|

|**Composant**|**Valeur cle**|**A retenir**|
|---|---|---|
|ATX|305 x 244 mm|Format standard desktop|
|Mini-ITX|170 x 170 mm|Format mini|
|USB 2.0|480 Mb/s|Languette noire/blanche|
|USB 3.0|5 Gb/s|Languette bleue|
|SATA III|600 Mo/s max|7 broches donnees + 15 alimentation|
|SSD NVMe Gen3|3500 Mo/s|6x plus rapide que SATA|
|SSD NVMe Gen4|7000 Mo/s|12x plus rapide que SATA|
|FAT32 limite|4 Go / fichier|Attention cles USB|
|DDR4 tension|1.2V|DDR3 = 1.5V, DDR5 = 1.1V|
|Pile CMOS|CR2032|Pile bouton 3V|
|MBR limite disque|2 To|Au-dela = GPT obligatoire|
|PCIe x16|Slot GPU|Le plus long slot de la carte mere|
|Pate thermique|Grain de riz|Quantite et emplacement centre CPU|
|TPM 2.0|Windows 11 requis|Puce securite|
