import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http_parser/http_parser.dart' show parseHttpDate;

import 'tech_news_models.dart';

/// Charge des titres depuis des flux RSS listés dans [assetPath] (ex. veille
/// pro Windows / infra via IT-Connect, configurable).
///
/// Sur **toutes** les plateformes, les requêtes passent par l’API publique
/// [rss2json](https://rss2json.com/) pour éviter le **CORS** du web et
/// homogénéiser le parsing JSON. En production à fort trafic, prévoir une
/// clé API rss2json ou un relais (Cloud Function) si les limites gratuites
/// posent problème.
class TechNewsRepository {
  TechNewsRepository({Dio? dio, this.assetPath = 'data/home/tech_feeds.json'})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 20),
                responseType: ResponseType.json,
                validateStatus: (code) => code != null && code < 500,
              ),
            );

  final Dio _dio;
  final String assetPath;

  static const String _rss2JsonBase =
      'https://api.rss2json.com/v1/api.json?rss_url=';

  /// Sur le web, [rootBundle] peut réutiliser une réponse HTTP cachée pour
  /// l’asset ; on refetch via Dio + query `cb` pour toujours lire le JSON à jour.
  Future<String> _loadFeedsConfigRaw() async {
    if (kIsWeb) {
      final base = Uri.base.replace(fragment: '', query: '');
      final assetUri = base.resolve('assets/$assetPath');
      final busted = assetUri.replace(
        queryParameters: {
          ...assetUri.queryParameters,
          'cb': '${DateTime.now().microsecondsSinceEpoch}',
        },
      );
      final res = await _dio.get<String>(
        busted.toString(),
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (c) => c == 200,
          headers: const {'Cache-Control': 'no-cache'},
        ),
      );
      final body = res.data;
      if (body == null || body.isEmpty) {
        throw StateError('Config flux vide (HTTP ${res.statusCode})');
      }
      return body;
    }
    return rootBundle.loadString(assetPath);
  }

  Future<List<TechNewsItem>> loadNews({
    String? sourceFilter,
    List<String> subscribedSources = const [],
  }) async {
    if (sourceFilter != null && sourceFilter.startsWith('custom:')) {
      try {
        final jsonStr = sourceFilter.substring(7);
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        final feed = TechFeedConfig(
          id: sourceFilter,
          label: map['label'] as String? ?? 'Flux perso',
          rssUrl: map['rssUrl'] as String? ?? '',
          category: map['category'] as String? ?? 'it_pro',
        );
        if (feed.rssUrl.isNotEmpty) {
          return _fetchFeedItems(feed, 12);
        }
      } catch (_) {}
      return const [];
    }

    final raw = await _loadFeedsConfigRaw();
    final root = jsonDecode(raw) as Map<String, dynamic>;
    final feedsJson = root['feeds'] as List<dynamic>? ?? const [];
    
    final customFeeds = <TechFeedConfig>[];
    for (final sub in subscribedSources) {
      if (sub.startsWith('custom:')) {
        try {
          final jsonStr = sub.substring(7);
          final map = jsonDecode(jsonStr) as Map<String, dynamic>;
          customFeeds.add(TechFeedConfig(
            id: sub,
            label: map['label'] as String? ?? 'Flux perso',
            rssUrl: map['rssUrl'] as String? ?? '',
            category: map['category'] as String? ?? 'it_pro',
          ));
        } catch (_) {}
      }
    }

    final feeds = [
      ...feedsJson.map((e) => TechFeedConfig.fromJson(e as Map<String, dynamic>)),
      ...customFeeds,
    ].where((f) => f.rssUrl.isNotEmpty).toList();

    if (feeds.isEmpty) return const [];

    if (sourceFilter != null) {
      final targetFeed = feeds.firstWhere(
        (f) => f.label.toLowerCase() == sourceFilter.toLowerCase(),
        orElse: () => feeds.firstWhere(
          (f) => f.id.toLowerCase() == sourceFilter.toLowerCase(),
          orElse: () => const TechFeedConfig(id: '', label: '', rssUrl: '', category: ''),
        ),
      );
      if (targetFeed.rssUrl.isEmpty) return const [];
      // Permettre jusqu'à 12 articles pour une carte dédiée à une source
      return _fetchFeedItems(targetFeed, 12);
    }

    final maxPer =
        (root['maxItemsPerFeed'] as num?)?.toInt().clamp(1, 20) ?? 5;
    final maxShown =
        (root['maxItemsShown'] as num?)?.toInt().clamp(1, 30) ?? 8;

    final perFeed = <String, List<TechNewsItem>>{};
    for (var i = 0; i < feeds.length; i++) {
      final feed = feeds[i];
      try {
        final items = await _fetchFeedItems(feed, maxPer);
        perFeed[feed.id] = items;
      } catch (e, st) {
        debugPrint('TechNewsRepository: flux ${feed.id} ignoré: $e\n$st');
      }
      // Évite les 429 / throttling rss2json quand plusieurs flux sont listés.
      if (i < feeds.length - 1) {
        await Future<void>.delayed(const Duration(milliseconds: 220));
      }
    }

    if (perFeed.isEmpty) return const [];

    return _mergeNewestFirst(perFeed, maxShown);
  }

  Future<List<TechNewsItem>> _fetchFeedItems(
    TechFeedConfig feed,
    int maxPer,
  ) async {
    final encoded = Uri.encodeComponent(feed.rssUrl);
    final uri = '$_rss2JsonBase$encoded';
    final response = await _dio.get<Map<String, dynamic>>(uri);
    final data = response.data;
    if (data == null || data['status'] != 'ok') {
      final msg = data?['message'] as String?;
      throw StateError(
        'rss2json ${feed.id}: ${msg ?? data?.toString() ?? "réponse nulle"}',
      );
    }
    final items = data['items'] as List<dynamic>? ?? const [];
    final out = <TechNewsItem>[];
    for (final raw in items) {
      if (raw is! Map<String, dynamic>) continue;
      final title = (raw['title'] as String?)?.trim() ?? '';
      final link = _linkFromItem(raw);
      if (title.isEmpty || link.isEmpty) continue;
      final pub = (raw['pubDate'] as String?)?.trim();
      out.add(
        TechNewsItem(
          title: title,
          link: link,
          sourceLabel: feed.label,
          category: feed.category,
          pubDate: pub,
          publishedAt: _parseArticleDate(pub),
        ),
      );
      if (out.length >= maxPer) break;
    }
    return out;
  }

  String _linkFromItem(Map<String, dynamic> item) {
    final link = item['link'];
    if (link is String && link.isNotEmpty) return link;
    final guid = item['guid'];
    if (guid is String && guid.startsWith('http')) return guid;
    return '';
  }

  /// Fusionne tous les flux et trie du **plus récent** au plus ancien.
  List<TechNewsItem> _mergeNewestFirst(
    Map<String, List<TechNewsItem>> perFeed,
    int maxShown,
  ) {
    final all = <TechNewsItem>[];
    for (final list in perFeed.values) {
      all.addAll(list);
    }
    all.sort((a, b) {
      final ta = a.publishedAt;
      final tb = b.publishedAt;
      if (ta == null && tb == null) {
        return a.title.compareTo(b.title);
      }
      if (ta == null) return 1;
      if (tb == null) return -1;
      final c = tb.compareTo(ta);
      if (c != 0) return c;
      return a.title.compareTo(b.title);
    });
    if (all.length <= maxShown) return all;
    return all.sublist(0, maxShown);
  }

  /// rss2json : souvent `yyyy-MM-dd HH:mm:ss` ; sinon RFC 822 / HTTP date.
  static DateTime? _parseArticleDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final s = raw.trim();
    if (s.length >= 19 && s[4] == '-' && s[7] == '-' && s[10] == ' ') {
      final iso = '${s.substring(0, 10)}T${s.substring(11)}';
      final d = DateTime.tryParse(iso);
      if (d != null) return d.toUtc();
    }
    final direct = DateTime.tryParse(s);
    if (direct != null) return direct.toUtc();
    try {
      return parseHttpDate(s).toUtc();
    } catch (_) {
      return null;
    }
  }
}
