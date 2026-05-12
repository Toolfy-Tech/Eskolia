/// Badges profil Firestore (`users/{uid}.badges`) — titres affichables.
class BadgeDef {
  const BadgeDef({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    this.isSuper = false,
  });

  final String id;
  final String emoji;
  final String title;
  final String description;
  final bool isSuper;
}

/// Badges catalogués (fixes + super badges).
const List<BadgeDef> kBadgeCatalogStatic = [
  BadgeDef(
    id: 'badge_survival_master',
    emoji: '\u{1F480}',
    title: 'Maître du survival',
    description:
        'Terminer un quiz survival avec toutes les bonnes réponses sans être éliminé.',
  ),
  BadgeDef(
    id: 'badge_daily_triple',
    emoji: '\u{1F3C6}',
    title: 'Triple menace',
    description: 'Compléter les trois quêtes quotidiennes le même jour.',
  ),
  BadgeDef(
    id: 'super_badge_tip_diploma',
    emoji: '\u{1F393}',
    title: 'Diplômé TIP',
    description:
        'Valider l’examen blanc de fin de formation TIP (parcours complet).',
    isSuper: true,
  ),
  BadgeDef(
    id: 'super_badge_optimus_diploma',
    emoji: '\u{1F916}',
    title: 'Diplômé Optimus',
    description:
        'Valider l’examen blanc de fin de parcours Optimus (toutes les sections).',
    isSuper: true,
  ),
  BadgeDef(
    id: 'badge_quiz_centurion',
    emoji: '\u{1F4DA}',
    title: 'Centurion du QCM',
    description: 'Terminer 100 quiz au compteur.',
  ),
  BadgeDef(
    id: 'badge_scholar_wins',
    emoji: '\u{1F3C5}',
    title: 'Érudit confirmé',
    description: 'Atteindre 50 quiz réussis (≥ 60 %).',
  ),
  BadgeDef(
    id: 'badge_flawless_run',
    emoji: '\u{2728}',
    title: 'Sans faute',
    description: 'Réussir un quiz d’au moins 15 questions à 100 %.',
  ),
  BadgeDef(
    id: 'badge_revision_pro',
    emoji: '\u{1F4CC}',
    title: 'Pro de la révision',
    description: 'Terminer 10 quiz lancés depuis le pool 📌.',
  ),
  BadgeDef(
    id: 'badge_lacunes_ninja',
    emoji: '\u{1F977}',
    title: 'Chasseur de lacunes',
    description: 'Terminer 15 sessions « Lacunes ».',
  ),
  BadgeDef(
    id: 'badge_daily_devoted',
    emoji: '\u{2600}',
    title: 'Accro au quotidien',
    description: 'Terminer le quiz du jour 7 fois.',
  ),
  BadgeDef(
    id: 'badge_pin_collector',
    emoji: '\u{1F4E6}',
    title: 'Collectionneur',
    description: 'Au moins 25 questions dans le pool de révision.',
  ),
  BadgeDef(
    id: 'badge_pin_archivist',
    emoji: '\u{1F3DB}',
    title: 'Archiviste',
    description: 'Au moins 75 questions dans le pool de révision.',
  ),
  BadgeDef(
    id: 'badge_flash_legend',
    emoji: '\u{1F0CF}',
    title: 'Légende des cartes',
    description: 'Terminer 75 sessions flashcards.',
  ),
  BadgeDef(
    id: 'super_badge_arc_learner',
    emoji: '\u{1F31F}',
    title: 'Maître de l’arc XP',
    description: 'Atteindre le niveau 30 — engagement exceptionnel.',
    isSuper: true,
  ),
  BadgeDef(
    id: 'badge_streak_inferno',
    emoji: '\u{1F525}',
    title: 'Série infernale',
    description: 'Conserver une série de connexion de 30 jours.',
  ),
  BadgeDef(
    id: 'badge_battle_champion',
    emoji: '\u{1F3AE}',
    title: 'Champion d’arène',
    description: 'Remporter une bataille multijoueur.',
  ),
  BadgeDef(
    id: 'badge_battle_legend',
    emoji: '\u{1F451}',
    title: 'Légende de l’arène',
    description: '10 victoires en multijoueur.',
  ),
  BadgeDef(
    id: 'badge_labo_reporter',
    emoji: '\u{1F6A9}',
    title: 'Veille qualité',
    description: 'Premier signalement utile depuis un quiz.',
  ),
  BadgeDef(
    id: 'badge_labo_author',
    emoji: '\u{1F9EA}',
    title: 'Auteur Labo',
    description: 'Première proposition de question au Labo.',
  ),
  BadgeDef(
    id: 'badge_labo_mentor',
    emoji: '\u{1F4A1}',
    title: 'Mentor Labo',
    description: 'Première astuce communauté pour un module.',
  ),
];

final Map<String, BadgeDef> kBadgeCatalogById = {
  for (final b in kBadgeCatalogStatic) b.id: b,
};

/// Affichage pour ids dynamiques (`badge_section_tip_s01`, etc.).
BadgeDef resolveBadgeDef(String id) {
  final known = kBadgeCatalogById[id];
  if (known != null) return known;

  final m = RegExp(r'^badge_section_([a-z0-9]+)_([a-z0-9]+)$')
      .firstMatch(id.toLowerCase());
  if (m != null) {
    final form = m.group(1)!;
    final sec = m.group(2)!.toUpperCase();
    return BadgeDef(
      id: id,
      emoji: '\u{1F4D8}',
      title: 'Section $sec validée',
      description:
          'Tu as terminé tous les modules de cette section ($form).',
    );
  }

  return BadgeDef(
    id: id,
    emoji: '\u{1F3C5}',
    title: id,
    description: 'Badge obtenu sur Eskolia.',
  );
}
