> **Parcours Optimus** - **Module 1** · Chapitre 4 sur 6 · *Alimentation et refroidissement*.
>
> Contenu adapte depuis les chapitres Optimus Module 1.

## Source 1 - chapter-07-alimentation-psu.md

> **Parcours Optimus** — **Module 1** · Chapitre 7 sur 12 · *Alimentation (PSU)*.
>
> Contenu issu du cours Optimus (PDF) ; tableaux extraits du PDF ; illustrations sous `curriculum/optimus/images/`.

## 6. L'alimentation (PSU - Power Supply Unit)

Le PSU convertit le courant secteur (220V en courant alternatif) en courant continu de faible tension
utilisable par les composants (12V, 5V, 3.3V). Il distribue l’énergie aux différents composants en étant
équipé de protection contre les surtensions, court-circuit, etc. Un PSU sous-dimensionne provoque
instabilite et pannes.

### 6.1. Caracteristiques principales

- **Caracteristique** | **Description**
- Puissance (Watts) | Règle des 20-30% de la capacite totale :**Choisir 20-30% de marge au-dessus de**
- Puissance (Watts) | **la consommation reelle.**
- Certification 80 Plus | Rendement énergétique :**White < Bronze < Silver < Gold < Platinum < Titanium**.
- Certification 80 Plus | Garantit qu'au moins 80% du courant est converti (le reste est perdu en chaleur).
- Modulaire | **Full** (tous les câbles détachables),**Semi** (câbles vitaux fixes) ou**Non-modulaire**.
- Modulaire | Facilite le_cable management_ et le flux d'air.
- Format | **ATX** (standard),**SFX** (compact),**TFX** (slim). Doit impérativement correspondre au
- Format | format supporté par le boîtier.

![Image 6](../images/image_006.png)

|PFC actif| |_Power Factor Correction_. Optimise la consommation électrique. Présent sur tous les modèles de qualité moderne.|

*Câble IEC : câble secteur qui entre dans le PSU
### 6.2. Connecteurs du PSU

- **Connecteur** | **Broches** | **Tensions** | **Destination** | **Remarques**
- ATX 24 broches | 24 pins | +3.3V, +5V, | Alimentation principale de la carte mere | Connecteur indispensable, toujours présent
- ATX 24 broches | 24 pins | +12V, -12V,
- ATX 24 broches | 24 pins | +5Vsb
- EPS / CPU | 4+4 ou 8 | +12V | Alimentation du processeur | Le format 4+4 permet l'adaptation
- EPS / CPU | broches | (pres du socket CPU) | selon le socket
- PCIe | 6 ou 8 | +12V | Alimentation de la carte graphique | Nouveau connecteur 16 broches
- PCIe | broches | (12VHPWR) sur GPU haut de gamme
- PCIe | (6+2) | RTX 4000/5000+
- SATA | 15 | +3.3V, +5V, +12V | Alimentation des HDD / SSD SATA / lecteurs optiques | Distinct du connecteur SATA données (7 broches, relié à la carte mère)
- SATA | broches
- SATA | en L
- Molex | 4 | +5V, +12V | Anciens peripheriques, | Progressivement remplacé par SATA
- Molex | broches | ventilateurs, eclairage | alimentation
- Floppy | 4 | +5V | Obsolete. Parfois utilise pour | 5V uniquement
- Floppy | broches | certains boitiers ou
- Floppy | petit | controleurs

### 6.3. Calcul de la puissance necessaire

### Methode de calcul PSU

1. Relevez la consommation GPU (ex : 200W sous charge) et le TDP du CPU (ex : 65W).
2. Ajoutez les autres composants : RAM (~5W), SSD (~5W), HDD (~8W), carte mere (~50W).

3. Total estimatif : 65 + 200 + 5 + 5 + 8 + 50 = 333W.
4. Ajoutez 20-30% de marge : 333 x 1.25 = ~416W.

5. Choisissez un PSU de 500W minimum dans cet exemple.

Thermal Design Power (TDP), ou enveloppe thermique nominale : mesure la quantite maximale de chaleur qu'un systeme de refroidissement (ventilateur, watercooling) doit dissiper pour que le processeur fonctionne correctement a sa frequence de base.

Outil utile : PCPartPicker.com ou OuterVision PSU Calculator.

