> **Parcours Optimus — Module 6 · Chapitre 8 sur 14**

# Observateur d'événements

L'**Observateur d'événements** (`eventvwr.msc`) est le journal centralisé de Windows. Il enregistre tout ce qui se passe : connexions, erreurs, avertissements, installations, pannes. Ouvrir via `Win+R` → `eventvwr.msc`.

**Les journaux essentiels** :

| Journal | Contenu |
|---|---|
| Système | Erreurs matérielles, pilotes, services Windows |
| Application | Erreurs des logiciels installés |
| Sécurité | Connexions réussies/échouées, modifications de comptes (audit) |
| Installation | Historique des MAJ et installations |

**Niveaux d'événements** : Information (événement normal) / Avertissement (problème potentiel à surveiller) / Erreur (service ou application en échec) / Critique (panne grave, crash système, perte de données).

**IDs d'événements à connaître** :

| ID | Journal | Signification |
|---|---|---|
| 4624 | Sécurité | Connexion réussie |
| 4625 | Sécurité | Échec de connexion (mauvais mot de passe) |
| 4740 | Sécurité | Compte verrouillé |
| 4648 | Sécurité | Tentative de connexion avec identifiants explicites |
| 41 | Système | Redémarrage inattendu (crash, coupure) |
| 6008 | Système | Arrêt brutal précédent |
| 1074 | Système | Redémarrage planifié (qui a redémarré et pourquoi) |

> **Réflexe terrain** : « mon PC a redémarré tout seul » → `eventvwr.msc` → Journal Système → filtrer sur les ID 41 et 6008 → la cause en 2 minutes.
