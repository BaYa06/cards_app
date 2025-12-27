import 'package:flutter/material.dart';
import '../../../../data/models/flash_card.dart';
import '../../../../data/repositories/app_repository.dart';
import '../../domain/entities/category_set.dart';

/// Экран добавления слов в набор
class AddWordPage extends StatefulWidget {
  final CategorySet set;

  const AddWordPage({super.key, required this.set});

  @override
  State<AddWordPage> createState() => _AddWordPageState();
}

class _AddWordPageState extends State<AddWordPage> {
  static const Color _primaryColor = Color(0xFF2D2DE6);
  static const Color _backgroundLight = Color(0xFFF6F6F8);
  static const Color _backgroundDark = Color(0xFF111121);

  final _wordController = TextEditingController();
  final _translationController = TextEditingController();
  final AppRepository _repo = AppRepository();

  bool _addExample = false;
  bool _addMnemonic = false;
  bool _savingWord = false;
  bool _loading = true;
  String? _error;

  final List<_AddedWord> _addedWords = [];

  final List<String> _helperChars = const ['ä', 'ö', 'ü', 'ß'];

  @override
  void dispose() {
    _wordController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? _backgroundDark : _backgroundLight;

    final canAdd = !_savingWord &&
        _wordController.text.trim().isNotEmpty &&
        _translationController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
      child: Column(
        children: [
          _buildHeader(isDark),
          Expanded(
            child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 130),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainCard(isDark, canAdd),
                    const SizedBox(height: 12),
                    _buildAddedList(isDark),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back,
              size: 26,
              color: isDark ? Colors.white : Colors.grey.shade800,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Добавить слова',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Набор: ${widget.set.title}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: _primaryColor,
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            child: const Text('Готово'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(bool isDark, bool canAdd) {
    final surface = isDark ? const Color(0xFF1E1E2E) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabeledField(
            label: 'Слово (DE)',
            requiredMark: true,
            child: _wordInput(isDark),
          ),
          const SizedBox(height: 10),
          _buildHelperChips(isDark),
          const SizedBox(height: 16),
          _buildLabeledField(
            label: 'Перевод (RU)',
            requiredMark: true,
            child: _translationInput(isDark),
          ),
          const SizedBox(height: 16),
          _buildToggles(isDark),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canAdd ? _handleAddWord : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAdd
                    ? _primaryColor
                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade200),
                foregroundColor: canAdd
                    ? Colors.white
                    : (isDark ? Colors.grey.shade500 : Colors.grey.shade500),
                elevation: canAdd ? 3 : 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _savingWord
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.add, size: 20),
              label: const Text(
                'Добавить слово',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField({required String label, bool requiredMark = false, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            if (requiredMark) const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _wordInput(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.15) : const Color(0xFFF8F8FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _wordController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Например: scharf',
                hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.mic, color: _primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _translationInput(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.15) : const Color(0xFFF8F8FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _translationController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Например: острый',
          hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildHelperChips(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _helperChars
            .map(
              (char) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _insertChar(char),
                  child: Container(
                    height: 36,
                    width: 44,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade700 : const Color(0xFFE8E8F3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      char,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildToggles(bool isDark) {
    final labelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
    );
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Добавить пример', style: labelStyle),
            Switch.adaptive(
              value: _addExample,
              activeColor: _primaryColor,
              onChanged: (val) => setState(() => _addExample = val),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Добавить мнемонику', style: labelStyle),
            Switch.adaptive(
              value: _addMnemonic,
              activeColor: _primaryColor,
              onChanged: (val) => setState(() => _addMnemonic = val),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddedList(bool isDark) {
    final surface = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final border = isDark ? Colors.grey.shade800 : Colors.grey.shade100;

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _loadWords,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Добавлено (${_addedWords.length})',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 10),
        ..._addedWords.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.word,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.translation,
                        maxLines: 1,
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
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.edit, size: 20, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                    ),
                    IconButton(
                      onPressed: item.id == null ? null : () => _deleteWord(item),
                      icon: Icon(Icons.delete, size: 20, color: Colors.red.shade400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(bool isDark) {
    final surface = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final border = isDark ? Colors.grey.shade700 : Colors.grey.shade200;
    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.upload_file, size: 20),
                      label: const Text(
                        'Импорт из PDF',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: isDark ? Colors.white : Colors.grey.shade800,
                        side: BorderSide(color: border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        shadowColor: _primaryColor.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Сохранить и выйти',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Добавлено: ${_addedWords.length} слова • Автосохранение',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _insertChar(String char) {
    final text = _wordController.text;
    final selection = _wordController.selection;
    final newText = text.replaceRange(selection.start, selection.end, char);
    final newSelectionIndex = selection.start + char.length;
    _wordController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
    setState(() {});
  }

  Future<void> _handleAddWord() async {
    final word = _wordController.text.trim();
    final translation = _translationController.text.trim();
    if (word.isEmpty || translation.isEmpty) return;

    setState(() => _savingWord = true);
    try {
      await _repo.initialize();
      final id = 'card_${DateTime.now().millisecondsSinceEpoch}';
      final card = FlashCard(
        id: id,
        germanWord: word,
        russianTranslation: translation,
        categoryId: widget.set.id,
        partOfSpeech: 'noun',
      );
      await _repo.addCard(card);
      await _loadWords();

      if (!mounted) return;
      _wordController.clear();
      _translationController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Карточка добавлена')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось добавить: $e')),
      );
    } finally {
      if (mounted) setState(() => _savingWord = false);
    }
  }

  Future<void> _loadWords() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _repo.initialize();
      final cards = await _repo.getCardsByCategory(widget.set.id);
      if (!mounted) return;
      setState(() {
        _addedWords
          ..clear()
          ..addAll(cards.map((c) {
            final cid = c.id == null ? null : c.id.toString();
            return _AddedWord(id: cid, word: c.germanWord, translation: c.russianTranslation);
          }));
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

  Future<void> _deleteWord(_AddedWord word) async {
    if (word.id == null) return;
    try {
      await _repo.deleteCard(word.id!, widget.set.id);
      await _loadWords();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось удалить: $e')),
      );
    }
  }
}

class _AddedWord {
  final String? id;
  final String word;
  final String translation;

  const _AddedWord({this.id, required this.word, required this.translation});
}
