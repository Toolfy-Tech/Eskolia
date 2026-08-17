import 'package:flutter/material.dart';

class FeatureInfo {
  final String title;
  final String description;
  final String emoji;

  const FeatureInfo({
    required this.title,
    required this.description,
    required this.emoji,
  });
}

class FeatureInfoResolver {
  static const Map<String, FeatureInfo> _infos = {
    'feature:ai': FeatureInfo(
      title: 'Mon Tuteur IA',
      description: 'Discutez en direct avec Optimus, votre tuteur IA disponible 24h/24 pour vous guider.\n\n• **Explications sur-mesure** : Posez des questions sur des concepts IT complexes (ex: modèle OSI, DNS, sous-réseaux).\n• **Génération d\'exercices** : Demandez-lui de générer des questions, des cas pratiques ou des QCM spécifiques.\n• **Aide au débogage** : Soumettez-lui des scripts PowerShell ou Bash pour comprendre vos erreurs.',
      emoji: '🧠',
    ),
    'feature:solo': FeatureInfo(
      title: 'Mode Solo',
      description: 'Accédez à tous les modes d\'entraînement individuels pour réviser à votre rythme.\n\n• **Vrai/Faux** : Évaluez rapidement vos réflexes sur des affirmations techniques.\n• **Mode Survie** : Testez vos limites avec seulement 3 vies pour faire le meilleur score.\n• **Lexique interactif** : Révisez et testez vos connaissances sur l\'ensemble des sigles et définitions de la formation.',
      emoji: '🎮',
    ),
    'feature:solo_quiz': FeatureInfo(
      title: 'Générateur de Quiz',
      description: 'Créez des quiz sur-mesure pour vous entraîner de manière ciblée.\n\n• **Sélection thématique** : Choisissez un ou plusieurs thèmes (Hardware, Windows Server, Réseaux, Sécurité...).\n• **Paramétrage libre** : Définissez le nombre de questions, le niveau de difficulté (Facile, Moyen, Difficile) et le mode de tirage.\n• **Sources multiples** : Choisissez d\'inclure des questions du parcours officiel, du lexique ou créées par la communauté.',
      emoji: '📝',
    ),
    'feature:solo_quiz_ai': FeatureInfo(
      title: 'Génération avec IA',
      description: 'Générez instantanément des quiz uniques créés en temps réel par l\'intelligence artificielle.\n\n• **Thématique libre** : Saisissez n\'importe quelle technologie ou mot-clé (ex: "Routage OSPF", "Active Directory Trust").\n• **Adaptation dynamique** : L\'IA formule des questions adaptées au niveau choisi (Facile, Moyen, Difficile).\n• **Correction expliquée** : Obtenez des explications pédagogiques détaillées pour chaque réponse proposée par l\'IA.',
      emoji: '🧠',
    ),
    'feature:solo_lacunes': FeatureInfo(
      title: 'Mes fautes',
      description: 'Ce pool regroupe automatiquement toutes les questions auxquelles vous avez répondu incorrectement dans les quiz ou les flashcards.\n\n• **Sortie automatique** : Répondez correctement à une question lors d\'un quiz correctif ou marquez "Je savais" lors des flashcards pour la sortir du pool.\n• **Gestion manuelle** : Utilisez le bouton "Gérer" pour supprimer définitivement des fautes ou les épingler dans vos révisions.\n• **Focus erreurs** : Concentrez vos efforts uniquement sur vos points faibles pour maximiser vos chances de réussite.',
      emoji: '❌',
    ),
    'feature:solo_pool': FeatureInfo(
      title: 'À revoir',
      description: 'Ce pool regroupe les questions que vous avez choisi d\'épingler manuellement pour les garder sous la main.\n\n• **Ajout à la carte** : Épinglez des questions complexes à la fin d\'un quiz ou depuis le volet de gestion de vos fautes.\n• **Révisions dédiées** : Lancez des sessions de quiz ou de flashcards spécifiquement sur ces questions épinglées.\n• **Nettoyage rapide** : Retirez les questions de ce pool à tout moment via l\'interface "Gérer" dès que vous les maîtrisez.',
      emoji: '📌',
    ),
    'feature:classement': FeatureInfo(
      title: 'Progression & Rang',
      description: 'Suivez votre progression par rapport aux autres étudiants de la formation.\n\n• **Calcul de l\'XP** : Gagnez des points d\'expérience en terminant des quiz, en lisant des cours et en réussissant vos TP.\n• **Ligues hebdomadaires** : Restez dans le haut du tableau pour être promu dans la ligue supérieure chaque dimanche soir.\n• **Classement général** : Comparez vos statistiques et votre assiduité pour stimuler vos révisions.',
      emoji: '🏆',
    ),
    'feature:leaderboard_mini': FeatureInfo(
      title: 'Classement Hebdomadaire',
      description: 'Suivez votre progression par rapport aux autres étudiants de la formation.\n\n• **Calcul de l\'XP** : Gagnez des points d\'expérience en terminant des quiz, en lisant des cours et en réussissant vos TP.\n• **Ligues hebdomadaires** : Restez dans le haut du tableau pour être promu dans la ligue supérieure chaque dimanche soir.\n• **Classement général** : Comparez vos statistiques et votre assiduité pour stimuler vos révisions.',
      emoji: '🏆',
    ),
    'feature:tp': FeatureInfo(
      title: 'Travaux Pratiques',
      description: 'Simulations interactives et scénarios réels d\'administration système et réseau.\n\n• **Scénarios guidés** : Résolvez des pannes système, configurez des architectures ou écrivez des scripts complexes.\n• **Validation automatisée** : Eskolia analyse vos réponses et vos configurations pour valider vos compétences.\n• **Progression technique** : Débloquez des TP de niveau avancé au fur et à mesure de vos succès.',
      emoji: '🛠️',
    ),
    'feature:tp_reseau': FeatureInfo(
      title: 'Réseau & Adressage IP',
      description: 'Entraînez-vous à maîtriser l\'adressage IPv4, le sous-réseautage et les masques.\n\n• **Calculs IP interactifs** : Déterminez l\'adresse réseau, de diffusion, le masque ou la plage d\'hôtes valides.\n• **Mode entraînement ou IA** : Générez des exercices sur-mesure ou laissez l\'IA créer des défis adaptés à vos forces.\n• **Progression graduelle** : Débutez sur des masques simples (/8, /16, /24) avant d\'aborder le VLSM et le CIDR.',
      emoji: '🌐',
    ),
    'feature:tp_ad': FeatureInfo(
      title: 'Active Directory',
      description: 'Administrez un domaine Active Directory simulé à travers des missions concrètes.\n\n• **Gestion des comptes** : Créez des utilisateurs, configurez des mots de passe et gérez le verrouillage de comptes.\n• **Structure d\'annuaire** : Organisez les Unités d\'Organisation (OU) et configurez les appartenances aux groupes de sécurité.\n• **Stratégies de groupe (GPO)** : Mettez en place des restrictions et appliquez des configurations de sécurité.',
      emoji: '📁',
    ),
    'feature:tp_powershell': FeatureInfo(
      title: 'Scripting PowerShell',
      description: 'Apprenez à automatiser l\'administration système sous Windows grâce à PowerShell.\n\n• **Syntaxe & Commandes** : Manipulez les Cmdlets de base, les variables, les boucles et les pipelines.\n• **Cas pratiques** : Écrivez des scripts pour importer des utilisateurs en masse, extraire des rapports ou configurer des services.\n• **Débogage guidé** : Analysez les messages d\'erreur et apprenez à optimiser vos scripts système.',
      emoji: '💻',
    ),
    'feature:tp_linux': FeatureInfo(
      title: 'Administration Linux',
      description: 'Maîtrisez les fondamentaux de la ligne de commande Linux (Bash).\n\n• **Gestion de fichiers** : Utilisez les commandes essentielles pour naviguer, éditer, rechercher et trier des données.\n• **Permissions & Sécurité** : Configurez les droits d\'accès (chmod, chown) sur les fichiers et dossiers.\n• **Administration système** : Gérez les processus, analysez les logs et configurez les services système.',
      emoji: '🐧',
    ),
    'feature:tp_cyber': FeatureInfo(
      title: 'Sécurité offensive/défensive',
      description: 'Comprenez et expérimentez les concepts clés de la cybersécurité.\n\n• **Analyse de vulnérabilités** : Identifiez les failles courantes (brute force, injections, mauvaise configuration).\n• **Bonnes pratiques ANSSI** : Appliquez les règles de durcissement et configurez des politiques de sécurité robustes.\n• **Supervision & Alertes** : Analysez le trafic réseau et configurez des pare-feux pour bloquer les attaques.',
      emoji: '🛡️',
    ),
    'feature:tp_incident': FeatureInfo(
      title: 'Gestion d\'Incidents & Supervision',
      description: 'Découvrez le quotidien d\'un technicien système et réseau en entreprise.\n\n• **Supervision de parc** : Configurez des alertes et surveillez l\'état de santé de serveurs (CPU, RAM, Disque, Services).\n• **Résolution de tickets** : Prenez en charge des incidents utilisateurs, qualifiez le problème et appliquez la correction.\n• **Indicateurs de performance** : Suivez les accords de niveau de service (SLA) pour garantir la qualité du support.',
      emoji: '📊',
    ),
    'feature:tp_glpi': FeatureInfo(
      title: 'Gestion de Parc & GLPI',
      description: 'Découvrez la gestion d\'inventaire informatique et le helpdesk avec GLPI.\n\n• **Inventaire d\'actifs** : Référencez et affectez le matériel informatique (ordinateurs, écrans, serveurs, licences).\n• **Gestion du helpdesk** : Créez, affectez et clôturez des tickets d\'assistance technique.\n• **Cycle de vie du matériel** : Suivez les garanties, les amortissements et la maintenance préventive de vos équipements.',
      emoji: '⚙️',
    ),
    'feature:tp_packet_tracer': FeatureInfo(
      title: 'Packet Tracer',
      description: 'Simulez des architectures réseaux complexes dans Cisco Packet Tracer.\n\n• **Câblage & Connectivité** : Reliez des routeurs, commutateurs et ordinateurs à l\'aide des câbles appropriés.\n• **Configuration réseau** : Attribuez les adresses IP et configurez le routage statique ou dynamique (OSPF, RIP).\n• **Analyse de trafic** : Utilisez le mode simulation pour observer le parcours des paquets et comprendre les protocoles (ARP, ICMP, DHCP).',
      emoji: '🕸️',
    ),
    'feature:tp_itil': FeatureInfo(
      title: 'Gestion de Tickets (ITIL)',
      description: 'Adoptez les bonnes pratiques de la gestion des services IT (ITSM) basées sur ITIL.\n\n• **Processus ITIL** : Différenciez la gestion des incidents (restaurer le service) de la gestion des problèmes (trouver la cause racine).\n• **Demandes de changement** : Planifiez et validez les modifications d\'infrastructure pour minimiser l\'impact.\n• **Satisfaction utilisateur** : Qualifiez l\'urgence et la priorité des demandes pour optimiser les temps de traitement.',
      emoji: '🎟️',
    ),
    'feature:notebook': FeatureInfo(
      title: 'Mon Notebook',
      description: 'Centralisez et organisez vos notes de cours de manière interactive.\n\n• **Éditeur Markdown** : Rédigez vos fiches de révision en utilisant des titres, du gras, du code ou des listes.\n• **Génération automatique de quiz** : Eskolia analyse le contenu de vos notes pour créer des questions de révision personnalisées.\n• **Synchronisation** : Accédez à vos notes depuis n\'importe quel appareil pour réviser à tout moment.',
      emoji: '📝',
    ),
    'feature:labo': FeatureInfo(
      title: 'Le Labo',
      description: 'Participez activement à la construction de la base de questions d\'Eskolia.\n\n• **Création de questions** : Soumettez de nouvelles questions de quiz en choisissant le thème, la difficulté et les explications.\n• **Modération par le professeur** : Vos propositions sont relues et validées par votre enseignant.\n• **Intégration au parcours** : Une fois validées, vos questions intègrent le catalogue officiel et font gagner des points à toute la classe.',
      emoji: '🧪',
    ),
    'feature:labo_contrib': FeatureInfo(
      title: 'Mes Contributions',
      description: 'Suivez le statut de validation de vos questions soumises au Labo d\'Eskolia (en attente, approuvées, rejetées).',
      emoji: '🧪',
    ),
    'feature:lobbys': FeatureInfo(
      title: 'Lobbys Multijoueur',
      description: 'Réviser à plusieurs en direct pour allier compétition et apprentissage.\n\n• **Salons publics ou privés** : Rejoignez un salon en cours ou créez le vôtre pour inviter vos camarades via un code unique.\n• **Quiz personnalisés** : Sélectionnez les thèmes ou laissez l\'IA générer des questions en direct sur le sujet de votre choix.\n• **Défis Express (1v1)** : Affrontez un adversaire aléatoire dans un duel rapide de 5 questions sous haute pression.',
      emoji: '👥',
    ),
    'feature:lobbys_active': FeatureInfo(
      title: 'Salons Actifs',
      description: 'Réviser à plusieurs en direct pour allier compétition et apprentissage.\n\n• **Salons publics ou privés** : Rejoignez un salon en cours ou créez le vôtre pour inviter vos camarades via un code unique.\n• **Quiz personnalisés** : Sélectionnez les thèmes ou laissez l\'IA générer des questions en direct sur le sujet de votre choix.\n• **Défis Express (1v1)** : Affrontez un adversaire aléatoire dans un duel rapide de 5 questions sous haute pression.',
      emoji: '👥',
    ),
    'feature:lobbys_create': FeatureInfo(
      title: 'Créer Salon',
      description: 'Configurez et ouvrez votre propre salon multijoueur (choix des thèmes, nombre de questions) pour inviter vos camarades à jouer en temps réel.',
      emoji: '👥',
    ),
    'feature:lobbys_create_ai': FeatureInfo(
      title: 'Créer Salon IA',
      description: 'Créez un salon multijoueur où les questions sont entièrement générées en direct par l\'intelligence artificielle sur un thème libre.',
      emoji: '🧠',
    ),
    'feature:lobbys_join_private': FeatureInfo(
      title: 'Rejoindre par Code',
      description: 'Saisissez le code d\'accès fourni par un camarade pour rejoindre instantanément son salon de révision privé.',
      emoji: '🔒',
    ),
    'feature:duel_quick': FeatureInfo(
      title: 'Défi Express',
      description: 'Lancez des duels en face-à-face en temps réel contre d\'autres étudiants.\n\n• **Matchmaking rapide** : Entrez instantanément dans une file d\'attente pour affronter un joueur disponible.\n• **Questions chronométrées** : Répondez le plus vite possible à une série de 5 questions pour marquer le maximum de points.\n• **Classement de duel** : Suivez votre historique de victoires/défaites et gagnez de l\'XP bonus à chaque victoire.',
      emoji: '⚡',
    ),
    'feature:parcours': FeatureInfo(
      title: 'Cours formation TIP',
      description: 'Le guide officiel de votre formation pour réussir votre certification.\n\n• **Fiches de cours** : Accédez à des synthèses claires et illustrées de chaque module de cours.\n• **Quiz de chapitre** : Validez vos connaissances à la fin de chaque chapitre pour débloquer la suite du parcours.\n• **Suivi de progression** : Visualisez votre avancement global et repérez facilement les chapitres à réviser.',
      emoji: '🎓',
    ),
    'feature:podcasts': FeatureInfo(
      title: 'Podcast TIP',
      description: 'Écoutez vos cours sous forme de capsules audio enregistrées par vos professeurs.\n\n• **Écoute nomade** : Révisez la théorie dans les transports, pendant vos trajets ou vos temps de pause.\n• **Sujets clés** : Retrouvez des explications audio sur les concepts indispensables de la certification.\n• **Player intégré** : Contrôlez la vitesse de lecture et reprenez l\'écoute là où vous vous étiez arrêté.',
      emoji: '🎙️',
    ),
    'feature:examen_blanc': FeatureInfo(
      title: 'Validation TIP',
      description: 'Simulez l\'épreuve finale de votre certification dans les conditions réelles de l\'examen.\n\n• **Test chronométré** : Répondez à un QCM complet de 40 questions avec une limite de temps stricte.\n• **Couverture globale** : Les questions couvrent l\'intégralité du syllabus officiel de la formation.\n• **Critère de réussite** : Atteignez le seuil de 80% de bonnes réponses pour valider votre examen blanc.',
      emoji: '🏆',
    ),
    'feature:lexique': FeatureInfo(
      title: 'Lexique TIP',
      description: 'Le dictionnaire interactif des termes et sigles informatiques indispensables.\n\n• **Définitions claires** : Retrouvez l\'explication complète de tous les acronymes de votre formation (ex: DHCP, AD, VLAN).\n• **Quiz lexique** : Lancez des entraînements rapides uniquement basés sur les termes et définitions du lexique.\n• **Recherche rapide** : Filtrez par lettre ou par mot-clé pour trouver instantanément le terme recherché.',
      emoji: '📖',
    ),
    'feature:mediatheque': FeatureInfo(
      title: 'Média TIP',
      description: 'Retrouvez l\'ensemble des contenus multimédias associés à votre formation.\n\n• **Vidéos explicatives** : Visionnez des tutoriels de configuration, des démonstrations et des cours vidéo.\n• **Supports de cours** : Téléchargez les diapositives et documents de référence présentés en cours.\n• **Accès centralisé** : Retrouvez facilement tous les médias associés à un chapitre particulier.',
      emoji: '📁',
    ),
    'feature:flashcards': FeatureInfo(
      title: 'Révisions Flashcards',
      description: 'Utilisez la répétition espacée pour mémoriser durablement les concepts clés.\n\n• **Système Recto/Verso** : Tentez de vous souvenir de la réponse avant de retourner la carte pour la vérifier.\n• **Auto-évaluation** : Indiquez si vous saviez ("Je savais") ou non ("À revoir") pour ajuster la fréquence de réapparition de la carte.\n• **Decks thématiques** : Paquets de cartes par thèmes selon les thèmes de votre formation.',
      emoji: '⚡',
    ),
    'feature:flashcards_deck': FeatureInfo(
      title: 'Révisions Mémoire',
      description: 'Utilisez la répétition espacée pour mémoriser durablement les concepts clés.\n\n• **Système Recto/Verso** : Tentez de vous souvenir de la réponse avant de retourner la carte pour la vérifier.\n• **Auto-évaluation** : Indiquez si vous saviez ("Je savais") ou non ("À revoir") pour ajuster la fréquence de réapparition de la carte.\n• **Decks thématiques** : Paquets de cartes par thèmes selon les thèmes de votre formation.',
      emoji: '⚡',
    ),
    'messages': FeatureInfo(
      title: 'Espace Messages',
      description: 'Restez connecté avec l\'équipe pédagogique et la communauté.\n\n• **Annonces officielles** : Suivez les dates d\'examens, les événements de la formation et les messages importants des professeurs.\n• **Conseils de révision** : Recevez des astuces méthodologiques pour optimiser votre apprentissage.\n• **Notifications** : Soyez averti dès qu\'un message important ou une nouvelle annonce est publiée.',
      emoji: '✉️',
    ),
    'astuces': FeatureInfo(
      title: 'Espace Astuces',
      description: 'Améliorez votre culture technique grâce à nos astuces quotidiennes.\n\n• **Astuce du jour** : Découvrez chaque jour un raccourci clavier, une commande utile ou une bonne pratique système.\n• **Veille technologique** : Restez informé des nouveautés et des évolutions du monde informatique.\n• **Mise en favoris** : Enregistrez les astuces les plus utiles pour les retrouver en un clic.',
      emoji: '💡',
    ),
    'feature:tp_osi': FeatureInfo(
      title: 'Modèle OSI',
      description: 'Ateliers pratiques interactifs dédiés à la maîtrise du modèle OSI (7 couches).\n\n• **Le Tri Sélectif** : Classification de cartes (matériels, protocoles, PDU) vers les 7 couches avec séries sans-faute.\n• **Le Voyage du Paquet** : Puzzle séquentiel pour comprendre visuellement l\'encapsulation (7 ➔ 1) et la décapsulation (1 ➔ 7).\n• **L\'Enquêteur OSI** : Analyse de pannes et tickets d\'incident réels pour diagnostiquer la couche en cause et choisir la bonne action de support.',
      emoji: '🌐',
    ),
    'favoris': FeatureInfo(
      title: 'Mes Favoris',
      description: 'Votre bibliothèque personnelle de contenus enregistrés.\n\n• **Sauvegarde rapide** : Ajoutez des cours, des astuces ou des articles de veille en favoris depuis l\'application.\n• **Accès hors-ligne** : Retrouvez vos favoris rapidement pour réviser sans perdre de temps à les chercher.\n• **Organisation libre** : Supprimez ou mettez en avant vos favoris au fil de vos besoins.',
      emoji: '⭐',
    ),
  };

  static FeatureInfo? getInfo(String key) {
    if (_infos.containsKey(key)) {
      return _infos[key];
    }
    // Gérer dynamiquement les flux RSS (sources/veille)
    if (key.startsWith('source:') || key.startsWith('merge:')) {
      return const FeatureInfo(
        title: 'Flux de Veille RSS',
        description: 'Flux d\'actualités technologiques (veille informatique) issus de sources externes.\n\n• **Sources variées** : Suivez l\'actualité de l\'informatique, de la cybersécurité et du système/réseau.\n• **Gestion personnalisée** : Ajoutez vos propres flux RSS ou masquez ceux qui ne vous intéressent pas.\n• **Favoris** : Enregistrez les articles importants pour les relire et préparer votre veille.',
        emoji: '📰',
      );
    }
    return null;
  }

  static Widget buildRichDescription(String text, TextStyle baseStyle) {
    final List<InlineSpan> spans = [];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: baseStyle.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return Text.rich(
      TextSpan(children: spans, style: baseStyle),
    );
  }
}
