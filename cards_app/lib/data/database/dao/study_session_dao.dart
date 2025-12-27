import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../../models/study_session.dart';

/// DAO для работы с сессиями обучения
class StudySessionDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Получить все сессии
  Future<List<StudySession>> getAllSessions() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> sessionMaps = await db.query(
      'study_sessions',
      orderBy: 'start_time DESC',
    );

    final sessions = <StudySession>[];
    for (final sessionMap in sessionMaps) {
      // Загружаем reviews для каждой сессии
      final reviews = await _getReviewsForSession(sessionMap['id'] as String);
      sessions.add(StudySession.fromJson({
        ..._convertToJson(sessionMap),
        'reviews': reviews.map((r) => r.toJson()).toList(),
      }));
    }

    return sessions;
  }

  /// Получить сессию по ID
  Future<StudySession?> getSessionById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_sessions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final reviews = await _getReviewsForSession(id);
    return StudySession.fromJson({
      ..._convertToJson(maps.first),
      'reviews': reviews.map((r) => r.toJson()).toList(),
    });
  }

  /// Получить сессии за период
  Future<List<StudySession>> getSessionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> sessionMaps = await db.query(
      'study_sessions',
      where: 'start_time >= ? AND start_time <= ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'start_time DESC',
    );

    final sessions = <StudySession>[];
    for (final sessionMap in sessionMaps) {
      final reviews = await _getReviewsForSession(sessionMap['id'] as String);
      sessions.add(StudySession.fromJson({
        ..._convertToJson(sessionMap),
        'reviews': reviews.map((r) => r.toJson()).toList(),
      }));
    }

    return sessions;
  }

  /// Получить сессии за сегодня
  Future<List<StudySession>> getTodaySessions() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return getSessionsByDateRange(startOfDay, endOfDay);
  }

  /// Создать новую сессию
  Future<StudySession> createSession({
    required String id,
    String? categoryId,
    required int totalCards,
    String sessionType = 'review',
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();

    final session = StudySession(
      id: id,
      categoryId: categoryId,
      startTime: now,
      totalCards: totalCards,
    );

    await db.insert('study_sessions', {
      ..._convertToDb(session.toJson()),
      'session_type': sessionType,
      'created_at': now.toIso8601String(),
    });

    return session;
  }

  /// Обновить сессию
  Future<void> updateSession(StudySession session) async {
    final db = await _dbHelper.database;
    
    final json = session.toJson();
    json.remove('reviews'); // Reviews хранятся отдельно
    
    await db.update(
      'study_sessions',
      _convertToDb(json),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  /// Завершить сессию
  Future<void> completeSession(String sessionId) async {
    final db = await _dbHelper.database;
    await db.update(
      'study_sessions',
      {
        'is_completed': 1,
        'end_time': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  /// Добавить review к сессии
  Future<void> addReview(CardReview review, String sessionId) async {
    final db = await _dbHelper.database;
    await db.insert('card_reviews', {
      'id': review.id,
      'session_id': sessionId,
      'card_id': review.cardId,
      'is_correct': review.isCorrect ? 1 : 0,
      'response_time_ms': review.responseTimeMs,
      'user_answer': review.userAnswer,
      'reviewed_at': review.reviewedAt.toIso8601String(),
    });

    // Обновляем счётчики в сессии
    final session = await getSessionById(sessionId);
    if (session != null) {
      await db.update(
        'study_sessions',
        {
          'cards_reviewed': session.cardsReviewed + 1,
          'correct_answers': session.correctAnswers + (review.isCorrect ? 1 : 0),
          'incorrect_answers': session.incorrectAnswers + (review.isCorrect ? 0 : 1),
        },
        where: 'id = ?',
        whereArgs: [sessionId],
      );
    }
  }

  /// Получить reviews для сессии
  Future<List<CardReview>> _getReviewsForSession(String sessionId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'card_reviews',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'reviewed_at ASC',
    );

    return List.generate(maps.length, (i) {
      return CardReview.fromJson({
        ...maps[i],
        'is_correct': maps[i]['is_correct'] == 1,
      });
    });
  }

  /// Удалить сессию
  Future<void> deleteSession(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'study_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Получить статистику за период
  Future<Map<String, dynamic>> getStatsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as sessions_count,
        SUM(cards_reviewed) as total_reviewed,
        SUM(correct_answers) as total_correct,
        SUM(incorrect_answers) as total_incorrect,
        SUM(
          CASE 
            WHEN end_time IS NOT NULL 
            THEN (julianday(end_time) - julianday(start_time)) * 24 * 60 * 60
            ELSE 0
          END
        ) as total_seconds
      FROM study_sessions
      WHERE start_time >= ? AND start_time <= ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isEmpty) {
      return {
        'sessions_count': 0,
        'total_reviewed': 0,
        'total_correct': 0,
        'total_incorrect': 0,
        'total_seconds': 0,
      };
    }

    return result.first;
  }

  /// Получить последнюю сессию
  Future<StudySession?> getLastSession() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_sessions',
      orderBy: 'start_time DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final reviews = await _getReviewsForSession(maps.first['id'] as String);
    return StudySession.fromJson({
      ..._convertToJson(maps.first),
      'reviews': reviews.map((r) => r.toJson()).toList(),
    });
  }

  /// Конвертация из БД формата в JSON
  Map<String, dynamic> _convertToJson(Map<String, dynamic> dbMap) {
    return {
      ...dbMap,
      'is_completed': dbMap['is_completed'] == 1,
    };
  }

  /// Конвертация из JSON в БД формат
  Map<String, dynamic> _convertToDb(Map<String, dynamic> json) {
    final result = Map<String, dynamic>.from(json);
    if (result.containsKey('is_completed')) {
      result['is_completed'] = result['is_completed'] == true ? 1 : 0;
    }
    result.remove('reviews'); // Reviews хранятся отдельно
    return result;
  }
}
