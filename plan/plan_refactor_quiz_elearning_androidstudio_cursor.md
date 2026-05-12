# PLAN DE REFACTOR — APPLICATION E-LEARNING / QUIZ KCULTURE

## OBJECTIF

Stabiliser complètement le système de quiz sans casser l’UI/UX actuelle.

Le but n’est PAS de refaire l’application.

Le but est de :
- supprimer les anciennes logiques quiz
- reconstruire un moteur quiz propre
- reconnecter uniquement les éléments utiles
- retrouver une architecture stable et maintenable
- réduire les bugs et la consommation de tokens IA

---

# RÈGLES IMPORTANTES

## INTERDICTIONS

NE PAS :
- refaire toute l’application
- modifier le design actuel
- changer les couleurs
- modifier les animations validées
- recréer les pages déjà fonctionnelles
- ajouter de nouvelles features avant stabilisation
- mélanger ancien et nouveau système Quiz

---

# PHASE 1 — AUDIT DU SYSTÈME QUIZ

## OBJECTIF

Identifier tout ce qui appartient :
- à l’ancien système
- au nouveau système
- aux composants morts/inutiles

---

## ACTIONS À EFFECTUER

Créer une liste complète :

```txt
Anciennes pages Quiz
Anciennes routes
Anciens composants
Anciens services
Anciens ViewModels
Anciennes API
Anciennes données mockées
Anciens timers
Anciennes animations
```

---

## LIVRABLE ATTENDU

Créer un fichier :

```txt
/docs/quiz_audit.md
```

Contenant :

```md
# Quiz Audit

## Utilisé actuellement
- QuizScreenV2
- QuizGameManager
- QuizRepository

## Obsolète
- OldQuizScreen
- QuizManagerLegacy
- QuizRouteOld

## Conflits détectés
- Double navigation
- Double state management
- Deux systèmes de score
```

---

# PHASE 2 — GEL DE L’UI

## OBJECTIF

Considérer l’UI actuelle comme VALIDÉE.

---

## ACTIONS

Ne plus modifier :
- composants visuels
- styles
- animations
- layout

Le refactor doit uniquement toucher :
- logique métier
- navigation
- state management
- données quiz

---

# PHASE 3 — SUPPRESSION COMPLÈTE DE L’ANCIEN SYSTÈME

## OBJECTIF

Ne garder QU’UN seul système Quiz.

---

## ACTIONS

Supprimer :
- anciens composants quiz
- anciennes routes
- anciens services
- anciens états
- anciens callbacks
- anciens providers
- anciens fichiers inutilisés

---

## IMPORTANT

Aucun fichier legacy ne doit rester connecté.

Même indirectement.

---

# PHASE 4 — NOUVELLE ARCHITECTURE QUIZ

## OBJECTIF

Créer une architecture propre et modulaire.

---

## STRUCTURE OBLIGATOIRE

```txt
/features
   /quiz
      /components
      /models
      /services
      /viewmodels
      /screens
```

---

# PHASE 5 — RECONSTRUCTION DU MOTEUR QUIZ

## OBJECTIF

Créer un système minimal mais stable.

---

## ÉTAPE 1 — QUIZ MINIMAL

Créer un quiz fonctionnel avec :

```txt
- 1 question
- 4 réponses
- bouton suivant
- score simple
```

---

## CONDITIONS

Le quiz doit fonctionner :
- sans animation
- sans multi
- sans timer
- sans effets spéciaux

---

## VALIDATION

Le quiz doit :
- démarrer
- afficher les questions
- enregistrer les réponses
- terminer correctement

AVANT toute feature supplémentaire.

---

# PHASE 6 — AJOUT PROGRESSIF DES FEATURES

## ORDRE OBLIGATOIRE

Ajouter UNE feature à la fois.

---

## ORDRE RECOMMANDÉ

### 1
Timer

### 2
Transitions UI

### 3
Effets sonores

### 4
Score avancé

### 5
Classement

### 6
Multijoueur

---

## RÈGLE

Après chaque ajout :
- compiler
- tester
- corriger
- commit Git

---

# PHASE 7 — NAVIGATION

## OBJECTIF

Éviter les conflits de routes.

---

## ACTIONS

Créer UNE seule route quiz :

```txt
/quiz
```

---

## INTERDICTION

Ne jamais avoir :

```txt
/quiz-old
/quiz-v2
/quiz-final
/quiz-new
```

---

# PHASE 8 — STATE MANAGEMENT

## OBJECTIF

Avoir UNE seule source de vérité.

---

## INTERDICTION

Ne jamais avoir :
- plusieurs états quiz
- plusieurs managers
- plusieurs repositories concurrents

---

## STRUCTURE CONSEILLÉE

```txt
QuizViewModel
   ↓
QuizRepository
   ↓
QuizDataSource
```

---

# PHASE 9 — BONNES PRATIQUES CURSOR / IA

## OBLIGATOIRE

Créer :

```txt
/.cursorrules
```

---

## CONTENU CONSEILLÉ

```txt
- Kotlin uniquement
- MVVM obligatoire
- Une seule logique Quiz
- Ne jamais recréer un composant existant
- Toujours réutiliser les composants
- Répondre avec le minimum de code nécessaire
- Ne jamais modifier plusieurs features en même temps
```

---

# PHASE 10 — GESTION DES TOKENS IA

## INTERDICTION

Ne jamais demander :

```txt
"Répare toute l’application"
```

---

## MÉTHODE CORRECTE

Toujours demander :

```txt
"Corrige uniquement QuizViewModel"
"Analyse uniquement la navigation Quiz"
"Supprime uniquement les anciens composants quiz"
```

---

# PHASE 11 — VERSIONNING

## OBLIGATOIRE

Créer un commit Git :
- avant chaque modification importante
- avant chaque refactor
- avant chaque suppression massive

---

## FORMAT CONSEILLÉ

```txt
feat: new quiz engine
fix: navigation quiz route
refactor: remove legacy quiz system
```

---

# PHASE 12 — OBJECTIF FINAL

À la fin :

Le projet doit avoir :
- une architecture propre
- un seul moteur Quiz
- une navigation stable
- une logique simple
- un UI déjà validé
- une maintenance facile
- une consommation IA réduite

---

# RÉSULTAT ATTENDU

Application :
- stable
- modulaire
- scalable
- facilement maintenable
- compatible avec ajout futur de nouvelles features

Sans recréer un “Frankenstein Project”.

