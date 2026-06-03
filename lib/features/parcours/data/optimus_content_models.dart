import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LexiqueEntry {
  const LexiqueEntry({
    required this.term,
    required this.definition,
    this.chapterSlug,
  });

  final String term;
  final String definition;

  /// Slug du chapitre auquel ce terme est rattaché (ex. "M01-CH05-outils-ticketing-parc").
  /// Null = terme de niveau module uniquement.
  final String? chapterSlug;

  factory LexiqueEntry.fromJson(Map<dynamic, dynamic> j) => LexiqueEntry(
        term: j['term'] as String,
        definition: j['definition'] as String,
        chapterSlug: j['chapterSlug'] as String?,
      );
}

class ModuleLexique {
  const ModuleLexique({required this.moduleId, required this.terms});

  final String moduleId;
  final List<LexiqueEntry> terms;
}

class MediathequeItem {
  const MediathequeItem({
    required this.title,
    required this.creator,
    required this.url,
    this.chapterSlug,
  });

  final String title;
  final String creator;
  final String url;
  final String? chapterSlug;

  factory MediathequeItem.fromJson(Map<dynamic, dynamic> j) => MediathequeItem(
        title: j['title'] as String,
        creator: j['creator'] as String,
        url: j['url'] as String,
        chapterSlug: j['chapterSlug'] as String?,
      );
}

class VeilleItem {
  const VeilleItem({
    required this.title,
    required this.url,
    required this.description,
  });

  final String title;
  final String url;
  final String description;

  factory VeilleItem.fromJson(Map<dynamic, dynamic> j) => VeilleItem(
        title: j['title'] as String,
        url: j['url'] as String,
        description: j['description'] as String,
      );
}

class ModuleMediatheque {
  const ModuleMediatheque({
    required this.moduleId,
    required this.specific,
    required this.veille,
  });

  final String moduleId;
  final List<MediathequeItem> specific;
  final List<VeilleItem> veille;
}

abstract final class OptimusLexiqueRepository {
  static const List<String> _moduleIds = [
    'M01', 'M02', 'M03', 'M04', 'M05', 'M06', 'M07', 'M08',
  ];

  static final Map<String, ModuleLexique> _cache = {};

  static Future<ModuleLexique> loadModule(String moduleId) async {
    if (_cache.containsKey(moduleId)) return _cache[moduleId]!;
    final raw = await rootBundle
        .loadString('data/lexique/optimus/$moduleId.json');
    final map = jsonDecode(raw);
    if (map is! Map) return ModuleLexique(moduleId: moduleId, terms: const []);
    final items = map['terms'];
    if (items is! List) return ModuleLexique(moduleId: moduleId, terms: const []);
    final terms = items
        .whereType<Map>()
        .map(LexiqueEntry.fromJson)
        .toList();
    final result = ModuleLexique(moduleId: moduleId, terms: terms);
    _cache[moduleId] = result;
    return result;
  }

  static Future<List<LexiqueEntry>> forChapter(
      String moduleId, String chapterSlug) async {
    final mod = await loadModule(moduleId);
    return mod.terms
        .where((t) => t.chapterSlug == chapterSlug)
        .toList();
  }

  static Future<List<ModuleLexique>> loadAll() async {
    final results = <ModuleLexique>[];
    for (final id in _moduleIds) {
      try {
        results.add(await loadModule(id));
      } catch (_) {}
    }
    return results;
  }
}

class SupportItem {
  const SupportItem({
    required this.chapterSlug,
    required this.type,
    required this.title,
    required this.filename,
    required this.description,
    required this.releaseBaseUrl,
  });

  final String chapterSlug;

  /// 'image' | 'pdf' | 'video'
  final String type;
  final String title;
  final String filename;
  final String description;
  final String releaseBaseUrl;

  String get url => '$releaseBaseUrl$filename';

  factory SupportItem.fromJson(Map<dynamic, dynamic> j, String baseUrl) =>
      SupportItem(
        chapterSlug: j['chapterSlug'] as String,
        type: j['type'] as String,
        title: j['title'] as String,
        filename: j['filename'] as String,
        description: j['description'] as String,
        releaseBaseUrl: baseUrl,
      );
}

class ModuleSupports {
  const ModuleSupports({required this.moduleId, required this.items});

  final String moduleId;
  final List<SupportItem> items;
}

abstract final class OptimusSupportsRepository {
  static const List<String> _moduleIds = [
    'M01', 'M02', 'M03', 'M04', 'M05', 'M06', 'M07', 'M08',
  ];

  static final Map<String, ModuleSupports> _cache = {};

  static Future<ModuleSupports> loadModule(String moduleId) async {
    if (_cache.containsKey(moduleId)) return _cache[moduleId]!;
    final raw = await rootBundle
        .loadString('data/supports/optimus/$moduleId.json');
    final map = jsonDecode(raw);
    final empty = ModuleSupports(moduleId: moduleId, items: const []);
    if (map is! Map) return empty;
    final baseUrl = map['releaseBaseUrl'] as String? ?? '';
    final list = map['supports'];
    if (list is! List) return empty;
    final items = list
        .whereType<Map>()
        .map((j) => SupportItem.fromJson(j, baseUrl))
        .toList();
    final result = ModuleSupports(moduleId: moduleId, items: items);
    _cache[moduleId] = result;
    return result;
  }

  static Future<List<SupportItem>> forChapter(
      String moduleId, String chapterSlug) async {
    try {
      final mod = await loadModule(moduleId);
      return mod.items.where((i) => i.chapterSlug == chapterSlug).toList();
    } catch (_) {
      return const [];
    }
  }
}

abstract final class OptimusMediathequeRepository {
  static const List<String> _moduleIds = [
    'M01', 'M02', 'M03', 'M04', 'M05', 'M06', 'M07', 'M08',
  ];

  static final Map<String, ModuleMediatheque> _cache = {};

  static Future<ModuleMediatheque> loadModule(String moduleId) async {
    if (_cache.containsKey(moduleId)) return _cache[moduleId]!;
    final raw = await rootBundle
        .loadString('data/mediatheque/optimus/$moduleId.json');
    final map = jsonDecode(raw);
    final empty = ModuleMediatheque(
        moduleId: moduleId, specific: const [], veille: const []);
    if (map is! Map) return empty;

    final specificList = map['specific'];
    final veille = map['veille'];
    final specific = specificList is List
        ? specificList.whereType<Map>().map(MediathequeItem.fromJson).toList()
        : <MediathequeItem>[];
    final veilleItems = veille is List
        ? veille.whereType<Map>().map(VeilleItem.fromJson).toList()
        : <VeilleItem>[];

    final result = ModuleMediatheque(
        moduleId: moduleId, specific: specific, veille: veilleItems);
    _cache[moduleId] = result;
    return result;
  }

  static Future<List<MediathequeItem>> specificForChapter(
      String moduleId, String chapterSlug) async {
    final mod = await loadModule(moduleId);
    return mod.specific
        .where((i) => i.chapterSlug == chapterSlug)
        .toList();
  }

  static Future<List<ModuleMediatheque>> loadAll() async {
    final results = <ModuleMediatheque>[];
    for (final id in _moduleIds) {
      try {
        results.add(await loadModule(id));
      } catch (_) {}
    }
    return results;
  }
}
