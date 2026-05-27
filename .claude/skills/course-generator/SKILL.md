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

Évaluer la complexité avant de générer :

| Complexité | Questions | Critères |
|---|---|---|
| Simple | 3 | Définition unique, concept isolé |
| Moyenne | 5 | Plusieurs sous-concepts, une procédure à retenir |
| Complexe | 7 | Concepts imbriqués, règles interdépendantes, notion centrale du module |

---

## 2d. Règles de mélange des types

- **Interdiction** d'enchaîner plus de 2 questions `classic` consécutives sans varier.
- **`sequence` et `association`** : maximum 1 par fichier de notion (ce sont des types lourds).
- **`ticket`** : réserver aux notions de support/diagnostic — pas aux notions théoriques.
- **`diagnostic_indices`** : réserver aux notions de dépannage avec une démarche logique claire.
- **Minimum 50% de questions `classic`** par fichier — elles fonctionnent dans tous les modes (quiz, flashcard, survival, révision).

---

## 2e. Format du fichier JSON final

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
