import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flash_card.dart';
import '../models/category.dart';
import '../models/card_progress.dart';
import '../models/study_session.dart';
import '../models/user_statistics.dart';
import '../models/app_settings.dart';

/// Хелпер для хранения данных на Web платформе через SharedPreferences
/// Использует JSON сериализацию для сложных объектов
class WebDatabaseHelper {
  // Singleton паттерн
  WebDatabaseHelper._internal();
  static final WebDatabaseHelper instance = WebDatabaseHelper._internal();

  static SharedPreferences? _prefs;

  // Ключи для хранения
  static const String _categoriesKey = 'categories';
  static const String _flashCardsKey = 'flash_cards';
  static const String _cardProgressKey = 'card_progress';
  static const String _studySessionsKey = 'study_sessions';
  static const String _cardReviewsKey = 'card_reviews';
  static const String _userStatisticsKey = 'user_statistics';
  static const String _dailyStatisticsKey = 'daily_statistics';
  static const String _categoryProgressKey = 'category_progress';
  static const String _appSettingsKey = 'app_settings';
  static const String _isInitializedKey = 'db_initialized';

  /// Получение SharedPreferences
  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Проверка, инициализирована ли база
  Future<bool> get isInitialized async {
    final p = await prefs;
    return p.getBool(_isInitializedKey) ?? false;
  }

  /// Установка флага инициализации
  Future<void> setInitialized(bool value) async {
    final p = await prefs;
    await p.setBool(_isInitializedKey, value);
  }

  // ==================== Categories ====================

  Future<List<Category>> getCategories() async {
    final p = await prefs;
    final json = p.getString(_categoriesKey);
    if (json == null) return [];
    
    final List<dynamic> list = jsonDecode(json);
    return list.map((e) => Category.fromJson(e)).toList();
  }

  Future<void> saveCategories(List<Category> categories) async {
    final p = await prefs;
    final json = jsonEncode(categories.map((e) => e.toJson()).toList());
    await p.setString(_categoriesKey, json);
  }

  Future<Category?> getCategoryById(dynamic id) async {
    final categories = await getCategories();
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<int> insertCategory(Category category) async {
    final categories = await getCategories();
    final newId = categories.isEmpty
        ? 1
        : categories
                .map((c) => int.tryParse(c.id.toString()) ?? 0)
                .reduce((a, b) => a > b ? a : b) +
            1;
    final newCategory = category.copyWith(id: newId.toString());
    categories.add(newCategory);
    await saveCategories(categories);
    return newId;
  }

  Future<void> updateCategory(Category category) async {
    final categories = await getCategories();
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
      await saveCategories(categories);
    }
  }

  Future<void> deleteCategory(dynamic id) async {
    final categories = await getCategories();
    categories.removeWhere((c) => c.id.toString() == id.toString());
    await saveCategories(categories);
  }

  // ==================== Flash Cards ====================

  Future<List<FlashCard>> getFlashCards() async {
    final p = await prefs;
    final json = p.getString(_flashCardsKey);
    if (json == null) return [];
    
    final List<dynamic> list = jsonDecode(json);
    return list.map((e) => FlashCard.fromJson(e)).toList();
  }

  Future<void> saveFlashCards(List<FlashCard> cards) async {
    final p = await prefs;
    final json = jsonEncode(cards.map((e) => e.toJson()).toList());
    await p.setString(_flashCardsKey, json);
  }

  Future<FlashCard?> getFlashCardById(dynamic id) async {
    final cards = await getFlashCards();
    try {
      return cards.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<FlashCard>> getFlashCardsByCategory(dynamic categoryId) async {
    final cards = await getFlashCards();
    return cards.where((c) => c.categoryId == categoryId.toString()).toList();
  }

  Future<List<FlashCard>> getFavoriteCards() async {
    final cards = await getFlashCards();
    return cards.where((c) => c.isFavorite).toList();
  }

  Future<int> insertFlashCard(FlashCard card) async {
    final cards = await getFlashCards();
    final newId = cards.isEmpty
        ? 1
        : cards
                .map((c) => int.tryParse(c.id.toString()) ?? 0)
                .reduce((a, b) => a > b ? a : b) +
            1;
    final newCard = card.copyWith(id: newId.toString());
    cards.add(newCard);
    await saveFlashCards(cards);
    return newId;
  }

  Future<void> updateFlashCard(FlashCard card) async {
    final cards = await getFlashCards();
    final index = cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      cards[index] = card;
      await saveFlashCards(cards);
    }
  }

  Future<void> toggleFavorite(dynamic cardId) async {
    final cards = await getFlashCards();
    final index = cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      cards[index] = cards[index].copyWith(isFavorite: !cards[index].isFavorite);
      await saveFlashCards(cards);
    }
  }

