---
name: Générateur de Cours et Quiz Pédagogique
description: Génère un module de cours ultra-pédagogique au format Markdown et son quiz d'évaluation associé au format JSON, ciblant les grands débutants.
---

# Objectif
Ce skill s'active pour la création de modules de cours. Le public cible est "ultra-débutant" (apprentissage de zéro). Le rendu doit obligatoirement inclure un bloc Markdown (le cours) suivi immédiatement d'un bloc JSON (le quiz).

---

# 1. Règles de rédaction (Markdown)

- **Pédagogie absolue :** Aucune connaissance préalable n'est requise. Chaque terme technique doit être défini immédiatement.
- **Format Web (Microlearning) :** Texte très aéré (paragraphes courts, listes, titres H2/H3). Aucun "mur de texte".
- **Structure obligatoire :**
  1. `# [Titre du module engageant]`
  2. `## 🤔 Le "Pourquoi"` : L'utilité concrète immédiate.
  3. `## 👣 Apprentissage pas-à-pas` : Le cœur du cours, découpé logiquement.
  4. `## 🌍 L'Analogie "Dans la vraie vie"` : Comparaison avec le monde physique.
  5. `## 🧠 L'Anti-Sèche` : Récapitulatif en 3 à 5 points clés.

---

# 2. Règles du Quiz (JSON) — Format Eskolia

## 2a. Types de questions — référence officielle

Il existe **6 types** dans Eskolia. Choisir le type en fonction du contenu, pas de la variété.

---

### `classic` — Question ouverte
Champ texte libre + auto-évaluation. Le type par défaut pour tout ce qui est définition, concept, réflexe métier, vrai/faux, acronyme. Couvre l'immense majorité des questions.

**Compatible flashcard : OUI**

```json
{
  "type": "classic",
  "question": "Que signifie l'acronyme ITSM ?",
  "answer": "IT Service Management — Gestion des services informatiques.",
  "comment": "L'ITSM structure comment une équipe IT délivre ses services. ITIL en est le référentiel le plus répandu."
}
```

> Pour un vrai/faux, utiliser `type: "classic"` avec `answer: "Vrai"` ou `answer: "Faux"` et un `comment` qui justifie obligatoirement.

---

### `ticket` — Simulation d'incident
Affiche un badge "TICKET D'INCIDENT" + une checklist de résolution après révélation. Idéal pour simuler le travail réel du technicien.

**Compatible flashcard : OUI**

Champs supplémentaires : `"checklist": ["Étape 1", "Étape 2", ...]`

```json
{
  "type": "ticket",
  "question": "TICKET #42 : 'Mon PC s'allume mais rien ne s'affiche à l'écran.'",
  "answer": "Problème d'affichage — câble moniteur, carte graphique ou RAM.",
  "checklist": [
    "Vérifier que le moniteur est allumé et branché",
    "Tester avec un autre câble vidéo",
    "Retirer et remettre les barrettes RAM",
    "Tester avec un autre moniteur"
  ],
  "comment": "Réflexe métier : toujours commencer par les causes physiques avant de suspecter le logiciel."
}
```

---

### `diagnostic_indices` — Déduction par indices
Révèle des indices un par un pour guider le raisonnement. Chaque indice est plus précis que le précédent.

**Compatible flashcard : OUI** (affiche question + réponse, sans les indices progressifs)

Champs supplémentaires : `"indices": ["Indice 1", "Indice 2", "Indice 3"]` (2 à 4 indices, du plus vague au plus précis)

```json
{
  "type": "diagnostic_indices",
  "question": "Un utilisateur ne peut plus accéder à Internet depuis son PC uniquement. Quel est le problème ?",
  "answer": "Problème de configuration réseau local (IP statique incorrecte ou conflit DHCP).",
  "indices": [
    "Les autres postes du bureau accèdent bien à Internet.",
    "Un ping vers la passerelle (192.168.1.1) échoue.",
    "L'adresse IP affichée est en 169.254.x.x (APIPA)."
  ],
  "comment": "Une adresse APIPA (169.254.x.x) signale que le PC n'a pas réussi à obtenir une IP du serveur DHCP."
}
```

---

### `sequence` — Remise en ordre (drag & drop)
L'utilisateur remet des étapes dans le bon ordre. Rendu interactif uniquement dans le quiz.

