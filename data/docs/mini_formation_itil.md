# Mini-formation — ITIL 4 & Gestion des Services IT (ITSM)

## 1. Qu'est-ce qu'ITIL 4 ?
**ITIL (Information Technology Infrastructure Library)** est le cadre de référence mondial le plus largement adopté pour la gestion des services informatiques (ITSM). La version 4, axée sur l'agilité, le DevOps et la transformation numérique, place la **co-création de valeur** au cœur des activités IT.

---

## 2. Le Système de Valeur des Services (SVS)
Le SVS décrit comment l'ensemble des composants d'une organisation collaborent pour transformer des opportunités et des demandes en valeur réelle :
- **Principes directeurs** : 7 règles fondamentales guidant chaque décision IT.
- **Gouvernance** : Contrôle, orientation et alignement stratégique.
- **Chaîne de valeur des services (SVC)** : 6 activités interconnectées (*Planifier, Améliorer, Engager, Concevoir & Faire la transition, Obtenir/Construire, Fournir & Supporter*).
- **Pratiques de gestion** : 34 pratiques regroupées en Pratiques Générales, Pratiques de Gestion des Services et Pratiques Techniques.
- **Amélioration continue** : Démarche itérative structurée en 7 étapes.

---

## 3. Les 4 Dimensions du Service Management
Pour garantir une approche holistique et équilibrée, chaque service IT doit être analysé sous 4 dimensions :
1. **Organisations et personnes** : Compétences, culture d'entreprise, rôles, communication et leadership.
2. **Information et technologies** : Outils ITSM (ticketing), bases de données (CMDB), réseaux, cloud et IA.
3. **Partenaires et fournisseurs** : Gestion des prestataires, contrats de sous-traitance, accords de support.
4. **Flux de valeur et processus** : Enchaînement des étapes pour délivrer les services sans gaspillage (*Lean*).

---

## 4. Pratiques Opérationnelles Clés pour le Technicien

### A. Gestion des Incidents (Incident Management)
- **Objectif** : Rétablir le service normal le plus rapidement possible et minimiser l'impact sur l'activité métier.
- **Règle clé** : L'accent est mis sur la vitesse de restauration (utilisation de solutions de contournement / *workarounds*), sans attendre de comprendre la cause profonde.
- **Incidents majeurs** : Procédure d'urgence dédiée, cellule de crise et communication prioritaire.

### B. Gestion des Problèmes (Problem Management)
- **Objectif** : Identifier la cause racine (*Root Cause Analysis - RCA*) d'un ou plusieurs incidents afin d'éviter leur récurrence.
- **Concepts** :
  - *Problème* : Cause (connue ou inconnue) d'un ou plusieurs incidents.
  - *Erreur connue (Known Error)* : Problème dont la cause racine est identifiée et pour lequel une solution de contournement ou un correctif est documenté (base de connaissances / KEDB).

### C. Gestion des Changements (Change Enablement)
- **Objectif** : Maximiser le nombre de changements réussis en évaluant rigoureusement les risques.
- **Types de changements** :
  - *Changement standard* : Pré-autorisé, à faible risque, procédure éprouvée (ex. remplacement de souris, déploiement d'une application validée).
  - *Changement normal* : Nécessite une évaluation, un plan de test, un plan de retour arrière (*Rollback*) et la validation par le CAB (*Change Advisory Board*).
  - *Changement d'urgence* : Traité en priorité pour résoudre un incident majeur ou une faille critique.

### D. Centre de Services (Service Desk)
- Point de contact unique (**SPOC - Single Point of Contact**) entre les utilisateurs et la DSI.
- Gestion des demandes d'assistance, demandes de matériel/accès (*Service Requests*) et accueil téléphonique/portail.

### E. Gestion des Actifs et de la Configuration (CMDB / CI)
- **CI (Configuration Item)** : Tout composant nécessaire pour délivrer un service (serveur, switch, base de données, licence, document de procédure).
- **CMDB** : Base de données cartographiant tous les CI et leurs interdépendances afin de mesurer l'impact d'une panne ou d'un changement.

---

## 5. Mesures et Indicateurs de Performance (SLA / OLA / UC)
- **SLA (Service Level Agreement)** : Engagement contractuel entre la DSI et le client métier définissant les niveaux de service convenus.
- **OLA (Operational Level Agreement)** : Accord interne entre différentes équipes techniques de la DSI (ex. équipe Réseau et équipe Système).
- **UC (Underpinning Contract)** : Contrat liant la DSI à un fournisseur tiers (ex. opérateur télécom, éditeur logiciel).
- **GTI (Garantie de Temps d'Intervention)** : Délai maximal avant la première prise en charge d'un ticket.
- **GTR (Garantie de Temps de Rétablissement)** : Délai maximal pour restaurer le service opérationnel.
- **MTTR (Mean Time to Resolve)** : Temps moyen de résolution d'une panne.
- **MTBF (Mean Time Between Failures)** : Temps moyen de bon fonctionnement entre deux pannes (fiabilité).

---

## 6. Les 7 Principes Directeurs
1. **Focalisez-vous sur la valeur** : Tout ce que fait l'IT doit apporter une valeur directe ou indirecte à l'utilisateur.
2. **Commencez là où vous êtes** : Réutiliser et valoriser l'existant plutôt que de tout recommencer à zéro.
3. **Progressez par itérations avec du feedback** : Découper les projets en étapes courtes et ajuster en continu.
4. **Collaborez et promouvez la visibilité** : Briser les silos entre équipes et partager les informations.
5. **Pensez et travaillez de façon holistique** : Prendre en compte l'écosystème global et les interdépendances.
6. **Restez simple et pratique** : Éliminer les étapes inutiles et concevoir des processus épurés.
7. **Optimisez et automatisez** : Automatiser les tâches répétitives après les avoir optimisées.

---
*Référence officielle : AXELOS ITIL® 4 Foundation.*
