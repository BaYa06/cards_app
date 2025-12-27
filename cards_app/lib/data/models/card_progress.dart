/// Модель прогресса изучения карточки
class CardProgress {
  final String id;
  final String cardId;
  final int repetitions; // Количество повторений
  final double easeFactor; // Фактор легкости (SM-2 алгоритм)
  final int interval; // Интервал до следующего повторения в днях
  final DateTime lastReviewDate;
  final DateTime nextReviewDate;
  final int correctCount; // Количество правильных ответов
  final int incorrectCount; // Количество неправильных ответов
  final bool isLearned; // Считается выученной
  final DateTime createdAt;
  final DateTime updatedAt;
  final CardStatus status;

  const CardProgress({
    required this.id,
    required this.cardId,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.interval = 0,
    required this.lastReviewDate,
    required this.nextReviewDate,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.isLearned = false,
    required this.createdAt,
    required this.updatedAt,
    this.status = CardStatus.learning,
  });

  /// Процент правильных ответов
  double get accuracy {
    final total = correctCount + incorrectCount;
    if (total == 0) return 0.0;
    return correctCount / total;
  }

  /// Всего попыток
  int get totalAttempts => correctCount + incorrectCount;

  /// Нужно ли повторять сегодня
  bool get isDueForReview {
    final now = DateTime.now();
    return nextReviewDate.isBefore(now) || 
           nextReviewDate.isAtSameMomentAs(now) ||
           (nextReviewDate.year == now.year && 
            nextReviewDate.month == now.month && 
            nextReviewDate.day == now.day);
  }

  /// Создание из JSON
  factory CardProgress.fromJson(Map<String, dynamic> json) {
    return CardProgress(
      id: json['id'].toString(),
      cardId: json['card_id'].toString(),
      repetitions: json['repetitions'] as int? ?? 0,
      easeFactor: (json['ease_factor'] as num?)?.toDouble() ?? 2.5,
      interval: json['interval'] as int? ?? 0,
      lastReviewDate: DateTime.parse(json['last_review_date'] as String),
      nextReviewDate: DateTime.parse(json['next_review_date'] as String),
      correctCount: json['correct_count'] as int? ?? 0,
      incorrectCount: json['incorrect_count'] as int? ?? 0,
      isLearned: json['is_learned'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      status: CardStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'learning'),
        orElse: () => CardStatus.learning,
      ),
    );
  }

  /// Конвертация в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_id': cardId,
      'repetitions': repetitions,
      'ease_factor': easeFactor,
      'interval': interval,
      'last_review_date': lastReviewDate.toIso8601String(),
      'next_review_date': nextReviewDate.toIso8601String(),
      'correct_count': correctCount,
      'incorrect_count': incorrectCount,
      'is_learned': isLearned,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status.name,
    };
  }

  /// Копирование с изменениями
  CardProgress copyWith({
    String? id,
    String? cardId,
    int? repetitions,
    double? easeFactor,
    int? interval,
    DateTime? lastReviewDate,
    DateTime? nextReviewDate,
    int? correctCount,
    int? incorrectCount,
    bool? isLearned,
    DateTime? createdAt,
    DateTime? updatedAt,
    CardStatus? status,
  }) {
    return CardProgress(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      repetitions: repetitions ?? this.repetitions,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      isLearned: isLearned ?? this.isLearned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  /// Создание начального прогресса для новой карточки
  factory CardProgress.initial({
    required String id,
    required String cardId,
  }) {
    final now = DateTime.now();
    return CardProgress(
      id: id,
      cardId: cardId,
      lastReviewDate: now,
      nextReviewDate: now,
      createdAt: now,
      updatedAt: now,
      status: CardStatus.learning,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardProgress &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum CardStatus { learning, reviewing, mastered }
