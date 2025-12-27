import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Результаты игры Match
class MatchGameResult {
  final int totalPairs;
  final int matchedPairs;
  final int mistakes;
  final int maxCombo;
  final Duration duration;

  MatchGameResult({
    required this.totalPairs,
    required this.matchedPairs,
    required this.mistakes,
    required this.maxCombo,
    required this.duration,
  });

  double get accuracy => totalPairs > 0 
      ? ((matchedPairs / (matchedPairs + mistakes)) * 100).clamp(0, 100) 
      : 0;

  String get formattedDuration {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  int get stars {
    if (mistakes == 0 && matchedPairs == totalPairs) return 3;
    if (mistakes <= 2 && matchedPairs == totalPairs) return 2;
    if (matchedPairs >= totalPairs * 0.5) return 1;
    return 0;
  }
}

class MatchGameResultPage extends StatefulWidget {
  final MatchGameResult result;
  final VoidCallback? onPlayAgain;
  final VoidCallback? onExit;

  const MatchGameResultPage({
    super.key,
    required this.result,
    this.onPlayAgain,
    this.onExit,
  });

  @override
  State<MatchGameResultPage> createState() => _MatchGameResultPageState();
}

class _MatchGameResultPageState extends State<MatchGameResultPage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  static const _primary = Color(0xFF2DA9E6);
  static const _bgLight = Color(0xFFF6F7F8);
  static const _bgDark = Color(0xFF111C21);
  static const _surfaceLight = Colors.white;
  static const _surfaceDark = Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? _bgDark : _bgLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildHeroSection(isDark),
                    const SizedBox(height: 32),
                    _buildStatsCard(isDark),
                    const SizedBox(height: 24),
                    _buildAchievements(isDark),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Bottom Actions
            _buildBottomActions(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Icon(
                  Icons.close,
                  size: 24,
                  color: isDark ? Colors.white : const Color(0xFF0E171B),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Match',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 40), // Balance
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    final stars = widget.result.stars;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          // Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final isActive = index < stars;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  isActive ? Icons.star : Icons.star_border,
                  size: index == 1 ? 56 : 40,
                  color: isActive ? Colors.amber : Colors.grey.shade400,
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            _getTitleByStars(stars),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getSubtitleByStars(stars),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _getTitleByStars(int stars) {
    switch (stars) {
      case 3: return 'Превосходно! 🏆';
      case 2: return 'Отлично! 🎉';
      case 1: return 'Хорошо! 👍';
      default: return 'Попробуй ещё! 💪';
    }
  }

  String _getSubtitleByStars(int stars) {
    switch (stars) {
      case 3: return 'Идеальный результат без ошибок!';
      case 2: return 'Почти идеально, всего пара ошибок!';
      case 1: return 'Неплохое начало, продолжай практиковаться!';
      default: return 'С каждой попыткой будет лучше!';
    }
  }

  Widget _buildStatsCard(bool isDark) {
    final surfaceColor = isDark ? _surfaceDark : _surfaceLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main stats row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle_outline,
                  label: 'Пары',
                  value: '${widget.result.matchedPairs}/${widget.result.totalPairs}',
                  color: Colors.green,
                  isDark: isDark,
                ),
              ),
              _buildDivider(isDark),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.timer_outlined,
                  label: 'Время',
                  value: widget.result.formattedDuration,
                  color: _primary,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
          const SizedBox(height: 20),
          // Secondary stats row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.close,
                  label: 'Ошибки',
                  value: '${widget.result.mistakes}',
                  color: widget.result.mistakes > 0 ? Colors.red : Colors.green,
                  isDark: isDark,
                ),
              ),
              _buildDivider(isDark),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.local_fire_department,
                  label: 'Макс. комбо',
                  value: 'x${widget.result.maxCombo}',
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 60,
      color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
    );
  }

  Widget _buildAchievements(bool isDark) {
    final achievements = <Map<String, dynamic>>[];

    if (widget.result.mistakes == 0) {
      achievements.add({
        'icon': Icons.stars,
        'title': 'Безупречно',
        'subtitle': 'Ни одной ошибки',
        'color': Colors.amber,
      });
    }

    if (widget.result.maxCombo >= 5) {
      achievements.add({
        'icon': Icons.local_fire_department,
        'title': 'Комбо мастер',
        'subtitle': 'Комбо x${widget.result.maxCombo}',
        'color': Colors.orange,
      });
    }

    if (widget.result.duration.inSeconds < 60) {
      achievements.add({
        'icon': Icons.speed,
        'title': 'Молния',
        'subtitle': 'Меньше минуты',
        'color': _primary,
      });
    }

    if (achievements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Достижения',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ...achievements.map((a) => _buildAchievementTile(a, isDark)),
      ],
    );
  }

  Widget _buildAchievementTile(Map<String, dynamic> achievement, bool isDark) {
    final surfaceColor = isDark ? _surfaceDark : _surfaceLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (achievement['color'] as Color).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (achievement['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              achievement['icon'] as IconData,
              color: achievement['color'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  achievement['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play Again button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                if (widget.onPlayAgain != null) {
                  widget.onPlayAgain!();
                } else {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: _primary.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text(
                'Играть снова',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Exit button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                if (widget.onExit != null) {
                  widget.onExit!();
                } else {
                  Navigator.of(context).pop();
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : Colors.grey.shade700,
                side: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Выйти',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
