/// Source virtuelle [QuizQuestion.sourceAssetPath] pour les QCM Labo validés.
const String kLaboApprovedQuestionSource = 'firestore/labo_question_drafts';

/// Id Firestore depuis [QuizQuestion.id] `labo_xxx`.
String? laboFirestoreIdFromQuizQuestionId(String quizId) {
  if (!quizId.startsWith('labo_')) return null;
  final rest = quizId.substring('labo_'.length);
  return rest.isEmpty ? null : rest;
}
