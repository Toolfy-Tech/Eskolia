import 'dart:math';

/// Une affirmation Vrai / Faux pour le mode swipe.
class TrueFalseItem {
  const TrueFalseItem({
    required this.statement,
    required this.answer,
    required this.explanation,
  });

  final String statement;
  final bool answer;
  final String explanation;
}

/// Repository pour le mode Vrai/Faux.
/// Note: Le fichier local a été supprimé. Le repository est neutralisé en attendant une nouvelle source.
class TrueFalseRepository {
  static const List<TrueFalseItem> _items = [
    TrueFalseItem(
      statement: "L'adresse IP 192.168.1.255 est une adresse de diffusion (broadcast) dans un sous-réseau /24.",
      answer: true,
      explanation: "Dans un sous-réseau de masque /24 (255.255.255.0), la dernière adresse (255) est réservée à la diffusion générale de ce réseau.",
    ),
    TrueFalseItem(
      statement: "Le port standard pour le protocole HTTPS est le port 80.",
      answer: false,
      explanation: "Le port standard pour HTTPS est le 443. Le port 80 est utilisé pour le protocole HTTP non sécurisé.",
    ),
    TrueFalseItem(
      statement: "Active Directory utilise le protocole LDAP pour interroger et modifier l'annuaire.",
      answer: true,
      explanation: "Active Directory repose sur le protocole LDAP (Lightweight Directory Access Protocol) pour la communication client-serveur et l'exploration de l'annuaire.",
    ),
    TrueFalseItem(
      statement: "Dans le modèle OSI, la couche Transport est la couche 3.",
      answer: false,
      explanation: "La couche Transport est la couche 4 du modèle OSI. La couche 3 est la couche Réseau (IP).",
    ),
    TrueFalseItem(
      statement: "Le RAID 1 offre une tolérance aux pannes en dupliquant les données en miroir sur au moins deux disques.",
      answer: true,
      explanation: "Le RAID 1 crée un miroir exact des données d'un disque sur un autre, permettant au système de continuer à fonctionner si l'un d'eux tombe en panne.",
    ),
    TrueFalseItem(
      statement: "Une adresse IPv6 est codée sur 128 bits.",
      answer: true,
      explanation: "Une adresse IPv6 utilise 128 bits (16 octets), ce qui offre un espace d'adressage considérablement plus grand qu'IPv4 (32 bits).",
    ),
    TrueFalseItem(
      statement: "Le protocole DHCP permet de résoudre des noms de domaine en adresses IP.",
      answer: false,
      explanation: "C'est le rôle du serveur DNS. Le protocole DHCP sert à attribuer dynamiquement des configurations réseau (adresse IP, masque, passerelle) aux hôtes.",
    ),
    TrueFalseItem(
      statement: "Le protocole SSH utilise par défaut le port 22.",
      answer: true,
      explanation: "Le port par défaut pour le shell sécurisé (SSH) est le port TCP 22.",
    ),
    TrueFalseItem(
      statement: "Un commutateur (switch) standard travaille sur la couche 3 du modèle OSI.",
      answer: false,
      explanation: "Un commutateur standard travaille sur la couche 2 (Liaison de données) en utilisant les adresses MAC. Les commutateurs de niveau 3 (Layer 3 switches) font exception mais le commutateur standard reste de couche 2.",
    ),
    TrueFalseItem(
      statement: "PowerShell manipule et retourne des objets plutôt que du texte brut.",
      answer: true,
      explanation: "Contrairement aux shells Unix traditionnels (Bash) qui retournent du texte brut, PowerShell est orienté objet, facilitant le filtrage et la manipulation des structures de données.",
    ),
  ];

  Future<List<TrueFalseItem>> loadAll() async {
    return _items;
  }

  /// Mélange et retourne au plus [count] cartes pour une partie.
  Future<List<TrueFalseItem>> loadRound({int count = 10, Random? rng}) async {
    final list = List<TrueFalseItem>.from(_items);
    list.shuffle(rng);
    return list.take(count).toList();
  }
}
