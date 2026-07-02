import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../data/tech_news_models.dart';

// Helper asynchrone pour sauvegarder dans Firestore en arrière-plan
Future<void> _updateFirebase(String field, dynamic value) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    try {
      await UserRepository().updateUser(uid, {field: value});
    } catch (_) {}
  }
}

class HomeFavoritesNotifier extends Notifier<List<TechNewsItem>> {
  static const String _prefKey = 'eskolia_home_favorites';

  @override
  List<TechNewsItem> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefKey);
    if (list != null) {
      state = list.map((itemStr) {
        final map = jsonDecode(itemStr) as Map<String, dynamic>;
        return TechNewsItem(
          title: map['title'] as String? ?? '',
          link: map['link'] as String? ?? '',
          sourceLabel: map['sourceLabel'] as String? ?? '',
          category: map['category'] as String? ?? 'it_pro',
          pubDate: map['pubDate'] as String?,
          publishedAt: map['publishedAt'] != null ? DateTime.tryParse(map['publishedAt'] as String) : null,
        );
      }).toList();
    }
  }

  Future<void> toggle(TechNewsItem item) async {
    final exists = state.any((x) => x.link == item.link);
    List<TechNewsItem> next;
    if (exists) {
      next = state.where((x) => x.link != item.link).toList();
    } else {
      next = [...state, item];
    }
    state = next;

    final prefs = await SharedPreferences.getInstance();
    final list = next.map((x) {
      return jsonEncode({
        'title': x.title,
        'link': x.link,
        'sourceLabel': x.sourceLabel,
        'category': x.category,
        'pubDate': x.pubDate,
        'publishedAt': x.publishedAt?.toIso8601String(),
      });
    }).toList();
    await prefs.setStringList(_prefKey, list);
  }

  bool isFavorite(String link) {
    return state.any((x) => x.link == link);
  }
}

final homeFavoritesProvider = NotifierProvider<HomeFavoritesNotifier, List<TechNewsItem>>(HomeFavoritesNotifier.new);

class HomeCardsOrderNotifier extends Notifier<List<String>> {
  static const String _prefKey = 'eskolia_home_cards_order_v2';
  static const List<String> _defaultOrder = ['messages', 'astuces', 'it_pro', 'favoris'];

  @override
  List<String> build() {
    _load();
    return _defaultOrder;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final migrated = prefs.getBool('eskolia_home_cards_v3_migrated') ?? false;
    if (!migrated) {
      await prefs.setStringList(_prefKey, _defaultOrder);
      await prefs.setBool('eskolia_home_cards_v3_migrated', true);
      await _updateFirebase('homeCardsOrder', _defaultOrder);
      state = _defaultOrder;
      return;
    }

    final list = prefs.getStringList(_prefKey);
    if (list != null) {
      state = list;
    }
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = List<String>.from(state);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, list);
    await _updateFirebase('homeCardsOrder', list);
  }

  Future<void> addCard(String key) async {
    if (state.contains(key)) return;
    final next = [...state, key];
    state = next;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, next);
    await _updateFirebase('homeCardsOrder', next);
  }

  Future<void> removeCard(String key) async {
    if (!state.contains(key)) return;
    final next = state.where((x) => x != key).toList();
    state = next;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, next);
    await _updateFirebase('homeCardsOrder', next);
  }

  Future<void> mergeCards(String keyA, String keyB) async {
    final list = List<String>.from(state);
    final idxA = list.indexOf(keyA);
    final idxB = list.indexOf(keyB);
    if (idxA == -1 || idxB == -1) return;

    List<String> getSubKeys(String key) {
      if (key.startsWith('merge:')) {
        return key.substring(6).split('+');
      }
      return [key];
    }

    final mergedKeys = [...getSubKeys(keyA), ...getSubKeys(keyB)];
    final newKey = 'merge:${mergedKeys.join('+')}';

    list.removeAt(idxA);
    final newIdxB = list.indexOf(keyB);
    if (newIdxB != -1) {
      list.removeAt(newIdxB);
    }

    list.insert(idxA < list.length ? idxA : list.length, newKey);
    state = list;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, list);
    await _updateFirebase('homeCardsOrder', list);
  }

  Future<void> unmergeCard(String mergeKey) async {
    if (!mergeKey.startsWith('merge:')) return;
    final list = List<String>.from(state);
    final idx = list.indexOf(mergeKey);
    if (idx == -1) return;

    final subKeys = mergeKey.substring(6).split('+');
    list.removeAt(idx);

    for (var i = 0; i < subKeys.length; i++) {
      list.insert(idx + i, subKeys[i]);
    }
    state = list;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, list);
    await _updateFirebase('homeCardsOrder', list);
  }

  void syncFromFirestore(List<String> firestoreList) {
    if (firestoreList.isEmpty) return;
    bool changed = false;
    if (firestoreList.length != state.length) {
      changed = true;
    } else {
      for (var i = 0; i < firestoreList.length; i++) {
        if (firestoreList[i] != state[i]) {
          changed = true;
          break;
        }
      }
    }
    if (changed) {
      state = firestoreList;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList(_prefKey, firestoreList);
      });
    }
  }
}

