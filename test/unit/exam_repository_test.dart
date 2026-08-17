import 'package:flutter_test/flutter_test.dart';
import 'package:eskolia/features/exam/data/exam_model.dart';
import 'package:eskolia/features/exam/data/exam_repository.dart';
import 'package:eskolia/features/parcours/data/tip_quiz_catalog.dart';
import 'package:eskolia/features/quiz/models/quiz_models.dart';
import 'package:eskolia/features/quiz/services/quiz_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExamRepository & Model Tests', () {
    test('ExamQuizItem properties and questionCount work correctly', () {
      final item = ExamQuizItem(
        id: 'epreuve_01',
        title: 'Épreuve Blanche 1 — Support & Diagnostic',
        description: 'Test blanc de révision',
        author: 'Eskolia',
        category: 'Examen Blanc',
        assetPath: 'data/exam/exam01.json',
        questions: const [
          QuizQuestion(
            id: 'q1',
            type: 'classic',
            question: 'Question 1',
            answer: 'Reponse 1',
          ),
          QuizQuestion(
            id: 'q2',
            type: 'sequence',
            question: 'Question 2',
            answer: 'Reponse 2',
            answerSequence: ['A', 'B', 'C'],
          ),
        ],
        bestScore: 85.0,
        isCompleted: true,
      );

      expect(item.questionCount, equals(2));
      expect(item.isCompleted, isTrue);
      expect(item.bestScore, equals(85.0));

      final updated = item.copyWith(bestScore: 95.0);
      expect(updated.bestScore, equals(95.0));
      expect(updated.title, equals(item.title));
    });

    test('buildExamSession creates an untimed standard session', () {
      final repo = ExamRepository.instance;
      final item = ExamQuizItem(
        id: 'epreuve_01',
        title: 'Épreuve Blanche 1',
        description: 'Description',
        author: 'Eskolia',
        category: 'Examen Blanc',
        assetPath: 'data/exam/exam01.json',
        questions: const [
          QuizQuestion(
            id: 'q1',
            type: 'classic',
            question: 'Question 1',
            answer: 'Reponse 1',
          ),
        ],
      );

      final session = repo.buildExamSession(item);

      expect(session.sessionId, equals('exam_epreuve_01'));
      expect(session.title, equals('Épreuve Blanche 1'));
      expect(session.timed, isFalse); // Non chronométré selon la demande
      expect(session.runMode, equals(QuizRunMode.standard));
      expect(session.questions.length, equals(1));
    });

    test('TipQuizCatalog correctly classifies exams track', () {
      expect(TipQuizCatalog.parseTrackQuery('exams'), equals(QuizCatalogTrack.exams));
      expect(TipQuizCatalog.quizAssetPathMatchesCatalogTrack('data/exam/exam01.json', QuizCatalogTrack.exams), isTrue);
      expect(TipQuizCatalog.quizAssetPathMatchesCatalogTrack('data/exam/exam01.json', QuizCatalogTrack.both), isTrue);
      expect(TipQuizCatalog.fallbackContextLineForAssetPath('data/exam/exam02.json'), equals('Examen Blanc'));
      expect(TipQuizCatalog.subjectLabelForPaths(['data/exam/exam01.json']), equals('Examen Blanc 01 (Alpha)'));
    });

    test('QuizRepository.tipJsonToQuizQuestions parses exam wrapper object schema', () {
      const sampleJson = '''
      {
        "quiz": { "title": "Épreuve Blanche 1 — Test" },
        "questions": [
          {
            "id": "q1",
            "type": "classic",
            "question": "Question 1",
            "answer": "Reponse 1",
            "difficulty": "facile"
          },
          {
            "id": "q2",
            "type": "sequence",
            "question": "Question 2",
            "answer": "1. A\\n2. B",
            "items": ["A", "B"],
            "difficulty": "moyen"
          }
        ]
      }
      ''';

      final parsed = QuizRepository.tipJsonToQuizQuestions(sampleJson, sourceAssetPath: 'data/exam/exam01.json');
      expect(parsed.length, equals(2));
      expect(parsed[0].difficultyBucket, equals('facile'));
      expect(parsed[1].difficultyBucket, equals('moyen'));
      expect(parsed[1].answerSequence, equals(['A', 'B']));
      expect(parsed[0].contextLine, contains('Épreuve Blanche 1'));
    });
  });
}
