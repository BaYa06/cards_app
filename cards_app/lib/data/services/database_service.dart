/// Сервис для работы с локальной базой данных
/// Будет использовать SQLite через sqflite
abstract class DatabaseService {
  /// Инициализация базы данных
  Future<void> initialize();

  /// Закрытие соединения
  Future<void> close();

  /// Очистка всех данных
  Future<void> clearAll();

  /// Выполнение миграций
  Future<void> runMigrations();

  /// Экспорт данных (для бэкапа)
  Future<Map<String, dynamic>> exportData();

  /// Импорт данных (восстановление из бэкапа)
  Future<void> importData(Map<String, dynamic> data);
}
