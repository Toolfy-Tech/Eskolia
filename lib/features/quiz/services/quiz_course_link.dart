import '../../parcours/data/parcours_repository.dart';
import '../../parcours/data/tip_quiz_catalog.dart';
import '../models/quiz_models.dart';

/// Module `/cours/:moduleId` pour une question : session parcours ou résolution par JSON QCM.
Future<String?> courseModuleIdForQuizContext(
  String sessionId,
  QuizQuestion q,
) async {
  final mod = ParcoursRepository.moduleById(sessionId);
  if (mod != null) return mod.id;
  return TipQuizCatalog.moduleIdForQuizAssetPath(q.sourceAssetPath ?? '');
}

/// Module `/cours/:moduleId` pour une question : session parcours ou résolution par JSON QCM.
Future<String?> resolveCourseModuleIdForQuestion(
  QuizSession session,
  QuizQuestion q,
) async {
  return courseModuleIdForQuizContext(session.sessionId, q);
}