final homeCardsOrderProvider = NotifierProvider<HomeCardsOrderNotifier, List<String>>(HomeCardsOrderNotifier.new);

class HomePinnedCardsNotifier extends Notifier<List<String>> {
  static const String _prefKey = 'eskolia_home_pinned_cards_v2';

  @override
  List<String> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefKey);
    if (list != null) {
      state = list;
    }
  }

  Future<void> togglePin(String key) async {
    final isPinned = state.contains(key);
    List<String> next;
    if (isPinned) {
      next = state.where((x) => x != key).toList();
    } else {
      next = [...state, key];
    }
    state = next;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, next);
    await _updateFirebase('homePinnedCards', next);
  }

  void syncFromFirestore(List<String> firestoreList) {
    bool changed = false;
    if (firestoreList.length != state.length) {
      changed = true;
    } else {
      for (var i = 0; i < firestoreList.length; i++) {
        if (!state.contains(firestoreList[i])) {
          changed = true;
          break;
        }
      }
    }
    if (changed) {
      state = firestoreList;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList(_prefKey, firestoreList);
      });
    }
  }
}

final homePinnedCardsProvider = NotifierProvider<HomePinnedCardsNotifier, List<String>>(HomePinnedCardsNotifier.new);

class HomeSubscribedSourcesNotifier extends Notifier<List<String>> {
  static const String _prefKey = 'eskolia_home_subscribed_sources';

  @override
  List<String> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefKey);
    if (list != null) {
      state = list;
    }
  }

  Future<void> subscribe(String source) async {
    if (state.contains(source)) return;
    final next = [...state, source];
    state = next;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, next);
    await _updateFirebase('subscribedSources', next);

    final cardKey = 'source:$source';
    ref.read(homeCardsOrderProvider.notifier).addCard(cardKey);
    ref.read(veilleCardsOrderProvider.notifier).addCard(cardKey);
  }

  Future<void> unsubscribe(String source) async {
    if (!state.contains(source)) return;
    final next = state.where((x) => x != source).toList();
    state = next;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, next);
    await _updateFirebase('subscribedSources', next);

    final cardKey = 'source:$source';
    ref.read(homeCardsOrderProvider.notifier).removeCard(cardKey);
    ref.read(veilleCardsOrderProvider.notifier).removeCard(cardKey);

    final pinned = ref.read(homePinnedCardsProvider);
    if (pinned.contains(cardKey)) {
      ref.read(homePinnedCardsProvider.notifier).togglePin(cardKey);
    }
  }

  void syncFromFirestore(List<String> firestoreList) {
    bool changed = false;
    if (firestoreList.length != state.length) {
      changed = true;
    } else {
      for (var i = 0; i < firestoreList.length; i++) {
        if (!state.contains(firestoreList[i])) {
          changed = true;
          break;
        }
      }
    }
    if (changed) {
      state = firestoreList;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList(_prefKey, firestoreList);
      });
    }
  }
}

