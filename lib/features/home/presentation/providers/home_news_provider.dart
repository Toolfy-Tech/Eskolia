import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/eskolia_tokens.dart';

class AppNewsItem {
  const AppNewsItem({
    required this.id,
    required this.emoji,
    required this.badge,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.targetRoute,
    required this.accentColor,
    this.date = '17 Août',
  });

  final String id;
  final String emoji;
  final String badge;
  final String title;
  final String description;
  final String actionLabel;
  final String targetRoute;
  final Color accentColor;
  final String date;
}

/// Liste des nouveautés récentes de l'application
const List<AppNewsItem> kAppNewsFeed = [
  AppNewsItem(
    id: 'news_tp_osi_2026_08',
    emoji: '🌐',
    badge: 'NOUVEAU TP',
    title: 'Ateliers Modèle OSI (3 Modes Interactifs)',
    description: 'Entraînez-vous sur les 7 couches avec Le Tri Sélectif, Le Voyage du Paquet (encapsulation 1 par 1) et L\'Enquêteur OSI (diagnostic de pannes IT réelles).',
    actionLabel: 'Lancer l\'atelier OSI ➔',
    targetRoute: '/tp/osi',
    accentColor: EskoliaTokens.cyan,
  ),
  AppNewsItem(
    id: 'news_memento_osi_2026_08',
    emoji: '📖',
    badge: 'MÉMENTO CONCRET',
    title: 'Mémento Réseau & Commandes IT',
    description: 'Analogies vivantes (la lettre, le traducteur, le transporteur, l\'adresse IP, la MAC) et fiches d\'outils CLI (ping, tracert, nslookup, netstat, wireshark). Accessible partout en 1 clic !',
    actionLabel: 'Consulter le Mémento ➔',
    targetRoute: '/tp/osi',
    accentColor: Color(0xFFA855F7),
  ),
  AppNewsItem(
    id: 'news_lobbies_sync_2026_08',
    emoji: '⚔️',
    badge: 'MULTIJOUEUR',
    title: 'Salons Multijoueurs & Combats Réseau',
    description: 'Permissions Firestore optimisées pour rejoindre et créer des salons de quiz sans accroc en temps réel avec vos pairs.',
    actionLabel: 'Rejoindre un salon ➔',
    targetRoute: '/lobbys',
    accentColor: Color(0xFFFFB300),
  ),
];

class DismissedNewsNotifier extends StateNotifier<Set<String>> {
  DismissedNewsNotifier() : super(<String>{}) {
    _loadFromPrefs();
  }

  static const String _prefKey = 'eskolia_dismissed_news_ids_v1';

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefKey) ?? <String>[];
      state = list.toSet();
    } catch (_) {}
  }

  Future<void> dismissNews(String newsId) async {
    final updated = Set<String>.from(state)..add(newsId);
    state = updated;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKey, updated.toList());
    } catch (_) {}
  }

  Future<void> restoreAllNews() async {
    state = <String>{};
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKey);
    } catch (_) {}
  }
}

final dismissedNewsProvider = StateNotifierProvider<DismissedNewsNotifier, Set<String>>((ref) {
  return DismissedNewsNotifier();
});

final activeAppNewsProvider = Provider<List<AppNewsItem>>((ref) {
  final dismissed = ref.watch(dismissedNewsProvider);
  return kAppNewsFeed.where((news) => !dismissed.contains(news.id)).toList();
});
