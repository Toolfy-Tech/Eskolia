import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/services/asset_cache_service.dart';
import 'tip_catalog_loader.dart';

/// Catégories de banques de questions
enum QuizCatalogTrack {
  optimusOnly, // Parcours Officiel Optimus
  terrain,     // Thèmes Terrain — banques hors-parcours ajoutées par le prof
  labo,        // Créations de la communauté (Firestore)
  both,        // Optimus + Terrain (toutes les banques hors-labo)
}

/// Référence d'un bloc de questions (Chapitre ou Thème)
class TipQuizChapterRef {
  const TipQuizChapterRef({
    required this.sectionId,
    required this.sectionTitle,
    required this.moduleId,
    required this.chapterTitle,
    required this.quizAssetPath,
    this.track = QuizCatalogTrack.optimusOnly,
  });

  final String sectionId;
  final String sectionTitle;
  final String moduleId;
  final String chapterTitle;
  final String quizAssetPath;
  final QuizCatalogTrack track;
}

class TipQuizCatalog {
  TipQuizCatalog._();

  /// Chemin sentinel pour les questions Labo (Firestore) — pas un vrai asset.
  static const String laboSentinelPath = 'labo://approved';

  static List<TipQuizChapterRef>? _cache;

  static void clearCache() {
    _cache = null;
  }

  static QuizCatalogTrack parseTrackQuery(String? q) {
    if (q == 'terrain' || q == 'themes') return QuizCatalogTrack.terrain;
    if (q == 'labo') return QuizCatalogTrack.labo;
    return QuizCatalogTrack.optimusOnly;
  }

  /// Banques Terrain — 8 thèmes transversaux ajoutés par le prof.
  static const List<Map<String, String>> _terrainThemes = [
    {'id': 'TRN01', 'title': 'Hardware & Architecture', 'path': 'data/tip-quiz/theme1_hardware.json'},
    {'id': 'TRN02', 'title': 'Windows & Support',        'path': 'data/tip-quiz/theme2_windows.json'},
    {'id': 'TRN03', 'title': 'Réseaux',                  'path': 'data/tip-quiz/theme3_reseaux.json'},
    {'id': 'TRN04', 'title': 'Cybersécurité',            'path': 'data/tip-quiz/theme4_securite.json'},
    {'id': 'TRN05', 'title': 'Support Utilisateur',      'path': 'data/tip-quiz/theme5_support.json'},
    {'id': 'TRN06', 'title': 'Cloud & Infrastructure',   'path': 'data/tip-quiz/theme6_cloud.json'},
    {'id': 'TRN07', 'title': 'Linux & Serveurs',         'path': 'data/tip-quiz/theme7_linux.json'},
    {'id': 'TRN08', 'title': 'Virtualisation',           'path': 'data/tip-quiz/theme8_virtualisation.json'},
  ];

  /// Charge tous les chapitres disponibles : Officiel → Terrain → Labo.
  static Future<List<TipQuizChapterRef>> loadChaptersWithQuiz() async {
    if (_cache != null) return _cache!;

    final out = <TipQuizChapterRef>[];
    final seenPaths = <String>{};

    // 1. Parcours Officiel Optimus
    await _appendFromIndex(
      indexAssetPath: 'data/curriculum/optimus/index.json',
      moduleIdPrefix: 'optimus',
      out: out,
      seenPaths: seenPaths,
      track: QuizCatalogTrack.optimusOnly,
    );

    // 2. Thèmes Terrain (hors-parcours — ajoutés par le prof)
    for (final t in _terrainThemes) {
      final path = t['path']!;
      if (await TipCatalogLoader.assetExists(path)) {
        out.add(TipQuizChapterRef(
          sectionId: 'TERRAIN',
          sectionTitle: 'Terrain',
          moduleId: 'terrain_${t['id']}',
          chapterTitle: t['title']!,
          quizAssetPath: path,
          track: QuizCatalogTrack.terrain,
        ));
      }
    }

    // 3. Labo — entrée unique représentant les questions approuvées (Firestore)
    out.add(TipQuizChapterRef(
      sectionId: 'LABO',
      sectionTitle: 'Le Labo',
      moduleId: 'labo_approved',
      chapterTitle: 'Questions approuvées',
      quizAssetPath: laboSentinelPath,
      track: QuizCatalogTrack.labo,
    ));

    _cache = out;
    return out;
  }

