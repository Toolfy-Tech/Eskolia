> **Parcours Optimus — Module 1 · Chapitre 1 sur 9**

# ITIL — Le cadre de gestion des services

**ITIL (Information Technology Infrastructure Library)** est un ensemble de bonnes pratiques pour gérer les services informatiques. Ce n'est pas un logiciel ni une norme obligatoire, mais un **référentiel** adopté par la majorité des entreprises pour organiser le support. La version actuelle est **ITIL 4** (éditée par AXELOS).

L'idée centrale : l'informatique ne « répare pas des machines », elle **rend un service** à des utilisateurs. Tout est donc pensé en termes de valeur rendue, de délais et de qualité.

## 1.1 Les trois types de sollicitations

Une erreur fréquente du débutant est de tout appeler « problème ». ITIL distingue précisément :

| Terme | Définition | Exemple |
|---|---|---|
| **Demande de service** (Service Request) | Requête normale, prévue, sans dysfonctionnement | « J'ai besoin d'un accès au dossier Compta », « installez-moi Teams » |
| **Incident** | Interruption non planifiée ou dégradation d'un service | « Mon PC ne démarre plus », « l'imprimante est hors ligne » |
| **Problème** | La **cause racine** sous-jacente à un ou plusieurs incidents | 12 PC plantent → cause = une mise à jour défectueuse déployée la nuit |

> **À retenir** : un incident, c'est le *symptôme* (« ça ne marche pas »). Le problème, c'est la *maladie* (« pourquoi ça ne marche pas »). On résout un incident pour rétablir le service vite ; on traite un problème pour que ça ne se reproduise plus.

## 1.2 Le centre de services (Service Desk)

Le **centre de services** est le **point de contact unique** (SPOC — *Single Point of Contact*) entre les utilisateurs et l'informatique. Toutes les demandes y transitent, ce qui évite que les utilisateurs appellent directement « leur » technicien préféré et garantit que rien ne se perd.

On distingue souvent des **niveaux de support** :

| Niveau | Rôle | Qui |
|---|---|---|
| **N1** | Réception, qualification, résolution des cas courants (mots de passe, périphériques, questions logicielles) | Technicien de proximity / Helpdesk |
| **N2** | Incidents techniques plus complexes nécessitant une expertise | Techniciens spécialisés, admins |
| **N3** | Expertise pointue, éditeurs, constructeurs | Experts, ingénieurs, support éditeur |

Le technicien informatique de proximité opère majoritairement en **N1**, et escalade vers le N2/N3 ce qui dépasse son périmètre.
