import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/router/app_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNavIndex = 0;

  // Design colors
  static const Color _primaryColor = Color(0xFF2D65E6);
  static const Color _backgroundLight = Color(0xFFF6F6F8);
  static const Color _backgroundDark = Color(0xFF111621);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _surfaceDark = Color(0xFF1E293B);
  static const Color _emerald = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? _backgroundDark : _backgroundLight,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, isDark),
              const SizedBox(height: 16),
              _buildDailyGoalSection(context, isDark),
              const SizedBox(height: 16),
              _buildContinueLearningSection(context, isDark),
              const SizedBox(height: 24),
              _buildQuickActionsSection(context, isDark),
              const SizedBox(height: 24),
              _buildGamesSection(context, isDark),
              const SizedBox(height: 24),
              _buildRecommendedSection(context, isDark),
              const SizedBox(height: 24),
              _buildWeeklyStatsSection(context, isDark),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context, isDark),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // User avatar and greeting
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.grey.shade700 : Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue.shade400, Colors.purple.shade400],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'A',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Online indicator
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green.shade500,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? _backgroundDark : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                    ),
                  ),
                  const Text(
                    'Алекс',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Action buttons
          Row(
            children: [
              // Notifications with badge
              Stack(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/settings'),
                icon: Icon(
                  Icons.settings_outlined,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Доброй ночи,';
    if (hour < 12) return 'Доброе утро,';
    if (hour < 18) return 'Добрый день,';
    return 'Добрый вечер,';
  }

  // ==================== DAILY GOAL SECTION ====================
  Widget _buildDailyGoalSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? _surfaceDark : _surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
          ),
          boxShadow: isDark ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative blob
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.blue.shade900.withOpacity(0.2)
                      : Colors.blue.shade50,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Цель дня',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                size: 16,
                                color: _primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Осталось: 6 минут',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Streak badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.orange.shade900.withOpacity(0.3)
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? Colors.orange.shade800.withOpacity(0.5)
                                : Colors.orange.shade100,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 18,
                              color: Colors.orange.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '7 дней',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.orange.shade400 : Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Progress row
                  Row(
                    children: [
                      // Circular progress
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CustomPaint(
                          painter: _CircularProgressPainter(
                            progress: 0.5,
                            backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                            progressColor: _primaryColor,
                            strokeWidth: 6,
                          ),
                          child: const Center(
                            child: Text(
                              '50%',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Stats
                      Expanded(
                        child: Column(
                          children: [
                            _buildProgressRow('Слова', '10 / 20', 0.5, isDark),
                            const SizedBox(height: 12),
                            _buildProgressRow('Время', '5 / 10 мин', 0.5, isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Start button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/study/1'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: _primaryColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Начать тренировку',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, String value, double progress, bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
            valueColor: const AlwaysStoppedAnimation<Color>(_primaryColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // ==================== CONTINUE LEARNING SECTION ====================
  Widget _buildContinueLearningSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? _surfaceDark : _surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
          ),
          boxShadow: isDark ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            // Category image
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade400, Colors.cyan.shade300],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.flight, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Путешествия (A1)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.arrow_forward,
                              color: _primaryColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildSmallBadge(Colors.orange.shade400, 'Повторить: 12'),
                      const SizedBox(width: 12),
                      _buildSmallBadge(Colors.blue.shade400, 'Новые: 5'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: 0.75,
                      backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(_emerald),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallBadge(Color dotColor, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  // ==================== QUICK ACTIONS SECTION ====================
  Widget _buildQuickActionsSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Быстрые действия',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildQuickActionCard(
                icon: Icons.picture_as_pdf,
                label: 'Импорт PDF',
                iconBgColor: isDark ? Colors.red.shade900.withOpacity(0.2) : Colors.red.shade50,
                iconColor: Colors.red.shade500,
                isDark: isDark,
                onTap: () {},
              ),
              _buildQuickActionCard(
                icon: Icons.auto_awesome,
                label: 'AI Генерация',
                iconBgColor: isDark ? Colors.purple.shade900.withOpacity(0.2) : Colors.purple.shade50,
                iconColor: Colors.purple.shade500,
                isDark: isDark,
                onTap: () {},
              ),
              _buildQuickActionCard(
                icon: Icons.add_circle,
                label: 'Создать набор',
                iconBgColor: isDark ? Colors.blue.shade900.withOpacity(0.2) : Colors.blue.shade50,
                iconColor: _primaryColor,
                isDark: isDark,
                onTap: () {},
              ),
              _buildQuickActionCard(
                icon: Icons.fitness_center,
                label: 'Слабые слова',
                iconBgColor: isDark ? Colors.orange.shade900.withOpacity(0.2) : Colors.orange.shade50,
                iconColor: Colors.orange.shade500,
                isDark: isDark,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color iconBgColor,
    required Color iconColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isDark ? _surfaceDark : _surfaceLight,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== GAMES SECTION ====================
  Widget _buildGamesSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Игры для закрепления',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Все',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildGameCard(
                title: 'Match',
                subtitle: 'Найди пару',
                icon: Icons.style,
                gradientColors: [Colors.blue.shade400, Colors.cyan.shade300],
                isDark: isDark,
              ),
              _buildGameCard(
                title: 'Typing',
                subtitle: 'Пиши верно',
                icon: Icons.keyboard,
                gradientColors: [Colors.purple.shade400, Colors.pink.shade300],
                isDark: isDark,
              ),
              _buildGameCard(
                title: 'Speed 60s',
                subtitle: 'На скорость',
                icon: Icons.timer,
                gradientColors: [Colors.orange.shade400, Colors.yellow.shade300],
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required bool isDark,
  }) {
    return Container(
      width: 144,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: isDark ? _surfaceDark : _surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 96,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 40,
                shadows: const [
                  Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== RECOMMENDED SECTION ====================
  Widget _buildRecommendedSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Рекомендуем',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
              ),
            ),
          ),
          _buildRecommendedCard(
            icon: Icons.restaurant,
            iconBgColor: isDark ? Colors.indigo.shade900.withOpacity(0.3) : Colors.indigo.shade100,
            iconColor: Colors.indigo.shade500,
            title: 'Еда и напитки (A2)',
            subtitle: '45 слов • Популярное',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildRecommendedCard(
            icon: Icons.work,
            iconBgColor: isDark ? _emerald.withOpacity(0.2) : const Color(0xFFD1FAE5),
            iconColor: _emerald,
            title: 'Бизнес немецкий',
            subtitle: '30 слов • Для работы',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? _surfaceDark : _surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.add,
                  size: 20,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== WEEKLY STATS SECTION ====================
  Widget _buildWeeklyStatsSection(BuildContext context, bool isDark) {
    final weekData = [
      {'day': 'Пн', 'value': 0.40, 'isToday': false},
      {'day': 'Вт', 'value': 0.65, 'isToday': false},
      {'day': 'Ср', 'value': 0.30, 'isToday': false},
      {'day': 'Чт', 'value': 0.85, 'isToday': false},
      {'day': 'Пт', 'value': 0.95, 'isToday': true},
      {'day': 'Сб', 'value': 0.10, 'isToday': false},
      {'day': 'Вс', 'value': 0.00, 'isToday': false},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? _surfaceDark : _surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
          ),
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Статистика недели',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.green.shade900.withOpacity(0.2) : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+12%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Chart
            SizedBox(
              height: 96,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: weekData.map((data) {
                  return Expanded(
                    child: _buildDayBar(
                      day: data['day'] as String,
                      value: data['value'] as double,
                      isToday: data['isToday'] as bool,
                      isDark: isDark,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayBar({
    required String day,
    required double value,
    required bool isToday,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  FractionallySizedBox(
                    heightFactor: value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isToday
                            ? _primaryColor
                            : value > 0
                                ? _primaryColor.withOpacity(0.3)
                                : (isDark ? Colors.grey.shade600 : Colors.grey.shade200),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        boxShadow: isToday ? [
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            day,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
              color: isToday
                  ? (isDark ? Colors.white : Colors.grey.shade900)
                  : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BOTTOM NAVIGATION ====================
  Widget _buildBottomNavigation(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? _surfaceDark : _surfaceLight).withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                icon: Icons.home,
                filledIcon: Icons.home,
                label: 'Главная',
                index: 0,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.style_outlined,
                filledIcon: Icons.style,
                label: 'Наборы',
                index: 1,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.sports_esports_outlined,
                filledIcon: Icons.sports_esports,
                label: 'Игры',
                index: 2,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                filledIcon: Icons.person,
                label: 'Профиль',
                index: 3,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData filledIcon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    final isSelected = _currentNavIndex == index;

    return GestureDetector(
      onTap: () => _handleNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : icon,
              size: 28,
              color: isSelected ? _primaryColor : Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected ? _primaryColor : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavTap(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.categories);
      return;
    }

    if (_currentNavIndex == index) return;
    setState(() => _currentNavIndex = index);
  }
}

// ==================== CIRCULAR PROGRESS PAINTER ====================
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    this.strokeWidth = 6.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}