**Compatible flashcard : NON** (perd l'interactivité — affiche juste le texte)

Champs supplémentaires :
- `"options"` : liste des étapes **mélangées** (ordre aléatoire)
- `"answer"` : liste des étapes dans le **bon ordre** (tableau JSON)

```json
{
  "type": "sequence",
  "question": "Remettez dans l'ordre les étapes de traitement d'un incident ITIL :",
  "options": ["Résolution et restauration", "Identification", "Clôture", "Catégorisation et priorisation", "Diagnostic"],
  "answer": ["Identification", "Catégorisation et priorisation", "Diagnostic", "Résolution et restauration", "Clôture"],
  "comment": "Le cycle ITIL garantit que chaque incident est tracé de son ouverture à sa clôture, sans étape sautée."
}
```

---

### `association` — Relier des paires (drag & drop)
L'utilisateur associe des éléments de deux colonnes. Rendu interactif uniquement dans le quiz.

**Compatible flashcard : NON** (perd l'interactivité — affiche juste le texte)

Champs supplémentaires : `"pairs": [{"left": "...", "right": "..."}, ...]`
Le champ `answer` doit décrire les bonnes paires en texte pour la flashcard.

```json
{
  "type": "association",
  "question": "Associez chaque terme ITIL à sa définition :",
  "pairs": [
    {"left": "Incident",  "right": "Interruption non planifiée d'un service"},
    {"left": "Problème",  "right": "Cause racine d'un ou plusieurs incidents"},
    {"left": "Changement","right": "Ajout, modification ou retrait d'un élément du SI"}
  ],
  "answer": "Incident = interruption non planifiée | Problème = cause racine | Changement = modification du SI",
  "comment": "Distinguer incident et problème est fondamental : on gère l'incident pour restaurer le service, on résout le problème pour éviter la récurrence."
}
```

---

## 2b. Structure complète d'une question

```json
{
  "id": "NXS-M[XX]-C[XX]-[NNN]",
  "category": "[Thème principal]",
  "chapter": "[Titre exact de la notion]",
  "tier": "C | B | A | S",
  "type": "[classic | ticket | diagnostic_indices | sequence | association]",
  "question": "...",
  "answer": "...",
  "comment": "..."
}
```

- **`id`** : format `NXS-M01-C01-001` (Nexus · Module · Chapitre · numéro séquentiel)
- **`tier`** : C = débutant, B = intermédiaire, A = difficile, S = expert
- **`comment`** : explication pédagogique post-révélation — toujours présent, jamais vide

---

## 2c. Nombre de questions selon la complexité de la notion

| Complexité | Questions | Critères |
|---|---|---|
| Standard | **10** | Notion à concept principal unique, définition ou procédure simple |
| Étendue | **12** | Plusieurs sous-concepts liés, procédure avec variantes |
| Approfondie | **15** | Concepts imbriqués, dépannage avancé, notion centrale du module |

**Minimum absolu : 10 questions par notion.**

---

## 2d. Règles de mélange des types

- Pas plus de **3 `classic` consécutifs** — alterner avec un type interactif.
- `sequence` : **maximum 2** par fichier, sur des procédures distinctes.
- `association` : **maximum 2** par fichier, sur des axes de regroupement différents.
- `ticket` : placer **uniquement là où c'est pertinent** (voir recettes Nature ci-dessous) — jamais par défaut.
- `diagnostic_indices` : réserver aux notions avec une démarche de déduction logique identifiable.
- **Minimum 40% de `classic`** — garanti de fonctionner dans tous les modes (quiz, flashcard, survival, révision).

---

## 2e. Stratégie de sélection des types par nature de notion

Identifier la **nature dominante** depuis le titre de la notion. Appliquer la recette.

---

### Nature A — Concepts & Définitions
*Reconnaître : "Qu'est-ce que", "Introduction à", "Les bases de", "Comprendre", "Les X de Y"*
> Ex : 1.1 ITSM, 7.1 OSI/TCP-IP, 8.1 Active Directory, 6.1 menaces

| Type | Quantité | Contenu attendu |
|---|---|---|
| `classic` | 6–9 | Définitions, vrai/faux pour corriger idées reçues, acronymes, distinctions entre concepts |
| `association` | **2** | 1 × termes↔définitions + 1 × concepts↔exemples concrets |
| `sequence` | 1 si pertinent | Uniquement si les concepts ont un ordre logique (ex : couches OSI, chronologie) |
| `ticket`, `diagnostic_indices` | Interdit | — |

---

### Nature B — Procédures & Étapes
*Reconnaître : "Installer", "Créer", "Configurer", "Déployer", "Intégrer", "Rédiger", "Gérer"*
> Ex : 4.2 Installer Windows, 8.4 Intégrer un poste, 6.5 Stratégie sauvegarde

| Type | Quantité | Contenu attendu |
|---|---|---|
| `classic` | 5–7 | Comprendre le pourquoi de chaque étape, identifier les erreurs courantes |
| `sequence` | **2** | 1 × procédure principale + 1 × sous-procédure ou procédure alternative |
| `association` | **1** | Outil↔étape ou commande↔action |
| `ticket` | 1 si résolution d'incident | Uniquement si la procédure sert à résoudre un problème (configurer firewall = oui, rédiger compte-rendu = non) |
| `diagnostic_indices` | Interdit | — |

---

### Nature C — Dépannage & Diagnostic
*Reconnaître : "Diagnostiquer", "Dépanner", "Identifier une panne", "Tests de", "Analyser"*
> Ex : 3.3 panne matérielle, 3.5 panne réseau, 7.10 tests connectivité, 8.7 authentification

| Type | Quantité | Contenu attendu |
|---|---|---|
| `classic` | 4–5 | Comprendre causes, symptômes, outils utilisés |
| `diagnostic_indices` | **2–3** | Scénarios de déduction distincts avec symptômes progressifs |
| `ticket` | **2** | Deux incidents réels différents du même type de panne |
| `association` | **1** | Symptôme↔cause probable ou outil↔cas d'usage |
| `sequence` | 1 si pertinent | Étapes de la démarche de diagnostic si ordonnée |

---

### Nature D — Outils & Logiciels
*Reconnaître : "Les outils", "Utiliser X", nom d'un outil (GLPI, TeamViewer, Wireshark…)*
> Ex : 1.6 outils ITSM, 2.4 prise en main à distance, 3.2 outils diagnostic Windows

| Type | Quantité | Contenu attendu |
|---|---|---|
| `classic` | 5–7 | Fonctions, usages, avantages/limites, différences entre outils |
| `association` | **2** | 1 × outil↔usage principal + 1 × fonctionnalité↔cas concret |
| `sequence` | **1** | Procédure d'utilisation clé de l'outil principal |
| `ticket` | 1 si pertinent | Uniquement si l'outil intervient dans la résolution d'un incident réel |
| `diagnostic_indices` | Interdit | — |

---

### Nature E — Réglementaire & Normatif
*Reconnaître : "RGPD", "ANSSI", "DEEE", "habilitation", "règles d'hygiène", "obligations"*
> Ex : 6.7 RGPD, 6.8 ANSSI, 5.5 habilitation électrique BS, 5.6 DEEE

Distinguer deux sous-types :

**E1 — Réglementaire à impact opérationnel** (le technicien peut recevoir un vrai incident lié)
> Ex : 6.7 RGPD, 6.8 ANSSI

| Type | Quantité | Contenu attendu |
|---|---|---|
| `classic` | 6–7 | Vrai/faux pour corriger idées reçues, définitions légales, obligations |
| `association` | **2** | 1 × règle↔obligation concrète + 1 × cas d'usage↔conformité |
| `ticket` | **1** | Incident réel lié à la réglementation (vol de laptop, fuite de données, signalement utilisateur) |
| `sequence` | 1 si pertinent | Procédure légale ordonnée (ex : déclarer une violation RGPD en 72h) |
| `diagnostic_indices` | Interdit | — |

**E2 — Réglementaire théorique** (pas d'incident technicien associable naturellement)
> Ex : 5.5 habilitation électrique BS, 5.6 DEEE

| Type | Quantité | Contenu attendu |
|---|---|---|
| `classic` | 7–9 | Vrai/faux, définitions, obligations, risques |
| `association` | **2** | 1 × règle↔obligation + 1 × situation↔bonne pratique |
| `ticket`, `sequence`, `diagnostic_indices` | Interdit | — |

---

### Nature F — Communication & Relationnel
*Reconnaître : "Écoute", "Adapter", "Communication", "Accompagner", "Former", "Discours"*
> Ex : 2.1 techniques communication, 2.2 adapter son discours, 9.1 écoute active

| Type | Quantité | Contenu attendu |
|---|---|---|
| `classic` | 6–8 | Concepts, bonnes pratiques, réflexes relationnels |
| `ticket` | **2** si assistance directe, **1** si théorique | Scénarios de communication réels avec utilisateurs difficiles ou profils variés |
| `association` | **1** | Profil utilisateur↔approche adaptée ou situation↔technique de communication |
| `sequence` | 1 si pertinent | Uniquement si une procédure de communication existe (ex : étapes de l'écoute active) |
| `diagnostic_indices` | Interdit | — |

> **Assistance directe** (ticket ×2) : 2.1, 2.2, 2.4, 9.1, 9.2
> **Théorique** (ticket ×1) : 2.3, 2.5, 2.6, 10.1, 10.2

---

### Natures mixtes
Certaines notions combinent deux natures (ex : "Configurer un switch" = B + D). Prendre la recette de la nature **dominante** et ajouter 1 élément de la nature secondaire si le budget le permet. Ne jamais dépasser 2 `sequence` ni 2 `association` au total.

---

## 2f. Format du fichier JSON final

Tableau JSON à la racine (pas d'objet englobant) :

```json
[
  {
    "id": "NXS-M01-C01-001",
    "category": "Support utilisateur",
    "chapter": "Introduction à l'ITSM",
    "tier": "C",
    "type": "classic",
    "question": "Que signifie l'acronyme ITSM ?",
    "answer": "IT Service Management — Gestion des services informatiques.",
    "comment": "L'ITSM structure comment une équipe IT délivre ses services. ITIL en est le référentiel le plus répandu."
  }
]
```
