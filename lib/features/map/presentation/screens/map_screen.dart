import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/env_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/data/mock_data.dart';

/// Mock map screen used when Google Maps API keys are not configured.
///
/// To enable real Google Maps:
/// 1. Add `google_maps_flutter` to pubspec.yaml
/// 2. Set `GOOGLE_MAPS_API_KEY` in `.env`
/// 3. Add the key to AndroidManifest.xml / AppDelegate / web index.html
/// 4. Replace [_MockMapCanvas] with GoogleMap widget
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby map')),
      body: Column(
        children: [
          if (!EnvConfig.hasMapsKey)
            MaterialBanner(
              content: const Text(
                'Using mock map. Add GOOGLE_MAPS_API_KEY to enable Google Maps.',
              ),
              actions: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Docs'),
                ),
              ],
            ),
          Expanded(
            child: Stack(
              children: [
                const Positioned.fill(child: _MockMapCanvas()),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Your location',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const Text('128 Market Street, San Francisco'),
                          const SizedBox(height: 8),
                          Text(
                            '${MockData.providers.where((p) => p.available).length} pros nearby · avg 2.4 km',
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MockMapCanvas extends StatelessWidget {
  const _MockMapCanvas();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapPainter(),
      child: Stack(
        children: [
          for (var i = 0; i < MockData.providers.length; i++)
            Positioned(
              left: 40.0 + (i * 55),
              top: 120.0 + (i.isEven ? 40 : 110),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.handyman_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  Text(
                    MockData.providers[i].name.split(' ').first,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          const Positioned(
            left: 180,
            top: 280,
            child: Icon(
              Icons.my_location_rounded,
              color: AppColors.secondary,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFE8EEF2);
    canvas.drawRect(Offset.zero & size, bg);

    final road = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
    final roadInner = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    for (var x = 0.0; x < size.width; x += 70) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), road);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadInner);
    }
    for (var y = 0.0; y < size.height; y += 70) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), road);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadInner);
    }

    final park = Paint()..color = const Color(0xFFBBF7D0).withValues(alpha: 0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.2, 90, 70),
        const Radius.circular(16),
      ),
      park,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
