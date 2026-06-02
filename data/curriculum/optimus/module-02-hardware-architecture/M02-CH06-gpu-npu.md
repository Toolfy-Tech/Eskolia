> **Parcours Optimus — Module 2 · Chapitre 6 sur 12**

# La carte graphique (GPU)... et NPU

Le GPU (Graphics Processing Unit) gère l'affichage. Deux types : les **GPU dédiés** (carte graphique indépendante) et les **GPU intégrés (iGPU)** intégrés au processeur (Intel UHD / Iris Xe, AMD Radeon). Les GPU intégrés aux chipsets de carte mère sont obsolètes depuis ~2010.

## 6.1 GPU intégré vs GPU dédié

| Critère | GPU intégré (iGPU) | GPU dédié (dGPU) |
|---|---|---|
| Localisation | Dans le CPU (sur carte mère = ancien, avant ~2010) | Carte PCIe indépendante |
| Mémoire | Utilise la RAM système | VRAM dédiée (4, 8, 16 Go...) |
| Performances | Suffisant pour bureau/vidéo/2D | Indispensable pour gaming/3D/IA |
| Consommation | Très faible (intégré au CPU) | Élevée (100W à 400W+) |
| Exemples | Intel UHD, AMD Radeon Vega | NVIDIA GeForce, AMD Radeon RX |

## 6.2 Connexion et alimentation

- **Interface** : slot PCIe x16 sur la carte mère (le plus grand slot).
- **Alimentation** : connecteur PCIe 6 ou 8 broches (ou 12 broches pour les puissantes).
- **Sorties vidéo** : HDMI, DisplayPort, DVI, VGA (obsolète).

## 6.3 Sorties vidéo — Comparatif

| Connecteur | Résolution max | Audio | Remarques |
|---|---|---|---|
| HDMI 2.1 | 10K / 8K@120Hz | Oui | Standard TV et moniteurs récents |
| DisplayPort 2.1 | 16K | Oui | Standard PC gaming, écrans haut de gamme |
| DVI-D | 2560×1600 | Non | Ancien standard, encore présent sur certains écrans |
| VGA (D-Sub) | Analogique | Non | Obsolète. À éviter. Ne supporte pas la HD sans dégradation. |
| USB-C / Thunderbolt | 8K | Oui | Laptops et moniteurs modernes |

> **À retenir — GPU**
> - Sans GPU dédié, jeux 3D et logiciels de conception sont possibles mais avec performances limitées. La VRAM est séparée de la RAM système sur les GPU dédiés.
> - VGA est un signal analogique : qualité inférieure. Toujours privilégier HDMI ou DisplayPort.

## 6.4 Les NPU (Neural Processing Units) : l'accélérateur d'IA

Le NPU est une unité matérielle spécialisée dans certains calculs liés à l'intelligence artificielle, notamment les calculs matriciels. Il exécute localement certaines tâches d'IA de manière plus efficace énergétiquement que le CPU ou le GPU. Son but : décharger le CPU et le GPU pour préserver l'autonomie et la réactivité.

Principaux acteurs : Intel (Core Ultra), AMD (Ryzen AI), Apple (Neural Engine), Qualcomm (Snapdragon X Elite). Intégré directement au processeur central (SoC). Fréquent sur les PC récents, surtout les portables milieu/haut de gamme.

- **Performance** : mesurée en TOPS (Trillions d'Opérations Par Seconde).
- **Usage concret** : reconnaissance vocale, amélioration d'image en temps réel, réduction de bruit intelligente, sécurité des données (traitement local sans cloud).
- **Maintenance** : surveiller les pilotes spécifiques ; l'activité du NPU peut être visible dans le Gestionnaire des tâches de Windows 11, onglet Performance.

Les trois composants (CPU, GPU, NPU) partagent le même bus mémoire RAM : le NPU ne remplace pas le CPU ou le GPU, ils coopèrent au sein du même SoC.

> L'intégration des NPU nécessite un minimum de 16 Go de RAM (norme Copilot+) pour gérer les modèles d'IA localement. Cette demande, couplée à la priorité donnée par les fabricants aux serveurs d'IA, a fait bondir le prix des puces DDR5 de plus de 50 % depuis 2025.
