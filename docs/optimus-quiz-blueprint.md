# Blueprint de creation quiz - Parcours Optimus

Version: 1.0  
Objectif: produire une banque de questions riche, coherente et pedagogique pour un niveau TIP, en suivant un workflow qualite "travail d'horloger".

## 1) Principes de production

- Generation chapitre par chapitre, dans le meme ordre que les cours.
- Mix progressif + epreuve finale pour chaque chapitre.
- Qualite prioritaire sur la vitesse.
- Questions 100% en francais, ton pro + ludique (tutoiement), contextualise terrain.
- Interdiction d'inventer hors cours; reemploi autorise des connaissances des sections precedentes.
- Interdiction de references directes au chapitre dans le texte des quiz (enonces/options/explications): exploiter le savoir appris sans formulations du type "selon le chapitre".

## 2) Repartition cible globale (formation complete)

Total cible propose: **1000 questions**.

Pourquoi 1000:
- assez de volume pour eviter la repetition,
- assez de granularite pour couvrir toutes les notions,
- compatible avec des modes apprentissage, revision et evaluation.

### Poids par section (importance TIP)

- O01 Hardware & Architecture: **180** (18%)
- O02 Systeme d'exploitation: **170** (17%)
- O03 Reseaux & Infrastructure: **230** (23%)
- O04 Maintenance & Sauvegarde: **160** (16%)
- O05 Cybersecurite: **170** (17%)
- O06 Utiliser l'IA: **90** (9%)

## 3) Repartition par chapitre (production + epreuve finale)

Modele applique a chaque chapitre:
- **80%** Questions de progression (entrainement)
- **20%** Epreuve finale de chapitre

### O01 Hardware & Architecture (180)

- C01 Fondations carte mere/CPU: 24 + 6 = **30**
- C02 Memoire/stockage: 28 + 7 = **35**
- C03 GPU/connectique/extensions: 20 + 5 = **25**
- C04 Energie/refroidissement: 20 + 5 = **25**
- C05 BIOS/UEFI: 20 + 5 = **25**
- C06 Assemblage/diagnostic: 32 + 8 = **40**

### O02 Systeme d'exploitation (170)

- C01 Systemes d'exploitation: 40 + 10 = **50**
- C02 Installer Windows: 48 + 12 = **60**
- C03 Virtualisation: 48 + 12 = **60**

### O03 Reseaux & Infrastructure (230)

- C01 Composants reseau/binaire: 32 + 8 = **40**
- C02 Adressage/segmentation: 40 + 10 = **50**
- C03 OSI/encapsulation/TCP-IP: 40 + 10 = **50**
- C04 VLANs/organisation: 32 + 8 = **40**
- C05 Services/protocoles critiques: 40 + 10 = **50**

### O04 Maintenance & Sauvegarde (160)

- C01 Definition + 3-2-1-1-0: 24 + 6 = **30**
- C02 Supports sauvegarde: 24 + 6 = **30**
- C03 Typologie sauvegardes: 24 + 6 = **30**
- C04 Plan RPO/RTO/snapshots: 32 + 8 = **40**
- C05 Solutions sauvegarde: 24 + 6 = **30**

### O05 Cybersecurite (170)

- C01 Malwares/menaces: 40 + 10 = **50**
- C02 Detection/analyse: 40 + 10 = **50**
- C03 Defense/outils technicien: 56 + 14 = **70**

### O06 Utiliser l'IA (90)

- C01 ROCT/contexte: 24 + 6 = **30**
- C02 Cas d'usage informatique: 24 + 6 = **30**
- C03 Pieges/securite IA: 24 + 6 = **30**

## 4) Regles de composition par lot

Pour tout lot de N questions (progression ou finale):

- Types:
  - QCM: 40%
  - Vrai/Faux: 20%
  - Association: 20%
  - Mise en ordre: 20%
- Convention Vrai/Faux (obligatoire):
  - options exactes: `["Vrai", "Faux"]`
  - pas de prefixe "Affirmation :" dans l'enonce
  - `answer` et `correct_index` obligatoirement coherents
- Champ `type` obligatoire par question: `qcm`, `vrai_faux`, `association` ou `mise_en_ordre`.
- Difficultes:
  - Facile: 30%
  - Moyen: 50%
  - Difficile: 20%
- Reponses:
  - distribution A/B/C/D equilibree
  - pas plus de 2 memes lettres consecutives
  - V/F vise 50/50

## 5) Cadence de fabrication (qualite max)

Pipeline par chapitre:

1. Lecture du chapitre source + extraction des notions.
2. Plan de couverture (themes x difficultes x types).
3. Generation d'un lot de **30 questions**.
4. Controle qualite automatique (`npm run quiz:quality`).
5. Passe "mode horloger" obligatoire (linguistique + anti-biais + homogenite).
6. Relecture manuelle pedagogique finale.
7. Retour utilisateur (checkpoint obligatoire toutes les 30 questions).
8. Corrections, puis lot suivant.

Regle process: ne jamais proposer un lot suivant tant que le lot courant n'a pas passe la passe horloger pragmatique (anti-biais evidents + coherence pedagogique).

## 5.b) Definition operationnelle du mode horloger

Un lot est "mode horloger pret" seulement si:
- accents/orthographe/ponctuation sont propres sur enonces, options et explications,
- aucune serie de 3 memes lettres correctes n'apparait,
- V/F est equilibre autant que possible sur le lot,
- la bonne reponse n'est pas systematiquement la plus longue,
- les distracteurs restent plausibles, techniques et pedagogiques.

## 6) Checklist de sortie d'un lot

- Questions reliees au chapitre (notion_id/chapter_slug/source_ref).
- Une seule bonne reponse indiscutable.
- Distracteurs plausibles (confusions reelles de debutant).
- Longueur/forme des options homogenes (regle +/-20%).
- Explication systematique apres chaque question.
- `shuffle_answers: true` quand le schema de donnees le supporte.

## 7) Regle de gouvernance

- Ce blueprint est la reference par defaut pour tout nouveau cours.
- Si un cours a un contexte special, on cree une variante "blueprint vX.Y" sans casser les regles coeur.
