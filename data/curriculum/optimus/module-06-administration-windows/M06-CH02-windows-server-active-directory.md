> **Parcours Optimus — Module 6 · Chapitre 2 sur 14**

# Windows Server et Active Directory

## 2.1 Qu'est-ce que Windows Server ?

OS Microsoft optimisé pour les serveurs. Rôle : gérer le matériel et fournir des services (fichiers, sites web, bases de données). Conçu pour rester allumé 24h/24 et gérer des centaines de connexions simultanées. C'est la **plateforme logicielle**.

## 2.2 Installer Windows Server sur VirtualBox (grandes étapes)

Matériel : 4 Go de RAM minimum, 60 Go de stockage, 2 cœurs de CPU. Installer en **Windows Server Standard en mode expérience de bureau** (interface graphique, pas seulement CLI).

- **Étape 1** : renommer le PC selon la convention (ex : SRV_AD_01). À faire **impérativement avant** de promouvoir le serveur en Contrôleur de Domaine.
- **Étape 2 (TP)** : créer un réseau NAT pour faire communiquer les machines. Mode expert sur VirtualBox > onglet Réseaux > Nat Network > Créer > nommer et donner l'adresse IP. Puis affecter ce réseau à la VM. *(L'adresse du NAT est une adresse réseau.)*
- **Étape 3** : FIXER L'IP (adresse privée). Un contrôleur de domaine ne doit jamais changer d'IP. Pour Serveur DNS préféré, taper l'IP du propre serveur (ou 127.0.0.1) : le serveur devient son propre serveur DNS. Redémarrer la VM.

## 2.3 Active Directory (AD) : Le Service d'Annuaire

AD n'est pas un OS, c'est un **rôle** que l'on installe sur Windows Server. Rôle : centraliser la gestion des utilisateurs, ordinateurs et droits d'accès. Au lieu de créer un compte sur chaque PC, on crée un compte une seule fois dans l'AD. Quand un Windows Server héberge la base AD, on l'appelle un **Contrôleur de Domaine (DC)**.

> Windows Server est le bâtiment, Active Directory est le service de sécurité à l'entrée avec l'annuaire des occupants.

**Objets d'AD** : Users, Groups (où l'on met les utilisateurs), PC (permissions/autorisations), GPO (Group Policy Object).

**Structure d'AD** (forêt et arbres) :

