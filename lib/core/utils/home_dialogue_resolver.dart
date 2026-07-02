class HomeDialogue {
  final String question;
  final String answer;

  HomeDialogue({required this.question, required this.answer});
}

class HomeDialogueResolver {
  /// Convertit une astuce brute en un dialogue élève-prof.
  static HomeDialogue getDialogueForTip(String rawTip) {
    // Nettoyer l'astuce de ses préfixes d'émojis
    var cleanTip = rawTip.trim();
    if (cleanTip.startsWith('💬')) {
      cleanTip = cleanTip.substring(1).trim();
    } else if (cleanTip.startsWith('\u{1F4AC}')) {
      cleanTip = cleanTip.substring(1).trim();
    }

    final lower = cleanTip.toLowerCase();

    // Mots-clés et questions personnalisées associées
    String question = "Monsieur, à quoi sert ce concept ?";
    
    if (lower.contains('cpu') && lower.contains('chipset')) {
      question = "Quelle est la différence entre le processeur (CPU) et le chipset ?";
    } else if (lower.contains('ram') && lower.contains('volatile')) {
      question = "La mémoire RAM conserve-t-elle ses données après l'extinction du PC ?";
    } else if (lower.contains('uefi')) {
      question = "Pourquoi utilise-t-on l'UEFI à la place du vieux BIOS ?";
    } else if (lower.contains('post')) {
      question = "Que se passe-t-il exactement lors du POST au démarrage de l'ordinateur ?";
    } else if (lower.contains('tpm')) {
      question = "À quoi sert la puce TPM 2.0 requise par Windows 11 ?";
    } else if (lower.contains('ntfs') && lower.contains('fat32')) {
      question = "Quels sont les avantages du système de fichiers NTFS par rapport au FAT32 ?";
    } else if (lower.contains('bitlocker')) {
      question = "Que se passe-t-il si je perds ma clé de récupération BitLocker ?";
    } else if (lower.contains('registre')) {
      question = "Où Windows stocke-t-il sa base de configuration générale ?";
    } else if (lower.contains('restauration')) {
      question = "Un point de restauration Windows sauvegarde-t-il mes documents personnels ?";
    } else if (lower.contains('dism') || lower.contains('sfc')) {
      question = "Quels outils utiliser en cas de corruption de fichiers Windows ?";
    } else if (lower.contains('linux') && lower.contains('chmod')) {
      question = "Quelles sont les commandes indispensables du terminal Linux ?";
    } else if (lower.contains('posix') || lower.contains('rwx')) {
      question = "Comment fonctionnent les droits d'accès sous Linux ?";
    } else if (lower.contains('mac') && lower.contains('ip')) {
      question = "Quelle différence y a-t-il entre une adresse MAC et une adresse IP ?";
    } else if (lower.contains('ping') && lower.contains('ttl')) {
      question = "Comment interpréter un délai expiré ou un échec de ping ?";
    } else if (lower.contains('dhcp')) {
      question = "Comment les machines obtiennent-elles leur configuration IP sans intervention ?";
    } else if (lower.contains('vlan')) {
      question = "Comment diviser un réseau physique pour isoler les services ?";
    } else if (lower.contains('spanning') || lower.contains('stp')) {
      question = "Comment éviter que des boucles réseau ne fassent planter mon commutateur ?";
    } else if (lower.contains('arp') && lower.contains('mac')) {
      question = "Comment une carte réseau trouve-t-elle l'adresse physique (MAC) associée à une IP ?";
    } else if (lower.contains('wi-fi') || lower.contains('wifi')) {
      question = "Quelle est la règle d'or pour installer des bornes Wi-Fi d'entreprise ?";
    } else if (lower.contains('vpn')) {
      question = "Un VPN protège-t-il entièrement un poste contre les cybermenaces ?";
    } else if (lower.contains('ou') && lower.contains('active directory')) {
      question = "Comment structurer mon annuaire Active Directory ?";
    } else if (lower.contains('gpo') && lower.contains('lsdou')) {
      question = "Dans quel ordre s'appliquent les stratégies de groupe (GPO) dans l'AD ?";
    } else if (lower.contains('srv') && lower.contains('dns')) {
      question = "Comment les postes clients trouvent-ils les serveurs LDAP de l'Active Directory ?";
    } else if (lower.contains('smb') || lower.contains('ntfs') && lower.contains('partages')) {
      question = "Si j'autorise un partage SMB mais l'interdis en NTFS, que se passe-t-il ?";
    } else if (lower.contains('contrôleur de domaine') || lower.contains('ad ds')) {
      question = "Quel est le rôle d'un contrôleur de domaine (DC) ?";
    } else if (lower.contains('exchange')) {
      question = "Comment Microsoft assure-t-il la disponibilité de la messagerie Office 365 ?";
    } else if (lower.contains('entra id') || lower.contains('azure ad')) {
      question = "Comment sécuriser et centraliser les accès à mes applications Cloud ?";
    } else if (lower.contains('intune')) {
      question = "Comment administrer à distance une flotte d'ordinateurs et de mobiles ?";
    } else if (lower.contains('autopilot')) {
      question = "Comment déployer un nouveau PC d'entreprise sans le configurer à la main ?";
    } else if (lower.contains('wim') || lower.contains('mdt')) {
      question = "Comment capturer un système d'exploitation Windows prêt à être déployé ?";
    } else if (lower.contains('pxe')) {
      question = "Comment installer un système d'exploitation sans clé USB ?";
    } else if (lower.contains('wsus')) {
      question = "Comment gérer le déploiement des mises à jour Windows en entreprise ?";
    } else if (lower.contains('hyperviseur') || lower.contains('esxi')) {
      question = "Quelle est la particularité d'un hyperviseur de Type 1 ?";
    } else if (lower.contains('vswitch')) {
      question = "Comment les machines virtuelles (VM) communiquent-elles entre elles ?";
    } else if (lower.contains('3-2-1')) {
      question = "Quelle est la règle fondamentale pour ne jamais perdre ses sauvegardes ?";
    } else if (lower.contains('rpo') || lower.contains('rto')) {
      question = "Quels sont les indicateurs clés d'un plan de reprise d'activité (PRA) ?";
    } else if (lower.contains('immuable') || lower.contains('worm')) {
      question = "Comment protéger mes sauvegardes contre les ransomwares ?";
    } else if (lower.contains('phishing')) {
      question = "Comment se prémunir contre la principale menace de sécurité par email ?";
    } else if (lower.contains('mfa')) {
      question = "Quelle mesure simple bloque la plupart des piratages de comptes ?";
    } else if (lower.contains('zero trust')) {
      question = "Quel est le grand principe de la sécurité réseau moderne ?";
    } else if (lower.contains('edr')) {
      question = "Pourquoi installer un EDR à la place d'un antivirus traditionnel ?";
    } else if (lower.contains('segmentation')) {
      question = "Comment bloquer un pirate s'il réussit à s'infiltrer sur un poste ?";
    } else if (lower.contains('qos')) {
      question = "Comment garantir la qualité des appels VoIP sur un réseau encombré ?";
    } else if (lower.contains('fibre')) {
      question = "Le débit de la fibre optique est-il garanti de bout en bout ?";
    } else if (lower.contains('bgp')) {
      question = "Comment les routeurs d'Internet s'échangent-ils les routes mondiales ?";
    } else if (lower.contains('ospf')) {
      question = "Comment optimiser la convergence du routage OSPF sur un grand réseau ?";
    }

    return HomeDialogue(question: question, answer: cleanTip);
  }

