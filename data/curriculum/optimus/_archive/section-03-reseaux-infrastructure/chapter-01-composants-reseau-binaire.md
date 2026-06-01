> **Parcours Optimus** — **Module 3** · Chapitre 1 sur 5 · *Composants du réseau et binaire*.
>
> Contenu issu du cours Optimus (PDF) ; tableaux extraits du PDF ; illustrations sous `curriculum/optimus/images/`.
MODULE 3 : RÉSEAUX & INFRASTRUCTURE
Partie 1 : Les composants du réseau (switch, routeur, wifi, MAC) et binaire
1. Réseau
Un réseau est un ensemble de machines et d'équipements (switch, routeurs, points d'accès, câbles RJ45,
cartes réseau/NIC) qui peuvent communiquer et s'échanger des données.
Définitions
- Adresse MAC : propre à chaque carte réseau, codée en hexadécimal sur 48 bits. Les 24 premiers
bits identifient le fabricant, les 24 suivants identifient la carte de façon unique.
- Hub : équipement de couche 1 (couche Physique du modèle OSI). Il répète le signal électrique reçu
vers TOUS ses ports simultanément, sans aucune intelligence : c'est du broadcast physique
permanent. Résultat : toutes les machines branchées « entendent » tout le traficla bande passante
est partagée entre tous les appareils. Le Hub est aujourd'hui obsolète et remplacé par le switch.
- Switch (commutateur) : équipement de
couche 2 (couche Liaison). Il analyse les
adresses MAC contenues dans chaque trame
et les envoie uniquement au port destinataire
grâce à sa table SAT (port physique ↔ adresse
MAC). Contrairement au Hub, la bande
passante est dédiée à chaque paire de
communicants.
- Modem : MOdulateur-DEModulateur. Convertit les signaux numériques en signaux analogiques
(modulation) et inversement (démodulation). Aujourd'hui notre box contient toujours un modem. Il
n'est pas remplacé, il est intégré dans un appareil tout-en-un (Modem + Routeur + Switch + Point
d'accès).
- Routeur : fait communiquer plusieurs réseaux entre eux, route les paquets vers leur destination en
s'appuyant sur les adresses IP.
- Passerelle (Gateway) : adresse IP du routeur côté réseau local. Elle constitue le point de sortie
obligatoire pour tout trafic à destination d'un autre réseau. Finit souvent par .1 par convention (non
obligatoire). La "Default Gateway" (Passerelle) : si la passerelle est mal configurée sur un PC, celui-
ci pourra communiquer avec ses voisins (VLAN local), mais ne pourra jamais sortir sur Internet,
même si l'IP et le DNS sont bons.
- NAT (Network Address Translation) : technique utilisée par les routeurs. Permet à plusieurs
appareils d'un réseau local de partager une seule IP publique. Indispensable pour Internet à la
maison. Pour être précis, ce qu'on utilise à la maison est le PAT (Port Address Translation). Le NAT
classique fait correspondre une IP privée à une IP publique. Le PAT permet à plusieurs IP privées
d'utiliser une seule IP publique grâce aux numéros de ports.
- Point d'accès Wi-Fi : crée une cellule sans fil (BSS) identifiée par un SSID. La box à la maison est
un appareil 3-en-1 : Routeur + Switch + Point d'accès.
- Adresse IP : identifiant logique unique de chaque appareil sur un réseau. Elle peut être fixe (static)
ou dynamique (DHCP) IP privées (réseau local, non routables) vs IP publiques (routables sur
Internet).
![Image 12](../images/image_012.jpeg)
- Masque de sous-réseau : valeur sur 32 bits associée à une adresse IP. Permet de distinguer la
partie réseau de la partie hôte d'une adresse. Exemple : 255.255.255.0 (/24). Utilisé pour
déterminer si deux appareils sont sur le même réseau.
- Adresse de réseau : première adresse d'une plage IP. Identifie le réseau lui-même, non assignable
à un appareil. Exemple : 192.168.1.0.
- Adresse de broadcast : dernière adresse d'une plage IP. Utilisée pour envoyer un message à tous
les appareils du réseau simultanément. Exemple : 192.168.1.255.
- DNS (Domain Name System) : convertit les noms de domaine en adresses IP (et inversement via
le DNS inversé). Permet de naviguer avec des noms lisibles plutôt que des adresses numériques.
- DDNS (Dynamic DNS) : service qui met à jour automatiquement un enregistrement DNS lorsque
l'IP publique d'un hôte change. Utile pour accéder à distance à un équipement dont l'IP publique est
dynamique (la plupart des abonnements particuliers).
- DHCP (Dynamic Host Configuration Protocol) : protocole qui attribue automatiquement une
configuration réseau aux appareils (adresse IP, masque, passerelle, DNS). Évite la configuration
manuelle de chaque poste.
- VPN (Virtual Private Network) : crée un tunnel sécurisé et chiffré entre un appareil et un réseau
distant. Masque l'adresse IP réelle. VPN nomade (connexion depuis n'importe où vers un réseau)
vs VPN site-à-site (tunnel fixe et permanent entre deux sites).
- VLAN (Virtual Local Area Network) : réseau local virtuel créé par segmentation logique d'un
switch. Permet d'isoler des groupes d'appareils sur la même infrastructure physique, pour des
raisons de sécurité ou d'organisation.
- Protocole réseau : ensemble de règles définissant comment les données sont échangées entre
appareils. Exemples principaux : TCP (transmission fiable avec vérification) et UDP (transmission
rapide sans vérification, utilisé pour la vidéo/jeux).
- Ping / ICMP : outil de diagnostic réseau. Envoie un paquet ICMP à une adresse cible et mesure le
temps de réponse (en ms). Permet de vérifier qu'un appareil est joignable et d'estimer la latence.
## 2. Supports de transmission : Filaire (Ethernet) vs Sans-fil (Wi-Fi)

