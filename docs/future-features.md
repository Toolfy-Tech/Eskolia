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

---

## 2. Eskolia Platform — Multi-formation & Écosystème complet

**Vision globale**
Transformer Eskolia d'un outil IT en une plateforme de formation universelle,
accessible à tout apprenant quel que soit son métier cible, avec un modèle
gratuit/ouvert et une couche B2B pour les écoles et CFA.

---

### 2.1 Bibliothèque de formations multi-domaines

**Principe**
Un apprenant crée son compte, parcourt un catalogue de formations, en choisit
une et commence immédiatement — comme Duolingo mais pour les métiers techniques.

**Contenu généré via IA + validation humaine**
Pipeline : expert métier rédige ses notes dans le Notebook → IA génère le cours
et le quiz → administrateur valide avant publication → disponible dans le catalogue.
Le pipeline est déjà construit à 80 % dans Eskolia actuel.

**Domaines cibles (ordre de déploiement suggéré)**
1. Informatique & Réseaux (déjà en place — TIP, TSSR, AIS)
2. Cybersécurité
3. Cloud & DevOps
4. Comptabilité / Gestion
5. RH & Management
6. Commerce & Marketing
7. ... (ouvert aux contributeurs)

**Modèle économique**
- Formations de base : 100 % gratuites, financées par le B2B
- Formations certifiantes ou premium : accès payant ou abonnement
- Écoles/CFA : licence institution (espace privé + marque blanche possible)

---

### 2.2 Espace Institutions — Écoles & CFA

**Principe**
Une école ou un CFA crée son espace Eskolia, y importe ses propres cours et
quiz (format JSON Eskolia ou via l'éditeur Notebook+IA), et ses apprenants
accèdent à un environnement branded avec le contenu officiel de l'établissement.

**Fonctionnalités spécifiques**
- Import de cours et quiz maison (format Eskolia existant)
- Tableau de bord prof amélioré : suivi de progression par apprenant, alertes
- Quiz multijoueur en classe (déjà fonctionnel)
- Rapports d'activité exportables (PDF/CSV) pour les bilans pédagogiques
- Option marque blanche : logo et couleurs de l'établissement

**Architecture**
Firestore supporte déjà la multi-tenancy via une collection `institutions/{id}`.
Les formations privées d'une institution ne sont visibles que de ses membres.

---

### 2.3 Stagios — Recherche de stage, alternance et emploi

**Principe**
Intégré directement dans Eskolia : un apprenant qui termine (ou progresse dans)
une formation peut accéder à Stagios pour trouver un stage, une alternance ou
un emploi dans le domaine qu'il apprend.

**Valeur différenciante**
Contrairement à LinkedIn ou Indeed, Stagios connaît le niveau réel de
l'apprenant (quiz réussis, formations complétées, certifs Eskolia) et peut
matcher intelligemment avec les offres adaptées à son profil réel — pas juste
son CV.

**Fonctionnalités envisagées**
- Offres de stage / alternance / CDI par domaine et région
- Profil apprenant automatiquement renseigné depuis les formations Eskolia
- Badge "Certifié Eskolia" vérifiable par les recruteurs
- Partenariats avec entreprises partenaires des CFA utilisateurs

**Modèle économique possible**
Offres gratuites pour les apprenants. Entreprises payent pour publier et accéder
aux profils certifiés.

---

### 2.4 Feuille de route personnelle — Validation du modèle

La validation du concept se fait via un cursus complet réalisé sur la plateforme :

| Formation | Statut | Objectif |
|---|---|---|
| **TIP** — Technicien Informatique et Prestations | En cours | Valider le modèle Eskolia sur un vrai exam |
| **TSSR** — Technicien Supérieur Systèmes & Réseaux | Suivant | Première formation TSSR entièrement créée avec Eskolia + IA |
| **AIS** — Administrateur d'Infrastructures Sécurisées | Après | Fin du cursus — preuve que la plateforme couvre un parcours complet |

À l'issue : **"J'ai passé mes trois certifications avec Eskolia"** — meilleur
argument de démonstration possible, reproductible par tout autre apprenant.

---

### 2.5 Ce qui est déjà en place (capital à ne pas reconstruire)

| Composant existant | Réutilisation dans la plateforme |
|---|---|
| Parcours Optimus (sections JSON) | Format de base pour toute nouvelle formation |
| Quiz multijoueur Firestore | Identique pour toutes les disciplines |
| Notebook + IA (cours + quiz) | Pipeline de création de contenu pour les formateurs |
| TP scénarios JSON | Réutilisable pour labs de toute discipline |
| Système de profil + achievements | Gamification inter-formations |
| Firebase Auth + Firestore | Multi-tenant prêt avec collection `institutions/` |
