> **Parcours Optimus — Module 6 · Chapitre 3 sur 14**

# Le déploiement et Windows Deployment Services

## 3.1 Introduction au déploiement et concepts clés

Le déploiement de postes consiste à installer et configurer rapidement plusieurs ordinateurs avec un système d'exploitation et des logiciels identiques. C'est essentiel en environnement professionnel pour gagner du temps et éviter les erreurs humaines, assurer l'homogénéité du parc informatique, et faciliter la maintenance et le support.

**Master vs Clone** — distinction cruciale :

- **Le Master (image de référence)** : système préparé spécifiquement pour être réutilisé et déployé à grande échelle proprement. Il est « dépersonnalisé » (généralisé).
- **Le Clone** : duplication brute (secteur par secteur) d'une machine existante. Il copie tout, y compris l'identité unique du PC. Moins adapté à un parc en réseau, sauf si la machine a été préalablement préparée.

> On **clone** une machine, on **déploie** un master. Le master est fait pour être réutilisé à grande échelle proprement ; le clone est une duplication brute, moins adaptée à un parc en réseau.

**Le clonage (outils locaux)** : copie intégralement un système (OS, logiciels, paramètres) d'une machine vers une ou plusieurs autres.
- **Clonezilla** : logiciel libre de référence pour cloner des disques ou des partitions. Très utilisé pour créer des images système locales et les restaurer.

## 3.2 Les méthodes de déploiement

Le choix de la méthode dépend du contexte (taille du parc, infrastructure réseau, flexibilité).

**Déploiement via supports bootables (petit parc / hors réseau)** — on utilise souvent une clé USB bootable :

| Outil | Caractéristiques |
|---|---|
| **Ventoy** | Clé USB multi-ISO : glisser-déposer plusieurs `.iso` pour avoir un menu de choix au démarrage. Idéal pour la boîte à outils d'un technicien. |
| **Rufus** | Simple et rapide pour créer une clé bootable d'un seul OS. Les versions récentes contournent les restrictions de Windows 11 (TPM 2.0, compte Microsoft) et suppriment les bloatwares. |
| **Easy2Boot** | Alternative à Ventoy pour clé multi-boot. Plus complexe à configurer mais plus flexible (supporte plus de formats : ISO, IMG, VHD...). Principalement hors réseau, sur clé USB. |

> Distinction clé : **Rufus** pour une clé simple et rapide, **Ventoy** et **Easy2Boot** pour une clé multi-ISO. Easy2Boot se différencie de Ventoy par sa compatibilité étendue avec les formats, au prix d'une configuration plus technique.

**Déploiement réseau via PXE (parc moyen à grand)** — le **PXE (Preboot Execution Environment)** permet de démarrer un ordinateur directement via la carte réseau, sans aucun support physique.

Principe du PXE :
1. Le poste démarre, la carte réseau est prioritaire.
2. Il envoie une requête en broadcast pour trouver un serveur DHCP et obtenir une adresse IP.
3. Le serveur DHCP lui fournit une IP et lui indique l'adresse du serveur de déploiement (**option DHCP 66**) et le fichier d'amorce (**option DHCP 67**). Pour que les options 66 et 67 fonctionnent, il faut souvent que le service DHCP et le service WDS ne soient pas sur le même serveur (conflit sur les ports), nécessitant de cocher des options spécifiques dans WDS (ne pas écouter sur le port 67).
4. Le poste télécharge le programme de démarrage via le protocole **TFTP**.
5. Il lance l'installation de l'OS via le réseau.

**Protocole TFTP** : quand une machine boote en PXE, elle obtient une IP via DHCP, puis télécharge le fichier de démarrage (`boot.wim`) depuis le serveur WDS via TFTP (Trivial File Transfer Protocol). C'est un protocole de transfert simplifié sur le port **UDP 69**, sans authentification. Utile pour le dépannage : si le boot PXE échoue après l'attribution IP, le problème vient souvent du TFTP (pare-feu qui bloque le port, mauvais chemin de fichier).

Avantages du PXE : déploiement simultané de dizaines de machines, gain de temps considérable, centralisation, aucune manipulation physique de clés USB.

**Automatisation du déploiement** : grâce à des fichiers de réponses (`unattended.xml`), on peut répondre automatiquement aux questions de l'installation (langue, partitionnement, nom du poste, etc.), permettant un déploiement sans intervention humaine (**Zero Touch Deployment**).

