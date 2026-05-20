import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedNotebookQuiz {
  const SavedNotebookQuiz({
    required this.id,
    required this.title,
    required this.rawJson,
    required this.savedAt,
    this.noteTitle,
  });

  final String id;
  final String title;
  final String rawJson;
  final DateTime savedAt;
  final String? noteTitle;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'rawJson': rawJson,
        'savedAt': savedAt.millisecondsSinceEpoch,
        if (noteTitle != null) 'noteTitle': noteTitle,
      };

  factory SavedNotebookQuiz.fromJson(Map<String, dynamic> m) =>
      SavedNotebookQuiz(
        id: m['id'] as String,
        title: m['title'] as String? ?? 'Quiz IA',
        rawJson: m['rawJson'] as String? ?? '',
        savedAt: DateTime.fromMillisecondsSinceEpoch(
            (m['savedAt'] as num?)?.toInt() ?? 0),
        noteTitle: m['noteTitle'] as String?,
      );

  factory SavedNotebookQuiz.create({
    required String title,
    required String rawJson,
    String? noteTitle,
  }) =>
      SavedNotebookQuiz(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        rawJson: rawJson,
        savedAt: DateTime.now(),
        noteTitle: noteTitle,
      );
}

class SavedQuizRepository {
  static const _key = 'notebook_saved_quizzes_v1';

  Future<List<SavedNotebookQuiz>> loadAll() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_key);
    if (s == null || s.isEmpty) return [];
    try {
      final list = jsonDecode(s) as List<dynamic>;
      final out = list
          .whereType<Map>()
          .map((e) =>
              SavedNotebookQuiz.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      out.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      return out;
    } catch (_) {
      return [];
    }
  }

  Future<void> save(SavedNotebookQuiz quiz) async {
    final all = await loadAll();
    all.removeWhere((q) => q.id == quiz.id);
    all.insert(0, quiz);
    await _persist(all);
  }

  Future<void> delete(String id) async {
    final all = await loadAll();
    all.removeWhere((q) => q.id == id);
    await _persist(all);
  }

  Future<void> _persist(List<SavedNotebookQuiz> list) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(list.map((q) => q.toJson()).toList()));
  }
}
