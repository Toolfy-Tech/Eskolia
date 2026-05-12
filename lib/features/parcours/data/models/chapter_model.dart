import '../../../auth/data/user_model.dart';

class ChapterModel {
  const ChapterModel({
    required this.id,
    required this.number,
    required this.title,
    required this.description,
    required this.totalModules,
    required this.isUnlocked,
    required this.moduleIds,
  });

  final String id;
  final int number;
  final String title;
  final String description;
  final int totalModules;
  final bool isUnlocked;
  final List<String> moduleIds;

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'] as String? ?? '',
      number: (json['number'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      totalModules: (json['totalModules'] as num?)?.toInt() ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      moduleIds: _ids(json['moduleIds']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'title': title,
        'description': description,
        'totalModules': totalModules,
        'isUnlocked': isUnlocked,
        'moduleIds': moduleIds,
      };

  bool isCompleted(UserModel user) {
    if (user.currentChapter > number) return true;
    if (user.currentChapter < number) return false;
    return user.currentModule > totalModules;
  }

  double progressFor(UserModel user) {
    if (user.currentChapter > number) return 1.0;
    if (user.currentChapter < number) return 0.0;
    if (totalModules <= 0) return 0.0;
    return (user.currentModule / totalModules).clamp(0.0, 1.0);
  }

  ChapterModel copyWith({
    String? id,
    int? number,
    String? title,
    String? description,
    int? totalModules,
    bool? isUnlocked,
    List<String>? moduleIds,
  }) {
    return ChapterModel(
      id: id ?? this.id,
      number: number ?? this.number,
      title: title ?? this.title,
      description: description ?? this.description,
      totalModules: totalModules ?? this.totalModules,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      moduleIds: moduleIds ?? this.moduleIds,
    );
  }

  static List<String> _ids(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((e) => e.toString()).toList();
  }
}
