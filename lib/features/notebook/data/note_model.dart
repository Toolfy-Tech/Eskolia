import 'dart:convert';

class NoteModel {
  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.aiResultsJson,
    this.aiFlashcardsJson,
  });

  /// Identifiant unique — millisecondes depuis epoch (String).
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? aiResultsJson;
  final String? aiFlashcardsJson;

  /// Cree une nouvelle note avec un id base sur l'instant.
  factory NoteModel.create({String title = '', String content = ''}) {
    final now = DateTime.now();
    return NoteModel(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Retourne une copie avec le titre/contenu/IA mis a jour et updatedAt = now.
  NoteModel copyWith({
    String? title,
    String? content,
    String? aiResultsJson,
    String? aiFlashcardsJson,
    bool clearAi = false,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      aiResultsJson: clearAi ? null : (aiResultsJson ?? this.aiResultsJson),
      aiFlashcardsJson: clearAi ? null : (aiFlashcardsJson ?? this.aiFlashcardsJson),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
        'aiResultsJson': aiResultsJson,
        'aiFlashcardsJson': aiFlashcardsJson,
      };

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
      aiResultsJson: json['aiResultsJson'] as String?,
      aiFlashcardsJson: json['aiFlashcardsJson'] as String?,
    );
  }

  /// Serialise en String JSON pour SharedPreferences.
  String toJsonString() => jsonEncode(toJson());

  factory NoteModel.fromJsonString(String raw) =>
      NoteModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is NoteModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
