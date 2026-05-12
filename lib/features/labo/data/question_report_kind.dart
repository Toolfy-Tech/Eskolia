/// Types de signalement — blueprint v3 § Le Labo (Remontée d'erreurs).
enum QuestionReportKind {
  poorlyWritten('poorly_written', 'Question mal écrite'),
  wrongAnswer('wrong_answer', 'Réponse incorrecte'),
  ambiguous('ambiguous', 'Question ambiguë'),
  // Valeurs héritées — conservées pour compatibilité lectures Firestore
  typo('typo', 'Faute / typo'),
  obsolete('obsolete', 'Obsolète / dépassé'),
  other('other', 'Autre');

  const QuestionReportKind(this.firestoreValue, this.label);

  final String firestoreValue;
  final String label;

  /// Les 3 options exposées dans le dialog utilisateur.
  static const List<QuestionReportKind> userFacing = [
    poorlyWritten,
    wrongAnswer,
    ambiguous,
  ];

  static QuestionReportKind fromFirestore(String? raw) {
    for (final k in QuestionReportKind.values) {
      if (k.firestoreValue == raw) return k;
    }
    return QuestionReportKind.other;
  }
}
