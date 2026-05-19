# Features futures — Backlog long terme

Ce fichier documente les idées validées pour les versions futures d'Eskolia,
une fois la version web stable et déployée.

---

## 1. Version Desktop + IA locale offline

**Contexte**
Eskolia est une app Flutter — le même code tourne sur web ET desktop
(Windows / macOS / Linux) avec très peu d'adaptations. En mode desktop,
le blocage CORS disparaît et l'app peut appeler une API locale (`localhost`).

**Vision**
Distribuer Eskolia en application desktop installable, avec un LLM embarqué
via **Ollama** (standard local LLM). Zéro internet requis après installation.
Idéal pour les centres de formation et les établissements scolaires avec
infrastructure réseau limitée ou politique de sécurité restrictive.

**Flux utilisateur cible**
1. Installer Eskolia Desktop (`.exe` / `.deb` / `.dmg`)
2. Au premier lancement : assistant d'installation du LLM local (téléchargement
   du modèle guidé, progression affichée)
3. Toutes les fonctionnalités IA (génération de cours, quiz, notebook) tournent
   100 % en local — aucune donnée ne quitte la machine

**Modèles recommandés**

| Modèle | Taille | RAM min | Qualité cours/quiz | Notes |
|---|---|---|---|---|
| Phi-3 Mini (Microsoft) | 2.3 GB | 4 GB | ★★★☆☆ | Ultra-léger, rapide |
| Llama 3.2 3B | 2 GB | 4 GB | ★★★☆☆ | Très léger |
| Mistral 7B | 4.1 GB | 8 GB | ★★★★☆ | Meilleur rapport qualité/taille |
| Qwen2.5 7B | 4.7 GB | 8 GB | ★★★★★ | Meilleur sur schemas JSON stricts |

Recommandation pour lycées/CFA avec matériel standard : **Mistral 7B via Ollama**
(supporte JSON mode, API OpenAI-compatible, qualité honnête sans GPU).

**Travail technique estimé**

Ollama expose une API OpenAI-compatible sur `http://localhost:11434/v1`.
`AiChatService` n'a donc besoin d'aucune modification — il suffit de :

- Ajouter `AiProvider.local` dans l'enum :
  ```dart
  // Dans ai_provider.dart — décommenter pour la version desktop
  // local, // Ollama — desktop only
  ```
  Avec `baseUrl: 'http://localhost:11434/v1'` et `defaultModel: 'mistral'`.

- Créer un écran `OllamaSetupScreen` :
  - Vérifie si Ollama tourne (`GET http://localhost:11434`)
  - Propose le téléchargement du modèle (`ollama pull mistral`)
  - Affiche la progression du téléchargement via process stdout

- Adapter le router pour distinguer web/desktop :
  ```dart
  import 'dart:io' show Platform; // uniquement en mode non-web
  ```

- Packager via `flutter build windows` / `flutter build linux`

Estimation : **1 semaine de travail** une fois la version web finalisée.
L'intégralité du pipeline IA (prompts, validation JSON, quiz, notebook)
s'applique sans modification au LLM local.

---

## 2. (Placeholder pour futures idées)

> Ajouter ici au fur et à mesure.
