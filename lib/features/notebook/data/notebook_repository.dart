import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'note_model.dart';

/// Persiste les notes localement via SharedPreferences.
/// Cle de stockage : 'notebook_notes_v1'
class NotebookRepository {
  static const String _key = 'notebook_notes_v1';

  /// Charge toutes les notes, triees par updatedAt decroissant.
  Future<List<NoteModel>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final notes = list
          .map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
          .toList();
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return notes;
    } catch (_) {
      return const [];
    }
  }

  /// Upsert : insere ou remplace la note par son id.
  Future<void> save(NoteModel note) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = List<NoteModel>.from(await loadAll());
    final idx = notes.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      notes[idx] = note;
    } else {
      notes.add(note);
    }
    await prefs.setString(_key, jsonEncode(notes.map((n) => n.toJson()).toList()));
  }

  /// Supprime la note identifiee par [id].
  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = List<NoteModel>.from(await loadAll());
    notes.removeWhere((n) => n.id == id);
    await prefs.setString(_key, jsonEncode(notes.map((n) => n.toJson()).toList()));
  }
}
