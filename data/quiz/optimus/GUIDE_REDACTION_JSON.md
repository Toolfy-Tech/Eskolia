# 📝 Cahier des Charges : Création de Cartes "Optimus Mastery"

Ce document définit les règles strictes pour la création de nouvelles questions au format JSON pour le projet Eskolia. Toute carte doit suivre cette structure pour être acceptée par le système.

---

## 🗂 Structure Commune (Base)
Chaque objet JSON doit obligatoirement contenir :
- `id`: Identifiant unique (ex: `O03-C02-045`).
- `category`: Thème principal (ex: `Hardware`, `Réseaux`).
- `chapter`: Nom du chapitre (ex: `Adressage IP`).
- `tier`: Niveau de difficulté (`S`, `A`, `B` ou `C`).
- `type`: Identifiant de la technique (ex: `ticket`, `sequence`).
- `question`: L'énoncé de la carte.
- `answer`: La réponse brute ou la conclusion.
- `comment`: L'explication pédagogique ou l'astuce de pro.

---

## 🎭 Spécifications par Type de Carte

### 1. Type `ticket` (Tier S)
*Simule un ticket d'incident réel.*
- **Champ spécifique :** `"checklist": ["Etape 1", "Etape 2", ...]`
- **Règle :** La checklist doit être ordonnée et contenir les réflexes métier indispensables.
- **Ton :** Utiliser des guillemets pour citer l'utilisateur (ex: "Mon PC ne démarre plus...").

### 2. Type `diagnostic_indices` (Tier S)
*Apprend la déduction par étapes.*
- **Champ spécifique :** `"indices": ["Indice 1", "Indice 2", "Indice 3"]`
- **Règle :** Les indices doivent être de plus en plus précis. Le score diminue à chaque indice révélé.

### 3. Type `sequence` (Tier A)
*Maîtrise des procédures.*
- **Champs spécifiques :** 
    - `"options": ["B", "A", "C"]` (Liste mélangée)
    - `"answer": ["A", "B", "C"]` (Liste dans le bon ordre)
- **Règle :** Les étapes doivent être claires et non ambiguës.

### 4. Type `astuce_pro` (Tier A)
*Flashcard classique enrichie.*
- **Règle :** Le `comment` doit impérativement commencer par "Astuce de pro :" ou "Réflexe métier :".

### 5. Type `reformulation` (Tier B)
*Vulgarisation pour le client.*
- **Règle :** La `answer` doit utiliser une métaphore simple. Le `comment` doit lister les critères de réussite (ex: "Ne pas utiliser le mot DNS").

### 6. Type `vrai_faux` (Tier B)
*Élimine le hasard.*
- **Règle :** La `answer` est uniquement "Vrai" ou "Faux". Le `comment` doit obligatoirement justifier le pourquoi.

### 7. Type `visual_id` (Tier C)
*Reconnaissance de composants.*
- **Règle :** Pour l'instant textuel, doit décrire précisément une forme, une couleur ou un emplacement physique.

---

## 🧠 Règles de Rédaction "Vision Mastery"
1. **Lien Inter-Section :** Si une question est de niveau O02 ou supérieur, essayez d'inclure une référence à une section précédente (ex: un problème réseau causé par un composant hardware).
2. **Réalité Terrain :** Évitez les questions purement théoriques ("C'est quoi l'UDP ?"). Préférez : "Pourquoi choisir l'UDP pour du streaming ?".
3. **Zéro Jargon Client :** Dans les types `reformulation`, bannissez les termes techniques dans la réponse.
4. **Format des ID :** `[CODE SECTION]-[CODE CHAPITRE]-[NUMERO]` (ex: `O01-C04-012`).

---

## 📥 Exemple de fichier valide
```json
[
  {
    "id": "O03-C02-099",
    "category": "Réseaux",
    "chapter": "Diagnostic",
    "tier": "S",
    "type": "ticket",
    "question": "TICKET #99 : 'Internet est lent sur mon PC uniquement.'",
    "checklist": [
      "Vérifier le câble RJ45 (Lien Section 01)",
      "Tester un ping vers la passerelle",
      "Vérifier si un téléchargement est en cours",
      "Désactiver/Réactiver la carte réseau"
    ],
    "answer": "Goulot d'étranglement local (Câble ou Carte réseau).",
    "comment": "Astuce de pro : Un câble Cat 5e endommagé peut brider la connexion à 100 Mb/s au lieu de 1 Gb/s."
  }
]
```
