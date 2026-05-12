class ModuleModel {
  const ModuleModel({
    required this.id,
    required this.chapterId,
    required this.number,
    required this.title,
    required this.content,
    required this.type,
    required this.xpReward,
    required this.estimatedMinutes,
    required this.isUnlocked,
  });

  final String id;
  final String chapterId;
  final int number;
  final String title;
  final String content;
  final String type;
  final int xpReward;
  final int estimatedMinutes;
  final bool isUnlocked;

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'] as String? ?? '',
      chapterId: json['chapterId'] as String? ?? '',
      number: (json['number'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? 'lesson',
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 0,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chapterId': chapterId,
        'number': number,
        'title': title,
        'content': content,
        'type': type,
        'xpReward': xpReward,
        'estimatedMinutes': estimatedMinutes,
        'isUnlocked': isUnlocked,
      };

  ModuleModel copyWith({
    String? id,
    String? chapterId,
    int? number,
    String? title,
    String? content,
    String? type,
    int? xpReward,
    int? estimatedMinutes,
    bool? isUnlocked,
  }) {
    return ModuleModel(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      number: number ?? this.number,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      xpReward: xpReward ?? this.xpReward,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
