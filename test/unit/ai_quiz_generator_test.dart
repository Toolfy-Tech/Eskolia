import 'package:flutter_test/flutter_test.dart';
import 'package:eskolia/features/ai/data/ai_quiz_generator_service.dart';
import 'package:eskolia/features/quiz/services/quiz_repository.dart';
import 'package:eskolia/features/quiz/services/quiz_template_service.dart';
import 'package:eskolia/features/lobby/data/models/custom_quiz_data.dart';

void main() {
  group('AiQuizGeneratorService Tests', () {
    test('extractJson properly strips markdown code fences', () {
      const wrapped = '''
```json
{
  "quizTitle": "Réseaux et TCP/IP",
  "questions": [
    {
      "id": "q1",
      "question": "Quel protocole fonctionne sur le port 443 ?",
      "options": ["HTTP", "HTTPS", "SSH", "FTP"],
      "correctAnswerIndex": 1,
      "explanation": "Le port 443 est le port standard pour HTTPS (HTTP sécurisé avec TLS).",
      "difficulty": "facile"
    }
  ]
}
```
''';
      final extracted = AiQuizGeneratorService.extractJson(wrapped);
      expect(extracted.startsWith('{'), isTrue);
      expect(extracted.endsWith('}'), isTrue);
      expect(extracted.contains('```'), isFalse);
    });

    test('parseQuizJson builds QuizSession with open active recall questions', () {
      const jsonStr = '''
{
  "quizTitle": "Systèmes Windows Server",
  "questions": [
    {
      "id": "q_ad_1",
      "question": "Quel rôle Windows Server permet de gérer les identités et permissions ?",
      "answer": "Active Directory Domain Services (AD DS)",
      "explanation": "AD DS fournit le service d'annuaire centralisé et la gestion des identités.",
      "difficulty": "moyen"
    },
    {
      "id": "q_ad_2",
      "question": "Quelle commande permet d'analyser la réplication Active Directory ?",
      "answer": "repadmin /replsummary",
      "explanation": "repadmin est l'outil en ligne de commande dédié au diagnostic de réplication AD.",
      "difficulty": "difficile"
    }
  ]
}
''';
      final service = AiQuizGeneratorService();
      final session = service.parseQuizJson(jsonStr, defaultTitle: 'Default');

      expect(session.title, equals('Systèmes Windows Server'));
      expect(session.questions.length, equals(2));

      final q1 = session.questions[0];
      expect(q1.id, equals('q_ad_1'));
      expect(q1.type, equals('classic'));
      expect(q1.answer, equals('Active Directory Domain Services (AD DS)'));
      expect(q1.explanation, contains('AD DS fournit'));
      expect(q1.difficultyBucket, equals('moyen'));

      final q2 = session.questions[1];
      expect(q2.id, equals('q_ad_2'));
      expect(q2.type, equals('classic'));
      expect(q2.answer, equals('repadmin /replsummary'));
      expect(q2.difficultyBucket, equals('difficile'));
    });

    test('parseQuizJson builds QuizSession with all 5 question types', () {
      const jsonStr = r'''
{
  "quizTitle": "Mix IT Équilibré",
  "questions": [
    {
      "id": "q1",
      "type": "classic",
      "question": "Quel est le rôle du DNS ?",
      "answer": "Résoudre les noms d'hôtes en adresses IP",
      "explanation": "Le DNS agit comme l'annuaire d'Internet sur le port 53 UDP/TCP.",
      "difficulty": "facile"
    },
    {
      "id": "q2",
      "type": "sequence",
      "question": "Ordonne le cycle DORA :",
      "answer": "1. Discover\n2. Offer\n3. Request\n4. Acknowledge",
      "items": ["Discover", "Offer", "Request", "Acknowledge"],
      "explanation": "DORA est le cycle d'attribution d'adresse IP par DHCP.",
      "difficulty": "moyen"
    },
    {
      "id": "q3",
      "type": "association",
      "question": "Associe les ports :",
      "answer": "SSH -> 22, HTTP -> 80",
      "pairs": [["SSH", "22"], ["HTTP", "80"]],
      "explanation": "Ports IANA standards.",
      "difficulty": "facile"
    },
    {
      "id": "q4",
      "type": "diagnostic_indices",
      "question": "Panne réseau sur poste client...",
      "answer": "Problème DHCP",
      "indices": ["IP en 169.254.x.x", "Pas de passerelle", "Pas de réponse DHCP"],
      "explanation": "Adresse APIPA générée.",
      "difficulty": "difficile"
    },
    {
      "id": "q5",
      "type": "ticket",
      "question": "Ticket #12 : Imprimante hors ligne",
      "answer": "Vérifier réseau et spooler",
      "checklist": ["Ping IP", "Redémarrer spooler", "Vérifier file d'attente"],
      "explanation": "Contrôle méthodique avant réinstallation.",
      "difficulty": "moyen"
    }
  ]
}
''';
      final service = AiQuizGeneratorService();
      final session = service.parseQuizJson(jsonStr, defaultTitle: 'Mix');

      expect(session.questions.length, equals(5));
      expect(session.questions[0].type, equals('classic'));
      expect(session.questions[1].type, equals('sequence'));
      expect(session.questions[1].answerSequence?.length, equals(4));
      expect(session.questions[2].type, equals('association'));
      expect(session.questions[2].matchPairs?.length, equals(2));
      expect(session.questions[3].type, equals('diagnostic_indices'));
      expect(session.questions[3].indices?.length, equals(3));
      expect(session.questions[4].type, equals('ticket'));
      expect(session.questions[4].checklist?.length, equals(3));
    });

    test('QuizTemplateService.getQuizTemplateJson produces valid CustomQuizData', () {
      final templateJson = QuizTemplateService.getQuizTemplateJson();
      final parsed = CustomQuizData.fromJsonString(templateJson);

      expect(parsed.title, contains('Modèle de Quiz'));
      expect(parsed.questions.length, equals(5));
      expect(parsed.questions.map((q) => q.type).toSet(), containsAll(['classic', 'sequence', 'association', 'diagnostic_indices', 'ticket']));
    });

    test('QuizRepository.resultExitDestination redirects solo and AI sessions to soloMenu', () {
      final soloSession = QuizSession(
        sessionId: 'solo_1700000000',
        title: 'Quiz Solo',
        questions: [],
        currentIndex: 0,
        userScores: [],
        startTime: DateTime.now(),
      );

      final aiSession = QuizSession(
        sessionId: 'ai_1700000000',
        title: 'Quiz IA',
        questions: [],
        currentIndex: 0,
        userScores: [],
        startTime: DateTime.now(),
      );

      final parcoursSession = QuizSession(
        sessionId: 'optimus_m01_ch01',
        title: 'Chapitre 1',
        questions: [],
        currentIndex: 0,
        userScores: [],
        startTime: DateTime.now(),
      );

      expect(QuizRepository.resultExitDestination(soloSession), equals(QuizResultExitDestination.soloMenu));
      expect(QuizRepository.resultExitDestination(aiSession), equals(QuizResultExitDestination.soloMenu));
      expect(QuizRepository.resultExitDestination(parcoursSession), equals(QuizResultExitDestination.parcours));
    });
  });
}