final homeSubscribedSourcesProvider = NotifierProvider<HomeSubscribedSourcesNotifier, List<String>>(HomeSubscribedSourcesNotifier.new);

class HomeCardSettings {
  final String title;
  final String emoji;
  final int colorHex;
  final int limit;
  final String sortBy;
  final bool isCollapsed;
  final int scrollInterval;

  HomeCardSettings({
    required this.title,
    required this.emoji,
    required this.colorHex,
    this.limit = 5,
    this.sortBy = 'newest',
    this.isCollapsed = false,
    this.scrollInterval = 12,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'emoji': emoji,
        'colorHex': colorHex,
        'limit': limit,
        'sortBy': sortBy,
        'isCollapsed': isCollapsed,
        'scrollInterval': scrollInterval,
      };

  factory HomeCardSettings.fromJson(Map<String, dynamic> json) {
    return HomeCardSettings(
      title: json['title'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '💡',
      colorHex: json['colorHex'] as int? ?? 0xFF00FFFF,
      limit: json['limit'] as int? ?? 5,
      sortBy: json['sortBy'] as String? ?? 'newest',
      isCollapsed: json['isCollapsed'] as bool? ?? false,
      scrollInterval: json['scrollInterval'] as int? ?? 12,
    );
  }

  HomeCardSettings copyWith({
    String? title,
    String? emoji,
    int? colorHex,
    int? limit,
    String? sortBy,
    bool? isCollapsed,
    int? scrollInterval,
  }) {
    return HomeCardSettings(
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      colorHex: colorHex ?? this.colorHex,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      isCollapsed: isCollapsed ?? this.isCollapsed,
      scrollInterval: scrollInterval ?? this.scrollInterval,
    );
  }
}

class HomeCardSettingsNotifier extends Notifier<Map<String, HomeCardSettings>> {
  static const String _prefKey = 'eskolia_home_card_settings';

  @override
  Map<String, HomeCardSettings> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_prefKey);
    if (rawJson != null) {
      try {
        final map = jsonDecode(rawJson) as Map<String, dynamic>;
        var hasChanges = false;
        final loaded = map.map((key, val) {
          var settings = HomeCardSettings.fromJson(val as Map<String, dynamic>);
          if (key == 'feature:parcours' &&
              (settings.title == 'Formation & Syllabus' ||
               settings.title == 'Formation TIP' ||
               settings.title.isEmpty)) {
            settings = settings.copyWith(title: 'Cours formation TIP');
            hasChanges = true;
          }
          if (key == 'feature:lexique' &&
              (settings.title == 'Méga Lexique' ||
               settings.title == 'Lexique IT' ||
               settings.title.isEmpty)) {
            settings = settings.copyWith(title: 'Lexique TIP');
            hasChanges = true;
          }
          if (key == 'feature:mediatheque' &&
              (settings.title == 'Médiathèque complète' ||
               settings.title.isEmpty)) {
            settings = settings.copyWith(title: 'Média TIP');
            hasChanges = true;
          }
          if (key == 'feature:examen_blanc' &&
              (settings.title == 'Examen blanc' ||
               settings.title == 'Validation' ||
               settings.title.isEmpty)) {
            settings = settings.copyWith(title: 'Validation TIP');
            hasChanges = true;
          }
          if (key == 'feature:podcasts' &&
              (settings.title == 'Podcasts IT' ||
               settings.title == 'Lecteur Podcasts' ||
               settings.title.isEmpty)) {
            settings = settings.copyWith(title: 'Podcast TIP');
            hasChanges = true;
          }
          return MapEntry(key, settings);
        });
        state = loaded;
        if (hasChanges) {
          final encoded = jsonEncode(loaded.map((k, v) => MapEntry(k, v.toJson())));
          await prefs.setString(_prefKey, encoded);
          await _updateFirebase('cardSettings', loaded.map((k, v) => MapEntry(k, v.toJson())));
        }
      } catch (_) {}
    }
  }

