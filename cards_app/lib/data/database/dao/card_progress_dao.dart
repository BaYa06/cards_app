import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../../models/card_progress.dart';

/// DAO для работы с прогрессом изучения карточек
class CardProgressDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Получить прогресс по карточке
  Future<CardProgress?> getProgressByCardId(String cardId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'card_progress',
      where: 'card_id = ?',
      whereArgs: [cardId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return CardProgress.fromJson(_convertToJson(maps.first));
  }

  /// Получить весь прогресс
  Future<List<CardProgress>> getAllProgress() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('card_progress');

    return List.generate(maps.length, (i) {
      return CardProgress.fromJson(_convertToJson(maps[i]));
    });
  }

  /// Получить карточки для повторения сегодня
  Future<List<CardProgress>> getDueForReview() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'card_progress',
      where: 'next_review_date <= ?',
      whereArgs: [today],
      orderBy: 'next_review_date ASC',
    );

    return List.generate(maps.length, (i) {
      return CardProgress.fromJson(_convertToJson(maps[i]));
    });
  }

  /// Получить выученные карточки
  Future<List<CardProgress>> getLearnedCards() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'card_progress',
      where: 'is_learned = 1',
    );

    return List.generate(maps.length, (i) {
      return CardProgress.fromJson(_convertToJson(maps[i]));
    });
  }

  /// Добавить или обновить прогресс
  Future<void> upsertProgress(CardProgress progress) async {
    final db = await _dbHelper.database;
    await db.insert(
      'card_progress',
      _convertToDb(progress.toJson()),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Обновить прогресс после ответа (SM-2 алгоритм)
  Future<CardProgress> updateProgressAfterReview({
    required String cardId,
    required bool isCorrect,
    required int quality, // 0-5, где 5 - идеально
  }) async {
    final existing = await getProgressByCardId(cardId);
    final now = DateTime.now();

    CardProgress newProgress;

    if (existing == null) {
      // Создаём новый прогресс
      newProgress = _calculateInitialProgress(cardId, isCorrect, quality, now);
    } else {
      // Обновляем существующий по SM-2
      newProgress = _calculateSM2Progress(existing, isCorrect, quality, now);
    }

    await upsertProgress(newProgress);
    return newProgress;
  }

  /// Расчёт начального прогресса
  CardProgress _calculateInitialProgress(
    String cardId,
    bool isCorrect,
    int quality,
    DateTime now,
  ) {
    final interval = isCorrect ? 1 : 0;
    final nextReview = now.add(Duration(days: interval));

    return CardProgress(
      id: 'prog_${cardId}_${now.millisecondsSinceEpoch}',
      cardId: cardId,
      repetitions: isCorrect ? 1 : 0,
      easeFactor: 2.5,
      interval: interval,
      lastReviewDate: now,
      nextReviewDate: nextReview,
      correctCount: isCorrect ? 1 : 0,
      incorrectCount: isCorrect ? 0 : 1,
      isLearned: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Расчёт прогресса по алгоритму SM-2
  CardProgress _calculateSM2Progress(
    CardProgress existing,
    bool isCorrect,
    int quality,
    DateTime now,
  ) {
    int repetitions = existing.repetitions;
    double easeFactor = existing.easeFactor;
    int interval = existing.interval;

    if (quality >= 3) {
      // Правильный ответ
      if (repetitions == 0) {
        interval = 1;
      } else if (repetitions == 1) {
        interval = 6;
      } else {
        interval = (interval * easeFactor).round();
      }
      repetitions++;
    } else {
      // Неправильный ответ - сброс
      repetitions = 0;
      interval = 0;
    }

    // Обновление ease factor
    easeFactor = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (easeFactor < 1.3) easeFactor = 1.3;

    final nextReview = now.add(Duration(days: interval));
    
    // Считается выученной после 5 успешных повторений с интервалом > 21 день
    final isLearned = repetitions >= 5 && interval >= 21;

    return existing.copyWith(
      repetitions: repetitions,
      easeFactor: easeFactor,
      interval: interval,
      lastReviewDate: now,
      nextReviewDate: nextReview,
      correctCount: existing.correctCount + (isCorrect ? 1 : 0),
      incorrectCount: existing.incorrectCount + (isCorrect ? 0 : 1),
      isLearned: isLearned,
      updatedAt: now,
    );
  }

  /// Удалить прогресс
  Future<void> deleteProgress(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'card_progress',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Удалить прогресс по карточке
  Future<void> deleteProgressByCardId(String cardId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'card_progress',
      where: 'card_id = ?',
      whereArgs: [cardId],
    );
  }

  /// Получить количество выученных карточек
  Future<int> getLearnedCount() async {
    final db = await _dbHelper.database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM card_progress WHERE is_learned = 1'),
    ) ?? 0;
  }

  /// Получить количество карточек для повторения сегодня
  Future<int> getDueCount() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    return Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM card_progress WHERE next_review_date <= ?',
        [today],
      ),
    ) ?? 0;
  }

  /// Получить общую статистику по прогрессу
  Future<Map<String, dynamic>> getProgressStats() async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_studied,
        SUM(CASE WHEN is_learned = 1 THEN 1 ELSE 0 END) as learned,
        SUM(correct_count) as total_correct,
        SUM(incorrect_count) as total_incorrect,
        AVG(ease_factor) as avg_ease_factor
      FROM card_progress
    ''');

    if (result.isEmpty) {
      return {
        'total_studied': 0,
        'learned': 0,
        'total_correct': 0,
        'total_incorrect': 0,
        'avg_ease_factor': 2.5,
      };
    }

    return result.first;
  }

  /// Конвертация из БД формата в JSON
  Map<String, dynamic> _convertToJson(Map<String, dynamic> dbMap) {
    return {
      ...dbMap,
      'is_learned': dbMap['is_learned'] == 1,
    };
  }

  /// Конвертация из JSON в БД формат
  Map<String, dynamic> _convertToDb(Map<String, dynamic> json) {
    final result = Map<String, dynamic>.from(json);
    if (result.containsKey('is_learned')) {
      result['is_learned'] = result['is_learned'] == true ? 1 : 0;
    }
    return result;
  }
}
