import 'package:flutter/material.dart';
import 'package:rummy_tracker/layouts/main_layout.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _floatController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late List<AnimationController> _suitControllers = [];
  late List<Animation<double>> _suitAnimations = [];

  @override
  void initState() {
    super.initState();

    // Main fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Scale animation for title
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Rotation animation for suits
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Float animation for suits
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Create animations for each suit
    final suits = ['♥', '♦', '♣', '♠'];
    for (int i = 0; i < suits.length; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 1200 + (i * 100)),
        vsync: this,
      );
      _suitControllers.add(controller);

      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));
      _suitAnimations.add(animation);
    }

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
    _rotationController.repeat();
    _floatController.repeat(reverse: true);

    // Start suit animations with delays
    for (int i = 0; i < _suitControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 250 + (i * 100)), () {
        if (mounted) {
          _suitControllers[i].forward();
        }
      });
    }

    // Navigate to main menu after animation completes
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainMenuScreen(),
            transitionDuration: const Duration(milliseconds: 700),
            reverseTransitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              
              return FadeTransition(
                opacity: curvedAnimation,
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.95,
                    end: 1.0,
                  ).animate(curvedAnimation),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.02),
                      end: Offset.zero,
                    ).animate(curvedAnimation),
                    child: child,
                  ),
                ),
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _floatController.dispose();
    for (var controller in _suitControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suits = [
      {'char': '♥', 'color': const Color(0xFFFF4D4D)},
      {'char': '♦', 'color': const Color(0xFFFF4D4D)},
      {'char': '♣', 'color': Colors.white},
      {'char': '♠', 'color': Colors.white},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient Overlay
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(
                          alpha: 0.3 + (0.5 * _fadeAnimation.value),
                        ),
                        Colors.black.withValues(
                          alpha: 0.7 + (0.2 * _fadeAnimation.value),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Animated Card Suits
          ...suits.asMap().entries.map((entry) {
            final index = entry.key;
            final suit = entry.value;
            final angle = (index * math.pi * 2) / suits.length;
            final radius = 120.0;

            return AnimatedBuilder(
              animation: Listenable.merge([
                _suitAnimations[index],
                _rotationController,
                _floatController,
              ]),
              builder: (context, child) {
                final floatOffset = math.sin(_floatController.value * math.pi * 2) * 15;
                final rotation = _rotationController.value * math.pi * 2;
                final opacity = _suitAnimations[index].value;

                return Positioned(
                  left: MediaQuery.of(context).size.width / 2 +
                      math.cos(angle + rotation) * radius -
                      20,
                  top: MediaQuery.of(context).size.height / 2 +
                      math.sin(angle + rotation) * radius +
                      floatOffset -
                      20,
                  child: Opacity(
                    opacity: opacity * 0.6,
                    child: Transform.rotate(
                      angle: rotation + (index * math.pi / 4),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (suit['color'] as Color).withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (suit['color'] as Color).withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            suit['char'] as String,
                            style: TextStyle(
                              color: suit['color'] as Color,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: (suit['color'] as Color).withValues(alpha: 0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          // Main Content
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: 0.5 + (0.5 * _scaleAnimation.value),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Title
                        Text(
                          'RUMMY',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 12,
                            fontFamily: 'serif',
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.8),
                                blurRadius: 30,
                                offset: const Offset(0, 0),
                              ),
                              Shadow(
                                color: const Color(0xFF30E8BF).withValues(alpha: 0.3),
                                blurRadius: 40,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'TRACKER',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 16,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
