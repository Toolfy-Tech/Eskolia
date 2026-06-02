> **Parcours Optimus — Module 2 · Chapitre 3 sur 12**

# Le processeur (CPU)

Le CPU (Central Processing Unit) est le cerveau de l'ordinateur. Il interprète et exécute les instructions des programmes selon un cycle perpétuel en 4 étapes :

1. **Fetch (Recherche)** : récupération de l'instruction en mémoire.
2. **Decode (Interprétation)** : décodage du code opération et des opérandes par l'unité de contrôle.
3. **Execute (Exécution)** : réalisation de l'opération par l'UAL.
4. **Writeback (Écriture)** : enregistrement du résultat en registre ou en RAM.

**Architecture interne :**

- **Unité de contrôle** : dirige le flux de données et coordonne les autres unités.
- **UAL (Unité Arithmétique et Logique)** : effectue les calculs (+, -, ×) et les comparaisons logiques.
- **Registres (32/64 bits)** : zones de stockage ultra-rapides (ex : Compteur Ordinal, Registre d'état).
- **Horloge** : génère des impulsions pour synchroniser et cadencer les traitements (mesurée en GHz).
- **Bus** : canaux de communication (Données, Adresses et Contrôle).

**Technologies modernes** : les processeurs actuels intègrent de la mémoire cache (SRAM) pour réduire les temps d'accès, ainsi que le pipelining et l'unité de prédiction de branchement pour optimiser l'exécution des instructions en anticipant les besoins du programme.

## 3.1 Caractéristiques clés

| Caractéristique | Définition | Exemple |
|---|---|---|
| Nombre de coeurs (cores) | Un processeur à un cœur traite une seule consigne à la fois (en série). Un CPU multi-cœurs possède plusieurs cœurs physiques indépendants pouvant exécuter des tâches simultanément. Plus de cœurs = meilleur multitâche. | 4, 8, 16 cœurs... |
| Nombre de threads | Cœurs logiques. Avec HyperThreading = 2× cœurs physiques (chez AMD : SMT, Simultaneous Multi-Threading). | 8 cœurs = 16 threads |
| Fréquence (GHz) | Nombre de cycles par seconde. Plus = calculs plus rapides. | 3.6 GHz (3,6 milliards de cycles/s ; 1 cycle ≠ 1 instruction, IPC variable), 5.0 GHz... |
| Cache L1 / L2 / L3 | Mémoire ultra-rapide intégrée au CPU. L1 < L2 < L3 (taille) — technologie SRAM. | L3 = 12 Mo, 32 Mo... |
| TDP (Watts) | Chaleur dissipée = consommation indicative. Important pour le choix du ventirad. | 65W, 95W, 125W... |
| Architecture (nm) | Finesse de gravure : impacte surtout la chauffe et la consommation. Plus c'est fin, plus on peut mettre de transistors dans le même espace. | 7nm, 5nm, 4nm... |

## 3.2 Principaux fabricants et sockets

| Fabricant | Gamme | Socket | Particularité |
|---|---|---|---|
| Intel | Core i3 / i5 / i7 / i9 | LGA 1700 (12e/13e/14e gen) ; LGA 1851 (Core Ultra / Arrow Lake) | Broches sur la carte mère (LGA) |
| AMD | Ryzen 3 / 5 / 7 / 9 | AM4, AM5 | Broches sur le CPU (PGA pour AM4, LGA pour AM5) |
| Intel | Xeon | LGA 3647 / 4677 | Serveurs et workstations |
| AMD | EPYC / Threadripper | TR4 / SP3 / SP5 | Serveurs et workstations |

## 3.3 Refroidissement CPU

- **Ventirad (air cooler)** : radiateur + ventilateur. Suffisant pour la majorité des usages.
- **Watercooling AIO** : radiateur + pompe + ventilateurs. Plus efficace pour CPU chauds.
- **Pâte thermique** : indispensable entre le CPU et le ventirad pour conduire la chaleur.

> **Attention — Erreur fréquente à l'examen**
> - LGA et PGA ne sont pas identiques : LGA = broches sur le socket de la carte mère, PGA = broches sur le CPU.
> - Un CPU Intel ne s'installe pas sur un socket AMD et vice versa.
> - Ne jamais oublier la pâte thermique lors du montage : sans elle, le CPU surchauffe en quelques secondes.