| Niveau | Ex | Relation |
|---|---|---|
| Forêt | Google | L'ensemble du groupe |
| Arbre 1 | Google.fr | Domaine racine de l'arbre principal |
| Branche (sous-domaine) | Maps.google.fr | Enfant de l'arbre 1 |
| Feuille (unité d'organisation) | OU « Communication » | Dossier où l'on classe les utilisateurs |
| Arbre 2 | Youtube.com | Un autre arbre de la même forêt |

Grâce à la hiérarchie Forêt > Arbre > Domaine > OU : gestion fine des permissions, et les **GPO sont héritées** (une GPO sur le Domaine s'applique à toutes les OU en dessous).

**Pas d'Active Directory sans DNS** : installer AD installe un serveur DNS en même temps (besoin de traduire les noms de domaines). Déverrouillage de session : Ctrl droit + Suppr.

## 2.4 Installer Active Directory dans VirtualBox

- **Étape 1 — Installer AD DS** : désactiver IPv6 (`ncpa.cpl` > Propriétés > décocher IPv6 — astuce de TP, déconseillé par Microsoft en production). Tableau de bord > Rôles et fonctionnalités > AD DS (Active Directory Domain Services).
- **Étape 2** : Notifications > Promouvoir ce serveur en contrôleur de domaine > Créer la forêt. Mettre un nom avec une extension. Recommandation Microsoft actuelle : utiliser un sous-domaine réel possédé (ex : `ad.entreprise.com`) plutôt que `.local`/`.lan`.

## 2.5 Créer les OU, groupes et utilisateurs

**Étape 1 — l'Unité d'Organisation** : avant les groupes, créer une OU (avec le nom de domaine), puis des sous-OU avec les services.

| Terme Anglais | Terme Français | Définition |
|---|---|---|
| Forest | Forêt | Entité de plus haut niveau regroupant tous les domaines |
| Tree | Arbre | Ensemble de domaines partageant un espace de noms contigu |
| Domain Controller (DC) | Contrôleur de Domaine | Serveur qui gère les authentifications |
| Organizational Unit (OU) | Unité d'Organisation (UO) | « Dossier » où l'on range les objets pour leur appliquer des GPO |
| Group Policy Object (GPO) | Stratégie de Groupe | Règles de configuration appliquées aux UO |
| Security Group | Groupe de sécurité | Donner des droits sur des dossiers/ressources |
| Workstation | Poste de travail | Ordinateurs des utilisateurs |
| Trust Relationship | Approbation | Lien permettant aux utilisateurs d'un site d'accéder aux ressources d'un autre |

**Étape 2 — les groupes** : principe du **moindre privilège** (droits minimums).

**Méthode AGDLP** : Account (Users) > Global group > Domain Local group > Permissions.
- Un compte utilisateur est membre d'un **groupe de sécurité global (GG_)**.
- Ce groupe global est membre d'un **groupe de sécurité domaine local (GDL_)** (portée sur le domaine d'appartenance).
- Ce groupe domaine local sert à ajuster les **permissions NTFS** sur le répertoire partagé.

Exemple : pour 3 groupes (Comptabilité, Direction, Marketing), avec Direction qui lit tout et édite le sien, Compta qui édite le sien et consulte le marketing, Marketing qui édite le sien :

| Dossier Cible | Groupe pour LIRE (RO) | Groupe pour ÉDITER (RW) |
|---|---|---|
| Compta | GDL_Compta_RO | GDL_Compta_RW |
| Direction | GDL_Direction_RO | GDL_Direction_RW |
| Marketing | GDL_Marketing_RO | GDL_Marketing_RW |

On n'ajoute pas les utilisateurs dans les GDL, mais les Groupes Globaux (GG_Compta, etc.) dans les GDL. Ex : GG_Compta membre de GDL_Compta_RW ; GG_Direction membre de GDL_Compta_RO.

**Étape 3 — les utilisateurs** : créer les utilisateurs dans chaque groupe correspondant, vérifier les règles de mot de passe.

**En résumé AGDLP** : A (Account) tu crées l'utilisateur dans l'OU ; G (Global Group) tu crées GG_Secretariat et tu y mets l'utilisateur ; DL (Domain Local Group) tu crées GDL_Secretariat_RW et GDL_Secretariat_RO ; P (Permissions) tu appliques les droits NTFS aux groupes GDL.

**Créer un utilisateur (procédure)** :
1. Ouvrir `dsa.msc`
2. Naviguer vers l'OU cible
3. Clic droit → Nouvel utilisateur
4. Remplir : prénom, nom, logon (m.dupont@aerosud.local)
5. Définir un mot de passe temporaire
6. Cocher « L'utilisateur doit changer son mot de passe à la prochaine ouverture de session »
7. Ajouter l'utilisateur au groupe de sécurité correspondant

**Départ d'un employé (ordre des actions)** :
1. Désactiver le compte (ne pas supprimer immédiatement)
2. Révoquer les sessions actives (RDP, VPN)
3. Transférer les emails vers le manager
4. Déplacer le compte dans OU=Désactivés
5. Supprimer des groupes de sécurité
6. Après 30 jours : suppression définitive selon politique interne

## 2.6 Créer un partage de fichiers (File server)

**Étape 1 — disque dur dédié aux données** :
- *Option 1* : créer un disque virtuel sur VirtualBox (Configuration VM > Stockage > Add hard drive > VDI). Redémarrer > Gestion des disques > Initialiser > attribuer une lettre > Formater en NTFS.
- *Option 2* : partitionner le disque (réduire le disque, etc.).

**Étape 2 — dossiers + paramétrage NTFS** :
- Créer les dossiers correspondant aux sous-OU (dans un dossier « partages » : compta, direction, etc.) sur le disque D:.
- Pour chaque dossier, paramétrer les autorisations : Clic droit > Propriétés > Onglet **Sécurité** (droits NTFS, le plus important) > Modifier > Ajouter les GDL.
- **Bonne pratique** : dans l'onglet **Partage**, donner « Contrôle Total » à « Tout le monde ». La vraie sécurité se gère uniquement dans l'onglet **Sécurité (NTFS)** avec les groupes GDL (le système applique toujours l'autorisation la plus restrictive des deux).
- Ne pas oublier de **désactiver l'héritage** : Clic droit > Sécurité > Avancé > Désactiver l'héritage > « Convertir les autorisations héritées en autorisations explicites ».

## 2.7 Créer les GPO

- **Étape 1** : Outils > Gestion des stratégies de groupe > dérouler jusqu'à Objets de stratégie de groupe > Clic droit > Nouveau > nommer selon convention (`U_mappage_commercial`, U pour user / O pour ordinateur).
- **Étape 2** : la lier à une OU (glisser dessus) puis clic droit > APPLIQUER.
- **Étape 3** : Clic droit > Modifier > choisir et paramétrer la GPO.

**GPO à connaître** :
- *Mappage de lecteurs* : Configuration utilisateur └ Préférences └ Paramètres Windows └ Mappage de lecteurs (Drive Maps).
- *Stratégie de mot de passe* : Configuration Ordinateur └ Stratégies └ Paramètres Windows └ Paramètres de sécurité └ Stratégies de comptes └ Stratégie de mots de passe. (L'ANSSI recommande minimum 14 caractères robustes + complexes.)
- *Firewall* : Paramètres Windows > Paramètres de sécurité > Pare-feu Windows Defender (bloquer/autoriser port/IP).

**Mapper les lecteurs** : Clic droit sur la GPO > Modifier > Utilisateur > Préférences > Paramètres Windows > Mappage de lecteur > Nouveau lecteur mappé > coller l'adresse du dossier (Propriétés > Partage > Chemin réseau) > choisir une lettre en commençant par la fin (Z) > Afficher ce lecteur et Afficher tous les lecteurs. Sur le PC client : `gpupdate /force`. Tester en créant un document dans le dossier. *(Si un document créé par l'admin pose problème en édition RW, changer le propriétaire du fichier.)*

## 2.8 Connecter le PC client au domaine

- **Étape 1 (réseau)** : les deux VM (Serveur et Client) sur le même réseau NAT.
- **Étape 2 (DNS du client)** : se connecter avec l'utilisateur local, renommer le PC (ex : PC-client-01), `Win+R > ncpa.cpl > Propriétés > IPv4` > serveur DNS préféré = adresse IP du serveur. (Le client doit pointer vers le DNS du DC.) Activer la découverte de réseaux. Tester avec un ping serveur/client. Si problème : vérifier le pare-feu (`wf.msc` > Règles de trafic entrant > « Partage de fichiers et d'imprimantes (Demande d'écho - ICMPv4-Entrant) » > Autoriser).
- **Étape 3 (jonction au domaine)** : Clic droit Démarrer > Système > Paramètres système avancés > onglet Nom de l'ordinateur > Modifier > sélectionner Domaine et taper le nom (ex : tip.ofiaq ; si échec, nom NetBIOS court : TIP). Taper l'identifiant Administrateur + mot de passe du serveur. Redémarrer. Vérifier : se connecter avec un compte utilisateur, copier le chemin d'un dossier partagé (ex : `\\SRV-AD-01\commercial`) et le coller via Win+R sur le client.

## 2.9 Récapitulatif AD

| Terme | Définition simple |
|---|---|
| Domaine | Ensemble d'utilisateurs et d'ordinateurs gérés par un même AD (ex : aerosud.local) |
| Contrôleur de domaine (DC) | Serveur Windows Server qui héberge l'AD — cerveau du réseau |
| Unité d'organisation (OU) | Dossier virtuel pour organiser les objets AD |
| Groupe de sécurité | Ensemble d'utilisateurs auxquels on attribue les mêmes droits |
| GPO | Règle appliquée automatiquement à des utilisateurs/ordinateurs |

> Sans contrôleur de domaine fonctionnel, les utilisateurs ne peuvent plus s'authentifier. Toujours avoir au minimum 2 DC (redondance).

**Commandes essentielles AD :**

```
dsa.msc                              → Active Directory Users & Computers
gpmc.msc                             → Console de gestion des GPO
gpupdate /force                      → Forcer l'application immédiate des GPO
gpresult /r                          → Afficher les GPO appliquées au poste
dcdiag                               → Diagnostiquer l'état du contrôleur de domaine
nltest /sc_query:aerosud.local       → Vérifier la connexion au DC
```
