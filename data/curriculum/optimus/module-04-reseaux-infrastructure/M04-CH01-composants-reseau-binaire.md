> **Parcours Optimus — Module 4 · Chapitre 1 sur 5**

# Les composants du réseau (switch, routeur, wifi, MAC) et binaire

## 1. Réseau

Un réseau est un ensemble de machines et d'équipements (switch, routeurs, points d'accès, câbles RJ45, cartes réseau/NIC) qui peuvent communiquer et s'échanger des données.

**Définitions :**

- **Adresse MAC** : propre à chaque carte réseau, codée en hexadécimal sur 48 bits. Les 24 premiers bits identifient le fabricant, les 24 suivants identifient la carte de façon unique.
- **Hub** : équipement de couche 1 (Physique, OSI). Répète le signal reçu vers TOUS ses ports simultanément, sans intelligence (broadcast physique permanent). Toutes les machines « entendent » tout le trafic, bande passante partagée. Obsolète, remplacé par le switch.
- **Switch (commutateur)** : équipement de couche 2 (Liaison). Analyse les adresses MAC de chaque trame et les envoie uniquement au port destinataire grâce à sa **table SAT** (port physique ↔ adresse MAC). La bande passante est dédiée à chaque paire de communicants.
- **Modem** : MOdulateur-DEModulateur. Convertit signaux numériques ↔ analogiques. La box contient toujours un modem, intégré dans un appareil tout-en-un (Modem + Routeur + Switch + Point d'accès).
- **Routeur** : fait communiquer plusieurs réseaux entre eux, route les paquets en s'appuyant sur les adresses IP.
- **Passerelle (Gateway)** : adresse IP du routeur côté réseau local. Point de sortie obligatoire pour tout trafic à destination d'un autre réseau. Finit souvent par .1 (convention, non obligatoire). Si la passerelle est mal configurée, le PC peut communiquer avec ses voisins (VLAN local) mais ne pourra jamais sortir sur Internet, même si IP et DNS sont bons.
- **NAT (Network Address Translation)** : permet à plusieurs appareils d'un réseau local de partager une seule IP publique. À la maison on utilise plutôt le **PAT** (Port Address Translation) : plusieurs IP privées via une seule IP publique grâce aux numéros de ports.
- **Point d'accès Wi-Fi** : crée une cellule sans fil (BSS) identifiée par un SSID. La box est un appareil 3-en-1 : Routeur + Switch + Point d'accès.
- **Adresse IP** : identifiant logique unique de chaque appareil. Fixe (static) ou dynamique (DHCP). IP privées (réseau local, non routables) vs IP publiques (routables sur Internet).
- **Masque de sous-réseau** : valeur sur 32 bits associée à une adresse IP. Distingue la partie réseau de la partie hôte. Ex : 255.255.255.0 (/24).
- **Adresse de réseau** : première adresse d'une plage IP. Identifie le réseau, non assignable. Ex : 192.168.1.0.
- **Adresse de broadcast** : dernière adresse d'une plage IP. Envoie un message à tous les appareils. Ex : 192.168.1.255.
- **DNS (Domain Name System)** : convertit les noms de domaine en adresses IP (et inversement via le DNS inversé).
- **DDNS (Dynamic DNS)** : met à jour automatiquement un enregistrement DNS lorsque l'IP publique change. Utile pour l'accès distant.
- **DHCP (Dynamic Host Configuration Protocol)** : attribue automatiquement une configuration réseau (IP, masque, passerelle, DNS).
- **VPN (Virtual Private Network)** : tunnel sécurisé et chiffré entre un appareil et un réseau distant. Masque l'IP réelle. VPN nomade vs VPN site-à-site.
- **VLAN (Virtual Local Area Network)** : réseau local virtuel créé par segmentation logique d'un switch. Isole des groupes d'appareils sur la même infrastructure physique.
- **Protocole réseau** : ensemble de règles définissant l'échange de données. Ex : TCP (fiable) et UDP (rapide).
- **Ping / ICMP** : outil de diagnostic. Envoie un paquet ICMP et mesure le temps de réponse (ms). Vérifie qu'un appareil est joignable et estime la latence.

## 2. Supports de transmission : Filaire (Ethernet) vs Sans-fil (Wi-Fi)

### 2.1 Ethernet — L'accès filaire (IEEE 802.3)

Ethernet est une norme réseau dédiée principalement aux LAN, mais aussi MAN et WAN. Standard universel des réseaux locaux. Utilisé aux couches Physique (1) et Liaison de données (2) du modèle OSI. Base de la norme IEEE 802.3. Première version (1980) : 10 Mb/s ; versions récentes : 400 Gb/s à 1,6 Tb/s sur fibre.

> ⚠️ Ethernet ne se limite pas au cuivre : il s'applique aussi aux liaisons fibre optique (10GBASE-SR, 100GBASE-LR…).

**Normes Ethernet :**

| Norme | Débit | Support | Distance max | Connecteur | Remarques |
|---|---|---|---|---|---|
| 10BASE-T | 10 Mb/s | Cat 3 / Cat 5 | 100 m | RJ45 | Obsolète |
| 100BASE-TX (Fast Eth.) | 100 Mb/s | Cat 5 / 5e | 100 m | RJ45 | Encore sur vieux équipements |
| 1000BASE-T (Gigabit) | 1 Gb/s | Cat 5e / 6 | 100 m | RJ45 | Standard actuel minimum |
| 10GBASE-T (10 Gigabit) | 10 Gb/s | Cat 6 (55 m) / Cat 6a | 55–100 m | RJ45 | Existe en cuivre, pas seulement fibre |
| 10GBASE-SR / LR | 10 Gb/s | Fibre multimode/monomode | Plusieurs km | LC/SC | Interconnexion switchs |
| 40G / 100G Ethernet | 40–100 Gb/s | Fibre optique | Variable | QSFP / MPO | Data centers, backbone |
| 200G / 400G / 800G / 1.6T | Très haut débit | Fibre optique | Variable | QSFP-DD | Réseaux opérateurs / hyperscale |

**Câbles et catégories** : le connecteur RJ45 reste identique pour toutes les catégories de cuivre. Ce qui change : qualité du cuivre, isolation interne, protection contre les interférences.

| Catégorie | Débit max | Fréquence | Blindage | Usage typique |
|---|---|---|---|---|
| Cat 5e | 1 Gb/s | 100 MHz | UTP (non blindé) | LAN bureautique — standard minimum |
| Cat 6 | 1 Gb/s (10 Gb/s sur 55 m) | 250 MHz | UTP ou FTP | LAN entreprise, interconnexion courte |
| Cat 6a | 10 Gb/s | 500 MHz | FTP / SFTP (blindé) | Infrastructure entreprise actuelle recommandée |
| Cat 7 | 10 Gb/s | 600 MHz | SFTP (blindage par paire) | Environnements industriels à fortes perturbations |
| Cat 8 | 40 Gb/s | 2000 MHz | SFTP | Data centers, liaisons très courtes (30 m max) |

**Le blindage :**

- **UTP** (Unshielded Twisted Pair) : pas de blindage — suffit en bureautique.
- **FTP** (Foiled Twisted Pair) : feuille d'aluminium autour de toutes les paires — bon rapport qualité/prix.
- **STP** (Shielded Twisted Pair) : blindage autour de chaque paire individuelle.
- **SFTP / S/FTP** : feuille par paire + blindage global — niveau maximum, milieu industriel.

> Application terrain : dans une usine avec de gros moteurs (CNC, variateurs), choisir du Cat 6a SFTP pour éviter que les parasites électromagnétiques fassent tomber le réseau.

**Rétrocompatibilité** : un câble Cat 6a fonctionne sur une vieille carte Fast Ethernet (bridé). L'inverse n'est pas vrai : un Cat 5e ne permettra jamais du 10 Gb/s stable sur 100 m.

**PoE — Power over Ethernet** : alimente électriquement un équipement réseau via le câble Ethernet, sans prise secteur séparée.

| Standard | Puissance max | Usage typique |
|---|---|---|
| PoE (802.3af) | 15,4 W | Téléphones IP, petites caméras IP, AP Wi-Fi basiques |
| PoE+ (802.3at) | 30 W | AP Wi-Fi 6, caméras PTZ, écrans d'affichage |
| PoE++ (802.3bt) | 60–90 W | PC légers, écrans, bornes de recharge, vidéo haute qualité |

> Pour qu'un équipement soit alimenté en PoE : le switch doit être un switch PoE ET l'équipement doit être compatible PoE. Un équipement non-PoE branché sur un port PoE ne sera pas endommagé (le switch détecte la compatibilité avant d'envoyer le courant).

**Le CPL (Courant Porteur en Ligne)**

> 🤖 *Passage ajouté avec l'assistance d'une IA — à relire et vérifier avant usage.*

Le **CPL** transporte le signal réseau **à travers le câblage électrique** existant du bâtiment. On branche un boîtier (adaptateur CPL) sur une prise secteur près de la box, relié en RJ45, et un second boîtier sur une prise dans une autre pièce : les données circulent par le réseau électrique. C'est une solution de **dépannage** quand on ne peut ni tirer de câble Ethernet, ni obtenir un Wi-Fi stable (mur épais, étage éloigné).

| Liaison | Principe | Quand l'utiliser |
|---|---|---|
| **Filaire (Ethernet)** | Câble RJ45 dédié | Référence : tout équipement fixe, débit garanti |
| **CPL** | Données via le réseau électrique | Dépannage quand le câble est impossible et le Wi-Fi insuffisant |
| **PoE** | Alimentation **via** le câble Ethernet | Alimenter caméra/AP/téléphone IP sans prise secteur à proximité |

> **Attention — ne pas confondre PoE et CPL.** Le **PoE** fait passer le *courant* sur un câble *réseau* (Ethernet → alimente l'équipement). Le **CPL** fait l'inverse : il fait passer le *réseau* sur le câblage *électrique* (prise secteur → transporte les données). Limites du CPL : performances variables selon la qualité et l'âge de l'installation électrique, dégradation si les deux prises sont sur des circuits/phases différents, et déconseillé sur multiprise parasurtenseur.

**Ethernet vs Wi-Fi :**

| Caractéristique | Ethernet (Câble) | Wi-Fi (Ondes) |
|---|---|---|
| Débit | Constant et dédié (Full-Duplex) | Partagé entre tous les appareils |
| Latence | Très faible — idéal VoIP, jeux, RDP | Variable — interférences et charge |
| Sécurité | Physique | Ondes dans l'air — plus exposé |
| Mobilité | Nulle | Totale |
| Fiabilité | Très élevée | Dépend de l'environnement |
| Installation | Tirage de câbles | Rapide |
| Usage recommandé | Postes fixes, serveurs, imprimantes | Téléphones, laptops, IoT |

> Règle terrain : pour tout équipement fixe (PC de bureau, imprimante, serveur, caméra fixe, téléphone IP), préférer le câble. Limite des 100 mètres : si l'imprimante est à 120 m → switch intermédiaire ou fibre.

### 2.2 Wi-Fi — Fonctionnement et normes

Né en 1997 avec l'IEEE 802.11 (2 Mb/s). Fonctionne via les ondes hertziennes sur les bandes 2,4 GHz, 5 GHz et 6 GHz.

| Génération | Norme IEEE | Année | Fréquences | Débit max théorique | Nouveauté clé |
|---|---|---|---|---|---|
| Wi-Fi 1 | 802.11b | 1999 | 2,4 GHz | 11 Mb/s | Première démocratisation |
| Wi-Fi 2 | 802.11a | 1999 | 5 GHz | 54 Mb/s | 5 GHz (moins de congestion) |
| Wi-Fi 3 | 802.11g | 2003 | 2,4 GHz | 54 Mb/s | Unification 2,4 GHz |
| Wi-Fi 4 | 802.11n | 2009 | 2,4 + 5 GHz | 600 Mb/s | MIMO (antennes multiples) |
| Wi-Fi 5 | 802.11ac | 2013 | 5 GHz | 3,5 Gb/s | MU-MIMO, beamforming |
| Wi-Fi 6 | 802.11ax | 2019 | 2,4 + 5 GHz | 9,6 Gb/s | OFDMA — gestion dense (IoT, open space) |
| Wi-Fi 6E | 802.11ax | 2021 | 2,4 + 5 + 6 GHz | 9,6 Gb/s | Bande 6 GHz non congestionnée |
| Wi-Fi 7 | 802.11be | 2024 | 2,4 + 5 + 6 GHz | 46 Gb/s max (5–10 Gb/s utiles en réalité) | Multi-Link Operation (plusieurs bandes simultanées) |

**Fréquences et canaux :**

| Fréquence | Portée | Débit max (pratique) | Interférences | Usage recommandé |
|---|---|---|---|---|
| 2,4 GHz | Longue (traverse mieux les murs) | ~300 Mb/s | Nombreuses (micro-ondes, Bluetooth, voisins, 3 canaux) | IoT, appareils éloignés |
| 5 GHz | Courte (s'atténue avec les murs) | ~1,3 Gb/s | Peu denses (25 canaux non-chevauchants) | PC, smartphones, TV proches |
| 6 GHz (Wi-Fi 6E/7) | Très courte | > 2 Gb/s | Quasi inexistantes | Équipements récents, très haut débit |

> Canaux 2,4 GHz : seuls 3 canaux sont non-chevauchants : **1, 6 et 11**. Deux points d'accès voisins sur le même canal se perturbent — principale cause de Wi-Fi lent en immeuble. Conseil : inspecter avec Wi-Fi Analyzer (Android) ou inSSIDer (PC). En environnement dense, passer sur du 5 GHz.

### 2.3 Wi-Fi — Sécurisation

Deux objectifs : **Authentification** (seul l'utilisateur autorisé se connecte) et **Chiffrement** (personne ne peut lire les données qui circulent).

| Protocole | Chiffrement | Statut | Niveau de sécurité |
|---|---|---|---|
| WEP | RC4 (cassé) | Obsolète, à bannir | Nul — se pirate en minutes |
| WPA | TKIP | Obsolète | Faible |
| WPA2 | AES-CCMP + PSK (Pre-Shared Key) | Standard actuel | Bon — le plus répandu en entreprise |
| WPA3 | AES-GCM + SAE (Simultaneous Authentication of Equals) | Recommandé | Excellent — résiste aux attaques par dictionnaire et brute-force offline |

> ⚠️ WEP est cassé depuis 2001. S'il est encore présent en production, c'est une faille de sécurité ouverte.

**Modes d'authentification : Personal vs Enterprise**

| Mode | Fonctionnement | Avantage | Inconvénient | Usage |
|---|---|---|---|---|
| WPA2/WPA3 Personal (PSK) | Un seul mot de passe partagé | Simple à configurer | Si un employé part, changer le mot de passe sur TOUS les appareils | Maison, PME sans AD |
| WPA2/WPA3 Enterprise (802.1X) | Chaque utilisateur se connecte avec son identifiant AD (via serveur RADIUS) | Révocation individuelle | Nécessite un serveur RADIUS + infra AD | Entreprises avec AD — recommandé |

> **Serveur RADIUS** : protocole AAA qui centralise l'authentification des accès réseau en s'appuyant sur Active Directory. Le NAS envoie les credentials au serveur RADIUS (ex : NPS sur Windows Server), qui les vérifie auprès de l'AD et répond Accept ou Reject.

**Bonnes pratiques de sécurisation :**

| Pratique | Description | Priorité |
|---|---|---|
| Utiliser WPA2 ou WPA3 | Ne jamais utiliser WEP ou WPA1 | Critique |
| Désactiver le WPS | Bouton WPS = faille connue (brute-force en quelques heures) | Critique |
| VLANs Wi-Fi dédiés | Réseau Invité isolé, Production séparé | Critique |
| Masquer le SSID | Fausse bonne idée : un scanner détecte le réseau même masqué | Inutile |
| Filtrage MAC | Limite : une MAC se spoofe facilement. Couche complémentaire | Complémentaire |
| Isolation des clients | Empêche les appareils Wi-Fi de communiquer entre eux. Obligatoire pour Wi-Fi Visiteurs | Recommandé |
| Changer le mot de passe admin par défaut | Les identifiants par défaut sont publics en ligne | Critique |

### 2.4 Récapitulatif

**Ethernet** : norme IEEE 802.3 (cuivre RJ45 et fibre) ; Cat 6a = standard recommandé en entreprise ; PoE pour caméras/téléphones IP/AP Wi-Fi ; pour tout équipement fixe, câble > Wi-Fi.

**Wi-Fi** : Wi-Fi 6 (802.11ax) = standard actuel recommandé ; 2,4 GHz portée longue/interférences vs 5 GHz portée courte/moins encombré ; 3 canaux non-chevauchants en 2,4 GHz (1, 6, 11) ; WPA3 > WPA2 > WPA > WEP (à bannir) ; Enterprise (802.1X) = seule vraie solution pro avec AD ; désactiver le WPS ; Réseau Invité = VLAN isolé.

> Règle d'or du terrain : « On câble tout ce qui ne bouge pas, on met en Wi-Fi tout ce qui se déplace. On n'autorise jamais un VoIP ou une caméra de sécurité sur le Wi-Fi si on peut l'éviter. »

## 3. Typologie des réseaux

| Type | Portée | Usage | Technologie |
|---|---|---|---|
| PAN | 1-10 m | Montre connectée, écouteurs | Bluetooth, USB |
| LAN | 100 m - 1 km | Réseau d'entreprise, maison | Wi-Fi, Ethernet |
| MAN | 10-50 km | Plusieurs sites d'une ville | Fibre optique |
| WAN | Illimité | Internet | Satellites, câbles sous-marins |

**Topologies réseau :**

| Topologie | Avantage | Inconvénient | Usage |
|---|---|---|---|
| Étoile | Panne isolée à un seul poste | Si nœud central tombe, tout tombe | Bureaux, foyers (la plus utilisée) |
| Maillée | Ultra-robuste, chemins alternatifs | Très coûteux | Internet, systèmes militaires |
| Hybride | Flexible, adaptable | Complexe | Grandes entreprises, campus |
| Bus | Simple et peu coûteux | Câble central = point unique de défaillance | Obsolète |
| Anneau | Pas de collision | Une panne = tout le réseau tombe | Réseaux industriels anciens |

## 4. Binaire et hexadécimal

| 2⁷ | 2⁶ | 2⁵ | 2⁴ | 2³ | 2² | 2¹ | 2⁰ |
|---|---|---|---|---|---|---|---|
| 128 | 64 | 32 | 16 | 8 | 4 | 2 | 1 |

**Binaire** (base 2). Exemple : 222 par divisions successives par 2 (lire les restes de bas en haut) :
222/2=111(0) → 111/2=55(1) → 55/2=27(1) → 27/2=13(1) → 13/2=6(1) → 6/2=3(0) → 3/2=1(1) → 1/2=0(1)
→ **222 = 1101 1110** (vérification : 128+64+16+8+4+2 = 222).

Méthode décimal → binaire : soustraire successivement les puissances de 2 en partant de 128. Décimal pair → finit par 0 ; impair → finit par 1.

**Hexadécimal** (base 16, symboles 0-9 et A-F). Un octet (8 bits) = 2 caractères hexa. Exemple : 255 (décimal) = **FF** (hexa) car F=15 → 15×16⁰ + 15×16¹ = 15 + 240 = 255.