## 3.3 Les serveurs de déploiement

Ce sont les machines qui stockent et distribuent les images système sur le réseau.

| Outil | Description |
|---|---|
| **WDS (Windows Deployment Services)** | Solution native Microsoft. Très efficace pour les environnements Windows purs. Permet l'installation simultanée (multicast) de nombreuses machines. |
| **FOG Project** | Solution open-source : capture d'images système, déploiement multi-plateformes, gestion centralisée du parc (renommage auto, intégration domaine...). |
| **DISM** | *Deployment Image Servicing and Management*. Outil CLI intégré nativement à Windows pour manipuler les `.wim` : monter une image, ajouter drivers/MAJ, nettoyer, capturer, appliquer. C'est la brique technique sur laquelle WDS s'appuie en arrière-plan. |

**Unicast vs Multicast** : en *unicast*, WDS envoie l'image séparément à chaque machine — 20 postes = 20 flux distincts, beaucoup de bande passante consommée. En *multicast*, le serveur envoie un seul flux que toutes les machines reçoivent simultanément (comme une diffusion). C'est l'intérêt principal de WDS sur un grand parc : 50 machines reçoivent la même image en même temps sans saturer le réseau.

**DISM en TIP** intervient principalement dans deux situations : maintenir un master sans tout reconstruire (ajout de drivers, mises à jour) et diagnostiquer/réparer un Windows endommagé.

## 3.4 Le Master : création, stratégie et Sysprep

Le master conditionne la qualité de tout le parc. S'il est défaillant, tous les postes le seront.

**Choix de la version de Windows** :
- **Mises à jour (Updates)** : correctifs de sécurité et de bugs. Obligatoires, n'impactent pas la version de base.
- **Versions (Upgrades)** : changements majeurs (Windows 10 → 11, ou 21H2 → 22H2). Modifient les prérequis matériels.

