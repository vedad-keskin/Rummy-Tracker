import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rummy_tracker/components/card_artwork.dart';
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
                            painter: LightTrailPainter(
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
                child: CustomPaint(painter: AcePainter(index)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
