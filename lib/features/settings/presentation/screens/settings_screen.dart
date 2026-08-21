import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

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
          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: mode,
            title: const Text('System'),
            onChanged: (v) =>
                ref.read(themeModeProvider.notifier).setMode(v!),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: mode,
            title: const Text('Light'),
            onChanged: (v) =>
                ref.read(themeModeProvider.notifier).setMode(v!),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: mode,
            title: const Text('Dark'),
            onChanged: (v) =>
                ref.read(themeModeProvider.notifier).setMode(v!),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Push notifications'),
            subtitle: const Text('Demo preference (persisted theme only)'),
            value: true,
            activeThumbColor: AppColors.primary,
            onChanged: (_) {},
          ),
          const ListTile(
            title: Text('Language'),
            subtitle: Text('English'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            title: Text('Privacy'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            title: Text('Security'),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            title: const Text('About'),
            subtitle: Text('${AppConstants.appName} · 1.0.0'),
          ),
        ],
      ),
    );
  }
}
