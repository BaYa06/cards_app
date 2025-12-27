import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../data/models/category.dart';
import '../../../../data/repositories/app_repository.dart';

/// Модальное окно создания набора
class CreateSetSheet extends StatefulWidget {
  final bool isDark;
  final Color primaryColor;
  final Color surfaceLight;
  final Color surfaceDark;

  const CreateSetSheet({
    super.key,
    required this.isDark,
    required this.primaryColor,
    required this.surfaceLight,
    required this.surfaceDark,
  });

  @override
  State<CreateSetSheet> createState() => _CreateSetSheetState();
}

class _CreateSetSheetState extends State<CreateSetSheet> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final AppRepository _repo = AppRepository();

  bool _isPrivate = true;
  bool _addWords = true;
  String _fromLanguage = 'Немецкий (DE)';
  String _toLanguage = 'Русский (RU)';
  String _category = 'Общие';
  bool _saving = false;

  final List<String> _languages = const [
    'Немецкий (DE)',
    'Английский (EN)',
    'Испанский (ES)',
    'Французский (FR)',
    'Русский (RU)',
    'Украинский (UA)',
  ];

  final List<String> _categories = const [
    'Общие',
    'Путешествия',
    'Еда',
    'Учёба',
    'Работа',
    'Грамматика',
    'Свой вариант…',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _descriptionController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final surface = isDark ? widget.surfaceDark : widget.surfaceLight;
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade200;
    final muted = isDark ? Colors.grey.shade400 : Colors.grey.shade500;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: const SizedBox(),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 0.88,
                child: Container(
                  decoration: BoxDecoration(
                    color: surface.withOpacity(0.98),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.14),
                        blurRadius: 30,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          width: 46,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Row(
                          children: [
                            const Text(
                              'Создать набор',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: widget.primaryColor,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              child: const Text('Отмена'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Название набора', requiredMark: true),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _nameController,
                                hint: 'Например: Путешествия (A1)',
                                isDark: isDark,
                                borderColor: borderColor,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Название будет видно в каталоге',
                                style: TextStyle(fontSize: 12, color: muted),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildLabel('Описание'),
                                  Text(
                                    '${_descriptionController.text.length}/200',
                                    style: TextStyle(fontSize: 12, color: muted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _descriptionController,
                                hint: 'Для каких тем/уровня и как использовать',
                                isDark: isDark,
                                borderColor: borderColor,
                                maxLines: 3,
                                maxLength: 200,
                              ),
                              const SizedBox(height: 18),
                              _buildLabel('Языки'),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdown(
                                      value: _fromLanguage,
                                      items: _languages,
                                      isDark: isDark,
                                      borderColor: borderColor,
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() => _fromLanguage = value);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _swapButton(isDark),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildDropdown(
                                      value: _toLanguage,
                                      items: _languages,
                                      isDark: isDark,
                                      borderColor: borderColor,
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() => _toLanguage = value);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Используется для импорта и тренировок',
                                style: TextStyle(fontSize: 12, color: muted),
                              ),
                              const SizedBox(height: 18),
                              _buildLabel('Категория'),
                              const SizedBox(height: 10),
                              _buildDropdown(
                                value: _category,
                                items: _categories,
                                isDark: isDark,
                                borderColor: borderColor,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _category = value);
                                  }
                                },
                              ),
                              const SizedBox(height: 18),
                              _buildLabel('Доступ'),
                              const SizedBox(height: 10),
                              _buildAccessToggle(isDark),
                              const SizedBox(height: 8),
                              Text(
                                'Публичные наборы видны другим и могут быть использованы в каталоге',
                                style: TextStyle(fontSize: 12, color: muted, height: 1.4),
                              ),
                              const SizedBox(height: 18),
                              const Divider(),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Сразу добавить слова',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: _addWords,
                                    activeColor: widget.primaryColor,
                                    onChanged: (value) => setState(() => _addWords = value),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _buildActionGrid(isDark),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                        decoration: BoxDecoration(
                          color: surface.withOpacity(0.98),
                          border: Border(
                            top: BorderSide(color: borderColor),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark ? Colors.grey.shade200 : Colors.grey.shade700,
                                  side: BorderSide(color: borderColor),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: const Text(
                                  'Отмена',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _nameController.text.trim().isEmpty || _saving
                                    ? null
                                    : _handleSave,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _nameController.text.trim().isEmpty || _saving
                                      ? (isDark ? Colors.grey.shade700 : Colors.grey.shade200)
                                      : widget.primaryColor,
                                  foregroundColor: _nameController.text.trim().isEmpty || _saving
                                      ? (isDark ? Colors.grey.shade400 : Colors.grey.shade600)
                                      : Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_saving) ...[
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    const Text(
                                      'Сохранить',
                                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool requiredMark = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (requiredMark) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required Color borderColor,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      style: TextStyle(
        fontSize: 15,
        color: isDark ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: widget.primaryColor, width: 1.6),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required bool isDark,
    required Color borderColor,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.expand_more, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _swapButton(bool isDark) {
    return Material(
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          setState(() {
            final temp = _fromLanguage;
            _fromLanguage = _toLanguage;
            _toLanguage = temp;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            Icons.sync_alt,
            size: 20,
            color: isDark ? Colors.grey.shade200 : widget.primaryColor,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      await _repo.initialize();
      final now = DateTime.now();
      final id = 'cat_${now.millisecondsSinceEpoch}';

      final color = _colorForCategory(_category);
      final icon = _iconForCategory(_category);

      final category = Category(
        id: id,
        name: name,
        description: description.isEmpty ? 'Пользовательская категория' : description,
        icon: icon,
        color: color,
        orderIndex: now.millisecondsSinceEpoch,
        isCustom: true,
        createdAt: now,
      );

      await _repo.createCategory(category);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось сохранить: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  int _colorForCategory(String category) {
    final palette = <String, int>{
      'Путешествия': 0xFF3B82F6,
      'Еда': 0xFFEF4444,
      'Учёба': 0xFF8B5CF6,
      'Работа': 0xFF10B981,
      'Грамматика': 0xFFF59E0B,
      'Общие': 0xFF2D65E6,
      'Свой вариант…': 0xFF6366F1,
    };
    if (palette.containsKey(category)) return palette[category]!;

    // случайный мягкий цвет
    final rand = Random();
    final colors = [
      0xFF3B82F6,
      0xFF10B981,
      0xFFF97316,
      0xFF8B5CF6,
      0xFFEC4899,
      0xFF14B8A6,
    ];
    return colors[rand.nextInt(colors.length)];
  }

  String _iconForCategory(String category) {
    const map = {
      'Путешествия': 'travel',
      'Еда': 'food',
      'Учёба': 'school',
      'Работа': 'work',
      'Грамматика': 'grammar',
      'Общие': 'category',
    };
    return map[category] ?? 'category';
  }

  Widget _buildAccessToggle(bool isDark) {
    final surface = isDark ? Colors.grey.shade800 : Colors.grey.shade100;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _accessChip(
            label: 'Приватный',
            selected: _isPrivate,
            isDark: isDark,
            onTap: () => setState(() => _isPrivate = true),
          ),
          _accessChip(
            label: 'Публичный',
            selected: !_isPrivate,
            isDark: isDark,
            onTap: () => setState(() => _isPrivate = false),
          ),
        ],
      ),
    );
  }

  Widget _accessChip({
    required String label,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bg = selected ? (isDark ? Colors.grey.shade600 : Colors.white) : Colors.transparent;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionGrid(bool isDark) {
    final muted = isDark ? Colors.grey.shade500 : Colors.grey.shade600;

    return AnimatedOpacity(
      opacity: _addWords ? 1 : 0.6,
      duration: const Duration(milliseconds: 150),
      child: AbsorbPointer(
        absorbing: !_addWords,
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.95,
          children: [
            _actionTile(
              label: 'Вручную',
              icon: Icons.edit,
              iconBg: isDark ? Colors.blue.shade900.withOpacity(0.25) : Colors.blue.shade50,
              iconColor: widget.primaryColor,
              muted: muted,
            ),
            _actionTile(
              label: 'Из PDF',
              icon: Icons.picture_as_pdf,
              iconBg: isDark ? Colors.orange.shade900.withOpacity(0.25) : Colors.orange.shade50,
              iconColor: Colors.orange.shade500,
              muted: muted,
            ),
            _actionTile(
              label: 'AI Генер.',
              icon: Icons.auto_awesome,
              iconBg: isDark ? Colors.purple.shade900.withOpacity(0.25) : Colors.purple.shade50,
              iconColor: Colors.purple.shade500,
              muted: muted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile({
    required String label,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color muted,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Ink(
          decoration: BoxDecoration(
            color: widget.isDark ? Colors.white.withOpacity(0.04) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.isDark ? Colors.grey.shade700 : Colors.grey.shade200),
            boxShadow: widget.isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
