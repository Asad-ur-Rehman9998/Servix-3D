import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';

/// Compact star rating display with optional numeric label.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.max = 5,
    this.size = 16,
    this.showValue = true,
    this.reviewCount,
    this.color = AppColors.accent,
  });

  final double rating;
  final int max;
  final double size;
  final bool showValue;
  final int? reviewCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(max, (index) {
          final threshold = index + 1;
          IconData icon;
          if (rating >= threshold) {
            icon = Icons.star_rounded;
          } else if (rating >= threshold - 0.5) {
            icon = Icons.star_half_rounded;
          } else {
            icon = Icons.star_outline_rounded;
          }
          return Icon(icon, size: size, color: color);
        }),
        if (showValue) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            rating.toStringAsFixed(1),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        if (reviewCount != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            '($reviewCount)',
            style: theme.textTheme.labelMedium?.copyWith(
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
            ),
          ),
        ],
      ],
    );
  }
}
