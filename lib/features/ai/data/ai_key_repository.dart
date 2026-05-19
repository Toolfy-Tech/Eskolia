import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ai_provider.dart';

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

/// Stocke la clé API dans le document Firestore de l'utilisateur.
/// Champs : aiApiKey (String) + aiProvider (String).
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

  Future<AiConnectionState> load() async {
    final doc = _userDoc;
    if (doc == null) return const AiConnectionState(isConnected: false);
    final snap = await doc.get();
    final data = snap.data() ?? {};
    final key = data['aiApiKey'] as String?;
    if (key == null || key.isEmpty) return const AiConnectionState(isConnected: false);
    final provider = AiProvider.detectFromKey(key);
    return AiConnectionState(isConnected: true, apiKey: key, provider: provider);
  }

  Future<void> save(String key) async {
    final doc = _userDoc;
    if (doc == null) return;
    final provider = AiProvider.detectFromKey(key);
    await doc.update({
      'aiApiKey': key.trim(),
      'aiProvider': provider.name,
    });
  }

  Future<void> delete() async {
    final doc = _userDoc;
    if (doc == null) return;
    await doc.update({
      'aiApiKey': FieldValue.delete(),
      'aiProvider': FieldValue.delete(),
    });
  }

  Stream<AiConnectionState> watch() {
    final doc = _userDoc;
    if (doc == null) return Stream.value(const AiConnectionState(isConnected: false));
    return doc.snapshots().map((snap) {
      final data = snap.data() ?? {};
      final key = data['aiApiKey'] as String?;
      if (key == null || key.isEmpty) return const AiConnectionState(isConnected: false);
      final provider = AiProvider.detectFromKey(key);
      return AiConnectionState(isConnected: true, apiKey: key, provider: provider);
    });
  }
}
