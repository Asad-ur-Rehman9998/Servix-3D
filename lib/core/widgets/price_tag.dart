import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';

/// Formatted "from $X" price badge.
class PriceTag extends StatelessWidget {
  const PriceTag({
    super.key,
    required this.amount,
    this.prefix = 'from',
    this.currency = '\$',
    this.compact = false,
    this.highlighted = false,
  });

  final double amount;
  final String prefix;
  final String currency;
  final bool compact;
  final bool highlighted;

  String get _formatted {
    final formatter = NumberFormat.currency(
      symbol: currency,
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    if (compact) {
      return Text(
        _formatted,
        style: theme.textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      );
    }

    final content = RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$prefix ',
            style: theme.textTheme.labelMedium?.copyWith(
              color: highlighted
                  ? Colors.white.withValues(alpha: 0.85)
                  : muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: _formatted,
            style: theme.textTheme.titleMedium?.copyWith(
              color: highlighted ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    if (!highlighted) return content;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: content,
    );
  }
}
