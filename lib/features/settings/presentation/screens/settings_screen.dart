import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/settings_prefs_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final notificationsOn = ref.watch(notificationsEnabledProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text(
              'Appearance',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          _ThemeTile(
            label: 'System',
            selected: mode == ThemeMode.system,
            onTap: () =>
                ref.read(themeModeProvider.notifier).setMode(ThemeMode.system),
          ),
          _ThemeTile(
            label: 'Light',
            selected: mode == ThemeMode.light,
            onTap: () =>
                ref.read(themeModeProvider.notifier).setMode(ThemeMode.light),
          ),
          _ThemeTile(
            label: 'Dark',
            selected: mode == ThemeMode.dark,
            onTap: () =>
                ref.read(themeModeProvider.notifier).setMode(ThemeMode.dark),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Push notifications'),
            subtitle: const Text('Persisted locally on this device'),
            value: notificationsOn,
            activeThumbColor: AppColors.primary,
            onChanged: (v) =>
                ref.read(notificationsEnabledProvider.notifier).setEnabled(v),
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(language == 'en' ? 'English' : language.toUpperCase()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final next = await showModalBottomSheet<String>(
                context: context,
                showDragHandle: true,
                builder: (context) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('English'),
                        onTap: () => Navigator.pop(context, 'en'),
                      ),
                      ListTile(
                        title: const Text('Español (demo)'),
                        onTap: () => Navigator.pop(context, 'es'),
                      ),
                      ListTile(
                        title: const Text('Français (demo)'),
                        onTap: () => Navigator.pop(context, 'fr'),
                      ),
                    ],
                  ),
                ),
              );
              if (next != null) {
                await ref.read(languageProvider.notifier).setLanguage(next);
              }
            },
          ),
          ListTile(
            title: const Text('Privacy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/privacy'),
          ),
          ListTile(
            title: const Text('Security'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/security'),
          ),
          ListTile(
            title: const Text('About'),
            subtitle: Text('${AppConstants.appName} · 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/about'),
          ),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Icon(
        selected ? Icons.check_circle : Icons.circle_outlined,
        color: selected ? AppColors.primary : null,
      ),
      onTap: onTap,
    );
  }
}
