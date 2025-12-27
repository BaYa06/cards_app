import 'package:flutter/material.dart';

/// Модель набора (категории карточек)
class CategorySet {
  final String id;
  final String title;
  final String level;
  final int words;
  final int? repeatCount;
  final String? repeatLabel;
  final int? newWords;
  final double progress;
  final IconData icon;
  final Color accentColor;
  final Color iconBackground;
  final Color progressColor;

  const CategorySet({
    required this.id,
    required this.title,
    required this.level,
    required this.words,
    required this.progress,
    required this.icon,
    required this.accentColor,
    required this.iconBackground,
    required this.progressColor,
    this.repeatCount,
    this.repeatLabel,
    this.newWords,
  });
}