Faut-il toujours le dernier Windows ? **Non.** Raisons : compatibilité matérielle (Windows 11 exige TPM 2.0 et un CPU récent), compatibilité logicielle (logiciels métiers certifiés), stabilité (attendre quelques mois après une sortie majeure), support (fin de vie — Windows 10 s'arrête en octobre 2025).

**Conseils avant de commencer le master** :
- Utiliser une machine virtuelle (VirtualBox, VMware) plutôt qu'une machine physique — plus facile à snapshotter, recommencer, transporter.
- Partir d'une ISO officielle Microsoft (VLSC ou Media Creation Tool), jamais d'une ISO téléchargée ailleurs.
- Choisir la bonne édition : Windows **Pro** ou **Entreprise**, jamais Home (pas de jonction de domaine, pas de GPO).

**Le cycle de vie du Master** :

1. **Installation de base** : installer un Windows propre sur une VM (recommandé) ou physique.
2. **Mode Audit** (`sysprep /audit`) : démarre Windows directement en administrateur sans passer par l'assistant OOBE. Exécutable : `C:\Windows\System32\Sysprep\sysprep.exe`. C'est dans ce mode qu'on finalise le contenu du master : logiciels, drivers, personnalisations. Tant qu'on est en mode audit, le système n'est pas généralisé (le SID est toujours présent).
3. **La Généralisation** (`sysprep /generalize /oobe /shutdown`) : étape **OBLIGATOIRE**. Sysprep dépersonnalise l'image et supprime le **SID** (identifiant de sécurité unique). Sans Sysprep, toutes les machines déployées auront le même SID → conflits dans un domaine Active Directory et problèmes d'authentification. La machine s'éteint d'elle-même à la fin.
4. **La Capture** : quand la machine est éteinte suite au Sysprep, on boote en PXE ou sur USB pour capturer l'image (via WDS ou Clonezilla).

> **Attention — Mode audit** : ne créez aucun compte utilisateur local en mode audit. Son profil serait capturé dans le master et se retrouverait sur toutes les machines déployées.

**Bonnes pratiques en mode audit** :
- Installer les logiciels dans l'ordre : drivers → mises à jour Windows → logiciels métier → **antivirus en dernier** (il peut bloquer les étapes suivantes).
- Le fond d'écran et les raccourcis du bureau de la session admin ne sont **pas** conservés (Sysprep efface les personnalisations de la session en cours). Pour contourner : placer les raccourcis dans le dossier public (`C:\Users\Public\Desktop`). Appliquer un fond d'écran après déploiement via GPO ou scripts.
- Ne jamais se connecter avec un compte Microsoft, ne jamais activer Windows à ce stade.
- Désactiver les applications inutiles (Cortana, OneDrive, Xbox...) et services non nécessaires — allège le master et réduit la surface d'attaque.
- Faire les mises à jour complètement avant Sysprep, redémarrer autant que nécessaire jusqu'à « Votre appareil est à jour ».

**Avant la capture** : vider les dossiers temporaires (`%temp%`, `C:\Windows\Temp`), vider la corbeille, désinstaller les logiciels de test, lancer un nettoyage de disque avec suppression des fichiers système, et vérifier qu'aucune mise à jour n'est en attente.

> **Première cause d'échec de Sysprep** : des mises à jour en attente. Windows considère le système comme instable et refuse la généralisation. Symptôme classique : Sysprep se lance puis s'interrompt avec une erreur dans `C:\Windows\System32\Sysprep\Panther\setupact.log`. Solution : laisser toutes les MAJ se terminer, redémarrer, vérifier qu'aucune n'est en attente, puis relancer Sysprep.

**Bonnes pratiques du master** :
- Créer un master par « profil » (Administratif, Technique). Ne pas tout mettre dans un seul master.
- Tester le master sur 2-3 machines avant déploiement en masse.
- Documenter ce qui est installé et sa version.
- Assurer la maintenance des postes déployés (MAJ, supervision, incidents, renouvellement). Mettre à jour le master régulièrement.
- Fixer une date de reconstruction : un master de plus de 12-18 mois accumule trop de dette technique. Mieux vaut en reconstruire un propre.

**Sécurité dans le master** : appliquer les MAJ, configurer le pare-feu, installer un antivirus, désactiver les services inutiles. Ne pas intégrer de données sensibles (comptes utilisateurs, mots de passe, certificats).

## 3.5 Flux PXE détaillé

**Étape 1 — le PC démarre en PXE**

Accès au BIOS au démarrage (selon fabricant : F2, F10, F12, Suppr ou Échap, souvent affiché brièvement au POST). Dans l'onglet **Boot** : trouver *Boot Device Priority* / *Boot Order*, activer *Network Boot / PXE Boot / LAN Boot* et le placer en première position. Dans *Advanced* / *Integrated Peripherals* : *Onboard LAN* sur Enabled, *Boot ROM / PXE ROM* activé.

**UEFI vs Legacy BIOS** :
- En mode UEFI, le boot PXE fonctionne nativement, mais le `boot.wim` de Windows 11 ne supporte que l'UEFI.
- En mode Legacy/BIOS, il faut utiliser un `boot.wim` de Windows 10 ou Windows Server.
- Si le parc est mixte, mieux vaut rester en Legacy ou activer le **CSM** (Compatibility Support Module) dans l'UEFI pour couvrir les deux cas.

**Secure Boot** : dans certains environnements, le Secure Boot bloque le démarrage PXE. Si le boot réseau échoue malgré une config correcte : *Security → Secure Boot → Disabled*. Sauvegarder (F10) et quitter.

**Étape 2 — le PC envoie une requête DHCP en broadcast**

Au démarrage en PXE, la machine n'a pas encore d'adresse IP : elle envoie un **broadcast** (message à tout le réseau, `255.255.255.255`).

La requête `DHCPDISCOVER` est un paquet UDP avec :
- IP source : `0.0.0.0` (pas encore d'IP)
- IP destination : `255.255.255.255` (broadcast)
- Port source : 68 (client DHCP) / Port destination : 67 (serveur DHCP)
- **Option 60** avec la valeur `PXEClient` : signale au serveur DHCP que la requête vient d'une machine PXE qui a besoin d'infos supplémentaires.

Le serveur répond (`DHCPOFFER`) avec : une IP disponible, le masque/passerelle/DNS, l'**option 66** (IP du serveur WDS / Next Server) et l'**option 67** (nom du fichier à télécharger : `boot.wim` ou `boot\x64\wdsnbp.com`). Le client confirme (`DHCPREQUEST → DHCPACK`) puis utilise les options 66/67 pour contacter le serveur TFTP.

> **Dépannage fréquent** — si le client PXE affiche `DHCP...` puis échoue sans obtenir d'IP : le serveur DHCP n'est pas démarré ou pas sur le même réseau ; les options 66/67 ne sont pas configurées ; un pare-feu bloque les ports 67/68 ; le serveur DHCP est sur un autre sous-réseau sans IP Helper (agent relais DHCP) sur le routeur.

**Les options DHCP 66 et 67 en PXE** :
- **Option 66 — Next Server** : adresse IP du serveur TFTP (en WDS, l'IP du serveur WDS). « Va chercher ton fichier de boot chez cette machine. » Ex : `192.168.1.1`.
- **Option 67 — Boot File Name** : nom et chemin du fichier de démarrage à télécharger via TFTP. « Le fichier à télécharger s'appelle ça. » Ex : `boot\x64\wdsnbp.com` ou `boot.wim`.

Sans l'option 66 → le client ne sait pas à qui parler. Sans l'option 67 → il ne sait pas quoi demander. Les deux sont obligatoires.

*Configuration dans Windows Server* : console DHCP → clic droit sur l'étendue → Options d'étendue → Configurer les options → cocher 066 et 067, renseigner les valeurs. Si le client obtient une IP mais que le boot PXE échoue avec un timeout TFTP, vérifier d'abord les options 66/67.

**Étape 3 — pourquoi TFTP utilise UDP et pas TCP**

TFTP est conçu pour être le plus simple possible : il doit fonctionner dans un environnement contraint (machine qui vient de s'allumer, sans OS, sans pile réseau complète, seulement le firmware de la carte réseau). TCP est trop lourd (handshake 3 étapes, retransmission, contrôle de flux, séquençage) — trop de mémoire et de code que le firmware n'a pas. UDP est sans connexion : on envoie un paquet, point. TFTP gère lui-même les accusés de réception (ACK) bloc par bloc.

> En résumé : UDP est choisi non pas parce que c'est optimal, mais parce que c'est le minimum viable pour un contexte aussi bas niveau.

**Si le port UDP 69 est bloqué** : le client a déjà son IP et les options 66/67, mais ne peut pas joindre le serveur TFTP. Symptôme à l'écran :
```
PXE-E32: TFTP open timeout   ou   PXE-E35: TFTP read timeout
```
Diagnostic (sur le serveur Windows) :
```
netsh advfirewall firewall show rule name=all | findstr TFTP
```
Si aucune règle n'apparaît, créer une règle entrante :
```
netsh advfirewall firewall add rule name="TFTP PXE" protocol=UDP dir=in localport=69 action=allow
```
WDS crée normalement cette règle automatiquement, mais elle peut être désactivée/supprimée par une GPO. Autre cause : si le chemin du fichier (option 67) est incorrect, TFTP s'ouvre mais répond `PXE-E23: Client received TFTP error from server` (problème de chemin du `boot.wim`, pas de pare-feu).

**Étape 4 — le rôle de Windows PE**

**Windows PE (Preinstallation Environment)** est un OS minimal basé sur Windows, contenu dans le `boot.wim`. Il ne sert pas à travailler au quotidien — uniquement à préparer et lancer le déploiement. Une fois chargé en RAM, la machine a un OS minimaliste qui peut : parler au réseau (récupérer `install.wim`), accéder aux disques (partitionner, formater, écrire), exécuter des scripts (`unattend.xml`), charger des drivers.

Il embarque : **DISM** (appliquer `install.wim`), **diskpart** (partitionner/formater), **wpeinit** (initialise le réseau), **wpeutil** (utilitaires de base), un shell CMD minimal. Pas d'interface graphique complète, pas de navigateur.

**boot.wim vs install.wim** — confusion fréquente :

| | boot.wim | install.wim |
|---|---|---|
| Contient | Windows PE | Windows complet |
| Rôle | Lance le déploiement | Est déployé sur le poste |
| Taille | ~500 Mo | 3 à 5 Go |
| Chargé via | TFTP | WDS (réseau) |

> Le `boot.wim` est le **livreur**, l'`install.wim` est le **colis**.

Windows PE tourne uniquement en RAM pendant le déploiement. Une fois `install.wim` appliqué et la machine redémarrée, Windows PE disparaît — il n'est jamais installé sur le poste final.

**Étape 5 — le multicast WDS pour envoyer install.wim**

Sans multicast, WDS fonctionne en *unicast* : une copie séparée de `install.wim` par client (20 machines = 20 flux = saturation). Le **multicast** fonctionne comme une diffusion TV : le serveur envoie un seul flux, toutes les machines abonnées le reçoivent simultanément.

```
Unicast    → Serveur ──► Client 1
             Serveur ──► Client 2
             Serveur ──► Client 3   (3 flux distincts)

Multicast  → Serveur ──► [groupe multicast] ──► Client 1
                                              ──► Client 2
                                              ──► Client 3   (1 seul flux)
```

Techniquement : le serveur crée une session multicast associée à une image. Les clients qui bootent en PXE rejoignent la session via une **adresse IP multicast** (plage `224.0.0.0` à `239.255.255.255`). Le serveur envoie les blocs de `install.wim` une seule fois vers cette adresse.

**Deux modes de transfert multicast** :
- **Auto-Cast** : le transfert démarre dès qu'un premier client est prêt, les suivants rejoignent le flux en cours. Les retardataires ratent les blocs déjà envoyés et doivent les récupérer séparément.
- **Scheduled-Cast** : le serveur attend un nombre minimum de clients ou une heure précise avant de démarrer. Tous reçoivent l'image depuis le début. **Mode recommandé** pour déployer un parc entier en une fois.

**Prérequis réseau** : le multicast nécessite que les switchs supportent l'**IGMP** (Internet Group Management Protocol), qui permet aux switchs de savoir quels ports appartiennent au groupe multicast. Sans IGMP, le flux multicast se comporte comme un broadcast et surcharge le réseau (l'effet inverse recherché).

*Configuration* : console WDS → clic droit sur *Transmissions par multidiffusion* → Nouvelle transmission → choisir l'image → Auto-Cast ou Scheduled-Cast.

## 3.6 Cas pratique : mise en place d'un serveur WDS

Pour faire du déploiement PXE avec Windows Server, on a besoin de deux rôles : **DHCP** et **WDS**.

> **Conflit de port 67** : si DHCP et WDS sont sur la même machine, ils se battent pour écouter le port UDP 67. Dans les propriétés du serveur WDS, onglet *DHCP*, cocher impérativement : « Ne pas écouter sur le port DHCP (67) » ET « Configurer l'option DHCP 60 » (indique que ce serveur est aussi un serveur PXE). Cette config s'applique partout, y compris en production. Ce n'est pas une limitation de VirtualBox : un port réseau ne peut pas être utilisé par deux applications en même temps.

**Étape 1 — le prérequis (serveur DHCP)** :
1. Préparation : renommer le PC (ex : `SRV-DEPLOIEMENT`), IP fixe, vérifier le raccordement réseau.
2. Installation : ajouter le rôle « Serveur DHCP ».
3. Configuration (nouvelle étendue IPv4) : DHCP → clic IPv4 → Actions → Nouvelle étendue.
   - Définir une plage d'IP (ex : `192.168.1.50` à `192.168.1.150`).
   - Exclure l'IP du serveur lui-même.
   - Renseigner la passerelle (le routeur).
   - Le DHCP distribuera aussi les options 66 (IP du serveur WDS) et 67 (nom du fichier de boot).

**Étape 2 — installation et configuration de WDS** :
1. Ajouter le rôle « Services de déploiement Windows » (WDS).
2. Configuration : clic droit sur le serveur → Configurer le serveur.
   - Créer le dossier d'installation (ex : `E:\RemoteInstall`) sur un **second disque dur** (50 Go min) formaté en NTFS, pas sur le C:.
   - Choisir « Serveur autonome » sans Active Directory. (En production, les postes sont généralement intégrés à un domaine AD pour la gestion centralisée — le déploiement peut intégrer automatiquement les machines au domaine après installation.)
   - Sélectionner « Répondre à tous les ordinateurs clients (connus et inconnus) ».
3. Démarrage : clic droit sur le serveur → Toutes les tâches → Démarrer.

**Étape 3 — ajout des images système (.wim)** : monter une ISO de Windows pour récupérer deux fichiers du dossier `Sources` :
1. **L'image de démarrage (`boot.wim`)** : le mini-système (Windows PE) qui charge l'assistant via le réseau.
   - *Le `boot.wim` de Windows 11 ne supporte pas le PXE en mode Legacy/BIOS, uniquement l'UEFI. Utiliser un `boot.wim` de Windows 10 ou Windows Server pour de vieilles machines BIOS ou sur VirtualBox.*
   - Trouver le `boot.wim` : clic droit sur l'ISO → ouvrir avec l'explorateur → dossier `Sources` → copier le fichier → l'importer depuis *Images de démarrage* du serveur WDS.
2. **L'image d'installation (`install.wim`)** *(à ne pas faire dans le cadre de la capture du Master)* : le système d'exploitation complet à déployer. Même emplacement (`Sources` de l'ISO). Dans WDS, s'ajoute séparément dans *Images d'installation*. Sans lui, WDS peut booter les machines mais n'a rien à installer.

*Option pour éviter d'appuyer sur F12 :* clic droit sur le serveur WDS → Propriétés → Démarrer → « Continuer le démarrage PXE sauf si l'utilisateur appuie sur Échap ».

**Étape 4 — capturer un master avec WDS** : le PC client a été préparé et `sysprep /generalize /oobe /shutdown` lancé, la machine est éteinte.
1. Console WDS → *Images de démarrage*.
2. Clic droit sur le `boot.wim` existant → Créer une image de capture.
3. Parcourir jusqu'à `E:\RemoteInstall\Boot\x64\Images\` → sélectionner `boot.wim`.
4. Le renommer `capture.wim` et valider. WDS l'ajoute à la liste des images de démarrage.
5. Désactiver le `boot.wim` (ou « Microsoft Windows Setup ») pour éviter toute confusion au boot PXE.
6. Modifier l'ordre de boot du PC client (réseau en premier).
7. Allumer le PC client (sysprepé) et booter en PXE → il boote directement sur `capture.wim`.
8. Un assistant « aspire » le disque dur du PC client et l'envoie sur le serveur WDS comme nouvelle image d'installation. Connexion au serveur : nom de l'ordinateur du serveur, utilisateur `nomduserveur\Administrateur`, mot de passe. Le groupe d'images doit avoir été créé au préalable (vide) dans *Images d'installation*.

> **L'image de capture se crée à partir du `boot.wim` existant sur le serveur — pas à partir d'un `install.wim` d'ISO Windows 11.** La capture peut prendre 20 à 45 minutes (voire plusieurs heures) selon la taille. Ne pas interrompre.

**Étape 5 — déployer le master** :
- Réactiver l'image de démarrage originale (clic droit sur l'image « Setup » → Activer) ; désactiver l'image « Capture » pour ne pas avoir à choisir.
- Créer une VM vide (sans ISO) avec les besoins classiques de Windows 11 : 4 Go de RAM, 50 Go de stockage, 2 cœurs. Sur le même réseau NAT que le serveur. Ordre de boot : Disque dur puis réseau.
- Lancer la VM : elle boote en PXE et charge le `boot.wim`.
- Se connecter (`nomdeserveur\Compte`), sélectionner le bon master.
- Définir le partitionnement et procéder à l'installation classique (OOBE...).

> *En production, prévoir un utilisateur dédié au déploiement plutôt que le compte administrateur, surtout pour automatiser ensuite.*

**Étape 6 — automatisation du déploiement WDS via fichiers de réponses (XML)** : supprimer toute intervention humaine grâce à des fichiers de réponses générés par **Windows ADK**.
- Ouvrir le Gestionnaire d'installation (Windows System Image Manager). Placer l'ISO de Windows 11 (pas du master) dans un dossier, copier le `install.wim` dans un dossier local, l'ajouter via Fichier → Sélectionner l'image Windows. Créer un « fichier catalogue » quand demandé.
- **Automatisation de WinPE (passe 1 : windowsPE)** : langue de l'interface d'installation (fr-FR), partitionnement (disque cible ID 0, `WillWipeDisk`, partition principale, lettre C:), identifiants de connexion WDS et sélection de l'image.
- **Automatisation de l'OOBE (passe 7 : oobeSystem)** : masquer les pages de config (EULA, Cortana, vie privée, publicités), création automatique d'un compte local et mot de passe, fuseau horaire et langue.
- **Application** : le fichier XML est lié dans les Propriétés de l'image d'installation (clic droit dans la console WDS).

> **Note UEFI** : pour les parcs UEFI, la structure du partitionnement dans le XML diffère (partition EFI en FAT32 de 100 Mo avant la partition principale). Vérifier UEFI vs BIOS via `msinfo32` ou la config de la VM.
