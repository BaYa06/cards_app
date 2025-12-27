/// Модель настроек приложения
class AppSettings {
  final bool isDarkMode;
  final String languageCode;
  final int cardsPerSession;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool notificationsEnabled;
  final String? reminderTime; // Формат "HH:mm"
  final bool showExamples;
  final bool autoPlayAudio;
  final CardDisplayMode cardDisplayMode;
  final StudyDirection studyDirection;
  final int dailyGoal;

  const AppSettings({
    this.isDarkMode = false,
    this.languageCode = 'ru',
    this.cardsPerSession = 10,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.notificationsEnabled = true,
    this.reminderTime,
    this.showExamples = true,
    this.autoPlayAudio = false,
    this.cardDisplayMode = CardDisplayMode.swipe,
    this.studyDirection = StudyDirection.germanToRussian,
    this.dailyGoal = 10,
  });

  /// Создание из JSON
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isDarkMode: json['is_dark_mode'] as bool? ?? false,
      languageCode: json['language_code'] as String? ?? 'ru',
      cardsPerSession: json['cards_per_session'] as int? ?? 10,
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      vibrationEnabled: json['vibration_enabled'] as bool? ?? true,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      reminderTime: json['reminder_time'] as String?,
      showExamples: json['show_examples'] as bool? ?? true,
      autoPlayAudio: json['auto_play_audio'] as bool? ?? false,
      cardDisplayMode: CardDisplayMode.values.firstWhere(
        (e) => e.name == json['card_display_mode'],
        orElse: () => CardDisplayMode.swipe,
      ),
      studyDirection: StudyDirection.values.firstWhere(
        (e) => e.name == json['study_direction'],
        orElse: () => StudyDirection.germanToRussian,
      ),
      dailyGoal: json['daily_goal'] as int? ?? 10,
    );
  }

  /// Конвертация в JSON
  Map<String, dynamic> toJson() {
    return {
      'is_dark_mode': isDarkMode,
      'language_code': languageCode,
      'cards_per_session': cardsPerSession,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
      'notifications_enabled': notificationsEnabled,
      'reminder_time': reminderTime,
      'show_examples': showExamples,
      'auto_play_audio': autoPlayAudio,
      'card_display_mode': cardDisplayMode.name,
      'study_direction': studyDirection.name,
      'daily_goal': dailyGoal,
    };
  }

  /// Копирование с изменениями
  AppSettings copyWith({
    bool? isDarkMode,
    String? languageCode,
    int? cardsPerSession,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? notificationsEnabled,
    String? reminderTime,
    bool? showExamples,
    bool? autoPlayAudio,
    CardDisplayMode? cardDisplayMode,
    StudyDirection? studyDirection,
    int? dailyGoal,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      cardsPerSession: cardsPerSession ?? this.cardsPerSession,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      showExamples: showExamples ?? this.showExamples,
      autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
      cardDisplayMode: cardDisplayMode ?? this.cardDisplayMode,
      studyDirection: studyDirection ?? this.studyDirection,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }

  /// Настройки по умолчанию
  static const AppSettings defaultSettings = AppSettings();
}

/// Режим отображения карточек
enum CardDisplayMode {
  swipe, // Свайп влево/вправо
  tap, // Нажатие для переворота
  buttons, // Кнопки "Знаю"/"Не знаю"
}

/// Направление изучения
enum StudyDirection {
  germanToRussian, // Немецкий -> Русский
  russianToGerman, // Русский -> Немецкий
  mixed, // Смешанный
}
