import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/category_set.dart';

/// Модалка выбора режима обучения
class StudyModeSheet extends StatefulWidget {
  final CategorySet set;
  final int wordsCount;

  const StudyModeSheet({
    super.key,
    required this.set,
    required this.wordsCount,
  });

  @override
  State<StudyModeSheet> createState() => _StudyModeSheetState();
}

class _StudyModeSheetState extends State<StudyModeSheet> {
  static const Color _primary = Color(0xFF2D65E6);
  bool _onlyUnknown = false;
  bool _showMnemonic = true;
  late String _countOption;
  String _mode = 'flashcards';

  int get _displayCount {
    if (_countOption == 'Все') return widget.wordsCount;
    return int.tryParse(_countOption) ?? min(20, widget.wordsCount);
  }

  @override
  void initState() {
    super.initState();
    final options = _availableCountOptions();
    _countOption = options.contains('20') ? '20' : options.first;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? Colors.grey.shade700 : Colors.grey.shade200;
    final bg = isDark ? const Color(0xFF111621) : const Color(0xFFF6F6F8);

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 0.88,
            builder: (context, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 30,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildHeader(isDark),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _recommendedCard(isDark, surface, border),
                            const SizedBox(height: 18),
                            _games(isDark, surface, border),
                            const SizedBox(height: 18),
                            _settings(isDark, surface, border),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                    _bottomAction(isDark),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final border = isDark ? Colors.grey.shade700 : Colors.grey.shade200;
    final textColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111621) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Выбор режима',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: textColor,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                child: const Text('Отмена'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Набор: ${widget.set.title}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: textColor,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                '${widget.wordsCount} слов',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recommendedCard(bool isDark, Color surface, Color border) {
    final chipColor = isDark ? Colors.white : Colors.white;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _primary.withOpacity(0.25), width: 2),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Recommended',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
              const Spacer(),
              Icon(Icons.style, color: _primary),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Text(
                'Flashcards',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              SizedBox(width: 8),
              Icon(Icons.check_circle, color: _primary, size: 18),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Переворот 180° • ${_directionLabel()}',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: subtitleColor),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.1) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'scharf',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Нажми, чтобы перевернуть',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.cached, color: _primary.withOpacity(0.8)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip('Не знаю', Colors.red.shade50, Colors.red.shade500, isDark),
              _chip('Сомневаюсь', Colors.orange.shade50, Colors.orange.shade500, isDark),
              _chip('Почти', Colors.blue.shade50, Colors.blue.shade500, isDark),
              _chip('Уверенно', Colors.green.shade50, Colors.green.shade500, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color lightBg, Color textColor, bool isDark) {
    final bg = isDark ? lightBg.withOpacity(0.16) : lightBg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _games(bool isDark, Color surface, Color border) {
    final subtitle = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    final rows = [
      ('Match', 'Сопоставление слов и переводов', Icons.join_inner, Colors.purple, true),
      ('Multiple Choice', 'Выбери правильный из 4 вариантов', Icons.checklist, Colors.teal, false),
      ('Memory Flip', 'Найди пары карточек', Icons.flip, Colors.amber, false),
      ('Word Builder', 'Собери слово из букв', Icons.sort_by_alpha, Colors.indigo, false),
      ('Audio Tap', 'Прослушай и выбери верное', Icons.headphones, Colors.pink, false),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Игры для закрепления',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: subtitle,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: rows
              .map(
                (row) => _buildGameRow(
                  title: row.$1,
                  subtitle: row.$2,
                  icon: row.$3,
                  color: row.$4,
                  isEnabled: row.$5,
                  isDark: isDark,
                  surface: surface,
                  border: border,
                  subtitleColor: subtitle,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildGameRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isEnabled,
    required bool isDark,
    required Color surface,
    required Color border,
    required Color subtitleColor,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: isEnabled
              ? () {
                  if (title == 'Match') {
                    Navigator.of(context).pop({
                      'mode': 'match',
                      'count': _countOption == 'Все' ? null : _displayCount,
                    });
                  }
                }
              : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                          if (!isEnabled) ...[                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Скоро',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: subtitleColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  isEnabled ? Icons.chevron_right : Icons.lock_outline,
                  color: subtitleColor,
                  size: isEnabled ? 24 : 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _settings(bool isDark, Color surface, Color border) {
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subtitle = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Настройки',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: subtitle,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Column(
            children: [
              _settingsRow(
                label: 'Только «Не запомнил»',
                trailing: Switch.adaptive(
                  value: _onlyUnknown,
                  activeColor: _primary,
                  onChanged: (v) => setState(() => _onlyUnknown = v),
                ),
                titleColor: titleColor,
              ),
              Divider(color: border, height: 1),
              _settingsRow(
                label: 'Количество слов',
                trailing: _countDropdown(isDark),
                titleColor: titleColor,
              ),
              Divider(color: border, height: 1),
              _settingsRow(
                label: 'Показывать мнемонику после ошибки',
                trailing: Switch.adaptive(
                  value: _showMnemonic,
                  activeColor: _primary,
                  onChanged: (v) => setState(() => _showMnemonic = v),
                ),
                titleColor: titleColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _settingsRow({
    required String label,
    required Widget trailing,
    required Color titleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _countDropdown(bool isDark) {
    final options = _availableCountOptions();
    final border = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    if (!options.contains(_countOption) && options.isNotEmpty) {
      _countOption = options.first;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _countOption,
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontWeight: FontWeight.w700))))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _countOption = v);
          },
        ),
      ),
    );
  }

  Widget _bottomAction(bool isDark) {
    final subtitle = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
              child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'mode': _mode,
                  'onlyUnknown': _onlyUnknown,
                  'showMnemonic': _showMnemonic,
                  'count': _countOption == 'Все' ? null : _displayCount,
                });
              },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 6,
                shadowColor: _primary.withOpacity(0.3),
              ),
              child: const Text(
                'Начать',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Режим: Flashcards • $_displayCount слов',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: subtitle),
          ),
        ],
      ),
    );
  }

  String _directionLabel() {
    return 'Немецкий → Русский';
  }

  List<String> _availableCountOptions() {
    final base = ['10', '20', '30', 'Все'];
    return base
        .where((o) {
          if (o == 'Все') return true;
          final parsed = int.tryParse(o);
          if (parsed == null) return false;
          return widget.wordsCount >= parsed || parsed <= 10;
        })
        .toList();
  }
}
