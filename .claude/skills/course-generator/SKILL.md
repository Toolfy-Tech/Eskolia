---
name: Générateur de Cours et Quiz Pédagogique
description: Génère un module de cours ultra-pédagogique au format Markdown et son quiz d'évaluation associé au format JSON, ciblant les grands débutants.
---

# Objectif
Ce skill s'active pour la création de modules de cours. Le public cible est "ultra-débutant" (apprentissage de zéro). Le rendu doit obligatoirement inclure un bloc Markdown (le cours) suivi immédiatement d'un bloc JSON (le quiz).

# 1. Règles de rédaction (Markdown)
- **Pédagogie absolue :** Aucune connaissance préalable n'est requise. Chaque terme technique doit être défini immédiatement.
- **Format Web (Microlearning) :** Le texte doit être très aéré (paragraphes courts, listes à puces, titres H2/H3) pour une lecture optimale sur écran. Aucun "mur de texte".
- **Structure obligatoire :**
  1. `# [Titre du module engageant]`
  2. `## 🤔 Le "Pourquoi"` : L'utilité concrète immédiate pour donner du sens.
  3. `## 👣 Apprentissage pas-à-pas` : Le cœur du cours, découpé logiquement.
  4. `## 🌍 L'Analogie "Dans la vraie vie"` : Une comparaison avec le monde physique.
  5. `## 🧠 L'Anti-Sèche` : Récapitulatif strict en 3 à 5 points clés.

# 2. Règles du Quiz (JSON) — Format Optimus Mastery

Le quiz doit être compatible avec le format lu par l'application Flutter. Chaque entrée JSON suit la structure définie dans `data/quiz/optimus/GUIDE_REDACTION_JSON.md`.

## 2a. Structure de chaque question

```json
{
  "id": "NXS-[MODULE]-[CHAPITRE]-[NUMERO]",
  "category": "[Thème principal]",
  "chapter": "[Titre exact de la notion]",
  "tier": "[S | A | B | C]",
  "type": "[voir types ci-dessous]",
  "question": "...",
  "answer": "...",
  "comment": "..."
}
```

- `id` : format `NXS-M01-C01-001` (Nexus, Module, Chapitre, numéro séquentiel)
- `tier` : S = expert/complexe, A = intermédiaire+, B = intermédiaire, C = débutant
- `comment` : explication pédagogique, commence par "Astuce de pro :" ou "Réflexe métier :" si type `astuce_pro`

## 2b. Types disponibles (choisir le plus adapté au contenu)

| type | usage | champs supplémentaires |
|---|---|---|
| `acronyme` | Définir un sigle ou terme | aucun |
| `vrai_faux` | Corriger une idée reçue | aucun — `answer` = "Vrai" ou "Faux" |
| `astuce_pro` | Réflexe métier essentiel | aucun — `comment` commence par "Astuce de pro :" |
| `reformulation` | Expliquer à un non-technicien | aucun — `answer` utilise une métaphore simple |
| `sequence` | Procédure ordonnée | `"options": [liste mélangée]` — `answer` = liste ordonnée |
| `diagnostic_indices` | Déduction par étapes | `"indices": ["Indice 1", "Indice 2", "Indice 3"]` |
| `ticket` | Simulation d'incident réel | `"checklist": ["Etape 1", ...]` |
| `association` | Relier deux colonnes (drag & drop) | `"pairs": [{"left": "...", "right": "..."}, ...]` — `answer` = description textuelle des bonnes paires |

## 2c. Nombre de questions selon la complexité de la notion

Avant de générer, évaluer la complexité :
- **Simple (3 questions)** : définition unique, concept isolé — ex. "Qu'est-ce qu'un ticket ?"
- **Moyenne (5 questions)** : plusieurs sous-concepts, une procédure — ex. "Les niveaux N1/N2/N3"
- **Complexe (7 questions)** : concepts imbriqués, règles interdépendantes, notion centrale — ex. "Cycle de vie d'un incident ITIL"

Varier les types de cartes au sein d'un même fichier (ne pas enchaîner 5 `acronyme`).

## 2d. Format du fichier JSON final

Le fichier est un tableau JSON à la racine (pas d'objet englobant) :

```json
[
  {
    "id": "NXS-M01-C01-001",
    "category": "Support utilisateur",
    "chapter": "Introduction à l'ITSM",
    "tier": "C",
    "type": "acronyme",
    "question": "Que signifie l'acronyme ITSM ?",
    "answer": "IT Service Management — Gestion des services informatiques.",
    "comment": "L'ITSM est le cadre qui structure comment une équipe IT délivre ses services. ITIL en est le référentiel de bonnes pratiques le plus répandu."
  },
  {
    "id": "NXS-M01-C01-002",
    "category": "Support utilisateur",
    "chapter": "Introduction à l'ITSM",
    "tier": "B",
    "type": "vrai_faux",
    "question": "Vrai ou Faux : Le centre de services (Service Desk) n'est qu'un système de tickets automatisé sans intervention humaine.",
    "answer": "Faux",
    "comment": "Le centre de services est le point de contact humain unique entre les utilisateurs et l'IT. Il qualifie, priorise et résout — ou escalade — chaque demande."
  }
]
```
