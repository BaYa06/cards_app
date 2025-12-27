/// Сервис для управления уведомлениями
abstract class NotificationService {
  /// Инициализация сервиса
  Future<void> initialize();

  /// Запросить разрешение на уведомления
  Future<bool> requestPermission();

  /// Запланировать ежедневное напоминание
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  });

  /// Отменить все запланированные уведомления
  Future<void> cancelAllNotifications();

  /// Отменить конкретное уведомление
  Future<void> cancelNotification(int id);

  /// Показать мгновенное уведомление
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  });

  /// Проверить, включены ли уведомления
  Future<bool> areNotificationsEnabled();
}
