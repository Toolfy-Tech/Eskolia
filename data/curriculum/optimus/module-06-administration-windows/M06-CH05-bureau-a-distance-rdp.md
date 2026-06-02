> **Parcours Optimus — Module 6 · Chapitre 5 sur 14**

# Bureau à distance — RDP

**RDP (Remote Desktop Protocol)** permet de prendre le contrôle graphique d'un PC ou serveur Windows à distance. **Port : 3389 (TCP)**.

**Activer le bureau à distance** : Paramètres → Système → Bureau à distance → Activer. Ou via PowerShell :
```powershell
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Bureau à distance"
```

**Se connecter** :
```
mstsc                          → Ouvre le client Bureau à distance
mstsc /v:192.168.1.10          → Connexion directe à une IP
mstsc /v:192.168.1.10 /admin   → Mode administration (session console)
```

**Sécurisation RDP** :

| Bonne pratique | Pourquoi |
|---|---|
| Changer le port 3389 | Réduit les scans automatiques (bots cherchent le 3389) |
| Activer le NLA (Network Level Authentication) | Authentification avant ouverture de session |
| Passer par un VPN | RDP ne doit jamais être exposé directement sur Internet |
| Limiter les utilisateurs autorisés | Groupe « Utilisateurs du Bureau à distance » uniquement |

> **RDP directement exposé sur Internet = cible n°1 des ransomwares.** En 2024, c'est encore la première porte d'entrée des attaques. Toujours passer par un VPN ou un bastion SSH.
