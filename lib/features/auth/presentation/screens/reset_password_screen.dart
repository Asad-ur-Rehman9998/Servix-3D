import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/validators/auth_validators.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    super.key,
    this.email,
    this.otp,
  });

  final String? email;
  final String? otp;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _submitting = false;

  Map<String, String> get _payload {
    final extra = GoRouterState.of(context).extra;
    if (extra is Map) {
      return {
        'email': (extra['email'] ?? widget.email ?? '').toString(),
        'otp': (extra['otp'] ?? widget.otp ?? '').toString(),
      };
    }
    return {
      'email': widget.email ?? '',
      'otp': widget.otp ?? '',
    };
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final payload = _payload;
    if (payload['email']!.isEmpty || payload['otp']!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing reset session. Restart from forgot password.'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(authRepositoryProvider).resetPassword(
            email: payload['email']!,
            otp: payload['otp']!,
            newPassword: _passwordController.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated. Please sign in.')),
      );
      context.go('/login');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.heroGradientDark
              : AppColors.heroGradientLight,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Set new password',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Choose a strong password you have not used before.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    GlassCard(
                      blur: false,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            AppTextField(
                              controller: _passwordController,
                              label: 'New password',
                              hint: 'At least 6 characters',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: true,
                              enableObscureToggle: true,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.newPassword],
                              validator: AuthValidators.password,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              controller: _confirmController,
                              label: 'Confirm password',
                              hint: 'Repeat password',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: true,
                              enableObscureToggle: true,
                              textInputAction: TextInputAction.done,
                              validator: (value) =>
                                  AuthValidators.confirmPassword(
                                value,
                                _passwordController.text,
                              ),
                              onSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppButton(
                              label: 'Update Password',
                              onPressed: _submit,
                              isLoading: _submitting,
                              icon: Icons.check_rounded,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
