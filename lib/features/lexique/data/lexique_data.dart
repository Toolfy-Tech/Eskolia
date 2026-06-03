class LexiqueEntry {
  const LexiqueEntry({
    required this.term,
    required this.definition,
    required this.category,
  });
  final String term;
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
  LexiqueCategory(name: 'Concepts & Métier', emoji: '💼', key: 'metier'),
  LexiqueCategory(name: 'Réseau',            emoji: '🌐', key: 'reseau'),
  LexiqueCategory(name: 'Windows / AD',      emoji: '🖥',  key: 'windows'),
  LexiqueCategory(name: 'Sécurité',          emoji: '🔒', key: 'securite'),
  LexiqueCategory(name: 'Matériel & OS',     emoji: '💻', key: 'materiel'),
];

const List<LexiqueEntry> allLexique = [
  // ── Concepts & Métier ─────────────────────────────────────────────────────
  LexiqueEntry(term: 'Audit',          definition: 'Examen methodique d\'un systeme ou processus pour evaluer sa conformite, sa securite ou ses performances', category: 'metier'),
  LexiqueEntry(term: 'Patch',          definition: 'Correctif logiciel applique pour corriger une faille de securite ou un bug dans un programme', category: 'metier'),
  LexiqueEntry(term: 'Incident',       definition: 'Evenement non planifie qui degrade ou interrompt un service informatique et necessite une resolution', category: 'metier'),
  LexiqueEntry(term: 'Ticket',         definition: 'Demande enregistree dans un systeme de suivi pour tracer la resolution d\'un incident ou d\'une requete utilisateur', category: 'metier'),
  LexiqueEntry(term: 'Backup',         definition: 'Copie de sauvegarde de donnees permettant de les restaurer en cas de perte, corruption ou ransomware', category: 'metier'),
  LexiqueEntry(term: 'Déploiement',    definition: 'Mise en production d\'un logiciel, d\'un service ou d\'une mise a jour sur l\'infrastructure cible', category: 'metier'),
  LexiqueEntry(term: 'Migration',      definition: 'Transfert d\'un systeme, d\'une application ou de donnees vers un nouvel environnement sans perte de service', category: 'metier'),
  LexiqueEntry(term: 'Supervision',    definition: 'Surveillance continue des performances et de la disponibilite des equipements et services du SI', category: 'metier'),
  LexiqueEntry(term: 'Escalade',       definition: 'Transfert d\'un incident vers un niveau de support superieur lorsque le niveau courant ne peut pas le resoudre', category: 'metier'),
  LexiqueEntry(term: 'Provisioning',   definition: 'Mise a disposition de ressources informatiques (compte, VM, acces) pour un utilisateur ou un service', category: 'metier'),
  LexiqueEntry(term: 'Hardening',      definition: 'Renforcement de la securite d\'un systeme en reduisant sa surface d\'attaque : desactivation des services inutiles, mises a jour, restrictions d\'acces', category: 'metier'),
  LexiqueEntry(term: 'Failover',       definition: 'Bascule automatique vers un systeme redondant en cas de defaillance du systeme principal, pour maintenir la continuite de service', category: 'metier'),
  LexiqueEntry(term: 'Load balancer',  definition: 'Repartiteur de charge qui distribue les requetes entrantes entre plusieurs serveurs pour eviter la saturation', category: 'metier'),
  LexiqueEntry(term: 'Cluster',        definition: 'Groupe de serveurs interconnectes travaillant ensemble pour offrir haute disponibilite ou puissance de calcul combinee', category: 'metier'),
  LexiqueEntry(term: 'Virtualisation', definition: 'Technologie permettant de faire fonctionner plusieurs systemes virtuels independants sur un meme serveur physique via un hyperviseur', category: 'metier'),
  LexiqueEntry(term: 'Conteneur',      definition: 'Unite d\'execution isolee et portable regroupant une application et ses dependances, plus legere qu\'une VM car partageant le noyau de l\'OS hote', category: 'metier'),
  LexiqueEntry(term: 'Onboarding',     definition: 'Processus d\'integration d\'un nouvel employe ou d\'un nouveau poste dans le systeme d\'information : creation de comptes, affectation des droits, remise du materiel', category: 'metier'),
  LexiqueEntry(term: 'Firewall',       definition: 'Pare-feu — equipement ou logiciel qui filtre le trafic reseau entrant et sortant selon des regles de securite definies', category: 'metier'),
  LexiqueEntry(term: 'Script',         definition: 'Fichier contenant une suite de commandes automatisees executees par un interpreteur (PowerShell, Bash, Python) pour gagner du temps sur des taches repetitives', category: 'metier'),
  LexiqueEntry(term: 'Documentation',  definition: 'Ensemble des documents decrivant une infrastructure, une procedure ou un processus, indispensable pour la maintenance et la continuite de service', category: 'metier'),
  LexiqueEntry(term: 'ITIL',           definition: 'Information Technology Infrastructure Library — referentiel de bonnes pratiques pour la gestion des services informatiques', category: 'metier'),
  LexiqueEntry(term: 'SLA',            definition: 'Service Level Agreement — contrat definissant le niveau de service garanti entre un fournisseur et son client (disponibilite, temps de reponse)', category: 'metier'),
  LexiqueEntry(term: 'Ransomware',     definition: 'Logiciel malveillant qui chiffre les donnees de la victime et exige une rancon pour les restaurer', category: 'metier'),
  LexiqueEntry(term: 'Phishing',       definition: 'Technique d\'attaque qui imite un message ou site legitime pour pieger l\'utilisateur et voler ses identifiants ou donnees sensibles', category: 'metier'),
  LexiqueEntry(term: 'Proxy',          definition: 'Serveur intermediaire qui traite les requetes reseau au nom des clients, utilisé pour filtrer, journaliser ou mettre en cache le trafic', category: 'metier'),
  LexiqueEntry(term: 'Hyperviseur',    definition: 'Logiciel qui cree et gere les machines virtuelles sur un serveur physique (ex : VMware ESXi, Hyper-V, Proxmox)', category: 'metier'),
  // ── Réseau ────────────────────────────────────────────────────────────────
  LexiqueEntry(term: 'DNS',   definition: 'Domain Name System — traduit les noms de domaine en adresses IP', category: 'reseau'),
  LexiqueEntry(term: 'DHCP',  definition: 'Dynamic Host Configuration Protocol — attribue automatiquement les adresses IP aux machines du reseau', category: 'reseau'),
  LexiqueEntry(term: 'TCP',   definition: 'Transmission Control Protocol — protocole de transport fiable avec accuse de reception', category: 'reseau'),
  LexiqueEntry(term: 'UDP',   definition: 'User Datagram Protocol — protocole de transport rapide sans verification de livraison', category: 'reseau'),
  LexiqueEntry(term: 'HTTP',  definition: 'HyperText Transfer Protocol — protocole de transfert des pages web', category: 'reseau'),
  LexiqueEntry(term: 'HTTPS', definition: 'HyperText Transfer Protocol Secure — HTTP chiffre via TLS', category: 'reseau'),
  LexiqueEntry(term: 'FTP',   definition: 'File Transfer Protocol — protocole de transfert de fichiers', category: 'reseau'),
  LexiqueEntry(term: 'SSH',   definition: 'Secure Shell — connexion distante securisee en ligne de commande', category: 'reseau'),
  LexiqueEntry(term: 'VLAN',  definition: 'Virtual Local Area Network — reseau local virtuel isole logiquement sur un commutateur physique', category: 'reseau'),
  LexiqueEntry(term: 'LAN',   definition: 'Local Area Network — reseau local d\'entreprise ou de domicile', category: 'reseau'),
  LexiqueEntry(term: 'WAN',   definition: 'Wide Area Network — reseau etendu reliant plusieurs sites distants', category: 'reseau'),
  LexiqueEntry(term: 'NAT',   definition: 'Network Address Translation — traduit des adresses IP privees en adresse IP publique', category: 'reseau'),
  LexiqueEntry(term: 'OSI',   definition: 'Open Systems Interconnection — modele en 7 couches standardisant les communications reseau', category: 'reseau'),
  LexiqueEntry(term: 'VPN',   definition: 'Virtual Private Network — tunnel chiffre permettant de connecter deux reseaux ou un poste distant de facon securisee', category: 'reseau'),
  LexiqueEntry(term: 'ICMP',  definition: 'Internet Control Message Protocol — protocole de diagnostic reseau utilise par ping et traceroute', category: 'reseau'),
  LexiqueEntry(term: 'ARP',   definition: 'Address Resolution Protocol — resout une adresse IP en adresse MAC sur le reseau local', category: 'reseau'),
  LexiqueEntry(term: 'CIDR',  definition: 'Classless Inter-Domain Routing — notation avec prefixe (ex: /24) pour definir les sous-reseaux', category: 'reseau'),
  LexiqueEntry(term: 'QoS',   definition: 'Quality of Service — priorisation du trafic reseau pour garantir la bande passante aux applications critiques', category: 'reseau'),
  LexiqueEntry(term: 'MTU',   definition: 'Maximum Transmission Unit — taille maximale en octets d\'un paquet reseau', category: 'reseau'),
  LexiqueEntry(term: 'ACL',   definition: 'Access Control List — liste de regles autorisant ou bloquant le trafic reseau', category: 'reseau'),
  LexiqueEntry(term: 'SSID',  definition: 'Service Set Identifier — nom d\'un reseau Wi-Fi diffuse par le point d\'acces', category: 'reseau'),
  LexiqueEntry(term: 'SMTP',  definition: 'Simple Mail Transfer Protocol — protocole d\'envoi d\'e-mails', category: 'reseau'),
  LexiqueEntry(term: 'IMAP',  definition: 'Internet Message Access Protocol — protocole de lecture des e-mails en restant synchronise avec le serveur', category: 'reseau'),
  LexiqueEntry(term: 'SNMP',  definition: 'Simple Network Management Protocol — protocole de surveillance et gestion des equipements reseau', category: 'reseau'),
  LexiqueEntry(term: 'BGP',   definition: 'Border Gateway Protocol — protocole de routage entre operateurs sur Internet', category: 'reseau'),
  LexiqueEntry(term: 'OSPF',  definition: 'Open Shortest Path First — protocole de routage interne calculant le chemin le plus court', category: 'reseau'),
  LexiqueEntry(term: 'MAC',   definition: 'Media Access Control — adresse physique unique gravee dans la carte reseau', category: 'reseau'),
  LexiqueEntry(term: 'NFS',   definition: 'Network File System — partage de fichiers reseau entre systemes Unix/Linux', category: 'reseau'),
  // ── Windows / AD ──────────────────────────────────────────────────────────
  LexiqueEntry(term: 'AD',    definition: 'Active Directory — service d\'annuaire Microsoft centralisant la gestion des utilisateurs, machines et ressources du domaine', category: 'windows'),
  LexiqueEntry(term: 'DC',    definition: 'Domain Controller — serveur Windows qui gere l\'authentification et les politiques d\'un domaine Active Directory', category: 'windows'),
  LexiqueEntry(term: 'OU',    definition: 'Organizational Unit — conteneur dans Active Directory pour organiser et appliquer des GPO a des groupes d\'objets', category: 'windows'),
  LexiqueEntry(term: 'GPO',   definition: 'Group Policy Object — objet de strategie de groupe applique aux utilisateurs ou machines pour configurer l\'environnement Windows', category: 'windows'),
  LexiqueEntry(term: 'NTFS',  definition: 'New Technology File System — systeme de fichiers Windows supportant les permissions avancees, la compression et le chiffrement', category: 'windows'),
  LexiqueEntry(term: 'SMB',   definition: 'Server Message Block — protocole Windows de partage de fichiers, imprimantes et ressources reseau', category: 'windows'),
  LexiqueEntry(term: 'RDP',   definition: 'Remote Desktop Protocol — protocole Microsoft permettant de prendre le controle graphique d\'un poste a distance', category: 'windows'),
  LexiqueEntry(term: 'WSUS',  definition: 'Windows Server Update Services — serveur interne distribuant les mises a jour Windows aux postes du parc', category: 'windows'),
  LexiqueEntry(term: 'LDAP',  definition: 'Lightweight Directory Access Protocol — protocole standard d\'interrogation et modification des annuaires comme Active Directory', category: 'windows'),
  LexiqueEntry(term: 'ADDS',  definition: 'Active Directory Domain Services — role Windows Server principal gerant le domaine, l\'authentification et les GPO', category: 'windows'),
  LexiqueEntry(term: 'SID',   definition: 'Security Identifier — identifiant unique attribue a chaque objet Active Directory (utilisateur, groupe, machine)', category: 'windows'),
  LexiqueEntry(term: 'KDC',   definition: 'Key Distribution Center — composant Kerberos qui delivre les tickets d\'authentification dans un domaine AD', category: 'windows'),
  LexiqueEntry(term: 'TGT',   definition: 'Ticket Granting Ticket — ticket Kerberos principal obtenu lors de l\'authentification, permettant d\'obtenir d\'autres tickets de service', category: 'windows'),
  LexiqueEntry(term: 'WMI',   definition: 'Windows Management Instrumentation — interface Microsoft permettant de surveiller et administrer les systemes Windows a distance', category: 'windows'),
  LexiqueEntry(term: 'IIS',   definition: 'Internet Information Services — serveur web Microsoft integre a Windows Server', category: 'windows'),
  LexiqueEntry(term: 'SAM',   definition: 'Security Account Manager — base de donnees locale stockant les comptes et mots de passe d\'un poste Windows', category: 'windows'),
  // ── Sécurité ──────────────────────────────────────────────────────────────
  LexiqueEntry(term: 'SSL',   definition: 'Secure Sockets Layer — protocole de chiffrement obsolete, remplace par TLS depuis 2015', category: 'securite'),
  LexiqueEntry(term: 'TLS',   definition: 'Transport Layer Security — protocole standard de chiffrement des communications reseau, successeur de SSL', category: 'securite'),
  LexiqueEntry(term: 'PKI',   definition: 'Public Key Infrastructure — infrastructure de creation, distribution et gestion des certificats numeriques', category: 'securite'),
  LexiqueEntry(term: 'MFA',   definition: 'Multi-Factor Authentication — authentification renforcee exigeant au moins deux facteurs de verification differents', category: 'securite'),
  LexiqueEntry(term: 'IDS',   definition: 'Intrusion Detection System — systeme qui surveille le reseau et alerte en cas d\'activite suspecte', category: 'securite'),
  LexiqueEntry(term: 'IPS',   definition: 'Intrusion Prevention System — systeme qui detecte et bloque activement les intrusions reseau', category: 'securite'),
  LexiqueEntry(term: 'DMZ',   definition: 'Demilitarized Zone — zone reseau intermediaire isolant les serveurs accessibles depuis Internet du reseau interne', category: 'securite'),
  LexiqueEntry(term: 'AES',   definition: 'Advanced Encryption Standard — algorithme de chiffrement symetrique standard utilise pour securiser les donnees', category: 'securite'),
  LexiqueEntry(term: 'SHA',   definition: 'Secure Hash Algorithm — famille d\'algorithmes produisant une empreinte numerique unique d\'un fichier ou message', category: 'securite'),
  LexiqueEntry(term: 'RBAC',  definition: 'Role-Based Access Control — modele de controle d\'acces ou les permissions sont attribuees selon les roles des utilisateurs', category: 'securite'),
  LexiqueEntry(term: 'SOC',   definition: 'Security Operations Center — equipe et outils dedies a la surveillance permanente de la securite du systeme d\'information', category: 'securite'),
  LexiqueEntry(term: 'SIEM',  definition: 'Security Information and Event Management — plateforme centralisant et analysant les journaux de securite pour detecter les incidents', category: 'securite'),
  LexiqueEntry(term: 'WAF',   definition: 'Web Application Firewall — pare-feu specialise protegeant les applications web contre les attaques (XSS, injection SQL, etc.)', category: 'securite'),
  LexiqueEntry(term: 'XSS',   definition: 'Cross-Site Scripting — injection de scripts malveillants dans une page web pour voler des sessions ou detourner des actions utilisateur', category: 'securite'),
  LexiqueEntry(term: 'CSRF',  definition: 'Cross-Site Request Forgery — attaque poussant un utilisateur authentifie a executer des actions non voulues sur un site de confiance', category: 'securite'),
  // ── Matériel & OS ─────────────────────────────────────────────────────────
  LexiqueEntry(term: 'CPU',   definition: 'Central Processing Unit — processeur central qui execute les instructions des programmes', category: 'materiel'),
  LexiqueEntry(term: 'RAM',   definition: 'Random Access Memory — memoire vive temporaire ou le processeur stocke les donnees en cours de traitement', category: 'materiel'),
  LexiqueEntry(term: 'ROM',   definition: 'Read-Only Memory — memoire permanente en lecture seule contenant le firmware du materiel', category: 'materiel'),
  LexiqueEntry(term: 'SSD',   definition: 'Solid-State Drive — disque de stockage rapide a base de memoire flash, sans piece mecanique', category: 'materiel'),
  LexiqueEntry(term: 'HDD',   definition: 'Hard Disk Drive — disque dur mecanique a plateaux rotatifs, plus lent qu\'un SSD mais moins cher par Go', category: 'materiel'),
  LexiqueEntry(term: 'BIOS',  definition: 'Basic Input/Output System — firmware historique de demarrage des PC, remplace progressivement par l\'UEFI', category: 'materiel'),
  LexiqueEntry(term: 'UEFI',  definition: 'Unified Extensible Firmware Interface — successeur moderne du BIOS offrant demarrage securise et interface graphique', category: 'materiel'),
  LexiqueEntry(term: 'GUI',   definition: 'Graphical User Interface — interface graphique permettant d\'interagir avec un OS via des fenetres, icones et menus', category: 'materiel'),
  LexiqueEntry(term: 'CLI',   definition: 'Command-Line Interface — interface en ligne de commande textuelle permettant d\'administrer un systeme sans interface graphique', category: 'materiel'),
  LexiqueEntry(term: 'VM',    definition: 'Virtual Machine — machine virtuelle emulant un ordinateur complet et fonctionnant sur un hyperviseur', category: 'materiel'),
  LexiqueEntry(term: 'RAID',  definition: 'Redundant Array of Independent Disks — combinaison de disques pour ameliorer la redondance (RAID 1) ou la performance (RAID 0)', category: 'materiel'),
  LexiqueEntry(term: 'OS',    definition: 'Operating System — systeme d\'exploitation gerant les ressources materiel et faisant le lien entre le materiel et les applications', category: 'materiel'),
  LexiqueEntry(term: 'API',   definition: 'Application Programming Interface — interface permettant a deux applications de communiquer en echangeant des donnees selon un contrat defini', category: 'materiel'),
  LexiqueEntry(term: 'SDK',   definition: 'Software Development Kit — ensemble d\'outils, bibliotheques et documentation pour developper des applications sur une plateforme', category: 'materiel'),
  LexiqueEntry(term: 'BSOD',  definition: 'Blue Screen Of Death — ecran bleu Windows signalant une erreur critique systeme ayant provoque l\'arret d\'urgence du noyau', category: 'materiel'),
];
