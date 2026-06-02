> **Parcours Optimus — Module 6 · Chapitre 11 sur 14**

# Réparation Windows — SFC et DISM

Deux outils natifs permettent de détecter et réparer les fichiers système corrompus sans réinstaller l'OS. Ils sont complémentaires et s'utilisent dans un ordre précis.

**SFC — System File Checker** : analyse et répare les fichiers système Windows corrompus en les comparant à une copie de référence.
```
sfc /scannow
```
À exécuter dans un terminal en tant qu'administrateur (5 à 15 minutes).

| Résultat affiché | Signification |
|---|---|
| « Aucune violation d'intégrité détectée » | Fichiers système OK |
| « WRP a trouvé des fichiers corrompus et les a réparés » | Réparation réussie |
| « WRP a trouvé des fichiers corrompus mais n'a pas pu les réparer » | L'image de référence est corrompue → utiliser DISM |

**DISM — Deployment Image Servicing and Management** : répare l'image Windows elle-même (le store de composants). À utiliser quand SFC échoue.
```powershell
DISM /Online /Cleanup-Image /CheckHealth     → Vérification rapide (non destructive)
DISM /Online /Cleanup-Image /ScanHealth      → Analyse complète (10-20 min)
DISM /Online /Cleanup-Image /RestoreHealth   → Réparation (télécharge depuis Windows Update)
```
> `/RestoreHealth` nécessite une connexion Internet (il télécharge les fichiers de remplacement depuis Microsoft).

**Ordre d'utilisation correct** :
```
Étape 1 : sfc /scannow
   ↓ Si échec ou erreurs non réparées
Étape 2 : DISM /Online /Cleanup-Image /RestoreHealth
   ↓ Une fois DISM terminé
Étape 3 : sfc /scannow (relancer pour vérifier)
   ↓ Si toujours des erreurs
Étape 4 : Réparer Windows via ISO (démarrage sur support)
```

> **Terrain** : un PC qui plante aléatoirement, des erreurs au démarrage, des applications qui crashent → commencer par `sfc /scannow` avant toute réinstallation. Résout environ 30 % des cas sans intervention lourde.
