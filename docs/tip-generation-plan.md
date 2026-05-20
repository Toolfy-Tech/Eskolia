# Plan de génération du Parcours TIP (IA)

## Contexte

Eskolia possède déjà un **Parcours Optimus** créé par l'humain (contenu issu
du cours PDF du formateur). L'objectif est de créer un **second parcours
entièrement généré par l'IA**, complémentaire et pédagogiquement unique.

Ce document décrit le workflow à suivre pour le lancer.

---

## Étape 1 — Définir le référentiel sur Claude.ai

**Où** : https://claude.ai (conversation normale, pas Claude Code)

**Ce qu'il faut apporter à Claude.ai :**
- Le PDF du référentiel officiel RNCP du titre TIP
  (ou l'intitulé exact + code RNCP si pas de PDF disponible)
- L'intitulé précis du titre : ex. "Technicien(ne) en Installation et
  Maintenance Informatique" ou autre appellation exacte du centre
- Les blocs de compétences (CCP) si connus
- Ce que le Parcours Optimus couvre déjà (pour éviter la redondance)
- Ton ressenti : ce qui est flou, incomplet ou mal expliqué dans l'existant

**Ce que Claude.ai doit produire :**

```
1. Fiche identité du titre
   - Intitulé officiel
   - Code RNCP + niveau (ex: niveau 4 = Bac)
   - Blocs de compétences (CCP 1, CCP 2, ...)
   - Durée typique de formation
   - Modalités d'examen

2. Plan du parcours IA — structure complète
   - Sections (ex: 6 sections comme Optimus ou différent)
   - Chapitres par section avec :
     * Titre
     * Objectifs pédagogiques (2-3 bullet points)
     * Compétences CCP couvertes
     * Notions clés à aborder
     * Type de quiz associé (classic / sequence / diagnostic_indices)

3. Ce qui différencie ce parcours d'Optimus
   - Approche pédagogique différente (ex: plus de cas pratiques,
     plus de mises en situation, plus de schémas)
   - Angles non couverts par Optimus
```

**Prompt de démarrage suggéré pour Claude.ai :**

> Je prépare une formation TIP (Technicien Informatique et Prestations —
> ou intitulé exact) et je veux créer un parcours de formation complet,
> structuré et pédagogiquement solide, entièrement généré par l'IA.
>
> Voici le référentiel officiel : [coller le PDF ou le texte du référentiel]
>
> Il existe déjà un parcours humain qui couvre : Hardware, Systèmes
> d'exploitation, Réseaux, Maintenance & Sauvegarde, Cybersécurité, IA.
>
> Je veux un NOUVEAU parcours IA qui :
> - Respecte exactement les blocs de compétences du référentiel officiel
> - Adopte une approche pédagogique différente (mise en situation, cas
>   terrain, progression logique du débutant vers le technicien)
> - Couvre tous les points d'examen sans exception
>
> Produis : la fiche identité du titre, puis le plan complet section par
> section avec chapitres, objectifs et notions clés. Sois exhaustif.

---

## Étape 2 — Valider le plan

Avant de générer quoi que ce soit :
- Vérifier que tous les CCP sont couverts
- Vérifier que la progression est logique (du simple au complexe)
- Ajuster les titres de chapitres si besoin
- Confirmer le nombre de chapitres (cible : 20-30 chapitres au total)

---

## Étape 3 — Générer le contenu sur Claude Code

**Où** : ici, dans cette session Claude Code

**Ce qu'il faut apporter à Claude Code :**
- Le plan validé (copier-coller depuis Claude.ai)
- Le nom exact du nouveau parcours (ex: "Parcours TIP — IA")
- Le slug technique (ex: `tip-ia`)

**Ce que Claude Code va faire :**
- Créer la structure de dossiers dans `data/curriculum/tip-ia/`
- Créer l'`index.json` du parcours
- Générer chaque chapitre `.md` (250-400 lignes, format Eskolia)
- Générer chaque fichier quiz `.json` (15-20 questions, tous types)
- Déclarer les assets dans `pubspec.yaml`
- Intégrer le parcours dans le router et l'écran de sélection
- Commit + push section par section

**Standard qualité par chapitre :**
```
- 250 à 400 lignes de Markdown
- Structure : intro → concepts clés → tableaux comparatifs
  → procédures pas-à-pas → cas terrain → points d'attention → résumé
- Niveau : technicien débutant, examen TIP en ligne de mire
- Exemples concrets issus du terrain IT français
- Quiz : 15-20 questions, mix classic / sequence / diagnostic_indices
```

---

## Format du plan attendu (à coller dans Claude Code)

```
PARCOURS : [Nom du parcours]
SLUG : [tip-ia ou autre]
NIVEAU : [Bac / Bac+2]
CCP : [liste des blocs]

SECTION 01 — [Titre]
  C01 : [Titre chapitre] | Objectifs : ... | Notions : ...
  C02 : [Titre chapitre] | Objectifs : ... | Notions : ...
  ...

SECTION 02 — [Titre]
  ...
```

---

## Notes importantes

- Le Parcours Optimus reste intact — il n'est pas modifié
- Le nouveau parcours IA est un parcours SÉPARÉ dans Eskolia
- Les deux parcours coexistent et se complètent
- L'apprenant peut faire les deux pour une préparation maximale
