> **Parcours Optimus** — **Module 3** · Chapitre 3 sur 5 · *OSI, encapsulation et TCP/IP*.
>
> Contenu issu du cours Optimus (PDF) ; tableaux extraits du PDF ; illustrations sous `curriculum/optimus/images/`.
Partie 3 : Comment tout communique (OSI, encapsulation, TCP/IP)
1. Modèle OSI — 7 couches
|**Couche**|**Nom**|**Rôle**|**Équipements/Protocoles**|
|---|---|---|---|
|7|Application|Données à transmettre|HTTP, FTP, DNS, SMTP|
|6|Présentation|Mise en forme, chiffrement/déchiffrement|SSL/TLS|
![Image 19](../images/image_019.png)
|5|Session|Synchroniser la connexion entre deux machines|La couche session est rarement isolée. Exemple historique : NetBIOS (peu utilisé aujourd’hui)|
|4|Transport|Communication de bout en bout|TCP (fiable) / UDP (rapide). DNS utilise principalement UDP 53, et TCP 53 pour les transferts de zone ou réponses volumineuses.|
|3|Réseau|Adressage et routage|IP, routeur. ARP fait le pont entre IP (couche 3) et MAC (couche 2). Commande : `arp -a` (Windows) ou `show ip arp` (Cisco).|
|2|Liaison des données|Adressage physique|Adresse MAC, Switch|
|1|Physique|Transmission des signaux|Câbles (**Cat 5e :** Jusqu'à 1 Gbps.**Cat 6 / 6a :** Jusqu'à 10 Gbps (le standard actuel en entreprise).**Fibre Optique :** Pour les liaisons longue distance ou entre switchs, Wi-Fi|
Moyen mnémotechnique (de 1 à 7) : « Pour le réseau tout se passe automatiquement »
Conseil : 50% des pannes se résolvent en vérifiant la Couche 1 (le câble ou l'alimentation) !
- ARP — Mécanisme détaillé (Liaison Couche 2 / Couche 3) : ARP (Address
Resolution Protocol) est le pont entre l'adresse IP (couche 3) et l'adresse MAC (couche 2). Sans
ARP, une machine ne peut pas envoyer de paquet sur le réseau local, même si elle connaît l'IP de
destination.
 Principe : "Je connais l'IP 192.168.1.50, mais quelle est son adresse MAC ?"
 Déroulement complet :
|**Étape**|**Type de trame**|**Destination**|**Contenu**|
|---|---|---|---|
|1 — ARP Request|Broadcast|ff:ff:ff:ff:ff:ff (toutes les machines du réseau)|"Qui a l'IP 192.168.1.50 ? Réponds à aa:bb:cc:dd:ee:ff"|
|2 — ARP Reply|Unicast|Directement vers l'expéditeur|"C'est moi ! Mon adresse MAC est 11:22:33:44:55:66"|
|3 — Mise en cache|Local|Table ARP locale de l'expéditeur|IP 192.168.1.50 ↔ MAC 11:22:33:44:55:66 (durée limitée)|
Cache ARP : après résolution, l'association IP ↔ MAC est stockée temporairement en mémoire pour
éviter de répéter la requête broadcast à chaque paquet. Ce cache a un délai d'expiration (timeout) :
- Windows : ~2 minutes par défaut
- Linux/Cisco : ~5 minutes par défaut
- Après expiration, une nouvelle ARP Request est émise si la communication reprend
Commande de consultation :
arp -a (Windows)
ip neigh show (Linux)
show ip arp (Cisco IOS)
💡 Si deux machines ont la même IP sur un réseau, leurs ARP Reply se concurrencent → conflit ARP
→ interruptions aléatoires. C'est un piège classique lors de la mise en production d'un nouveau
serveur.
- TLS / SSL — Le chiffrement des communications : Définition TLS (Transport Layer Security)
est le protocole qui chiffre les données échangées entre un client et un serveur. C'est lui qui affiche
le cadenas dans le navigateur. SSL est son prédécesseur — il est abandonné depuis 2015 et ne
doit plus être utilisé. Quand on dit encore "SSL" dans le langage courant, on parle en réalité de
TLS. Versions : TLS 1.2 → encore très répandu, acceptable / TLS 1.3 → version actuelle /
recommandée, plus rapide et plus sécurisée / SSL / TLS 1.0 / TLS 1.1 → obsolètes, à désactiver
Le handshake TLS — Comment ça fonctionne Avant d'échanger la moindre donnée, le client et le
serveur négocient en 4 étapes :
- Le client dit : "Bonjour, voici les algorithmes de chiffrement que je supporte"
- Le serveur répond et envoie son certificat (preuve de son identité)
- Le client vérifie le certificat auprès d'une autorité de certification (CA)
- Une clé de session chiffrée est générée → la communication peut commencer
Si le certificat est expiré ou non reconnu → le navigateur bloque l'accès avec une erreur "Votre
connexion n'est pas privée". C'est la couche 6 qui signale le problème.
Lien avec les ports : Port 80 → HTTP (non chiffré) Port 443 → HTTPS (chiffré via TLS)
Sur le terrain Un certificat TLS expiré = les utilisateurs ne peuvent plus accéder à l'application → ticket de
support. Première chose à vérifier : date d'expiration du certificat (dans le navigateur : cliquer sur le
cadenas → Certificat → Date de validité).
- DNS et UDP/TCP : DNS utilise principalement l'UDP 53 (rapide pour les requêtes). Il utilise TCP 53
pour les transferts de zone ou quand la réponse est trop volumineuse.
## 2. L'encapsulation

Les données sont encapsulées de la couche 7 vers la couche 1 : on ajoute un en-tête à chaque couche
(comme une lettre dans une enveloppe).
|**Couche**|**Analogie postale**|
|---|---|
|Application|Tu écris ton message (la donnée)|
|Transport|Tu mets la lettre dans une enveloppe (TCP = recommandé, UDP = simple)|
|Réseau|Tu écris les adresses IP expéditeur/destinataire|
|Accès Réseau|La lettre est mise dans le camion (câble ou Wi-Fi)|
Utilisation pour le dépannage : Je n'ai plus internet → je commence par vérifier le câble (couche 1), puis les
paramètres réseau (couche 3), puis l'application (couche 7).
## 3. Le modèle TCP/IP — 4 couches

Le Modèle TCP/IP est un modèle réseau en 4 couches qui décrit comment les données sont transmises
sur Internet à l’aide de protocoles comme TCP et IP.
|**Couche**|**Rôle**|**Protocoles**|
|---|---|---|
|4 - Application|Interface avec l'utilisateur, prépare les données|HTTP, FTP, SMTP, DNS|
|3 - Transport|Communication bout en bout, vérification des données|TCP (fiable) / UDP (rapide)|
|2 - Réseau (Internet)|Adresse et route les paquets entre réseaux|IP (IPv4/IPv6), ICMP (Ping)|
|---|---|---|
|1 - Liaison (Accès réseau)|Transforme les données en signaux physiques|Ethernet, Wi-Fi (802.11), Fibre|
4. Notion de port — Identification des applications
L'adresse IP identifie une machine sur le réseau. Mais une machine fait tourner plusieurs services
en même temps (serveur web, messagerie, DNS…). Le numéro de port permet de distinguer quel
service est concerné par un paquet.
Combinaison clé : IP + Port = Socket. C'est le couple qui identifie de façon unique une
communication réseau.
Exemple : 192.168.1.10:443 = machine 192.168.1.10, service HTTPS (port 443)
- Ports 0-1023 : ports bien connus (réservés aux services standards comme HTTP=80,
HTTPS=443, SSH=22)
- Ports 1024-49151 : ports enregistrés (applications spécifiques comme RDP=3389, ERP
custom...)
- Ports 49152-65535 : ports dynamiques/éphémères (utilisés par le client pour établir une
connexion)
|**Protocole**|**Port(s)**|**Description**|**TCP ou UDP ?**|
|---|---|---|---|
|HTTP|80|Navigation web non sécurisée|TCP|
|HTTPS|443|Navigation web sécurisée (TLS)|TCP|
|DNS|53|Résolution de noms|UDP (requêtes) / TCP (transferts)|
|DHCP|67/68|Attribution automatique des IP|UDP|
|SSH|22|Connexion à distance sécurisée|TCP|
|FTP|20-21|Transfert de fichiers|TCP|
|SFTP|22|FTP sécurisé (via SSH)|TCP|
|RDP|3389|Bureau à distance Windows|TCP|
|SMTP|25|Envoi d'emails|TCP|
|POP3|110|Réception d'emails (téléchargement)|TCP|
|IMAP|143|Réception d'emails (synchronisation)|TCP|
|SNMP|161|Supervision et monitoring réseau|UDP|
TCP vs UDP — Comparatif
|**Caractéristique**|**TCP**|**UDP**|
|---|---|---|
|Fiabilité|Très élevée (accusés de réception)|Faible (pas de vérification)|
|Vitesse|Plus lent|Très rapide|
|Ordre des paquets|Garanti (1, 2, 3...)|Non garanti (ordre non assuré)|
|Analogie|Lettre recommandée|Mégaphone dans la rue|
|---|---|---|
|Exemple d'usage|Téléchargement, navigation web, RDP|Streaming, jeux en ligne, VoIP|
4. Le Modèle OSI — Application terrain
### 4.1. Mise en situation — L'ERP inaccessible chez Aérotec

🔷 Contexte (vidéo Formip)
Sonia, admin réseau chez Aérotec Industrie (200 postes, usine aéronautique), reçoit une alerte : l'ERP
est inaccessible depuis tous les postes de l'atelier. Les opérateurs ne peuvent plus scanner les pièces.
La chaîne de production est à l'arrêt. Sa méthode : le modèle OSI couche par couche, de bas en haut.
💡 La règle d'or de Sonia
« On ne saute jamais une marche. Tu commences en bas, tu vérifies, tu élimines, tu montes. »
### 4.2. La méthode Bottom-Up — OSI comme plan d'enquête

Le modèle OSI n'est pas qu'un schéma à apprendre par cœur : c'est un plan d'enquête structuré. Chaque
couche est un étage à inspecter. On commence toujours par le bas (le câble) et on remonte vers
l'application.
- **Couche** | **Nom** | **Commande clé** | **Ce qu'on vérifie**
- **Couche** | **Nom** | **(Cisco)**
- **1** | **Physique** | `show interfaces` | Ports connectés, vitesse, compteurs CRC/erreurs
- **1** | **Physique** | `status`
- **1** | **Physique** | `show interface Gi0/3`
- **2** | **Liaison** | `show mac address-` | Adresses MAC apprises, topologie voisins, erreurs L2
- **2** | **Liaison** | `table`
- **2** | **Liaison** | `show cdp neighbors`
- **3** | **Réseau** | `show ip interface` | Interfaces UP/DOWN, joignabilité IP, routes, résolution ARP
- **3** | **Réseau** | `brief`
- **3** | **Réseau** | `ping <IP>`
- **3** | **Réseau** | `show ip route`
- **3** | **Réseau** | `show ip arp`
- **4** | **Transport** | `telnet <IP> <PORT>` `netstat -an` | Port TCP ouvert ou fermé, service en
- **4** | **Transport** | `telnet <IP> <PORT>` `netstat -an` | écoute
- **5-6-7** | **Session /** | `Test applicatif` `direct` | Vérification groupée : l'application
- **5-6-7** | **Présent. / App.** | répond-elle ?
### 4.3. Déroulé du diagnostic — Couche par couche

Couche 1 — Physique
Première vérification : les ports sont-ils physiquement connectés ? Y a-t-il des erreurs de signal ?
SW-Atelier# show interfaces status
Port Status Speed Duplex VLAN
Gi0/1 connected 1000 full 20
...
SW-Atelier# show interface GigabitEthernet 0/3
→ 0 CRC errors, 0 runts, 0 giants ← Signal propre
Résultat : tous les ports sont connectés, zéro erreur CRC. Couche 1 ✅ éliminée.
🔷 Note sur les erreurs CRC
## 47. erreurs CRC détectées sur le lien montant (uplink) depuis le dernier reset des compteurs.

Non critique sur plusieurs semaines, mais signe d'un câble vieillissant. À surveiller.
Couche 2 — Liaison des données
Vérification que le switch reconnaît bien les machines et que la topologie est conforme.
SW-Atelier# show mac address-table
→ Adresses MAC des postes atelier présentes, bon port, bon VLAN
SW-Atelier# show cdp neighbors
→ Switch de distribution visible sur Gi0/48
→ Switch bureau d'études visible sur Gi0/47
 Topologie conforme au schéma réseau.
Résultat : trames circulantes, MACs apprises, voisins visibles. Couche 2 ✅ éliminée.
Couche 3 — Réseau
L'atelier (10.10.20.0/24) et le serveur ERP (10.10.50.0/24) sont sur des réseaux différents : les paquets
passent obligatoirement par le routeur.
Routeur# show ip interface brief
GigabitEthernet0/0 10.10.20.1 UP/UP ← vers atelier
GigabitEthernet0/1 10.10.50.1 UP/UP ← vers serveurs
Routeur# ping 10.10.50.10
!!!!! → 5/5 reçus. Routeur atteint le serveur ERP.
Routeur# show ip route
C 10.10.20.0/24 via Gi0/0 ← réseau atelier
C 10.10.50.0/24 via Gi0/1 ← réseau serveurs
Routeur# show ip arp
10.10.50.10 → aa:bb:cc:dd:ee:ff ← résolution ARP OK
Résultat : routage fonctionnel, ARP résolu, ping depuis les postes atelier = 4/4. Couche 3 ✅ éliminée.
💡 Et pourtant…
Câble OK. Trames OK. Paquets OK. Mais l'ERP reste inaccessible. Le problème est plus haut.
Couche 4 — Transport (TCP/UDP)
Un ping fonctionne → Couche 3 OK. Mais le ping utilise ICMP, pas TCP. L'ERP communique en TCP sur
un port précis. C'est ce port qu'il faut tester.
Poste-Atelier> telnet 10.10.50.10 8080
→ Connection refused ← Le port 8080 ne répond pas
# Sur le serveur ERP (Windows Server) :
C:\> netstat -an | findstr 8080
→ (aucun résultat) ← 8080 n'est PAS en écoute
C:\> netstat -an | findstr LISTENING
→ 0.0.0.0:9090 LISTENING ← L'ERP écoute sur 9090 !
🔷 Cause identifiée
Une mise à jour de l'ERP déployée le samedi soir a changé le port par défaut : 8080 → 9090.
La note de version le mentionnait en page 14. Personne n'avait lu. Personne n'avait prévenu l'équipe réseau.
Résultat : le pare-feu autorisait toujours le TCP/8080, mais bloquait le TCP/9090 (jamais ajouté en liste blanche).
### 4.4. Résolution — Pare-feu Cisco

Deux actions : ouvrir le nouveau port 9090, fermer l'ancien port 8080 devenu inutile (une porte ouverte
inutilement = un risque de sécurité).
Routeur# configure terminal
! Autoriser TCP depuis l'atelier vers l'ERP sur le nouveau port
Routeur(config)# access-list 101 permit tcp 10.10.20.0 0.0.0.255 host 10.10.50.10 eq 9090
! Supprimer l'ancienne règle devenue obsolète
Routeur(config)# no access-list 101 permit tcp 10.10.20.0 0.0.0.255 host 10.10.50.10 eq 8080
! Vérifier
Routeur# show access-list 101
→ permit tcp ... eq 9090 ✓
→ (eq 8080 disparaît) ✓
Poste-Atelier> telnet 10.10.50.10 9090
→ Connexion établie. Handshake TCP OK. ERP accessible.
⏱ Durée totale du diagnostic : 25 minutes. Couche 1 → Couche 4. Sans paniquer, sans tirer dans le
tas.
### 4.5. Pourquoi les couches 5, 6 et 7 n'ont pas été diagnostiquées séparément

Dans la théorie, les 7 couches OSI sont distinctes. Sur le terrain, les couches 5, 6 et 7 sont quasiment
toujours fusionnées dans les protocoles modernes (ex. HTTPS gère session + chiffrement TLS + HTTP
ensemble).
- **Couche** | **Nom** | **Réalité terrain**
- **5** | **Session** | Gère l'ouverture/fermeture des sessions. Pas de
- **5** | **Session** | commande isolée — on le détecte en testant
- **5** | **Session** | l'application.
- **6** | **Présentation** | Chiffrement SSL/TLS, encodage. Vérifié globalement
- **6** | **Présentation** | (ex. certificat expiré → erreur à l'ouverture de l'appli).
- **7** | **Application** | L'interface utilisateur. Si TCP (C4) passe → on teste
- **7** | **Application** | directement l'appli. Les 3 couches se valident d'un
- **7** | **Application** | coup.
💡 Règle pratique
Les couches 1 à 4 se diagnostiquent une par une avec des commandes précises. Les couches 5, 6 et 7 se vérifient
ensemble en testant l'application. Ce n'est pas un raccourci — c'est ainsi que fonctionnent les réseaux modernes.
### 4.6. La Couche 8 — L'interface chaise-clavier (ICC)

Même jour, second ticket : M. Duran (comptabilité) n'a plus de réseau du tout. Plus de ping, plus rien. Marc
a déjà vérifié à distance — sans succès.
Sonia se déplace. Constat en 8 secondes : le câble RJ45 est débranché. M. Duran avait déplacé des
bureaux vendredi soir pour un pot de départ et le câble avait sauté. Il n'avait pas vérifié.
- **Couche 8** | **Définition**
- **Interface Chaise-** **Clavier (ICC)** | Erreur humaine entre l'utilisateur et la machine. Aucun protocole ne peut la
- **Interface Chaise-** **Clavier (ICC)** | corriger, aucun pare-feu ne peut la filtrer, aucune mise à jour ne peut la
- **Interface Chaise-** **Clavier (ICC)** | patcher.
Temps de diagnostic : 8 secondes. Temps de résolution : 1 seconde.
🔷 Statistique terrain
Statistiquement, la couche 8 génère le plus grand nombre de tickets en entreprise.
La bonne pratique : avant de lancer un diagnostic OSI complet, vérifier l'évidence physique (câble branché ?).
→ C'est d'ailleurs pourquoi le conseil du cours reste valide : 50% des pannes = couche 1.
### 4.7. Récapitulatif — Ce qu'il faut retenir

- Le modèle OSI est un outil de diagnostic, pas juste un schéma théorique
- Méthode bottom-up : couche 1 → couche 7, sans sauter d'étape
- Quand une couche basse est en panne, toutes les couches au-dessus sont impactées (effet
domino)
- Un ping qui fonctionne prouve la couche 3, PAS la couche 4 (ping = ICMP, pas TCP)
- Tester un port TCP : telnet <IP> <PORT> ou netstat -an sur le serveur
- Les couches 5, 6, 7 se valident ensemble en testant directement l'application
- La couche 8 (erreur humaine) est souvent la première cause à éliminer physiquement
💡 Morale de l'histoire (Sonia)
« Un réseau qui tombe, c'est rarement un drame, c'est un puzzle. Et le modèle OSI, c'est la boîte qui contient toutes
les pièces rangées par catégorie. Tu n'y cherches pas au hasard — tu ouvres le bon tiroir. »
## 5. Les VLANs : segmentation logique des réseaux

### 5.1. Mise en situation — Le cas AéroSud
Contexte (vidéo Formip) : Nadia, admin réseau chez AéroSud (fabricant aéronautique, 120 employés, 4
étages), arrive un lundi matin et reçoit un appel urgent du DAF : un stagiaire du marketing vient de tomber
sur les fiches de paie de toute l'entreprise. Le coupable ? Un réseau non segmenté depuis 3 ans.
Le diagnostic de Nadia est immédiat. Elle se connecte en SSH sur le switch principal et tape :
AeroSud-SW1# show vlan brief
VLAN Name Status Ports
---- --------- ------ ------
1. default active Fa0/1, Fa0/2 ... Fa0/48
→ 48 ports. Tous dans le VLAN 1 (VLAN d'usine). Aucune segmentation.
Ce résultat révèle un réseau "plat" : un seul domaine de broadcast, aucun cloisonnement entre la
comptabilité, la R&D, le marketing, la direction et le showroom.
Deuxième appel dans la matinée : les caisses du showroom tombent. Un technicien R&D est en train de
transférer 40 Go entre deux serveurs — son trafic sature tout le réseau, caisses incluses.
 Problème fondamental
Un réseau plat = tout le monde voit tout le monde, tout le monde subit le trafic de tout le monde. Ça «
marche » jusqu'au jour où ça explose.