  Future<void> updateSettings(String key, HomeCardSettings settings) async {
    final next = Map<String, HomeCardSettings>.from(state);
    next[key] = settings;
    state = next;

    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(next.map((k, v) => MapEntry(k, v.toJson())));
    await prefs.setString(_prefKey, encoded);
    await _updateFirebase('cardSettings', next.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> toggleCollapse(String key) async {
    final next = Map<String, HomeCardSettings>.from(state);
    final current = next[key];
    if (current != null) {
      next[key] = current.copyWith(isCollapsed: !current.isCollapsed);
    } else {
      next[key] = HomeCardSettings(
        title: '',
        emoji: '',
        colorHex: 0xFF00FFFF,
        isCollapsed: true,
      );
    }
    state = next;

    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(next.map((k, v) => MapEntry(k, v.toJson())));
    await prefs.setString(_prefKey, encoded);
    await _updateFirebase('cardSettings', next.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> collapseAll(List<String> keys) async {
    final next = Map<String, HomeCardSettings>.from(state);
    for (final key in keys) {
      final current = next[key];
      if (current != null) {
        next[key] = current.copyWith(isCollapsed: true);
      } else {
        next[key] = HomeCardSettings(
          title: '',
          emoji: '',
          colorHex: 0xFF00FFFF,
          isCollapsed: true,
        );
      }
    }
    state = next;

    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(next.map((k, v) => MapEntry(k, v.toJson())));
    await prefs.setString(_prefKey, encoded);
    await _updateFirebase('cardSettings', next.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> expandAll(List<String> keys) async {
    final next = Map<String, HomeCardSettings>.from(state);
    for (final key in keys) {
      final current = next[key];
      if (current != null) {
        next[key] = current.copyWith(isCollapsed: false);
      } else {
        next[key] = HomeCardSettings(
          title: '',
          emoji: '',
          colorHex: 0xFF00FFFF,
          isCollapsed: false,
        );
      }
    }
    state = next;

    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(next.map((k, v) => MapEntry(k, v.toJson())));
    await prefs.setString(_prefKey, encoded);
    await _updateFirebase('cardSettings', next.map((k, v) => MapEntry(k, v.toJson())));
  }

  void syncFromFirestore(Map<String, dynamic> firestoreMap) {
    try {
      final next = firestoreMap.map((key, val) {
        return MapEntry(key, HomeCardSettings.fromJson(val as Map<String, dynamic>));
      });
      bool changed = false;
      if (next.length != state.length) {
        changed = true;
      } else {
        for (final k in next.keys) {
          if (!state.containsKey(k) ||
              state[k]?.title != next[k]?.title ||
              state[k]?.emoji != next[k]?.emoji ||
              state[k]?.colorHex != next[k]?.colorHex ||
              state[k]?.limit != next[k]?.limit ||
              state[k]?.sortBy != next[k]?.sortBy ||
              state[k]?.isCollapsed != next[k]?.isCollapsed ||
              state[k]?.scrollInterval != next[k]?.scrollInterval) {
            changed = true;
            break;
          }
        }
      }
      if (changed) {
        state = next;
        SharedPreferences.getInstance().then((prefs) {
          final encoded = jsonEncode(next.map((k, v) => MapEntry(k, v.toJson())));
          prefs.setString(_prefKey, encoded);
        });
      }
    } catch (_) {}
  }
}

final homeCardSettingsProvider = NotifierProvider<HomeCardSettingsNotifier, Map<String, HomeCardSettings>>(HomeCardSettingsNotifier.new);

class VeillePinnedCardsNotifier extends Notifier<List<String>> {
  static const String _prefKey = 'eskolia_veille_pinned_cards';

  @override
  List<String> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefKey);
    if (list != null) {
      state = list;
    }
  }

  Future<void> togglePin(String key) async {
    final isPinned = state.contains(key);
    List<String> next;
    if (isPinned) {
      next = state.where((x) => x != key).toList();
    } else {
      next = [...state, key];
    }
    state = next;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, next);
    await _updateFirebase('veillePinnedCards', next);
  }

  void syncFromFirestore(List<String> firestoreList) {
    bool changed = false;
    if (firestoreList.length != state.length) {
      changed = true;
    } else {
      for (var i = 0; i < firestoreList.length; i++) {
        if (!state.contains(firestoreList[i])) {
          changed = true;
          break;
        }
      }
    }
    if (changed) {
      state = firestoreList;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList(_prefKey, firestoreList);
      });
    }
  }
}

final veillePinnedCardsProvider = NotifierProvider<VeillePinnedCardsNotifier, List<String>>(VeillePinnedCardsNotifier.new);

class VeilleCardsOrderNotifier extends Notifier<List<String>> {
  static const String _prefKey = 'eskolia_veille_cards_order';
  static const List<String> _defaultOrder = [
    'messages',
    'astuces',
    'it_pro',
    'it',
    'security',
    'hardware',
    'software',
    'favoris',
  ];

