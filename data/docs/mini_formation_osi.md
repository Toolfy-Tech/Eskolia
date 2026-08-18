# Mini-formation — Modèle OSI & Réseaux Informatiques

## 1. Qu'est-ce que le Modèle OSI ?
Le **Modèle OSI (Open Systems Interconnection)** est une norme internationale (ISO/IEC 7498-1) structurée en **7 couches distinctes**. Il standardise les fonctions de communication réseau pour permettre l'interopérabilité entre matériels et logiciels de constructeurs hétérogènes.

---

## 2. Tableau Complet des 7 Couches & PDU

| N° | Couche | Nom Anglais | PDU (Unité) | Rôle Opérationnel | Protocoles & Matériels Clés |
|---|---|---|---|---|---|
| **7** | **Application** | Application | Données | Point d'entrée utilisateur & services réseau | HTTP, HTTPS, DNS, DHCP, SSH, FTP, SMTP, RDP |
| **6** | **Présentation** | Presentation | Données | Formatage, encodage, compression & chiffrement | TLS / SSL, JSON, XML, JPEG, PNG, ASCII, UTF-8 |
| **5** | **Session** | Session | Données | Ouverture, maintien et clôture des dialogues | NetBIOS, RPC, PPTP, NFS, Named Pipes |
| **4** | **Transport** | Transport | Segment / Datagramme | Découpage, contrôle de flux et fiabilité de bout en bout | TCP (fiable / 3-way handshake), UDP (rapide), Ports 1-65535 |
| **3** | **Réseau** | Network | Paquet | Adressage logique global & routage inter-réseaux | IPv4, IPv6, ICMP (Ping), IGMP, IPsec, Routeurs, Switchs L3 |
| **2** | **Liaison** | Data Link | Trame | Adressage physique local & contrôle d'accès au média | Ethernet (802.3), Wi-Fi (802.11), Switchs L2, Adresses MAC, VLAN (802.1Q), ARP |
| **1** | **Physique** | Physical | Bit | Transmission des signaux bruts sur le support | Câbles RJ45 (Cat 6/6a), Fibre optique (Monmode/Multimode), Hubs, Répéteurs, SFP |

---

## 3. Le Mécanisme d'Encapsulation & Décapsulation
- **Émission (Couche 7 ➔ Couche 1)** :
  1. L'application génère les **Données** brutes (L7-L5).
  2. La couche Transport ajoute un en-tête avec les ports source/destination ➔ **Segment** (L4).
  3. La couche Réseau ajoute un en-tête avec les adresses IP source/destination ➔ **Paquet** (L3).
  4. La couche Liaison ajoute l'en-tête MAC et le code de contrôle FCS (CRC) ➔ **Trame** (L2).
  5. La couche Physique convertit la trame en impulsions électriques, optiques ou radio ➔ **Bits** (L1).
- **Réception (Couche 1 ➔ Couche 7)** : Le processus inverse (décapsulation) retire successivement chaque en-tête à chaque couche.

---

## 4. Comparatif Stratégique : TCP vs UDP (Couche 4)

| Caractéristique | TCP (Transmission Control Protocol) | UDP (User Datagram Protocol) |
|---|---|---|
| **Mode de connexion** | Orienté connexion (**SYN ➔ SYN-ACK ➔ ACK**) | Sans connexion (envoi direct sans négociation) |
| **Fiabilité** | 100% garanti (acquittements ACK, retransmission des pertes) | Non garanti (aucune retransmission, *Best Effort*) |
| **Ordre des données** | Respect strict de l'ordre d'envoi (numéros de séquence) | Aucun ordonnancement garanti |
| **Contrôle de flux & congestion** | Oui (fenêtre glissante / *Sliding Window*) | Non (vitesse maximale sans régulation) |
| **Usage typique** | Web (HTTPS), Transfert de fichiers (SFTP), Mails (IMAP), Terminal (SSH) | Streaming vidéo/audio, Jeux en ligne, DNS, DHCP, VoIP |

---

## 5. Correspondance avec le Modèle TCP/IP (4 couches)
- **Application (TCP/IP)** = Couches 7 (Application) + 6 (Présentation) + 5 (Session)
- **Transport (TCP/IP)** = Couche 4 (Transport)
- **Internet (TCP/IP)** = Couche 3 (Réseau)
- **Accès Réseau (TCP/IP)** = Couches 2 (Liaison) + 1 (Physique)

---

## 6. Diagnostic & Commandes Utiles pour le Technicien
- `ping <IP/domaine>` : Teste la couche 3 (connectivité IP via messages ICMP Echo Request/Reply).
- `tracert <IP>` (Windows) / `traceroute` (Linux) : Identifie chaque saut de routeur sur le chemin.
- `nslookup <domaine>` : Interroge les serveurs DNS (couche 7) pour résoudre un nom en IP.
- `ipconfig /all` : Affiche l'adresse IP (L3), le masque, la passerelle par défaut, le serveur DNS et l'adresse MAC (L2).
- `arp -a` : Affiche la table de correspondance IP ➔ MAC locale.
- `netstat -ano` : Liste les ports ouverts et connexions actives (L4) avec leur PID associé.
- `wireshark` : Analyseur de paquets permettant d'inspecter chaque trame, paquet et segment en temps réel.

---

## 7. Ateliers Pratiques Disponibles dans Eskolia
Rendez-vous dans la section **TP & Labs ➔ Modèle OSI** pour vous entraîner sur nos 3 simulateurs immersifs :
1. ⚡ **Le Tri Sélectif** : Glissez-déposez les protocoles sur les 7 couches en mode Série ou Survie.
2. 📦 **Le Voyage du Paquet** : Assemblez et décortiquez la structure du paquet de données sans spoiler.
3. 🔍 **L'Enquêteur OSI** : Résolvez des tickets d'incidents réels en isolant la couche en cause et l'action corrective.
4. 📖 **Mémento OSI** : Guide de révision interactif accessible à tout moment.

---
*Référence : Norme ISO/IEC 7498-1 et RFCs IETF.*
