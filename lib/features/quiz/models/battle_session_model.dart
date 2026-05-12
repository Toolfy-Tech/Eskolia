import 'package:cloud_firestore/cloud_firestore.dart';
import 'quiz_models.dart';

class BattleSessionModel {
  const BattleSessionModel({
    required this.id,
    required this.player1Id,
    required this.player2Id,
    required this.player1Name,
    required this.player2Name,
    required this.player1Score,
    required this.player2Score,
    required this.questions,
    required this.currentQuestionIndex,
    required this.status,
    this.winnerId,
    required this.createdAt,
    required this.moduleId,
  });

  final String id;
  final String player1Id;
  final String player2Id;
  final String player1Name;
  final String player2Name;
  final int player1Score;
  final int player2Score;
  final List<QuizQuestion> questions;
  final int currentQuestionIndex;
  final String status;
  final String? winnerId;
  final DateTime createdAt;
  final String moduleId;

  bool get isFinished => status == 'finished';

  String? get loser {
    if (winnerId == null) return null;
    if (winnerId == player1Id) return player2Id;
    return player1Id;
  }

  bool isWinner(String uid) => winnerId == uid;

  int scoreFor(String uid) {
    if (uid == player1Id) return player1Score;
    if (uid == player2Id) return player2Score;
    return 0;
  }

  factory BattleSessionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final qRaw = data['questions'];
    final questions = <QuizQuestion>[];
    if (qRaw is List) {
      for (final e in qRaw) {
        if (e is Map<String, dynamic>) {
          questions.add(_quizQuestionFromMap(e));
        } else if (e is Map) {
          questions.add(_quizQuestionFromMap(Map<String, dynamic>.from(e)));
        }
      }
    }
    return BattleSessionModel(
      id: doc.id,
      player1Id: data['player1Id'] as String? ?? '',
      player2Id: data['player2Id'] as String? ?? '',
      player1Name: data['player1Name'] as String? ?? '',
      player2Name: data['player2Name'] as String? ?? '',
      player1Score: (data['player1Score'] as num?)?.toInt() ?? 0,
      player2Score: (data['player2Score'] as num?)?.toInt() ?? 0,
      questions: questions,
      currentQuestionIndex: (data['currentQuestionIndex'] as num?)?.toInt() ?? 0,
      status: data['status'] as String? ?? 'waiting',
      winnerId: data['winnerId'] as String?,
      createdAt: _tsToDate(data['createdAt']) ?? DateTime.now(),
      moduleId: data['moduleId'] as String? ?? '',
    );
  }

  static QuizQuestion _quizQuestionFromMap(Map<String, dynamic> m) {
    return QuizQuestion(
      id: m['id']?.toString() ?? '',
      type: m['type']?.toString() ?? 'classic',
      question: m['question']?.toString() ?? '',
      answer: (m['answer'] ?? m['correctAnswer'])?.toString() ?? '',
      explanation: m['explanation']?.toString(),
      options: m['options'] is List ? List<String>.from(m['options']) : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'player1Id': player1Id,
        'player2Id': player2Id,
        'player1Name': player1Name,
        'player2Name': player2Name,
        'player1Score': player1Score,
        'player2Score': player2Score,
        'questions': questions.map((q) => q.toJson()).toList(),
        'currentQuestionIndex': currentQuestionIndex,
        'status': status,
        if (winnerId != null) 'winnerId': winnerId,
        'createdAt': Timestamp.fromDate(createdAt),
        'moduleId': moduleId,
      };

  BattleSessionModel copyWith({
    String? id,
    String? player1Id,
    String? player2Id,
    String? player1Name,
    String? player2Name,
    int? player1Score,
    int? player2Score,
    List<QuizQuestion>? questions,
    int? currentQuestionIndex,
    String? status,
    String? winnerId,
    bool clearWinnerId = false,
    DateTime? createdAt,
    String? moduleId,
  }) {
    return BattleSessionModel(
      id: id ?? this.id,
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id ?? this.player2Id,
      player1Name: player1Name ?? this.player1Name,
      player2Name: player2Name ?? this.player2Name,
      player1Score: player1Score ?? this.player1Score,
      player2Score: player2Score ?? this.player2Score,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      status: status ?? this.status,
      winnerId: clearWinnerId ? null : (winnerId ?? this.winnerId),
      createdAt: createdAt ?? this.createdAt,
      moduleId: moduleId ?? this.moduleId,
    );
  }

  static DateTime? _tsToDate(dynamic v) {
    if (v is Timestamp) return v.toDate();
    return null;
  }
}