### 2.1. Ethernet — L'accès filaire (IEEE 802.3)
Si le Wi-Fi est la liberté, l'Ethernet est la stabilité. Ethernet est une norme réseau dédiée principalement
aux réseaux LAN, mais également utilisée dans les réseaux MAN et WAN. Elle s'est imposée comme le
standard universel des réseaux locaux.
Ethernet est utilisé dans le modèle OSI aux niveaux de la couche Physique (couche 1) et de la couche
Liaison de données (couche 2). Il a servi de base à la norme IEEE 802.3, qui a unifié le développement
des réseaux et des composants matériels. Ethernet est une norme en constante évolution. Sa première
version (1980) n'offrait que 10 Mb/s. Aujourd'hui, les versions les plus récentes atteignent 400 Gb/s à 1,6
Tb/s sur fibre optique.
⚠️ Même si on associe Ethernet aux réseaux câblés, cette norme ne se limite pas au cuivre : elle
s'applique aussi aux liaisons fibre optique (10GBASE-SR, 100GBASE-LR…).
2.1.1. Normes Ethernet — De 10 Mb/s à 1,6 Tb/s
- **Norme** | **Débit** | **Support (câble)** | **Distance** | **Connecteur** | ** Remarques**
- **Norme** | **Débit** | **Support (câble)** | **max**
|10BASE-T|10 Mb/s|Cat 3 / Cat 5|100 m|RJ45|Obsolète|
|---|---|---|---|---|---|
|100BASE-TX (Fast Eth.)|100 Mb/s|Cat 5 / 5e|100 m|RJ45|Encore sur vieux équipements|
|1000BASE-T (Gigabit)|1 Gb/s|Cat 5e / 6|100 m|RJ45|Standard actuel minimum|
|10GBASE-T (10 Gigabit)|10 Gb/s|Cat 6 (55 m) / Cat 6a|55–100 m|RJ45|Existe en cuivre, pas seulement fibre|
|10GBASE-SR / LR|10 Gb/s|Fibre optique multimodo/monomodo|Jusqu'à plusieurs km|LC/SC|Interconnexion switchs|
|40G / 100G Ethernet|40–100 Gb/s|Fibre optique|Variable|QSFP / MPO|Data centers, backbone|
|200G / 400G / 800G / 1.6T|Très haut débit|Fibre optique|Variable|QSFP-DD|Réseaux opérateurs / hyperscale|
2.1.2. Câbles et catégories — Ce qui change vraiment
Le connecteur RJ45 reste identique pour toutes les catégories de câble cuivre. Ce qui change, c'est la
qualité du cuivre, l'isolation interne et la protection contre les interférences.
|**Catégorie**|**Débit max**|**Fréquence**|**Blindage**|**Usage typique**|
|---|---|---|---|---|
|Cat 5e|1 Gb/s|100 MHz|UTP (non blindé)|LAN bureautique — standard minimum|
|Cat 6|1 Gb/s (10 Gb/s sur 55 m)|250 MHz|UTP ou FTP|LAN entreprise, interconnexion courte|
|Cat 6a|10 Gb/s|500 MHz|FTP / SFTP (blindé)|Infrastructure entreprise actuelle recommandée|
|Cat 7|10 Gb/s|600 MHz|SFTP (blindage par paire)|Environnements industriels à fortes perturbations|
|Cat 8|40 Gb/s|2000 MHz|SFTP|Data centers, liaisons très courtes (30 m max)|
Le blindage (Shielding) :
- UTP (Unshielded Twisted Pair) : pas de blindage — suffit en bureautique standard
- FTP (Foiled Twisted Pair) : feuille d'aluminium autour de toutes les paires — bon rapport qualité/prix
- STP (Shielded Twisted Pair) : blindage autour de chaque paire individuelle
- SFTP / S/FTP : feuille par paire + blindage global — niveau maximum, utilisé en milieu industriel/
📌 Application terrain (Sonia) : dans une usine avec de gros moteurs électriques (CNC, variateurs de
vitesse), on choisit du Cat 6a SFTP pour éviter que les parasites électromagnétiques fassent tomber le
réseau. Le surcout du câble blindé est négligeable comparé au coût d'une panne de production.
La rétrocompatibilité : un câble Cat 6a fonctionnera parfaitement sur une vieille carte réseau Fast
Ethernet (100 Mbps), mais il sera bridé. L'inverse n'est pas vrai : un câble Cat 5e ne permettra jamais
d'atteindre du 10 Gb/s stable sur 100 mètres.
2.1.3. PoE — Power over Ethernet
Le PoE (Power over Ethernet) permet d’alimenter électriquement un équipement réseau directement via
le câble Ethernet, sans prise secteur séparée. Les données et l’alimentation peuvent transiter sur le
même câble réseau.
- **Standard** | **Puissance** | **Usage typique**
- **Standard** | **max**
- PoE (802.3af) | 15,4 W | Téléphones IP, petites caméras IP, points d'accès Wi-Fi basiques
- PoE+ (802.3at) | 30 W | Points d'accès Wi-Fi 6, caméras PTZ, écrans d'affichage
- PoE++ (802.3bt) | 60–90 W | PC légers, écrans, bornes de recharge, équipements vidéo haute qualité
✅ Avantage terrain majeur : une caméra de surveillance ou un point d'accès Wi-Fi placé en hauteur
ou en extérieur n'a besoin que d'un seul câble RJ45. Pas d'électricien, pas de gaine supplémentaire.
Un switch PoE peut alimenter 24 équipements avec un seul câble chacun.
💡 Pour qu'un équipement soit alimenté en PoE, deux conditions : le switch doit être un switch PoE
(pas un switch standard), et l'équipement doit être compatible PoE. Un équipement non-PoE branché
sur un port PoE ne sera pas endommagé — le switch détecte la compatibilité avant d'envoyer le
courant.
2.1.4. Ethernet vs Wi-Fi — Tableau comparatif
|**Caractéristique**|**Ethernet (Câble)**|**Wi-Fi (Ondes)**|
|---|---|---|
|Débit|Constant et dédié (Full-Duplex)|Partagé entre tous les appareils connectés|
|Latence|Très faible — idéal pour VoIP, jeux, RDP|Variable — sujet aux interférences et à la charge|
|Sécurité|Physique — il faut se brancher physiquement|Ondes dans l'air — plus exposé aux interceptions|
|Mobilité|Nulle — fil obligatoire|Totale — liberté de déplacement|
|Fiabilité|Très élevée — pas de perturbations|Dépend de l'environnement (murs, appareils voisins)|
|Installation|Tirage de câbles nécessaire|Rapide — juste un point d'accès|
|Usage recommandé|Postes fixes, serveurs, imprimantes|Téléphones, laptops, IoT, espaces ouverts|
📌 Règle terrain : pour tout équipement fixe (PC de bureau, imprimante réseau, serveur, caméra
fixe, téléphone IP), préférer toujours le câble. Le Wi-Fi est réservé aux équipements mobiles ou
aux zones impossibles à câbler.connecte. Limite des 100 mètres : c'est la question piège sur le
terrain : "Qu'est-ce qu'on fait si l'imprimante est à 120 mètres ?" (Réponse : switch intermédiaire
ou fibre).
### 2.2. Wi-Fi — Fonctionnement et normes

