> **Parcours Optimus — Module 5 · Chapitre 4 sur 7**

# Paramètres du plan de sauvegarde

| Concept | Définition |
|---|---|
| PCA / PCI | Plan de Continuité de l'Activité/Informatique : redondance pour éviter toute interruption |
| PRA / PRI | Plan de Reprise de l'Activité/Informatique : comment restaurer après un sinistre |
| RPO (Recovery Point Objective) | Quantité de données maximum acceptable à perdre (en temps) |
| RTO (Recovery Time Objective) | Durée maximum acceptable sans production |

**Snapshot** : cliché instantané de l'état d'une machine (différent d'une sauvegarde : il copie l'état, pas les données). Restauration quasi-immédiate. Trop de snapshots peut ralentir la VM.

> 🔁 Réflexe : prendre un snapshot avant toute manipulation risquée !
