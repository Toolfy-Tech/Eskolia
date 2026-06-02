> **Parcours Optimus — Module 4 · Chapitre 3 sur 5**

# OSI, encapsulation et TCP/IP

## 1. Modèle OSI — 7 couches

| Couche | Nom | Rôle | Équipements/Protocoles |
|---|---|---|---|
| 7 | Application | Données à transmettre | HTTP, FTP, DNS, SMTP |
| 6 | Présentation | Mise en forme, chiffrement/déchiffrement | SSL/TLS |
| 5 | Session | Synchroniser la connexion entre deux machines | Rarement isolée (ex. historique : NetBIOS) |
| 4 | Transport | Communication de bout en bout | TCP (fiable) / UDP (rapide). DNS : UDP 53 (requêtes), TCP 53 (transferts de zone / réponses volumineuses) |
| 3 | Réseau | Adressage et routage | IP, Routeur, mécanisme ARP |
| 2 | Liaison des données | Adressage physique | Adresse MAC, Switch |
| 1 | Physique | Transmission des signaux | Câbles (Cat 5e ~1 Gbps, Cat 6/6a ~10 Gbps), Fibre, Wi-Fi |

> Moyen mnémotechnique (1 à 7) : « **P**our **l**e **r**éseau **t**out **s**e **p**asse **a**utomatiquement ».
> Conseil : 50 % des pannes se résolvent en vérifiant la Couche 1 (câble ou alimentation) !

**ARP — Address Resolution Protocol (pont couche 2/3)** : sans ARP, une machine ne peut pas envoyer de paquet sur le réseau local même si elle connaît l'IP. Principe : « Je connais l'IP 192.168.1.50, mais quelle est son adresse MAC ? »

| Étape | Type de trame | Destination | Contenu |
|---|---|---|---|
| 1 | ARP Request | Broadcast `ff:ff:ff:ff:ff:ff` | « Qui a l'IP 192.168.1.50 ? Réponds à aa:bb:cc:dd:ee:ff » |
| 2 | ARP Reply | Unicast vers l'expéditeur | « C'est moi ! Mon adresse MAC est 11:22:33:44:55:66 » |
| 3 | Mise en cache | (local) | IP 192.168.1.50 ↔ MAC 11:22:33:44:55:66 (durée limitée) |

Cache ARP (timeout) : Windows ~2 min, Linux/Cisco ~5 min. Commandes : `arp -a` (Windows), `ip neigh show` (Linux), `show ip arp` (Cisco IOS).

> Si deux machines ont la même IP, leurs ARP Reply se concurrencent → **conflit ARP** → interruptions aléatoires.

**TLS / SSL — Chiffrement des communications** : TLS (Transport Layer Security) chiffre les données entre client et serveur (cadenas du navigateur). SSL est son prédécesseur, abandonné depuis 2015. Versions : TLS 1.2 (répandu, acceptable), TLS 1.3 (actuelle/recommandée), SSL / TLS 1.0 / 1.1 (obsolètes, à désactiver).

