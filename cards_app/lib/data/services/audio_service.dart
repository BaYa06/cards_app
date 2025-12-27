/// Сервис для воспроизведения аудио произношения
abstract class AudioService {
  /// Инициализация сервиса
  Future<void> initialize();

  /// Воспроизвести произношение слова
  Future<void> playPronunciation(String text, {String language = 'de'});

  /// Воспроизвести аудиофайл по URL
  Future<void> playFromUrl(String url);

  /// Воспроизвести локальный аудиофайл
  Future<void> playFromAsset(String assetPath);

  /// Остановить воспроизведение
  Future<void> stop();

  /// Проверить, воспроизводится ли аудио
  bool get isPlaying;

  /// Освободить ресурсы
  Future<void> dispose();
}
