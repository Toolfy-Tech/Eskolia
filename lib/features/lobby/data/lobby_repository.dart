import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../core/services/asset_cache_service.dart';

import '../../quiz/services/quiz_repository.dart';

/// Capacité max des lobbies (MVP).
const int kLobbyMaxPlayers = 30;

/// Nombre de questions (mode Quiz multi) : bornes côté client + tirage.
const int kLobbyMinQuestionCount = 5;
const int kLobbyMaxQuestionCount = 50;

/// Multijoueur « classique » : Maîtrise avec correction collective.
const String kLobbyGameModeQuiz = 'mastery';

/// Multijoueur survival : 3 vies par joueur, erreur = −1 vie, 0 vie = éliminé.
const String kLobbyGameModeSurvival = 'survival';

class LobbyModel {
  const LobbyModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.hostName,
    required this.hostAvatar,
    required this.currentPlayers,
    required this.maxPlayers,
    required this.status,
    required this.difficulty,
    required this.quizId,
    required this.createdAt,
    this.hostId = '',
    this.playerMeta = const [],
    this.questionAssetPaths = const [],
    this.joinCode = '',
    this.isPrivate = false,
    this.gameMode = kLobbyGameModeQuiz,
    this.timed = true,
    this.questionCount = 10,
    this.difficultyFilters = const ['facile', 'moyen', 'difficile'],
    this.customQuestionsJson = '',
  });

  final String id;
  final String title;
  final String subject;
  final String hostName;
  final String hostAvatar;
  final int currentPlayers;
  final int maxPlayers;
  final String status;
  final String difficulty;
  final String quizId;
  final DateTime createdAt;
  final String hostId;
  final List<PlayerMeta> playerMeta;
  final List<String> questionAssetPaths;
  final String joinCode;
  final bool isPrivate;
  final String gameMode;
  final bool timed;
  final int questionCount;
  final List<String> difficultyFilters;
  /// Questions personnalisées sérialisées en JSON (non vide quand quizId == 'custom').
  final String customQuestionsJson;

  bool get isFull => currentPlayers >= maxPlayers;
  bool get isSurvival => gameMode == kLobbyGameModeSurvival;

  String get gameModeLabelShort => isSurvival ? 'Arena' : 'Mastery';
  String get gameModeLabelDetail => isSurvival ? 'Arena (Survival)' : 'Maîtrise (Quiz multi)';
}

class PlayerMeta {
  const PlayerMeta({
    required this.userId,
    required this.displayName,
    required this.avatar,
  });

  final String userId;
  final String displayName;
  final String avatar;

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'displayName': displayName,
    'avatar': avatar,
  };
}

class BattleQuestion {
  const BattleQuestion({
    required this.id,
    required this.question,
    required this.answer,
    this.type = 'classic',
    this.contextLine,
    this.difficultyBucket = 'unknown',
    this.sourceAssetPath,
    this.indices,
    this.checklist,
    this.options,
    this.answerSequence,
    this.categoryGroup = QuestionCategoryGroup.officialParcours,
    this.authorName = 'Eskolia Team',
  });

  final String id;
  final String question;
  final String answer;
  final String type;
  final String? contextLine;
  final String difficultyBucket;
  final String? sourceAssetPath;
  final List<String>? indices;
  final List<String>? checklist;
  final List<String>? options;
  /// Ordre correct des étapes — uniquement pour type == 'sequence'.
  final List<String>? answerSequence;
  final QuestionCategoryGroup categoryGroup;
  final String authorName;

  Map<String, dynamic> toMap() => {
    'id': id,
    'question': question,
    'answer': answer,
    'type': type,
    'contextLine': contextLine,
    'difficultyBucket': difficultyBucket,
    'sourceAssetPath': sourceAssetPath,
    'indices': indices,
    'checklist': checklist,
    'options': options,
    'answerSequence': answerSequence,
    'categoryGroup': categoryGroup.index,
    'authorName': authorName,
  };

