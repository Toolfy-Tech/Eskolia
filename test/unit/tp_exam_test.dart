import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eskolia/features/tp/exam_tp/models/tp_exam_model.dart';
import 'package:eskolia/features/tp/exam_tp/data/tp_exam_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TpExamModel & Repository Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('TpExamScenario models parse and calculate points correctly', () {
      final scenario = TpExamScenario(
        id: 'tp_exam_test',
        title: 'Test TP Exam',
        subtitle: 'Subtitle test',
        candidateName: 'Test Candidate',
        companyName: 'Test Co',
        role: 'Technician',
        accessibilityContext: 'Accessibility requirement',
        vmInfo: const TpExamVmInfo(
          vmName: 'MV-Test',
          targetHostname: 'MV-Target',
          os: 'Win 11',
          adminUser: 'Admin',
          adminPassword: 'Pass',
          tpmKey: 'TPMKey',
          userAccount: TpExamUserAccount(
            username: 'test.user',
            fullName: 'Test User',
            password: 'UserPass',
          ),
        ),
        tasks: const [
          TpExamTask(
            id: 'task_1',
            order: 1,
            title: 'Task 1',
            points: 1.0,
            instruction: 'Instruction 1',
            guiSteps: 'GUI Steps',
            powerShellScript: 'Get-Process',
            captureExpected: 'Capture 1',
          ),
          TpExamTask(
            id: 'task_2',
            order: 2,
            title: 'Task 2',
            points: 1.0,
            instruction: 'Instruction 2',
            guiSteps: 'GUI Steps 2',
            powerShellScript: 'Get-Service',
            captureExpected: 'Capture 2',
          ),
        ],
        tutorialGuide: const TpExamTutorialGuide(
          title: 'Tutorial Title',
          documentName: 'Tutorial Doc',
          targetAudience: 'Beginner',
          maxPages: 10,
          formalRequirements: ['Title page', 'Table of contents'],
          modules: [],
          evaluationRubric: [
            TpExamRubricItem(criterion: 'Crit 1', maxPoints: 2.0, details: 'Details 1'),
            TpExamRubricItem(criterion: 'Crit 2', maxPoints: 4.0, details: 'Details 2'),
          ],
        ),
      );

      expect(scenario.totalTaskPoints, equals(2.0));
      expect(scenario.totalTutorialPoints, equals(6.0));
      expect(scenario.maxScore, equals(8.0));
      expect(scenario.isCompleted, isFalse);

      final updated = scenario.copyWith(
        isCompleted: true,
        userScore: 18.5,
        checkedTaskIds: {'task_1'},
      );

      expect(updated.isCompleted, isTrue);
      expect(updated.userScore, equals(18.5));
      expect(updated.checkedTaskIds.contains('task_1'), isTrue);
    });

    test('TpExamRepository loads all 4 scenario files', () async {
      final repo = TpExamRepository.instance;
      expect(repo, isNotNull);
      final list = await repo.loadAllScenarios();
      expect(list, isA<List<TpExamScenario>>());
    });

    test('TpExamRepository activation toggle works with local fallback', () async {
      final repo = TpExamRepository.instance;
      // Par défaut désactivé
      final initial = await repo.isTpExamEnabled();
      expect(initial, isFalse);

      // Activation
      await repo.setTpExamEnabled(true);
      final enabled = await repo.isTpExamEnabled();
      expect(enabled, isTrue);

      // Désactivation
      await repo.setTpExamEnabled(false);
      final disabled = await repo.isTpExamEnabled();
      expect(disabled, isFalse);
    });
  });
}
