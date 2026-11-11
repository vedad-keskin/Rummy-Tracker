import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rummy_tracker/layouts/main_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;
  bool _leaving = false;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 2000),
          animationBehavior: AnimationBehavior.preserve,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) _openMenu();
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_started) return;
    _started = true;
    if (_reduceMotion) _controller.duration = const Duration(milliseconds: 220);
    _controller.forward();
  }

  void _openMenu() {
    if (!mounted || _leaving) return;
    _leaving = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainMenuScreen(),
        transitionDuration: Duration(milliseconds: _reduceMotion ? 180 : 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
              child: child,
            ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101B2D),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.08),
            radius: 0.8,
            colors: [Color(0xFF173A48), Color(0xFF101B2D)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest;
              final logoSize = math.min(
                300.0,
                math.min(size.shortestSide * 0.62, (size.height - 64) / 2),
              );
              final center = Offset(size.width / 2, size.height / 2);
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double phase(double start, double end) =>
                      Curves.easeOutCubic.transform(
                        Interval(start, end).transform(_controller.value),
                      );
                  final reveal = phase(0, 0.42);
                  final exit = phase(0.78, 1);
                  return Stack(
                    children: [
                      if (!_reduceMotion)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _LightTrailPainter(
                              progress: _controller.value,
                              radius: logoSize * 0.72,
                              opacity: phase(0.03, 0.25) * (1 - exit),
                            ),
                          ),
                        ),
                      if (!_reduceMotion)
                        for (var index = 0; index < 4; index++)
                          _card(
                            index,
                            size,
                            center,
                            logoSize,
                            phase(0.04 + index * 0.08, 0.42 + index * 0.08),
                            exit,
                          ),
                      Center(
                        child: Opacity(
                          opacity: _reduceMotion
                              ? _controller.value
                              : 0.4 + 0.6 * phase(0, 0.25),
                          child: Transform.translate(
                            offset: Offset(
                              0,
                              _reduceMotion ? 0 : 28 * (1 - reveal),
                            ),
                            child: Transform.scale(
                              scale: _reduceMotion ? 1 : 0.86 + 0.14 * reveal,
                              child: HeroMode(
                                enabled: !_reduceMotion,
                                child: Hero(
                                  tag: 'rummy-logo',
                                  child: Image.asset(
                                    'assets/images/logo_transparent.png',
                                    width: logoSize,
                                    height: logoSize,
                                    fit: BoxFit.contain,
                                    semanticLabel: 'Rummy Tracker',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _card(
    int index,
    Size viewport,
    Offset center,
    double logoSize,
    double arrival,
    double exit,
  ) {
    final right = index.isOdd ? 1.0 : -1.0;
    final bottom = index < 2 ? -1.0 : 1.0;
    final height = logoSize * 0.42;
    final width = height * 0.69;
    final end = Offset(
      right * logoSize * 0.28,
      bottom * (logoSize / 2 + height * 0.65 + 10),
    );
    final start = Offset(
      right * (viewport.width / 2 + width),
      viewport.height * 0.6,
    );
    final control1 = Offset(right * logoSize * 0.95, viewport.height * 0.2);
    final control2 = Offset(right * logoSize * 0.82, end.dy - bottom * 40);
    final t = arrival;
    final position =
        start * math.pow(1 - t, 3).toDouble() +
        control1 * (3 * math.pow(1 - t, 2) * t).toDouble() +
        control2 * (3 * (1 - t) * t * t) +
        end * (t * t * t);
    final float =
        math.sin(_controller.value * math.pi * 2.6 + index) * 4 * arrival;
    final offset =
        Offset.lerp(position, end * 0.5, exit)! + Offset(0, float * (1 - exit));

    return Positioned(
      left: center.dx + offset.dx - width / 2,
      top: center.dy + offset.dy - height / 2,
      child: ExcludeSemantics(
        child: Opacity(
          opacity: arrival * (1 - exit),
          child: Transform.rotate(
            angle: right * (0.8 * (1 - arrival) + bottom * 0.16),
            child: Transform.scale(
              scale: 1 - exit * 0.25,
              child: SizedBox(
                key: ValueKey('intro-card-$index'),
                width: width,
                height: height,
                child: CustomPaint(painter: _AcePainter(index)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LightTrailPainter extends CustomPainter {
  const _LightTrailPainter({
    required this.progress,
    required this.radius,
    required this.opacity,
  });
  final double progress;
  final double radius;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final angle = progress * math.pi * 1.7 - math.pi / 2;
    for (final (offset, color) in [
      (0.0, const Color(0xFF30E8BF)),
      (math.pi, const Color(0xFFFFC84A)),
    ]) {
      final paint = Paint()
        ..color = color.withValues(alpha: opacity * 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      canvas.drawArc(rect, angle + offset, 1.05, false, paint);
      paint
        ..maskFilter = null
        ..strokeWidth = 1.7
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: opacity * 0.85);
      canvas.drawArc(rect, angle + offset, 1.05, false, paint);
      canvas.drawCircle(
        center +
            Offset(
                  math.cos(angle + offset + 1.05),
                  math.sin(angle + offset + 1.05),
                ) *
                radius,
        2.7,
        paint..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_LightTrailPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      radius != oldDelegate.radius ||
      opacity != oldDelegate.opacity;
}

class _AcePainter extends CustomPainter {
  const _AcePainter(this.suit);
  final int suit;

  @override
  void paint(Canvas canvas, Size size) {
    final face = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.width * 0.13),
    );
    canvas.drawShadow(
      Path()..addRRect(face),
      Colors.black.withValues(alpha: 0.55),
      8,
      true,
    );
    canvas.drawRRect(face, Paint()..color = const Color(0xFFFFF5DE));
    canvas.drawRRect(
      face.deflate(0.75),
      Paint()
        ..color = const Color(0xFFE3C984)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final color = suit == 0 || suit == 3
        ? const Color(0xFFEC315D)
        : const Color(0xFF142747);
    final rank = TextPainter(
      text: TextSpan(
        text: 'A',
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.25,
          fontFamily: 'serif',
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    rank.paint(canvas, Offset(size.width * 0.13, size.height * 0.055));
    canvas.save();
    canvas.translate(size.width, size.height);
    canvas.rotate(math.pi);
    rank.paint(canvas, Offset(size.width * 0.13, size.height * 0.055));
    canvas.restore();
    _paintSuit(
      canvas,
      Offset(size.width / 2, size.height / 2),
      size.width * 0.56,
      color,
    );
  }

  void _paintSuit(Canvas canvas, Offset center, double size, Color color) {
    canvas.save();
    canvas.translate(center.dx - size / 2, center.dy - size / 2);
    canvas.scale(size);
    final paint = Paint()..color = color;
    final path = Path();
    if (suit == 0) {
      path.moveTo(0.5, 0.95);
      path.cubicTo(0.42, 0.82, 0.05, 0.60, 0.05, 0.33);
      path.cubicTo(0.05, 0.05, 0.38, 0, 0.5, 0.25);
      path.cubicTo(0.62, 0, 0.95, 0.05, 0.95, 0.33);
      path.cubicTo(0.95, 0.60, 0.58, 0.82, 0.5, 0.95);
      path.close();
    } else if (suit == 3) {
      path.moveTo(0.5, 0.02);
      path.lineTo(0.95, 0.5);
      path.lineTo(0.5, 0.98);
      path.lineTo(0.05, 0.5);
      path.close();
    } else {
      if (suit == 1) {
        path.moveTo(0.5, 0.02);
        path.cubicTo(0.4, 0.2, 0.05, 0.43, 0.05, 0.65);
        path.cubicTo(0.05, 0.91, 0.38, 0.97, 0.5, 0.75);
        path.cubicTo(0.62, 0.97, 0.95, 0.91, 0.95, 0.65);
        path.cubicTo(0.95, 0.43, 0.6, 0.2, 0.5, 0.02);
        path.close();
      } else {
        for (final point in [
          const Offset(0.5, 0.26),
          const Offset(0.26, 0.57),
          const Offset(0.74, 0.57),
        ]) {
          path.addOval(Rect.fromCircle(center: point, radius: 0.24));
        }
      }
      canvas.drawPath(
        Path()
          ..moveTo(0.46, 0.6)
          ..quadraticBezierTo(0.45, 0.9, 0.3, 0.98)
          ..lineTo(0.7, 0.98)
          ..quadraticBezierTo(0.55, 0.9, 0.54, 0.6)
          ..close(),
        paint,
      );
    }
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_AcePainter oldDelegate) => suit != oldDelegate.suit;
}
