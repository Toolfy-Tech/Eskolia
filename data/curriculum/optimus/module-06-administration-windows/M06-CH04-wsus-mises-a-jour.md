> **Parcours Optimus — Module 6 · Chapitre 4 sur 14**

# Gestion des mises à jour — WSUS

**WSUS (Windows Server Update Services)** est un rôle Windows Server qui centralise la gestion des mises à jour de tous les postes du parc.

- **Sans WSUS** : chaque PC télécharge ses MAJ directement depuis Microsoft → bande passante saturée, MAJ non contrôlées, postes hétérogènes.
- **Avec WSUS** : un seul serveur récupère les MAJ, l'administrateur les valide, puis les distribue de façon planifiée.

```
Serveurs Microsoft
     ↓
Serveur WSUS (télécharge et stocke les MAJ)
     ↓ (après validation par l'admin)
Tous les postes du domaine
```

**Patch Tuesday** : Microsoft publie ses MAJ de sécurité le **2ᵉ mardi de chaque mois**. C'est la référence pour planifier les déploiements WSUS.

> **Bonne pratique** : tester les MAJ sur un groupe pilote (5-10 postes) avant de les déployer à tout le parc. Une MAJ mal testée peut casser une application métier.

**Paramétrage via GPO** :
```
Configuration Ordinateur
 → Modèles d'administration
 → Composants Windows
 → Windows Update
 → Spécifier l'emplacement intranet du service de mise à jour Microsoft
   → http://nom-serveur-wsus:8530
```

**Ciblage côté client (Client-Side Targeting)** : option GPO qui indique à un PC de se connecter au serveur WSUS en se déclarant membre d'un groupe (ex : « Comptabilité ») pour recevoir les MAJ validées pour ce groupe. Indispensable pour gérer les groupes pilotes.
