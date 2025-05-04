import '/services/theme_controller.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        children: [
SwitchListTile(
  value: ThemeController.themeModeNotifier.value == ThemeMode.dark,
  onChanged: (val) {
    ThemeController.toggleTheme(val);
  },
  title: const Text('الوضع الليلي'),
  secondary: const Icon(Icons.brightness_6),
),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('حول التطبيق'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Central App',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 جميع الحقوق محفوظة',
              );
            },
          ),
        ],
      ),
    );
  }
}
