import 'package:flutter/material.dart';

// Импорты экранов
import '../../features/splash/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/cards/presentation/pages/cards_list_page.dart';
import '../../features/cards/presentation/pages/study_session_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';

/// Названия маршрутов приложения
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String categories = '/categories';
  static const String categoryCards = '/category/:id';
  static const String studySession = '/study/:categoryId';
  static const String cardDetail = '/card/:id';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
  static const String about = '/about';
}

/// Роутер приложения
class AppRouter {
  AppRouter._();

  /// Генерация маршрутов
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(
          const SplashPage(),
          settings,
        );

      case AppRoutes.onboarding:
        return _buildRoute(
          const OnboardingPage(),
          settings,
        );

      case AppRoutes.home:
        return _buildRoute(
          const HomePage(),
          settings,
        );

      case AppRoutes.categories:
        return _buildRoute(
          const CategoriesPage(),
          settings,
        );

      case AppRoutes.statistics:
        return _buildRoute(
          const StatisticsPage(),
          settings,
        );

      case AppRoutes.settings:
        return _buildRoute(
          const SettingsPage(),
          settings,
        );

      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('Страница не найдена: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  /// Построение маршрута с анимацией
  static PageRouteBuilder<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        );

        final slideAnimation = animation.drive(tween);
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Переход с анимацией слайда
  static PageRouteBuilder<dynamic> slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Переход с анимацией fade
  static PageRouteBuilder<dynamic> fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}

/// Временная страница-заглушка
class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title Page\n(В разработке)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
