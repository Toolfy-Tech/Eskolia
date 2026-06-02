> **Parcours Optimus — Module 6 · Chapitre 13 sur 14**

# PowerShell — Introduction

**PowerShell** est le shell et langage de script de Microsoft. Il remplace l'invite de commandes (`cmd`) pour l'administration système. Tout ce qui se fait en interface graphique peut se faire en PowerShell — souvent plus vite, et sur 1000 machines à la fois.

Ouvrir en administrateur : `Win+X` → Windows PowerShell (Admin), ou rechercher « powershell » → Exécuter en tant qu'administrateur.

**Commandes essentielles** :
```powershell
Get-Command                                       → Lister toutes les commandes disponibles
Get-Help <commande>                               → Aide sur une commande
Get-Help Get-Process -Examples                    → Exemples d'utilisation
Get-Process                                       → Lister les processus actifs
Stop-Process -Name "notepad"                      → Tuer un processus par nom
Stop-Process -Id 1234                             → Tuer un processus par PID
Get-Service                                        → Lister les services Windows
Start-Service -Name "wuauserv"                    → Démarrer le service Windows Update
Stop-Service -Name "wuauserv"                      → Arrêter un service
Restart-Service -Name "spooler"                   → Redémarrer le spouleur d'impression
Get-EventLog -LogName System -Newest 20           → 20 derniers événements système
Get-EventLog -LogName Security -InstanceId 4625   → Tous les échecs de connexion
Test-NetConnection -ComputerName google.fr -Port 443  → Tester un port réseau
Get-NetIPConfiguration                            → Équivalent de ipconfig /all
Resolve-DnsName google.fr                         → Résolution DNS
Restart-Computer                                   → Redémarrer
Stop-Computer                                      → Éteindre
```

**Automatisation — exemple** (rapport des comptes AD désactivés) :
```powershell
Import-Module ActiveDirectory
Get-ADUser -Filter {Enabled -eq $false} -Properties * |
  Select-Object Name, SamAccountName, LastLogonDate |
  Export-Csv -Path "C:\rapports\comptes_desactives.csv" -Encoding UTF8
```

> **PowerShell + Active Directory** = combinaison la plus puissante pour l'administration Windows. Un script de 5 lignes peut créer 200 comptes utilisateurs en quelques secondes là où l'interface graphique prendrait des heures.

**Récapitulatif — commandes et outils d'administration Windows** :

| Outil / Commande | Rôle |
|---|---|
| `dsa.msc` | Active Directory Users & Computers |
| `gpmc.msc` | Console GPO |
| `gpupdate /force` | Forcer les GPO |
| `eventvwr.msc` | Observateur d'événements |
| `regedit` | Registre Windows |
| `resmon` | Moniteur de ressources |
| `mstsc` | Bureau à distance (RDP) |
| `services.msc` | Gestionnaire de services |
| `compmgmt.msc` | Gestion de l'ordinateur (tout-en-un) |
| `taskmgr` | Gestionnaire de tâches |
| `msconfig` | Configuration du système (démarrage) |
| `diskmgmt.msc` | Gestion des disques |
| `taskschd.msc` | Planificateur de tâches |
| `sfc /scannow` | Réparation fichiers système |
| `manage-bde` | Gestion BitLocker |

> **Réflexe diagnostic Windows** : `eventvwr` → Gestionnaire des tâches → `resmon`. Dans cet ordre, on couvre 80 % des pannes courantes.
