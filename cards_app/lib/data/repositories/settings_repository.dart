import '../models/app_settings.dart';

/// Абстрактный репозиторий для работы с настройками
abstract class SettingsRepository {
  /// Получить настройки
  Future<AppSettings> getSettings();

  /// Сохранить настройки
  Future<void> saveSettings(AppSettings settings);

  /// Обновить конкретную настройку
  Future<void> updateSetting<T>(String key, T value);

  /// Сбросить настройки до значений по умолчанию
  Future<void> resetSettings();

  /// Проверить, первый ли это запуск
  Future<bool> isFirstLaunch();

  /// Отметить, что первый запуск завершен
  Future<void> setFirstLaunchCompleted();

  /// Проверить, завершен ли онбординг
  Future<bool> isOnboardingCompleted();

  /// Отметить, что онбординг завершен
  Future<void> setOnboardingCompleted();
}
