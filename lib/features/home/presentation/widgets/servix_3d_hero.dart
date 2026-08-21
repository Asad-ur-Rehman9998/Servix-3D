import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';

/// Interactive pseudo-3D hero for the home screen.
///
/// Uses Matrix4 / CustomPaint (no WebView) so it runs on Windows, mobile, and web.
/// Drag horizontally/vertically to orbit a floating house + car + tools scene.
class Servix3dHero extends StatefulWidget {
  const Servix3dHero({
    super.key,
    this.height = 280,
    this.title = 'Book help in 3D',
    this.subtitle = 'Drag to explore · Cleaning, car wash & repairs nearby',
    this.onCta,
    this.ctaLabel = 'Explore services',
  });

  final double height;
  final String title;
  final String subtitle;
  final VoidCallback? onCta;
  final String ctaLabel;

  @override
  State<Servix3dHero> createState() => _Servix3dHeroState();
}

class _Servix3dHeroState extends State<Servix3dHero>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _float;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  double _yaw = -0.35;
  double _pitch = 0.22;
  double _velocityX = 0;
  double _velocityY = 0;
  Ticker? _inertiaTicker;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.86, end: 1).animate(
      CurvedAnimation(parent: _entrance, curve: Curves.easeOutBack),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));

    _entrance.forward();
    _inertiaTicker = createTicker(_onInertiaTick)..start();
  }

  void _onInertiaTick(Duration elapsed) {
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt <= 0) return;

    if (_velocityX.abs() < 0.0005 && _velocityY.abs() < 0.0005) {
      _velocityX = 0;
      _velocityY = 0;
      return;
    }

    setState(() {
      _yaw += _velocityX;
      _pitch = (_pitch + _velocityY).clamp(-0.55, 0.65);
      _velocityX *= math.pow(0.92, dt * 60).toDouble();
      _velocityY *= math.pow(0.92, dt * 60).toDouble();
    });
  }

  @override
  void dispose() {
    _inertiaTicker?.dispose();
    _entrance.dispose();
    _float.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _yaw += details.delta.dx * 0.008;
      _pitch = (_pitch - details.delta.dy * 0.006).clamp(-0.55, 0.65);
      _velocityX = details.delta.dx * 0.0012;
      _velocityY = -details.delta.dy * 0.0009;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            height: widget.height,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0xFF0F2926),
                        Color(0xFF0C1F33),
                        Color(0xFF12302C),
                      ]
                    : const [
                        Color(0xFFCCFBF1),
                        Color(0xFFE0F2FE),
                        Color(0xFFF0FDFA),
                      ],
              ),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder
                    : Colors.white.withValues(alpha: 0.8),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _float,
                      builder: (context, _) {
                        return GestureDetector(
                          onPanUpdate: _onDragUpdate,
                          onPanEnd: (_) {},
                          child: CustomPaint(
                            painter: _ServixScenePainter(
                              yaw: _yaw,
                              pitch: _pitch,
                              floatT: _float.value,
                              isDark: isDark,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: AppSpacing.lg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.7),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusPill),
                          ),
                          child: Text(
                            'Drag to rotate',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          widget.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        if (widget.onCta != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FilledButton.icon(
                              onPressed: widget.onCta,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                              label: Text(widget.ctaLabel),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServixScenePainter extends CustomPainter {
  _ServixScenePainter({
    required this.yaw,
    required this.pitch,
    required this.floatT,
    required this.isDark,
  });

  final double yaw;
  final double pitch;
  final double floatT;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.62, size.height * 0.38);
    final bob = math.sin(floatT * math.pi) * 6;

    _paintAmbient(canvas, size);

    final objects = <_SceneObject>[
      _SceneObject(
        kind: _ObjectKind.platform,
        local: const Offset(0, 42),
        depthBias: 0,
      ),
      _SceneObject(
        kind: _ObjectKind.house,
        local: const Offset(-18, -8),
        depthBias: 0,
      ),
      _SceneObject(
        kind: _ObjectKind.car,
        local: const Offset(54, 28),
        depthBias: 12,
      ),
      _SceneObject(
        kind: _ObjectKind.tools,
        local: const Offset(-58, 24),
        depthBias: -8,
      ),
      _SceneObject(
        kind: _ObjectKind.spark,
        local: const Offset(28, -48),
        depthBias: 20,
      ),
    ];

    final projected = objects.map((obj) {
      final p = _project(
        Offset(obj.local.dx, obj.local.dy + bob),
        yaw,
        pitch,
        center,
        obj.depthBias,
      );
      return (obj: obj, point: p.offset, depth: p.depth);
    }).toList()
      ..sort((a, b) => a.depth.compareTo(b.depth));

    for (final item in projected) {
      switch (item.obj.kind) {
        case _ObjectKind.platform:
          _drawPlatform(canvas, item.point, yaw);
        case _ObjectKind.house:
          _drawHouse(canvas, item.point, yaw, pitch);
        case _ObjectKind.car:
          _drawCar(canvas, item.point, yaw);
        case _ObjectKind.tools:
          _drawTools(canvas, item.point, yaw);
        case _ObjectKind.spark:
          _drawSpark(canvas, item.point, floatT);
      }
    }
  }

  void _paintAmbient(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.65, size.height * 0.35),
        size.width * 0.55,
        [
          AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.18),
          Colors.transparent,
        ],
      );
    canvas.drawRect(Offset.zero & size, bg);

    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : AppColors.primary)
          .withValues(alpha: isDark ? 0.05 : 0.07)
      ..strokeWidth = 1;

    for (var i = 0; i < 8; i++) {
      final y = size.height * 0.55 + i * 12.0;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + i * 2), gridPaint);
    }
  }

  ({Offset offset, double depth}) _project(
    Offset local,
    double yaw,
    double pitch,
    Offset center,
    double depthBias,
  ) {
    final x = local.dx;
    final y = local.dy;
    final z = depthBias;

    final cosY = math.cos(yaw);
    final sinY = math.sin(yaw);
    final cosP = math.cos(pitch);
    final sinP = math.sin(pitch);

    final x1 = x * cosY - z * sinY;
    final z1 = x * sinY + z * cosY;
    final y1 = y * cosP - z1 * sinP;
    final z2 = y * sinP + z1 * cosP;

    final perspective = 1 / (1 + z2 * 0.0045);
    return (
      offset: Offset(
        center.dx + x1 * perspective,
        center.dy + y1 * perspective,
      ),
      depth: z2,
    );
  }

  void _drawPlatform(Canvas canvas, Offset c, double yaw) {
    final path = Path()
      ..moveTo(c.dx - 90, c.dy)
      ..lineTo(c.dx + math.cos(yaw) * 20, c.dy - 18)
      ..lineTo(c.dx + 95, c.dy + 6)
      ..lineTo(c.dx - math.cos(yaw) * 10, c.dy + 24)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(c.dx - 80, c.dy - 20),
          Offset(c.dx + 80, c.dy + 20),
          [
            AppColors.primary.withValues(alpha: 0.35),
            AppColors.secondary.withValues(alpha: 0.22),
          ],
        ),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  void _drawHouse(Canvas canvas, Offset c, double yaw, double pitch) {
    final lean = math.sin(yaw) * 8;
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c.translate(lean * 0.2, 0), width: 78, height: 58),
      const Radius.circular(10),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = ui.Gradient.linear(
          c.translate(-40, -30),
          c.translate(40, 30),
          const [Color(0xFF14B8A6), Color(0xFF0F766E)],
        ),
    );

    final roof = Path()
      ..moveTo(c.dx - 48 + lean, c.dy - 22)
      ..lineTo(c.dx + lean * 0.5, c.dy - 52 - pitch * 8)
      ..lineTo(c.dx + 48 + lean * 0.2, c.dy - 20)
      ..close();
    canvas.drawPath(
      roof,
      Paint()..color = const Color(0xFF0E7490),
    );

    final windowPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(-14, -2), width: 16, height: 16),
        const Radius.circular(4),
      ),
      windowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(14, -2), width: 16, height: 16),
        const Radius.circular(4),
      ),
      windowPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c.dx - 8, c.dy + 4, 16, 24),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFF59E0B),
    );

    // Soft drop shadow
    canvas.drawOval(
      Rect.fromCenter(center: c.translate(0, 38), width: 70, height: 14),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
  }

  void _drawCar(Canvas canvas, Offset c, double yaw) {
    final tilt = math.sin(yaw) * 6;
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c.translate(tilt, 0), width: 72, height: 28),
      const Radius.circular(10),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = ui.Gradient.linear(
          c.translate(-30, -10),
          c.translate(30, 10),
          const [Color(0xFF38BDF8), Color(0xFF0369A1)],
        ),
    );

    final cabin = Path()
      ..moveTo(c.dx - 16 + tilt, c.dy - 8)
      ..lineTo(c.dx - 4 + tilt, c.dy - 24)
      ..lineTo(c.dx + 18 + tilt, c.dy - 24)
      ..lineTo(c.dx + 28 + tilt, c.dy - 8)
      ..close();
    canvas.drawPath(cabin, Paint()..color = const Color(0xFFE0F2FE));

    final wheelPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(c.translate(-20 + tilt, 14), 7, wheelPaint);
    canvas.drawCircle(c.translate(20 + tilt, 14), 7, wheelPaint);
    canvas.drawCircle(
      c.translate(-20 + tilt, 14),
      3,
      Paint()..color = Colors.white24,
    );
    canvas.drawCircle(
      c.translate(20 + tilt, 14),
      3,
      Paint()..color = Colors.white24,
    );
  }

  void _drawTools(Canvas canvas, Offset c, double yaw) {
    final rot = yaw * 0.4;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rot);

    final wrench = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(-16, 16), const Offset(16, -16), wrench);
    canvas.drawCircle(const Offset(16, -16), 7, wrench);

    final hammer = Paint()
      ..color = const Color(0xFF14B8A6)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(-18, -12), const Offset(18, 12), hammer);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 4, 16, 10),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF0F766E),
    );

    canvas.restore();

    canvas.drawOval(
      Rect.fromCenter(center: c.translate(0, 22), width: 36, height: 8),
      Paint()..color = Colors.black.withValues(alpha: 0.1),
    );
  }

  void _drawSpark(Canvas canvas, Offset c, double t) {
    final pulse = 0.55 + 0.45 * math.sin(t * math.pi * 2);
    canvas.drawCircle(
      c,
      10 * pulse,
      Paint()..color = AppColors.primaryLight.withValues(alpha: 0.35 * pulse),
    );
    canvas.drawCircle(
      c,
      4,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _ServixScenePainter oldDelegate) {
    return oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch ||
        oldDelegate.floatT != floatT ||
        oldDelegate.isDark != isDark;
  }
}

enum _ObjectKind { platform, house, car, tools, spark }

class _SceneObject {
  const _SceneObject({
    required this.kind,
    required this.local,
    required this.depthBias,
  });

  final _ObjectKind kind;
  final Offset local;
  final double depthBias;
}
