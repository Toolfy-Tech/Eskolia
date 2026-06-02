> **Parcours Optimus — Module 6 · Chapitre 7 sur 14**

# Gestion des droits et partages (NTFS)

**NTFS vs Partage réseau** — deux niveaux de permissions :

| | Permissions NTFS | Permissions de partage |
|---|---|---|
| S'appliquent | Sur le disque local ET en réseau | Uniquement en accès réseau |
| Granularité | Très fine (lecture, écriture, modification, contrôle total...) | Simple (Lecture, Modification, Contrôle total) |
| En cas de conflit | La permission la plus restrictive gagne | La permission la plus restrictive gagne |
| Recommandation | Gérer finement via NTFS | Mettre « Contrôle total » au partage, affiner via NTFS |

> **Règle terrain** : donner « Contrôle total » au niveau du partage réseau, puis tout gérer via les permissions NTFS. Une seule couche à maintenir.

**Créer un partage réseau** : Clic droit sur le dossier → Propriétés → Partage → Partage avancé → cocher « Partager ce dossier » → nommer le partage (ex : `Compta$` — le `$` le rend invisible dans l'explorateur) → onglet Sécurité → modifier les permissions NTFS.

**Permissions NTFS essentielles** :

| Permission | Ce qu'elle permet |
|---|---|
| Lecture | Voir et ouvrir les fichiers |
| Lecture et exécution | + lancer les programmes |
| Modification | + créer, modifier, supprimer |
| Contrôle total | Tout + modifier les permissions |

> Ne jamais donner le Contrôle total à « Tout le monde ». Toujours assigner les droits aux **groupes AD**, jamais aux utilisateurs individuels.
