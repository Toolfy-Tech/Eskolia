> **Parcours Optimus — Module 6 · Chapitre 10 sur 14**

# Registre Windows

Le **registre Windows** (`regedit`) est la base de données centrale de configuration du système : tous les paramètres de Windows, des logiciels et des utilisateurs. Ouvrir via `Win+R` → `regedit` (droits admin requis).

> Le registre est sensible. Une mauvaise modification peut rendre Windows inutilisable. **Toujours exporter une sauvegarde avant toute modification** : Fichier → Exporter.

**Les 5 ruches principales** :

| Ruche | Contenu |
|---|---|
| HKEY_LOCAL_MACHINE (HKLM) | Configuration matérielle et logicielle de la machine (tous utilisateurs) |
| HKEY_CURRENT_USER (HKCU) | Configuration spécifique à l'utilisateur connecté |
| HKEY_CLASSES_ROOT (HKCR) | Associations de fichiers et COM (extensions → logiciels) |
| HKEY_USERS (HKU) | Profils de tous les utilisateurs du système |
| HKEY_CURRENT_CONFIG (HKCC) | Configuration matérielle active au démarrage |

**Clés utiles** :
```
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
  → Programmes lancés au démarrage pour tous les utilisateurs
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
  → Programmes lancés au démarrage pour l'utilisateur courant
HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\fDenyTSConnections
  → Activer/désactiver RDP (0 = activé, 1 = désactivé)
```

> Le registre est souvent utilisé par les malwares pour assurer leur persistance (clé Run). C'est l'un des premiers endroits à vérifier lors d'une analyse de poste suspect.
