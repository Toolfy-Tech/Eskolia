import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherQuiz {
  const TeacherQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.authorId,
    required this.authorName,
    required this.isPublished,
    required this.questions,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final String authorId;
  final String authorName;
  final bool isPublished;
  final List<TeacherQuizQuestion> questions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static TeacherQuiz fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    final rawQ = d['questions'] as List<dynamic>? ?? [];
    return TeacherQuiz(
      id: doc.id,
      title: d['title'] as String? ?? '',
      description: d['description'] as String? ?? '',
      authorId: d['authorId'] as String? ?? '',
      authorName: d['authorName'] as String? ?? 'Admin',
      isPublished: d['isPublished'] as bool? ?? false,
      questions: rawQ
          .whereType<Map<String, dynamic>>()
          .map(TeacherQuizQuestion.fromMap)
          .toList(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'authorId': authorId,
        'authorName': authorName,
        'isPublished': isPublished,
        'questions': questions.map((q) => q.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

class TeacherQuizQuestion {
  const TeacherQuizQuestion({
    required this.question,
    required this.answer,
    required this.difficulty,
    this.hint = '',
    this.type = 'classic',
    this.contextLine,
    this.indices = const [],
    this.items = const [],
    this.pairs = const [],
    this.checklist = const [],
  });

  final String question;
  final String answer;
  final String difficulty;
  final String hint;
  final String type;
  final String? contextLine;
  final List<String> indices;
  final List<String> items;
  final List<List<String>> pairs;
  final List<String> checklist;

  static TeacherQuizQuestion fromMap(Map<String, dynamic> m) {
    final rawPairs = m['pairs'];
    final pairs = <List<String>>[];
    if (rawPairs is List) {
      for (final p in rawPairs) {
        if (p is List && p.length >= 2) {
          pairs.add([p[0].toString(), p[1].toString()]);
        } else if (p is Map) {
          final l = p['left']?.toString() ?? '';
          final r = p['right']?.toString() ?? '';
          if (l.isNotEmpty && r.isNotEmpty) pairs.add([l, r]);
        }
      }
    }

    return TeacherQuizQuestion(
      question: m['question'] as String? ?? '',
      answer: m['answer'] as String? ?? '',
      difficulty: m['difficulty'] as String? ?? 'moyen',
      hint: m['hint'] as String? ?? '',
      type: m['type'] as String? ?? 'classic',
      contextLine: m['contextLine'] as String?,
      indices: List<String>.from(m['indices'] as List? ?? []),
      items: List<String>.from(m['items'] as List? ?? []),
      pairs: pairs,
      checklist: List<String>.from(m['checklist'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'question': question,
        'answer': answer,
        'difficulty': difficulty,
        'hint': hint,
        'type': type,
        'contextLine': contextLine,
        'indices': indices,
        'items': items,
        'pairs': pairs,
        'checklist': checklist,
      };
}
