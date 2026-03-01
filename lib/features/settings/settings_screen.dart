import 'package:flutter/material.dart';
import 'package:bookkeeping/core/services/theme_service.dart';
import 'package:bookkeeping/core/widgets/appbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings', showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Appearance',
            style: theme.textTheme.titleMedium!.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService.instance.themeMode,
            builder: (context, themeMode, _) {
              return Card(
                child: Column(
                  children: [
                    _ThemeOptionTile(
                      title: 'System default',
                      subtitle: 'Match device setting',
                      icon: Icons.brightness_auto_outlined,
                      value: ThemeMode.system,
                      groupValue: themeMode,
                      onChanged: () =>
                          ThemeService.instance.setThemeMode(ThemeMode.system),
                    ),
                    Divider(height: 1, color: colorScheme.outlineVariant),
                    _ThemeOptionTile(
                      title: 'Light',
                      subtitle: 'Always use light theme',
                      icon: Icons.light_mode_outlined,
                      value: ThemeMode.light,
                      groupValue: themeMode,
                      onChanged: () =>
                          ThemeService.instance.setThemeMode(ThemeMode.light),
                    ),
                    Divider(height: 1, color: colorScheme.outlineVariant),
                    _ThemeOptionTile(
                      title: 'Dark',
                      subtitle: 'Always use dark theme',
                      icon: Icons.dark_mode_outlined,
                      value: ThemeMode.dark,
                      groupValue: themeMode,
                      onChanged: () =>
                          ThemeService.instance.setThemeMode(ThemeMode.dark),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode groupValue;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value == groupValue;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall!.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 24)
          : null,
      onTap: onChanged,
    );
  }
}
