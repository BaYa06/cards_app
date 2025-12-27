import 'package:flutter/material.dart';
import '../../../../core/router/app_router.dart';
import '../../../../data/models/category.dart';
import '../../../../data/repositories/app_repository.dart';
import '../../domain/entities/category_set.dart';
import '../pages/set_detail_page.dart';
import '../widgets/create_set_sheet.dart';

/// Страница со списком наборов (категорий)
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  // Цвета из макета
  static const Color _primaryColor = Color(0xFF2D65E6);
  static const Color _backgroundLight = Color(0xFFF6F6F8);
  static const Color _backgroundDark = Color(0xFF111621);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _surfaceDark = Color(0xFF1E293B);

  final List<String> _filters = const [
    'Все',
    'Сегодня',
    'A1',
    'A2',
    'Мои',
    'Публичные',
    'Из PDF',
    'AI',
  ];

  int _selectedFilter = 0;
  int _currentNavIndex = 1;

  final AppRepository _repo = AppRepository();
  List<CategorySet> _sets = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSets();
  }

  Future<void> _loadSets() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _repo.initialize();
      List<CategorySet> loaded = [];

      try {
        final withStats = await _repo.getCategoriesWithStats();
        loaded = withStats.map((item) {
          final Category category = item['category'] as Category;
          final cardsCount = item['cardsCount'] as int? ?? 0;
          final learnedCount = item['learnedCount'] as int? ?? 0;
          final progress = cardsCount == 0 ? 0.0 : learnedCount / cardsCount;
          return _mapCategoryToSet(
            category,
            cardsCount: cardsCount,
            learned: learnedCount,
            progress: progress,
          );
        }).toList();
      } catch (_) {
        final categories = await _repo.getCategories();
        loaded = categories
            .map((cat) => _mapCategoryToSet(
                  cat,
                  cardsCount: 0,
                  learned: 0,
                  progress: 0,
                ))
            .toList();
      }

      if (!mounted) return;
      setState(() {
        _sets = loaded;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Не удалось загрузить наборы: $e';
        _loading = false;
      });
    }
  }

  CategorySet _mapCategoryToSet(
    Category category, {
    required int cardsCount,
    required int learned,
    required double progress,
  }) {
    final accent = category.colorValue;
    final remaining = (cardsCount - learned).clamp(0, cardsCount);
    return CategorySet(
      id: category.id.toString(),
      title: category.name,
      level: category.isCustom ? 'Мой' : 'A1',
      words: cardsCount,
      repeatCount: remaining,
      newWords: remaining,
      progress: progress.clamp(0.0, 1.0),
      icon: category.iconData,
      accentColor: accent,
      iconBackground: accent.withOpacity(0.12),
      progressColor: accent,
      repeatLabel: learned >= cardsCount && cardsCount > 0 ? 'Всё повторено' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? _backgroundDark : _backgroundLight;

    final sliverContent = _loading
        ? SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(
                color: _primaryColor,
              ),
            ),
          )
        : _error != null
            ? SliverFillRemaining(
                hasScrollBody: false,
                child: _buildErrorState(isDark),
              )
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: index == _sets.length - 1 ? 0 : 14),
                        child: _buildSetCard(_sets[index], isDark),
                      );
                    },
                    childCount: _sets.length,
                  ),
                ),
              );

    return Scaffold(
      backgroundColor: background,
      floatingActionButton: _buildFab(isDark),
      bottomNavigationBar: _buildBottomNavigation(isDark),
      body: CustomScrollView(
        slivers: [
          _buildHeader(isDark),
          SliverToBoxAdapter(child: _wrapWidth(_buildSearchField(isDark))),
          SliverToBoxAdapter(child: _wrapWidth(_buildFilters(isDark))),
          SliverToBoxAdapter(child: _wrapWidth(_buildReviewCard(isDark))),
          sliverContent,
        ],
      ),
    );
  }

  // ================= HEADER =================
  SliverAppBar _buildHeader(bool isDark) {
    final color = isDark ? _backgroundDark : _backgroundLight;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final muted = isDark ? Colors.grey.shade400 : Colors.grey.shade500;

    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: color.withOpacity(0.97),
      surfaceTintColor: color,
      elevation: 0,
      toolbarHeight: 96,
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: borderColor.withOpacity(0.7)),
      ),
      title: _wrapWidth(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Наборы',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  _roundedIconButton(Icons.search, isDark),
                  const SizedBox(width: 8),
                  _roundedIconButton(Icons.tune, isDark),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    'Всего: 12',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: muted,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    'К повторению сегодня: 38',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundedIconButton(IconData icon, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 22,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  // ================= SEARCH =================
  Widget _buildSearchField(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? _surfaceDark : _surfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Поиск по наборам и словам…',
            hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
            prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  // ================= FILTERS =================
  Widget _buildFilters(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 0, 14),
      child: SizedBox(
        height: 46,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final selected = _selectedFilter == index;
            final background = selected
                ? _primaryColor
                : isDark
                    ? _surfaceDark
                    : _surfaceLight;
            final borderColor = selected
                ? Colors.transparent
                : isDark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300;
            final textColor = selected
                ? Colors.white
                : isDark
                    ? Colors.grey.shade300
                    : Colors.grey.shade700;

            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: borderColor),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ================= REVIEW CARD =================
  Widget _buildReviewCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Container(
        height: 196,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), _primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.28),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -32,
              right: -24,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -24,
              left: -18,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade700.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Время повторения',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.style, size: 18, color: Colors.indigo.shade100),
                          const SizedBox(width: 8),
                          Text(
                            '38 карточек • ~8 минут',
                            style: TextStyle(
                              color: Colors.indigo.shade100,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _primaryColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Начать повторение',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                        ),
                        child: const Text(
                          'Выбрать набор',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SET CARDS =================
  Widget _buildSetCard(CategorySet item, bool isDark) {
    final surface = isDark ? _surfaceDark : _surfaceLight;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final muted = isDark ? Colors.grey.shade500 : Colors.grey.shade500;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: item.iconBackground,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: item.accentColor.withOpacity(0.15),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(item.icon, color: item.accentColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _smallStat(text: '${item.words} слов', color: muted),
                          _dividerDot(isDark),
                          _smallStat(
                            text: item.repeatLabel ?? 'Повторить: ${item.repeatCount}',
                            color: item.repeatLabel == null ? Colors.orange.shade400 : muted,
                          ),
                          if (item.newWords != null) ...[
                            _dividerDot(isDark),
                            _smallStat(
                              text: 'Новые: ${item.newWords}',
                              color: Colors.green.shade500,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: item.progress,
                          minHeight: 6,
                          backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(item.progressColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.level,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.more_horiz,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _openSetDetails(item),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: _primaryColor.withOpacity(0.2), width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      foregroundColor: _primaryColor,
                    ),
                    child: const Text(
                      'Посмотреть',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                      foregroundColor: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.school, size: 18, color: isDark ? Colors.grey.shade200 : Colors.grey.shade700),
                        const SizedBox(width: 6),
                        const Text(
                          'Учить',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openSetDetails(CategorySet item) {
    Navigator.of(context).push(
      AppRouter.slideRoute(
        SetDetailPage(set: item),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 42, color: isDark ? Colors.red.shade300 : Colors.red.shade400),
          const SizedBox(height: 12),
          Text(
            _error ?? 'Ошибка загрузки',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _loadSets,
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryColor,
              side: BorderSide(color: _primaryColor.withOpacity(0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Widget _smallStat({required String text, required Color color}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }

  Widget _dividerDot(bool isDark) {
    return Container(
      width: 1,
      height: 14,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // ================= BOTTOM NAVIGATION =================
  Widget _buildBottomNavigation(bool isDark) {
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
    if (_currentNavIndex == index) return;
    setState(() => _currentNavIndex = index);

    if (index == 0) {
      // Вернуться на главную
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
  }

  // ================= FAB =================
  Widget _buildFab(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FloatingActionButton(
        backgroundColor: _primaryColor,
        elevation: 6,
        shape: const CircleBorder(),
        onPressed: () => _showCreateSetSheet(isDark),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }

  void _showCreateSetSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (context) => CreateSetSheet(
        isDark: isDark,
        primaryColor: _primaryColor,
        surfaceLight: _surfaceLight,
        surfaceDark: _surfaceDark,
      ),
    ).then((result) {
      if (result == true) {
        _loadSets();
      }
    });
  }

  Widget _wrapWidth(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: child,
      ),
    );
  }
}
