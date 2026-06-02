> **Parcours Optimus — Module 6 · Chapitre 9 sur 14**

# Gestionnaire de tâches et performances

Raccourci : **Ctrl+Maj+Échap** (ou clic droit sur la barre des tâches).

| Onglet | Usage terrain |
|---|---|
| Processus | Identifier quel programme consomme CPU/RAM — tuer un processus bloqué |
| Performances | Vue graphique CPU, RAM, disque, réseau en temps réel |
| Démarrage | Gérer les programmes lancés au démarrage (ralentissement au boot) |
| Utilisateurs | Voir les sessions actives — déconnecter un utilisateur fantôme |
| Détails | PID, priorité des processus — niveau avancé |

**Moniteur de ressources** (`resmon`) : plus précis que le Gestionnaire de tâches. Permet de voir exactement quels fichiers sont ouverts par quel processus, quelle IP est contactée par quelle application — indispensable pour diagnostiquer un ralentissement ou un comportement suspect.

**Seuils d'alerte terrain** :

| Ressource | Normal | À surveiller | Critique |
|---|---|---|---|
| CPU | < 30 % | 30-70 % | > 80 % en continu |
| RAM | < 70 % | 70-85 % | > 90 % (pagination disque) |
| Disque | < 20 % | 20-50 % | > 80 % en continu |

> Un disque à 100 % en continu sur un HDD = symptôme classique d'un disque mourant ou d'un malware. Premier réflexe : Gestionnaire de tâches → Performances → Disque → identifier le processus responsable.
