import 'package:flutter/material.dart';

/// Страница статистики пользователя
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Серия дней
            _buildStreakCard(),
            const SizedBox(height: 16),

            // Основная статистика
            _buildMainStats(),
            const SizedBox(height: 24),

            // Прогресс по категориям
            const Text(
              'Прогресс по категориям',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoryProgress(),
            const SizedBox(height: 24),

            // График активности
            const Text(
              'Активность за неделю',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildActivityChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_fire_department,
                size: 32,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '7 дней подряд!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Лучшая серия: 14 дней',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStats() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Изучено', '156', Icons.school, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Точность', '87%', Icons.check_circle, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Время', '4ч 30м', Icons.timer, Colors.purple)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryProgress() {
    final categories = [
      ('Еда', 0.8, Colors.orange),
      ('Семья', 0.6, Colors.pink),
      ('Путешествия', 0.4, Colors.blue),
      ('Работа', 0.2, Colors.green),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(category.$1),
                      Text('${(category.$2 * 100).toInt()}%'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: category.$2,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(category.$3),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    final values = [0.3, 0.5, 0.8, 0.4, 0.9, 0.6, 0.7];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 30,
                    height: 80 * values[index],
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2 + values[index] * 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days[index],
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
