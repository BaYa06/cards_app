import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../../models/user_statistics.dart';

/// DAO для работы со статистикой пользователя
class StatisticsDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Получить статистику пользователя
  Future<UserStatistics> getUserStatistics() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_statistics',
      where: 'id = ?',
      whereArgs: ['main'],
      limit: 1,
    );

    if (maps.isEmpty) {
      // Создаём запись если нет
      final now = DateTime.now();
      final stats = UserStatistics(
        id: 'main',
        createdAt: now,
        updatedAt: now,
      );
      await db.insert('user_statistics', _convertToDb(stats.toJson()));
      return stats;
    }

    // Загружаем прогресс по категориям отдельно
    final categoryProgress = await _getCategoryProgress();

    return UserStatistics.fromJson({
      ...maps.first,
      'category_progress': categoryProgress,
    });
  }

  /// Обновить статистику пользователя
  Future<void> updateStatistics(UserStatistics stats) async {
    final db = await _dbHelper.database;
    await db.update(
      'user_statistics',
      {
        ..._convertToDb(stats.toJson()),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: ['main'],
    );
  }

  /// Обновить после сессии обучения
  Future<void> updateAfterSession({
    required int cardsReviewed,
    required int correctAnswers,
    required int incorrectAnswers,
    required int studyTimeSeconds,
    required int experienceEarned,
    required int newLearnedCards,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();

    await db.rawUpdate('''
      UPDATE user_statistics SET
        total_cards_reviewed = total_cards_reviewed + ?,
        total_correct_answers = total_correct_answers + ?,
        total_incorrect_answers = total_incorrect_answers + ?,
        total_study_time_seconds = total_study_time_seconds + ?,
        total_experience = total_experience + ?,
        total_cards_learned = total_cards_learned + ?,
        last_study_date = ?,
        updated_at = ?
      WHERE id = 'main'
    ''', [
      cardsReviewed,
      correctAnswers,
      incorrectAnswers,
      studyTimeSeconds,
      experienceEarned,
      newLearnedCards,
      now.toIso8601String(),
      now.toIso8601String(),
    ]);

    // Обновляем streak
    await _updateStreak();

    // Обновляем дневную статистику
    await updateDailyStatistics(
      cardsReviewed: cardsReviewed,
      correctAnswers: correctAnswers,
      incorrectAnswers: incorrectAnswers,
      studyTimeSeconds: studyTimeSeconds,
      experienceEarned: experienceEarned,
      newLearnedCards: newLearnedCards,
    );
  }

  /// Обновить streak (серию дней)
  Future<void> _updateStreak() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Получаем текущую статистику
    final stats = await getUserStatistics();

    if (stats.lastStudyDate == null) {
      // Первый день обучения
      await db.rawUpdate('''
        UPDATE user_statistics SET
          current_streak = 1,
          longest_streak = CASE WHEN longest_streak < 1 THEN 1 ELSE longest_streak END
        WHERE id = 'main'
      ''');
    } else {
      final lastStudy = DateTime(
        stats.lastStudyDate!.year,
        stats.lastStudyDate!.month,
        stats.lastStudyDate!.day,
      );

      if (lastStudy == today) {
        // Уже занимались сегодня - ничего не меняем
        return;
      } else if (lastStudy == yesterday) {
        // Продолжаем streak
        final newStreak = stats.currentStreak + 1;
        await db.rawUpdate('''
          UPDATE user_statistics SET
            current_streak = ?,
            longest_streak = CASE WHEN longest_streak < ? THEN ? ELSE longest_streak END
          WHERE id = 'main'
        ''', [newStreak, newStreak, newStreak]);
      } else {
        // Streak сбрасывается
        await db.rawUpdate('''
          UPDATE user_statistics SET
            current_streak = 1
          WHERE id = 'main'
        ''');
      }
    }
  }

  /// Получить прогресс по категориям
  Future<Map<String, int>> _getCategoryProgress() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('category_progress');

    final result = <String, int>{};
    for (final map in maps) {
      result[map['category_id'] as String] = map['cards_learned'] as int;
    }
    return result;
  }

  /// Обновить прогресс по категории
  Future<void> updateCategoryProgress(String categoryId, int learnedCards) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    await db.insert(
      'category_progress',
      {
        'id': 'catprog_$categoryId',
        'category_id': categoryId,
        'cards_learned': learnedCards,
        'last_study_date': now,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ========== Ежедневная статистика ==========

  /// Получить статистику за день
  Future<Map<String, dynamic>?> getDailyStatistics(DateTime date) async {
    final db = await _dbHelper.database;
    final dateStr = _dateToString(date);

    final List<Map<String, dynamic>> maps = await db.query(
      'daily_statistics',
      where: 'date = ?',
      whereArgs: [dateStr],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return maps.first;
  }

  /// Обновить дневную статистику
  Future<void> updateDailyStatistics({
    required int cardsReviewed,
    required int correctAnswers,
    required int incorrectAnswers,
    required int studyTimeSeconds,
    required int experienceEarned,
    required int newLearnedCards,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final dateStr = _dateToString(now);

    final existing = await getDailyStatistics(now);

    if (existing == null) {
      // Создаём новую запись
      await db.insert('daily_statistics', {
        'id': 'daily_$dateStr',
        'date': dateStr,
        'cards_learned': newLearnedCards,
        'cards_reviewed': cardsReviewed,
        'correct_answers': correctAnswers,
        'incorrect_answers': incorrectAnswers,
        'study_time_seconds': studyTimeSeconds,
        'sessions_count': 1,
        'experience_earned': experienceEarned,
        'created_at': now.toIso8601String(),
      });
    } else {
      // Обновляем существующую
      await db.rawUpdate('''
        UPDATE daily_statistics SET
          cards_learned = cards_learned + ?,
          cards_reviewed = cards_reviewed + ?,
          correct_answers = correct_answers + ?,
          incorrect_answers = incorrect_answers + ?,
          study_time_seconds = study_time_seconds + ?,
          sessions_count = sessions_count + 1,
          experience_earned = experience_earned + ?
        WHERE date = ?
      ''', [
        newLearnedCards,
        cardsReviewed,
        correctAnswers,
        incorrectAnswers,
        studyTimeSeconds,
        experienceEarned,
        dateStr,
      ]);
    }
  }

  /// Получить статистику за последние N дней
  Future<List<Map<String, dynamic>>> getStatisticsForLastDays(int days) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days - 1));

    // Генерируем все даты
    final result = <Map<String, dynamic>>[];
    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final dateStr = _dateToString(date);

      final List<Map<String, dynamic>> maps = await db.query(
        'daily_statistics',
        where: 'date = ?',
        whereArgs: [dateStr],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        result.add({
          ...maps.first,
          'day_of_week': date.weekday,
        });
      } else {
        result.add({
          'date': dateStr,
          'cards_learned': 0,
          'cards_reviewed': 0,
          'correct_answers': 0,
          'incorrect_answers': 0,
          'study_time_seconds': 0,
          'sessions_count': 0,
          'experience_earned': 0,
          'day_of_week': date.weekday,
        });
      }
    }

    return result;
  }

  /// Получить статистику за текущую неделю
  Future<List<Map<String, dynamic>>> getWeeklyStatistics() async {
    return getStatisticsForLastDays(7);
  }

  /// Получить статистику за текущий месяц
  Future<List<Map<String, dynamic>>> getMonthlyStatistics() async {
    return getStatisticsForLastDays(30);
  }

  /// Конвертация даты в строку (YYYY-MM-DD)
  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Конвертация из JSON в БД формат
  Map<String, dynamic> _convertToDb(Map<String, dynamic> json) {
    final result = Map<String, dynamic>.from(json);
    result.remove('category_progress'); // Хранится отдельно
    return result;
  }
}
