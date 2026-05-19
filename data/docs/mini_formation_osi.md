# Mini-formation — Modèle OSI

## Qu'est-ce que le modèle OSI ?

Le modèle OSI (Open Systems Interconnection) est un cadre conceptuel en **7 couches** qui standardise les fonctions d'un système de communication réseau. Il facilite l'interopérabilité entre équipements et protocoles de différents fabricants.

---

## Les 7 couches (de bas en haut)

| # | Couche | Rôle | Exemples de protocoles/équipements |
|---|---|---|---|
| 7 | **Application** | Interface avec les applications utilisateur | HTTP, HTTPS, FTP, SMTP, DNS, SSH |
| 6 | **Présentation** | Encodage, chiffrement, compression | TLS/SSL, JPEG, ASCII, UTF-8 |
| 5 | **Session** | Gestion des sessions et dialogues | NetBIOS, RPC, PPTP |
| 4 | **Transport** | Fiabilité, contrôle de flux, segmentation | TCP, UDP |
| 3 | **Réseau** | Adressage logique et routage | IP, ICMP, ARP, routeurs |
| 2 | **Liaison de données** | Adressage physique (MAC), détection d'erreurs | Ethernet, Wi-Fi, switches |
| 1 | **Physique** | Transmission des bits sur le support | Câbles RJ45, fibre, hubs |

**Moyen mnémotechnique (haut → bas)** : *"Ah ! Pour Sauvegarder Tu Résoudras Les Problèmes"*

---

## Encapsulation des données

Quand une donnée descend les couches :
- Couche 7–5 : **données**
- Couche 4 : **segment** (TCP) ou **datagramme** (UDP)
- Couche 3 : **paquet** (ajout de l'en-tête IP)
- Couche 2 : **trame** (ajout de l'en-tête Ethernet + adresse MAC)
- Couche 1 : **bits** (signal électrique, lumineux ou radio)

À la réception, le processus est inversé (désencapsulation).

---

## TCP vs UDP (couche 4)

| Critère | TCP | UDP |
|---|---|---|
| Connexion | Orienté connexion (3-way handshake) | Sans connexion |
| Fiabilité | Garanti (acquittements) | Non garanti |
| Ordre | Ordonné | Non garanti |
| Vitesse | Plus lent | Plus rapide |
| Usage | HTTP, FTP, SSH | DNS, streaming, VoIP |

---

## Modèle TCP/IP vs OSI

Le modèle TCP/IP (plus courant en pratique) regroupe les couches OSI :

| TCP/IP | Couches OSI correspondantes |
|---|---|
| Application | 5 + 6 + 7 |
| Transport | 4 |
| Internet | 3 |
| Accès réseau | 1 + 2 |

---

## Points clés pour un technicien

- **Ping** utilise ICMP (couche 3) — teste la connectivité réseau.
- **Switch** opère en couche 2 (adresses MAC), **routeur** en couche 3 (adresses IP).
- **Firewall** peut opérer en couche 3, 4 ou 7 (pare-feu applicatif / proxy).
- **Wireshark** capture les trames à partir de la couche 2.
- **VLAN** = segmentation logique au niveau couche 2.

---

*Référence : IEEE 802, RFC 791 (IPv4), RFC 793 (TCP)*