  @override
  List<String> build() {
    _load();
    return _defaultOrder;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefKey);
    if (list != null) {
      final merged = List<String>.from(list);
      for (final def in _defaultOrder) {
        if (!merged.contains(def)) {
          merged.add(def);
        }
      }
      state = merged;
    } else {
      state = _defaultOrder;
    }
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = List<String>.from(state);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, list);
    await _updateFirebase('veilleCardsOrder', list);
  }

  Future<void> addCard(String key) async {
    if (state.contains(key)) return;
    final next = [...state, key];
    state = next;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, next);
    await _updateFirebase('veilleCardsOrder', next);
  }

  Future<void> removeCard(String key) async {
    if (!state.contains(key)) return;
    final next = state.where((x) => x != key).toList();
    state = next;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, next);
    await _updateFirebase('veilleCardsOrder', next);
  }
}

final veilleCardsOrderProvider = NotifierProvider<VeilleCardsOrderNotifier, List<String>>(VeilleCardsOrderNotifier.new);

class NotebookPinnedNotesNotifier extends Notifier<List<String>> {
  static const String _prefKey = 'eskolia_notebook_pinned_notes';

  @override
  List<String> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefKey);
    if (list != null) {
      state = list;
    }
  }

  Future<void> togglePin(String noteId) async {
    final isPinned = state.contains(noteId);
    List<String> next;
    if (isPinned) {
      next = state.where((x) => x != noteId).toList();
    } else {
      next = [...state, noteId];
    }
    state = next;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, next);
    await _updateFirebase('notebookPinnedNotes', next);
  }

  void syncFromFirestore(List<String> firestoreList) {
    bool changed = false;
    if (firestoreList.length != state.length) {
      changed = true;
    } else {
      for (var i = 0; i < firestoreList.length; i++) {
        if (!state.contains(firestoreList[i])) {
          changed = true;
          break;
        }
      }
    }
    if (changed) {
      state = firestoreList;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList(_prefKey, firestoreList);
      });
    }
  }
}

final notebookPinnedNotesProvider = NotifierProvider<NotebookPinnedNotesNotifier, List<String>>(NotebookPinnedNotesNotifier.new);

class NotebookNotesOrderNotifier extends Notifier<List<String>> {
  static const String _prefKey = 'eskolia_notebook_notes_order';

  @override
  List<String> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefKey);
    if (list != null) {
      state = list;
    }
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = List<String>.from(state);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, list);
    await _updateFirebase('notebookNotesOrder', list);
  }

  Future<void> updateOrder(List<String> allIds) async {
    final list = List<String>.from(state);
    // Supprimer les IDs obsolètes
    list.removeWhere((id) => !allIds.contains(id));
    // Ajouter les nouveaux IDs à la fin
    for (final id in allIds) {
      if (!list.contains(id)) {
        list.add(id);
      }
    }
    state = list;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, list);
  }
}

final notebookNotesOrderProvider = NotifierProvider<NotebookNotesOrderNotifier, List<String>>(NotebookNotesOrderNotifier.new);

