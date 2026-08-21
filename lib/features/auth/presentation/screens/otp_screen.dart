import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/validators/auth_validators.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, this.email});

  final String? email;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _submitting = false;
  bool _resending = false;

  String get _email {
    if (widget.email != null && widget.email!.isNotEmpty) {
      return widget.email!;
    }
    final extra = GoRouterState.of(context).extra;
    if (extra is String) return extra;
    if (extra is Map && extra['email'] is String) {
      return extra['email'] as String;
    }
    return '';
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    if (_email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing email. Go back and try again.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final ok = await ref.read(authRepositoryProvider).verifyOtp(
            email: _email,
            otp: _otpController.text.trim(),
          );
      if (!mounted) return;
      if (ok) {
        context.push(
          '/reset-password',
          extra: {
            'email': _email,
            'otp': _otpController.text.trim(),
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP. Please try again.')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resend() async {
    if (_email.isEmpty) return;
    setState(() => _resending = true);
    try {
      await ref.read(authRepositoryProvider).requestPasswordReset(_email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new code was sent to your email.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
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
                      'Enter verification code',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _email.isEmpty
                          ? 'We sent a 6-digit code to your email.'
                          : 'We sent a 6-digit code to $_email',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.45,
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
                            TextFormField(
                              controller: _otpController,
                              validator: AuthValidators.otp,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                letterSpacing: 10,
                                fontWeight: FontWeight.w800,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              decoration: const InputDecoration(
                                hintText: '••••••',
                                counterText: '',
                              ),
                              maxLength: 6,
                              onFieldSubmitted: (_) => _verify(),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppButton(
                              label: 'Verify Code',
                              onPressed: _verify,
                              isLoading: _submitting,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppButton(
                              label: 'Resend code',
                              onPressed: _resend,
                              isLoading: _resending,
                              variant: AppButtonVariant.ghost,
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