  QuizQuestion toQuizQuestion() => QuizQuestion(
    id: id,
    question: question,
    answer: answer,
    type: type,
    contextLine: contextLine,
    difficultyBucket: difficultyBucket,
    sourceAssetPath: sourceAssetPath,
    indices: indices,
    checklist: checklist,
    options: options,
    answerSequence: answerSequence,
    categoryGroup: categoryGroup,
    authorName: authorName,
  );
}

class BattleState {
  const BattleState({
    required this.lobbyId,
    required this.players,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.phase,
    this.questions = const [],
    this.lastRoundPoints = const {},
    this.timed = false,
    this.gameMode = kLobbyGameModeQuiz,
    this.secondsPerQuestion = 20,
    this.revealedIndices = 0,
    this.allAnswers = const [],
    this.allJudgments = const [],
  });

  final String lobbyId;
  final List<PlayerState> players;
  final int currentQuestion;
  final int totalQuestions;
  /// Phases : countdown, question, final_judgment, finished.
  final String phase;
  final List<BattleQuestion> questions;
  final Map<String, double> lastRoundPoints;
  final bool timed;
  final String gameMode;
  final int secondsPerQuestion;
  final int revealedIndices;
  /// Réponses de tous les joueurs par question : allAnswers[questionIdx][userId] = texte.
  final List<Map<String, String>> allAnswers;
  /// Jugements finaux par question : allJudgments[questionIdx][userId] = true/false/null.
  final List<Map<String, bool?>> allJudgments;

  bool get isSurvival => gameMode == kLobbyGameModeSurvival;
}

class PlayerState {
  const PlayerState({
    required this.userId,
    required this.displayName,
    required this.avatar,
    required this.score,
    required this.hasAnswered,
    required this.isConnected,
    this.lastAnswerText,
    this.lives = 0,
    this.eliminated = false,
    this.lastJudgment, // null = en attente, true = validé, false = refusé
    this.lastScore = 0.0,
  });

  final String userId;
  final String displayName;
  final String avatar;
  final double score;
  final bool hasAnswered;
  final bool isConnected;
  final String? lastAnswerText;
  final int lives;
  final bool eliminated;
  final bool? lastJudgment;
  final double lastScore;
}

class LobbyRepository {
  LobbyRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<List<LobbyModel>> watchLobbies() {
    return _db.collection('lobbies').snapshots().map((snap) {
      return snap.docs
          .map(_lobbyFromDoc)
          .where((l) => !l.isPrivate && l.status != 'finished')
          .toList();
    });
  }

  Stream<LobbyModel?> watchLobby(String lobbyId) {
    return _db.collection('lobbies').doc(lobbyId).snapshots().map((d) {
      if (!d.exists) return null;
      return _lobbyFromDoc(d);
    });
  }

