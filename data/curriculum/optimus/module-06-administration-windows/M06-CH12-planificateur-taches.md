> **Parcours Optimus — Module 6 · Chapitre 12 sur 14**

# Planificateur de tâches — Task Scheduler

Le **Planificateur de tâches** (`taskschd.msc`) exécute automatiquement des programmes, scripts ou commandes selon un déclencheur : heure fixe, événement système, connexion d'un utilisateur, démarrage de Windows.

| Déclencheur | Usage typique |
|---|---|
| À une heure précise | Lancer une sauvegarde chaque nuit à 2h |
| Au démarrage de Windows | Lancer un script de configuration réseau |
| À la connexion d'un utilisateur | Mapper des lecteurs, synchroniser des fichiers |
| Sur événement Windows | Déclencher une alerte si l'ID 4625 est détecté |
| À la création d'une session | Nettoyer les fichiers temporaires |

**Créer une tâche planifiée** : `taskschd.msc` → Bibliothèque → Clic droit → Créer une tâche de base (assistant) ou Créer une tâche (options complètes) → onglet Général (nom, compte d'exécution) → Déclencheurs → Actions (programme/script) → Conditions (réseau, batterie) → Paramètres (relance si échec).

**Via PowerShell** :
```powershell
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File C:\scripts\sauvegarde.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At "02:00"
Register-ScheduledTask -TaskName "Sauvegarde nocturne" -Action $action -Trigger $trigger -RunLevel Highest -User "SYSTEM"
```

**Bonnes pratiques** :
- Exécuter les tâches sensibles sous le compte **SYSTEM** ou un compte de service dédié — jamais sous un compte utilisateur nominatif (si le compte est désactivé, la tâche ne s'exécute plus).
- Activer la journalisation (onglet Paramètres).
- Tester manuellement avant de planifier : clic droit sur la tâche → Exécuter.

> Les malwares utilisent fréquemment le Planificateur de tâches pour la persistance — comme la clé Run du registre. C'est le deuxième endroit à vérifier lors d'une analyse de poste suspect.

**Vérifier en ligne de commande** :
```powershell
Get-ScheduledTask                                              → Lister toutes les tâches
Get-ScheduledTask | Where-Object {$_.State -eq "Ready"}        → Tâches actives
Get-ScheduledTaskInfo -TaskName "Sauvegarde nocturne"          → Dernière exécution et résultat
Unregister-ScheduledTask -TaskName "Tâche suspecte" -Confirm:$false
```
