> **Parcours Optimus — Module 5 · Chapitre 6 sur 7**

# Protection du système : le RAID

La sauvegarde protège contre la perte logique (suppression, ransomware, corruption). Le **RAID** protège contre la panne matérielle — il maintient le système en fonctionnement même si un disque physique lâche. Deux couches complémentaires, jamais interchangeables.

**Définition** : le RAID (Redundant Array of Independent Disks) combine plusieurs disques durs en un seul volume logique. Selon le niveau : performance, sécurité, ou les deux.

> Le RAID n'est pas une sauvegarde. Si un fichier est supprimé ou corrompu, le RAID ne le récupère pas — il réplique aussi la suppression.

## 6.1 RAID 0, RAID 1 et RAID 5

**RAID 0 — Performance** (striping : données découpées et réparties sur plusieurs disques simultanément)
- Disques minimum : 2
- Performance : élevée
- Tolérance aux pannes : aucune (un disque tombe = tout est perdu)
- Capacité utile : 100 % (2× 1 To = 2 To)
- Usage : montage vidéo, jeux (vitesse > sécurité)

**RAID 1 — Sécurité** (mirroring : données copiées à l'identique sur deux disques)
- Disques minimum : 2
- Performance : lecture rapide / écriture légèrement plus lente
- Tolérance aux pannes : un disque peut tomber sans perte
- Capacité utile : 50 % (2× 1 To = 1 To)
- Usage : serveurs critiques, postes comptables

**RAID 5 — Équilibre performance / sécurité** (données + parité réparties sur tous les disques)
- Disques minimum : 3
- Performance : bonne en lecture / écriture plus lente (calcul de parité)
- Tolérance aux pannes : un disque peut tomber sans perte
- Capacité utile : (n-1) disques (3× 1 To = 2 To)
- Usage : serveurs de fichiers d'entreprise — le compromis le plus utilisé en production

> Moyen mnémotechnique : RAID **0** = zéro sécurité ; RAID **1** = 1 copie miroir ; RAID **5** = le 5 étoiles des serveurs d'entreprise.

## 6.2 Mise en place et déploiement d'un RAID

La mise en place se réfléchit dès la conception de la machine, car elle conditionne l'installation de l'OS.

**Quand ?** Le moment idéal est avant d'installer l'OS et avant d'y mettre des données (la création d'un volume RAID efface intégralement les disques).
1. Brancher les disques vierges.
2. Créer le volume RAID (via BIOS/UEFI ou carte RAID).
3. Installer l'OS sur le volume virtuel créé.

> Possible de créer un RAID logiciel après coup sur des disques secondaires. Mais pour le disque système principal, le RAID se configure toujours au démarrage initial.

**RAID Matériel (Hardware) — Entreprise** : carte contrôleur RAID dédiée avec son propre processeur et mémoire.
1. Brancher les disques sur la carte RAID.
2. Au démarrage, touche dédiée (Ctrl+R, F2 selon le fabricant).
3. Sélectionner les disques, choisir le niveau RAID, valider.
4. La carte fusionne les disques → l'OS ne voit qu'un seul volume → installer l'OS.

| Avantage | Inconvénient |
|---|---|
| Performances maximales (processeur dédié) | Coût élevé (carte RAID = 150 € à plusieurs milliers €) |
| Transparent pour l'OS | Si la carte tombe, les disques sont illisibles sans carte identique |
| Gestion du cache en écriture | — |

**RAID Logiciel (Software) — Particuliers / NAS** : pas de carte dédiée, c'est le processeur et l'OS qui gèrent.
1. Brancher les disques secondaires vierges.
2. Ouvrir la Gestion des disques (`diskmgmt.msc`).
3. Clic droit → Nouveau volume agrégé par bandes (RAID 0) ou Nouveau volume en miroir (RAID 1).
4. L'OS gère le RAID en arrière-plan.

| Avantage | Inconvénient |
|---|---|
| Gratuit (intégré à l'OS) | Consomme des ressources CPU |
| Simple à mettre en place | Moins performant que le matériel |
| Portable (pas dépendant d'une carte) | — |

> C'est cette couche intermédiaire (matérielle ou logicielle) qui « ment intelligemment » à l'OS : il croit qu'il n'y a qu'un seul disque, alors qu'en arrière-plan les données sont dupliquées ou découpées.

**Chaîne complète de déploiement :**
```
[Achat des disques identiques]
        ↓
[Installation physique dans les baies]
        ↓
[Boot BIOS / Contrôleur RAID]  →  Choix du niveau (0, 1, 5…)
        ↓
[Création de la grappe virtuelle]  →  N disques physiques = 1 volume logique
        ↓
[Installation de l'OS / Formatage]
```
