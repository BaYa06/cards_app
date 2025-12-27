/// Пути к ресурсам приложения
class AssetPaths {
  AssetPaths._();

  // Изображения
  static const String imagesPath = 'assets/images';
  static const String logo = '$imagesPath/logo.png';
  static const String placeholder = '$imagesPath/placeholder.png';
  static const String emptyState = '$imagesPath/empty_state.png';
  static const String successIcon = '$imagesPath/success.png';

  // Иконки категорий
  static const String categoryIcons = '$imagesPath/categories';

  // Аудио
  static const String audioPath = 'assets/audio';

  // JSON данные
  static const String dataPath = 'assets/data';
  static const String initialCardsData = '$dataPath/initial_cards.json';
  static const String categoriesData = '$dataPath/categories.json';

  // Шрифты
  static const String fontsPath = 'assets/fonts';

  // Lottie анимации
  static const String animationsPath = 'assets/animations';
  static const String successAnimation = '$animationsPath/success.json';
  static const String loadingAnimation = '$animationsPath/loading.json';
}
