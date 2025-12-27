import '../models/category.dart';

/// Абстрактный репозиторий для работы с категориями
abstract class CategoriesRepository {
  /// Получить все категории
  Future<List<Category>> getAllCategories();

  /// Получить категорию по ID
  Future<Category?> getCategoryById(String id);

  /// Добавить категорию
  Future<void> addCategory(Category category);

  /// Обновить категорию
  Future<void> updateCategory(Category category);

  /// Удалить категорию
  Future<void> deleteCategory(String id);

  /// Получить категории с прогрессом
  Future<List<CategoryWithProgress>> getCategoriesWithProgress();
}

/// Модель категории с информацией о прогрессе
class CategoryWithProgress {
  final Category category;
  final int totalCards;
  final int learnedCards;
  final int dueCards;

  const CategoryWithProgress({
    required this.category,
    required this.totalCards,
    required this.learnedCards,
    required this.dueCards,
  });

  /// Прогресс изучения (0.0 - 1.0)
  double get progress {
    if (totalCards == 0) return 0.0;
    return learnedCards / totalCards;
  }
}
