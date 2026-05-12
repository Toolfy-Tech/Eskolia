/// Hauts faits Eskolia — progression solo, Labo, multijoueur et économie.
class AchievementDef {
  const AchievementDef({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    this.linkedBadgeId,
  });

  final String id;
  final String emoji;
  final String title;
  final String description;

  /// Si non null : débloque aussi ce badge Firestore (`users.badges`) en même temps.
  final String? linkedBadgeId;
}

const List<AchievementDef> kAchievementCatalog = [
  AchievementDef(
    id: 'first_quiz',
    emoji: '\u{1F3AE}',
    title: 'Premier quiz',
    description: 'Terminer une partie de quiz.',
  ),
  AchievementDef(
    id: 'first_flash',
    emoji: '\u{1F0CF}',
    title: 'Cartes en main',
    description: 'Terminer une session flashcards.',
  ),
  AchievementDef(
    id: 'first_parcours_day',
    emoji: '\u{1F4DA}',
    title: 'Sur les rails',
    description: 'Valider la quête « Parcours » du jour.',
  ),
  AchievementDef(
    id: 'daily_trio',
    emoji: '\u{1F3C6}',
    title: 'Triple menace',
    description:
        'Compléter les 3 quêtes quotidiennes le même jour. Débloque le badge « Triple menace ».',
    linkedBadgeId: 'badge_daily_triple',
  ),
  AchievementDef(
    id: 'labo_first_report',
    emoji: '\u{1F6A9}',
    title: 'Chasseur de coquilles',
    description:
        'Envoyer un premier signalement depuis un quiz. Débloque le badge « Veille qualité ».',
    linkedBadgeId: 'badge_labo_reporter',
  ),
  AchievementDef(
    id: 'labo_first_draft',
    emoji: '\u{1F9EA}',
    title: 'Chercheur de QCM',
    description:
        'Proposer ta première question au Labo. Débloque le badge « Auteur Labo ».',
    linkedBadgeId: 'badge_labo_author',
  ),
  AchievementDef(
    id: 'labo_first_tip',
    emoji: '\u{1F4A1}',
    title: 'Mentor en herbe',
    description:
        'Proposer ta première astuce pour un module. Débloque le badge « Mentor Labo ».',
    linkedBadgeId: 'badge_labo_mentor',
  ),
  AchievementDef(
    id: 'survival_perfect',
    emoji: '\u{1F480}',
    title: 'Survivant',
    description:
        'Terminer un Survival sans perdre toutes tes vies, toutes les questions. Débloque le badge « Maître du survival ».',
    linkedBadgeId: 'badge_survival_master',
  ),
  AchievementDef(
    id: 'tip_grand_finale',
    emoji: '\u{1F393}',
    title: 'Examen blanc TIP',
    description:
        'Valider l’examen blanc de fin de formation : au moins 40 questions, 80 % de bonnes réponses, après les 10 sections. Débloque le super badge « Diplômé TIP ».',
    linkedBadgeId: 'super_badge_tip_diploma',
  ),
  AchievementDef(
    id: 'optimus_grand_finale',
    emoji: '\u{1F916}',
    title: 'Examen blanc Optimus',
    description:
        'Valider l’épreuve finale Optimus (80 % de bonnes réponses) après les évaluations O01–O06. Débloque le super badge « Diplômé Optimus ».',
    linkedBadgeId: 'super_badge_optimus_diploma',
  ),
  AchievementDef(
    id: 'quiz_10',
    emoji: '\u{1F4D6}',
    title: 'En roue libre',
    description: 'Terminer 10 quiz (tous modes solo comptés).',
  ),
  AchievementDef(
    id: 'quiz_50',
    emoji: '\u{1F4CA}',
    title: 'À fond la caisse',
    description: 'Terminer 50 quiz.',
  ),
  AchievementDef(
    id: 'quiz_100',
    emoji: '\u{1F3C6}',
    title: 'Centenaire',
    description: 'Terminer 100 quiz. Débloque le badge « Centurion du QCM ».',
    linkedBadgeId: 'badge_quiz_centurion',
  ),
  AchievementDef(
    id: 'quiz_wins_10',
    emoji: '\u{2705}',
    title: 'En confiance',
    description: 'Réussir 10 quiz (score ≥ 60 %).',
  ),
  AchievementDef(
    id: 'quiz_wins_50',
    emoji: '\u{1F9E0}',
    title: 'Tête bien faite',
    description: 'Réussir 50 quiz. Débloque le badge « Érudit confirmé ».',
    linkedBadgeId: 'badge_scholar_wins',
  ),
  AchievementDef(
    id: 'quiz_flawless_big',
    emoji: '\u{2728}',
    title: 'Sans faute',
    description:
        'Réussir un quiz d’au moins 15 questions à 100 % (hors survival). Débloque un badge.',
    linkedBadgeId: 'badge_flawless_run',
  ),
  AchievementDef(
    id: 'first_revision_quiz',
    emoji: '\u{1F4CC}',
    title: 'Révision ciblée',
    description: 'Terminer un quiz lancé depuis le pool 📌.',
  ),
  AchievementDef(
    id: 'revision_quiz_10',
    emoji: '\u{1F9F5}',
    title: 'Tisserand de savoir',
    description: '10 quiz terminés depuis le pool 📌. Débloque un badge.',
    linkedBadgeId: 'badge_revision_pro',
  ),
  AchievementDef(
    id: 'first_lacunes_quiz',
    emoji: '\u{1F578}',
    title: 'Traque des erreurs',
    description: 'Terminer une session « Lacunes ».',
  ),
  AchievementDef(
    id: 'lacunes_grinder',
    emoji: '\u{1F3AF}',
    title: 'Zéro lacune',
    description: '15 sessions « Lacunes ». Débloque un badge.',
    linkedBadgeId: 'badge_lacunes_ninja',
  ),
  AchievementDef(
    id: 'first_daily_quiz',
    emoji: '\u{1F319}',
    title: 'Rituel du jour',
    description: 'Terminer le quiz du jour une première fois.',
  ),
  AchievementDef(
    id: 'daily_quiz_7',
    emoji: '\u{2600}',
    title: 'Sept fois le matin',
    description: 'Terminer le quiz du jour 7 fois. Débloque un badge.',
    linkedBadgeId: 'badge_daily_devoted',
  ),
  AchievementDef(
    id: 'pool_25_pins',
    emoji: '\u{1F4E6}',
    title: 'Papier peint',
    description: 'Avoir au moins 25 questions dans le pool 📌.',
    linkedBadgeId: 'badge_pin_collector',
  ),
  AchievementDef(
    id: 'pool_75_pins',
    emoji: '\u{1F3DB}',
    title: 'Bibliothèque perso',
    description: '75 questions ou plus dans le pool 📌.',
    linkedBadgeId: 'badge_pin_archivist',
  ),
  AchievementDef(
    id: 'flash_sessions_20',
    emoji: '\u{1F4AD}',
    title: 'Mémoire active',
    description: 'Terminer 20 sessions flashcards.',
  ),
  AchievementDef(
    id: 'flash_sessions_75',
    emoji: '\u{1F0CF}',
    title: 'Carte mémoire',
    description: '75 sessions flashcards. Débloque un badge.',
    linkedBadgeId: 'badge_flash_legend',
  ),
  AchievementDef(
    id: 'level_15',
    emoji: '\u{1F4C8}',
    title: 'Montée en puissance',
    description: 'Atteindre le niveau 15.',
  ),
  AchievementDef(
    id: 'level_30',
    emoji: '\u{1F31F}',
    title: 'Sommet XP',
    description: 'Atteindre le niveau 30. Débloque un super badge.',
    linkedBadgeId: 'super_badge_arc_learner',
  ),
  AchievementDef(
    id: 'streak_week_fire',
    emoji: '\u{1F525}',
    title: 'Semaine en feu',
    description: 'Série de connexion de 7 jours.',
  ),
  AchievementDef(
    id: 'streak_month',
    emoji: '\u{1F525}',
    title: 'Infernal',
    description: 'Série de connexion de 30 jours. Débloque un badge.',
    linkedBadgeId: 'badge_streak_inferno',
  ),
  AchievementDef(
    id: 'battle_first',
    emoji: '\u{2694}',
    title: 'Première escarmouche',
    description: 'Terminer une bataille multijoueur.',
  ),
  AchievementDef(
    id: 'battle_win_first',
    emoji: '\u{1F3C5}',
    title: 'Vainqueur',
    description: 'Gagner une bataille multijoueur. Débloque un badge.',
    linkedBadgeId: 'badge_battle_champion',
  ),
  AchievementDef(
    id: 'battle_wins_10',
    emoji: '\u{1F451}',
    title: 'Dominateur',
    description: '10 victoires multijoueur.',
    linkedBadgeId: 'badge_battle_legend',
  ),
];

final Map<String, AchievementDef> kAchievementCatalogById = {
  for (final a in kAchievementCatalog) a.id: a,
};
