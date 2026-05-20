import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ai_provider.dart';

const String _kOllamaUrl   = 'ollama_url';
const String _kOllamaModel = 'ollama_model';

class AiConnectionState {
  const AiConnectionState({
    required this.isConnected,
    this.apiKey,
    this.provider = AiProvider.unknown,
  });

  final bool isConnected;
  final String? apiKey;
  final AiProvider provider;
}

/// Stocke la cle API dans users/{uid}/settings/ai_key (sous-collection protegee isSelf).
/// Le document users/{uid} ne conserve que aiProvider (indicateur public, sans valeur sensible).
class AiKeyRepository {
  AiKeyRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid);
  }

  DocumentReference<Map<String, dynamic>>? get _keyDoc {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('settings').doc('ai_key');
  }

  Future<AiConnectionState> load() async {
    final keyRef = _keyDoc;
    if (keyRef == null) return const AiConnectionState(isConnected: false);

    // Lecture depuis la sous-collection protegee.
    final snap = await keyRef.get();
    if (snap.exists) {
      final key = snap.data()?['apiKey'] as String?;
      if (key != null && key.isNotEmpty) {
        final provider = AiProvider.detectFromKey(key);
        return AiConnectionState(isConnected: true, apiKey: key, provider: provider);
      }
    }

    // Migration : ancienne cle stockee directement sur le document utilisateur.
    final userSnap = await _userDoc?.get();
    final legacyKey = userSnap?.data()?['aiApiKey'] as String?;
    if (legacyKey != null && legacyKey.isNotEmpty) {
      await save(legacyKey);
      return AiConnectionState(
        isConnected: true,
        apiKey: legacyKey,
        provider: AiProvider.detectFromKey(legacyKey),
      );
    }

    return const AiConnectionState(isConnected: false);
  }

  Future<void> save(String key) async {
    final keyRef = _keyDoc;
    final userRef = _userDoc;
    if (keyRef == null || userRef == null) return;
    final provider = AiProvider.detectFromKey(key);

    // Cle dans la sous-collection — lisible uniquement par le proprietaire.
    await keyRef.set({'apiKey': key.trim()}, SetOptions(merge: true));

    // Indicateur public : uniquement le nom du provider, sans la cle.
    await userRef.update({
      'aiProvider': provider.name,
      // Suppression de l'ancienne cle en clair si elle existait.
      'aiApiKey': FieldValue.delete(),
    });
  }

  Future<void> delete() async {
    final keyRef = _keyDoc;
    final userRef = _userDoc;
    if (keyRef == null || userRef == null) return;
    await keyRef.delete();
    await userRef.update({'aiProvider': FieldValue.delete()});
  }

  // ── Ollama (provider local, sans cle API) ─────────────────────────────────

  /// Enregistre les parametres Ollama et ecrit le sentinel dans Firestore.
  Future<void> saveOllama({
    String url   = 'http://localhost:11434',
    String model = 'gemma3',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kOllamaUrl, url);
    await prefs.setString(_kOllamaModel, model);

    // Sentinel dans la sous-collection : indique Ollama sans exposer de cle.
    final keyRef  = _keyDoc;
    final userRef = _userDoc;
    if (keyRef == null || userRef == null) return;
    await keyRef.set({'apiKey': 'ollama'}, SetOptions(merge: true));
    await userRef.update({'aiProvider': 'ollama', 'aiApiKey': FieldValue.delete()});
  }

  /// Lit les parametres Ollama depuis SharedPreferences.
  Future<({String url, String model})> loadOllamaSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      url:   prefs.getString(_kOllamaUrl)   ?? 'http://localhost:11434',
      model: prefs.getString(_kOllamaModel) ?? 'gemma3',
    );
  }

  /// Supprime les parametres Ollama (SharedPreferences + Firestore).
  Future<void> deleteOllama() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kOllamaUrl);
    await prefs.remove(_kOllamaModel);
    await delete();
  }

  Stream<AiConnectionState> watch() {
    final keyRef = _keyDoc;
    if (keyRef == null) return Stream.value(const AiConnectionState(isConnected: false));
    return keyRef.snapshots().map((snap) {
      final key = snap.data()?['apiKey'] as String?;
      if (key == null || key.isEmpty) return const AiConnectionState(isConnected: false);
      final provider = AiProvider.detectFromKey(key);
      return AiConnectionState(isConnected: true, apiKey: key, provider: provider);
    });
  }
}
