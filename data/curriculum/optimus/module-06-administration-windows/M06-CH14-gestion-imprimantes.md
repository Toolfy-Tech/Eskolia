> **Parcours Optimus — Module 6 · Chapitre 14 sur 14**

# Gestion et dépannage des imprimantes

Le dépannage des imprimantes (et copieurs multifonctions — MFP) représente environ **20 à 30 % des tickets** en support de proximité.

## 14.1 Imprimante locale vs imprimante réseau

- **Imprimante locale** : branchée directement en USB sur un PC. Seul ce PC peut imprimer. Si le PC est éteint, personne d'autre ne peut l'utiliser, même « partagée », car c'est le PC hôte qui gère le spouleur.
- **Imprimante réseau** : branchée en RJ45 (ou Wi-Fi) directement sur le switch. Elle possède sa propre adresse IP. C'est le standard en entreprise.

## 14.2 Le spouleur d'impression (Print Spooler)

Service Windows qui met les documents en file d'attente, les traduit dans un langage compréhensible par l'imprimante, et les envoie un par un. S'il plante, toute l'impression sur le PC est paralysée.

> **Réflexe terrain (débloquer une file coincée)** : si un document affiche « En cours de suppression... » pendant des heures et bloque tout le reste, redémarrer l'imprimante ne sert à rien (le blocage est sur le PC). Un simple redémarrage du service échoue souvent sur les files corrompues. Il faut vider manuellement le dossier de spool (PowerShell admin) :
> ```powershell
> Stop-Service -Name Spooler -Force
> Remove-Item -Path "C:\Windows\System32\spool\PRINTERS\*" -Force
> Start-Service -Name Spooler
> ```

## 14.3 Le piège du port WSD

Lorsqu'on ajoute une imprimante réseau via les « Paramètres Windows », Windows crée souvent un port **WSD (Web Services for Devices)** au lieu d'un port TCP/IP standard.

- **Le problème** : le WSD est instable. Si l'imprimante se met en veille, Windows perd la connexion et l'imprimante apparaît « Hors connexion », même si elle fonctionne très bien.

**Bonne pratique de déploiement** :
1. **Fixer l'IP** de l'imprimante (via son interface web en IP statique, ou via une réservation DHCP — plus facile à gérer centralement).
2. **Installer manuellement** via Panneau de configuration → Périphériques et imprimantes → Ajouter une imprimante → Ajouter manuellement → Créer un nouveau port → **Standard TCP/IP Port** → renseigner l'IP fixe. Cela ne plantera jamais.

**Méthodes pour trouver l'IP d'une imprimante réseau** :
1. Imprimer la page de configuration (bouton physique).
2. Panneau de l'imprimante → Menu réseau → Infos TCP/IP.
3. Scanner le réseau : `arp -a` dans cmd → chercher l'adresse MAC du fabricant.
4. Logiciels constructeurs (HP Device Manager, Xerox CentreWare, Ricoh Web Image Monitor).

## 14.4 Langages d'impression et pilotes (Drivers)

Pour qu'un PC parle à une imprimante, il lui faut un pilote.

- **PCL (Printer Command Language)** : standard universel (souvent PCL6). Rapide, excellent pour la bureautique (Word, Excel, PDF texte).
- **PostScript (PS)** : traitement plus complexe, mais qualité de rendu supérieure pour les éléments graphiques et la colorimétrie. Indispensable pour les services communication/marketing (suite Adobe : Illustrator, InDesign).

**L'Universal Print Driver (UPD)** : en entreprise, on n'installe généralement pas le driver complet du fabricant (lourd, bloatwares). On utilise un UPD (HP UPD, Xerox Global Print Driver...) : un driver générique compatible avec tous les modèles d'une même marque. Avantage : un seul driver léger pour tout le parc.

## 14.5 Déploiement d'imprimantes via GPO

En environnement Active Directory, on ne déploie pas les imprimantes manuellement poste par poste. On utilise une GPO :
- **Chemin** : Configuration utilisateur → Préférences → Paramètres Windows → Imprimantes.
- **Résultat** : l'imprimante apparaît automatiquement à la connexion de l'utilisateur selon son OU.

## 14.6 Configurer la numérisation (Scan)

**Option A — Scan vers dossier (Scan to SMB)** : permettre aux utilisateurs de scanner un document depuis le copieur pour qu'il arrive directement sur leur PC ou le serveur.
1. *Côté PC/Serveur* : créer un dossier (ex : `C:\Scans`), le partager, s'assurer que l'utilisateur a les droits NTFS et de Partage en Modification.
2. *Côté copieur* : interface web → carnet d'adresses → ajouter un profil « Scan to SMB » → renseigner le chemin réseau (`\\NomDuPC\Scans`), l'identifiant Windows et le mot de passe.

> **Bonne pratique** : utiliser un compte de service dédié (ex : `svc_scanner@entreprise.local`) avec un mot de passe qui n'expire pas. Si on utilise le compte personnel de l'utilisateur, chaque changement de mot de passe cassera le scan.

> **Attention au SMBv1** : désactivé aujourd'hui pour des raisons de sécurité (faille WannaCry). Si le copieur est trop vieux pour SMBv2/v3, mettre à jour son firmware peut corriger cela ; sinon, le **Scan to Email** ou le **Scan vers FTP/SFTP** sont les alternatives sécurisées.

**Option B — Scan to Email (SMTP)** : solution de contournement la plus fiable face aux problèmes SMB. Le copieur envoie les scans comme pièces jointes par email.
1. Interface web du copieur → Paramètres réseau → SMTP.
2. Renseigner l'adresse du serveur mail (ou le relais SMTP de l'entreprise), le port (25 ou 587), et un compte expéditeur dédié (ex : `scanner@entreprise.com`).
