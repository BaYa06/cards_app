import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../../models/category.dart';

/// DAO для работы с категориями
class CategoryDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Получить все категории
  Future<List<Category>> getAllCategories() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      orderBy: 'order_index ASC',
    );

    return List.generate(maps.length, (i) {
      return Category.fromJson(_convertToJson(maps[i]));
    });
  }

  /// Получить категорию по ID
  Future<Category?> getCategoryById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Category.fromJson(_convertToJson(maps.first));
  }

  /// Добавить категорию
  Future<void> insertCategory(Category category) async {
    final db = await _dbHelper.database;
    await db.insert(
      'categories',
      _convertToDb(category.toJson()),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Обновить категорию
  Future<void> updateCategory(Category category) async {
    final db = await _dbHelper.database;
    await db.update(
      'categories',
      _convertToDb({
        ...category.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      }),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Удалить категорию
  Future<void> deleteCategory(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Обновить количество карточек в категории
  Future<void> updateCardsCount(String categoryId) async {
    final db = await _dbHelper.database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM flash_cards WHERE category_id = ?',
      [categoryId],
    )) ?? 0;

    await db.update(
      'categories',
      {
        'cards_count': count,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }

  /// Получить категории с количеством карточек
  Future<List<Map<String, dynamic>>> getCategoriesWithStats() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT 
        c.*,
        COALESCE(cp.cards_learned, 0) as learned_count,
        (SELECT COUNT(*) FROM flash_cards WHERE category_id = c.id) as total_count
      FROM categories c
      LEFT JOIN category_progress cp ON c.id = cp.category_id
      ORDER BY c.order_index ASC
    ''');
  }

  /// Конвертация из БД формата в JSON
  Map<String, dynamic> _convertToJson(Map<String, dynamic> dbMap) {
    return {
      ...dbMap,
      'is_premium': dbMap['is_premium'] == 1,
    };
  }

  /// Конвертация из JSON в БД формат
  Map<String, dynamic> _convertToDb(Map<String, dynamic> json) {
    final result = Map<String, dynamic>.from(json);
    if (result.containsKey('is_premium')) {
      result['is_premium'] = result['is_premium'] == true ? 1 : 0;
    }
    return result;
  }
}
