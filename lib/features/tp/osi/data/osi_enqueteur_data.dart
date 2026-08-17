import '../models/osi_incident_case_model.dart';

abstract final class OsiEnqueteurData {
  OsiEnqueteurData._();

  static const List<OsiIncidentCase> cases = [
    // --- CAS 1 (Couche 1 - Physique) ---
    OsiIncidentCase(
      id: 'case_phys_rj45',
      ticketNumber: 'INC-2024-101',
      userRole: 'Secrétaire de direction',
      userComplaint: 'Mon PC n\'a plus du tout Internet depuis que la femme de ménage a passé l\'aspirateur sous mon bureau.',
      technicalSymptoms: [
        'Icône réseau Windows : "Câble réseau non branché" (Croix rouge)',
        'LED d\'activité du port RJ45 de la tour : Éteinte',
        'Commande "ipconfig" : "Statut du média : Déconnecté"',
        'Le switch de l\'étage affiche le port 14 en état DOWN / Link Down',
      ],
      correctLayerNumber: 1,
      diagnosticHint: 'La couche physique gère les câbles, connecteurs et signaux électriques.',
      actions: [
        OsiSupportAction(
          id: 'a1',
          title: 'Vérifier et ré-enclencher le câble RJ45 sous le bureau ou le remplacer s\'il est pincé/endommagé.',
          isCorrect: true,
          explanation: 'L\'absence de signal électrique et la LED éteinte confirment une rupture de liaison physique en Couche 1.',
        ),
        OsiSupportAction(
          id: 'a2',
          title: 'Modifier le serveur DNS dans les paramètres de la carte réseau pour mettre 8.8.8.8.',
          isCorrect: false,
          explanation: 'Le DNS est en Couche 7 et nécessite une liaison réseau opérationnelle pour être contacté.',
        ),
        OsiSupportAction(
          id: 'a3',
          title: 'Exécuter "route add default 192.168.1.1" dans l\'invite de commande.',
          isCorrect: false,
          explanation: 'Le routage est en Couche 3 ; il ne peut pas résoudre une déconnexion matérielle de câble.',
        ),
      ],
      fullRcaExplanation: 'L\'incident provenait d\'un arrachement physique du connecteur RJ45 lors du passage de l\'aspirateur. Sans liaison physique (Couche 1), aucun signal ne parvient à la carte réseau.',
    ),

    // --- CAS 2 (Couche 2 - Liaison / VLAN / ARP) ---
    OsiIncidentCase(
      id: 'case_link_vlan',
      ticketNumber: 'INC-2024-202',
      userRole: 'Technicien comptabilité',
      userComplaint: 'Je viens de changer de bureau, mais impossible de joindre le serveur comptable ni les autres postes de mon équipe.',
      technicalSymptoms: [
        'LED de lien RJ45 : Verte clignotante (Lien physique OK)',
        'Adresse IP obtenue : 192.168.50.12 (Réseau Visiteurs / VLAN 50)',
        'Le serveur comptable est sur 192.168.10.200 (VLAN 10 Comptabilité)',
        'Impossible de pinger la passerelle 192.168.10.1',
        'Le port du switch est assigné en mode Access VLAN 50 au lieu de VLAN 10',
      ],
      correctLayerNumber: 2,
      diagnosticHint: 'Les VLANs (802.1Q) et la commutation locale opèrent en couche Liaison de données.',
      actions: [
        OsiSupportAction(
          id: 'b1',
          title: 'Reconfigurer le port du switch d\'étage dans le bon VLAN (VLAN 10 Comptabilité).',
          isCorrect: true,
          explanation: 'L\'affectation du port de commutateur au bon VLAN (Couche 2) permet de réintégrer le broadcast domain approprié.',
        ),
        OsiSupportAction(
          id: 'b2',
          title: 'Réinstaller le pilote de la carte graphique du PC.',
          isCorrect: false,
          explanation: 'La carte graphique n\'a aucun lien avec la segmentation réseau.',
        ),
        OsiSupportAction(
          id: 'b3',
          title: 'Désactiver le pare-feu Windows sur le serveur comptable.',
          isCorrect: false,
          explanation: 'Le problème est un mauvais cloisonnement de réseau local (VLAN L2), pas un blocage de firewall.',
        ),
      ],
      fullRcaExplanation: 'Le brassage de la prise murale était raccordé à un port configuré sur le VLAN 50. La reconfiguration du port switch en VLAN 10 a rétabli l\'accès immédiat.',
    ),

    // --- CAS 3 (Couche 3 - Réseau / Passerelle / Routage) ---
    OsiIncidentCase(
      id: 'case_net_gateway',
      ticketNumber: 'INC-2024-303',
      userRole: 'Responsable logistique',
      userComplaint: 'J\'accède à l\'imprimante de mon bureau (192.168.1.20) mais aucun site web externe ne s\'ouvre (ex: chronopost.fr).',
      technicalSymptoms: [
        'ping 192.168.1.20 (Imprimante locale) : Succès 100% (4/4 reçus)',
        'ping 192.168.1.1 (Passerelle / Routeur) : Réponse impossible / Hôte de destination inaccessible',
        'Commande "ipconfig" : Passerelle par défaut vide ou saisie en 192.168.2.1 par erreur',
        'ping 8.8.8.8 : "Délai d\'attente de la demande dépassé"',
      ],
      correctLayerNumber: 3,
      diagnosticHint: 'L\'adressage IP, les sous-réseaux et la passerelle par défaut appartiennent à la couche Réseau.',
      actions: [
        OsiSupportAction(
          id: 'c1',
          title: 'Corriger la passerelle par défaut (Default Gateway) dans la configuration IPv4 pour renseigner 192.168.1.1.',
          isCorrect: true,
          explanation: 'Sans passerelle valide sur le même sous-réseau en Couche 3, les paquets à destination d\'autres réseaux ne peuvent pas être routés.',
        ),
        OsiSupportAction(
          id: 'c2',
          title: 'Changer le câble réseau par un câble blindé Cat 7.',
          isCorrect: false,
          explanation: 'Le ping vers l\'imprimante locale fonctionne, la couche 1 et la couche 2 sont donc parfaitement fonctionnelles.',
        ),
        OsiSupportAction(
          id: 'c3',
          title: 'Vider le cache du navigateur Chrome (Ctrl + F5).',
          isCorrect: false,
          explanation: 'Le ping vers 8.8.8.8 échoue également en invite de commande, le souci est réseau et non lié au navigateur.',
        ),
      ],
      fullRcaExplanation: 'La passerelle par défaut était mal configurée sur le poste client, empêchant le système d\'envoyer les paquets IP hors du sous-réseau local (Couche 3).',
    ),

    // --- CAS 4 (Couche 4 - Transport / Ports / Firewall L4) ---
    OsiIncidentCase(
      id: 'case_trans_port',
      ticketNumber: 'INC-2024-404',
      userRole: 'Développeur Junior',
      userComplaint: 'Mon serveur web écoute sur le port 8080, mais mes collègues reçoivent "Connexion refusée" lorsqu\'ils tentent de s\'y connecter.',
      technicalSymptoms: [
        'ping de l\'IP du serveur : Succès (0% de perte, RTT < 1ms)',
        'Test PowerShell "Test-NetConnection 192.168.1.45 -Port 8080" : TcpTestSucceeded = False',
        'Commande "netstat -ano" sur le serveur : LISTENING sur 127.0.0.1:8080 (Boucle locale uniquement) au lieu de 0.0.0.0:8080',
        'Le pare-feu bloque également les connexions entrantes sur le port TCP 8080',
      ],
      correctLayerNumber: 4,
      diagnosticHint: 'Les ports TCP/UDP, les sockets d\'écoute et les règles de filtrage de port relèvent de la couche Transport.',
      actions: [
        OsiSupportAction(
          id: 'd1',
          title: 'Lier le service web à 0.0.0.0 et ouvrir le port TCP 8080 dans le pare-feu du serveur.',
          isCorrect: true,
          explanation: 'La couche Transport (TCP) requiert que le port soit en écoute sur l\'interface réseau externe et autorisé par le filtrage L4.',
        ),
        OsiSupportAction(
          id: 'd2',
          title: 'Acheter un nouveau nom de domaine chez un registrar.',
          isCorrect: false,
          explanation: 'Le test est fait directement par adresse IP et port TCP.',
        ),
        OsiSupportAction(
          id: 'd3',
          title: 'Changer le masque de sous-réseau de /24 en /16.',
          isCorrect: false,
          explanation: 'Le ping fonctionne parfaitement en couche 3, modifier le masque est inutile et risqué.',
        ),
      ],
      fullRcaExplanation: 'Le socket TCP était restreint à localhost (127.0.0.1) et le port 8080 était fermé en entrée. En couche 4, les paquets SYN entrants étaient rejetés avec un flag TCP RST.',
    ),

    // --- CAS 5 (Couche 7 - Application / DNS) ---
    OsiIncidentCase(
      id: 'case_app_dns',
      ticketNumber: 'INC-2024-705',
      userRole: 'Directeur commercial',
      userComplaint: 'Je n\'arrive pas à aller sur google.fr ("Serveur introuvable"), pourtant mon collègue me dit qu\'Internet marche très bien.',
      technicalSymptoms: [
        'ping 8.8.8.8 (IP directe) : Succès 100% (Temps = 12ms)',
        'ping google.fr : "La requête Ping n\'a pas pu trouver l\'hôte google.fr. Vérifiez le nom et essayez à nouveau."',
        'Commande "nslookup google.fr" : "DNS request timed out. Serveur : 192.168.1.250 (Serveur DNS local éteint)"',
      ],
      correctLayerNumber: 7,
      diagnosticHint: 'Le DNS (Domain Name System) est un protocole de couche Application qui traduit les noms de domaine en IP.',
      actions: [
        OsiSupportAction(
          id: 'e1',
          title: 'Modifier les serveurs DNS de la machine ou du DHCP pour pointer vers un résolveur DNS actif (ex: 1.1.1.1 ou DNS d\'entreprise fonctionnel).',
          isCorrect: true,
          explanation: 'Puisque la connectivité IP (Couche 3) est parfaite vers 8.8.8.8, l\'échec est purement applicatif lors de la résolution de nom DNS (Couche 7).',
        ),
        OsiSupportAction(
          id: 'e2',
          title: 'Rebrancher la prise électrique de l\'écran de l\'ordinateur.',
          isCorrect: false,
          explanation: 'L\'utilisateur voit le message d\'erreur, son écran fonctionne.',
        ),
        OsiSupportAction(
          id: 'e3',
          title: 'Changer l\'adresse MAC de la carte réseau.',
          isCorrect: false,
          explanation: 'La couche liaison fonctionne très bien puisque les paquets IP circulent jusqu\'à 8.8.8.8.',
        ),
      ],
      fullRcaExplanation: 'Le serveur DNS configuré était hors service. L\'utilisateur n\'arrivait pas à résoudre les noms d\'hôtes applicatifs en Couche 7, bien que la route IP soit totalement opérationnelle.',
    ),

    // --- CAS 6 (Couche 6 - Présentation / Certificat TLS) ---
    OsiIncidentCase(
      id: 'case_pres_ssl',
      ticketNumber: 'INC-2024-606',
      userRole: 'Client e-commerce',
      userComplaint: 'Mon navigateur affiche un cadenas rouge barré avec "NET::ERR_CERT_DATE_INVALID" et bloque mon paiement.',
      technicalSymptoms: [
        'ping mondomaine.com : Succès',
        'Connexion TCP sur le port 443 : Établie avec succès (SYN-ACK)',
        'Négociation TLS : Échec lors de la validation de la chaîne de confiance',
        'Détails du certificat serveur : Date d\'expiration dépassée depuis hier (Expired Certificate)',
      ],
      correctLayerNumber: 6,
      diagnosticHint: 'Le chiffrement, la gestion des certificats TLS/SSL et le formatage sécurisé relèvent de la couche Présentation.',
      actions: [
        OsiSupportAction(
          id: 'f1',
          title: 'Renouveler et installer le certificat TLS/SSL à jour sur le serveur web.',
          isCorrect: true,
          explanation: 'La couche Présentation (TLS) rejette la connexion car le certificat garantissant le chiffrement et l\'authenticité a expiré.',
        ),
        OsiSupportAction(
          id: 'f2',
          title: 'Redémarrer la box Internet du client.',
          isCorrect: false,
          explanation: 'Le problème se situe sur le certificat hébergé sur le serveur web distant.',
        ),
        OsiSupportAction(
          id: 'f3',
          title: 'Remplacer les serveurs DHCP du réseau local.',
          isCorrect: false,
          explanation: 'Le DHCP n\'intervient pas dans la validation des certificats SSL/TLS.',
        ),
      ],
      fullRcaExplanation: 'Le certificat TLS avait expiré, provoquant l\'interruption immédiate de la couche Présentation (Couche 6) avant tout échange de données applicatives chiffrées.',
    ),

    // --- CAS 7 (Couche 2 - Liaison / Tempête de Broadcast / STP) ---
    OsiIncidentCase(
      id: 'case_link_loop',
      ticketNumber: 'INC-2024-207',
      userRole: 'Administrateur réseau',
      userComplaint: 'Tout le réseau local de l\'entreprise est complètement saturé, les voyants de tous les switches clignotent frénétiquement.',
      technicalSymptoms: [
        'Wireshark montre des millions de trames ARP Broadcast par seconde (Broadcast Storm)',
        'Utilisation CPU des commutateurs d\'accès à 100%',
        'Un technicien a branché un câble RJ45 entre deux ports du même switch dans une salle de réunion',
        'Le protocole Spanning Tree (STP 802.1D / RSTP) était désactivé sur ce switch',
      ],
      correctLayerNumber: 2,
      diagnosticHint: 'Les boucles de commutation de trames et le protocole Spanning Tree (STP) opèrent en couche Liaison de données.',
      actions: [
        OsiSupportAction(
          id: 'g1',
          title: 'Débrancher le câble formant la boucle et activer Spanning Tree Protocol (STP / BPDU Guard) sur tous les switches.',
          isCorrect: true,
          explanation: 'En Couche 2, les trames Ethernet ne possèdent pas de champ TTL : une boucle physique provoque une tempête de broadcast infinie si STP n\'est pas activé.',
        ),
        OsiSupportAction(
          id: 'g2',
          title: 'Changer le mot de passe administrateur du contrôleur de domaine Active Directory.',
          isCorrect: false,
          explanation: 'Aucun rapport avec une boucle physique de commutation.',
        ),
        OsiSupportAction(
          id: 'g3',
          title: 'Ajouter des règles iptables de niveau 7 pour bloquer HTTP.',
          isCorrect: false,
          explanation: 'La saturation est causée par des trames de diffusion (Broadcast) en couche 2.',
        ),
      ],
      fullRcaExplanation: 'L\'absence de TTL dans l\'en-tête de trame Ethernet (Couche 2) a provoqué une boucle infinie de diffusion. L\'activation de STP isole automatiquement les ports en boucle.',
    ),

    // --- CAS 8 (Couche 3 - Réseau / Conflit d'adresse IP) ---
    OsiIncidentCase(
      id: 'case_net_ip_conflict',
      ticketNumber: 'INC-2024-308',
      userRole: 'Infographiste',
      userComplaint: 'Windows m\'affiche une alerte "Une autre machine sur ce réseau possède la même adresse IP" et mes transferts se coupent.',
      technicalSymptoms: [
        'Notification Windows : Conflit d\'adresse IP détecté',
        'Le PC a été configuré manuellement en IP fixe 192.168.1.100',
        'Le serveur DHCP a alloué 192.168.1.100 à l\'ordinateur d\'un stagiaire dans sa plage dynamique',
        'La table ARP du routeur oscille en permanence entre deux adresses MAC différentes (ARP Flapping)',
      ],
      correctLayerNumber: 3,
      diagnosticHint: 'L\'unicité de l\'adresse IP logique au sein d\'un sous-réseau est une exigence de la couche Réseau.',
      actions: [
        OsiSupportAction(
          id: 'h1',
          title: 'Passer le poste en attribution DHCP automatique ou exclure l\'IP fixe de la plage de distribution DHCP.',
          isCorrect: true,
          explanation: 'La couche Réseau (IP) exige une adresse logique unique par interface pour que le routage et l\'adressage soient cohérents.',
        ),
        OsiSupportAction(
          id: 'h2',
          title: 'Réinstaller Windows 11 sur les deux machines.',
          isCorrect: false,
          explanation: 'Une simple modification de configuration IP suffit.',
        ),
        OsiSupportAction(
          id: 'h3',
          title: 'Changer le connecteur de la fibre optique du bâtiment.',
          isCorrect: false,
          explanation: 'Le problème est d\'ordre logique IP et non d\'infrastructure optique.',
        ),
      ],
      fullRcaExplanation: 'Deux machines partageaient la même adresse IPv4 (Couche 3), créant une instabilité de routage local et des déconnexions aléatoires.',
    ),
  ];
}
