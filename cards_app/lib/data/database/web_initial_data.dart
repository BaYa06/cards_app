import 'web_database_helper.dart';
import '../models/flash_card.dart';
import '../models/category.dart';

/// Загрузчик начальных данных для Web платформы
class WebInitialDataLoader {
  static final WebDatabaseHelper _db = WebDatabaseHelper.instance;

  /// Загрузка всех начальных данных
  static Future<void> loadInitialData() async {
    // Проверяем, загружены ли уже данные
    if (await _db.isInitialized) {
      return;
    }

    // Загружаем категории
    await _loadCategories();

    // Загружаем начальные слова
    await _loadInitialWords();

    // Помечаем базу как инициализированную
    await _db.setInitialized(true);
  }

  /// Загрузка категорий
  static Future<void> _loadCategories() async {
    final categories = [
      Category(
        id: 1,
        name: 'Основы',
        description: 'Базовые слова и фразы для начинающих',
        icon: 'school',
        color: 0xFF4CAF50,
        orderIndex: 1,
      ),
      Category(
        id: 2,
        name: 'Еда и напитки',
        description: 'Слова связанные с едой и напитками',
        icon: 'restaurant',
        color: 0xFFFF9800,
        orderIndex: 2,
      ),
      Category(
        id: 3,
        name: 'Семья',
        description: 'Члены семьи и родственники',
        icon: 'family_restroom',
        color: 0xFFE91E63,
        orderIndex: 3,
      ),
      Category(
        id: 4,
        name: 'Числа',
        description: 'Числа и счёт',
        icon: 'numbers',
        color: 0xFF2196F3,
        orderIndex: 4,
      ),
      Category(
        id: 5,
        name: 'Цвета',
        description: 'Названия цветов',
        icon: 'palette',
        color: 0xFF9C27B0,
        orderIndex: 5,
      ),
      Category(
        id: 6,
        name: 'Глаголы',
        description: 'Основные глаголы',
        icon: 'directions_run',
        color: 0xFF00BCD4,
        orderIndex: 6,
      ),
      Category(
        id: 7,
        name: 'Дом',
        description: 'Предметы в доме и мебель',
        icon: 'home',
        color: 0xFF795548,
        orderIndex: 7,
      ),
      Category(
        id: 8,
        name: 'Одежда',
        description: 'Предметы одежды',
        icon: 'checkroom',
        color: 0xFF607D8B,
        orderIndex: 8,
      ),
      Category(
        id: 9,
        name: 'Транспорт',
        description: 'Виды транспорта',
        icon: 'directions_car',
        color: 0xFFFF5722,
        orderIndex: 9,
      ),
      Category(
        id: 10,
        name: 'Природа',
        description: 'Природа и погода',
        icon: 'nature',
        color: 0xFF8BC34A,
        orderIndex: 10,
      ),
      Category(
        id: 11,
        name: 'Тело',
        description: 'Части тела',
        icon: 'accessibility',
        color: 0xFFCDDC39,
        orderIndex: 11,
      ),
      Category(
        id: 12,
        name: 'Время',
        description: 'Время и даты',
        icon: 'schedule',
        color: 0xFF3F51B5,
        orderIndex: 12,
      ),
      Category(
        id: 13,
        name: 'Мои слова',
        description: 'Ваши собственные слова',
        icon: 'bookmark',
        color: 0xFFF44336,
        orderIndex: 13,
        isCustom: true,
      ),
    ];

    await _db.saveCategories(categories);
  }

