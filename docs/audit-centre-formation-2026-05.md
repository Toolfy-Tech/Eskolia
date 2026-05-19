# Audit Eskolia — Rapport Centre de Formation
**Date :** Mai 2026
**Rôle :** Auditeur indépendant spécialisé en plateformes LMS
**Périmètre :** Application web Eskolia — version `claude/fix-multiplayer-launch-J3A4S`

---

## Verdict global

> **L'application est fonctionnelle et utilisable dans un contexte de formation,
> mais n'est pas encore prête pour un déploiement en centre de formation professionnel
> en l'état. Trois problèmes bloquants et une dizaine de points à corriger avant
> toute mise en production.**

**Note globale : 6,5 / 10**

---

## Scores par dimension

| Dimension | Note | Verdict |
|---|---|---|
| Sécurité des données | 5/10 | ⚠️ Bloquant |
| Complétude des écrans | 7/10 | ✅ Acceptable |
| Qualité du code | 6/10 | ⚠️ Fragile |
| Contenu pédagogique | 7.5/10 | ✅ Bon |
| Expérience utilisateur | 7/10 | ✅ Acceptable |
| Stabilité (gestion d'erreurs) | 5.5/10 | ⚠️ Insuffisant |

---

## SECTION 1 — SÉCURITÉ (BLOQUANT pour centre de formation)

### 🔴 Critique #1 — Clés API IA stockées en clair dans Firestore
**Fichier :** `lib/features/ai/data/ai_key_repository.dart` lignes 39-72

Les clés API des utilisateurs (OpenAI, Anthropic, Groq...) sont stockées
**sans chiffrement** directement dans Firestore. Tout administrateur Firebase
avec accès à la console peut lire toutes les clés de tous les utilisateurs.

**Risque pour un centre :** Si le centre fournit des clés API mutualisées aux
élèves, elles seraient exposées. Violation potentielle des CGU des providers IA.

**Correction :** Chiffrement côté client avant stockage, ou architecture
backend proxy (Cloud Function) qui conserve la clé côté serveur.

---

### 🔴 Critique #2 — Les parties multijoueur sont modifiables par n'importe quel joueur
**Fichier :** `firestore.rules` lignes 86, 90

```
allow read, write: if signedIn()  // TROP PERMISSIF
```

N'importe quel élève connecté peut modifier les scores, les réponses, ou
l'état d'une bataille multijoueur qui ne le concerne pas.

**Risque pour un centre :** Triche triviale lors des épreuves en classe.
Un élève peut modifier les résultats de ses camarades depuis la console.

**Correction :** Restreindre les writes aux participants du lobby uniquement.

---

### 🟡 Important #3 — Profils utilisateurs lisibles par tous
**Fichier :** `firestore.rules` ligne 47

```
allow read: if signedIn()  // Expose email, rôle, progression de tous
```

Tout élève connecté peut lire le profil complet de tous les autres :
email, niveau, progression, badges, dernière connexion, **et rôle admin**.

**Correction :** Séparer champs publics / privés, ou restreindre à `isSelf()`.

---

### 🟡 Important #4 — Comptes admin codés en dur dans le source
**Fichier :** `lib/features/admin/data/staff_bootstrap.dart`

Des usernames et emails sont hardcodés pour obtenir les droits admin automatiquement.
Si ce fichier est versionné (il l'est), ces comptes ont un accès admin permanent
indépendamment de Firestore.

**Correction :** Supprimer les bootstrap emails, utiliser uniquement le champ
`role` en Firestore avec attribution manuelle.

---

### 🟡 Important #5 — Validation des pseudos insuffisante
**Fichier :** `lib/features/auth/data/auth_repository.dart` lignes 174-175

Seuls `/` et `\` sont bloqués. Les caractères `;`, `<`, `>`, `"`, `'` sont
acceptés — risque d'injection dans les chemins Firestore et affichage HTML.

**Correction :**
```dart
if (!RegExp(r'^[a-zA-Z0-9_\-]{3,20}$').hasMatch(username)) throw ...
```

---

## SECTION 2 — STABILITÉ ET GESTION D'ERREURS

### 🔴 Bloquant — Routes TP cassées (UnimplementedError)
**Fichier :** `lib/features/solo/data/practical_catalog_repository.dart`

```dart
throw UnimplementedError('Le parcours $trackId est en cours de refonte.');
```

Les routes `/tp/:trackId` et `/tp/:trackId/missions` crashent l'application
avec une erreur non gérée. Aucun message utilisateur, juste un écran blanc.

**Impact :** Si un élève clique sur un TP depuis le menu Solo, l'app plante.

**Correction :** Remplacer par une page "Contenu en cours de préparation" ou
rediriger vers `/tp` (le hub fonctionne, lui).

---

### 🟡 Fragile — Partie multijoueur sans protection sur les opérations critiques
**Fichier :** `lib/features/lobby/data/lobby_repository.dart` lignes 404-435

`startBattleCountdown()` n'a pas de try/catch global. Une erreur Firestore
lors du lancement d'une bataille laisse tous les joueurs dans un état bloqué
sans message d'erreur.

---

### 🟡 Fragile — Force unwrap sur données Firestore
**Fichier :** `lib/features/quiz/services/quiz_repository.dart` ligne 218

```dart
final d = snap.data()!  // crash garanti si document absent
```

Si un document Firestore est absent ou mal formé, l'app crashe sans récupération.

---

### 🟡 Fragile — Stream IA sans timeout
**Fichier :** `lib/features/ai/data/ai_chat_service.dart` lignes 65-86

Les requêtes vers les providers IA n'ont pas de timeout configuré. Si le
provider ne répond pas, l'app reste bloquée indéfiniment avec le spinner de
génération actif.

---

### 🟠 Mineur — Catch trop larges qui masquent les erreurs
Dans plusieurs fichiers (`quiz_repository.dart`, `lobby_repository.dart`),
des `catch (_) {}` vides avalent silencieusement des erreurs qui devraient
remonter à l'utilisateur ou au moins être loggées.

---

## SECTION 3 — CONTENU PÉDAGOGIQUE

### Volume disponible

| Ressource | Quantité | Temps estimé |
|---|---|---|
| Questions quiz Optimus | 437 | ~18 heures |
| Questions TIP-Quiz | 255 | ~8 heures |
| Chapitres de cours | 25 | ~2-3 heures |
| Scénarios TP | 6 (AD × 3 + PS × 3) | 20-50 heures |
| Mini-formations docs | 5 | ~1 heure |
| **TOTAL** | | **45-79 heures** |

**Point positif :** 692 questions avec 8 types pédagogiques différents
(astuce pro, ticket, diagnostic, séquence, vrai/faux, etc.). Variété exemplaire.

---

### Déséquilibres identifiés

**Sections creuses (cours théorique insuffisant) :**

| Section | Cours (lignes) | Questions | Problème |
|---|---|---|---|
| Cybersécurité | ~200 lignes | 60 | Ratio cours/quiz trop faible |
| Utiliser l'IA | ~150 lignes | 50 | Contenu trop sommaire |
| Systèmes | ~600 lignes | 45 | Manque Linux/macOS |

**Linux et Virtualisation sous-représentés dans TIP-Quiz :**
20 questions chacun vs 40 pour les autres thèmes.

**Mini-formations RGPD/CNIL/ANSSI trop brèves :**
16-18 lignes chacune — suffisant pour une intro, pas pour une formation.

---

### Points forts pédagogiques

- Structure JSON 100% valide sur tous les fichiers
- Progression claire C (fondation) → B → A → S (spécialiste)
- 6 TP pratiques avec progression Débutant → Avancé bien scaffoldée
- Types de questions variés couvrant tous les niveaux cognitifs (Bloom)
- Contenu Réseaux et Maintenance excellent (100 questions chacun, cours complets)

---

## SECTION 4 — EXPÉRIENCE UTILISATEUR

### Points forts

- Design cohérent, dark theme soigné, animations fluides
- Navigation principale bien structurée (7 onglets clairs)
- États vides et erreurs gérés sur 85% des écrans
- Skeleton loaders présents sur les écrans principaux
- Quiz multijoueur fonctionnel et bien pensé pédagogiquement

---

### Points faibles

**Onboarding insuffisant pour un nouveau centre :**
Un élève qui crée son compte arrive sur la home sans aucun guidage.
Pas de "par où commencer ?", pas de sélection de formation, pas d'objectif.
Dans un centre de formation, les élèves doivent être guidés immédiatement
vers leur parcours.

**Pas de badge de notifications non lues** dans la barre de navigation.

**Progression du parcours codée en dur** dans le profil (`const totalChapters = 23`).
Ne se met pas à jour dynamiquement si le contenu évolue.

**Skeleton loaders incohérents** : certains écrans utilisent des skeletons,
d'autres un simple `CircularProgressIndicator`. À harmoniser.

---

## SECTION 5 — FONCTIONNALITÉS MANQUANTES pour un contexte centre

Les éléments suivants seraient attendus par un centre de formation mais
sont absents :

| Fonctionnalité | Priorité | Complexité |
|---|---|---|
| Tableau de bord formateur (suivi élèves) | Haute | Moyenne |
| Rapports de progression exportables (PDF) | Haute | Haute |
| Gestion de groupes/classes | Haute | Haute |
| Certificat de completion téléchargeable | Moyenne | Faible |
| Onboarding guidé (choix de formation) | Haute | Faible |
| Badge notifications non-lues | Faible | Faible |

---

## PLAN DE CORRECTION RECOMMANDÉ

### Phase 1 — Bloquants (avant tout déploiement)
1. **Règles Firestore battles/lobbies** — restreindre aux participants
2. **Corriger routes TP cassées** — UnimplementedError → page d'attente
3. **Validation pseudos** — regex strict alphanumériques

### Phase 2 — Sécurité données (avant déploiement avec données sensibles)
4. **Chiffrement clés API** — ou architecture proxy Cloud Function
5. **Profils utilisateurs** — séparer données publiques/privées
6. **Supprimer bootstrap admin hardcodé**

### Phase 3 — Stabilité (avant montée en charge)
7. **Try/catch sur opérations Firestore critiques** (battle, quiz)
8. **Timeout sur streams IA**
9. **Remplacer force unwraps** par null-safe patterns

### Phase 4 — Contenu et UX (avant lancement formation)
10. **Onboarding guidé** — sélection parcours au premier lancement
11. **Enrichir cybersécurité et IA** — cours théoriques insuffisants
12. **Certificat de completion**
13. **Tableau de bord formateur** minimal

---

## CONCLUSION DE L'AUDIT

Eskolia est une application **bien architecturée, techniquement solide dans ses
fondations**, avec un contenu pédagogique de qualité et une UX soignée.

Elle est **utilisable dès maintenant** pour :
- Un usage personnel de révision et d'entraînement
- Des tests avec un groupe réduit et bienveillant
- La validation du concept pédagogique

Elle **n'est pas encore prête** pour un déploiement institutionnel car :
- Les règles de sécurité Firestore sont trop permissives (triche possible)
- Deux routes crashent l'application
- Aucun outil de suivi formateur n'est disponible
- L'onboarding laisse les nouveaux utilisateurs sans guidage

**Estimation du travail pour atteindre la maturité institutionnelle :
4 à 6 semaines de développement concentré sur les phases 1 à 4 ci-dessus.**
