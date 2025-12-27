/// Ключи для локального хранилища
class StorageKeys {
  StorageKeys._();

  // Настройки пользователя
  static const String isDarkMode = 'is_dark_mode';
  static const String selectedLanguage = 'selected_language';
  static const String cardsPerSession = 'cards_per_session';
  static const String soundEnabled = 'sound_enabled';
  static const String vibrationEnabled = 'vibration_enabled';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String reminderTime = 'reminder_time';

  // Прогресс пользователя
  static const String totalCardsLearned = 'total_cards_learned';
  static const String currentStreak = 'current_streak';
  static const String longestStreak = 'longest_streak';
  static const String lastStudyDate = 'last_study_date';

  // Первый запуск
  static const String isFirstLaunch = 'is_first_launch';
  static const String onboardingCompleted = 'onboarding_completed';
}
