/// Модель сессии обучения
class StudySession {
  final String id;
  final String? categoryId;
  final DateTime startTime;
  final DateTime? endTime;
  final int totalCards;
  final int cardsReviewed;
  final int correctAnswers;
  final int incorrectAnswers;
  final int skippedCards;
  final List<CardReview> reviews;
  final bool isCompleted;

  const StudySession({
    required this.id,
    this.categoryId,
    required this.startTime,
    this.endTime,
    required this.totalCards,
    int cardsReviewed = 0,
    int? cardsStudied,
    int correctAnswers = 0,
    int incorrectAnswers = 0,
    int skippedCards = 0,
    List<CardReview> reviews = const [],
    bool isCompleted = false,
  })  : cardsReviewed = cardsStudied ?? cardsReviewed,
        correctAnswers = correctAnswers,
        incorrectAnswers = incorrectAnswers,
        skippedCards = skippedCards,
        reviews = reviews,
        isCompleted = isCompleted;

  int get cardsStudied => cardsReviewed;
  int get wrongAnswers => incorrectAnswers;

  /// Длительность сессии
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Длительность в секундах
  int get durationInSeconds => duration.inSeconds;

  /// Точность в сессии
  double get accuracy {
    if (cardsReviewed == 0) return 0.0;
    return correctAnswers / cardsReviewed;
  }

  /// Прогресс сессии (0.0 - 1.0)
  double get progress {
    if (totalCards == 0) return 0.0;
    return cardsReviewed / totalCards;
  }

  /// Среднее время на карточку (в секундах)
  double get averageTimePerCard {
    if (cardsReviewed == 0) return 0.0;
    return durationInSeconds / cardsReviewed;
  }

  /// Опыт, заработанный в сессии
  int get earnedExperience {
    // 10 опыта за правильный ответ, 2 за неправильный
    return (correctAnswers * 10) + (incorrectAnswers * 2);
  }

  /// Создание из JSON
  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'].toString(),
      categoryId: json['category_id'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      totalCards: json['total_cards'] as int,
      cardsReviewed: json['cards_reviewed'] as int? ?? json['cards_studied'] as int? ?? 0,
      correctAnswers: json['correct_answers'] as int? ?? 0,
      incorrectAnswers: json['incorrect_answers'] as int? ?? json['wrong_answers'] as int? ?? 0,
      skippedCards: json['skipped_cards'] as int? ?? 0,
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => CardReview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  /// Конвертация в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'total_cards': totalCards,
      'cards_reviewed': cardsReviewed,
      'correct_answers': correctAnswers,
      'incorrect_answers': incorrectAnswers,
      'skipped_cards': skippedCards,
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'is_completed': isCompleted,
    };
  }

  /// Копирование с изменениями
  StudySession copyWith({
    String? id,
    String? categoryId,
    DateTime? startTime,
    DateTime? endTime,
    int? totalCards,
    int? cardsReviewed,
    int? correctAnswers,
    int? incorrectAnswers,
    int? skippedCards,
    List<CardReview>? reviews,
    bool? isCompleted,
  }) {
    return StudySession(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalCards: totalCards ?? this.totalCards,
      cardsReviewed: cardsReviewed ?? this.cardsReviewed,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      skippedCards: skippedCards ?? this.skippedCards,
      reviews: reviews ?? this.reviews,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Модель ответа на карточку в сессии
class CardReview {
  final String id;
  final String cardId;
  final bool isCorrect;
  final int responseTimeMs;
  final String? userAnswer;
  final DateTime reviewedAt;

  const CardReview({
    required this.id,
    required this.cardId,
    required this.isCorrect,
    required this.responseTimeMs,
    this.userAnswer,
    required this.reviewedAt,
  });

  factory CardReview.fromJson(Map<String, dynamic> json) {
    return CardReview(
      id: json['id'] as String,
      cardId: json['card_id'] as String,
      isCorrect: json['is_correct'] as bool,
      responseTimeMs: json['response_time_ms'] as int,
      userAnswer: json['user_answer'] as String?,
      reviewedAt: DateTime.parse(json['reviewed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_id': cardId,
      'is_correct': isCorrect,
      'response_time_ms': responseTimeMs,
      'user_answer': userAnswer,
      'reviewed_at': reviewedAt.toIso8601String(),
    };
  }
}