Le **handshake TLS** en 4 étapes :
1. Le client annonce les algorithmes de chiffrement qu'il supporte.
2. Le serveur répond et envoie son certificat (preuve d'identité).
3. Le client vérifie le certificat auprès d'une autorité de certification (CA).
4. Une clé de session chiffrée est générée → la communication commence.

> Certificat expiré ou non reconnu → le navigateur bloque avec « Votre connexion n'est pas privée » (problème de couche 6).
> Lien avec les ports : Port 80 → HTTP (non chiffré) ; Port 443 → HTTPS (chiffré via TLS).

## 2. L'encapsulation

Les données sont encapsulées de la couche 7 vers la couche 1 : on ajoute un en-tête à chaque couche (comme une lettre dans une enveloppe).

| Couche | Analogie postale |
|---|---|
| Application | Tu écris ton message (la donnée) |
| Transport | Tu mets la lettre dans une enveloppe (TCP = recommandé, UDP = simple) |
| Réseau | Tu écris les adresses IP expéditeur/destinataire |
| Accès Réseau | La lettre est mise dans le camion (câble ou Wi-Fi) |

Dépannage : « plus d'internet » → vérifier le câble (couche 1), puis les paramètres réseau (couche 3), puis l'application (couche 7).

## 3. Le modèle TCP/IP — 4 couches

| Couche | Rôle | Protocoles |
|---|---|---|
| 4 - Application | Interface utilisateur, prépare les données | HTTP, FTP, SMTP, DNS |
| 3 - Transport | Communication bout en bout, vérification | TCP (fiable) / UDP (rapide) |
| 2 - Réseau (Internet) | Adresse et route les paquets | IP (IPv4/IPv6), ICMP (Ping) |
| 1 - Liaison (Accès réseau) | Transforme les données en signaux physiques | Ethernet, Wi-Fi (802.11), Fibre |

## 4. Notion de port — Identification des applications

L'adresse IP identifie une machine ; le **numéro de port** distingue quel service est concerné. **IP + Port = Socket** (ex : `192.168.1.10:443` = machine + service HTTPS).

- Ports 0-1023 : ports bien connus (HTTP=80, HTTPS=443, SSH=22).
- Ports 1024-49151 : ports enregistrés (RDP=3389, ERP custom...).
- Ports 49152-65535 : ports dynamiques/éphémères (côté client).

| Protocole | Port(s) | Description | TCP / UDP |
|---|---|---|---|
| HTTP | 80 | Navigation web non sécurisée | TCP |
| HTTPS | 443 | Navigation web sécurisée (TLS) | TCP |
| DNS | 53 | Résolution de noms | UDP (requêtes) / TCP (transferts) |
| DHCP | 67/68 | Attribution automatique des IP | UDP |
| SSH | 22 | Connexion à distance sécurisée | TCP |
| FTP | 20-21 | Transfert de fichiers | TCP |
| SFTP | 22 | FTP sécurisé (via SSH) | TCP |
| RDP | 3389 | Bureau à distance Windows | TCP |
| SMTP | 25 | Envoi d'emails | TCP |
| POP3 | 110 | Réception d'emails (téléchargement) | TCP |
| IMAP | 143 | Réception d'emails (synchronisation) | TCP |
| SNMP | 161 | Supervision et monitoring réseau | UDP |

**TCP vs UDP :**

| Caractéristique | TCP | UDP |
|---|---|---|
| Fiabilité | Très élevée (accusés de réception) | Faible (pas de vérification) |
| Vitesse | Plus lent | Très rapide |
| Ordre des paquets | Garanti | Non garanti |
| Analogie | Lettre recommandée | Mégaphone dans la rue |
| Exemple d'usage | Téléchargement, web, RDP | Streaming, jeux en ligne, VoIP |

## 4 (bis). Le modèle OSI — Application terrain (cas Aérotec)

**Contexte** : Sonia, admin réseau chez Aérotec (200 postes), reçoit une alerte : l'ERP est inaccessible depuis tous les postes de l'atelier. Méthode : le modèle OSI couche par couche, de bas en haut (**bottom-up**). Règle d'or : « On ne saute jamais une marche. »

| Couche | Nom | Commande clé (Cisco) | Ce qu'on vérifie |
|---|---|---|---|
| 1 | Physique | `show interfaces status`, `show interface Gi0/3` | Ports connectés, vitesse, compteurs CRC/erreurs |
| 2 | Liaison | `show mac address-table`, `show cdp neighbors` | MAC apprises, topologie voisins, erreurs L2 |
| 3 | Réseau | `show ip interface brief`, `ping <IP>`, `show ip route`, `show ip arp` | Interfaces UP/DOWN, joignabilité IP, routes, ARP |
| 4 | Transport | `telnet <IP> <PORT>`, `netstat -an` | Port TCP ouvert/fermé, service en écoute |
| 5-6-7 | Session / Présent. / App. | Test applicatif direct | L'application répond-elle ? |

**Déroulé** : Couche 1 (zéro erreur CRC) ✅, Couche 2 (MAC apprises, voisins visibles) ✅, Couche 3 (routage OK, ping 5/5) ✅… et pourtant l'ERP reste inaccessible. La couche 4 révèle le problème : `telnet 10.10.50.10 8080` → Connection refused. `netstat -an | findstr LISTENING` montre que l'ERP écoute sur **9090** (pas 8080).

**Cause** : une mise à jour de l'ERP a changé le port par défaut 8080 → 9090. Le pare-feu autorisait toujours TCP/8080 mais bloquait TCP/9090. **Résolution** (pare-feu Cisco) : ouvrir le port 9090, fermer l'ancien 8080.

```
Routeur(config)# access-list 101 permit tcp 10.10.20.0 0.0.0.255 host 10.10.50.10 eq 9090
Routeur(config)# no access-list 101 permit tcp 10.10.20.0 0.0.0.255 host 10.10.50.10 eq 8080
```

**Pourquoi les couches 5, 6, 7 ne sont pas diagnostiquées séparément** : sur le terrain, elles sont quasiment toujours fusionnées dans les protocoles modernes (ex. HTTPS gère session + chiffrement TLS + HTTP). Les couches 1 à 4 se diagnostiquent une par une ; les couches 5-6-7 se vérifient ensemble en testant l'application.

**La Couche 8 — L'Interface Chaise-Clavier (ICC)** : erreur humaine entre l'utilisateur et la machine. Aucun protocole, pare-feu ou MAJ ne peut la corriger. Statistiquement, elle génère le plus grand nombre de tickets. Avant tout diagnostic OSI, vérifier l'évidence physique (câble branché ?).

> Morale : « Un réseau qui tombe, c'est rarement un drame, c'est un puzzle. Le modèle OSI, c'est la boîte qui contient toutes les pièces rangées par catégorie. »
