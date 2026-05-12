import 'package:flutter/services.dart';

/// Service de mise en cache pour les assets (JSON, Markdown, etc.)
/// Évite les accès répétitifs au [rootBundle] qui peuvent causer des micro-lags.
class AssetCacheService {
  AssetCacheService._();

  static final Map<String, String> _stringCache = {};
  static final Map<String, ByteData> _byteCache = {};

  /// Charge et cache une chaîne de caractères depuis les assets.
  static Future<String> loadString(String assetPath) async {
    if (_stringCache.containsKey(assetPath)) {
      return _stringCache[assetPath]!;
    }
    final content = await rootBundle.loadString(assetPath);
    _stringCache[assetPath] = content;
    return content;
  }

  /// Pré-charge une liste d'assets en mémoire.
  static Future<void> prefetchStrings(List<String> assetPaths) async {
    await Future.wait(assetPaths.map((path) => loadString(path)));
  }

  /// Vide le cache pour libérer de la mémoire.
  static void clearCache() {
    _stringCache.clear();
    _byteCache.clear();
  }
}
