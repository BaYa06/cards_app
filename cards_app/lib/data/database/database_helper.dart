import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Хелпер для работы с SQLite базой данных
/// На Web платформе используется IndexedDB через sqflite_common_ffi_web
class DatabaseHelper {
  static const String _databaseName = 'deutsch_cards.db';
  static const int _databaseVersion = 1;

  // Singleton паттерн
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  /// Получение инстанса базы данных
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Инициализация базы данных
  Future<Database> _initDatabase() async {
    // На web sqflite не работает, поэтому пропускаем инициализацию
    if (kIsWeb) {
      throw UnsupportedError(
        'SQLite не поддерживается на Web. Используйте WebDatabaseHelper.',
      );
    }
    
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Настройка базы данных (включение внешних ключей)
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Создание таблиц
  Future<void> _onCreate(Database db, int version) async {
    // Таблица категорий
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        order_index INTEGER DEFAULT 0,
        is_premium INTEGER DEFAULT 0,
        is_custom INTEGER DEFAULT 0,
        cards_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Таблица карточек
    await db.execute('''
      CREATE TABLE flash_cards (
        id TEXT PRIMARY KEY,
        german_word TEXT NOT NULL,
        russian_translation TEXT NOT NULL,
        article TEXT,
        plural_form TEXT,
        example_sentence TEXT,
        example_translation TEXT,
        category_id TEXT NOT NULL,
        audio_url TEXT,
        image_url TEXT,
        difficulty_level INTEGER DEFAULT 1,
        part_of_speech TEXT NOT NULL,
        is_favorite INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Индекс для быстрого поиска по категории
    await db.execute('''
      CREATE INDEX idx_flash_cards_category ON flash_cards (category_id)
    ''');

    // Индекс для поиска слов
    await db.execute('''
      CREATE INDEX idx_flash_cards_word ON flash_cards (german_word)
    ''');

    // Таблица прогресса карточек
    await db.execute('''
      CREATE TABLE card_progress (
        id TEXT PRIMARY KEY,
        card_id TEXT NOT NULL UNIQUE,
        repetitions INTEGER DEFAULT 0,
        ease_factor REAL DEFAULT 2.5,
        interval INTEGER DEFAULT 0,
        last_review_date TEXT NOT NULL,
        next_review_date TEXT NOT NULL,
        correct_count INTEGER DEFAULT 0,
        incorrect_count INTEGER DEFAULT 0,
        is_learned INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (card_id) REFERENCES flash_cards (id) ON DELETE CASCADE
      )
    ''');

    // Индекс для поиска карточек для повторения
    await db.execute('''
      CREATE INDEX idx_card_progress_next_review ON card_progress (next_review_date)
    ''');

    // Таблица сессий обучения
    await db.execute('''
      CREATE TABLE study_sessions (
        id TEXT PRIMARY KEY,
        category_id TEXT,
        session_type TEXT DEFAULT 'review',
        start_time TEXT NOT NULL,
        end_time TEXT,
        total_cards INTEGER NOT NULL,
        cards_reviewed INTEGER DEFAULT 0,
        correct_answers INTEGER DEFAULT 0,
        incorrect_answers INTEGER DEFAULT 0,
        skipped_cards INTEGER DEFAULT 0,
        is_completed INTEGER DEFAULT 0,
        earned_experience INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');

    // Индекс для статистики по датам
    await db.execute('''
      CREATE INDEX idx_study_sessions_date ON study_sessions (start_time)
    ''');

    // Таблица отдельных ответов (reviews) в сессии
    await db.execute('''
      CREATE TABLE card_reviews (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        card_id TEXT NOT NULL,
        is_correct INTEGER NOT NULL,
        response_time_ms INTEGER NOT NULL,
        user_answer TEXT,
        reviewed_at TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES study_sessions (id) ON DELETE CASCADE,
        FOREIGN KEY (card_id) REFERENCES flash_cards (id) ON DELETE CASCADE
      )
    ''');

    // Таблица статистики пользователя
    await db.execute('''
      CREATE TABLE user_statistics (
        id TEXT PRIMARY KEY DEFAULT 'main',
        total_cards_learned INTEGER DEFAULT 0,
        total_cards_reviewed INTEGER DEFAULT 0,
        total_correct_answers INTEGER DEFAULT 0,
        total_incorrect_answers INTEGER DEFAULT 0,
        total_study_time_seconds INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        total_experience INTEGER DEFAULT 0,
        last_study_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Таблица ежедневной статистики (для графиков)
    await db.execute('''
      CREATE TABLE daily_statistics (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL UNIQUE,
        cards_learned INTEGER DEFAULT 0,
        cards_reviewed INTEGER DEFAULT 0,
        correct_answers INTEGER DEFAULT 0,
        incorrect_answers INTEGER DEFAULT 0,
        study_time_seconds INTEGER DEFAULT 0,
        sessions_count INTEGER DEFAULT 0,
        experience_earned INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Индекс для быстрого поиска по дате
    await db.execute('''
      CREATE INDEX idx_daily_statistics_date ON daily_statistics (date)
    ''');

    // Таблица прогресса по категориям
    await db.execute('''
      CREATE TABLE category_progress (
        id TEXT PRIMARY KEY,
        category_id TEXT NOT NULL UNIQUE,
        cards_learned INTEGER DEFAULT 0,
        cards_total INTEGER DEFAULT 0,
        last_study_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Таблица настроек приложения
    await db.execute('''
      CREATE TABLE app_settings (
        id TEXT PRIMARY KEY DEFAULT 'main',
        is_dark_mode INTEGER DEFAULT 0,
        language_code TEXT DEFAULT 'ru',
        cards_per_session INTEGER DEFAULT 10,
        sound_enabled INTEGER DEFAULT 1,
        vibration_enabled INTEGER DEFAULT 1,
        notifications_enabled INTEGER DEFAULT 1,
        reminder_time TEXT,
        show_examples INTEGER DEFAULT 1,
        auto_play_audio INTEGER DEFAULT 0,
        card_display_mode TEXT DEFAULT 'swipe',
        study_direction TEXT DEFAULT 'germanToRussian',
        daily_goal INTEGER DEFAULT 10,
        updated_at TEXT NOT NULL
      )
    ''');

    // Создаём начальную запись статистики
    final now = DateTime.now().toIso8601String();
    await db.insert('user_statistics', {
      'id': 'main',
      'created_at': now,
      'updated_at': now,
    });

    // Создаём начальные настройки
    await db.insert('app_settings', {
      'id': 'main',
      'updated_at': now,
    });

    // Добавляем начальные категории
    await _insertInitialCategories(db);
  }

  /// Миграции при обновлении версии
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Здесь будут миграции при обновлении версии БД
    // if (oldVersion < 2) { ... }
  }

  /// Добавление начальных категорий
  Future<void> _insertInitialCategories(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    final categories = [
      {
        'id': 'cat_basics',
        'name': 'Основы',
        'description': 'Базовые слова и выражения',
        'icon': 'school',
        'color': 0xFF2D65E6,
        'order_index': 0,
      },
      {
        'id': 'cat_food',
        'name': 'Еда и напитки',
        'description': 'Названия продуктов, блюд и напитков',
        'icon': 'food',
        'color': 0xFFEF4444,
        'order_index': 1,
      },
      {
        'id': 'cat_travel',
        'name': 'Путешествия',
        'description': 'Слова для путешествий и туризма',
        'icon': 'travel',
        'color': 0xFF10B981,
        'order_index': 2,
      },
      {
        'id': 'cat_family',
        'name': 'Семья',
        'description': 'Члены семьи и родственники',
        'icon': 'family',
        'color': 0xFFF59E0B,
        'order_index': 3,
      },
      {
        'id': 'cat_numbers',
        'name': 'Числа',
        'description': 'Числительные и счёт',
        'icon': 'numbers',
        'color': 0xFF8B5CF6,
        'order_index': 4,
      },
      {
        'id': 'cat_colors',
        'name': 'Цвета',
        'description': 'Названия цветов',
        'icon': 'colors',
        'color': 0xFFEC4899,
        'order_index': 5,
      },
      {
        'id': 'cat_animals',
        'name': 'Животные',
        'description': 'Домашние и дикие животные',
        'icon': 'animals',
        'color': 0xFF14B8A6,
        'order_index': 6,
      },
      {
        'id': 'cat_body',
        'name': 'Тело человека',
        'description': 'Части тела и здоровье',
        'icon': 'body',
        'color': 0xFFF97316,
        'order_index': 7,
      },
      {
        'id': 'cat_clothes',
        'name': 'Одежда',
        'description': 'Предметы одежды и аксессуары',
        'icon': 'clothes',
        'color': 0xFF6366F1,
        'order_index': 8,
      },
      {
        'id': 'cat_time',
        'name': 'Время',
        'description': 'Дни недели, месяцы, время',
        'icon': 'time',
        'color': 0xFF0EA5E9,
        'order_index': 9,
      },
      {
        'id': 'cat_verbs',
        'name': 'Глаголы',
        'description': 'Часто используемые глаголы',
        'icon': 'verbs',
        'color': 0xFF84CC16,
        'order_index': 10,
      },
      {
        'id': 'cat_adjectives',
        'name': 'Прилагательные',
        'description': 'Описательные слова',
        'icon': 'adjectives',
        'color': 0xFFD946EF,
        'order_index': 11,
      },
      {
        'id': 'cat_phrases',
        'name': 'Фразы',
        'description': 'Полезные фразы и выражения',
        'icon': 'phrases',
        'color': 0xFF22D3EE,
        'order_index': 12,
      },
    ];

    for (final category in categories) {
      await db.insert('categories', {
        ...category,
        'is_premium': 0,
        'is_custom': 0,
        'cards_count': 0,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  /// Закрытие базы данных
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Очистка всех данных
  Future<void> clearAll() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('card_reviews');
      await txn.delete('study_sessions');
      await txn.delete('card_progress');
      await txn.delete('flash_cards');
      await txn.delete('daily_statistics');
      await txn.delete('category_progress');
      
      // Сброс статистики
      final now = DateTime.now().toIso8601String();
      await txn.update('user_statistics', {
        'total_cards_learned': 0,
        'total_cards_reviewed': 0,
        'total_correct_answers': 0,
        'total_incorrect_answers': 0,
        'total_study_time_seconds': 0,
        'current_streak': 0,
        'total_experience': 0,
        'last_study_date': null,
        'updated_at': now,
      });
    });
  }

  /// Удаление базы данных
  Future<void> deleteDatabase() async {
    _initDatabaseFactory();
    
    String path;
    if (kIsWeb) {
      path = _databaseName;
    } else {
      final documentsDirectory = await getDatabasesPath();
      path = join(documentsDirectory, _databaseName);
    }
    
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  void _initDatabaseFactory() {
    // Для web платформа использует web databaseFactory, на остальных остается по умолчанию.
  }
}
