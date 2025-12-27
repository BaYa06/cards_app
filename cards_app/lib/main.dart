import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'data/repositories/app_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация базы данных
  await AppRepository().initialize();
  
  runApp(const DeutschCardsApp());
}

class DeutschCardsApp extends StatelessWidget {
  const DeutschCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeutschCards',
      debugShowCheckedModeBanner: false,

      // Темы
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Маршрутизация
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
