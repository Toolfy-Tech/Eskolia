> **Parcours Optimus — Module 6 · Chapitre 6 sur 14**

# BitLocker — Chiffrement des postes

**BitLocker** est l'outil de chiffrement intégré à Windows (éditions Pro, Entreprise et Éducation). Il chiffre intégralement le contenu d'un disque dur. Si un PC est volé ou le disque extrait physiquement, les données sont illisibles sans la clé de déchiffrement.

> BitLocker n'est **pas** disponible sur Windows Home.

**Prérequis matériel** :
- Puce **TPM 2.0** (Trusted Platform Module) — présente sur la quasi-totalité des machines depuis 2016.
- Sans TPM : BitLocker peut fonctionner avec une clé USB de démarrage, mais c'est moins pratique.

**Activer BitLocker** : Panneau de configuration → Système et sécurité → Chiffrement de lecteur BitLocker → Activer sur C: → choisir le mode de déverrouillage (TPM automatique recommandé) → **sauvegarder la clé de récupération (obligatoire)**. Ou via PowerShell :
```powershell
Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256 -TpmProtector
```

**La clé de récupération** — point critique : code à 48 chiffres généré à l'activation. Indispensable si le TPM détecte une modification matérielle (changement de carte mère, BIOS mis à jour), si l'utilisateur a oublié son PIN, ou si le disque est branché sur une autre machine.

| Où stocker la clé | Recommandation |
|---|---|
| Compte Microsoft | Acceptable pour les particuliers |
| Active Directory (AD) | Standard entreprise — clé centralisée sur le DC |
| Fichier local sur le même PC | Inutile — si le PC est volé, la clé aussi |
| Impression papier dans un coffre | Acceptable en complément |

**Sauvegarde automatique dans Active Directory** (via GPO) :
```
Configuration Ordinateur
 → Modèles d'administration
 → Composants Windows
 → Chiffrement de lecteur BitLocker
 → Lecteurs du système d'exploitation
 → « Choisir comment les lecteurs OS protégés par BitLocker peuvent être récupérés »
   → Cocher « Sauvegarder les informations de récupération BitLocker dans les services AD »
```
Résultat : dès qu'un poste active BitLocker, la clé est stockée dans l'objet ordinateur dans l'AD. Récupération : `dsa.msc` → clic droit sur le PC → Propriétés → onglet Récupération BitLocker.

**Vérifier l'état du chiffrement** :
```
manage-bde -status        → État de tous les lecteurs
manage-bde -status C:     → État du lecteur C: uniquement
```

> **Terrain** : « Mon PC me demande une clé de récupération BitLocker au démarrage. » Causes fréquentes : MAJ du BIOS la nuit précédente, changement de composant matériel, modification de l'ordre de boot. Réflexe : récupérer la clé dans l'AD (`dsa.msc`) → la communiquer → investiguer pourquoi le TPM a été déclenché.
