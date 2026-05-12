# Blueprint — Application de Quiz Flashcard (Solo + Multijoueur)

## Objectif

Créer une application web en HTML / CSS / JavaScript avec deux modes :

### Mode SOLO
L’utilisateur répond à une question en texte libre, valide sa réponse, puis la carte se retourne immédiatement pour afficher la bonne réponse. Il doit ensuite indiquer lui-même s’il avait juste ou faux.

### Mode MULTIJOUEUR (Classe)
Le professeur crée un lobby, choisit les thèmes et le nombre de questions. Les élèves rejoignent avec un code de salle, répondent aux questions librement sans correction immédiate, puis le professeur corrige toutes les réponses à la fin, élève par élève, avant de générer un classement final.

L’objectif est de créer une expérience pédagogique type active recall + correction collective.

---

## Style visuel

Design moderne, propre, professionnel.

Inspiration :
- Kahoot
- Quizlet
- Anki
- interface EdTech moderne

Style attendu :
- cartes larges centrées
- animations de flip card
- interface claire
- responsive desktop/mobile
- couleurs sobres et modernes
- effet application sérieuse, pas design enfantin

Technologies :
- HTML
- CSS
- JavaScript Vanilla (ou React si version avancée)

---

## Mode Solo

### Étape 1 — Affichage question

Une flashcard affiche :

**Question :**
Quelle commande permet d’afficher l’adresse IP sous Windows ?

Zone de texte :
[ champ de réponse libre ]

Bouton :
[ Valider ]

---

### Étape 2 — Flip card

Quand l’utilisateur clique sur Valider :

La carte se retourne avec animation.

Face arrière :

**Bonne réponse :**
ipconfig

Puis 2 boutons :

- ✅ J’avais bon
- ❌ J’avais faux

---

### Étape 3 — Score

Le score se met à jour :

**Score : 7 / 10**

Puis bouton :

[ Question suivante ]

### Important

Le système ne corrige pas automatiquement.

C’est l’utilisateur qui s’auto-évalue.

But pédagogique : forcer la mémorisation active.

---

## Mode Multijoueur

### Phase 1 — Création du Lobby (Prof)

Le professeur peut configurer :

- Nom du quiz
- Thèmes sélectionnés
- Nombre de questions
- Temps par question (optionnel)
- Mode individuel

Bouton :
[ Créer la salle ]

Le système génère un code lobby :

**TECH-482**

Le prof devient Host.

---

### Phase 2 — Rejoindre le Lobby (Élèves)

Champs :

- pseudo
- code du lobby

Bouton :
[ Rejoindre ]

Exemple :

Pseudo : Lucas  
Code : TECH-482

---

### Phase 3 — Réponses des Élèves

Chaque question s’affiche :

**Question :**
Quelle commande affiche l’adresse IP sous Windows ?

Champ libre :
[ réponse ]

Bouton :
[ Valider ]

Important : aucune correction immédiate.

Les élèves répondent à toutes les questions avant correction.

---

### Phase 4 — Correction Collective (Prof)

Quand tout le monde a terminé :

Le Host passe en mode correction.

Pour chaque question :

**Question :** Quelle commande affiche l’adresse IP ?  
**Réponse attendue :** ipconfig

Puis affichage des réponses :

Élève : Lucas  
Réponse : ipconfig

Boutons :

- ✅ Correct
- ❌ Incorrect

Puis élève suivant.

Le prof valide manuellement.

Important : la validation appartient uniquement au professeur.

---

### Phase 5 — Classement Final

Après correction :

🥇 Lucas — 9/10  
🥈 Sarah — 8/10  
🥉 Yanis — 7/10

Option bonus : afficher “Erreur la plus fréquente”.

---

## Structure des pages

### Page d’accueil

Choix :

- Mode Solo
- Mode Multijoueur

### Solo

- quiz screen
- correction screen
- score final

### Multi

#### Prof

- host setup
- lobby room
- correction screen
- ranking screen

#### Élève

- join screen
- answer screen
- waiting room
- final ranking

---

## Données à prévoir

### Questions

Chaque question contient :

- id
- thème
- question
- réponse attendue
- difficulté (optionnel)

Exemple JSON :

```json
{
  "id": 1,
  "theme": "Réseau",
  "question": "Quelle commande affiche l’adresse IP ?",
  "answer": "ipconfig"
}
```

---

## Version MVP (priorité)

### Obligatoire

- mode solo
- mode lobby simple
- réponses libres
- correction manuelle
- classement final

### Plus tard

- timer
- avatars
- mode équipe
- historique
- statistiques
- IA de correction
- répétition espacée
- sauvegarde cloud

---

## Important pour le développeur

Le projet doit être pensé pour être extensible.

Architecture propre.

Code simple à maintenir.

Pas de code spaghetti.

Le mode multijoueur doit pouvoir évoluer vers :

- Supabase
- Firebase
- WebSocket temps réel

Commencer simple mais propre.

---

## Objectif final

Créer une plateforme de révision intelligente :

moins QCM scolaire, plus réflexion + correction + pédagogie active.

Le vrai cœur du projet : la correction collective.

C’est cela qui fait la différence.

