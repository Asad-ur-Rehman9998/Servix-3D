import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Loads a local asset path or a remote URL with a consistent placeholder.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.fallbackIcon = Icons.image_outlined,
  });

  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;

  bool get _isAsset => source.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    final child = _isAsset
        ? Image.asset(
            source,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (_, __, ___) => _fallback(),
          )
        : CachedNetworkImage(
            imageUrl: source,
            fit: fit,
            width: width,
            height: height,
            placeholder: (_, __) => _placeholder(),
            errorWidget: (_, __, ___) => _fallback(),
          );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.primary.withValues(alpha: 0.08),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Icon(fallbackIcon, color: AppColors.primary, size: 40),
    );
  }
}

/// Circle avatar that supports asset paths and network URLs.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.source,
    this.radius = 24,
    this.fallbackText,
  });

  final String? source;
  final double radius;
  final String? fallbackText;

  @override
  Widget build(BuildContext context) {
    final src = source;
    ImageProvider? image;
    if (src != null && src.isNotEmpty) {
      image = src.startsWith('assets/')
          ? AssetImage(src)
          : CachedNetworkImageProvider(src);
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      backgroundImage: image,
      onBackgroundImageError: image == null ? null : (_, __) {},
      child: image == null
          ? Text(
              (fallbackText != null && fallbackText!.isNotEmpty)
                  ? fallbackText![0].toUpperCase()
                  : 'S',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.75,
              ),
            )
          : null,
    );
  }
}
