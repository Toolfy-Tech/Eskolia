> **Parcours Optimus — Module 2 · Chapitre 10 sur 12**

# Refroidissement

## 10.1 Pourquoi refroidir ?

Les composants (CPU, GPU, VRM, RAM) produisent de la chaleur par effet Joule. Sans évacuation thermique :

- les performances baissent (**throttling** = réduction automatique de fréquence) ;
- la durée de vie des composants diminue ;
- dans les cas extrêmes : arrêt d'urgence ou dommages permanents.

## 10.2 Les types de refroidissement

- **Refroidissement par air** (le plus courant) : deux éléments indissociables :
  - Le **dissipateur thermique (heatsink)** : bloc de métal (aluminium/cuivre) qui absorbe la chaleur et augmente la surface de dissipation via ses ailettes.
  - Le **ventilateur (fan)** : fait circuler l'air à travers les ailettes. Contrôlé par la carte mère via le signal **PWM** (régulation de vitesse selon la température).
  - **Pâte thermique** : comble les micro-irrégularités de surface qui emprisonneraient de l'air. En intervention : ne jamais remonter un ventirad sans renouveler la pâte si elle est sèche ou craquelée.
- **Watercooling (refroidissement liquide)** : l'eau conduit mieux la chaleur que l'air.
  - **AIO (All-In-One)** : circuit fermé prêt à l'emploi (pompe + radiateur + ventilateurs). Facile à installer, entretien minimal. Standard sur PC gaming et workstations.
  - **Custom loop** : circuit ouvert configurable (réservoir, pompe séparée, waterblocks GPU/RAM). Très performant, très coûteux, maintenance régulière. Niche (overclocking extrême).
- **Refroidissement passif** : aucun ventilateur, dissipateur seul (convection naturelle). Silencieux, zéro panne mécanique. Limité aux composants basse consommation (mini-PC, NAS, embarqué).

## 10.3 La circulation d'air dans le boîtier

Règle de base : ventilateurs d'entrée (**intake**) en façade/bas, ventilateurs de sortie (**exhaust**) en arrière/haut (la chaleur monte). **Pression positive** (plus d'entrée que de sortie) → moins de poussière, recommandé avec filtres. **Pression négative** (plus de sortie que d'entrée) → aspire la poussière, déconseillé.

## 10.4 Températures de référence (au repos / en charge)

| Composant | Normal repos | Normal charge | Seuil d'alerte |
|---|---|---|---|
| CPU (moderne) | 30–45 °C | 70–85 °C | > 95 °C |
| GPU | 35–50 °C | 75–85 °C | > 95 °C |
| SSD NVMe | 35–50 °C | 60–70 °C | > 80 °C |
| HDD | 30–40 °C | 40–50 °C | > 55 °C |

*Certains CPU modernes atteignent 95 °C en fonctionnement normal.*

## 10.5 Outils de diagnostic en intervention

| Outil | Usage |
|---|---|
| HWMonitor | Températures, vitesses ventilateurs, tensions |
| MSI Afterburner | Monitoring GPU en temps réel |
| CrystalDiskInfo | Température SSD/HDD via SMART |
| BIOS/UEFI | Températures CPU, vitesses fans sans OS |

> **À retenir pour le support IT :**
> - PC qui s'éteint seul sous charge → vérifier les températures en premier.
> - CPU à 100 % sans raison → peut être du throttling thermique, pas un problème logiciel.
> - Nettoyage des filtres et radiateurs = maintenance préventive essentielle (poussière = isolation thermique).
> - Renouveler la pâte thermique tous les 3–5 ans sur un laptop, moins souvent sur desktop.