Le Wi-Fi (Wireless Fidelity) est né en 1997 avec la norme initiale IEEE 802.11 (2 Mb/s). En 1999,
le Wi-Fi décolle avec le 802.11b (11 Mb/s, 2,4 GHz) et le 802.11a (54 Mb/s, 5 GHz). Le 802.11g
unifie les débits à 54 Mb/s en 2003, puis le 802.11n (Wi-Fi 4, 2009) introduit le MIMO (antennes
multiples) pour atteindre 600 Mb/s. En 2013, le 802.11ac (Wi-Fi 5) franchit le gigabit grâce au 5
GHz uniquement. Depuis 2019, le Wi-Fi 6 (802.11ax) optimise la gestion des environnements
denses (nombreux appareils), tandis que le Wi-Fi 7 (802.11be, 2024) dépasse les 46 Gb/s
théoriques.
Le Wi-Fi fonctionne via les ondes hertziennes sur les bandes de fréquences 2,4 GHz, 5 GHz et 6
GHz.
2.2.1. Évolution des normes Wi-Fi
- **Génération** | **Norme** **IEEE** | **Année** | **Fréquences** | **Débit max** | **Nouveauté clé**
- **Génération** | **Norme** **IEEE** | **Année** | **Fréquences** | **théorique**
- Wi-Fi 1 | 802.11b | 1999 | 2,4 GHz | 11 Mb/s | Première démocratisation
- Wi-Fi 2 | 802.11a | 1999 | 5 GHz | 54 Mb/s | 5 GHz (moins de congestion)
- Wi-Fi 3 | 802.11g | 2003 | 2,4 GHz | 54 Mb/s | Unification 2,4 GHz
- Wi-Fi 4 | 802.11n | 2009 | 2,4 + 5 GHz | 600 Mb/s | MIMO (antennes multiples)
- Wi-Fi 5 | 802.11ac | 2013 | 5 GHz | 3,5 Gb/s | MU-MIMO, beamforming
- Wi-Fi 6 | 802.11ax | 2019 | 2,4 + 5 GHz | 9,6 Gb/s | OFDMA — gestion dense (IoT, open space)
- Wi-Fi 6E | 802.11ax | 2021 | 2,4 + 5 + 6 GHz | 9,6 Gb/s | Bande 6 GHz non congestionnée
- Wi-Fi 7 | 802.11be | 2024 | 2,4 + 5 + 6 GHz | 46 Gb/s max plutot des 5 à 10 Gb/s utiles dans la réalité | Multi-Link Operation (plusieurs bandes simultanées)
2.2.2. Fréquences et canaux
- **Fréquence** | **Portée** | **Débit max** | **Interférences** | **Usage**
- **Fréquence** | **Portée** | **(pratique)** | **recommandé**
- 2,4 GHz | Longue — traverse mieux les murs et les obstacles | ~300 Mb/s | Nombreuses (micro-ondes, Bluetooth, voisins, tous sur 3 canaux) | IoT, appareils éloignés du point d'accès
- 5 GHz | Courte — s'atténue rapidement avec les murs | ~1,3 Gb/s | Peu denses — plus de canaux disponibles (25 canaux non-chevauchants) | PC, smartphones, TV proches du point d'accès
- 6 GHz (Wi-Fi 6E/7) | Très courte | > 2 Gb/s | Quasi inexistantes — bande récente peu utilisée | Équipements récents, très haut débit
Canaux et interférences (2,4 GHz) : en 2,4 GHz, seuls 3 canaux sont non-chevauchants : 1, 6 et
## 11. Lorsque deux points d'accès voisins utilisent le même canal, les signaux se perturbent

