import 'package:flutter/material.dart';

/// Страница настроек приложения
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  int _cardsPerSession = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          // Секция внешнего вида
          _buildSectionHeader('Внешний вид'),
          SwitchListTile(
            title: const Text('Темная тема'),
            subtitle: const Text('Переключить цветовую схему'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
            },
            secondary: const Icon(Icons.dark_mode),
          ),

          const Divider(),

          // Секция обучения
          _buildSectionHeader('Обучение'),
          ListTile(
            leading: const Icon(Icons.format_list_numbered),
            title: const Text('Карточек за сессию'),
            subtitle: Text('$_cardsPerSession карточек'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCardsPerSessionDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Направление изучения'),
            subtitle: const Text('Немецкий → Русский'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Показать диалог выбора направления
            },
          ),

          const Divider(),

          // Секция звуков
          _buildSectionHeader('Звуки и вибрация'),
          SwitchListTile(
            title: const Text('Звуки'),
            subtitle: const Text('Звуковые эффекты в приложении'),
            value: _soundEnabled,
            onChanged: (value) {
              setState(() {
                _soundEnabled = value;
              });
            },
            secondary: const Icon(Icons.volume_up),
          ),
          SwitchListTile(
            title: const Text('Вибрация'),
            subtitle: const Text('Тактильная обратная связь'),
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() {
                _vibrationEnabled = value;
              });
            },
            secondary: const Icon(Icons.vibration),
          ),

          const Divider(),

          // Секция уведомлений
          _buildSectionHeader('Уведомления'),
          SwitchListTile(
            title: const Text('Напоминания'),
            subtitle: const Text('Ежедневные напоминания об обучении'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            secondary: const Icon(Icons.notifications),
          ),
          if (_notificationsEnabled)
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Время напоминания'),
              subtitle: const Text('20:00'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showTimePickerDialog(),
            ),

          const Divider(),

          // Секция данных
          _buildSectionHeader('Данные'),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Экспорт данных'),
            subtitle: const Text('Сохранить прогресс в файл'),
            onTap: () {
              // TODO: Экспорт данных
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Импорт данных'),
            subtitle: const Text('Восстановить из файла'),
            onTap: () {
              // TODO: Импорт данных
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red.shade400),
            title: Text(
              'Сбросить прогресс',
              style: TextStyle(color: Colors.red.shade400),
            ),
            subtitle: const Text('Удалить весь прогресс обучения'),
            onTap: () => _showResetProgressDialog(),
          ),

          const Divider(),

          // Секция о приложении
          _buildSectionHeader('О приложении'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Версия'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Оценить приложение'),
            onTap: () {
              // TODO: Открыть страницу в App Store
            },
          ),
          ListTile(
            leading: const Icon(Icons.mail),
            title: const Text('Обратная связь'),
            onTap: () {
              // TODO: Открыть почтовый клиент
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Политика конфиденциальности'),
            onTap: () {
              // TODO: Открыть политику
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showCardsPerSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Карточек за сессию'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: _cardsPerSession.toDouble(),
                  min: 5,
                  max: 50,
                  divisions: 9,
                  label: _cardsPerSession.toString(),
                  onChanged: (value) {
                    setDialogState(() {
                      _cardsPerSession = value.toInt();
                    });
                  },
                ),
                Text('$_cardsPerSession карточек'),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showTimePickerDialog() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0),
    );

    if (time != null) {
      // TODO: Сохранить время напоминания
    }
  }

  void _showResetProgressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить прогресс?'),
        content: const Text(
          'Это действие удалит весь ваш прогресс обучения. Это нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // TODO: Сбросить прогресс
              Navigator.pop(context);
            },
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }
}
