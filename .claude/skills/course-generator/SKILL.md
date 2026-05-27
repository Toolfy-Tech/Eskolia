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

# 2. Règles du Quiz (JSON)
Génère ensuite un bloc JSON valide contenant 3 à 5 questions à choix multiples.
- Respecte strictement cette structure par question : `id` (entier), `questionText` (chaîne), `options` (tableau de 4 chaînes), `correctAnswerIndex` (entier, commençant à 0).
- Inclus obligatoirement ces deux clés d'accompagnement :
  - `hint` : Un indice court pour guider la réflexion.
  - `explanation` : L'explication pédagogique détaillée post-réponse.

Exemple de format JSON attendu :
```json
{
  "quizTitle": "Titre du Quiz",
  "difficulty": "Débutant",
  "questions": [
    {
      "id": 1,
      "questionText": "...",
      "options": ["A", "B", "C", "D"],
      "correctAnswerIndex": 0,
      "hint": "...",
      "explanation": "..."
    }
  ]
}
```
