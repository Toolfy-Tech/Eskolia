class FlashcardModel {
  const FlashcardModel({
    required this.id,
    required this.moduleId,
    required this.question,
    required this.answer,
    this.hint,
    required this.difficulty,
    required this.timesReviewed,
    required this.isKnown,
  });

  final String id;
  final String moduleId;
  final String question;
  final String answer;
  final String? hint;
  final String difficulty;
  final int timesReviewed;
  final bool isKnown;

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json['id'] as String? ?? '',
      moduleId: json['moduleId'] as String? ?? '',
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      hint: json['hint'] as String?,
      difficulty: json['difficulty'] as String? ?? 'easy',
      timesReviewed: (json['timesReviewed'] as num?)?.toInt() ?? 0,
      isKnown: json['isKnown'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'moduleId': moduleId,
        'question': question,
        'answer': answer,
        if (hint != null) 'hint': hint,
        'difficulty': difficulty,
        'timesReviewed': timesReviewed,
        'isKnown': isKnown,
      };

  FlashcardModel copyWith({
    String? id,
    String? moduleId,
    String? question,
    String? answer,
    String? hint,
    bool clearHint = false,
    String? difficulty,
    int? timesReviewed,
    bool? isKnown,
  }) {
    return FlashcardModel(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      hint: clearHint ? null : (hint ?? this.hint),
      difficulty: difficulty ?? this.difficulty,
      timesReviewed: timesReviewed ?? this.timesReviewed,
      isKnown: isKnown ?? this.isKnown,
    );
  }
}
