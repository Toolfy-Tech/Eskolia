import 'package:flutter/material.dart';
import '../models/osi_layer_model.dart';

abstract final class OsiLayersData {
  OsiLayersData._();

  static const List<OsiLayerModel> layers = [
    // --- COUCHE 7 : APPLICATION ---
    OsiLayerModel(
      number: 7,
      name: 'Application',
      englishName: 'Application',
      pdu: 'Données (Data)',
      role: 'Interface directe entre l\'utilisateur/logiciel et le réseau.',
      keyProtocols: [
        'HTTP / HTTPS (Web - ports 80 / 443)',
        'DNS (Résolution de noms de domaine - port 53)',
        'DHCP (Attribution auto d\'adresses IP - ports 67/68)',
        'SSH (Administration sécurisée - port 22)',
        'SMTP (Envoi d\'e-mails - port 25/587)',
        'IMAP / POP3 (Réception d\'e-mails - ports 993/995)',
        'FTP / SFTP (Transfert de fichiers - ports 21/22)',
        'SNMP (Supervision d\'équipements - port 161)',
      ],
      keyHardware: [
        'Logiciels clients (Chrome, Outlook, FileZilla)',
        'Serveurs d\'applications (Apache, Nginx, BIND DNS, Windows AD DS)',
        'Passerelles applicatives (Reverse Proxy, WAF)',
      ],
      accentColor: Color(0xFFEC4899), // Rose Néon
      mnemonicHint: 'A — Après (Tous les pros savent programmer)',
      analogy: '📝 Le contenu du message : Vous écrivez une lettre dans votre logiciel de messagerie ou tapez une URL dans votre navigateur. C\'est ce qui a du sens directement pour l\'humain.',
      concreteExplanation: 'La couche Application ne représente pas les applications elles-mêmes (comme Word ou Chrome), mais les protocoles standardisés que ces logiciels utilisent pour dialoguer à travers le réseau. Par exemple, quand votre navigateur demande une page web, il dialogue en protocole HTTP/HTTPS. Quand vous tapez "google.com", il appelle le protocole DNS pour trouver l\'adresse IP.',
      diagnosticTools: [
        'curl -I https://exemple.com (tester la réponse HTTP d\'un serveur)',
        'nslookup exemple.com (tester la résolution de noms DNS)',
        'Test-NetConnection -ComputerName serveur -Port 443 (PowerShell)',
        'Navigateur Web (F12 > onglet Réseau / Network)',
      ],
      typicalBreakdowns: [
        'Erreur HTTP 404 (Page non trouvée) ou 500 (Erreur interne du serveur).',
        'Panne de résolution DNS : impossible d\'ouvrir "intranet.local", mais la connexion fonctionne en tapant l\'adresse IP directe.',
        'Serveur Web ou service Apache/Nginx arrêté ou planté sur la machine distante.',
      ],
    ),

    // --- COUCHE 6 : PRÉSENTATION ---
    OsiLayerModel(
      number: 6,
      name: 'Présentation',
      englishName: 'Presentation',
      pdu: 'Données (Data)',
      role: 'Traduction, formatage, compression et chiffrement/déchiffrement des données.',
      keyProtocols: [
        'TLS / SSL (Chiffrement sécurisé du trafic HTTPS/FTPS)',
        'Formats de texte : ASCII, UTF-8, UTF-16',
        'Formats d\'images : JPEG, PNG, GIF, WebP',
        'Formats de données : JSON, XML, Protobuf',
        'Formats multimédias : MPEG, MP4, MP3, H.264',
      ],
      keyHardware: [
        'Moteurs de chiffrement matériel (Cartes d\'accélération SSL/TLS, puces TPM)',
        'Bibliothèques logicielles (OpenSSL, codecs multimédias)',
      ],
      accentColor: Color(0xFFA855F7), // Violet Astral
      mnemonicHint: 'P — Plusieurs',
      analogy: '🔐 Le traducteur et le coffre-fort : Si deux personnes ne parlent pas la même langue, un interprète traduit le texte. S\'il est secret, il le code dans un alphabet chiffré que seul le destinataire peut décrypter.',
      concreteExplanation: 'La couche Présentation garantit que les données envoyées par une application sur un système (ex: un serveur Linux en UTF-8) soient compréhensibles par le système récepteur (ex: un client Windows ou un smartphone). C\'est également ici que s\'effectue le chiffrement (TLS/SSL) pour protéger les données en transit et la compression pour économiser la bande passante.',
      diagnosticTools: [
        'openssl s_client -connect exemple.com:443 (inspecter la négociation TLS et les certificats)',
        'Vérificateur de certificat SSL dans le navigateur (icône cadenas > Détails du certificat)',
      ],
      typicalBreakdowns: [
        'Certificat SSL/TLS expiré ou invalide (« Votre connexion n\'est pas privée », SEC_ERROR_EXPIRED_CERTIFICATE).',
        'Incompatibilité d\'encodage de caractères (texte avec des caractères bizarres comme  ou Ã©).',
        'Incompatibilité de version TLS (ex: serveur refusant TLS 1.0/1.1 obsolète).',
      ],
    ),

    // --- COUCHE 5 : SESSION ---
    OsiLayerModel(
      number: 5,
      name: 'Session',
      englishName: 'Session',
      pdu: 'Données (Data)',
      role: 'Établissement, gestion, synchronisation et clôture des dialogues entre applications.',
      keyProtocols: [
        'NetBIOS / NetBEUI (Partage de fichiers historique Windows)',
        'RPC (Remote Procedure Call - appels de fonctions distantes)',
        'PPTP (Protocole de tunnel VPN)',
        'Sockets POSIX (Interfaces de session logicielle)',
        'NFS (Network File System) / SMB Session',
      ],
      keyHardware: [
        'Gestionnaire de session du système d\'exploitation',
        'Piles de protocoles réseau de l\'OS',
      ],
      accentColor: Color(0xFF6366F1), // Indigo Électrique
      mnemonicHint: 'S — Semaines',
      analogy: '📞 L\'appel téléphonique et la formule de politesse : « Allô ? Tu m\'entends ? Oui ! » Vous maintenez la conversation ouverte, vous convenez de qui parle à quel moment, et vous dites « Au revoir » avant de raccrocher.',
      concreteExplanation: 'La couche Session gère les règles du dialogue entre deux machines : est-ce que les deux peuvent parler en même temps (Full Duplex) ou chacun son tour (Half Duplex) ? Elle place également des points de contrôle (checkpoints) : si vous téléchargez un gros fichier de 5 Go et que la connexion coupe à 4 Go, la couche session permet de reprendre là où vous vous étiez arrêté sans tout recommencer.',
      diagnosticTools: [
        'Get-SmbSession (PowerShell : lister les sessions de partage ouvertes)',
        'rpcping (tester la connectivité RPC sous Windows)',
        'Net use / Net session (gestion des sessions sous Windows)',
      ],
      typicalBreakdowns: [
        'Session de partage de fichiers SMB expirée ou déconnectée (« La session réseau distante a été fermée »).',
        'Échec d\'appel RPC lors de la synchronisation d\'un contrôleur de domaine Active Directory.',
        'Déconnexion intempestive de session VPN après un délai d\'inactivité (Keep-Alive manquant).',
      ],
    ),

    // --- COUCHE 4 : TRANSPORT ---
    OsiLayerModel(
      number: 4,
      name: 'Transport',
      englishName: 'Transport',
      pdu: 'Segment (TCP) / Datagramme (UDP)',
      role: 'Acheminement de bout en bout, multiplexage par numéros de port, fiabilité et contrôle de débit.',
      keyProtocols: [
        'TCP (Orienté connexion, fiable, acquittements ACK/SYN, contrôle d\'erreur)',
        'UDP (Non orienté connexion, rapide, sans garantie d\'arrivée : streaming, DNS, VoIP)',
        'Numéros de ports (0 à 65535, ex: 80, 443, 22, 53, 3389 RDP)',
        'QUIC / SCTP',
      ],
      keyHardware: [
        'Pare-feu avec état (Stateful Firewall - inspection des ports et flags TCP)',
        'Équilibreur de charge niveau 4 (HAProxy, F5 BIG-IP)',
      ],
      accentColor: Color(0xFF00E5FF), // Cyan Tardis
      mnemonicHint: 'T — Tout',
      analogy: '🚚 Le transporteur et le numéro d\'appartement : Le paquet est mis dans un camion. TCP est un recommandé avec accusé de réception (si un carton tombe, il le renvoie). UDP est une carte postale envoyée sans garantie. Le numéro de port est le numéro d\'appartement dans l\'immeuble (pour savoir à quelle application sur la machine livrer les données).',
      concreteExplanation: 'Une machine possède une seule adresse IP, mais exécute des dizaines d\'applications en même temps (navigateur, jeu, Spotify, Discord). La couche Transport utilise les numéros de ports (0 à 65535) pour savoir quel paquet appartient à quelle application. TCP découpe les gros fichiers en petits segments numérotés pour s\'assurer qu\'aucun morceau ne manque à l\'arrivée.',
      diagnosticTools: [
        'netstat -ano (afficher les ports TCP/UDP ouverts et les connexions actives)',
        'Test-NetConnection 192.168.1.10 -Port 3389 (vérifier si un port est ouvert)',
        'telnet IP PORT ou nc -zv IP PORT (tester l\'ouverture d\'un port TCP)',
      ],
      typicalBreakdowns: [
        'Port bloqué par le pare-feu local Windows Defender ou pare-feu réseau (« Connection refused » ou « Timeout »).',
        'Service non démarré ou n\'écoutant pas sur le bon port (aucun processus sur le port 443).',
        'Saturation de la bande passante entraînant une perte massive de segments TCP et des retransmissions en boucle.',
      ],
    ),

    // --- COUCHE 3 : RÉSEAU ---
    OsiLayerModel(
      number: 3,
      name: 'Réseau',
      englishName: 'Network',
      pdu: 'Paquet (Packet)',
      role: 'Adressage logique mondial (adresses IP), routage et choix du meilleur chemin à travers les réseaux.',
      keyProtocols: [
        'IPv4 (ex: 192.168.1.1, 10.0.0.0/8, 172.16.0.0/12)',
        'IPv6 (ex: 2001:db8::1)',
        'ICMP (Protocole de contrôle et de test utilisé par Ping et Traceroute)',
        'OSPF / BGP / RIP (Protocoles de routage dynamique entre routeurs)',
        'IPsec (Chiffrement au niveau réseau)',
      ],
      keyHardware: [
        'Routeur (interconnexion de réseaux différents)',
        'Switch de niveau 3 (Switch administrable avec fonctions de routage inter-VLAN)',
        'Passerelle par défaut (Default Gateway)',
      ],
      accentColor: Color(0xFF10B981), // Émeraude
      mnemonicHint: 'R — Recommence',
      analogy: '🗺️ Le GPS et l\'adresse postale (Code postal & Ville) : L\'adresse IP est l\'adresse complète mondiale de destination. Le routeur est l\'échangeur d\'autoroute qui regarde le panneau indicateur pour aiguiller le paquet vers la bonne direction.',
      concreteExplanation: 'La couche Réseau s\'occupe de déplacer des données d\'une machine à une autre même si elles se trouvent à l\'autre bout de la planète sur des réseaux différents. Chaque machine a une adresse IP logique. Le routeur lit l\'adresse IP de destination contenue dans l\'en-tête du paquet et consulte sa table de routage pour le transmettre au saut suivant (next hop).',
      diagnosticTools: [
        'ping 8.8.8.8 (tester la connectivité réseau de base via ICMP)',
        'tracert 8.8.8.8 (Windows) ou traceroute (Linux) : voir chaque routeur traversé',
        'ipconfig /all (Windows) ou ip a (Linux) : vérifier sa configuration IP, masque et passerelle',
        'route print (afficher la table de routage de la machine)',
      ],
      typicalBreakdowns: [
        'Passerelle par défaut (Default Gateway) mal configurée ou injoignable : accès au réseau local OK, mais pas d\'accès Internet.',
        'Conflit d\'adresse IP (deux machines configurées avec la même adresse IP sur le réseau).',
        'Masque de sous-réseau incorrect (ex: /24 au lieu de /16 empêchant de joindre certains hôtes).',
      ],
    ),

    // --- COUCHE 2 : LIAISON DE DONNÉES ---
    OsiLayerModel(
      number: 2,
      name: 'Liaison de données',
      englishName: 'Data Link',
      pdu: 'Trame (Frame)',
      role: 'Communication locale sur le même réseau physique, adressage MAC et détection des erreurs matérielles.',
      keyProtocols: [
        'Ethernet (Norme IEEE 802.3 pour les réseaux filaires)',
        'Wi-Fi MAC (Norme IEEE 802.11 pour le sans-fil)',
        'ARP (Address Resolution Protocol : trouve l\'adresse MAC à partir d\'une IP)',
        'VLAN (IEEE 802.1Q : segmentation logique des réseaux locaux)',
        'STP (Spanning Tree Protocol 802.1D : empêche les boucles réseau infinies)',
      ],
      keyHardware: [
        'Switch Ethernet (Commutateur niveau 2 utilisant la table MAC CAM)',
        'Carte réseau (NIC - possède l\'adresse MAC gravée en usine)',
        'Pont réseau (Bridge)',
        'Point d\'accès Wi-Fi (AP en mode pont L2)',
      ],
      accentColor: Color(0xFFF59E0B), // Ambre Doré
      mnemonicHint: 'L — Le',
      analogy: '🏷️ Le prénom dans la pièce et l\'étiquette d\'identification : Dans une salle de réunion, vous appelez les gens par leur nom direct. L\'adresse MAC est l\'empreinte physique unique de votre carte réseau. Le switch est le concierge qui sait exactement à quelle porte physique se trouve chaque personne.',
      concreteExplanation: 'Alors que la couche 3 utilise l\'IP pour traverser la planète, la couche 2 s\'occupe des sauts directs d\'un câble à l\'autre dans le même réseau local. Le switch regarde l\'adresse MAC de destination de la trame et l\'envoie uniquement sur le port où est branché le PC. En queue de trame, le champ FCS (Frame Check Sequence / CRC) vérifie que pas un seul bit n\'a été corrompu par un parasite électrique.',
      diagnosticTools: [
        'arp -a (afficher la table ARP associant adresses IP et adresses MAC)',
        'getmac (Windows : afficher l\'adresse MAC de ses cartes réseau)',
        'Wireshark (analyser les trames Ethernet, broadcasts ARP et requêtes DHCP)',
        'Interface du switch (show mac address-table)',
      ],
      typicalBreakdowns: [
        'Tempête de broadcast (Broadcast Storm) : deux câbles branchés en boucle entre switchs sans Spanning Tree Protocol (STP).',
        'Port de switch assigné au mauvais VLAN (PC isolé dans le VLAN 20 au lieu du VLAN 10).',
        'Échec de résolution ARP (machine introuvable sur le réseau local ou table ARP corrompue).',
      ],
    ),

    // --- COUCHE 1 : PHYSIQUE ---
    OsiLayerModel(
      number: 1,
      name: 'Physique',
      englishName: 'Physical',
      pdu: 'Bit (Signal électrique / optique / ondes radio)',
      role: 'Transmission matérielle brute des 0 et des 1 sous forme de tensions électriques, flashs lumineux ou ondes radio.',
      keyProtocols: [
        'Normes filaires Ethernet : 100BASE-TX, 1000BASE-T (Gigabit), 10GBASE-T',
        'Normes fibre optique : 1000BASE-SX, 10GBASE-SR (Multimode), 10GBASE-LR (Monomode)',
        'Câblage structuré : EIA/TIA-568A et 568B (Ordre des couleurs des fils)',
        'Normes de transmission : DSL, USB, Bluetooth PHY',
      ],
      keyHardware: [
        'Câbles réseau RJ45 cuivre (Cat 5e, Cat 6, Cat 6A, Cat 7 - Paires torsadées UTP/STP)',
        'Jarretières et câbles de fibre optique (Connecteurs LC, SC, ST)',
        'Prises murales RJ45, Panneaux de brassage (Patch Panels)',
        'Hubs (Concentrateurs - répètent bêtement le signal sur tous les ports)',
        'Répéteurs de signal et émetteurs Wi-Fi / Radio',
        'Modules transceivers SFP / SFP+',
      ],
      accentColor: Color(0xFFEF4444), // Rouge Corail
      mnemonicHint: 'P — Pour',
      analogy: '⚡ Le câble électrique et le tuyau de cuivre : Ce sont les électrons qui voyagent dans le cuivre, les impulsions de lumière laser dans la fibre de verre, ou les ondes invisibles dans l\'air. Sans câble branché, rien ne peut exister au-dessus.',
      concreteExplanation: 'La couche Physique s\'occupe de tout ce que l\'on peut toucher des mains : les câbles en cuivre, les fibres de verre, les connecteurs RJ45, la tension électrique (ex: +2.5V pour un 1, -2.5V pour un 0), la fréquence des ondes radio. Elle ne comprend ni les adresses IP, ni les noms de domaine, ni les fichiers : elle transmet uniquement une suite continue de zéros et de uns.',
      diagnosticTools: [
        'Testeur de câble réseau RJ45 (vérifier la continuité des 8 fils de couleur)',
        'Vérification visuelle des voyants LED (Link/Act vert/orange) sur le port réseau',
        'Photomètre / Réflectomètre optique (OTDR pour mesurer l\'atténuation de la fibre)',
        'Remplacement préventif du câble réseau RJ45 douteux',
      ],
      typicalBreakdowns: [
        'Câble RJ45 débranché, écrasé, tordu ou coupé (LED éteinte sur la carte réseau).',
        'Mauvais sertissage d\'un connecteur RJ45 (fil 1 ou fil 2 mal enfoncé, faux contact).',
        'Longueur de câble cuivre supérieure à 100 mètres (limite maximale Ethernet) provoquant des pertes de paquets.',
        'Poussière ou connecteur abîmé sur une jarretière fibre optique.',
      ],
    ),
  ];

  static OsiLayerModel getLayer(int number) {
    return layers.firstWhere(
      (l) => l.number == number,
      orElse: () => layers.first,
    );
  }
}
