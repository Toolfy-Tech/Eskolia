import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LobbyCardsOrderNotifier extends Notifier<List<String>> {
  static const String _prefKey = 'eskolia_lobby_cards_order_v1';
  static const List<String> _defaultOrder = [
    'feature:lobbys_active',
    'feature:lobbys_create',
    'feature:lobbys_create_ai',
    'feature:lobbys_join_private',
    'feature:duel_quick',
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

final lobbyCardsOrderProvider = NotifierProvider<LobbyCardsOrderNotifier, List<String>>(LobbyCardsOrderNotifier.new);

class LobbyPinnedCardsNotifier extends Notifier<List<String>> {
  static const String _prefKey = 'eskolia_lobby_pinned_cards';

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

final lobbyPinnedCardsProvider = NotifierProvider<LobbyPinnedCardsNotifier, List<String>>(LobbyPinnedCardsNotifier.new);
