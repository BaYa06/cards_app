/// Основные константы приложения DeutschCards
class AppConstants {
  AppConstants._();

  // Название приложения
  static const String appName = 'DeutschCards';
  static const String appVersion = '1.0.0';

  // База данных
  static const String databaseName = 'deutsch_cards.db';
  static const int databaseVersion = 1;

  // Настройки карточек
  static const int defaultCardsPerSession = 10;
  static const int minCardsPerSession = 5;
  static const int maxCardsPerSession = 50;

  // Интервалы повторения (в днях) - алгоритм интервального повторения
  static const List<int> repetitionIntervals = [1, 3, 7, 14, 30, 60];

  // Уровни сложности
  static const int easyLevel = 1;
  static const int mediumLevel = 2;
  static const int hardLevel = 3;

  // Анимации
  static const Duration cardFlipDuration = Duration(milliseconds: 300);
  static const Duration swipeDuration = Duration(milliseconds: 200);

  // Размеры
  static const double cardBorderRadius = 16.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
}
