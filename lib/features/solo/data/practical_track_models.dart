import 'dart:convert';

class PracticalTrackSummary {
  const PracticalTrackSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;

  static List<PracticalTrackSummary> parseIndex(String jsonStr) {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    final list = (map['tracks'] as List<dynamic>).cast<Map<String, dynamic>>();
    return list
        .map(
          (e) => PracticalTrackSummary(
            id: e['id'] as String? ?? '',
            title: e['title'] as String? ?? '',
            description: e['description'] as String? ?? '',
            emoji: e['emoji'] as String? ?? '1F4BB',
          ),
        )
        .where((t) => t.id.isNotEmpty)
        .toList();
  }
}

class PracticalTutorialRef {
  const PracticalTutorialRef({required this.label, required this.asset});

  final String label;
  final String asset;

  static PracticalTutorialRef? fromJson(Map<String, dynamic>? m) {
    if (m == null) return null;
    final label = m['label'] as String? ?? '';
    final asset = m['asset'] as String? ?? '';
    if (label.isEmpty || asset.isEmpty) return null;
    return PracticalTutorialRef(label: label, asset: asset);
  }
}

class PracticalTrackManifest {
  const PracticalTrackManifest({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tutorials,
    required this.exercisesAsset,
    required this.quizTheoryAsset,
    required this.quizPratiqueAsset,
    required this.tipModuleId,
    this.missionsAsset,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<PracticalTutorialRef> tutorials;
  final String exercisesAsset;
  final String quizTheoryAsset;
  final String quizPratiqueAsset;
  final String tipModuleId;

  /// Parcours « une mission après l’autre » sur VM (auto-validation), si présent.
  final String? missionsAsset;

  static PracticalTrackManifest parse(String jsonStr) {
    final m = jsonDecode(jsonStr) as Map<String, dynamic>;
    final tutRaw = (m['tutorials'] as List<dynamic>?) ?? const [];
    final tutorials = tutRaw
        .map((e) => PracticalTutorialRef.fromJson(e as Map<String, dynamic>?))
        .whereType<PracticalTutorialRef>()
        .toList();
    final missionsRaw = (m['missionsAsset'] as String?)?.trim();
    return PracticalTrackManifest(
      id: m['id'] as String? ?? '',
      title: m['title'] as String? ?? '',
      subtitle: m['subtitle'] as String? ?? '',
      tutorials: tutorials,
      exercisesAsset: m['exercisesAsset'] as String? ?? '',
      quizTheoryAsset: m['quizTheoryAsset'] as String? ?? '',
      quizPratiqueAsset: m['quizPratiqueAsset'] as String? ?? '',
      tipModuleId: m['tipModuleId'] as String? ?? '',
      missionsAsset:
          missionsRaw != null && missionsRaw.isNotEmpty ? missionsRaw : null,
    );
  }
}

/// Mission d’un parcours type « GameShell » sur VM (contenu asset JSON).
class PracticalMission {
  const PracticalMission({
    required this.id,
    required this.title,
    required this.intro,
    required this.steps,
  });

  final String id;
  final String title;
  final String intro;
  final List<String> steps;

  static PracticalMission? fromJson(Map<String, dynamic> m) {
    final id = m['id'] as String? ?? '';
    final title = m['title'] as String? ?? '';
    if (id.isEmpty || title.isEmpty) return null;
    final stepsRaw = m['steps'];
    final steps = stepsRaw is List
        ? stepsRaw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList()
        : const <String>[];
    return PracticalMission(
      id: id,
      title: title,
      intro: (m['intro'] as String?)?.trim() ?? '',
      steps: steps,
    );
  }
}

/// Fichier [missions.json] d’un thème TP.
class PracticalMissionsPack {
  const PracticalMissionsPack({
    required this.title,
    required this.subtitle,
    required this.missions,
  });

  final String title;
  final String subtitle;
  final List<PracticalMission> missions;

  static PracticalMissionsPack parse(String jsonStr) {
    final m = jsonDecode(jsonStr) as Map<String, dynamic>;
    final raw = (m['missions'] as List<dynamic>?) ?? const [];
    final missions = <PracticalMission>[];
    for (final e in raw) {
      if (e is! Map) continue;
      final pm = PracticalMission.fromJson(Map<String, dynamic>.from(e));
      if (pm != null) missions.add(pm);
    }
    return PracticalMissionsPack(
      title: m['title'] as String? ?? 'Missions',
      subtitle: m['subtitle'] as String? ?? '',
      missions: missions,
    );
  }
}

class PracticalExercise {
  const PracticalExercise({
    required this.id,
    required this.title,
    required this.objectif,
    required this.etapes,
  });

  final String id;
  final String title;
  final String objectif;
  final List<String> etapes;

  static PracticalExercise fromJson(Map<String, dynamic> m) {
    List<String> strList(dynamic x) {
      if (x is! List) return const [];
      return x.map((e) => e.toString()).toList();
    }

    return PracticalExercise(
      id: m['id'] as String? ?? '',
      title: m['title'] as String? ?? '',
      objectif: m['objectif'] as String? ?? '',
      etapes: strList(m['etapes']),
    );
  }

  static List<PracticalExercise> parseList(String jsonStr) {
    final decoded = jsonDecode(jsonStr);
    if (decoded is! List) return [];
    return decoded
        .map((e) => PracticalExercise.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((e) => e.id.isNotEmpty && e.title.isNotEmpty)
        .toList();
  }
}
