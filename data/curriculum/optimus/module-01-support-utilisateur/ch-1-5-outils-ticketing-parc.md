> **Parcours Optimus — Module 1 · Chapitre 5 sur 9**

# Outils de ticketing et de gestion de parc

## 5.1 Les outils de ticketing

La gestion des tickets s'appuie sur un logiciel dédié (ITSM — *IT Service Management*). Exemples courants :

| Outil | Particularité |
|---|---|
| **GLPI** | Open source, gratuit, très répandu en PME et collectivités. Gère tickets **ET** inventaire de parc. |
| **GLPI + FusionInventory / OCS** | Ajoute l'inventaire automatique du matériel et des logiciels. |
| **ServiceNow** | Solution entreprise haut de gamme, grands comptes. |
| **Jira Service Management** | Orienté équipes techniques et DevOps. |
| **Zendesk, Freshdesk** | Orientés support client / helpdesk. |

**GLPI** est le fil rouge du métier : il centralise les tickets, la base de connaissances, l'inventaire matériel et logiciel, et la gestion des contrats/licences. C'est souvent le premier outil qu'un technicien apprend en entreprise.

## 5.2 La gestion de parc (inventaire)

Gérer le **parc**, c'est tenir à jour l'inventaire de tout le matériel et tous les logiciels de l'entreprise : qui possède quoi, quelle configuration, quelle date d'achat, quelle fin de garantie, quelle licence.

Utilité concrète :
- Savoir **quand renouveler** un matériel vieillissant (anticipation des pannes).
- Suivre les **licences logicielles** (conformité légale, éviter le sous- ou sur-licenciement).
- Associer chaque ticket à un **équipement identifié** (numéro d'inventaire / numéro de série).
- Produire des statistiques (matériels les plus en panne, coûts).

> **Réflexe terrain** : un parc à jour permet de répondre en 10 secondes à « ce PC a quelle config et il est sous garantie jusqu'à quand ? ». Un parc non tenu, c'est des heures perdues à chaque intervention.

## 5.3 La base de connaissances (Knowledge Base)

La **base de connaissances** regroupe les procédures de résolution des incidents récurrents. Quand un même incident revient, on ne redécouvre pas la solution : on consulte (et on enrichit) la base.

Bonne pratique : après avoir résolu un incident nouveau ou complexe, **rédiger une fiche** (symptôme → cause → solution étape par étape). Le service entier gagne en rapidité, et les cas courants deviennent traitables par n'importe quel membre de l'équipe.
