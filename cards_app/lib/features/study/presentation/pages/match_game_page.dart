import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/models/flash_card.dart';
import '../../../../data/repositories/app_repository.dart';
import '../../../categories/domain/entities/category_set.dart';
import 'match_game_result_page.dart';

/// Состояние карточки в игре Match
enum MatchCardState {
  normal,
  selected,
  matched,
  error,
}

/// Модель карточки для игры Match
class MatchCard {
  final String id;
  final String text;
  final bool isGerman;
  final String pairId; // ID для сопоставления пары
  MatchCardState state;

  MatchCard({
    required this.id,
    required this.text,
    required this.isGerman,
    required this.pairId,
    this.state = MatchCardState.normal,
  });
}

class MatchGamePage extends StatefulWidget {
  final CategorySet set;
  final int pairsCount;

  const MatchGamePage({
    super.key,
    required this.set,
    this.pairsCount = 10,
  });

  @override
  State<MatchGamePage> createState() => _MatchGamePageState();
}

class _MatchGamePageState extends State<MatchGamePage> with TickerProviderStateMixin {
  final AppRepository _repo = AppRepository();
  
  // Игровое состояние
  List<MatchCard> _germanCards = [];
  List<MatchCard> _russianCards = [];
  MatchCard? _selectedCard;
  
  // Статистика
  int _matchedPairs = 0;
  int _totalPairs = 0;
  int _mistakes = 0;
  int _combo = 0;
  int _maxCombo = 0;
  
  // Таймер
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isPaused = false;
  
  // Состояние загрузки
  bool _loading = true;
  String? _error;
  