> **Attention - Erreur frequente a l'examen**  
> Un PSU pas assez puissant = redemarrages aleatoires, coupures sous charge, corruption de donnees.  

> Un PSU de mauvaise qualite sans certification 80 Plus peut endommager les autres composants en cas de surtension.  
> Ne jamais ouvrir un PSU : les condensateurs gardent une charge electrique dangereuse meme PC eteint et debranche.

## Source 2 - chapter-10-refroidissement.md

> **Parcours Optimus** — **Module 1** · Chapitre 10 sur 12 · *Refroidissement*.
>
> Contenu issu du cours Optimus (PDF) ; tableaux extraits du PDF ; illustrations sous `curriculum/optimus/images/`.

### 9.1. Pourquoi refroidir ?

Les composants électroniques (CPU, GPU, VRM, RAM) produisent de la chaleur par effet Joule. Sans
évacuation thermique :

- les performances baissent (throttling = réduction automatique de fréquence)
- la durée de vie des composants diminue
- dans les cas extrêmes, arrêt d'urgence ou dommages permanents

### 9.2. Les types de refroidissement

- Refroidissement par air (le plus courant). Il est composé de deux éléments indissociables : Le
dissipateur thermique (heatsink) Bloc de métal (aluminium ou cuivre) qui absorbe la chaleur du
composant et augmente la surface de dissipation via ses ailettes. Et Le ventilateur (fan) Fait
circuler l'air à travers les ailettes pour évacuer la chaleur. Contrôlé par la carte mère via le signal
PWM (régulation de vitesse selon la température). Pâte thermique : Matériau conducteur appliqué
entre le CPU/GPU et le dissipateur. Elle comble les micro-irrégularités de surface qui
emprisonneraient de l'air (mauvais conducteur thermique). En intervention : ne jamais remonter
un ventirad sans renouveler la pâte thermique si elle est sèche ou craquelée.

- Watercooling (refroidissement liquide) L'eau conduit mieux la chaleur que l'air. Deux variantes : AIO
(All-In-One) Circuit fermé prêt à l'emploi. Pompe + radiateur + ventilateurs intégrés. Facile à
installer, entretien minimal. Standard sur les PC gaming et workstations. / Custom loop Circuit
ouvert configurable (reservoir, pompe séparée, waterblocks GPU/RAM). Très performant, très
coûteux, maintenance régulière. Niche (overclocking extrême).

- Refroidissement passif : Aucun ventilateur. Le dissipateur seul évacue la chaleur par convection
naturelle. Silencieux, zéro panne mécanique. Limité aux composants basse consommation (mini-
PC, NAS, composants embarqués).

### 9.3. La circulation d'air dans le boîtier

Un bon refroidissement ne dépend pas que des composants — la circulation d'air dans le boîtier est
critique. Règle de base : les ventilateurs d'entrée (intake) en façade/bas, les ventilateurs de sortie

(exhaust) en arrière/haut. La chaleur monte naturellement. Pression positive (plus d'entrée que de sortie)
→ moins de poussière, recommandé avec filtres. Pression négative (plus de sortie que d'entrée) → aspire
la poussière, déconseillé.

### 9.4. Températures de référence (au repos / en charge)

Composant
Normal repos
Normal charge
Seuil d'alerte
CPU (modern)
30–45 °C
70–85 °C
> 95 °C
GPU
35–50 °C
75–85 °C
> 95 °C
SSD NVMe
35–50 °C
60–70 °C
> 80 °C
HDD
30–40 °C
40–50 °C
> 55 °C
*certains CPU modernes atteignent 95°C en fonctionnement normal
### 9.5. Outils de diagnostic en intervention

Outil
Usage

HWMonitor
Températures, vitesses ventilateurs,
tensions
MSI Afterburner
Monitoring GPU en temps réel
CrystalDiskInfo
Température SSD/HDD via SMART
BIOS/UEFI
Températures CPU, vitesses fans sans OS

À retenir pour le support IT :

- Un PC qui s'éteint seul sous charge → vérifier les températures en premier
- Un CPU à 100 % sans raison → peut être du throttling thermique, pas un problème logiciel
- Nettoyage des filtres et radiateurs = maintenance préventive essentielle (poussière = isolation
thermique)
- Renouveler la pâte thermique tous les 3–5 ans sur un laptop, moins souvent sur desktop
