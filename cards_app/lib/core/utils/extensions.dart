import 'package:flutter/material.dart';

/// Расширения для String
extension StringExtensions on String {
  /// Капитализация первой буквы
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Капитализация каждого слова
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Проверка на пустую строку или null
  bool get isNullOrEmpty => isEmpty;

  /// Обрезка строки с добавлением "..."
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

/// Расширения для DateTime
extension DateTimeExtensions on DateTime {
  /// Форматирование даты в читаемый формат
  String get formatted {
    return '${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.$year';
  }

  /// Форматирование времени
  String get timeFormatted {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Проверка на сегодня
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Проверка на вчера
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Разница в днях от сегодня
  int get daysFromNow {
    final now = DateTime.now();
    return DateTime(year, month, day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }
}

/// Расширения для BuildContext
extension ContextExtensions on BuildContext {
  /// Получение размеров экрана
  Size get screenSize => MediaQuery.of(this).size;

  /// Ширина экрана
  double get screenWidth => screenSize.width;

  /// Высота экрана
  double get screenHeight => screenSize.height;

  /// Текущая тема
  ThemeData get theme => Theme.of(this);

  /// Цветовая схема
  ColorScheme get colorScheme => theme.colorScheme;

  /// Текстовая тема
  TextTheme get textTheme => theme.textTheme;

  /// Проверка на темную тему
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Показать SnackBar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Показать диалог подтверждения
  Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = 'Да',
    String cancelText = 'Отмена',
  }) {
    return showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

/// Расширения для int
extension IntExtensions on int {
  /// Форматирование числа с разделителями
  String get formatted {
    if (this < 1000) return toString();
    if (this < 1000000) return '${(this / 1000).toStringAsFixed(1)}K';
    return '${(this / 1000000).toStringAsFixed(1)}M';
  }

  /// Получение склонения слова (для русского языка)
  String pluralize(String one, String few, String many) {
    final n = abs() % 100;
    if (n >= 5 && n <= 20) return many;
    final n1 = n % 10;
    if (n1 == 1) return one;
    if (n1 >= 2 && n1 <= 4) return few;
    return many;
  }
}

/// Расширения для double
extension DoubleExtensions on double {
  /// Округление до N знаков после запятой
  double roundTo(int places) {
    final mod = 10.0 * places;
    return (this * mod).round() / mod;
  }

  /// Форматирование процентов
  String get percentFormatted => '${(this * 100).toStringAsFixed(0)}%';
}

/// Расширения для List
extension ListExtensions<T> on List<T> {
  /// Безопасное получение элемента по индексу
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Перемешивание списка с возвратом нового
  List<T> get shuffled => List<T>.from(this)..shuffle();
}