  /// Загрузка начальных слов
  static Future<void> _loadInitialWords() async {
    final words = <FlashCard>[];
    int id = 1;

    // Основы (categoryId: 1)
    final basics = [
      {'de': 'Hallo', 'ru': 'Привет', 'example': 'Hallo, wie geht es dir?'},
      {'de': 'Guten Tag', 'ru': 'Добрый день', 'example': 'Guten Tag, Herr Müller!'},
      {'de': 'Auf Wiedersehen', 'ru': 'До свидания', 'example': 'Auf Wiedersehen und bis bald!'},
      {'de': 'Danke', 'ru': 'Спасибо', 'example': 'Danke für Ihre Hilfe!'},
      {'de': 'Bitte', 'ru': 'Пожалуйста', 'example': 'Bitte schön!'},
      {'de': 'Ja', 'ru': 'Да', 'example': 'Ja, ich verstehe.'},
      {'de': 'Nein', 'ru': 'Нет', 'example': 'Nein, das stimmt nicht.'},
      {'de': 'Entschuldigung', 'ru': 'Извините', 'example': 'Entschuldigung, wo ist der Bahnhof?'},
      {'de': 'Ich', 'ru': 'Я', 'example': 'Ich bin Student.'},
      {'de': 'Du', 'ru': 'Ты', 'example': 'Wie heißt du?'},
      {'de': 'Gut', 'ru': 'Хорошо', 'example': 'Mir geht es gut.'},
      {'de': 'Schlecht', 'ru': 'Плохо', 'example': 'Das Wetter ist schlecht.'},
    ];

    for (var word in basics) {
      words.add(FlashCard(
        id: id++,
        germanWord: word['de']!,
        russianTranslation: word['ru']!,
        exampleSentence: word['example'],
        categoryId: 1,
      ));
    }

    // Еда и напитки (categoryId: 2)
    final food = [
      {'de': 'das Brot', 'ru': 'Хлеб', 'example': 'Ich esse Brot zum Frühstück.'},
      {'de': 'das Wasser', 'ru': 'Вода', 'example': 'Kann ich ein Glas Wasser haben?'},
      {'de': 'der Kaffee', 'ru': 'Кофе', 'example': 'Ich trinke jeden Morgen Kaffee.'},
      {'de': 'der Tee', 'ru': 'Чай', 'example': 'Möchten Sie Tee oder Kaffee?'},
      {'de': 'die Milch', 'ru': 'Молоко', 'example': 'Die Milch ist frisch.'},
      {'de': 'das Fleisch', 'ru': 'Мясо', 'example': 'Ich esse kein Fleisch.'},
      {'de': 'der Fisch', 'ru': 'Рыба', 'example': 'Der Fisch schmeckt gut.'},
      {'de': 'das Obst', 'ru': 'Фрукты', 'example': 'Obst ist gesund.'},
      {'de': 'das Gemüse', 'ru': 'Овощи', 'example': 'Ich kaufe frisches Gemüse.'},
      {'de': 'der Apfel', 'ru': 'Яблоко', 'example': 'Der Apfel ist rot.'},
      {'de': 'die Banane', 'ru': 'Банан', 'example': 'Ich esse eine Banane.'},
      {'de': 'der Käse', 'ru': 'Сыр', 'example': 'Der Käse ist aus der Schweiz.'},
    ];

    for (var word in food) {
      words.add(FlashCard(
        id: id++,
        germanWord: word['de']!,
        russianTranslation: word['ru']!,
        exampleSentence: word['example'],
        categoryId: 2,
      ));
    }

    // Семья (categoryId: 3)
    final family = [
      {'de': 'die Mutter', 'ru': 'Мама', 'example': 'Meine Mutter kocht gut.'},
      {'de': 'der Vater', 'ru': 'Папа', 'example': 'Mein Vater arbeitet viel.'},
      {'de': 'die Schwester', 'ru': 'Сестра', 'example': 'Ich habe eine Schwester.'},
      {'de': 'der Bruder', 'ru': 'Брат', 'example': 'Mein Bruder ist älter als ich.'},
      {'de': 'die Großmutter', 'ru': 'Бабушка', 'example': 'Meine Großmutter lebt auf dem Land.'},
      {'de': 'der Großvater', 'ru': 'Дедушка', 'example': 'Mein Großvater erzählt gern Geschichten.'},
      {'de': 'die Tochter', 'ru': 'Дочь', 'example': 'Unsere Tochter geht zur Schule.'},
      {'de': 'der Sohn', 'ru': 'Сын', 'example': 'Unser Sohn ist fünf Jahre alt.'},
      {'de': 'die Familie', 'ru': 'Семья', 'example': 'Meine Familie ist groß.'},
      {'de': 'die Eltern', 'ru': 'Родители', 'example': 'Meine Eltern wohnen in Berlin.'},
    ];

    for (var word in family) {
      words.add(FlashCard(
        id: id++,
        germanWord: word['de']!,
        russianTranslation: word['ru']!,
        exampleSentence: word['example'],
        categoryId: 3,
      ));
    }

    // Числа (categoryId: 4)
    final numbers = [
      {'de': 'eins', 'ru': 'Один', 'example': 'Ich habe eins.'},
      {'de': 'zwei', 'ru': 'Два', 'example': 'Zwei plus zwei ist vier.'},
      {'de': 'drei', 'ru': 'Три', 'example': 'Ich habe drei Äpfel.'},
      {'de': 'vier', 'ru': 'Четыре', 'example': 'Das Zimmer hat vier Ecken.'},
      {'de': 'fünf', 'ru': 'Пять', 'example': 'Fünf Finger an einer Hand.'},
      {'de': 'sechs', 'ru': 'Шесть', 'example': 'Sechs Tage die Woche.'},
      {'de': 'sieben', 'ru': 'Семь', 'example': 'Sieben Tage hat die Woche.'},
      {'de': 'acht', 'ru': 'Восемь', 'example': 'Um acht Uhr beginnt die Schule.'},
      {'de': 'neun', 'ru': 'Девять', 'example': 'Neun ist meine Lieblingszahl.'},
      {'de': 'zehn', 'ru': 'Десять', 'example': 'Ich zähle bis zehn.'},
      {'de': 'hundert', 'ru': 'Сто', 'example': 'Hundert Prozent richtig!'},
      {'de': 'tausend', 'ru': 'Тысяча', 'example': 'Tausend Dank!'},
    ];

    for (var word in numbers) {
      words.add(FlashCard(
        id: id++,
        germanWord: word['de']!,
        russianTranslation: word['ru']!,
        exampleSentence: word['example'],
        categoryId: 4,
      ));
    }

    // Цвета (categoryId: 5)
    final colors = [
      {'de': 'rot', 'ru': 'Красный', 'example': 'Das Auto ist rot.'},
      {'de': 'blau', 'ru': 'Синий', 'example': 'Der Himmel ist blau.'},
      {'de': 'grün', 'ru': 'Зелёный', 'example': 'Das Gras ist grün.'},
      {'de': 'gelb', 'ru': 'Жёлтый', 'example': 'Die Sonne ist gelb.'},
      {'de': 'schwarz', 'ru': 'Чёрный', 'example': 'Die Katze ist schwarz.'},
      {'de': 'weiß', 'ru': 'Белый', 'example': 'Der Schnee ist weiß.'},
      {'de': 'orange', 'ru': 'Оранжевый', 'example': 'Die Orange ist orange.'},
      {'de': 'braun', 'ru': 'Коричневый', 'example': 'Der Hund ist braun.'},
      {'de': 'grau', 'ru': 'Серый', 'example': 'Die Wolken sind grau.'},
      {'de': 'rosa', 'ru': 'Розовый', 'example': 'Die Blume ist rosa.'},
    ];

    for (var word in colors) {
      words.add(FlashCard(
        id: id++,
        germanWord: word['de']!,
        russianTranslation: word['ru']!,
        exampleSentence: word['example'],
        categoryId: 5,
      ));
    }

    // Глаголы (categoryId: 6)
    final verbs = [
      {'de': 'sein', 'ru': 'Быть', 'example': 'Ich bin glücklich.'},
      {'de': 'haben', 'ru': 'Иметь', 'example': 'Ich habe ein Auto.'},
      {'de': 'gehen', 'ru': 'Идти', 'example': 'Ich gehe zur Arbeit.'},
      {'de': 'kommen', 'ru': 'Приходить', 'example': 'Er kommt aus Deutschland.'},
      {'de': 'machen', 'ru': 'Делать', 'example': 'Was machst du?'},
      {'de': 'sagen', 'ru': 'Говорить', 'example': 'Was sagt er?'},
      {'de': 'können', 'ru': 'Мочь', 'example': 'Ich kann Deutsch sprechen.'},
      {'de': 'wollen', 'ru': 'Хотеть', 'example': 'Ich will nach Hause gehen.'},
      {'de': 'essen', 'ru': 'Есть', 'example': 'Ich esse gern Pizza.'},
      {'de': 'trinken', 'ru': 'Пить', 'example': 'Was trinkst du?'},
      {'de': 'schlafen', 'ru': 'Спать', 'example': 'Ich schlafe acht Stunden.'},
      {'de': 'arbeiten', 'ru': 'Работать', 'example': 'Ich arbeite im Büro.'},
      {'de': 'lernen', 'ru': 'Учить', 'example': 'Ich lerne Deutsch.'},
    ];

    for (var word in verbs) {
      words.add(FlashCard(
        id: id++,
        germanWord: word['de']!,
        russianTranslation: word['ru']!,
        exampleSentence: word['example'],
        categoryId: 6,
      ));
    }

    await _db.saveFlashCards(words);
  }
}