  // Анимации
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // Цвета
  static const _primary = Color(0xFF2DA9E6);
  static const _bgLight = Color(0xFFF6F7F8);
  static const _bgDark = Color(0xFF111C21);
  static const _surfaceLight = Colors.white;
  static const _surfaceDark = Color(0xFF1E293B);
  static const _borderLight = Color(0xFFD0DFE6);
  static const _borderDark = Color(0xFF334155);

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _loadCards();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  String get _formattedTime {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _loadCards() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _repo.initialize();
      var cards = await _repo.getCardsByCategory(widget.set.id);
      
      if (cards.isEmpty) {
        if (!mounted) return;
        setState(() {
          _error = 'Нет карточек в этом наборе';
          _loading = false;
        });
        return;
      }

      // Перемешиваем и берем нужное количество
      cards.shuffle();
      final pairsToUse = cards.take(widget.pairsCount).toList();
      _totalPairs = pairsToUse.length;

      // Создаем карточки для игры
      _germanCards = [];
      _russianCards = [];

      for (int i = 0; i < pairsToUse.length; i++) {
        final card = pairsToUse[i];
        final pairId = 'pair_$i';

        _germanCards.add(MatchCard(
          id: 'german_$i',
          text: card.fullGermanWord,
          isGerman: true,
          pairId: pairId,
        ));

        _russianCards.add(MatchCard(
          id: 'russian_$i',
          text: card.russianTranslation,
          isGerman: false,
          pairId: pairId,
        ));
      }

      // Перемешиваем колонки отдельно
      _germanCards.shuffle();
      _russianCards.shuffle();

      if (!mounted) return;
      setState(() {
        _loading = false;
        _matchedPairs = 0;
        _mistakes = 0;
        _combo = 0;
        _maxCombo = 0;
        _elapsedSeconds = 0;
        _selectedCard = null;
      });

      _startTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Ошибка загрузки: $e';
        _loading = false;
      });
    }
  }

  void _onCardTap(MatchCard card) {
    if (_isPaused || card.state == MatchCardState.matched) return;

    HapticFeedback.lightImpact();

    setState(() {
      // Если это та же карточка - снимаем выделение
      if (_selectedCard?.id == card.id) {
        _selectedCard!.state = MatchCardState.normal;
        _selectedCard = null;
        return;
      }

      // Если ничего не выбрано
      if (_selectedCard == null) {
        card.state = MatchCardState.selected;
        _selectedCard = card;
        return;
      }

      // Если выбраны карточки из одной колонки
      if (_selectedCard!.isGerman == card.isGerman) {
        _selectedCard!.state = MatchCardState.normal;
        card.state = MatchCardState.selected;
        _selectedCard = card;
        return;
      }

      // Проверяем пару
      if (_selectedCard!.pairId == card.pairId) {
        // Правильная пара!
        HapticFeedback.mediumImpact();
        _selectedCard!.state = MatchCardState.matched;
        card.state = MatchCardState.matched;
        _selectedCard = null;
        _matchedPairs++;
        _combo++;
        if (_combo > _maxCombo) _maxCombo = _combo;

        // Проверяем завершение игры
        if (_matchedPairs >= _totalPairs) {
          _timer?.cancel();
          Future.delayed(const Duration(milliseconds: 500), _showResults);
        }
      } else {
        // Неправильная пара
        HapticFeedback.heavyImpact();
        _shakeController.forward(from: 0);
        card.state = MatchCardState.error;
        _selectedCard!.state = MatchCardState.error;
        _mistakes++;
        _combo = 0;

        // Сбрасываем состояние через 500мс
        final prevSelected = _selectedCard;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          setState(() {
            card.state = MatchCardState.normal;
            prevSelected?.state = MatchCardState.normal;
          });
        });
        _selectedCard = null;
      }
    });
  }

  void _togglePause() {
    HapticFeedback.lightImpact();
    setState(() => _isPaused = !_isPaused);
  }

  void _resetProgress() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Сбросить прогресс?'),
        content: const Text('Текущий прогресс будет потерян'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _loadCards();
            },
            style: FilledButton.styleFrom(backgroundColor: _primary),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }

  void _loadNextPairs() {
    HapticFeedback.mediumImpact();
    _loadCards();
  }

  void _showResults() {
    final result = MatchGameResult(
      totalPairs: _totalPairs,
      matchedPairs: _matchedPairs,
      mistakes: _mistakes,
      maxCombo: _maxCombo,
      duration: Duration(seconds: _elapsedSeconds),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MatchGameResultPage(
          result: result,
          onPlayAgain: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MatchGamePage(
                  set: widget.set,
                  pairsCount: widget.pairsCount,
                ),
              ),
            );
          },
          onExit: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? _bgDark : _bgLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(isDark),
                _buildProgressSection(isDark),
                _buildMetrics(isDark),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: _primary))
                      : _error != null
                          ? _buildErrorState(isDark)
                          : _buildGameArea(isDark),
                ),
              ],
            ),
            // Fixed Footer
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildFooter(isDark),
            ),
            // Pause Overlay
            if (_isPaused) _buildPauseOverlay(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          _buildIconButton(
            icon: Icons.arrow_back,
            isDark: isDark,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'Match',
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
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 28,
            color: isDark ? Colors.white : const Color(0xFF0E171B),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(bool isDark) {
    final progress = _totalPairs > 0 ? _matchedPairs / _totalPairs : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Пары: $_matchedPairs/$_totalPairs',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF0E171B),
                ),
              ),
              Text(
                _formattedTime,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace',
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4F7F96),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: isDark ? _borderDark : _borderLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Соедини слово с переводом',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4F7F96),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics(bool isDark) {
    final surfaceColor = isDark ? _surfaceDark : _surfaceLight;
    final borderColor = isDark ? _borderDark : _borderLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Combo
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'x$_combo',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'КОМБО',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4F7F96),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Mistakes
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_mistakes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ОШИБКИ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4F7F96),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // German column
          Expanded(
            child: Column(
              children: _germanCards
                  .map((card) => _buildCard(card, isDark))
                  .toList(),
            ),
          ),
          const SizedBox(width: 12),
          // Russian column
          Expanded(
            child: Column(
              children: _russianCards
                  .map((card) => _buildCard(card, isDark))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(MatchCard card, bool isDark) {
    final surfaceColor = isDark ? _surfaceDark : _surfaceLight;
    final borderColor = isDark ? _borderDark : _borderLight;

    Color bgColor;
    Color textColor;
    Color cardBorderColor;
    double borderWidth = 1;

    switch (card.state) {
      case MatchCardState.selected:
        bgColor = _primary.withOpacity(0.1);
        textColor = _primary;
        cardBorderColor = _primary;
        borderWidth = 2;
        break;
      case MatchCardState.matched:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        cardBorderColor = Colors.green.shade400;
        borderWidth = 2;
        break;
      case MatchCardState.error:
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        cardBorderColor = Colors.red.shade400;
        borderWidth = 2;
        break;
      case MatchCardState.normal:
      default:
        bgColor = surfaceColor;
        textColor = isDark ? Colors.white : const Color(0xFF0E171B);
        cardBorderColor = borderColor;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          double offset = 0;
          if (card.state == MatchCardState.error) {
            offset = _shakeAnimation.value * 8 * (1 - _shakeAnimation.value) * 
                    ((_shakeAnimation.value * 10).floor() % 2 == 0 ? 1 : -1);
          }
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: card.state == MatchCardState.matched
                ? null
                : () => _onCardTap(card),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 80),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cardBorderColor,
                  width: borderWidth,
                ),
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: card.state == MatchCardState.selected 
                        ? FontWeight.bold 
                        : FontWeight.w500,
                    color: textColor,
                  ),
                  child: Text(
                    card.text,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    final surfaceColor = isDark ? _surfaceDark : _surfaceLight;
    final borderColor = isDark ? _borderDark : _borderLight;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.95),
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Pause button
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _togglePause,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : const Color(0xFF0E171B),
                      side: BorderSide(color: borderColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                    label: Text(
                      _isPaused ? 'Продолжить' : 'Пауза',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Next pairs button
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _loadNextPairs,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: _primary.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    label: const Text(
                      'Следующие пары',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _resetProgress,
            child: Text(
              'Сбросить прогресс',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4F7F96),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay(bool isDark) {
    return Container(
      color: (isDark ? Colors.black : Colors.white).withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pause_circle_outline,
              size: 80,
              color: _primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Пауза',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Время: $_formattedTime',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _togglePause,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text(
                'Продолжить',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: isDark ? Colors.red.shade300 : Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadCards,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
              style: FilledButton.styleFrom(backgroundColor: _primary),
            ),
          ],
        ),
      ),
    );
  }
}
