class LexiqueEntry {
  const LexiqueEntry({
    required this.acronym,
    required this.definition,
    required this.category,
  });
  final String acronym;
  final String definition;
  final String category;
}

class LexiqueCategory {
  const LexiqueCategory({required this.name, required this.emoji, required this.key});
  final String name;
  final String emoji;
  final String key;
  int get count => allLexique.where((e) => e.category == key).length;
}

const List<LexiqueCategory> lexiqueCategories = [
  LexiqueCategory(name: 'Réseau',        emoji: '🌐', key: 'reseau'),
  LexiqueCategory(name: 'Windows / AD',  emoji: '🖥', key: 'windows'),
  LexiqueCategory(name: 'Sécurité',      emoji: '🔒', key: 'securite'),
  LexiqueCategory(name: 'Matériel & OS', emoji: '💻', key: 'materiel'),
];

const List<LexiqueEntry> allLexique = [
  // Réseau
  LexiqueEntry(acronym: 'DNS',   definition: 'Domain Name System — traduit les noms de domaine en adresses IP',                        category: 'reseau'),
  LexiqueEntry(acronym: 'DHCP',  definition: 'Dynamic Host Configuration Protocol — attribue automatiquement les adresses IP',          category: 'reseau'),
  LexiqueEntry(acronym: 'TCP',   definition: 'Transmission Control Protocol — protocole fiable avec accuse de reception',               category: 'reseau'),
  LexiqueEntry(acronym: 'UDP',   definition: 'User Datagram Protocol — protocole rapide sans verification de livraison',                category: 'reseau'),
  LexiqueEntry(acronym: 'HTTP',  definition: 'HyperText Transfer Protocol — protocole de transfert du web',                            category: 'reseau'),
  LexiqueEntry(acronym: 'HTTPS', definition: 'HyperText Transfer Protocol Secure — HTTP chiffre via TLS',                              category: 'reseau'),
  LexiqueEntry(acronym: 'FTP',   definition: 'File Transfer Protocol — protocole de transfert de fichiers',                            category: 'reseau'),
  LexiqueEntry(acronym: 'SSH',   definition: 'Secure Shell — connexion distante securisee en ligne de commande',                       category: 'reseau'),
  LexiqueEntry(acronym: 'VLAN',  definition: 'Virtual Local Area Network — reseau local virtuel isole logiquement',                    category: 'reseau'),
  LexiqueEntry(acronym: 'LAN',   definition: 'Local Area Network — reseau local d\'entreprise ou domicile',                            category: 'reseau'),
  LexiqueEntry(acronym: 'WAN',   definition: 'Wide Area Network — reseau etendu reliant plusieurs sites distants',                     category: 'reseau'),
  LexiqueEntry(acronym: 'NAT',   definition: 'Network Address Translation — traduit des adresses IP privees en IP publique',           category: 'reseau'),
  LexiqueEntry(acronym: 'OSI',   definition: 'Open Systems Interconnection — modele en 7 couches pour les communications reseau',      category: 'reseau'),
  LexiqueEntry(acronym: 'VPN',   definition: 'Virtual Private Network — tunnel chiffre entre deux points du reseau',                   category: 'reseau'),
  LexiqueEntry(acronym: 'ICMP',  definition: 'Internet Control Message Protocol — diagnostics reseau comme ping et traceroute',        category: 'reseau'),
  LexiqueEntry(acronym: 'ARP',   definition: 'Address Resolution Protocol — resout une adresse IP en adresse MAC locale',             category: 'reseau'),
  LexiqueEntry(acronym: 'CIDR',  definition: 'Classless Inter-Domain Routing — notation /prefixe pour les sous-reseaux',              category: 'reseau'),
  LexiqueEntry(acronym: 'QoS',   definition: 'Quality of Service — priorisation du trafic reseau',                                    category: 'reseau'),
  LexiqueEntry(acronym: 'MTU',   definition: 'Maximum Transmission Unit — taille maximale d\'un paquet reseau',                       category: 'reseau'),
  LexiqueEntry(acronym: 'ACL',   definition: 'Access Control List — liste de regles autorisant ou bloquant le trafic',                category: 'reseau'),
  LexiqueEntry(acronym: 'SSID',  definition: 'Service Set Identifier — nom d\'un reseau Wi-Fi diffuse par le point d\'acces',         category: 'reseau'),
  LexiqueEntry(acronym: 'SMTP',  definition: 'Simple Mail Transfer Protocol — protocole d\'envoi d\'e-mails',                         category: 'reseau'),
  LexiqueEntry(acronym: 'IMAP',  definition: 'Internet Message Access Protocol — protocole de lecture des e-mails en ligne',          category: 'reseau'),
  LexiqueEntry(acronym: 'SNMP',  definition: 'Simple Network Management Protocol — surveillance des equipements reseau',               category: 'reseau'),
  LexiqueEntry(acronym: 'BGP',   definition: 'Border Gateway Protocol — protocole de routage inter-operateurs sur Internet',          category: 'reseau'),
  LexiqueEntry(acronym: 'OSPF',  definition: 'Open Shortest Path First — protocole de routage interne base sur le chemin le plus court', category: 'reseau'),
  LexiqueEntry(acronym: 'MAC',   definition: 'Media Access Control — adresse physique unique d\'une carte reseau',                    category: 'reseau'),
  LexiqueEntry(acronym: 'NFS',   definition: 'Network File System — partage de fichiers reseau entre systemes Unix/Linux',            category: 'reseau'),
  // Windows / AD
  LexiqueEntry(acronym: 'AD',    definition: 'Active Directory — service d\'annuaire Microsoft pour gerer utilisateurs et ressources', category: 'windows'),
  LexiqueEntry(acronym: 'DC',    definition: 'Domain Controller — serveur qui gere l\'authentification dans un domaine AD',           category: 'windows'),
  LexiqueEntry(acronym: 'OU',    definition: 'Organizational Unit — unite organisationnelle pour structurer les objets AD',           category: 'windows'),
  LexiqueEntry(acronym: 'GPO',   definition: 'Group Policy Object — strategie de groupe appliquee aux utilisateurs ou machines',      category: 'windows'),
  LexiqueEntry(acronym: 'NTFS',  definition: 'New Technology File System — systeme de fichiers Windows avec permissions avancees',    category: 'windows'),
  LexiqueEntry(acronym: 'SMB',   definition: 'Server Message Block — protocole Windows de partage de fichiers et imprimantes',       category: 'windows'),
  LexiqueEntry(acronym: 'RDP',   definition: 'Remote Desktop Protocol — protocole de bureau a distance Windows',                     category: 'windows'),
  LexiqueEntry(acronym: 'WSUS',  definition: 'Windows Server Update Services — serveur de distribution des mises a jour Windows',    category: 'windows'),
  LexiqueEntry(acronym: 'LDAP',  definition: 'Lightweight Directory Access Protocol — protocole d\'interrogation des annuaires',     category: 'windows'),
  LexiqueEntry(acronym: 'ADDS',  definition: 'Active Directory Domain Services — role principal du DC gerant le domaine',            category: 'windows'),
  LexiqueEntry(acronym: 'SID',   definition: 'Security Identifier — identifiant unique attribue a chaque objet AD',                  category: 'windows'),
  LexiqueEntry(acronym: 'KDC',   definition: 'Key Distribution Center — composant Kerberos qui delivre les tickets d\'authentification', category: 'windows'),
  LexiqueEntry(acronym: 'TGT',   definition: 'Ticket Granting Ticket — ticket Kerberos principal obtenu apres authentification',     category: 'windows'),
  LexiqueEntry(acronym: 'WMI',   definition: 'Windows Management Instrumentation — interface d\'administration et monitoring Windows', category: 'windows'),
  LexiqueEntry(acronym: 'IIS',   definition: 'Internet Information Services — serveur web Microsoft integre a Windows Server',       category: 'windows'),
  LexiqueEntry(acronym: 'SAM',   definition: 'Security Account Manager — base de donnees locale des comptes Windows',               category: 'windows'),
  // Sécurité
  LexiqueEntry(acronym: 'SSL',   definition: 'Secure Sockets Layer — protocole de chiffrement obsolete, remplace par TLS',          category: 'securite'),
  LexiqueEntry(acronym: 'TLS',   definition: 'Transport Layer Security — protocole de chiffrement des communications reseau',        category: 'securite'),
  LexiqueEntry(acronym: 'PKI',   definition: 'Public Key Infrastructure — infrastructure de gestion des certificats numeriques',     category: 'securite'),
  LexiqueEntry(acronym: 'MFA',   definition: 'Multi-Factor Authentication — authentification par plusieurs facteurs de verification', category: 'securite'),
  LexiqueEntry(acronym: 'IDS',   definition: 'Intrusion Detection System — systeme de detection des intrusions reseau',              category: 'securite'),
  LexiqueEntry(acronym: 'IPS',   definition: 'Intrusion Prevention System — systeme de prevention et blocage des intrusions',       category: 'securite'),
  LexiqueEntry(acronym: 'DMZ',   definition: 'Demilitarized Zone — zone reseau isolee exposant les serveurs publics',               category: 'securite'),
  LexiqueEntry(acronym: 'AES',   definition: 'Advanced Encryption Standard — algorithme de chiffrement symetrique standard',        category: 'securite'),
  LexiqueEntry(acronym: 'SHA',   definition: 'Secure Hash Algorithm — famille d\'algorithmes de hachage cryptographique',           category: 'securite'),
  LexiqueEntry(acronym: 'RBAC',  definition: 'Role-Based Access Control — controle d\'acces base sur les roles des utilisateurs',   category: 'securite'),
  LexiqueEntry(acronym: 'SOC',   definition: 'Security Operations Center — equipe chargee de surveiller la securite du SI',        category: 'securite'),
  LexiqueEntry(acronym: 'SIEM',  definition: 'Security Information and Event Management — centralisation et analyse des journaux de securite', category: 'securite'),
  LexiqueEntry(acronym: 'WAF',   definition: 'Web Application Firewall — pare-feu protegeant les applications web',                 category: 'securite'),
  LexiqueEntry(acronym: 'XSS',   definition: 'Cross-Site Scripting — injection de scripts malveillants dans une page web',         category: 'securite'),
  LexiqueEntry(acronym: 'CSRF',  definition: 'Cross-Site Request Forgery — attaque forcant un utilisateur a effectuer des actions non voulues', category: 'securite'),
  // Matériel & OS
  LexiqueEntry(acronym: 'CPU',   definition: 'Central Processing Unit — processeur central d\'un ordinateur',                       category: 'materiel'),
  LexiqueEntry(acronym: 'RAM',   definition: 'Random Access Memory — memoire vive a acces aleatoire',                               category: 'materiel'),
  LexiqueEntry(acronym: 'ROM',   definition: 'Read-Only Memory — memoire en lecture seule non volatile',                            category: 'materiel'),
  LexiqueEntry(acronym: 'SSD',   definition: 'Solid-State Drive — disque de stockage rapide sans piece mecanique',                  category: 'materiel'),
  LexiqueEntry(acronym: 'HDD',   definition: 'Hard Disk Drive — disque dur mecanique a plateaux rotatifs',                          category: 'materiel'),
  LexiqueEntry(acronym: 'BIOS',  definition: 'Basic Input/Output System — firmware de demarrage des PC historiques',                category: 'materiel'),
  LexiqueEntry(acronym: 'UEFI',  definition: 'Unified Extensible Firmware Interface — successeur moderne du BIOS',                  category: 'materiel'),
  LexiqueEntry(acronym: 'GUI',   definition: 'Graphical User Interface — interface graphique pour interagir avec l\'OS',            category: 'materiel'),
  LexiqueEntry(acronym: 'CLI',   definition: 'Command-Line Interface — interface en ligne de commande textuelle',                   category: 'materiel'),
  LexiqueEntry(acronym: 'VM',    definition: 'Virtual Machine — machine virtuelle emulee sur un hyperviseur',                       category: 'materiel'),
  LexiqueEntry(acronym: 'RAID',  definition: 'Redundant Array of Independent Disks — groupement de disques pour redondance ou performance', category: 'materiel'),
  LexiqueEntry(acronym: 'OS',    definition: 'Operating System — systeme d\'exploitation comme Windows, Linux ou macOS',            category: 'materiel'),
  LexiqueEntry(acronym: 'API',   definition: 'Application Programming Interface — interface permettant a des applications de communiquer', category: 'materiel'),
  LexiqueEntry(acronym: 'SDK',   definition: 'Software Development Kit — ensemble d\'outils pour developper des applications',      category: 'materiel'),
  LexiqueEntry(acronym: 'BSOD',  definition: 'Blue Screen Of Death — ecran bleu Windows signalant une erreur critique systeme',    category: 'materiel'),
];
