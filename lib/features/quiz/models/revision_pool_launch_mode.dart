/// Passé via [GoRouterState.extra] vers [`/revision-pool`].
enum RevisionPoolLaunchMode {
  /// Liste + sélection manuelle puis Quiz / Flashcards.
  browse,

  /// Lance une session QCM sur tout le pool dès l’arrivée.
  quizAll,

  /// Lance une session flashcards sur tout le pool dès l’arrivée.
  flashcardsAll,
}
