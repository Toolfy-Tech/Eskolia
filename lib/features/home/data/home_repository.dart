import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/repositories/user_repository.dart';
import '../../auth/data/user_model.dart';
import '../../lobby/data/lobby_repository.dart';

class HomeRepository {
  HomeRepository({
    UserRepository? userRepo,
    LobbyRepository? lobbyRepo,
  })  : _userRepo = userRepo ?? UserRepository(),
        _lobbyRepo = lobbyRepo ?? LobbyRepository();

  final UserRepository _userRepo;
  final LobbyRepository _lobbyRepo;

  Stream<UserModel?> watchCurrentUser() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream<UserModel?>.value(null);
    return _userRepo.watchUser(uid);
  }

  /// Aperçu des lobbies rejoignables (même logique que l’écran Multijoueur).
  Stream<List<LobbyModel>> watchHomeLobbiesPreview({int maxItems = 5}) {
    return _lobbyRepo.watchLobbies().map((all) {
      final open = all
          .where(
            (l) =>
                (l.status == 'waiting' || l.status == 'in_progress') && !l.isFull,
          )
          .toList();
      open.sort((a, b) {
        final wa = a.status == 'waiting' ? 0 : 1;
        final wb = b.status == 'waiting' ? 0 : 1;
        if (wa != wb) return wa.compareTo(wb);
        return b.createdAt.compareTo(a.createdAt);
      });
      if (open.length <= maxItems) return open;
      return open.sublist(0, maxItems);
    });
  }

  Future<UserModel?> getCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return _userRepo.getUserById(uid);
  }

  List<String> getLocalTips() {
    const bubble = '\u{1F4AC}';
    return [
      // Matériel & firmware
      '$bubble Le CPU exécute les instructions ; le chipset relie CPU, RAM et bus.',
      '$bubble La RAM volatile se vide à la coupure d\'alimentation - la NVMe/SSD non.',
      '$bubble L\'UEFI remplace le BIOS classique et gère Secure Boot + démarrage GPT.',
      '$bubble Un POST au boot vérifie CPU, RAM et périphériques avant chargement OS.',
      '$bubble Le TPM 2.0 sert au chiffrement (BitLocker) et à l\'intégrité du démarrage.',
      // Windows & stockage
      '$bubble NTFS gère journaux, quotas et permissions bien plus fines que FAT32/exFAT.',
      '$bubble Un volume BitLocker chiffre tout le disque - garde la clé de récupération !',
      '$bubble Le registre Windows centralise paramètres système et applications (HKLM/HKCU).',
      '$bubble Les points de restauration sauvent l\'état système, pas toujours vos fichiers perso.',
      '$bubble DISM / SFC réparent l\'image Windows et les fichiers système corrompus.',
      // Linux bases
      '$bubble Sous Linux, `ls`, `cd`, `chmod` et `systemctl` sont le quotidien admin.',
      '$bubble Les permissions POSIX (rwx) s\'appliquent à user / groupe / autres.',
      // Réseau LAN
      '$bubble Une adresse MAC est unique au NIC ; l\'IP peut changer (DHCP).',
      '$bubble Le ping mesure la latence ; un TTL expiré peut indiquer une boucle ou filtrage.',
      '$bubble Le DHCP attribue IP, masque, passerelle et DNS automatiquement.',
      '$bubble Un VLAN segmente logiquement un LAN sans multiplier les câbles.',
      '$bubble Le spanning tree (STP) bloque les ports pour éviter les boucles L2.',
      '$bubble ARP associe IP -> MAC sur le même sous-réseau.',
      '$bubble Un Wi-Fi bien dimensionné limite le chevauchement des canaux.',
      // VPN & accès distant
      '$bubble Un VPN chiffre le tunnel ; il ne remplace pas MFA ni antivirus.',
      // Active Directory & DNS
      '$bubble Une OU Active Directory structure utilisateurs, ordinateurs et délégations.',
      '$bubble Les GPO s\'appliquent selon l\'ordre LSDOU (Local, Site, Domain, OU).',
      '$bubble Un enregistrement DNS SRV indique où trouver LDAP ou Kerberos.',
      '$bubble Les partages SMB + permissions NTFS se combinent (la plus restrictive l\'emporte).',
      '$bubble Un contrôleur de domaine héberge AD DS, DNS intégré et souvent DHCP.',
      // Messagerie & collaboration
      '$bubble Exchange Online repose sur des bases DAG haute dispo côté Microsoft 365.',
      // Cloud & identité
      '$bubble Entra ID (Azure AD) gère identité cloud, MFA et accès conditionnel.',
      '$bubble Intune pousse politiques et apps sur postes Windows, iOS, Android.',
      '$bubble Autopilot pré-enrôle un PC pour une expérience OOBE quasi zéro touch.',
      // Industrialisation & déploiement
      '$bubble Une image master WIM capture un poste de référence avant déploiement MDT/SCCM.',
      '$bubble Le boot PXE permet d\'installer un OS depuis le réseau sans clé USB.',
      '$bubble WSUS centralise les mises à jour Microsoft en intranet.',
      // Virtualisation
      '$bubble Un hyperviseur type 1 (ESXi, Hyper-V bare metal) n\'a pas d\'OS hôte classique.',
      '$bubble Le vSwitch virtuel relie les VM comme un switch physique.',
      // Sauvegardes & ITIL
      '$bubble Règle 3-2-1 : 3 copies, 2 supports, 1 hors site (ou cloud immuable).',
      '$bubble RPO = données max acceptables perdues ; RTO = délai max pour reprendre le service.',
      '$bubble Une sauvegarde immuable (WORM) résiste à un ransomware qui efface les backups.',
      // Cybersécurité
      '$bubble Le phishing reste le vecteur N°1 : vérifier l\'expéditeur avant tout clic.',
      '$bubble MFA bloque la majorité des compromissions de comptes "mot de passe volé".',
      '$bubble Zero Trust : ne jamais faire confiance par défaut, vérifier à chaque accès.',
      '$bubble Un EDR surveille comportements suspects au-delà d\'un simple antivirus.',
      '$bubble La segmentation réseau limite le mouvement latéral après intrusion.',
      // Réseau avancé (rappels)
      '$bubble QoS marque les paquets pour prioriser VoIP et visioconférence.',
      '$bubble En fibre, la latence est faible mais le débit dépend toujours du lien d\'accès.',
      '$bubble BGP annonce les préfixes entre AS ; une erreur de filtre peut impacter l\'Internet.',
      '$bubble OSPF converge vite en zone unique ; segmenter réduit les LSA storms.',
    ];
  }
}