  /// Retourne les messages d'accueil et d'onboarding sous forme de dialogues.
  static List<HomeDialogue> getFeatureMessages(String username, int streak) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Bonjour' : (hour < 18 ? 'Bon après-midi' : 'Bonsoir');
    final name = username.isNotEmpty ? username : "l'ami";

    final list = <HomeDialogue>[
      HomeDialogue(
        question: "Bonjour Professeur ! Ravi de vous retrouver aujourd'hui.",
        answer: "$greeting $name ! Prêt à relever de nouveaux défis de veille et d'apprentissage ?",
      ),
    ];

    if (streak >= 1) {
      list.add(HomeDialogue(
        question: "Où en est ma série de connexions consécutives ?",
        answer: "Signal stable ! Série active de $streak jour${streak > 1 ? "s" : ""} ! Continue à te connecter chaque jour pour débloquer des badges exclusifs.",
      ));
    }

    // Ajout des descriptions de features sous forme de dialogue
    list.addAll([
      HomeDialogue(
        question: "Comment puis-je m'entraîner en autonomie sur Eskolia ?",
        answer: "Utilise le mode **Solo** ! Tu as le Vrai/Faux pour de l'évaluation rapide, le mode Survival (3 vies) pour te dépasser, ou la Maîtrise pour composer un quiz sur-mesure.",
      ),
      HomeDialogue(
        question: "C'est quoi cet onglet « Mon IA » dans le menu ?",
        answer: "C'est ton tuteur virtuel Optimus. Tu peux dialoguer avec lui, lui demander d'expliquer un concept ou de te générer des exercices pratiques.",
      ),
      HomeDialogue(
        question: "À quoi sert la fonctionnalité « Mon Bloc-notes » ?",
        answer: "Enregistre tes cours ou notes en Markdown. Notre IA analysera ton texte pour générer instantanément un QCM adapté à tes révisions !",
      ),
      HomeDialogue(
        question: "Comment puis-je proposer de nouvelles questions de quiz ?",
        answer: "Rends-toi dans **Le Labo** ! C'est notre espace de recherche : soumets tes questions, le professeur les valide et elles rejoindront le parcours officiel !",
      ),
      HomeDialogue(
        question: "Peut-on réviser à plusieurs sur la plateforme ?",
        answer: "Absolument. Va dans l'onglet **Lobbys** pour rejoindre ou créer un salon multijoueur. Affronte tes camarades en direct sur des séries de questions !",
      ),
      HomeDialogue(
        question: "Comment fonctionne le système d'expérience (XP) ?",
        answer: "Chaque bonne réponse et chaque TP validé te rapportent de l'XP. Monte dans le **Classement** hebdomadaire et tente de te qualifier pour la ligue supérieure.",
      ),
      HomeDialogue(
        question: "Qu'est-ce qu'on fait dans les « Travaux Pratiques (TP) » ?",
        answer: "Ce sont des pannes réseau, du script PowerShell et de l'administration Active Directory en environnement simulé. Une vraie expérience d'administrateur !",
      ),
      HomeDialogue(
        question: "Où puis-je consulter des fiches mémo et des cours rapides ?",
        answer: "L'onglet **Documentation** centralise des mini-cours synthétiques et fiches mémo sur les normes (ITIL, RGPD, ANSSI) et les technologies clés (Modèle OSI).",
      ),
      HomeDialogue(
        question: "Comment suivre mes succès sur la plateforme ?",
        answer: "L'onglet **Hauts faits** liste tous tes badges débloqués (Série de connexion, Sans-faute, Soumission Labo...). Tente de tous les obtenir !",
      ),
      HomeDialogue(
        question: "Comment ajouter mes propres sites d'actualité technologique ?",
        answer: "Clique sur le bouton **Flux & Sources** sur ton Espace Veille. Saisis le nom et l'URL RSS pour générer ta propre carte d'actualité personnalisée !",
      ),
    ]);

    return list;
  }
}
