import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/models/flash_card.dart';
import '../../../../data/models/card_progress.dart';
import '../../../../data/repositories/app_repository.dart';
import '../../../categories/domain/entities/category_set.dart';
import 'flashcards_result_page.dart';

/// Уровень уверенности при ответе (SRS)
enum ConfidenceLevel {
  dontKnow,   // Не знаю
  doubt,      // Сомневаюсь
  almost,     // Почти
  confident,  // Уверенно
}

class FlashcardsPage extends StatefulWidget {
  final CategorySet set;
  final bool onlyUnknown;
  final bool showMnemonic;
  final int? limit;

  const FlashcardsPage({
    super.key,
    required this.set,
    this.onlyUnknown = false,
    this.showMnemonic = true,
    this.limit,
  });

  @override
  State<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> with SingleTickerProviderStateMixin {
  final AppRepository _repo = AppRepository();
  List<FlashCard> _cards = [];
  final Set<String> _favoriteIds = {};
  int _index = 0;
  bool _isFlipped = false;
  bool _loading = true;
  String? _error;

  // Статистика сессии
  DateTime? _sessionStartTime;
  final List<CardResult> _cardResults = [];
  int _learnedCount = 0;
  int _errorCount = 0;

  // Анимация переворота карточки
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // Цвета
  static const _primary = Color(0xFF2D65E6);
  static const _bgLight = Color(0xFFF6F6F8);
  static const _bgDark = Color(0xFF111621);
  static const _cardLight = Colors.white;
  static const _cardDark = Color(0xFF1E2532);

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _loadCards();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _repo.initialize();
      var cards = await _repo.getCardsByCategory(widget.set.id);

      if (widget.onlyUnknown) {
        final progressList = await _repo.getDueCards();
        final learnedIds = <String>{};
        for (final p in progressList) {
          if (p.status == CardStatus.mastered || p.status == CardStatus.reviewing) {
            learnedIds.add(p.cardId);
          }
        }
        cards = cards.where((c) => !learnedIds.contains(c.id?.toString())).toList();
      }

      cards.shuffle();
      if (widget.limit != null && widget.limit! < cards.length) {
        cards = cards.take(widget.limit!).toList();
      }

      // Загружаем избранное
      for (final card in cards) {
        if (card.isFavorite) {
          _favoriteIds.add(card.id.toString());
        }
      }

      if (!mounted) return;
      setState(() {
        _cards = cards;
        _index = 0;
        _isFlipped = false;
        _loading = false;
        // Сброс статистики
        _sessionStartTime = DateTime.now();
        _cardResults.clear();
        _learnedCount = 0;
        _errorCount = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Не удалось загрузить карточки: $e';
        _loading = false;
      });
    }
  }

  void _flipCard() {
    HapticFeedback.lightImpact();
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _toggleFavorite() {
    if (_cards.isEmpty) return;
    final cardId = _cards[_index].id.toString();
    HapticFeedback.selectionClick();
    setState(() {
      if (_favoriteIds.contains(cardId)) {
        _favoriteIds.remove(cardId);
      } else {
        _favoriteIds.add(cardId);
      }
    });
    // TODO: Сохранить в базу данных
  }

  void _playAudio() {
    HapticFeedback.lightImpact();
    // TODO: Воспроизвести аудио
  }

  void _skipCard() {
    // При пропуске считаем как ошибку
    _recordCardResult(ConfidenceLevel.dontKnow);
    _goToNext();
  }

  void _rateCard(ConfidenceLevel level) {
    HapticFeedback.mediumImpact();
    _recordCardResult(level);
    _goToNext();
  }

  void _recordCardResult(ConfidenceLevel level) {
    if (_cards.isEmpty || _index >= _cards.length) return;
    
    final card = _cards[_index];
    final isCorrect = level == ConfidenceLevel.confident || level == ConfidenceLevel.almost;
    
    _cardResults.add(CardResult(
      germanWord: card.fullGermanWord,
      translation: card.russianTranslation,
      isCorrect: isCorrect,
      confidenceLevel: level.index,
    ));
    
    if (isCorrect) {
      _learnedCount++;
    } else {
      _errorCount++;
    }
    
    // TODO: Сохранить прогресс в SRS систему
  }

  void _goToNext() {
    if (_cards.isEmpty) return;
    if (_index + 1 >= _cards.length) {
      _showResultsPage();
      return;
    }
    
    // Сбрасываем состояние карточки
    _flipController.reset();
    setState(() {
      _isFlipped = false;
      _index++;
    });
  }

  void _showResultsPage() {
    final duration = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!)
        : Duration.zero;
    
    final result = FlashcardsResult(
      totalCards: _cards.length,
      learnedCards: _learnedCount,
      errors: _errorCount,
      duration: duration,
      cardResults: List.from(_cardResults),
    );
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => FlashcardsResultPage(
          result: result,
          onNextCards: () {
            // Загрузить новые карточки
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => FlashcardsPage(
                  set: widget.set,
                  onlyUnknown: widget.onlyUnknown,
                  showMnemonic: widget.showMnemonic,
                  limit: widget.limit,
                ),
              ),
            );
          },
          onRepeatErrors: () {
            // TODO: Повторить только ошибки
            Navigator.of(context).pop();
          },
          onRepeatAll: () {
            // Повторить все карточки
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => FlashcardsPage(
                  set: widget.set,
                  onlyUnknown: false,
                  showMnemonic: widget.showMnemonic,
                  limit: widget.limit,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openSettings() {
    // TODO: Открыть настройки
    HapticFeedback.lightImpact();
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
            _buildHeader(isDark),
            // Progress Bar
            _buildProgressBar(isDark),
            // Main Content
            Expanded(
              child: _loading
                  ? _buildLoadingState()
                  : _error != null
                      ? _buildErrorState(isDark)
                      : _cards.isEmpty
                          ? _buildEmptyState(isDark)
                          : _buildCardContent(isDark),
            ),
            // Bottom SRS Panel
            if (!_loading && _cards.isNotEmpty && _error == null)
              _buildSRSPanel(isDark),
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
            onTap: _openSettings,
            iconSize: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
    double iconSize = 28,
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
            size: iconSize,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(bool isDark) {
    final current = _cards.isEmpty ? 0 : _index + 1;
    final total = _cards.length;
    final progress = total == 0 ? 0.0 : current / total;
    final estimatedMinutes = (total * 0.3).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$current/$total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              Text(
                '~$estimatedMinutes мин',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
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
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: _primary),
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
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 56,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Нет карточек для изучения',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте слова в набор, чтобы учить их здесь',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(bool isDark) {
    final card = _cards[_index];
    final isFavorite = _favoriteIds.contains(card.id.toString());

    return Column(
      children: [
        // Карточка
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final angle = _flipAnimation.value * 3.14159;
                    final isBack = _flipAnimation.value >= 0.5;
                    
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: isBack
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(3.14159),
                              child: _buildCardFace(card, true, isDark),
                            )
                          : _buildCardFace(card, false, isDark),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        // Secondary Actions
        _buildSecondaryActions(isDark, isFavorite),
      ],
    );
  }

  Widget _buildCardFace(FlashCard card, bool isBack, bool isDark) {
    final cardColor = isDark ? _cardDark : _cardLight;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    
    // Контент в зависимости от стороны
    final mainText = isBack ? card.russianTranslation : card.fullGermanWord;
    final subText = isBack ? (card.exampleTranslation ?? '') : (card.exampleSentence ?? '');
    
    // Мнемоника (только на обратной стороне)
    final mnemonic = _generateMnemonic(card);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340, maxHeight: 420),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Top action (audio)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildCardActionButton(
                  icon: Icons.volume_up,
                  isDark: isDark,
                  onTap: _playAudio,
                ),
              ],
            ),
            // Card content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    mainText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 48,
                    height: 2,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (subText.isNotEmpty)
                    Text(
                      subText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
            // Mnemonic hint (visible on back side with mnemonic enabled)
            if (isBack && widget.showMnemonic && mnemonic != null)
              _buildMnemonicHint(mnemonic, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCardActionButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isDark ? const Color(0xFF334155).withOpacity(0.5) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 24,
            color: _primary,
          ),
        ),
      ),
    );
  }

  String? _generateMnemonic(FlashCard card) {
    // Генерация простой мнемоники на основе слова
    // В реальном приложении это может быть из базы данных
    final word = card.germanWord.toLowerCase();
    
    // Примеры мнемоник (можно расширить)
    final mnemonics = <String, String>{
      'scharf': 'Острый, жгучий шарф на шее',
      'schnell': 'Шнель - снаряд летит быстро',
      'haus': 'Хаус (house) - дом',
      'buch': 'Бух! - книга упала',
    };
    
    return mnemonics[word];
  }

  Widget _buildMnemonicHint(String mnemonic, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF312E81).withOpacity(0.2) 
            : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 18,
            color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4F46E5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mnemonic,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4F46E5),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryActions(bool isDark, bool isFavorite) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Skip button
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _skipCard,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(
                    'Пропустить',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Favorite button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleFavorite,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  size: 24,
                  color: isFavorite 
                      ? Colors.amber.shade500 
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSRSPanel(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          Text(
            'Оцени, насколько уверенно знаешь',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Не знаю
              Expanded(
                child: _buildSRSButton(
                  label: 'Не знаю',
                  bgColor: isDark 
                      ? const Color(0xFF7F1D1D).withOpacity(0.2) 
                      : const Color(0xFFFEF2F2),
                  textColor: isDark 
                      ? const Color(0xFFFCA5A5) 
                      : const Color(0xFFDC2626),
                  onTap: () => _rateCard(ConfidenceLevel.dontKnow),
                ),
              ),
              const SizedBox(width: 8),
              // Сомневаюсь
              Expanded(
                child: _buildSRSButton(
                  label: 'Сомнев...',
                  bgColor: isDark 
                      ? const Color(0xFF78350F).withOpacity(0.2) 
                      : const Color(0xFFFFF7ED),
                  textColor: isDark 
                      ? const Color(0xFFFDBA74) 
                      : const Color(0xFFEA580C),
                  onTap: () => _rateCard(ConfidenceLevel.doubt),
                ),
              ),
              const SizedBox(width: 8),
              // Почти
              Expanded(
                child: _buildSRSButton(
                  label: 'Почти',
                  bgColor: isDark 
                      ? const Color(0xFF0C4A6E).withOpacity(0.2) 
                      : const Color(0xFFF0F9FF),
                  textColor: isDark 
                      ? const Color(0xFF7DD3FC) 
                      : const Color(0xFF0284C7),
                  onTap: () => _rateCard(ConfidenceLevel.almost),
                ),
              ),
              const SizedBox(width: 8),
              // Уверенно
              Expanded(
                child: _buildSRSButton(
                  label: 'Уверенно',
                  bgColor: _primary,
                  textColor: Colors.white,
                  isPrimary: true,
                  onTap: () => _rateCard(ConfidenceLevel.confident),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSRSButton({
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      elevation: isPrimary ? 4 : 0,
      shadowColor: isPrimary ? _primary.withOpacity(0.4) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
