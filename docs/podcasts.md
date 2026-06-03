# Podcasts — documentation feature

Fonctionnalite : un podcast audio (analyse approfondie type NotebookLM) par
module du parcours Optimus. L'eleve peut l'ecouter avant de lire le cours.

## Ou vivent les fichiers audio

Les `.m4a` ne sont PAS dans le depot (trop lourds, ~320 Mo au total). Ils sont
heberges dans une **release GitHub** :

```
https://github.com/Toolfy-Tech/Eskolia/releases/download/Podcast/M0X_podcast.m4a
```

Choix retenu : gratuit, pas de bloat du depot, URLs stables streamables. Firebase
Storage a ete ecarte (payant). Seul le manifeste leger est bundle dans l'app.

## Fichiers

| Fichier | Role |
|---|---|
| `assets/audio/podcasts.json` | Manifeste : 8 entrees `{id, sectionId, title, subtitle, url}`. **Seule source des URLs.** |
| `lib/features/podcasts/data/podcast_model.dart` | `Podcast` + `PodcastCatalog.load()` / `forSection(sectionId)` (parsing type-safe dart2js). |
| `lib/features/podcasts/presentation/podcast_player_card.dart` | `PodcastPlayerCard({required title, required url, subtitle})` — lecteur autonome reutilisable (play/pause/seek, un seul podcast joue a la fois). |
| `lib/features/podcasts/presentation/podcasts_screen.dart` | Ecran liste des 8 podcasts (route `/podcasts`). |

## Mapping podcast <-> module

Les `id`/`sectionId` du manifeste correspondent **1:1** aux ids de section du
curriculum (`data/curriculum/optimus/index.json`) : `M01`..`M08`.

L'association ne repose sur **aucune liste codee en dur** : `PodcastCatalog.forSection(sectionId)`
matche `podcast.sectionKey (== sectionId ?? id)` avec le `sectionId` du module.

## Points d'acces dans l'app

1. **Espace Podcasts autonome** : carte en tete de l'ecran Parcours -> route `/podcasts`
   (liste des 8 episodes).
2. **En tete de cours** : dans `chapter_lesson_screen.dart`, le podcast de la section
   s'affiche au-dessus du contenu, precede d'un bandeau-conseil ("Ecoute le podcast
   avant de lire"). Affiche **uniquement sur le 1er chapitre de chaque section**
   (`section.modules.first.id == moduleId`) pour ne pas le repeter sur tous les chapitres.

## Ajouter / modifier un episode

Editer `assets/audio/podcasts.json` (rien d'autre). Pour rattacher a un module,
mettre `sectionId` = l'id de section voulu (`M01`..`M08`).

## A valider / limites

- Lecture non testee en navigateur dans l'environnement de dev distant (pas de
  toolchain). Les releases GitHub servent les `.m4a` en `Content-Type:
  application/octet-stream` ; la balise `<audio>` (via `audioplayers`) doit lire
  quand meme, mais c'est le seul point a confirmer a l'execution (`flutter run -d chrome`).
- `audioplayers ^6.1.0` ajoute au `pubspec.yaml` -> faire `flutter pub get`.
