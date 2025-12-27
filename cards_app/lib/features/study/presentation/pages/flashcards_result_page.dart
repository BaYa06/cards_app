import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Модель результатов тренировки
class FlashcardsResult {
  final int totalCards;
  final int learnedCards;
  final int errors;
  final Duration duration;
  final List<CardResult> cardResults;

  FlashcardsResult({
    required this.totalCards,
    required this.learnedCards,
    required this.errors,
    required this.duration,
    this.cardResults = const [],
  });

  double get accuracy => totalCards > 0 ? (learnedCards / totalCards) * 100 : 0;
  
  String get formattedDuration {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Результат по отдельной карточке
class CardResult {
  final String germanWord;
  final String translation;
  final bool isCorrect;
  final int confidenceLevel; // 0-3

  CardResult({
    required this.germanWord,
    required this.translation,
    required this.isCorrect,
    required this.confidenceLevel,
  });
}

class FlashcardsResultPage extends StatelessWidget {
  final FlashcardsResult result;
  final VoidCallback? onNextCards;
  final VoidCallback? onRepeatErrors;
  final VoidCallback? onRepeatAll;

  const FlashcardsResultPage({
    super.key,
    required this.result,
    this.onNextCards,
    this.onRepeatErrors,
    this.onRepeatAll,
  });

  static const _primary = Color(0xFF2D2DE6);
  static const _bgLight = Color(0xFFF6F6F8);
  static const _bgDark = Color(0xFF111121);
  static const _surfaceLight = Colors.white;
  static const _surfaceDark = Color(0xFF1E1E2F);

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
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Hero Section
                    _buildHeroSection(isDark),
                    const SizedBox(height: 32),
                    // Statistics Card
                    _buildStatisticsCard(isDark),
                    const SizedBox(height: 24),
                    // Detailed Review Button
                    _buildReviewButton(context, isDark),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildIconButton(
            icon: Icons.arrow_back,
            isDark: isDark,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'Flashcards',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ),
          _buildIconButton(
            icon: Icons.settings_outlined,
            isDark: isDark,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 24,
            color: isDark ? Colors.white : const Color(0xFF0E0E1B),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return Column(
      children: [
        // Medallion with glow
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            // Medal circle
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_primary, Color(0xFF3B82F6)],
                ),
                border: Border.all(
                  color: isDark ? _bgDark : Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                size: 48,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Title
        const Text(
          'Готово!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        // Subtitle with learned count
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0E0E1B),
            ),
            children: [
              const TextSpan(text: 'Выучено '),
              TextSpan(
                text: '${result.learnedCards} слов',
                style: const TextStyle(color: _primary),
              ),
              TextSpan(text: ' из ${result.totalCards}'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Encouragement text
        Text(
          _getEncouragementText(),
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  String _getEncouragementText() {
    final accuracy = result.accuracy;
    if (accuracy >= 90) return 'Превосходно! Ты молодец! 🌟';
    if (accuracy >= 70) return 'Отличная работа — продолжай серию!';
    if (accuracy >= 50) return 'Хорошее начало! Практикуйся дальше!';
    return 'Не сдавайся! С каждым разом лучше!';
  }

  Widget _buildStatisticsCard(bool isDark) {
    final surfaceColor = isDark ? _surfaceDark : _surfaceLight;
    final dividerColor = isDark ? Colors.grey.shade700.withOpacity(0.5) : Colors.grey.shade100;

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
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Accuracy
            Expanded(
              child: _buildStatItem(
                label: 'ТОЧНОСТЬ',
                value: '${result.accuracy.round()}%',
                valueColor: isDark ? Colors.white : Colors.grey.shade900,
                isDark: isDark,
              ),
            ),
            VerticalDivider(color: dividerColor, thickness: 1),
            // Time
            Expanded(
              child: _buildStatItem(
                label: 'ВРЕМЯ',
                value: result.formattedDuration,
                valueColor: isDark ? Colors.white : Colors.grey.shade900,
                isDark: isDark,
              ),
            ),
            VerticalDivider(color: dividerColor, thickness: 1),
            // Errors
            Expanded(
              child: _buildStatItem(
                label: 'ОШИБОК',
                value: '${result.errors}',
                valueColor: result.errors > 0 ? Colors.red.shade500 : Colors.green.shade500,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color valueColor,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewButton(BuildContext context, bool isDark) {
    final surfaceColor = isDark ? _surfaceDark : Colors.white;
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _showDetailedResults(context, isDark),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt, size: 20, color: _primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Посмотреть результат',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Список слов, ответы и ошибки',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailedResults(BuildContext context, bool isDark) {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? _surfaceDark : _surfaceLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Детальные результаты',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                // Results list
                Expanded(
                  child: result.cardResults.isEmpty
                      ? Center(
                          child: Text(
                            'Нет данных',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: result.cardResults.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final cardResult = result.cardResults[index];
                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: cardResult.isCorrect
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  cardResult.isCorrect ? Icons.check : Icons.close,
                                  color: cardResult.isCorrect
                                      ? Colors.green.shade600
                                      : Colors.red.shade600,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                cardResult.germanWord,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(cardResult.translation),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary CTA - Next cards
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                if (onNextCards != null) {
                  onNextCards!();
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Следующие карточки',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 22),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Secondary actions row
          Row(
            children: [
              // Repeat errors
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: result.errors > 0
                        ? () {
                            HapticFeedback.lightImpact();
                            if (onRepeatErrors != null) {
                              onRepeatErrors!();
                            }
                          }
                        : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(
                        color: isDark
                            ? Colors.red.shade900.withOpacity(0.3)
                            : Colors.red.shade100,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text(
                      'Повторить ошибки',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Repeat all
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (onRepeatAll != null) {
                        onRepeatAll!();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      side: BorderSide(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.school_outlined, size: 20),
                    label: const Text(
                      'Повторить слова',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
