import 'package:flutter/material.dart';

/// Страница сессии изучения карточек
class StudySessionPage extends StatefulWidget {
  final String? categoryId;
  final int cardsCount;

  const StudySessionPage({
    super.key,
    this.categoryId,
    this.cardsCount = 10,
  });

  @override
  State<StudySessionPage> createState() => _StudySessionPageState();
}

class _StudySessionPageState extends State<StudySessionPage> {
  int _currentIndex = 0;
  bool _isFlipped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentIndex + 1} / ${widget.cardsCount}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () {
              // TODO: Воспроизвести произношение
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Прогресс бар
              LinearProgressIndicator(
                value: (_currentIndex + 1) / widget.cardsCount,
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(height: 24),

              // Карточка
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFlipped = !_isFlipped;
                    });
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_isFlipped) ...[
                            const Text(
                              'der Hund',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Нажмите, чтобы перевернуть',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ] else ...[
                            const Text(
                              'собака',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Der Hund ist sehr treu.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Собака очень верная.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Кнопки оценки
              if (_isFlipped)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAnswerButton(
                      icon: Icons.close,
                      label: 'Не знаю',
                      color: Colors.red,
                      onTap: () => _answerCard(false),
                    ),
                    _buildAnswerButton(
                      icon: Icons.check,
                      label: 'Знаю',
                      color: Colors.green,
                      onTap: () => _answerCard(true),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _answerCard(bool isCorrect) {
    // TODO: Обновить прогресс карточки

    if (_currentIndex < widget.cardsCount - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    } else {
      // Показать результаты
      _showResults();
    }
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из сессии?'),
        content: const Text('Прогресс текущей сессии будет сохранен.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Сессия завершена! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Отличная работа!'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Изучено', '${widget.cardsCount}'),
                _buildStatItem('Правильно', '8'),
                _buildStatItem('Точность', '80%'),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Готово'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
