import 'dart:math';

/// Вспомогательные функции приложения
class Helpers {
  Helpers._();

  /// Генерация уникального ID
  static String generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(20, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Расчет уровня на основе опыта
  static int calculateLevel(int experience) {
    // Каждый уровень требует экспоненциально больше опыта
    // Уровень 1: 0-100, Уровень 2: 100-300, Уровень 3: 300-600, и т.д.
    if (experience < 100) return 1;

    int level = 1;
    int requiredExp = 100;

    while (experience >= requiredExp) {
      level++;
      requiredExp += level * 100;
    }

    return level;
  }

  /// Расчет прогресса до следующего уровня (0.0 - 1.0)
  static double calculateLevelProgress(int experience) {
    int currentLevelExp = 0;
    int nextLevelExp = 100;
    int level = 1;

    while (experience >= nextLevelExp) {
      currentLevelExp = nextLevelExp;
      level++;
      nextLevelExp += level * 100;
    }

    return (experience - currentLevelExp) / (nextLevelExp - currentLevelExp);
  }

  /// Расчет следующей даты повторения по алгоритму SM-2
  static DateTime calculateNextReviewDate({
    required int repetitions,
    required double easeFactor,
    required DateTime lastReview,
  }) {
    int interval;

    if (repetitions == 0) {
      interval = 1;
    } else if (repetitions == 1) {
      interval = 6;
    } else {
      // SM-2 алгоритм
      interval = (6 * pow(easeFactor, repetitions - 1)).round();
    }

    return lastReview.add(Duration(days: interval));
  }

  /// Обновление ease factor по алгоритму SM-2
  static double updateEaseFactor(double currentEF, int quality) {
    // quality: 0-5 (0-2 = неправильно, 3-5 = правильно с разной уверенностью)
    final newEF = currentEF + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    return newEF < 1.3 ? 1.3 : newEF; // Минимум 1.3
  }

  /// Форматирование времени обучения
  static String formatStudyTime(int seconds) {
    if (seconds < 60) {
      return '$seconds сек';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      if (remainingSeconds == 0) {
        return '$minutes мин';
      }
      return '$minutes мин $remainingSeconds сек';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      if (minutes == 0) {
        return '$hours ч';
      }
      return '$hours ч $minutes мин';
    }
  }

  /// Форматирование серии (streak)
  static String formatStreak(int days) {
    if (days == 0) return 'Начните серию!';
    if (days == 1) return '1 день подряд';
    if (days < 5) return '$days дня подряд';
    return '$days дней подряд';
  }

  /// Получение мотивационного сообщения
  static String getMotivationalMessage(int streak, int cardsLearned) {
    if (streak >= 30) {
      return 'Невероятно! Месяц непрерывного обучения! 🏆';
    } else if (streak >= 7) {
      return 'Неделя подряд! Отличная работа! 🔥';
    } else if (streak >= 3) {
      return 'Вы на правильном пути! Продолжайте! 💪';
    } else if (cardsLearned >= 100) {
      return 'Уже 100 слов! Впечатляет! 🌟';
    } else if (cardsLearned >= 50) {
      return 'Половина сотни! Так держать! ⭐';
    } else if (cardsLearned >= 10) {
      return 'Хорошее начало! Продолжайте учить! 📚';
    }
    return 'Начните изучение немецкого прямо сейчас! 🇩🇪';
  }

  /// Валидация email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Перемешивание списка с seed для воспроизводимости
  static List<T> shuffleWithSeed<T>(List<T> list, int seed) {
    final random = Random(seed);
    final shuffled = List<T>.from(list);
    for (int i = shuffled.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }
    return shuffled;
  }
}
