import 'dart:convert';

/// Un note dans le carnet personnel de l'utilisateur.
class NoteModel {
  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Identifiant unique — millisecondes depuis epoch (String).
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

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

  /// Retourne une copie avec le titre/contenu mis a jour et updatedAt = now.
  NoteModel copyWith({String? title, String? content}) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
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
