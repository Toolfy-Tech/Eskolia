class TpExamScenario {
  const TpExamScenario({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.candidateName,
    required this.companyName,
    required this.role,
    required this.accessibilityContext,
    required this.vmInfo,
    required this.tasks,
    required this.tutorialGuide,
    this.isCompleted = false,
    this.completedAt,
    this.userScore,
    this.checkedTaskIds = const {},
  });

  final String id;
  final String title;
  final String subtitle;
  final String candidateName;
  final String companyName;
  final String role;
  final String accessibilityContext;
  final TpExamVmInfo vmInfo;
  final List<TpExamTask> tasks;
  final TpExamTutorialGuide tutorialGuide;
  final bool isCompleted;
  final DateTime? completedAt;
  final double? userScore; // Note sur 20
  final Set<String> checkedTaskIds;

  double get totalTaskPoints => tasks.fold(0.0, (sum, t) => sum + t.points);
  double get totalTutorialPoints => tutorialGuide.evaluationRubric.fold(0.0, (sum, r) => sum + r.maxPoints);
  double get maxScore => totalTaskPoints + totalTutorialPoints;

  TpExamScenario copyWith({
    bool? isCompleted,
    DateTime? completedAt,
    double? userScore,
    Set<String>? checkedTaskIds,
  }) {
    return TpExamScenario(
      id: id,
      title: title,
      subtitle: subtitle,
      candidateName: candidateName,
      companyName: companyName,
      role: role,
      accessibilityContext: accessibilityContext,
      vmInfo: vmInfo,
      tasks: tasks,
      tutorialGuide: tutorialGuide,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      userScore: userScore ?? this.userScore,
      checkedTaskIds: checkedTaskIds ?? this.checkedTaskIds,
    );
  }

  factory TpExamScenario.fromJson(Map<String, dynamic> json) {
    final tasksList = (json['tasks'] as List<dynamic>? ?? [])
        .map((t) => TpExamTask.fromJson(t as Map<String, dynamic>))
        .toList();

    return TpExamScenario(
      id: json['id'] as String? ?? 'tp_exam_unknown',
      title: json['title'] as String? ?? 'Épreuve Pratique TIP',
      subtitle: json['subtitle'] as String? ?? '',
      candidateName: json['candidateName'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      role: json['role'] as String? ?? '',
      accessibilityContext: json['accessibilityContext'] as String? ?? '',
      vmInfo: TpExamVmInfo.fromJson(json['vmInfo'] as Map<String, dynamic>? ?? {}),
      tasks: tasksList,
      tutorialGuide: TpExamTutorialGuide.fromJson(json['tutorialGuide'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class TpExamVmInfo {
  const TpExamVmInfo({
    required this.vmName,
    required this.targetHostname,
    required this.os,
    required this.adminUser,
    required this.adminPassword,
    required this.tpmKey,
    required this.userAccount,
  });

  final String vmName;
  final String targetHostname;
  final String os;
  final String adminUser;
  final String adminPassword;
  final String tpmKey;
  final TpExamUserAccount userAccount;

  factory TpExamVmInfo.fromJson(Map<String, dynamic> json) {
    return TpExamVmInfo(
      vmName: json['vmName'] as String? ?? 'MV-Client',
      targetHostname: json['targetHostname'] as String? ?? 'MV-Station',
      os: json['os'] as String? ?? 'Windows 11 English',
      adminUser: json['adminUser'] as String? ?? 'Admin',
      adminPassword: json['adminPassword'] as String? ?? '',
      tpmKey: json['tpmKey'] as String? ?? '',
      userAccount: TpExamUserAccount.fromJson(json['userAccount'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class TpExamUserAccount {
  const TpExamUserAccount({
    required this.username,
    required this.fullName,
    required this.password,
    this.isAdministrator = false,
  });

  final String username;
  final String fullName;
  final String password;
  final bool isAdministrator;

  factory TpExamUserAccount.fromJson(Map<String, dynamic> json) {
    return TpExamUserAccount(
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      password: json['password'] as String? ?? '',
      isAdministrator: json['isAdministrator'] as bool? ?? false,
    );
  }
}

class TpExamTask {
  const TpExamTask({
    required this.id,
    required this.order,
    required this.title,
    required this.points,
    required this.instruction,
    required this.guiSteps,
    required this.powerShellScript,
    required this.captureExpected,
  });

  final String id;
  final int order;
  final String title;
  final double points;
  final String instruction;
  final String guiSteps;
  final String powerShellScript;
  final String captureExpected;

  factory TpExamTask.fromJson(Map<String, dynamic> json) {
    return TpExamTask(
      id: json['id'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? '',
      points: (json['points'] as num?)?.toDouble() ?? 1.0,
      instruction: json['instruction'] as String? ?? '',
      guiSteps: json['guiSteps'] as String? ?? '',
      powerShellScript: json['powerShellScript'] as String? ?? '',
      captureExpected: json['captureExpected'] as String? ?? '',
    );
  }
}

class TpExamTutorialGuide {
  const TpExamTutorialGuide({
    required this.title,
    required this.documentName,
    required this.targetAudience,
    required this.maxPages,
    required this.formalRequirements,
    required this.modules,
    required this.evaluationRubric,
  });

  final String title;
  final String documentName;
  final String targetAudience;
  final int maxPages;
  final List<String> formalRequirements;
  final List<TpExamTutorialModule> modules;
  final List<TpExamRubricItem> evaluationRubric;

  factory TpExamTutorialGuide.fromJson(Map<String, dynamic> json) {
    return TpExamTutorialGuide(
      title: json['title'] as String? ?? '',
      documentName: json['documentName'] as String? ?? '',
      targetAudience: json['targetAudience'] as String? ?? '',
      maxPages: (json['maxPages'] as num?)?.toInt() ?? 10,
      formalRequirements: (json['formalRequirements'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      modules: (json['modules'] as List<dynamic>? ?? [])
          .map((m) => TpExamTutorialModule.fromJson(m as Map<String, dynamic>))
          .toList(),
      evaluationRubric: (json['evaluationRubric'] as List<dynamic>? ?? [])
          .map((r) => TpExamRubricItem.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TpExamTutorialModule {
  const TpExamTutorialModule({
    required this.moduleNumber,
    required this.title,
    required this.description,
    required this.steps,
  });

  final int moduleNumber;
  final String title;
  final String description;
  final List<TpExamTutorialStep> steps;

  factory TpExamTutorialModule.fromJson(Map<String, dynamic> json) {
    return TpExamTutorialModule(
      moduleNumber: (json['moduleNumber'] as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      steps: (json['steps'] as List<dynamic>? ?? [])
          .map((s) => TpExamTutorialStep.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TpExamTutorialStep {
  const TpExamTutorialStep({
    required this.stepNumber,
    required this.stepTitle,
    required this.instruction,
  });

  final int stepNumber;
  final String stepTitle;
  final String instruction;

  factory TpExamTutorialStep.fromJson(Map<String, dynamic> json) {
    return TpExamTutorialStep(
      stepNumber: (json['stepNumber'] as num?)?.toInt() ?? 1,
      stepTitle: json['stepTitle'] as String? ?? '',
      instruction: json['instruction'] as String? ?? '',
    );
  }
}

class TpExamRubricItem {
  const TpExamRubricItem({
    required this.criterion,
    required this.maxPoints,
    required this.details,
  });

  final String criterion;
  final double maxPoints;
  final String details;

  factory TpExamRubricItem.fromJson(Map<String, dynamic> json) {
    return TpExamRubricItem(
      criterion: json['criterion'] as String? ?? '',
      maxPoints: (json['maxPoints'] as num?)?.toDouble() ?? 1.0,
      details: json['details'] as String? ?? '',
    );
  }
}