  LobbyModel _lobbyFromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data() ?? {};
    final rawMeta = data['playerMeta'] as List? ?? [];
    final playerMeta = rawMeta.map((p) {
      final map = Map<String, dynamic>.from(p as Map);
      return PlayerMeta(
        userId: map['userId'] as String? ?? '',
        displayName: map['displayName'] as String? ?? '',
        avatar: map['avatar'] as String? ?? '\u{1F464}',
      );
    }).toList();
    return LobbyModel(
      id: d.id,
      title: data['title'] ?? '',
      subject: data['subject'] ?? 'tip',
      hostName: data['hostName'] ?? '',
      hostAvatar: data['hostAvatar'] ?? '\u{1F464}',
      currentPlayers: (data['currentPlayers'] as num?)?.toInt() ?? 0,
      maxPlayers: (data['maxPlayers'] as num?)?.toInt() ?? kLobbyMaxPlayers,
      status: data['status'] ?? 'waiting',
      difficulty: data['difficulty'] ?? 'moyen',
      quizId: data['quizId'] ?? 'tip',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hostId: data['hostId'] ?? '',
      gameMode: data['gameMode'] ?? kLobbyGameModeQuiz,
      questionCount: (data['questionCount'] as num?)?.toInt() ?? 10,
      joinCode: data['joinCode'] ?? '',
      isPrivate: data['isPrivate'] ?? false,
      questionAssetPaths: List<String>.from(data['questionAssetPaths'] ?? []),
      difficultyFilters: List<String>.from(data['difficultyFilters'] ?? []),
      customQuestionsJson: data['customQuestionsJson'] as String? ?? '',
      playerMeta: playerMeta,
    );
  }

  Future<String> createLobby(LobbyModel l) async {
    final code = _generateJoinCode();
    final doc = await _db.collection('lobbies').add({
      'title': l.title,
      'subject': l.subject,
      'hostName': l.hostName,
      'hostAvatar': l.hostAvatar,
      'currentPlayers': 1,
      'maxPlayers': l.maxPlayers,
      'status': 'waiting',
      'difficulty': l.difficulty,
      'quizId': l.quizId,
      'createdAt': FieldValue.serverTimestamp(),
      'hostId': l.hostId,
      'playerIds': [l.hostId],
      'playerMeta': l.playerMeta.map((p) => p.toMap()).toList(),
      'questionAssetPaths': l.questionAssetPaths,
      if (l.customQuestionsJson.isNotEmpty) 'customQuestionsJson': l.customQuestionsJson,
      'joinCode': code,
      'isPrivate': l.isPrivate,
      'gameMode': l.gameMode,
      'timed': l.timed,
      'questionCount': l.questionCount,
      'difficultyFilters': l.difficultyFilters,
    });
    return doc.id;
  }

  Future<void> joinLobby(String lobbyId, String userId) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    final name = u.displayName ?? u.email?.split('@').first ?? 'Joueur';
    final avatar = '\u{1F464}';

    final ref = _db.collection('lobbies').doc(lobbyId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data = snap.data()!;
      final ids = List<String>.from(data['playerIds'] ?? []);
      if (ids.contains(userId)) return;

      final meta = List<Map<String, dynamic>>.from(data['playerMeta'] ?? []);
      meta.add(PlayerMeta(userId: userId, displayName: name, avatar: avatar).toMap());

      tx.update(ref, {
        'playerIds': FieldValue.arrayUnion([userId]),
        'currentPlayers': FieldValue.increment(1),
        'playerMeta': meta,
      });
    });
  }

  Future<String?> findLobbyIdByJoinCode(String code) async {
    final q = await _db
        .collection('lobbies')
        .where('joinCode', isEqualTo: code.toUpperCase())
        .where('status', isNotEqualTo: 'finished')
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return q.docs.first.id;
  }

  /// Supprime les lobbies en attente créés il y a plus de 15 minutes.
  /// Appelé silencieusement à l'ouverture de la liste des lobbies.
  Future<void> cleanupStaleLobbies() async {
    final cutoff = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(minutes: 15)),
    );
    final snap = await _db
        .collection('lobbies')
        .where('status', isEqualTo: 'waiting')
        .where('createdAt', isLessThan: cutoff)
        .get();
    if (snap.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> deleteLobby(String lobbyId) async {
    await _db.collection('lobbies').doc(lobbyId).delete();
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  Future<void> startBattleCountdown(String lobbyId, LobbyModel lobby) async {
    final questions = await _pickBattleQuestions(lobby);
    if (questions.isEmpty) {
      throw Exception(
        'Aucune question trouvée pour cette sélection. '
        'Vérifie les chapitres et filtres de difficulté choisis.',
      );
    }
    final players = lobby.playerMeta.map((p) => _playerToInitialState(p, lobby)).toList();

    await _db.collection('lobbies').doc(lobbyId).update({
      'status': 'in_progress',
      'battle': {
        'phase': 'countdown',
        'currentQuestion': 0,
        'totalQuestions': questions.length,
        'questions': questions.map((q) => q.toMap()).toList(),
        'players': players.map((p) => _playerToMap(p)).toList(),
        'timed': false,
        'gameMode': lobby.gameMode,
        'revealedIndices': 0,
        'allAnswers': [],
        'allJudgments': [],
      },
    });

    // Petit délai pour laisser le countdown s'afficher
    Future.delayed(const Duration(seconds: 4), () {
      _db.collection('lobbies').doc(lobbyId).update({'battle.phase': 'question'});
    });
  }

  Future<List<BattleQuestion>> _pickBattleQuestions(LobbyModel l) async {
    final all = <BattleQuestion>[];

    // Quiz personnalisé importé (JSON stocké dans Firestore)
    if (l.quizId == 'custom' && l.customQuestionsJson.isNotEmpty) {
      try {
        final raw = l.customQuestionsJson;
        final qs = QuizRepository.tipJsonToQuizQuestions(raw, sourceAssetPath: 'custom://imported');
        final ts = DateTime.now().millisecondsSinceEpoch;
        for (int i = 0; i < qs.length; i++) {
          final q = qs[i];
          all.add(BattleQuestion(
            id: 'custom_${ts}_$i',
            question: q.question,
            answer: q.answer,
            type: q.type,
            contextLine: q.contextLine,
            difficultyBucket: q.difficultyBucket,
            sourceAssetPath: 'custom://imported',
            indices: q.indices,
            checklist: q.checklist,
            options: q.options,
            answerSequence: q.answerSequence,
            categoryGroup: q.categoryGroup,
            authorName: q.authorName,
          ));
        }
      } catch (e) {
        debugPrint('[LobbyRepo] Erreur parsing quiz custom : $e');
      }
      all.shuffle();
      return all.take(l.questionCount).toList();
    }

    // Banque catalogue (Optimus, Terrain, Labo)
    List<String> paths = l.questionAssetPaths;

    final all2 = <BattleQuestion>[];
    for (final p in paths) {
      try {
        final raw = await AssetCacheService.loadString(p);
        final qs = QuizRepository.tipJsonToQuizQuestions(raw, sourceAssetPath: p);
        for (final q in qs) {
          if (l.difficultyFilters.contains(q.difficultyBucket) ||
              (q.difficultyBucket == 'unknown' && l.difficultyFilters.contains('moyen'))) {
            all2.add(BattleQuestion(
              id: q.id,
              question: q.question,
              answer: q.answer,
              type: q.type,
              contextLine: q.contextLine,
              difficultyBucket: q.difficultyBucket,
              sourceAssetPath: q.sourceAssetPath,
              indices: q.indices,
              checklist: q.checklist,
              options: q.options,
              answerSequence: q.answerSequence,
              categoryGroup: q.categoryGroup,
              authorName: q.authorName,
            ));
          }
        }
      } catch (e) {
        debugPrint('[LobbyRepo] Erreur chargement asset "$p" : $e');
      }
    }

    all2.shuffle();
    return all2.take(l.questionCount).toList();
  }

  PlayerState _playerToInitialState(PlayerMeta p, LobbyModel l) => PlayerState(
    userId: p.userId,
    displayName: p.displayName,
    avatar: p.avatar,
    score: 0.0,
    hasAnswered: false,
    isConnected: true,
    lives: l.isSurvival ? 3 : 0,
  );

  Future<void> submitAnswer(
    String lobbyId,
    String userId,
    String answerText,
  ) async {
    final ref = _db.collection('lobbies').doc(lobbyId);
    await _db.runTransaction((tx) async {
      final s = await tx.get(ref);
      if (!s.exists) return;
      final st = _battleFromDoc(s.data() ?? {}, lobbyId);
      if (st == null || st.phase != 'question') return;

      final players = st.players.map((p) {
        if (p.userId == userId) {
          return PlayerState(
            userId: p.userId,
            displayName: p.displayName,
            avatar: p.avatar,
            score: p.score,
            hasAnswered: true,
            isConnected: p.isConnected,
            lastAnswerText: answerText,
            lives: p.lives,
            eliminated: p.eliminated,
            lastScore: 0.0,
          );
        }
        return p;
      }).toList();

      // Sauvegarder la réponse dans allAnswers[currentQuestion][userId]
      final rawAnswers = List<Map<String, dynamic>>.from(
        st.allAnswers.map((m) => Map<String, dynamic>.from(m)),
      );
      while (rawAnswers.length <= st.currentQuestion) {
        rawAnswers.add(<String, dynamic>{});
      }
      rawAnswers[st.currentQuestion][userId] = answerText;

      tx.update(ref, {
        'battle.players': players.map((p) => _playerToMap(p)).toList(),
        'battle.allAnswers': rawAnswers,
      });
    });
  }

  Future<void> revealIndice(String lobbyId) async {
    await _db.collection('lobbies').doc(lobbyId).update({
      'battle.revealedIndices': FieldValue.increment(1),
    });
  }

  Future<void> setBattlePhaseJudgment(String lobbyId) async {
    await _db.collection('lobbies').doc(lobbyId).update({
      'battle.phase': 'judgment',
    });
  }

  Future<void> judgePlayerAnswer(
    String lobbyId,
    String userId,
    bool isCorrect,
  ) async {
    final ref = _db.collection('lobbies').doc(lobbyId);
    await _db.runTransaction((tx) async {
      final s = await tx.get(ref);
      if (!s.exists) return;
      final st = _battleFromDoc(s.data() ?? {}, lobbyId);
      if (st == null || st.phase != 'judgment') return;
      if (st.currentQuestion < 0 || st.currentQuestion >= st.questions.length) return;

      final q = st.questions[st.currentQuestion];
      double points = isCorrect ? 1.0 : 0.0;
      
      if (isCorrect && q.type == 'diagnostic_indices') {
        points = (1.0 - (st.revealedIndices * 0.25)).clamp(0.25, 1.0);
      }

      final players = st.players.map((p) {
        if (p.userId != userId) return p;
        var lives = p.lives;
        var eliminated = p.eliminated;
        if (st.isSurvival && !isCorrect) {
          lives = max(0, lives - 1);
          if (lives == 0) eliminated = true;
        }
        return PlayerState(
          userId: p.userId,
          displayName: p.displayName,
          avatar: p.avatar,
          score: p.score + points,
          hasAnswered: p.hasAnswered,
          isConnected: p.isConnected,
          lastAnswerText: p.lastAnswerText,
          lives: lives,
          eliminated: eliminated,
          lastJudgment: isCorrect,
          lastScore: points,
        );
      }).toList();

      tx.update(ref, {
        'battle.players': players.map((p) => _playerToMap(p)).toList(),
      });
    });
  }

  /// Auto-score toutes les réponses d'une question de type 'sequence'.
  /// Score = nombre de positions correctes / total. Pas de jugement manuel.
  Future<void> judgeSequenceAnswers(String lobbyId) async {
    final ref = _db.collection('lobbies').doc(lobbyId);
    await _db.runTransaction((tx) async {
      final s = await tx.get(ref);
      if (!s.exists) return;
      final st = _battleFromDoc(s.data() ?? {}, lobbyId);
      if (st == null || st.phase != 'judgment') return;
      if (st.currentQuestion < 0 || st.currentQuestion >= st.questions.length) return;

      final q = st.questions[st.currentQuestion];
      final correct = q.answerSequence ?? [];

      final players = st.players.map((p) {
        List<String> playerOrder = [];
        try {
          final decoded = jsonDecode(p.lastAnswerText ?? '[]');
          if (decoded is List) playerOrder = List<String>.from(decoded);
        } catch (_) {}

        double score = 0.0;
        if (correct.isNotEmpty) {
          int ok = 0;
          for (int i = 0; i < correct.length; i++) {
            if (i < playerOrder.length && playerOrder[i] == correct[i]) ok++;
          }
          score = ok / correct.length;
        }

        var lives = p.lives;
        var eliminated = p.eliminated;
        if (st.isSurvival && score < 0.5) {
          lives = max(0, lives - 1);
          if (lives == 0) eliminated = true;
        }

        return PlayerState(
          userId: p.userId,
          displayName: p.displayName,
          avatar: p.avatar,
          score: p.score + score,
          hasAnswered: p.hasAnswered,
          isConnected: p.isConnected,
          lastAnswerText: p.lastAnswerText,
          lives: lives,
          eliminated: eliminated,
          lastJudgment: score >= 0.5,
          lastScore: score,
        );
      }).toList();

      tx.update(ref, {
        'battle.players': players.map((pp) => _playerToMap(pp)).toList(),
      });
    });
  }

  Future<void> showRoundResult(String lobbyId) async {
    await _db.collection('lobbies').doc(lobbyId).update({
      'battle.phase': 'result',
    });
  }

  Future<void> advanceToNextQuestion(String lobbyId) async {
    final ref = _db.collection('lobbies').doc(lobbyId);
    final d = await ref.get();
    final st = _battleFromDoc(d.data() ?? {}, lobbyId);
    if (st == null) return;

    if (st.currentQuestion >= st.totalQuestions - 1) {
      // Dernière question → correction finale
      await ref.update({'battle.phase': 'final_judgment'});
      return;
    }

    final players = st.players.map((p) => PlayerState(
      userId: p.userId,
      displayName: p.displayName,
      avatar: p.avatar,
      score: p.score,
      hasAnswered: false,
      isConnected: p.isConnected,
      lives: p.lives,
      eliminated: p.eliminated,
    )).toList();

    await ref.update({
      'battle.currentQuestion': st.currentQuestion + 1,
      'battle.phase': 'question',
      'battle.players': players.map((p) => _playerToMap(p)).toList(),
      'battle.revealedIndices': 0,
    });
  }

  /// Marque la réponse d'un joueur pour une question donnée (correction finale).
  /// Met à jour le score ET enregistre le jugement pour éviter les doublons.
  Future<void> judgeAnswerAtEnd(
    String lobbyId,
    int questionIdx,
    String userId,
    bool isCorrect,
  ) async {
    final ref = _db.collection('lobbies').doc(lobbyId);
    await _db.runTransaction((tx) async {
      final s = await tx.get(ref);
      if (!s.exists) return;
      final st = _battleFromDoc(s.data() ?? {}, lobbyId);
      if (st == null) return;

      // Vérifier que ce jugement n'a pas déjà été rendu
      if (questionIdx < st.allJudgments.length) {
        final judged = st.allJudgments[questionIdx][userId];
        if (judged != null) return; // Déjà jugé
      }

      // Mettre à jour le score du joueur
      final players = st.players.map((p) {
        if (p.userId != userId) return p;
        return PlayerState(
          userId: p.userId,
          displayName: p.displayName,
          avatar: p.avatar,
          score: p.score + (isCorrect ? 1.0 : 0.0),
          hasAnswered: p.hasAnswered,
          isConnected: p.isConnected,
          lastAnswerText: p.lastAnswerText,
          lives: p.lives,
          eliminated: p.eliminated,
        );
      }).toList();

      // Enregistrer le jugement
      final rawJudgments = List<Map<String, dynamic>>.from(
        st.allJudgments.map((m) => Map<String, dynamic>.from(m)),
      );
      while (rawJudgments.length <= questionIdx) {
        rawJudgments.add(<String, dynamic>{});
      }
      rawJudgments[questionIdx][userId] = isCorrect;

      tx.update(ref, {
        'battle.players': players.map((p) => _playerToMap(p)).toList(),
        'battle.allJudgments': rawJudgments,
      });
    });
  }

  /// Termine la correction finale et affiche les scores.
  Future<void> finalizeBattle(String lobbyId) async {
    await _db.collection('lobbies').doc(lobbyId).update({
      'status': 'finished',
      'battle.phase': 'finished',
    });
  }

  BattleState? _battleFromDoc(Map<String, dynamic> data, String lobbyId) {
    final b = data['battle'];
    if (b is! Map) return null;
    final m = Map<String, dynamic>.from(b);
    
    final players = (m['players'] as List? ?? []).map((p) {
      final map = Map<String, dynamic>.from(p);
      return PlayerState(
        userId: map['userId'] ?? '',
        displayName: map['displayName'] ?? '',
        avatar: map['avatar'] ?? '',
        score: (map['score'] as num?)?.toDouble() ?? 0.0,
        hasAnswered: map['hasAnswered'] ?? false,
        isConnected: map['isConnected'] ?? true,
        lastAnswerText: map['lastAnswerText'],
        lives: map['lives'] ?? 0,
        eliminated: map['eliminated'] ?? false,
        lastJudgment: map['lastJudgment'],
        lastScore: (map['lastScore'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    final questions = (m['questions'] as List? ?? []).map((q) {
      final map = Map<String, dynamic>.from(q);
      return BattleQuestion(
        id: map['id'] ?? '',
        question: map['question'] ?? '',
        answer: map['answer'] ?? '',
        type: map['type'] ?? 'classic',
        contextLine: map['contextLine'],
        difficultyBucket: map['difficultyBucket'] ?? 'unknown',
        sourceAssetPath: map['sourceAssetPath'],
        indices: map['indices'] is List ? List<String>.from(map['indices']) : null,
        checklist: map['checklist'] is List ? List<String>.from(map['checklist']) : null,
        options: map['options'] is List ? List<String>.from(map['options']) : null,
        answerSequence: map['answerSequence'] is List ? List<String>.from(map['answerSequence']) : null,
        categoryGroup: QuestionCategoryGroup.values[map['categoryGroup'] ?? 0],
        authorName: map['authorName'] ?? 'Eskolia Team',
      );
    }).toList();

    final rawAnswers = (m['allAnswers'] as List? ?? []);
    final allAnswers = rawAnswers.map((e) {
      final map = Map<String, dynamic>.from(e as Map? ?? {});
      return map.map((k, v) => MapEntry(k, v?.toString() ?? ''));
    }).toList();

    final rawJudgments = (m['allJudgments'] as List? ?? []);
    final allJudgments = rawJudgments.map((e) {
      final map = Map<String, dynamic>.from(e as Map? ?? {});
      return map.map((k, v) => MapEntry(k, v as bool?));
    }).toList();

    return BattleState(
      lobbyId: lobbyId,
      players: players,
      currentQuestion: m['currentQuestion'] ?? 0,
      totalQuestions: m['totalQuestions'] ?? 5,
      phase: m['phase'] ?? 'question',
      questions: questions,
      timed: m['timed'] as bool? ?? false,
      gameMode: m['gameMode'] ?? kLobbyGameModeQuiz,
      revealedIndices: m['revealedIndices'] ?? 0,
      allAnswers: allAnswers,
      allJudgments: allJudgments,
    );
  }

  Map<String, dynamic> _playerToMap(PlayerState p) => {
    'userId': p.userId,
    'displayName': p.displayName,
    'avatar': p.avatar,
    'score': p.score,
    'hasAnswered': p.hasAnswered,
    'isConnected': p.isConnected,
    'lastAnswerText': p.lastAnswerText,
    'lives': p.lives,
    'eliminated': p.eliminated,
    'lastJudgment': p.lastJudgment,
    'lastScore': p.lastScore,
  };

  Future<void> leaveLobby(String lobbyId, String userId) async {
    final ref = _db.collection('lobbies').doc(lobbyId);
    await ref.update({
      'playerIds': FieldValue.arrayRemove([userId]),
      'currentPlayers': FieldValue.increment(-1),
    });
  }

  Future<void> resetBattle(String lobbyId) async {
    await _db.collection('lobbies').doc(lobbyId).update({
      'status': 'waiting',
      'battle': FieldValue.delete(),
    });
  }

  Stream<BattleState> watchBattle(String lobbyId) {
    return _db.collection('lobbies').doc(lobbyId).snapshots().map((snap) {
      if (!snap.exists) return _emptyBattle(lobbyId);
      return _battleFromDoc(snap.data() ?? {}, lobbyId) ?? _emptyBattle(lobbyId);
    });
  }

  BattleState _emptyBattle(String lobbyId) => BattleState(
    lobbyId: lobbyId,
    players: const [],
    currentQuestion: 0,
    totalQuestions: 5,
    phase: 'finished',
    questions: const [],
    timed: false,
    gameMode: kLobbyGameModeQuiz,
  );
}
