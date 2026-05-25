# Eskolia — Guide Claude Code

## Stack
Flutter Web + Firebase (Firestore, Auth, Hosting). CI/CD sur push `main`.
Dart uniquement — pas de JS côté app. GoRouter ShellRoute.

## Règles absolues
- `withValues(alpha: x)` — JAMAIS `withOpacity(x)`
- Pas de guillemets typographiques `""` dans les fichiers Dart
- Pas de commentaires descriptifs — uniquement les WHY non-évidents
- Pas de `emoji` dans le code sauf dans les strings UI explicitement demandées
- Ne jamais pusher sur `main` directement — toujours via branche + merge

## Architecture features
Chaque feature suit : `data/` (models, repositories) → `presentation/` (screens, widgets).
Les anciens fichiers racine (`home_screen.dart`, etc.) sont des fantômes — ignorer.

## Providers IA (BYOK)
- Gemini : appel non-streaming `generateContent`, body `{"contents":[{"parts":[{"text":"..."}]}]}`
- Gemini model stocké dans SharedPreferences clé `gemini_model`
- Ollama : sentinel `'ollama'` dans Firestore, config dans SharedPreferences
- `testKey` retourne `Future<String?>` — null = OK, string = message d'erreur réel
- dart2js (Flutter Web) : ne jamais chaîner `?.` sur `dynamic` — utiliser `is List` / `is Map`

## Gestion du contexte — quand compacter

Claude doit dire explicitement quand compacter. Règles déclencheurs :

| Signal | Action recommandée |
|---|---|
| Après un déploiement (`git push main`) qui clôt une mission complète | `/compact` |
| Après avoir lu ou modifié plus de 6 fichiers dans la session | `/compact` |
| Après 3 features distinctes dans la même session | `/clear` (nouveau sujet) |
| Si la réponse commence à résumer ce qu'on a déjà fait | `/compact` immédiat |
| Si un fichier lu est signalé "Wasted call — file unchanged" | contexte déjà saturé → `/compact` |

**Format du rappel** : À la fin de chaque réponse post-déploiement ou post-mission,
Claude ajoute une ligne :
> `— Contexte : [leger | moyen | charge] · Suggestion : rien | /compact | /clear`

## Découpage des requêtes
1. Une feature à la fois — ne pas mélanger `quiz/` et `ai/` si non liées
2. Couche par couche — `data/` ou `presentation/`, pas les deux sauf si nécessaire
3. Citer les fichiers nommément — pas de "regarde le dossier X entier"
4. Après un push, nouveau sujet = nouvelle session ou /compact