  static Future<void> _appendFromIndex({
    required String indexAssetPath,
    required String moduleIdPrefix,
    required List<TipQuizChapterRef> out,
    required Set<String> seenPaths,
    required QuizCatalogTrack track,
  }) async {
    try {
      final raw = await AssetCacheService.loadString(indexAssetPath);
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final sectionsJson = (map['sections'] as List<dynamic>).cast<Map<String, dynamic>>();
      final chapitresJson = (map['chapitres'] as List<dynamic>).cast<Map<String, dynamic>>();

      final sectionTitles = {for (final s in sectionsJson) s['id'] as String: s['titre'] as String};

      for (final ch in chapitresJson) {
        final sid = ch['section'] as String? ?? '';
        final slug = ch['slug'] as String? ?? '';
        final titre = ch['titre'] as String? ?? '';

        String? quizPath = ch['mastery_quiz_path'] as String?;
        if (quizPath == null || quizPath.isEmpty) continue;

        final fullPath = 'data/$quizPath';
        if (!seenPaths.add(fullPath)) continue;
        if (!await TipCatalogLoader.assetExists(fullPath)) continue;

        out.add(TipQuizChapterRef(
          sectionId: sid,
          sectionTitle: sectionTitles[sid] ?? sid,
          moduleId: '${moduleIdPrefix}_${sid}_$slug',
          chapterTitle: titre,
          quizAssetPath: fullPath,
          track: track,
        ));
      }
    } catch (e) {
      debugPrint('Erreur catalogue: $e');
    }
  }

  static List<TipQuizChapterRef> filterByTrack(List<TipQuizChapterRef> list, QuizCatalogTrack track) {
    if (track == QuizCatalogTrack.both) {
      return list.where((e) => e.track != QuizCatalogTrack.labo).toList();
    }
    return list.where((e) => e.track == track).toList();
  }

  static String contextLineForChapter(TipQuizChapterRef ref) {
    switch (ref.track) {
      case QuizCatalogTrack.optimusOnly:
        return 'Optimus · ${ref.sectionTitle} — ${ref.chapterTitle}';
      case QuizCatalogTrack.terrain:
        return 'Terrain · ${ref.chapterTitle}';
      case QuizCatalogTrack.labo:
        return 'Labo · Questions approuvées';
      case QuizCatalogTrack.both:
        return '${ref.sectionTitle} — ${ref.chapterTitle}';
    }
  }

  static Future<Map<String, TipQuizChapterRef>> pathToChapterRefMap() async {
    final list = await loadChaptersWithQuiz();
    return {for (final c in list) c.quizAssetPath: c};
  }

  static String? fallbackContextLineForAssetPath(String assetPath) {
    if (assetPath.contains('quiz/optimus')) return 'Parcours Optimus';
    if (assetPath.contains('tip-quiz')) return 'Terrain';
    if (assetPath.contains('quiz/themes')) return 'Terrain';
    if (assetPath == laboSentinelPath || assetPath.contains('labo')) return 'Le Labo';
    return 'Eskolia';
  }

  static bool quizAssetPathMatchesCatalogTrack(String path, QuizCatalogTrack track) {
    if (track == QuizCatalogTrack.optimusOnly) return path.contains('quiz/optimus');
    if (track == QuizCatalogTrack.terrain) {
      return path.contains('tip-quiz') || path.contains('quiz/themes');
    }
    if (track == QuizCatalogTrack.labo) return path == laboSentinelPath || path.contains('labo');
    if (track == QuizCatalogTrack.both) {
      return path.contains('quiz/optimus') || path.contains('tip-quiz') || path.contains('quiz/themes');
    }
    return false;
  }

  static Map<String, List<TipQuizChapterRef>> groupBySection(List<TipQuizChapterRef> entries) {
    final map = <String, List<TipQuizChapterRef>>{};
    for (final e in entries) {
      map.putIfAbsent(e.sectionTitle, () => []).add(e);
    }
    return map;
  }

  static String subjectLabelForPaths(List<String> paths) {
    if (paths.isEmpty) return 'Aucun chapitre';
    if (paths.length == 1) {
      final p = paths.first;
      if (p == laboSentinelPath) return 'Le Labo';
      if (p.contains('section-01')) return 'Hardware';
      if (p.contains('section-02')) return 'Systèmes';
      if (p.contains('section-03')) return 'Réseaux';
      if (p.contains('section-04')) return 'Maintenance';
      if (p.contains('section-05')) return 'Sécurité';
      if (p.contains('section-06')) return 'IA';
      if (p.contains('theme1')) return 'Hardware (Terrain)';
      if (p.contains('theme2')) return 'Windows (Terrain)';
      if (p.contains('theme3')) return 'Réseaux (Terrain)';
      if (p.contains('theme4')) return 'Cybersécurité (Terrain)';
      if (p.contains('theme5')) return 'Support (Terrain)';
      if (p.contains('theme6')) return 'Cloud (Terrain)';
      if (p.contains('theme7')) return 'Linux (Terrain)';
      if (p.contains('theme8')) return 'Virtualisation (Terrain)';
      return 'Mixte';
    }
    return 'Multi-chapitres';
  }

  static String quizIdForPaths(List<String> paths) {
    if (paths.isEmpty) return 'empty';
    return 'multi_${paths.length}_${paths.first.hashCode}';
  }

  static String moduleIdForQuizAssetPath(String path) {
    if (path.contains('section-01')) return 'optimus_01';
    if (path.contains('section-02')) return 'optimus_02';
    if (path.contains('section-03')) return 'optimus_03';
    if (path.contains('section-04')) return 'optimus_04';
    if (path.contains('section-05')) return 'optimus_05';
    if (path.contains('section-06')) return 'optimus_06';
    return 'unknown';
  }
}
