/// Модель статистики пользователя
class UserStatistics {
  final String id;
  final int totalCardsLearned;
  final int totalCardsReviewed;
  final int totalCorrectAnswers;
  final int totalIncorrectAnswers;
  final int totalStudyTimeSeconds;
  final int totalStudyTimeMinutes;
  final int currentStreak;
  final int longestStreak;
  final int totalExperience;
  final DateTime? lastStudyDate;
  final Map<String, int> categoryProgress; // categoryId -> learned cards count
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserStatistics({
    required this.id,
    this.totalCardsLearned = 0,
    this.totalCardsReviewed = 0,
    this.totalCorrectAnswers = 0,
    this.totalIncorrectAnswers = 0,
    this.totalStudyTimeSeconds = 0,
    this.totalStudyTimeMinutes = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalExperience = 0,
    this.lastStudyDate,
    this.categoryProgress = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// Общая точность
  double get accuracy {
    final total = totalCorrectAnswers + totalIncorrectAnswers;
    if (total == 0) return 0.0;
    return totalCorrectAnswers / total;
  }

  /// Уровень пользователя
  int get level {
    if (totalExperience < 100) return 1;
    int level = 1;
    int requiredExp = 100;
    while (totalExperience >= requiredExp) {
      level++;
      requiredExp += level * 100;
    }
    return level;
  }

  /// Прогресс до следующего уровня (0.0 - 1.0)
  double get levelProgress {
    int currentLevelExp = 0;
    int nextLevelExp = 100;
    int lvl = 1;

    while (totalExperience >= nextLevelExp) {
      currentLevelExp = nextLevelExp;
      lvl++;
      nextLevelExp += lvl * 100;
    }

    return (totalExperience - currentLevelExp) / (nextLevelExp - currentLevelExp);
  }

  /// Проверка, занимался ли пользователь сегодня
  bool get studiedToday {
    if (lastStudyDate == null) return false;
    final now = DateTime.now();
    return lastStudyDate!.year == now.year &&
        lastStudyDate!.month == now.month &&
        lastStudyDate!.day == now.day;
  }

  /// Создание из JSON
  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      id: json['id'] as String,
      totalCardsLearned: json['total_cards_learned'] as int? ?? 0,
      totalCardsReviewed: json['total_cards_reviewed'] as int? ?? 0,
      totalCorrectAnswers: json['total_correct_answers'] as int? ?? 0,
      totalIncorrectAnswers: json['total_incorrect_answers'] as int? ?? 0,
      totalStudyTimeSeconds: json['total_study_time_seconds'] as int? ?? 0,
      totalStudyTimeMinutes: json['total_study_time_minutes'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      totalExperience: json['total_experience'] as int? ?? 0,
      lastStudyDate: json['last_study_date'] != null
          ? DateTime.parse(json['last_study_date'] as String)
          : null,
      categoryProgress: (json['category_progress'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value as int)) ??
          {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Конвертация в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total_cards_learned': totalCardsLearned,
      'total_cards_reviewed': totalCardsReviewed,
      'total_correct_answers': totalCorrectAnswers,
      'total_incorrect_answers': totalIncorrectAnswers,
      'total_study_time_seconds': totalStudyTimeSeconds,
      'total_study_time_minutes': totalStudyTimeMinutes,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_experience': totalExperience,
      'last_study_date': lastStudyDate?.toIso8601String(),
      'category_progress': categoryProgress,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Копирование с изменениями
  UserStatistics copyWith({
    String? id,
    int? totalCardsLearned,
    int? totalCardsReviewed,
    int? totalCorrectAnswers,
    int? totalIncorrectAnswers,
    int? totalStudyTimeSeconds,
    int? totalStudyTimeMinutes,
    int? currentStreak,
    int? longestStreak,
    int? totalExperience,
    DateTime? lastStudyDate,
    Map<String, int>? categoryProgress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserStatistics(
      id: id ?? this.id,
      totalCardsLearned: totalCardsLearned ?? this.totalCardsLearned,
      totalCardsReviewed: totalCardsReviewed ?? this.totalCardsReviewed,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalIncorrectAnswers: totalIncorrectAnswers ?? this.totalIncorrectAnswers,
      totalStudyTimeSeconds: totalStudyTimeSeconds ?? this.totalStudyTimeSeconds,
      totalStudyTimeMinutes: totalStudyTimeMinutes ?? this.totalStudyTimeMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalExperience: totalExperience ?? this.totalExperience,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Создание начальной статистики
  factory UserStatistics.initial({required String id}) {
    final now = DateTime.now();
    return UserStatistics(
      id: id,
      createdAt: now,
      updatedAt: now,
    );
  }
}
