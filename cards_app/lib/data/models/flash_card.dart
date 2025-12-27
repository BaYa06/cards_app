/// Модель карточки для изучения немецких слов
class FlashCard {
  final dynamic id;
  final String germanWord;
  final String russianTranslation;
  final String? article; // der, die, das для существительных
  final String? pluralForm;
  final String? exampleSentence;
  final String? exampleTranslation;
  final String categoryId;
  final String? audioUrl;
  final String? imageUrl;
  final int difficultyLevel; // 1 - легкий, 2 - средний, 3 - сложный
  final String partOfSpeech; // noun, verb, adjective, etc.
  final bool isFavorite;
  final DateTime createdAt;

  FlashCard({
    required this.id,
    required this.germanWord,
    required this.russianTranslation,
    this.article,
    this.pluralForm,
    this.exampleSentence,
    this.exampleTranslation,
    required dynamic categoryId,
    this.audioUrl,
    this.imageUrl,
    this.difficultyLevel = 1,
    this.partOfSpeech = 'noun',
    this.isFavorite = false,
    DateTime? createdAt,
  })  : categoryId = categoryId.toString(),
        createdAt = createdAt ?? DateTime.now();

  /// Полное немецкое слово с артиклем (если есть)
  String get fullGermanWord {
    if (article != null && article!.isNotEmpty) {
      return '$article $germanWord';
    }
    return germanWord;
  }

  /// Создание из JSON
  factory FlashCard.fromJson(Map<String, dynamic> json) {
    return FlashCard(
      id: json['id'],
      germanWord: (json['german_word'] ?? json['germanWord'] ?? '') as String? ?? '',
      russianTranslation: (json['russian_translation'] ?? json['russianTranslation'] ?? '') as String? ?? '',
      article: json['article'] as String?,
      pluralForm: json['plural_form'] as String?,
      exampleSentence: json['example_sentence'] as String?,
      exampleTranslation: json['example_translation'] as String?,
      categoryId: (json['category_id'] ?? json['categoryId'] ?? '').toString(),
      audioUrl: json['audio_url'] as String?,
      imageUrl: json['image_url'] as String?,
      difficultyLevel: json['difficulty_level'] as int? ?? 1,
      partOfSpeech: json['part_of_speech'] as String? ?? 'noun',
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Конвертация в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'german_word': germanWord,
      'russian_translation': russianTranslation,
      'article': article,
      'plural_form': pluralForm,
      'example_sentence': exampleSentence,
      'example_translation': exampleTranslation,
      'category_id': categoryId,
      'audio_url': audioUrl,
      'image_url': imageUrl,
      'difficulty_level': difficultyLevel,
      'part_of_speech': partOfSpeech,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Копирование с изменениями
  FlashCard copyWith({
    String? id,
    String? germanWord,
    String? russianTranslation,
    String? article,
    String? pluralForm,
    String? exampleSentence,
    String? exampleTranslation,
    dynamic categoryId,
    String? audioUrl,
    String? imageUrl,
    int? difficultyLevel,
    String? partOfSpeech,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return FlashCard(
      id: id ?? this.id,
      germanWord: germanWord ?? this.germanWord,
      russianTranslation: russianTranslation ?? this.russianTranslation,
      article: article ?? this.article,
      pluralForm: pluralForm ?? this.pluralForm,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      exampleTranslation: exampleTranslation ?? this.exampleTranslation,
      categoryId: categoryId?.toString() ?? this.categoryId,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlashCard &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FlashCard{id: $id, germanWord: $germanWord, russianTranslation: $russianTranslation}';
  }
}
