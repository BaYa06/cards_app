import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../../models/app_settings.dart';

/// DAO для работы с настройками приложения
class SettingsDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Получить настройки
  Future<AppSettings> getSettings() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_settings',
      where: 'id = ?',
      whereArgs: ['main'],
      limit: 1,
    );

    if (maps.isEmpty) {
      // Создаём настройки по умолчанию
      const settings = AppSettings();
      await saveSettings(settings);
      return settings;
    }

    return AppSettings.fromJson(_convertToJson(maps.first));
  }

  /// Сохранить настройки
  Future<void> saveSettings(AppSettings settings) async {
    final db = await _dbHelper.database;
    await db.insert(
      'app_settings',
      {
        ..._convertToDb(settings.toJson()),
        'id': 'main',
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Обновить отдельную настройку
  Future<void> updateSetting(String key, dynamic value) async {
    final db = await _dbHelper.database;
    
    dynamic dbValue = value;
    if (value is bool) {
      dbValue = value ? 1 : 0;
    }

    await db.update(
      'app_settings',
      {
        key: dbValue,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: ['main'],
    );
  }

  /// Получить дневную цель
  Future<int> getDailyGoal() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_settings',
      columns: ['daily_goal'],
      where: 'id = ?',
      whereArgs: ['main'],
      limit: 1,
    );

    if (maps.isEmpty) return 10;
    return maps.first['daily_goal'] as int? ?? 10;
  }

  /// Установить дневную цель
  Future<void> setDailyGoal(int goal) async {
    await updateSetting('daily_goal', goal);
  }

  /// Получить тему (тёмная/светлая)
  Future<bool> isDarkMode() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_settings',
      columns: ['is_dark_mode'],
      where: 'id = ?',
      whereArgs: ['main'],
      limit: 1,
    );

    if (maps.isEmpty) return false;
    return maps.first['is_dark_mode'] == 1;
  }

  /// Установить тему
  Future<void> setDarkMode(bool isDark) async {
    await updateSetting('is_dark_mode', isDark);
  }

  /// Сбросить настройки
  Future<void> resetSettings() async {
    const settings = AppSettings();
    await saveSettings(settings);
  }

  /// Конвертация из БД формата в JSON
  Map<String, dynamic> _convertToJson(Map<String, dynamic> dbMap) {
    return {
      ...dbMap,
      'is_dark_mode': dbMap['is_dark_mode'] == 1,
      'sound_enabled': dbMap['sound_enabled'] == 1,
      'vibration_enabled': dbMap['vibration_enabled'] == 1,
      'notifications_enabled': dbMap['notifications_enabled'] == 1,
      'show_examples': dbMap['show_examples'] == 1,
      'auto_play_audio': dbMap['auto_play_audio'] == 1,
    };
  }

  /// Конвертация из JSON в БД формат
  Map<String, dynamic> _convertToDb(Map<String, dynamic> json) {
    final result = Map<String, dynamic>.from(json);
    
    final boolKeys = [
      'is_dark_mode',
      'sound_enabled',
      'vibration_enabled',
      'notifications_enabled',
      'show_examples',
      'auto_play_audio',
    ];

    for (final key in boolKeys) {
      if (result.containsKey(key)) {
        result[key] = result[key] == true ? 1 : 0;
      }
    }

    return result;
  }
}
