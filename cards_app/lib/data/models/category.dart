import 'package:flutter/material.dart';

/// Модель категории карточек
class Category {
  final dynamic id;
  final String name;
  final String description;
  final String icon; // Название иконки из Icons
  final int color; // Цвет в формате int (0xFFXXXXXX)
  final int orderIndex;
  final bool isPremium;
  final bool isCustom;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.orderIndex = 0,
    this.isPremium = false,
    this.isCustom = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Получение цвета как Color
  Color get colorValue => Color(color);

  /// Получение иконки
  IconData get iconData {
    // Маппинг строковых названий на IconData
    final iconMap = <String, IconData>{
      'home': Icons.home,
      'food': Icons.restaurant,
      'travel': Icons.flight,
      'work': Icons.work,
      'family': Icons.family_restroom,
      'numbers': Icons.numbers,
      'colors': Icons.palette,
      'animals': Icons.pets,
      'body': Icons.accessibility_new,
      'clothes': Icons.checkroom,
      'time': Icons.access_time,
      'weather': Icons.wb_sunny,
      'city': Icons.location_city,
      'nature': Icons.park,
      'sport': Icons.sports_soccer,
      'music': Icons.music_note,
      'school': Icons.school,
      'shopping': Icons.shopping_cart,
      'health': Icons.local_hospital,
      'transport': Icons.directions_car,
      'verbs': Icons.text_fields,
      'adjectives': Icons.format_color_text,
      'phrases': Icons.chat_bubble,
      'grammar': Icons.menu_book,
    };

    return iconMap[icon] ?? Icons.category;
  }

  /// Создание из JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    bool _toBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      return false;
    }

    return Category(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '') as String? ?? '',
      description: (json['description'] ?? '') as String? ?? '',
      icon: (json['icon'] ?? 'category') as String? ?? 'category',
      color: (json['color'] as int?) ?? 0xFF2D65E6,
      orderIndex: json['order_index'] as int? ?? 0,
      isPremium: _toBool(json['is_premium']),
      isCustom: _toBool(json['is_custom']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Конвертация в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'order_index': orderIndex,
      'is_premium': isPremium,
      'is_custom': isCustom,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Копирование с изменениями
  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    int? color,
    int? orderIndex,
    bool? isPremium,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      orderIndex: orderIndex ?? this.orderIndex,
      isPremium: isPremium ?? this.isPremium,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Category{id: $id, name: $name}';
  }
}
