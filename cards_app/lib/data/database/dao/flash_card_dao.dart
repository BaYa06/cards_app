import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../../models/flash_card.dart';

/// DAO для работы с карточками
class FlashCardDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Получить все карточки
  Future<List<FlashCard>> getAllCards() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('flash_cards');

    return List.generate(maps.length, (i) {
      return FlashCard.fromJson(_convertToJson(maps[i]));
    });
  }

  /// Получить карточку по ID
  Future<FlashCard?> getCardById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'flash_cards',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return FlashCard.fromJson(_convertToJson(maps.first));
  }

  /// Получить карточки по категории
  Future<List<FlashCard>> getCardsByCategory(String categoryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'flash_cards',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return FlashCard.fromJson(_convertToJson(maps[i]));
    });
  }

  /// Поиск карточек
  Future<List<FlashCard>> searchCards(String query) async {
    final db = await _dbHelper.database;
    final searchQuery = '%$query%';
    final List<Map<String, dynamic>> maps = await db.query(
      'flash_cards',
      where: 'german_word LIKE ? OR russian_translation LIKE ?',
      whereArgs: [searchQuery, searchQuery],
      orderBy: 'german_word ASC',
    );

    return List.generate(maps.length, (i) {
      return FlashCard.fromJson(_convertToJson(maps[i]));
    });
  }

  /// Получить избранные карточки
  Future<List<FlashCard>> getFavoriteCards() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'flash_cards',
      where: 'is_favorite = 1',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return FlashCard.fromJson(_convertToJson(maps[i]));
    });
  }

  /// Добавить карточку
  Future<void> insertCard(FlashCard card) async {
    final db = await _dbHelper.database;
    await db.insert(
      'flash_cards',
      _convertToDb(card.toJson()),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Добавить несколько карточек (batch insert)
  Future<void> insertCards(List<FlashCard> cards) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (final card in cards) {
      batch.insert(
        'flash_cards',
        _convertToDb(card.toJson()),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Обновить карточку
  Future<void> updateCard(FlashCard card) async {
    final db = await _dbHelper.database;
    await db.update(
      'flash_cards',
      _convertToDb({
        ...card.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      }),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  /// Установить/снять избранное
  Future<void> toggleFavorite(String cardId, bool isFavorite) async {
    final db = await _dbHelper.database;
    await db.update(
      'flash_cards',
      {
        'is_favorite': isFavorite ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [cardId],
    );
  }

  /// Удалить карточку
  Future<void> deleteCard(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'flash_cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Удалить все карточки категории
  Future<void> deleteCardsByCategory(String categoryId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'flash_cards',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }

  /// Получить количество карточек
  Future<int> getCardsCount() async {
    final db = await _dbHelper.database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM flash_cards'),
    ) ?? 0;
  }

  /// Получить количество карточек в категории
  Future<int> getCardsCountByCategory(String categoryId) async {
    final db = await _dbHelper.database;
    return Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM flash_cards WHERE category_id = ?',
        [categoryId],
      ),
    ) ?? 0;
  }

  /// Получить карточки для изучения (новые или требующие повторения)
  Future<List<FlashCard>> getCardsForStudy({
    String? categoryId,
    int limit = 10,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    String query = '''
      SELECT f.* FROM flash_cards f
      LEFT JOIN card_progress p ON f.id = p.card_id
      WHERE (p.id IS NULL OR p.next_review_date <= ?)
    ''';

    List<dynamic> args = [now];

    if (categoryId != null) {
      query += ' AND f.category_id = ?';
      args.add(categoryId);
    }

    query += '''
      ORDER BY 
        CASE WHEN p.id IS NULL THEN 0 ELSE 1 END,
        p.next_review_date ASC
      LIMIT ?
    ''';
    args.add(limit);

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, args);

    return List.generate(maps.length, (i) {
      return FlashCard.fromJson(_convertToJson(maps[i]));
    });
  }

  /// Получить слабые карточки (низкая точность ответов)
  Future<List<FlashCard>> getWeakCards({int limit = 20}) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT f.* FROM flash_cards f
      INNER JOIN card_progress p ON f.id = p.card_id
      WHERE (p.correct_count + p.incorrect_count) > 0
      ORDER BY 
        CAST(p.correct_count AS REAL) / (p.correct_count + p.incorrect_count) ASC
      LIMIT ?
    ''', [limit]);

    return List.generate(maps.length, (i) {
      return FlashCard.fromJson(_convertToJson(maps[i]));
    });
  }

  /// Конвертация из БД формата в JSON
  Map<String, dynamic> _convertToJson(Map<String, dynamic> dbMap) {
    return {
      ...dbMap,
      'is_favorite': dbMap['is_favorite'] == 1,
    };
  }

  /// Конвертация из JSON в БД формат
  Map<String, dynamic> _convertToDb(Map<String, dynamic> json) {
    final result = Map<String, dynamic>.from(json);
    if (result.containsKey('is_favorite')) {
      result['is_favorite'] = result['is_favorite'] == true ? 1 : 0;
    }
    // Добавляем updated_at если нет
    if (!result.containsKey('updated_at')) {
      result['updated_at'] = DateTime.now().toIso8601String();
    }
    return result;
  }
}
