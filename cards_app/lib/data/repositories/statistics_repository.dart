import '../models/user_statistics.dart';
import '../models/study_session.dart';

/// Абстрактный репозиторий для работы со статистикой
abstract class StatisticsRepository {
  /// Получить статистику пользователя
  Future<UserStatistics> getUserStatistics();

  /// Обновить статистику после сессии
  Future<void> updateStatisticsAfterSession(StudySession session);

  /// Обновить серию (streak)
  Future<void> updateStreak();

  /// Сбросить статистику
  Future<void> resetStatistics();

  /// Получить историю сессий
  Future<List<StudySession>> getSessionHistory({
    int limit = 30,
    DateTime? fromDate,
  });

  /// Сохранить сессию
  Future<void> saveSession(StudySession session);

  /// Получить статистику по дням
  Future<Map<DateTime, DailyStatistics>> getDailyStatistics({
    required DateTime fromDate,
    required DateTime toDate,
  });
}

/// Модель дневной статистики
class DailyStatistics {
  final DateTime date;
  final int cardsReviewed;
  final int correctAnswers;
  final int studyTimeSeconds;
  final int sessionsCount;

  const DailyStatistics({
    required this.date,
    required this.cardsReviewed,
    required this.correctAnswers,
    required this.studyTimeSeconds,
    required this.sessionsCount,
  });

  double get accuracy {
    if (cardsReviewed == 0) return 0.0;
    return correctAnswers / cardsReviewed;
  }
}
