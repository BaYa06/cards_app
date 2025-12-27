import 'package:flutter/foundation.dart' show kIsWeb;
import '../database/database_helper.dart';
import '../database/web_database_helper.dart';
import '../database/dao/dao.dart';
import '../database/initial_data.dart';
import '../database/web_initial_data.dart';
import '../models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Главный репозиторий для работы с данными приложения
/// Автоматически выбирает способ хранения в зависимости от платформы
class AppRepository {
  static final AppRepository _instance = AppRepository._internal();
  factory AppRepository() => _instance;
  AppRepository._internal();

  // SQLite хелперы (для мобильных платформ)
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final CategoryDao _categoryDao = CategoryDao();
  final FlashCardDao _cardDao = FlashCardDao();
  final CardProgressDao _progressDao = CardProgressDao();
  final StudySessionDao _sessionDao = StudySessionDao();
  final StatisticsDao _statisticsDao = StatisticsDao();
  final SettingsDao _settingsDao = SettingsDao();

  // Web хелпер
  final WebDatabaseHelper _webDb = WebDatabaseHelper.instance;

  bool _isInitialized = false;

  /// Инициализация репозитория
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      // Для Web используем SharedPreferences + JSON
      await WebInitialDataLoader.loadInitialData();
    } else {
      // Для мобильных платформ используем SQLite
      await _dbHelper.database;

      // Проверяем, нужно ли загрузить начальные данные
      final prefs = await SharedPreferences.getInstance();
      final isFirstRun = prefs.getBool('is_first_run') ?? true;

      if (isFirstRun) {
        await _loadInitialData();
        await prefs.setBool('is_first_run', false);
      }
    }

    _isInitialized = true;
  }

  /// Загрузка начальных данных (для SQLite)
  Future<void> _loadInitialData() async {
    final loader = InitialDataLoader();
    await loader.loadAllData();
  }

  // ============ Категории ============

  /// Получить все категории
  Future<List<Category>> getCategories() async {
    if (kIsWeb) {
      return _webDb.getCategories();
    }
    return _categoryDao.getAllCategories();
  }

  /// Получить категорию по ID
  Future<Category?> getCategoryById(String id) async {
    if (kIsWeb) {
      return _webDb.getCategoryById(id);
    }
    return _categoryDao.getCategoryById(id);
  }

  /// Получить категории со статистикой
  Future<List<Map<String, dynamic>>> getCategoriesWithStats() async {
    if (kIsWeb) {
      final categories = await _webDb.getCategories();
      final cards = await _webDb.getFlashCards();
      
      return categories.map((cat) {
        final catCards = cards.where((c) => c.categoryId == cat.id).length;
        return {
          'category': cat,
          'cardsCount': catCards,
          'learnedCount': 0,
        };
      }).toList();
    }
    return _categoryDao.getCategoriesWithStats();
  }

  /// Создать пользовательскую категорию
  Future<void> createCategory(Category category) async {
    if (kIsWeb) {
      await _webDb.insertCategory(category);
      return;
    }
    await _categoryDao.insertCategory(category);
  }

  /// Обновить категорию
  Future<void> updateCategory(Category category) async {
    if (kIsWeb) {
      await _webDb.updateCategory(category);
      return;
    }
    await _categoryDao.updateCategory(category);
  }

  /// Удалить категорию
  Future<void> deleteCategory(String id) async {
    if (kIsWeb) {
      await _webDb.deleteCategory(id);
      return;
    }
    await _categoryDao.deleteCategory(id);
  }

  // ============ Карточки ============

  /// Получить все карточки
  Future<List<FlashCard>> getAllCards() async {
    if (kIsWeb) {
      return _webDb.getFlashCards();
    }
    return _cardDao.getAllCards();
  }

  /// Получить карточку по ID
  Future<FlashCard?> getCardById(String id) async {
    if (kIsWeb) {
      return _webDb.getFlashCardById(id);
    }
    return _cardDao.getCardById(id);
  }

  /// Получить карточки по категории
  Future<List<FlashCard>> getCardsByCategory(String categoryId) async {
    if (kIsWeb) {
      return _webDb.getFlashCardsByCategory(categoryId);
    }
    return _cardDao.getCardsByCategory(categoryId);
  }

  /// Поиск карточек
  Future<List<FlashCard>> searchCards(String query) async {
    if (kIsWeb) {
      return _webDb.searchFlashCards(query);
    }
    return _cardDao.searchCards(query);
  }

  /// Получить избранные карточки
  Future<List<FlashCard>> getFavoriteCards() async {
    if (kIsWeb) {
      return _webDb.getFavoriteCards();
    }
    return _cardDao.getFavoriteCards();
  }

  /// Получить карточки для изучения
  Future<List<FlashCard>> getCardsForStudy({
    String? categoryId,
    int limit = 10,
  }) async {
    if (kIsWeb) {
      return _webDb.getCardsForStudy(limit: limit);
    }
    return _cardDao.getCardsForStudy(categoryId: categoryId, limit: limit);
  }

  /// Получить слабые карточки
  Future<List<FlashCard>> getWeakCards({int limit = 20}) async {
    if (kIsWeb) {
      return _webDb.getCardsForStudy(limit: limit);
    }
    return _cardDao.getWeakCards(limit: limit);
  }

  /// Добавить карточку
  Future<void> addCard(FlashCard card) async {
    if (kIsWeb) {
      await _webDb.insertFlashCard(card);
      return;
    }
    await _cardDao.insertCard(card);
    await _categoryDao.updateCardsCount(card.categoryId);
  }

  /// Добавить несколько карточек
  Future<void> addCards(List<FlashCard> cards) async {
    if (kIsWeb) {
      for (final card in cards) {
        await _webDb.insertFlashCard(card);
      }
      return;
    }
    await _cardDao.insertCards(cards);
    final categoryIds = cards.map((c) => c.categoryId).toSet();
    for (final categoryId in categoryIds) {
      await _categoryDao.updateCardsCount(categoryId);
    }
  }

  /// Обновить карточку
  Future<void> updateCard(FlashCard card) async {
    if (kIsWeb) {
      await _webDb.updateFlashCard(card);
      return;
    }
    await _cardDao.updateCard(card);
  }

  /// Переключить избранное
  Future<void> toggleFavorite(String cardId, bool isFavorite) async {
    if (kIsWeb) {
      await _webDb.toggleFavorite(cardId);
      return;
    }
    await _cardDao.toggleFavorite(cardId, isFavorite);
  }

  /// Удалить карточку
  Future<void> deleteCard(String id, String categoryId) async {
    if (kIsWeb) {
      await _webDb.deleteFlashCard(id);
      return;
    }
    await _cardDao.deleteCard(id);
    await _categoryDao.updateCardsCount(categoryId);
  }

  /// Получить количество карточек
  Future<int> getCardsCount() async {
    if (kIsWeb) {
      final cards = await _webDb.getFlashCards();
      return cards.length;
    }
    return _cardDao.getCardsCount();
  }

  // ============ Прогресс ============

  /// Получить прогресс по карточке
  Future<CardProgress?> getCardProgress(String cardId) async {
    if (kIsWeb) {
      return _webDb.getCardProgress(cardId);
    }
    return _progressDao.getProgressByCardId(cardId);
  }

  /// Получить карточки для повторения
  Future<List<CardProgress>> getDueCards() async {
    if (kIsWeb) {
      final list = await _webDb.getCardProgressList();
      final now = DateTime.now();
      return list.where((p) => p.nextReviewDate.isBefore(now)).toList();
    }
    return _progressDao.getDueForReview();
  }

  /// Обновить прогресс после ответа
  Future<CardProgress> recordAnswer({
    required String cardId,
    required bool isCorrect,
    required int quality,
  }) async {
    if (kIsWeb) {
      var progress = await _webDb.getCardProgress(cardId);
      final now = DateTime.now();
      
      if (progress == null) {
        progress = CardProgress(
          id: cardId,
          cardId: cardId,
          easeFactor: 2.5,
          interval: 1,
          repetitions: 0,
          nextReviewDate: now,
          lastReviewDate: now,
          createdAt: now,
          updatedAt: now,
          status: CardStatus.learning,
        );
      }
      
      int newInterval = progress.interval;
      double newEaseFactor = progress.easeFactor;
      
      if (isCorrect) {
        newInterval = (progress.interval * progress.easeFactor).round();
        if (newInterval < 1) newInterval = 1;
      } else {
        newInterval = 1;
        newEaseFactor = progress.easeFactor - 0.2;
        if (newEaseFactor < 1.3) newEaseFactor = 1.3;
      }
      
      final newProgress = CardProgress(
        id: progress.id,
        cardId: cardId,
        easeFactor: newEaseFactor,
        interval: newInterval,
        repetitions: progress.repetitions + 1,
        nextReviewDate: now.add(Duration(days: newInterval)),
        lastReviewDate: now,
        createdAt: progress.createdAt,
        updatedAt: now,
        status: newInterval > 21 ? CardStatus.mastered : 
                newInterval > 7 ? CardStatus.reviewing : CardStatus.learning,
      );
      
      await _webDb.upsertCardProgress(newProgress);
      return newProgress;
    }
    return _progressDao.updateProgressAfterReview(
      cardId: cardId,
      isCorrect: isCorrect,
      quality: quality,
    );
  }

  /// Получить статистику прогресса
  Future<Map<String, dynamic>> getProgressStats() async {
    if (kIsWeb) {
      final cards = await _webDb.getFlashCards();
      final progress = await _webDb.getCardProgressList();
      
      final learned = progress.where((p) => 
        p.status == CardStatus.mastered || p.status == CardStatus.reviewing
      ).length;
      
      return {
        'total': cards.length,
        'learned': learned,
        'learning': progress.where((p) => p.status == CardStatus.learning).length,
        'new': cards.length - progress.length,
      };
    }
    return _progressDao.getProgressStats();
  }

  /// Количество выученных карточек
  Future<int> getLearnedCount() async {
    if (kIsWeb) {
      final progress = await _webDb.getCardProgressList();
      return progress.where((p) => 
        p.status == CardStatus.mastered || p.status == CardStatus.reviewing
      ).length;
    }
    return _progressDao.getLearnedCount();
  }

  /// Количество карточек для повторения сегодня
  Future<int> getDueCount() async {
    if (kIsWeb) {
      final progress = await _webDb.getCardProgressList();
      final now = DateTime.now();
      return progress.where((p) => p.nextReviewDate.isBefore(now)).length;
    }
    return _progressDao.getDueCount();
  }

  // ============ Сессии ============

  /// Создать сессию обучения
  Future<StudySession> startSession({
    required String id,
    String? categoryId,
    required int totalCards,
  }) async {
    if (kIsWeb) {
      final session = StudySession(
        id: id,
        startTime: DateTime.now(),
        cardsReviewed: 0,
        correctAnswers: 0,
        incorrectAnswers: 0,
        categoryId: categoryId,
        totalCards: totalCards,
      );
      await _webDb.insertStudySession(session);
      return session;
    }
    return _sessionDao.createSession(
      id: id,
      categoryId: categoryId,
      totalCards: totalCards,
    );
  }

  /// Завершить сессию
  Future<void> completeSession(String sessionId) async {
    if (kIsWeb) return;
    await _sessionDao.completeSession(sessionId);
  }

  /// Добавить ответ в сессию
  Future<void> addReviewToSession(CardReview review, String sessionId) async {
    if (kIsWeb) return;
    await _sessionDao.addReview(review, sessionId);
  }

  /// Получить сессии за сегодня
  Future<List<StudySession>> getTodaySessions() async {
    if (kIsWeb) {
      final sessions = await _webDb.getStudySessions();
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      return sessions
        .where((s) {
          final start = DateTime.parse(s['startTime'] as String);
          return start.isAfter(todayStart);
        })
        .map((s) => StudySession(
          id: s['id'].toString(),
          startTime: DateTime.parse(s['startTime'] as String),
          endTime: s['endTime'] != null ? DateTime.parse(s['endTime'] as String) : null,
          totalCards: s['totalCards'] as int? ?? 0,
          cardsReviewed: s['cardsStudied'] as int? ?? 0,
          correctAnswers: s['correctAnswers'] as int? ?? 0,
          incorrectAnswers: s['wrongAnswers'] as int? ?? 0,
          categoryId: s['categoryId']?.toString(),
        ))
        .toList();
    }
    return _sessionDao.getTodaySessions();
  }

  /// Получить последнюю сессию
  Future<StudySession?> getLastSession() async {
    if (kIsWeb) {
      final sessions = await _webDb.getStudySessions();
      if (sessions.isEmpty) return null;
      
      sessions.sort((a, b) => 
        DateTime.parse(b['startTime'] as String)
          .compareTo(DateTime.parse(a['startTime'] as String))
      );
      
      final s = sessions.first;
      return StudySession(
        id: s['id'].toString(),
        startTime: DateTime.parse(s['startTime'] as String),
        endTime: s['endTime'] != null ? DateTime.parse(s['endTime'] as String) : null,
        totalCards: s['totalCards'] as int? ?? 0,
        cardsReviewed: s['cardsStudied'] as int? ?? 0,
        correctAnswers: s['correctAnswers'] as int? ?? 0,
        incorrectAnswers: s['wrongAnswers'] as int? ?? 0,
        categoryId: s['categoryId']?.toString(),
      );
    }
    return _sessionDao.getLastSession();
  }

  // ============ Статистика ============

  /// Получить статистику пользователя
  Future<UserStatistics> getUserStatistics() async {
    if (kIsWeb) {
      var stats = await _webDb.getUserStatistics();
      if (stats == null) {
        stats = UserStatistics.initial(id: '1');
        await _webDb.saveUserStatistics(stats);
      }
      return stats;
    }
    return _statisticsDao.getUserStatistics();
  }

  /// Обновить статистику после сессии
  Future<void> updateStatisticsAfterSession({
    required int cardsReviewed,
    required int correctAnswers,
    required int incorrectAnswers,
    required int studyTimeSeconds,
    required int experienceEarned,
    required int newLearnedCards,
  }) async {
    if (kIsWeb) {
      await _webDb.updateStatisticsAfterReview(
        isCorrect: correctAnswers > incorrectAnswers,
        studyTimeSeconds: studyTimeSeconds,
      );
      return;
    }
    await _statisticsDao.updateAfterSession(
      cardsReviewed: cardsReviewed,
      correctAnswers: correctAnswers,
      incorrectAnswers: incorrectAnswers,
      studyTimeSeconds: studyTimeSeconds,
      experienceEarned: experienceEarned,
      newLearnedCards: newLearnedCards,
    );
  }

  /// Получить статистику за неделю
  Future<List<Map<String, dynamic>>> getWeeklyStatistics() async {
    if (kIsWeb) return [];
    return _statisticsDao.getWeeklyStatistics();
  }

  /// Получить статистику за месяц
  Future<List<Map<String, dynamic>>> getMonthlyStatistics() async {
    if (kIsWeb) return [];
    return _statisticsDao.getMonthlyStatistics();
  }

  // ============ Настройки ============

  /// Получить настройки
  Future<AppSettings> getSettings() async {
    if (kIsWeb) {
      return _webDb.getAppSettings();
    }
    return _settingsDao.getSettings();
  }

  /// Сохранить настройки
  Future<void> saveSettings(AppSettings settings) async {
    if (kIsWeb) {
      await _webDb.saveAppSettings(settings);
      return;
    }
    await _settingsDao.saveSettings(settings);
  }

  /// Получить дневную цель
  Future<int> getDailyGoal() async {
    if (kIsWeb) {
      final settings = await _webDb.getAppSettings();
      return settings.dailyGoal;
    }
    return _settingsDao.getDailyGoal();
  }

  /// Установить дневную цель
  Future<void> setDailyGoal(int goal) async {
    if (kIsWeb) {
      final settings = await _webDb.getAppSettings();
      await _webDb.saveAppSettings(settings.copyWith(dailyGoal: goal));
      return;
    }
    await _settingsDao.setDailyGoal(goal);
  }

  /// Тёмная тема
  Future<bool> isDarkMode() async {
    if (kIsWeb) {
      final settings = await _webDb.getAppSettings();
      return settings.isDarkMode;
    }
    return _settingsDao.isDarkMode();
  }

  /// Установить тему
  Future<void> setDarkMode(bool isDark) async {
    if (kIsWeb) {
      final settings = await _webDb.getAppSettings();
      await _webDb.saveAppSettings(settings.copyWith(isDarkMode: isDark));
      return;
    }
    await _settingsDao.setDarkMode(isDark);
  }

  // ============ Общие методы ============

  /// Очистить все данные
  Future<void> clearAllData() async {
    if (kIsWeb) {
      await _webDb.clearAllData();
      return;
    }
    await _dbHelper.clearAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_run', true);
  }

  /// Удалить базу и пересоздать
  Future<void> resetDatabase() async {
    if (kIsWeb) {
      await _webDb.clearAllData();
      _isInitialized = false;
      await initialize();
      return;
    }
    await _dbHelper.deleteDatabase();
    _isInitialized = false;
    await initialize();
  }

  /// Закрыть соединение
  Future<void> close() async {
    if (!kIsWeb) {
      await _dbHelper.close();
    }
    _isInitialized = false;
  }
}
