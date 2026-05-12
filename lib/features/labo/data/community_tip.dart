import 'package:cloud_firestore/cloud_firestore.dart';

import 'labo_tip_kind.dart';

class CommunityTip {
  const CommunityTip({
    required this.id,
    required this.authorId,
    required this.moduleId,
    required this.moduleTitle,
    required this.kind,
    required this.body,
    required this.status,
    this.createdAt,
    this.upCount = 0,
    this.downCount = 0,
    this.voterVotes = const {},
  });

  final String id;
  final String authorId;
  final String moduleId;
  final String moduleTitle;
  final LaboTipKind kind;
  final String body;
  final String status;
  final DateTime? createdAt;
  final int upCount;
  final int downCount;
  /// `userId` → `1` (utile) ou `-1` (pas utile).
  final Map<String, int> voterVotes;

  int get score => upCount - downCount;

  /// Vote du lecteur connecté : `1`, `-1`, ou `null`.
  int? voteOf(String? uid) {
    if (uid == null || uid.isEmpty) return null;
    return voterVotes[uid];
  }

  factory CommunityTip.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final vm = data['voters'];
    final voterVotes = <String, int>{};
    if (vm is Map) {
      for (final e in vm.entries) {
        final v = e.value;
        if (v is num) {
          final i = v.toInt();
          if (i == 1 || i == -1) voterVotes[e.key.toString()] = i;
        }
      }
    }
    return CommunityTip(
      id: doc.id,
      authorId: data['authorId'] as String? ?? '',
      moduleId: data['moduleId'] as String? ?? '',
      moduleTitle: data['moduleTitle'] as String? ?? '',
      kind: LaboTipKind.fromFirestore(data['kind'] as String?),
      body: data['body'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      upCount: (data['upCount'] as num?)?.toInt() ?? 0,
      downCount: (data['downCount'] as num?)?.toInt() ?? 0,
      voterVotes: voterVotes,
    );
  }
}
