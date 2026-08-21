import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const _pages = <_OnboardingPageData>[
    _OnboardingPageData(
      title: 'Book trusted help in 3D',
      subtitle:
          'Explore services visually, compare pros, and book in minutes — all from one premium marketplace.',
      icon: Icons.view_in_ar_rounded,
      accent: AppColors.primary,
    ),
    _OnboardingPageData(
      title: 'Verified local providers',
      subtitle:
          'Every pro is rated, reviewed, and available nearby. Track jobs from request to completion.',
      icon: Icons.verified_user_rounded,
      accent: AppColors.secondary,
    ),
    _OnboardingPageData(
      title: 'Pay securely, relax fully',
      subtitle:
          'Transparent pricing, secure checkout, and real-time updates so you always know what is next.',
      icon: Icons.security_rounded,
      accent: AppColors.accent,
    ),
  ];

  bool get _isLast => _index == _pages.length - 1;

  Future<void> _finish() async {
    await ref.read(onboardingDoneProvider.notifier).complete();
    if (!mounted) return;
    context.go('/login');
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                page.accent.withValues(alpha: 0.18),
                                AppColors.primary.withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusXl),
                            border: Border.all(
                              color: page.accent.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Icon(
                            page.icon,
                            size: 72,
                            color: page.accent,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SmoothPageIndicator(
              controller: _controller,
              count: _pages.length,
              effect: ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 3.2,
                spacing: 8,
                activeDotColor: AppColors.primary,
                dotColor: isDark
                    ? AppColors.darkBorder
                    : AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: AppButton(
                label: _isLast ? 'Get Started' : 'Next',
                onPressed: _next,
                icon: _isLast
                    ? Icons.arrow_forward_rounded
                    : Icons.chevron_right_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
}
