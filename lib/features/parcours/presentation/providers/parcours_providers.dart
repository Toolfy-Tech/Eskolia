import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/parcours_repository.dart';
import '../../../podcasts/data/podcast_model.dart';

final parcoursFormationsProvider = StreamProvider.autoDispose<List<FormationModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  return ParcoursRepository().watchFormations(uid);
});

class HomeSelectedModuleIndexNotifier extends Notifier<int> {
  static const String _prefKey = 'eskolia_home_selected_module_idx';

  @override
  int build() {
    _load();
    return 0;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(_prefKey);
    if (idx != null) {
      state = idx;
    }
  }

  Future<void> setIndex(int index) async {
    state = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, index);
  }
}

final homeSelectedModuleIndexProvider = NotifierProvider<HomeSelectedModuleIndexNotifier, int>(HomeSelectedModuleIndexNotifier.new);

class HomeLastClickedChapterNotifier extends Notifier<String?> {
  static const String _prefKey = 'eskolia_home_last_clicked_chapter';

  @override
  String? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_prefKey);
  }

  Future<void> setChapterId(String chapterId) async {
    state = chapterId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, chapterId);
  }
}

final homeLastClickedChapterProvider = NotifierProvider<HomeLastClickedChapterNotifier, String?>(HomeLastClickedChapterNotifier.new);


class ParcoursCardsOrderNotifier extends Notifier<List<String>> {
  static const String _prefKey = 'eskolia_parcours_cards_order_v2';
  static const List<String> _defaultOrder = ['formation', 'podcasts', 'examen_blanc', 'lexique', 'mediatheque'];

  @override
  List<String> build() {
    _load();
    return _defaultOrder;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final oldList = prefs.getStringList('eskolia_parcours_card_order');
    final newList = prefs.getStringList(_prefKey);
    final list = newList ?? oldList;
    if (list != null) {
      final filtered = list.where((x) => x != 'docs').toList();
      for (final key in _defaultOrder) {
        if (!filtered.contains(key)) {
          filtered.add(key);
        }
      }
      if (filtered.isNotEmpty) {
        state = filtered;
      }
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

final parcoursCardsOrderProvider = NotifierProvider<ParcoursCardsOrderNotifier, List<String>>(ParcoursCardsOrderNotifier.new);

class ParcoursPinnedCardsNotifier extends Notifier<List<String>> {
  static const String _prefKey = 'eskolia_parcours_pinned_cards';

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

final parcoursPinnedCardsProvider = NotifierProvider<ParcoursPinnedCardsNotifier, List<String>>(ParcoursPinnedCardsNotifier.new);

final allPodcastsProvider = FutureProvider<List<Podcast>>((ref) {
  return PodcastCatalog.load();
});

