import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/quiz/models/battle_session_model.dart';
import '../../features/quiz/models/quiz_models.dart';
import 'user_repository.dart';

class BattleRepository {
  BattleRepository({
    FirebaseFirestore? db,
    UserRepository? userRepository,
  })  : _db = db ?? FirebaseFirestore.instance,
        _userRepository = userRepository ?? UserRepository();

  final FirebaseFirestore _db;
  final UserRepository _userRepository;

  Future<BattleSessionModel> createLobby(
    String player1Id,
    String player1Name,
    String moduleId,
    List<QuizQuestion> questions,
  ) async {
    final ref = _db.collection('battles').doc();
    final id = ref.id;
    final battle = BattleSessionModel(
      id: id,
      player1Id: player1Id,
      player2Id: '',
      player1Name: player1Name,
      player2Name: '',
      player1Score: 0,
      player2Score: 0,
      questions: questions,
      currentQuestionIndex: 0,
      status: 'waiting',
      winnerId: null,
      createdAt: DateTime.now(),
      moduleId: moduleId,
    );
    await ref.set(battle.toFirestore());
    return battle;
  }

  Future<BattleSessionModel?> joinLobby(
    String battleId,
    String player2Id,
    String player2Name,
  ) async {
    final ref = _db.collection('battles').doc(battleId);
    return _db.runTransaction<BattleSessionModel?>((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists || snap.data() == null) return null;
      final b = BattleSessionModel.fromFirestore(snap);
      if (b.status != 'waiting' || b.player2Id.isNotEmpty) return null;
      final updated = b.copyWith(
        player2Id: player2Id,
        player2Name: player2Name,
        status: 'playing',
      );
      tx.set(ref, updated.toFirestore());
      return updated;
    });
  }

  Stream<BattleSessionModel?> watchBattle(String battleId) {
    return _db.collection('battles').doc(battleId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return BattleSessionModel.fromFirestore(doc);
    });
  }

  Future<void> submitBattleAnswer(
    String battleId,
    String playerId,
    int score,
  ) async {
    final ref = _db.collection('battles').doc(battleId);
    final doc = await ref.get();
    if (!doc.exists || doc.data() == null) return;
    final b = BattleSessionModel.fromFirestore(doc);
    if (playerId == b.player1Id) {
      await ref.update({'player1Score': FieldValue.increment(score)});
    } else if (playerId == b.player2Id) {
      await ref.update({'player2Score': FieldValue.increment(score)});
    }
  }

  Future<void> finishBattle(String battleId) async {
    final ref = _db.collection('battles').doc(battleId);
    final doc = await ref.get();
    if (!doc.exists || doc.data() == null) return;
    final battle = BattleSessionModel.fromFirestore(doc);

    String? winnerId;
    if (battle.player1Score > battle.player2Score) {
      winnerId = battle.player1Id;
    } else if (battle.player2Score > battle.player2Score) {
      winnerId = battle.player2Id;
    }

    await ref.update({
      'status': 'finished',
      'winnerId': winnerId,
    });

    if (winnerId != null) {
      final loserId = winnerId == battle.player1Id
          ? battle.player2Id
          : battle.player1Id;
      if (loserId.isNotEmpty) {
        await _userRepository.incrementBattleWins(winnerId);
        await _userRepository.addXp(winnerId, 200);
        await _userRepository.addXp(loserId, 100);
      }
    } else {
      await _userRepository.addXp(battle.player1Id, 100);
      if (battle.player2Id.isNotEmpty) {
        await _userRepository.addXp(battle.player2Id, 100);
      }
    }
  }

  Stream<List<BattleSessionModel>> watchOpenLobbies() {
    return _db
        .collection('battles')
        .where('status', isEqualTo: 'waiting')
        .snapshots()
        .map((snap) => snap.docs.map(BattleSessionModel.fromFirestore).toList());
  }
}
