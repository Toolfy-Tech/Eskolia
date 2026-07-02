import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocsCardsOrderNotifier extends Notifier<List<String>> {
  static const String _prefKey = 'eskolia_docs_cards_order_v1';
  static const List<String> _defaultOrder = [
    'feature:docs_mes_cours',
    'feature:docs_mes_quiz',
    'feature:docs_rgpd',
    'feature:docs_cnil',
    'feature:docs_anssi',
    'feature:docs_itil',
    'feature:docs_osi',
    'feature:docs_technician',
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
  }
}

final docsCardsOrderProvider = NotifierProvider<DocsCardsOrderNotifier, List<String>>(DocsCardsOrderNotifier.new);

class DocsPinnedCardsNotifier extends Notifier<List<String>> {
  static const String _prefKey = 'eskolia_docs_pinned_cards';

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
  }
}

final docsPinnedCardsProvider = NotifierProvider<DocsPinnedCardsNotifier, List<String>>(DocsPinnedCardsNotifier.new);
