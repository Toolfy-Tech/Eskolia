> **Parcours Optimus — Module 2 · Chapitre 7 sur 12**

# L'alimentation (PSU - Power Supply Unit)

Le PSU convertit le courant secteur (220V alternatif) en courant continu de faible tension (12V, 5V, 3.3V). Il distribue l'énergie et protège contre surtensions, court-circuit, etc. Un PSU sous-dimensionné provoque instabilité et pannes.

## 7.1 Caractéristiques principales

| Caractéristique | Description |
|---|---|
| Puissance (Watts) | Règle des 20-30 % : choisir 20-30 % de marge au-dessus de la consommation réelle. |
| Certification 80 Plus | Rendement énergétique : White < Bronze < Silver < Gold < Platinum < Titanium. Garantit qu'au moins 80 % du courant est converti (le reste perdu en chaleur). |
| Modulaire | Full (tous câbles détachables), Semi (câbles vitaux fixes) ou Non-modulaire. Facilite le cable management et le flux d'air. |
| Format | ATX (standard), SFX (compact), TFX (slim). Doit correspondre au format supporté par le boîtier. |
| PFC actif | Power Factor Correction. Optimise la consommation électrique. Présent sur tous les modèles de qualité moderne. |

> Câble IEC : câble secteur qui entre dans le PSU.

## 7.2 Connecteurs du PSU

| Connecteur | Broches | Tensions | Destination | Remarques |
|---|---|---|---|---|
| ATX 24 broches | 24 pins | +3.3V, +5V, +12V, -12V, +5Vsb | Alimentation principale carte mère | Indispensable, toujours présent |
| EPS / CPU | 4+4 ou 8 broches | +12V | Alimentation du processeur (près du socket CPU) | Le 4+4 permet l'adaptation selon le socket |
| PCIe | 6 ou 8 broches (6+2) | +12V | Alimentation carte graphique | Nouveau connecteur 16 broches (12VHPWR) sur GPU haut de gamme RTX 4000/5000+ |
| SATA | 15 broches en L | +3.3V, +5V, +12V | Alimentation HDD / SSD SATA / lecteurs optiques | Distinct du connecteur SATA données (7 broches) |
| Molex | 4 broches | +5V, +12V | Anciens périphériques, ventilateurs, éclairage | Progressivement remplacé par SATA alimentation |
| Floppy | 4 broches petit | +5V | Obsolète. Parfois pour certains boîtiers/contrôleurs | 5V uniquement |

## 7.3 Calcul de la puissance nécessaire

1. Relever la consommation GPU (ex : 200W sous charge) et le **TDP** du CPU (ex : 65W). *TDP (Thermal Design Power) = quantité maximale de chaleur qu'un système de refroidissement doit dissiper pour que le processeur fonctionne correctement à sa fréquence de base.*
2. Ajouter les autres composants : RAM (~5W), SSD (~5W), HDD (~8W), carte mère (~50W).
3. Total estimatif : 65 + 200 + 5 + 5 + 8 + 50 = **333W**.
4. Ajouter 20-30 % de marge : 333 × 1.25 = **~416W**.
5. Choisir un PSU de **500W minimum** dans cet exemple.

Outils utiles : PCPartPicker.com, OuterVision PSU Calculator.

> **Attention — Erreur fréquente à l'examen**
> - PSU pas assez puissant = redémarrages aléatoires, coupures sous charge, corruption de données.
> - PSU de mauvaise qualité sans certification 80 Plus peut endommager les autres composants en cas de surtension.
> - Ne jamais ouvrir un PSU : les condensateurs gardent une charge électrique dangereuse même PC éteint et débranché.

## 7.4 L'onduleur (UPS) — protéger les équipements critiques

> 🤖 *Section ajoutée avec l'assistance d'une IA — à relire et vérifier avant usage.*

Le PSU protège un poste contre les défauts internes, mais pas contre les **problèmes du secteur** (coupure, micro-coupure, surtension, baisse de tension). L'**onduleur** (UPS — *Uninterruptible Power Supply*) s'intercale entre la prise murale et l'équipement : il contient une **batterie** qui prend instantanément le relais en cas de coupure, et **filtre** les perturbations électriques.

Son rôle n'est pas de faire fonctionner longtemps la machine sans courant, mais de **laisser le temps d'un arrêt propre** (ou de tenir le temps qu'un groupe électrogène prenne le relais), évitant ainsi corruption de données et redémarrages brutaux.

**Pour qui ?** Les **équipements critiques** : serveurs, NAS/stockage, équipements réseau (switch, routeur, box), poste de supervision. Un onduleur sur un serveur de production ou un NAS d'entreprise est indispensable.

| Type d'onduleur | Principe | Usage |
|---|---|---|
| **Off-line (standby)** | Bascule sur batterie au moment de la coupure | Postes individuels, petits équipements |
| **Line-interactive** | Régule en continu les variations de tension + batterie | PME, petits serveurs (bon compromis) |
| **Online (double conversion)** | L'équipement est toujours alimenté par la batterie (zéro coupure de bascule) | Datacenters, serveurs critiques |

**Critères de choix** : la **puissance** (en VA / Watts, à dimensionner selon les équipements branchés), l'**autonomie** (durée sur batterie), le nombre et le type de prises, et la **communication** (port USB/réseau pour déclencher un **arrêt automatique propre** des serveurs via un logiciel dédié).

> **Réflexe terrain** : la batterie d'un onduleur **s'use** (durée de vie ~3 à 5 ans). Un onduleur dont la batterie est morte ne protège plus rien, alors qu'il semble fonctionner. Tester/remplacer les batteries fait partie de la maintenance préventive. Ne pas brancher d'imprimante laser sur un onduleur (appel de courant trop élevé).
