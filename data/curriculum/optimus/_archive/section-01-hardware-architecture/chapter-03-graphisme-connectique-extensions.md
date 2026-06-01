> **Parcours Optimus** - **Module 1** · Chapitre 3 sur 6 · *GPU, connectique et extensions*.
>
> Contenu adapte depuis les chapitres Optimus Module 1.

## Source 1 - chapter-06-gpu-npu.md

> **Parcours Optimus** — **Module 1** · Chapitre 6 sur 12 · *Carte graphique (GPU) et NPU*.
>
> Contenu issu du cours Optimus (PDF) ; tableaux extraits du PDF ; illustrations sous `curriculum/optimus/images/`.

## 5. La carte graphique (GPU)... et NPU

![Image 5](../images/image_005.jpeg)

Le GPU (Graphics Processing Unit) gere l'affichage. Il existe deux types : les GPU dedies (carte graphique
independante) et les GPU intégrés (iGPU) : intégré au processeur (Intel UHD / Iris Xe, AMD Radeon). Les
GPU intégrés aux chipsets de carte mère sont obsolètes depuis ~2010.

### 5.1. GPU integre vs GPU dedie

- **Critere** | **GPU integre (iGPU)** | **GPU dedie (dGPU)**
- Localisation | Dans le CPU (GPU sur carte mère | Carte PCIe independante
- Localisation | = ancien (chipsets d’avant ~2010)
- Memoire | Utilise la RAM systeme | VRAM dediee (4 Go, 8 Go, 16 Go...)
- Performances | Suffisant pour bureau/video/2D | I | ndispensable pour gaming/3D/IA
- Consommation | Tres faible (integre au CPU) | Elevee (100W a 400W+)
- Exemples | Intel UHD, AMD Radeon Vega | NVIDIA GeForce, AMD Radeon RX

### 5.2. Connexion et alimentation

- Interface : slot PCIe x16 sur la carte mere (le plus grand slot)
- Alimentation : connecteur PCIe 6 ou 8 broches (ou 12 broches pour les puissantes)
- Sorties video : HDMI, DisplayPort, DVI, VGA (obsolete)
### 5.3. Sorties video - Comparatif

- **Connecteur** | **Resolution max** | **Audio** | **Remarques**
- HDMI 2.1 | 10K / 8K@120Hz | Oui | Standard TV et moniteurs recents
- DisplayPort 2.1 | 16K | Oui | Standard PC gaming, ecrans haut de gamme
- DVI-D | 2560x1600 | Non | Ancien standard, encore present sur certains ecrans
- VGA (D-Sub) | Analogique | Non | Obsolete. A eviter. Ne supporte pas la HD sans degradation.
- USB-C / Thunderbolt | 8K | Oui | Laptops et moniteurs modernes

- **A retenir - GPU**
- Sans GPU dedie, les jeux 3D et logiciels de conception graphique sont possibles mais avec performances
- limitées. La VRAM (memoire video) est separee de la RAM systeme sur les GPU dedies.
- VGA est un signal analogique : qualite d'image inferieure. Toujours privilegier HDMI ou DisplayPort.

### 5.4. Les NPU (Neural Processing Units) : l’accélérateur d’IA

Le NPU (Neural Processing Unit) est une unité matérielle spécialisée dans certains calculs liés à
l’intelligence artificielle, notamment les calculs matriciels. Il permet d’exécuter localement certaines tâches
d’IA de manière plus efficace énergétiquement que le CPU ou le GPU dans certains usages. Son but est
de décharger le CPU et le GPU pour préserver l'autonomie et la réactivité du système.
Les principaux acteurs sont Intel (Core Ultra), AMD (Ryzen AI), Apple (Neural Engine) et Qualcomm
(Snapdragon X Elite). Intégré directement au processeur central (SoC), son prix ne se détaille pas
séparément. (à partir d'environ 250 € pour le processeur complet) Les NPU deviennent fréquents sur les
PC récents, surtout les portables de milieu et haut de gamme. .

- Performance : Mesurée en TOPS (Trillions d'Opérations Par Seconde). certaines certifications
constructeurs ou marketing imposent des seuils minimaux de TOPS.

- Usage concret : Reconnaissance vocale, amélioration d'image en temps réel, réduction de bruit
intelligente et sécurité des données (traitement local sans passer par le cloud).
- Maintenance : le technicien doit surveiller les pilotes spécifiques et, sur certaines machines
compatibles, l’activité du NPU peut être visible dans le Gestionnaire des tâches de Windows 11,
onglet Performance.

Les trois composants partagent le même bus mémoire RAM, ce qui illustre bien pourquoi le NPU ne

remplace pas le CPU ou le GPU — ils coopèrent au sein du même SoC.

✅ L'intégration des NPU nécessite un minimum de 16 Go de RAM (norme Copilot+) pour gérer les
modèles d'IA localement, créant une tension massive sur la production mondiale. Cette demande, couplée
à la priorité donnée par les fabricants aux serveurs d'IA, a fait bondir le prix des puces DDR5 de plus de 50
% depuis 2025.

## Source 2 - chapter-08-connecteurs-ports.md

> **Parcours Optimus** — **Module 1** · Chapitre 8 sur 12 · *Connecteurs et ports externes*.
>
> Contenu issu du cours Optimus (PDF) ; tableaux extraits du PDF ; illustrations sous `curriculum/optimus/images/`.

- **Standard** | **Debit max** | **Couleur** | **Forme** | **Remarques**
- **Standard** | **Debit max** | **connecteur**

![Image 7](../images/image_007.jpeg)

- USB 2.0 | 480 Mb/s (60 | Noir / blanc | Type-A | Standard ancien, toujours tres
- USB 2.0 | Mo/s) | repandu
- USB 3.0 / 3.1 | 5 Gb/s (625 Mo/s) | Bleu | Type-A ou C | Appele aussi USB 3.2 Gen1
- Gen1
- USB 3.1 Gen2 | 10 Gb/s (1.25 | Rouge / bleu | Type-A ou C | Appele aussi USB 3.2 Gen2
- USB 3.1 Gen2 | Go/s)
- USB 3.2 Gen2x2 | 20 Gb/s | Generalement C | Type-C | Rare, specifique
- USB4 / | 40 Gb/s | Type-C | Compatible video, daisy chain,
- Thunderbolt 4 | alimentation

### 7.2. Formes des connecteurs USB

|**Forme**|**Usage**|
|---|---|
|Type-A (rectangle plat)|PC, chargeurs, hubs. Le plus courant cote 'host'.|
|---|---|
|Type-B (carre avec coins coupes)|Imprimantes, scanners, anciens peripheriques.|
|---|---|
|Mini-USB (trapeze petit)|Anciens appareils photo, GPS, disques externes. Obsolete.|
|Micro-USB (trapeze tres plat)|Smartphones anciens, manettes. En voie d'obsolescence.|
|Type-C (ovale symetrique)|Standard actuel : smartphones, laptops, moniteurs, accessoires.|

### 7.3. Ports reseau et audio

- **Port** | **Description**
- RJ-45 (Ethernet) | Reseau filaire. 8 broches. 100 Mb/s (Fast), 1 Gb/s (Gigabit), 2.5/10 Gb/s (haute perf).
- Jack 3.5mm | Audio analogique. Vert = sortie audio. Rose = entree micro. Bleu = entree ligne.
- Optique | Audio numerique optique. Qualite superieure au Jack.
- TOSLINK
- HDMI (type A) | 19 broches. Video + audio numerique. Standard TV/moniteur.
- DisplayPort | 20 broches. Video + audio. Standard PC gaming.

![Image 8](../images/image_008.jpeg)

### 7.4. Ports d'affichage legacy*

- **Port** | **Broches** | **Signal** | **Statut**
- VGA (D-Sub 15) | 15 broches | Analogique | Obsolete. Encore present sur anciens
- VGA (D-Sub 15) | 15 broches | Analogique | ecrans.
- DVI-I | 29 broches | Analogique + | Ancien standard
- DVI-I | 29 broches | Numerique
- DVI-D Single Link | 19 broches | Numerique | Max 1920x1200
- DVI-D Dual Link | 25 broches | Numerique | Max 2560x1600
- **A retenir - Connecteurs USB**
- La couleur BLEUE d'un port USB-A = USB 3.0 minimum. Port NOIR ou BLANC = USB 2.0.
- USB Type-C ne signifie pas forcement USB 4 ou Thunderbolt : la forme est la meme mais les debits varient.
- VGA = signal analogique degradable. Toujours lui preferer HDMI ou DisplayPort.

* Legacy désigne une technologie ancienne, conservée pour compatibilité, mais : technologiquement
dépassée, plus développée activement, remplacée par des standards plus récents.

Legacy ≠ inutilisable, mais non recommandée pour du matériel moderne.

## Source 3 - chapter-09-bus-extensions.md

> **Parcours Optimus** — **Module 1** · Chapitre 9 sur 12 · *Bus et slots d'extension*.
>
> Contenu issu du cours Optimus (PDF) ; tableaux extraits du PDF ; illustrations sous `curriculum/optimus/images/`.

## 8. Les bus et slots d'extension

### 8.1. Le bus PCIe (PCI Express)

PCIe est le bus d'extension principal des PC modernes. Il sert a connecter GPU, SSD NVMe, cartes
reseau, etc.

- **Version PCIe** | **Debit par lane** | **Slot x16 total** | **Usage**
- PCIe 3.0 | ~1 Go/s / lane | ~16 Go/s | Standard encore tres repandu
- PCIe 4.0 | ~2 Go/s / lane | ~32 Go/s | GPU recents, SSD NVMe Gen4
- PCIe 5.0 | ~4 Go/s / lane | ~64 Go/s | Plateformes 2023+ (Intel 13e gen, AMD Ryzen
- PCIe 5.0 | ~4 Go/s / lane | ~64 Go/s | 7000)
- PCIe 6.0 | ~8 Go/s / lane | ~128 Go/s | En cours de deploiement (serveurs)

### 8.2. Tailles de slots PCIe

![Image 9](../images/image_009.jpeg)

- **Slots PCIe - Tailles et compatibilite**
- x1  : petit slot. Cartes reseau, cartes son, cartes d'acquisition. 1 lane.
- x4  : slot moyen. SSD NVMe en adaptateur, cartes HBA.
- x8  : slot grand. Cartes RAID, certains GPU secondaires.
- x16 : le plus grand slot. Reserve au GPU principal.
- COMPATIBILITE : une carte PCIe peut s'inserer dans un slot plus grand (x1 dans x16) mais tournera a la
- bande passante du slot de la carte.
- PCIe est rétrocompatible : une carte PCIe 4.0 peut fonctionner sur un port PCIe 3.0 (avec performances
- réduites)

### 8.3. Anciens bus (a connaitre pour les pannes)

|**Bus**|**Periode**|**Description**|
|---|---|---|
|PCI|1992-2010|Avant PCIe. Slots blancs sur anciennes cartes. Debit faible (133 Mo/s).|
|AGP|1997-2004|Slot dedie aux cartes graphiques. Remplace par PCIe.|
|ISA|1981-2000|Tres ancien bus 8/16 bits. Uniquement sur machines d'avant 2000.|
