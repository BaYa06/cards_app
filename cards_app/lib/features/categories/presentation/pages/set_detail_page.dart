import 'package:flutter/material.dart';
import '../../../../core/router/app_router.dart';
import '../../../../data/models/card_progress.dart';
import '../../../../data/repositories/app_repository.dart';
import '../../domain/entities/category_set.dart';
import 'add_word_page.dart';

class SetDetailPage extends StatefulWidget {
  final CategorySet set;

  const SetDetailPage({super.key, required this.set});

  @override
  State<SetDetailPage> createState() => _SetDetailPageState();
}

class _SetDetailPageState extends State<SetDetailPage> {
  static const Color _primaryColor = Color(0xFF2D65E6);
  static const Color _backgroundLight = Color(0xFFF6F6F8);
  static const Color _backgroundDark = Color(0xFF111621);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _surfaceDark = Color(0xFF1E293B);

  List<_SetWord> _words = [];
  bool _loading = true;
  String? _error;
  int _filterIndex = 0;
  String _query = '';

  int get _wordCount => _loading ? widget.set.words : _words.length;

  double get _progressValue {
    if (_loading) return widget.set.progress;
    if (_words.isEmpty) return 0;
    final learned = _words.where((w) => w.learned).length;
    final value = learned / _words.length;
    return (value.clamp(0.0, 1.0)) as double;
  }

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = AppRepository();
      await repo.initialize();
      final cards = await repo.getCardsByCategory(widget.set.id);
      final loaded = <_SetWord>[];

      for (final card in cards) {
        final cardId = card.id == null ? '' : card.id.toString();
        CardProgress? progress;
        if (cardId.isNotEmpty) {
          progress = await repo.getCardProgress(cardId);
        }
        final learned = progress != null &&
            (progress.status == CardStatus.mastered ||
                progress.status == CardStatus.reviewing ||
                progress.isLearned);

        loaded.add(
          _SetWord(
            text: card.germanWord,
            translation: card.russianTranslation,
            learned: learned,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _words = loaded;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Не удалось загрузить слова: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? _backgroundDark : _backgroundLight;

    final filtered = _filteredWords();

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(isDark),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 110),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        _buildFilterSegment(isDark),
                        const SizedBox(height: 12),
                        _buildSearchRow(isDark),
                        const SizedBox(height: 12),
                        _buildContent(filtered, isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildBottomBar(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 10),
      decoration: BoxDecoration(
        color: (isDark ? _backgroundDark : _backgroundLight).withOpacity(0.97),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
              Expanded(
                child: Text(
                  widget.set.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.more_horiz,
                  size: 24,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$_wordCount слов',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.set.repeatLabel ?? 'К повторению сегодня: ${widget.set.repeatCount ?? 0}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange.shade400,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Освоено: ${(_progressValue * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: _progressValue,
                    minHeight: 8,
                    backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(_primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSegment(bool isDark) {
    final options = ['Все', 'Запомнил', 'Не запомнил'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200.withOpacity(0.8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: List.generate(options.length, (index) {
            final selected = _filterIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _filterIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? _primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      options[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? Colors.white
                            : isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSearchRow(bool isDark) {
    final surface = isDark ? _surfaceDark : _surfaceLight;
    final border = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Поиск по словам…',
                  hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Icon(Icons.sort, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_SetWord> _filteredWords() {
    return _words.where((word) {
      if (_filterIndex == 1 && !word.learned) return false;
      if (_filterIndex == 2 && word.learned) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return word.text.toLowerCase().contains(q) ||
          word.translation.toLowerCase().contains(q);
    }).toList();
  }

  Widget _buildContent(List<_SetWord> filtered, bool isDark) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loadWords,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _primaryColor.withOpacity(0.4)),
                foregroundColor: _primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Повторить загрузку'),
            ),
          ],
        ),
      );
    }

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              'Здесь пока нет слов',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Добавьте первые карточки, чтобы начать обучение',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _openAddWord,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Добавить карточку'),
            )
          ],
        ),
      );
    }

    return _buildGrid(filtered, isDark);
  }

  Widget _buildGrid(List<_SetWord> words, bool isDark) {
    final surface = isDark ? _surfaceDark : _surfaceLight;
    final border = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      child: GridView.builder(
        itemCount: words.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.25,
        ),
        itemBuilder: (context, index) {
          final word = words[index];
          final learned = word.learned;
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        word.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        word.translation,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: learned
                    ? Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check, size: 16, color: Colors.green.shade600),
                      )
                    : Icon(Icons.fiber_manual_record,
                        size: 12, color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: isDark ? Colors.grey.shade200 : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    final surface = isDark ? _surfaceDark : _surfaceLight;
    final border = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: surface.withOpacity(0.95),
          border: Border(top: BorderSide(color: border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openAddWord(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                      foregroundColor: isDark ? Colors.white : Colors.grey.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                    ),
                    child: const Text(
                      'Добавить карточку',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      shadowColor: _primaryColor.withOpacity(0.35),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Учить всё',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        Text(
                          'Будет включено: $_wordCount',
                          style: const TextStyle(fontSize: 10, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAddWord() {
    Navigator.of(context)
        .push(
          AppRouter.slideRoute(
            AddWordPage(set: widget.set),
          ),
        )
        .then((value) {
      if (value == true) {
        _loadWords();
      }
    });
  }
}

class _SetWord {
  final String text;
  final String translation;
  final bool learned;

  const _SetWord({
    required this.text,
    required this.translation,
    this.learned = false,
  });
}