mutuellement — c'est la principale cause de Wi-Fi lent en immeuble.
💡 Conseil terrain : si le Wi-Fi est lent ou instable, inspecter les canaux voisins avec Wi-Fi
Analyzer (Android) ou inSSIDer (PC). Changer de canal peut résoudre le problème sans
aucune intervention matérielle. En environnement dense, passer sur du 5 GHz réduit
drastiquement les interférences.
### 2.3. Wi-Fi — Sécurisation

La sécurité Wi-Fi garantit deux choses : que seul l'utilisateur autorisé peut se connecter
(Authentification) et que personne ne peut lire les données qui circulent dans l'air (Chiffrement).
2.3.1. Protocoles de sécurité
|**Protocole**|**Chiffrement**|**Statut**|**Niveau de sécurité**|
|---|---|---|---|
|WEP|RC4 (cassé)|Obsolète, à bannir|Nul — se pirate en quelques minutes avec un simple PC|
|WPA|TKIP|Obsolète|Faible — première réponse urgente aux failles WEP|
|WPA2|Chiffrement : AES-CCMP (Advanced Encryption Standard)- (Counter Mode with Cipher Block Chaining Message Authentication Code Protocol) + Méthode de connexion : PSK (PreShared Key) : "Handshake" (la poignée de main) entre le PC et la borne contient des informations qui permettent de deviner le mot de passe.|Standard actuel|Protocole de chiffrement robuste du WPA2 qui garantit que vos données Wi-Fi sont à la fois illisibles pour les pirates et protégées contre toute modification. Bon — norme la plus répandue en entreprise aujourd'hui|
|WPA3|Chiffrement : AES-GCM + Méthode de connexion : SAE (_Simultaneous_ _Authentication of Equals : c_'est ce qui remplace le "Handshake" du WPA2 et empêche le pirate du parking de faire une attaque par dictionnaire offline)| Recommandé|Excellent — résiste aux attaques par dictionnaire et brute-force offline|
⚠️ WEP est cassé depuis 2001. S'il est encore présent sur un équipement en production, c'est
une faille de sécurité ouverte. Aucune excuse pour le maintenir.
2.3.2. Modes d'authentification : Personal vs Enterprise
|**Mode**|**Fonctionnement**|**Avantage**|**Inconvénient**|**Usage**|
|---|---|---|---|---|
|WPA2/WPA3 Personal (PSK)|Un seul mot de passe partagé entre tous les utilisateurs|Simple à configurer|Si un employé part, il faut changer le mot de passe sur TOUS les appareils|Maison, PME sans AD (Le WPA2**reste sûr en pratique** quand le mot de passe est fort  MAIS**vulnérable aux** **attaques offline** (KRACK exclu))|
|---|---|---|---|---|
|WPA2/WPA3 Enterprise (802.1X)|Chaque utilisateur se connecte avec son identifiant/mot de passe Active Directory (via serveur RADIUS*)|Révocation individuelle : on coupe l'accès d'une personne sans toucher aux autres|Nécessite un serveur RADIUS + infrastructure AD|Entreprises avec AD — solution recommandée|
*Serveur RADIUS : RADIUS est un protocole AAA qui centralise l'authentification des accès réseau en
s'appuyant sur Active Directory comme base d'utilisateurs par exemple. Lorsqu'un utilisateur tente de se
connecter, le NAS envoie les credentials au serveur RADIUS (ex: NPS sur Windows Server), qui les vérifie
auprès de l'AD et répond Accept ou Reject.
2.3.3. Bonnes pratiques de sécurisation
|**Pratique**|**Description**|**Priorité**|
|---|---|---|
|Utiliser WPA2 ou WPA3|Ne jamais utiliser WEP ou WPA1|Critique|
|Désactiver le WPS|Le bouton WPS est une faille connue (brute-force en quelques heures). À désactiver immédiatement|Critique|
|VLANs Wi-Fi dédiés|Réseau Invité sur VLAN isolé, réseau Production sur VLAN séparé. Un invité ne doit jamais atteindre les serveurs|Critique|
|Masquer le SSID|Fausse bonne idée : un scanner (Wireshark, Aircrack) détecte le réseau même masqué. Complique la vie des utilisateurs sans apporter de vraie sécurité|Inutile|
|Filtrage MAC|On autorise uniquement les adresses MAC connues. Limite : une adresse MAC se spoofie facilement. Couche supplémentaire, pas une protection réelle| Complémentaire|
|---|---|---|
|Isolation des clients|Empêche les appareils Wi-Fi de communiquer entre eux. Obligatoire pour un Wi-Fi Visiteurs| Recommandé|
|Changer le mot de passe par défaut du point d'accès|Les identifiants admin par défaut sont publics en ligne|Critique|
2.3.4. Cas pratique — AéroSud (Nadia)
🔷 Situation : Un pirate stationne sur le parking d'AéroSud avec un ordinateur portable et un
adaptateur Wi-Fi en mode monitor.
|**Scénario**|**Ce que le pirate peut faire**|**Solution de Nadia**|
|---|---|---|
|Wi-Fi ouvert (aucun chiffrement)|Capture et lit en clair TOUS les emails, mots de passe et données qui circulent (attaque passive avec Wireshark) Un**Wi-** **Fi ouvert** permet à un attaquant d’intercepter le trafic**non chiffré** et d’exploiter des services mal sécurisés. Même si de nombreux sites utilisent aujourd’hui**HTTPS/TLS**, ce type de réseau reste**inadapté à un usage** **professionnel**.|Inadmissible en entreprise|
|---|---|---|
|WPA2 Personal avec mot de passe simple (ex: Aerosud2024)| Attaque par dictionnaire offline : il capture le handshake et teste des millions de combinaisons avec Hashcat|Mot de passe long et complexe — mais révocation impossible si l'employé part|
|WPA2/WPA3 Enterprise (802.1X + RADIUS + AD)| Bloqué : chaque utilisateur a ses propres identifiants AD. Sans compte valide, impossible de s'authentifier|Solution retenue par Nadia — révocation individuelle, logs de connexion, intégration AD|
✅ La solution Enterprise de Nadia est la seule qui coupe l'accès en 30 secondes si un
employé est licencié, sans toucher aux autres utilisateurs. C'est la norme dans toute
infrastructure professionnelle sérieuse.
### 2.4. Récapitulatif — Ce qu'il faut retenir

Ethernet
- Norme IEEE 802.3 — fonctionne sur cuivre (RJ45) et fibre optique
- Cat 6a = standard recommandé en entreprise (10 Gb/s, résistant aux perturbations)
- PoE : alimentation électrique via le câble RJ45 — idéal pour caméras, téléphones IP, AP Wi-Fi
- Pour tout équipement fixe : câble > Wi-Fi (débit garanti, latence constante, sécurité physique)
Wi-Fi
- Wi-Fi 6 (802.11ax) = standard actuel recommandé pour les déploiements neufs
- 2,4 GHz = portée longue, interférences nombreuses / 5 GHz = portée courte, moins encombré
- 3 canaux non-chevauchants en 2,4 GHz : 1, 6, 11
- WPA3 > WPA2 > WPA > WEP (à bannir absolument)
- Enterprise (802.1X) = seule vraie solution en environnement professionnel avec AD
- Désactiver le WPS — c'est une faille ouverte
- Réseau Invité = VLAN isolé obligatoire
📌 La règle d'or du terrain (Sonia) : "On câble tout ce qui ne bouge pas, on met en Wi-Fi tout ce qui se
déplace. Et on n'autorise jamais un VoIP ou une caméra de sécurité sur le Wi-Fi si on peut l'éviter."
## 3. Typologie des réseaux

|**Type**|**Portée**|**Usage**|**Technologie**|
|---|---|---|---|
|PAN|1-10 m|Montre connectée, écouteurs|Bluetooth, USB|
|LAN|100 m - 1 km|Réseau d'entreprise, maison|Wi-Fi, Ethernet|
|MAN|10-50 km|Plusieurs sites d'une ville|Fibre optique|
|WAN|Illimité|Internet|Satellites, câbles sous-marins|
Topologies réseau
|**Topologie**|**Avantage**|**Inconvénient**|**Usage**|
|---|---|---|---|
|Étoile|Panne isolée à un seul poste|Si nœud central tombe, tout tombe|Bureaux, foyers (la plus utilisée)|
|Maillée|Ultra-robuste, chemins alternatifs|Très coûteux|Internet, systèmes militaires|
|Hybride|Flexible, adaptable|Complexe|Grandes entreprises, campus|
|Bus|Simple et peu coûteux|Câble central = point unique de défaillance|Obsolète|
|Anneau|Pas de collision|Une panne = tout le réseau tombe|Réseaux industriels anciens|
4. Binaire et hexadécimal
Comprendre le binaire et l'hexadécimal est indispensable pour configurer les masques de sous-réseau,
interpréter les adresses IPv6 ou diagnostiquer des erreurs matérielles, car ces systèmes numériques
représentent la réalité brute des données circulant sur un réseau.
|**2⁷**|**2⁶**|**2⁵**|**2⁴**|**2³**|**2²**|**2¹**|**2⁰**|
|---|---|---|---|---|---|---|---|
|128|64|32|16|8|4|2|1|
Le binaire est un langage base 2. Exemple : 222 en binaire
Méthode de la division successives par 2, on lit les restes de bas en haut :
222/2=111(0) → 111/2=55(1) → 55/2=27(1) → 27/2=13(1) → 13/2=6(1) → 6/2=3(0) → 3/2=1(1)
→ 1/2=0(1)
 222 = 1101 1110 (vérification : 128+64+16+8+4+2 = 222)
Méthode décimal → binaire : soustraire successivement les puissances de 2 en partant de 128.
Si le décimal est pair → se termine par 0 ; si impair → se termine par 1.
Hexadécimal :
L'hexadécimal utilise la base 16 (symboles 0-9 et A-F). Un octet (8 bits) se représente en 2 caractères
hexadécimaux. C'est beaucoup plus compact pour lire la mémoire ou les adresses MAC.
Exemple : 255 (décimal) = FF (hexadécimal) car F=15 → 15×16⁰ + 15×16¹ = 15 + 240 = 255
