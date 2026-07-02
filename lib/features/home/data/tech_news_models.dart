class TechFeedConfig {
  const TechFeedConfig({
    required this.id,
    required this.label,
    required this.rssUrl,
    required this.category,
  });

  final String id;
  final String label;
  final String rssUrl;
  final String category;

  factory TechFeedConfig.fromJson(Map<String, dynamic> json) {
    return TechFeedConfig(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? json['id'] as String? ?? 'Flux',
      rssUrl: json['rssUrl'] as String? ?? '',
      category: json['category'] as String? ?? 'it_pro',
    );
  }
}

class TechNewsItem {
  const TechNewsItem({
    required this.title,
    required this.link,
    required this.sourceLabel,
    required this.category,
    this.pubDate,
    this.publishedAt,
  });

  final String title;
  final String link;
  final String sourceLabel;
  final String category;
  final String? pubDate;

  /// Date de publication interprétée pour le tri (UTC si possible).
  final DateTime? publishedAt;
}

