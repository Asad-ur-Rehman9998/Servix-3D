import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';

/// Subtle glass / elevated surface card for premium layouts.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.borderRadius,
    this.onTap,
    this.blur = true,
    this.elevation = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool blur;
  final bool elevation;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius =
        borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg);

    final decorated = Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: isDark ? AppColors.glassDark : AppColors.glassLight,
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.7),
        ),
        boxShadow: elevation
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
        color: blur
            ? null
            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
      ),
      child: Padding(padding: padding, child: child),
    );

    Widget content = blur
        ? ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: decorated,
            ),
          )
        : decorated;

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: content,
        ),
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}
