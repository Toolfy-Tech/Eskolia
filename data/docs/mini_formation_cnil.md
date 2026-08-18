# Mini-formation — CNIL & Réglementation Française

## 1. Rôle et Missions de la CNIL
La **Commission Nationale de l'Informatique et des Libertés (CNIL)** est l'autorité administrative indépendante française créée par la loi Informatique et Libertés du 6 janvier 1978. Elle veille à ce que l'informatique soit au service du citoyen et ne porte atteinte ni à l'identité humaine, ni aux droits de l'homme, ni à la vie privée.

### Ses 5 missions fondamentales :
1. **Informer & Protéger** : Éclairer les citoyens sur leurs droits et répondre aux plaintes/réclamations.
2. **Accompagner & Conseiller** : Publier des référentiels, labels et guides techniques à destination des professionnels.
3. **Anticiper & Innover** : Analyser les impacts des technologies émergentes (IA, biométrie, objets connectés).
4. **Contrôler** : Réaliser des contrôles sur place, sur pièces ou en ligne pour vérifier la conformité.
5. **Sanctionner** : Prononcer des avertissements, des mises en demeure et des amendes administratives.

---

## 2. Guides et Référentiels Techniques Clés
La CNIL édite des recommandations opérationnelles indispensables pour les équipes IT :
- **Guide de la sécurité des données personnelles** : 17 fiches pratiques couvrant la gestion des accès, le chiffrement, les sauvegardes, la journalisation et la maintenance.
- **Politique de mots de passe** : Règles de complexité et d'entropie (ex. minimum 12 caractères variés sans MFA, ou 8 caractères avec MFA, hachage avec sel via bcrypt / argon2).
- **Gestion des cookies et traceurs (Directive ePrivacy)** : Obligation de recueil du consentement préalable libre, éclairé, spécifique et univoque avant tout dépôt de traceurs non essentiels.
- **Vidéoprotection et Cybersurveillance des salariés** : Interdiction de surveillance constante et disproportionnée (pas de keyloggers sans motif exceptionnel encadré, interdiction de filmer les postes de travail en continu).

---

## 3. L'AIPD (Analyse d'Impact relative à la Protection des Données)
L'**AIPD (ou PIA - Privacy Impact Assessment)** est une étude d'évaluation des risques obligatoire avant de mettre en œuvre tout traitement susceptible d'engendrer un risque élevé pour les droits et libertés des personnes :
- Traitement à grande échelle de données sensibles (données de santé, opinions politiques, casier judiciaire).
- Surveillance systématique à grande échelle d'une zone accessible au public.
- Croisement ou profilage automatique de données à grande échelle.
- L'outil logiciel libre et open-source **PIA de la CNIL** permet de structurer et documenter cette analyse.

---

## 4. Obligations et Démarches Pratiques
- **Registre des traitements** : Document obligatoire recensant tous les traitements de données, leurs finalités, les catégories de données, les destinataires et les durées de conservation.
- **Désignation d'un DPO** : Obligatoire pour le secteur public et pour les entreprises dont l'activité de base implique un suivi régulier ou le traitement de données sensibles.
- **Notification de violation** : Téléservice en ligne sur le site de la CNIL pour déclarer tout incident de sécurité impactant des données personnelles sous 72h.

---
*Site officiel et ressources : [cnil.fr](https://www.cnil.fr)*
