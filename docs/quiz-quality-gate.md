# Quiz Quality Gate

Ce controle automatise valide les lots de questions avant integration.

## Commande

- `npm run quiz:quality`
- ou `dart run tool/quiz_quality_gate.dart`

## Regles controlees automatiquement

- Presence des champs critiques: `question`, `explanation`, `difficulty`.
- Presence/validite du champ `type`: `qcm`, `vrai_faux`, `association`, `mise_en_ordre`.
- `difficulty` valide en 1/2/3 (ou alias texte classique).
- QCM: 4 options non vides, bonne reponse valide (`answer` A-D ou index 0-3).
- Longueur des 4 options QCM dans une plage de +/-20%.
- Coherence de forme: on cible surtout les biais evidents (ex: bonne reponse seule avec parentheses).
- References source dans le texte pedagogique: warning si une formulation cite explicitement le chapitre (ex: "selon le chapitre", "dans ce chapitre", "d'apres le chapitre").
- Anti-biais: pas 3 memes lettres correctes d'affilee.
- Anti-biais sur fenetres de 10 QCM: max 3 occurrences de la meme lettre.
- Vrai/Faux: equilibre global proche de 50/50 (ecart max 1 item).
- Vrai/Faux: 2 options exactes attendues (`Vrai`, `Faux`) avec `answer`/`correct_index` coherents.
- Vrai/Faux: warning si l'enonce commence par `Affirmation :`.
- `shuffle_answers`: erreur si present mais different de `true`.
- `shuffle_answers`: warning si absent.
- Presence d'un ancrage de cours (warning): `notion_id`, `chapter_slug`, etc.

## Politique recommandee

- Erreurs (`ERROR`) => lot bloque, corrections obligatoires (structure JSON, champs critiques, validite des bonnes reponses).
- Avertissements (`WARNING`) => lot acceptable; corriger en priorite les biais evidents (bonne reponse visiblement avantagée).
- A executer a chaque generation de lot, puis apres toute retouche manuelle.
- Important: un warning n'impose pas une retouche mecanique. Conserver la lisibilite pedagogique et la naturalite du francais reste prioritaire.
