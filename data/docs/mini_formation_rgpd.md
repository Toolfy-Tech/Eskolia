# Mini-formation — RGPD & Protection des Données Personnelles

## 1. Qu'est-ce que le RGPD ?
Le **Règlement Général sur la Protection des Données (RGPD / GDPR)** est le cadre juridique européen entré en application le 25 mai 2018. Il harmonise les lois relatives à la confidentialité des données à travers l'Union Européenne et responsabilise toutes les organisations traitant des données de résidents européens.

---

## 2. Définitions Clés
- **Donnée à caractère personnel** : Toute information se rapportant à une personne physique identifiée ou identifiable (nom, prénom, e-mail, identifiant de connexion, adresse IP, adresse MAC, géolocalisation, logs nominatifs, enregistrement vocal, etc.).
- **Traitement** : Toute opération appliquée à des données (collecte, enregistrement, organisation, conservation, modification, extraction, consultation, diffusion, effacement ou destruction).
- **Responsable de traitement (RT)** : L'entité (entreprise, administration) qui détermine les finalités et les moyens du traitement.
- **Sous-traitant** : L'entité qui traite des données pour le compte du responsable de traitement (hébergeur cloud, éditeur SaaS, infogéreur).
- **DPO (Data Protection Officer)** : Le Délégué à la Protection des Données, garant de la conformité au sein de l'organisation.

---

## 3. Les 6 Grands Principes Fondamentaux
1. **Licéité, Loyauté et Transparence** : Traitement reposant sur une base légale valide (consentement, contrat, obligation légale, intérêt légitime, sauvegarde des intérêts vitaux, mission d'intérêt public) et information claire de l'usager.
2. **Limitation des finalités** : Les données doivent être collectées pour des objectifs déterminés, explicites et légitimes (interdiction de réutiliser les données pour un autre usage sans base légale).
3. **Minimisation des données** : Collecter uniquement ce qui est strictement adéquat, pertinent et nécessaire à l'objectif visé (*« Pas de collecte au cas où »*).
4. **Exactitude** : Les données doivent être exactes et tenues à jour.
5. **Limitation de la conservation** : Définir et appliquer des durées de conservation précises (archivage intermédiaire, purge automatique après expiration).
6. **Intégrité et Confidentialité (Sécurité)** : Mise en œuvre de mesures techniques et organisationnelles adaptées au risque (chiffrement, contrôle des accès, traçabilité, sauvegardes).

---

## 4. Droits des Personnes Concernées
- **Droit d'accès** : Obtenir la confirmation que des données sont traitées et en recevoir une copie.
- **Droit de rectification** : Corriger des données inexactes ou incomplètes.
- **Droit à l'effacement (« droit à l'oubli »)** : Supprimer les données lorsque leur conservation n'est plus justifiée.
- **Droit à la limitation du traitement** : Geler temporairement l'utilisation d'une donnée.
- **Droit à la portabilité** : Récupérer ses données dans un format structuré et lisible par machine (CSV, JSON).
- **Droit d'opposition** : S'opposer à tout moment à un traitement (ex. prospection commerciale).

---

## 5. Rôle et Bonnes Pratiques pour le Technicien IT
- **Aucune copie de base de production** : Ne jamais copier de dump de base réelle sur son poste de travail ou sur un support non sécurisé ; utiliser des jeux d'essai anonymisés ou pseudonymisés.
- **Sécurité et Habilitations (RBAC)** : Restreindre les accès aux seuls personnels autorisés (moindre privilège), désactiver les comptes partagés pour assurer une traçabilité nominative.
- **Chiffrement systématique** : Chiffrer les flux réseau (TLS 1.3 / HTTPS / SSH) et les supports de stockage (BitLocker / LUKS / AES-256).
- **Gestion des Violations de Données** :
  - En cas de fuite, perte ou accès illégitime à des données, la procédure d'incident doit être déclenchée immédiatement.
  - Notification obligatoire à la CNIL dans un délai maximal de **72 heures** après en avoir pris connaissance.
  - Notification aux personnes concernées si le risque pour leurs droits et libertés est élevé.
- **Privacy by Design & by Default** : Intégrer la protection des données dès la conception d'un projet informatique et paramétrer le niveau de confidentialité le plus élevé par défaut.

---

## 6. Sanctions en cas de non-respect
- Mises en demeure publiques et injonctions sous astreinte.
- Sanctions financières pouvant atteindre jusqu'à **20 millions d'euros** ou **4 % du chiffre d'affaires annuel mondial** total de l'exercice précédent.

---
*Référence officielle : Règlement (UE) 2016/679 du Parlement européen et du Conseil.*
