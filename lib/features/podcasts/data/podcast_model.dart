import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class Podcast {
  const Podcast({
    required this.id,
    required this.title,
    required this.url,
    this.subtitle,
  });

  final String id;
  final String title;
  final String url;
  final String? subtitle;
}

/// Charge le manifeste des podcasts (titres + URLs des releases GitHub).
/// Les fichiers .m4a vivent hors du depot (releases), seul ce manifeste leger
/// est bundle dans l'app.
abstract final class PodcastCatalog {
  PodcastCatalog._();

  static const String assetPath = 'assets/audio/podcasts.json';

  static Future<List<Podcast>> load() async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return const [];
    final items = decoded['podcasts'];
    if (items is! List) return const [];

    final out = <Podcast>[];
    for (final item in items) {
      if (item is! Map) continue;
      final id = item['id'];
      final title = item['title'];
      final url = item['url'];
      if (id is! String || title is! String || url is! String) continue;
      if (url.isEmpty) continue;
      final subtitle = item['subtitle'];
      out.add(
        Podcast(
          id: id,
          title: title,
          url: url,
          subtitle: subtitle is String && subtitle.isNotEmpty ? subtitle : null,
        ),
      );
    }
    return out;
  }
}
