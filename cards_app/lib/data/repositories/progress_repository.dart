import '../models/card_progress.dart';

/// Абстрактный репозиторий для работы с прогрессом карточек
abstract class ProgressRepository {
  /// Получить прогресс карточки
  Future<CardProgress?> getCardProgress(String cardId);

  /// Получить весь прогресс
  Future<List<CardProgress>> getAllProgress();

  /// Получить карточки для повторения
  Future<List<CardProgress>> getDueProgress({int limit = 10});

  /// Сохранить/обновить прогресс карточки
  Future<void> saveProgress(CardProgress progress);

  /// Обновить прогресс после ответа
  Future<CardProgress> updateProgressAfterAnswer({
    required String cardId,
    required bool isCorrect,
    required int quality, // 0-5 для SM-2 алгоритма
  });

  /// Сбросить прогресс карточки
  Future<void> resetCardProgress(String cardId);

  /// Сбросить весь прогресс
  Future<void> resetAllProgress();

  /// Получить количество изученных карточек
  Future<int> getLearnedCardsCount();

  /// Получить количество карточек для повторения
  Future<int> getDueCardsCount();
}