  Future<void> deleteFlashCard(dynamic id) async {
    final cards = await getFlashCards();
    cards.removeWhere((c) => c.id.toString() == id.toString());
    await saveFlashCards(cards);
  }

  Future<List<FlashCard>> searchFlashCards(String query) async {
    final cards = await getFlashCards();
    final lowerQuery = query.toLowerCase();
    return cards.where((c) => 
      c.germanWord.toLowerCase().contains(lowerQuery) ||
      c.russianTranslation.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  // ==================== Card Progress ====================

  Future<List<CardProgress>> getCardProgressList() async {
    final p = await prefs;
    final json = p.getString(_cardProgressKey);
    if (json == null) return [];
    
    final List<dynamic> list = jsonDecode(json);
    return list.map((e) => CardProgress.fromJson(e)).toList();
  }

  Future<void> saveCardProgressList(List<CardProgress> progressList) async {
    final p = await prefs;
    final json = jsonEncode(progressList.map((e) => e.toJson()).toList());
    await p.setString(_cardProgressKey, json);
  }

  Future<CardProgress?> getCardProgress(String cardId) async {
    final list = await getCardProgressList();
    try {
      return list.firstWhere((p) => p.cardId == cardId);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsertCardProgress(CardProgress progress) async {
    final list = await getCardProgressList();
    final index = list.indexWhere((p) => p.cardId == progress.cardId);
    if (index != -1) {
      list[index] = progress;
    } else {
      final newId = list.isEmpty
          ? 1
          : list
                  .map((p) => int.tryParse(p.id.toString()) ?? 0)
                  .reduce((a, b) => a > b ? a : b) +
              1;
      list.add(progress.copyWith(id: newId.toString()));
    }
    await saveCardProgressList(list);
  }

  Future<List<FlashCard>> getCardsForStudy({int limit = 20}) async {
    final cards = await getFlashCards();
    final progressList = await getCardProgressList();
    final now = DateTime.now();
    
    final dueCards = <FlashCard>[];
    
    for (final card in cards) {
      final progress = progressList.where((p) => p.cardId.toString() == card.id.toString()).firstOrNull;
      if (progress == null || progress.nextReviewDate.isBefore(now)) {
        dueCards.add(card);
      }
    }
    
    dueCards.shuffle();
    return dueCards.take(limit).toList();
  }

  // ==================== Study Sessions ====================

  Future<List<Map<String, dynamic>>> getStudySessions() async {
    final p = await prefs;
    final json = p.getString(_studySessionsKey);
    if (json == null) return [];
    
    final List<dynamic> list = jsonDecode(json);
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> saveStudySessions(List<Map<String, dynamic>> sessions) async {
    final p = await prefs;
    final json = jsonEncode(sessions);
    await p.setString(_studySessionsKey, json);
  }

  Future<int> insertStudySession(StudySession session) async {
    final sessions = await getStudySessions();
    final newId = sessions.isEmpty ? 1 : sessions.map((s) => s['id'] as int? ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    sessions.add({
      'id': newId,
      'startTime': session.startTime.toIso8601String(),
      'endTime': session.endTime?.toIso8601String(),
      'cardsStudied': session.cardsReviewed,
      'totalCards': session.totalCards,
      'correctAnswers': session.correctAnswers,
      'wrongAnswers': session.incorrectAnswers,
      'categoryId': session.categoryId,
    });
    await saveStudySessions(sessions);
    return newId;
  }

  Future<void> updateStudySession(StudySession session) async {
    final sessions = await getStudySessions();
    final index = sessions.indexWhere((s) => s['id'] == session.id);
    if (index != -1) {
      sessions[index] = {
        'id': session.id,
        'startTime': session.startTime.toIso8601String(),
        'endTime': session.endTime?.toIso8601String(),
        'totalCards': session.totalCards,
        'cardsStudied': session.cardsReviewed,
        'correctAnswers': session.correctAnswers,
        'wrongAnswers': session.incorrectAnswers,
        'categoryId': session.categoryId,
      };
      await saveStudySessions(sessions);
    }
  }

  // ==================== User Statistics ====================

  Future<UserStatistics?> getUserStatistics() async {
    final p = await prefs;
    final json = p.getString(_userStatisticsKey);
    if (json == null) return null;
    
    return UserStatistics.fromJson(jsonDecode(json));
  }

  Future<void> saveUserStatistics(UserStatistics stats) async {
    final p = await prefs;
    final json = jsonEncode(stats.toJson());
    await p.setString(_userStatisticsKey, json);
  }

  Future<void> updateStatisticsAfterReview({
    required bool isCorrect,
    required int studyTimeSeconds,
  }) async {
    var stats = await getUserStatistics();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (stats == null) {
      stats = UserStatistics(
        id: '1',
        totalCardsLearned: isCorrect ? 1 : 0,
        totalCardsReviewed: 1,
        totalCorrectAnswers: isCorrect ? 1 : 0,
        totalIncorrectAnswers: isCorrect ? 0 : 1,
        totalStudyTimeSeconds: studyTimeSeconds,
        totalStudyTimeMinutes: studyTimeSeconds ~/ 60,
        currentStreak: 1,
        longestStreak: 1,
        lastStudyDate: today,
        createdAt: today,
        updatedAt: today,
      );
    } else {
      final isNewDay = stats.lastStudyDate == null ? true : stats.lastStudyDate!.isBefore(today);
      final isConsecutiveDay = stats.lastStudyDate == null
          ? false
          : stats.lastStudyDate!.isAfter(today.subtract(const Duration(days: 2)));
      
      int newStreak = stats.currentStreak;
      if (isNewDay) {
        newStreak = isConsecutiveDay ? stats.currentStreak + 1 : 1;
      }
      
      stats = stats.copyWith(
        totalCardsLearned: stats.totalCardsLearned + (isCorrect ? 1 : 0),
        totalCardsReviewed: stats.totalCardsReviewed + 1,
        totalCorrectAnswers: stats.totalCorrectAnswers + (isCorrect ? 1 : 0),
        totalIncorrectAnswers: stats.totalIncorrectAnswers + (isCorrect ? 0 : 1),
        totalStudyTimeSeconds: stats.totalStudyTimeSeconds + studyTimeSeconds,
        totalStudyTimeMinutes: stats.totalStudyTimeMinutes + (studyTimeSeconds ~/ 60),
        currentStreak: newStreak,
        longestStreak: newStreak > stats.longestStreak ? newStreak : stats.longestStreak,
        lastStudyDate: today,
        updatedAt: DateTime.now(),
      );
    }
    
    await saveUserStatistics(stats);
  }

  // ==================== App Settings ====================

  Future<AppSettings> getAppSettings() async {
    final p = await prefs;
    final json = p.getString(_appSettingsKey);
    if (json == null) {
      return AppSettings(
        isDarkMode: false,
        dailyGoal: 20,
        notificationsEnabled: true,
        soundEnabled: true,
        vibrationEnabled: true,
        cardsPerSession: 20,
        autoPlayAudio: false,
        showExamples: true,
      );
    }
    
    return AppSettings.fromJson(jsonDecode(json));
  }

  Future<void> saveAppSettings(AppSettings settings) async {
    final p = await prefs;
    final json = jsonEncode(settings.toJson());
    await p.setString(_appSettingsKey, json);
  }

  // ==================== Utility ====================

  Future<void> clearAllData() async {
    final p = await prefs;
    await p.remove(_categoriesKey);
    await p.remove(_flashCardsKey);
    await p.remove(_cardProgressKey);
    await p.remove(_studySessionsKey);
    await p.remove(_cardReviewsKey);
    await p.remove(_userStatisticsKey);
    await p.remove(_dailyStatisticsKey);
    await p.remove(_categoryProgressKey);
    await p.remove(_appSettingsKey);
    await p.remove(_isInitializedKey);
  }
}
