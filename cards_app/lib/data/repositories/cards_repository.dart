import '../models/flash_card.dart';

/// Абстрактный репозиторий для работы с карточками
abstract class CardsRepository {
  /// Получить все карточки
  Future<List<FlashCard>> getAllCards();

  /// Получить карточку по ID
  Future<FlashCard?> getCardById(String id);

  /// Получить карточки по категории
  Future<List<FlashCard>> getCardsByCategory(String categoryId);

  /// Получить карточки для повторения (due cards)
  Future<List<FlashCard>> getDueCards({int limit = 10});

  /// Получить новые карточки (еще не изученные)
  Future<List<FlashCard>> getNewCards({
    String? categoryId,
    int limit = 10,
  });

  /// Поиск карточек
  Future<List<FlashCard>> searchCards(String query);

  /// Добавить карточку
  Future<void> addCard(FlashCard card);

  /// Добавить несколько карточек
  Future<void> addCards(List<FlashCard> cards);

  /// Обновить карточку
  Future<void> updateCard(FlashCard card);

  /// Удалить карточку
  Future<void> deleteCard(String id);

  /// Получить количество карточек в категории
  Future<int> getCardsCountByCategory(String categoryId);

  /// Получить общее количество карточек
  Future<int> getTotalCardsCount();
}
