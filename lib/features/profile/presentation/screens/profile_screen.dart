import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/async_value_x.dart';
import '../../../auth/domain/validators/auth_validators.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).valueOrNull;
    final user = session?.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  backgroundImage: user?.avatarUrl != null
                      ? NetworkImage(user!.avatarUrl!)
                      : null,
                  child: user?.avatarUrl == null
                      ? Text(
                          (user?.name.isNotEmpty ?? false)
                              ? user!.name[0]
                              : 'S',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? 'Guest',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(user?.email ?? ''),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _tile(
            context,
            icon: Icons.edit_outlined,
            title: 'Edit profile',
            onTap: () => context.push('/profile/edit'),
          ),
          _tile(
            context,
            icon: Icons.calendar_month_outlined,
            title: 'My bookings',
            onTap: () => context.go('/bookings'),
          ),
          _tile(
            context,
            icon: Icons.favorite_border,
            title: 'Favorites',
            onTap: () => context.go('/favorites'),
          ),
          _tile(
            context,
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            onTap: () => context.push('/notifications'),
          ),
          _tile(
            context,
            icon: Icons.credit_card_outlined,
            title: 'Payment methods',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Demo: manage cards in production')),
            ),
          ),
          _tile(
            context,
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () => context.push('/settings'),
          ),
          _tile(
            context,
            icon: Icons.help_outline_rounded,
            title: 'Help & support',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('support@servix3d.com')),
            ),
          ),
          _tile(
            context,
            icon: Icons.info_outline_rounded,
            title: 'About ${AppConstants.appName}',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: AppConstants.appName,
              applicationVersion: '1.0.0',
              applicationLegalese: AppConstants.appTagline,
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Log out',
            variant: AppButtonVariant.secondary,
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    _name = TextEditingController(text: user?.name ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _address = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final current = ref.read(authControllerProvider).valueOrNull?.user;
    if (current == null) return;
    setState(() => _saving = true);
    await ref.read(authControllerProvider.notifier).updateProfile(
          current.copyWith(
            name: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            address: _address.text.trim(),
          ),
        );
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(
              controller: _name,
              label: 'Full name',
              validator: AuthValidators.name,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _email,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _phone,
              label: 'Phone',
              keyboardType: TextInputType.phone,
              validator: AuthValidators.phone,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _address,
              label: 'Address',
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Save changes',
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
