---
name: Structuration du Cours Optimus
description: Découpe et met en forme le cours TIP « Optimus » en chapitres Markdown pour l'app Eskolia, en préservant fidèlement la rédaction d'origine. Cours uniquement — ne génère AUCUN quiz.
---

# Objectif

Ce skill s'active pour **produire les fichiers de cours du track Optimus** à partir d'un cours déjà rédigé. Il **ne génère pas de quiz** (le quiz est traité par un skill séparé). Sa mission est de **découper** un cours source en chapitres exploitables par l'app, **sans en réécrire le fond**.

> ⚠️ **Principe fondamental — FIDÉLITÉ.** Le cours Optimus est une transcription fidèle du travail de l'auteur. Ce skill **structure et met en forme**, il ne **résume pas**, ne **reformule pas** et ne **réécrit pas** en style « microlearning ». On conserve les phrases, l'enchaînement, les tableaux, les encadrés et les exemples de l'auteur. Si une tournure est gardée à l'identique, c'est voulu.

---

# 1. Source et périmètre

- **Source unique** : le fichier de cours complet fourni (ex. `docs/cours_complet_v2.md` / `Cours_TIP_complet.md`).
- Le cours est organisé en **8 modules** (`# MODULE X : …`) contenant des sections (`## …`).
- Certaines sections sont des **ajouts marqués 🤖** : on les **garde et on garde le marqueur**.
- **Track cible** : `optimus`. Les chapitres vivent sous `data/curriculum/optimus/`.

---

# 2. Règle de couverture (NON négociable)

- **100 % des sections de contenu** du cours source doivent se retrouver dans un chapitre. **Aucune section ne doit être omise ni « oubliée ».**
- Seules exceptions autorisées : les sections purement récapitulatives de fin de module (« Fiche récapitulative — Questions d'examen types », « Récapitulatif — Chiffres clés »), qui peuvent être **fusionnées dans le dernier chapitre du module** ou converties en chapitre « Révision », mais **jamais supprimées**.
- Avant de produire quoi que ce soit, établir la **table de correspondance** « section source → chapitre » et vérifier qu'aucune section n'est laissée de côté (voir checklist §6).

---

# 3. Découpage en chapitres

- **Par défaut : une section `##` du cours = un chapitre.**
- Les sous-sections « (bis) » (ex. `## 7 (bis). Le paysage logiciel`) sont des **sections à part entière** → un chapitre dédié (ou fusion explicite avec la section voisine, jamais une suppression).
- **Sections très longues** (ex. Hardware, Admin Windows, Réseaux) : si une section dépasse une longueur raisonnable pour un chapitre, la **scinder en chapitres cohérents** de taille comparable, sans perdre de contenu.
- **Module 4 (Réseaux)** est structuré en « Partie 1…5 » : chaque **Partie = un chapitre** (ou scindée si trop longue).
- Viser des chapitres de **taille comparable** dans tout le parcours (éviter un chapitre de 3 lignes à côté d'un chapitre de 15 écrans).
- **Soumettre la liste des chapitres pour validation humaine AVANT de générer les fichiers.**

---

# 4. Format d'un fichier chapitre (`.md`)

Chaque chapitre est un fichier Markdown autonome respectant le format de l'app.

**En-tête obligatoire** (1re ligne, format Optimus) :

```markdown
> **Parcours Optimus — Module {N} · Chapitre {Y} sur {Z}**

# {Titre du chapitre}
```

- `{N}` = numéro de module, `{Y}` = numéro du chapitre dans le module, `{Z}` = nombre total de chapitres du module.
- Le **titre** reprend l'intitulé de la section source (nettoyé si besoin, mais fidèle).

**Corps du chapitre :**
- Reprendre **le texte de l'auteur tel quel** : paragraphes, listes, **tableaux conservés en tableaux**, blocs de code conservés.
- Conserver les **encadrés** (« À retenir », « Attention », « Réflexe terrain ») dans leur style d'origine (blocs `>`).
- Conserver les **marqueurs 🤖** sur les passages ajoutés.
- Mise en forme web aérée autorisée (titres `##`/`###`, espacements) **tant qu'elle ne modifie pas le fond**.
- **Interdit** : résumer, raccourcir, retirer un chiffre/une commande/un détail technique, transformer la prose en simples puces, ou plaquer une structure imposée (pas de « 🤔 Le Pourquoi / 👣 Pas-à-pas / 🌍 Analogie / 🧠 Anti-sèche » sur du contenu qui ne l'avait pas).

---

# 5. Intégration au manifeste `index.json`

Mettre à jour `data/curriculum/optimus/index.json` :

- **Sections** : une entrée par module (`id` type `O01`…`O08`, `titre`, `slug`).
- **Chapitres** : pour chaque chapitre, renseigner
  - `id` (ex. `C01`, unique dans la section),
  - `section` (ex. `O02`),
  - `titre`, `slug`,
  - `path` → chemin du `.md` du chapitre,
  - `mastery_quiz_path` → chemin **prévu** du quiz (généré par le skill quiz). Réserver le chemin même si le quiz n'existe pas encore.
- Respecter exactement le **schéma déjà attendu par le loader** (`tip_catalog_loader` / `index.json` existant) : ne pas inventer de champs.
- Conserver la cohérence track (`"track": "optimus"`).

> Convention d'`id` de quiz associée (gérée par le skill quiz) : `OPT-M{module}-C{chapitre}-{NNN}`, ex. `OPT-M02-C03-001`.

---

# 6. Checklist de complétude (à exécuter avant livraison)

1. **Couverture** : chaque section `##` du cours source (y compris les « (bis) » et les ajouts 🤖) est rattachée à un chapitre. Aucune omise.
2. **Fidélité** : aucun tableau aplati en puces, aucun chiffre/commande retiré, aucune reformulation du fond.
3. **Marqueurs 🤖** préservés là où ils étaient.
4. **En-têtes** de chapitre corrects (`Module N · Chapitre Y sur Z`), `Z` cohérent avec le nombre réel de chapitres du module.
5. **`index.json`** : sections et chapitres déclarés, `path` valides, `mastery_quiz_path` réservés, schéma respecté.
6. **Équilibre** : pas de chapitre anormalement court ou long par rapport aux autres.

---

# 7. Ce que ce skill NE fait PAS

- ❌ Générer des quiz (rôle du skill quiz dédié).
- ❌ Réécrire / résumer / « vulgariser » le contenu de l'auteur.
- ❌ Supprimer des sections jugées « secondaires ».
- ❌ Inventer du contenu non présent dans le cours source.
