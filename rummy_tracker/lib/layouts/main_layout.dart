import 'package:flutter/material.dart';
import 'dart:async';
import 'package:rummy_tracker/players_section/players_screen.dart';
import 'package:rummy_tracker/ranking_section/ranking_screen.dart';
import 'package:rummy_tracker/components/team_credits_dialog.dart';
import 'package:rummy_tracker/game_flow/phase_one_selection.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  Timer? _easterEggTimer;

  @override
  void dispose() {
    _easterEggTimer?.cancel();
    super.dispose();
  }

  void _showEasterEgg() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Team Credits',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const TeamCreditsDialog(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),
          ),
          // Gradient Overlay for depth
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Title / Brand
                    Column(
                      children: [
                        Text(
                          'RUMMY',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 10,
                            fontFamily:
                                'serif', // Using serif for a more "classic" game feel
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 25,
                                offset: const Offset(0, 0),
                              ),
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'TRACKER',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),
                    // Centered Menu Container
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 40,
                            spreadRadius: -10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MenuTile(
                            title: 'PLAY NOW',
                            icon: Icons.play_arrow_rounded,
                            color: const Color.fromARGB(255, 255, 1, 1),
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const PhaseOneScreen(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        var curve = Curves.easeOutCubic;
                                        var curvedAnimation = CurvedAnimation(
                                          parent: animation,
                                          curve: curve,
                                        );

                                        return FadeTransition(
                                          opacity: curvedAnimation,
                                          child: ScaleTransition(
                                            scale: Tween<double>(
                                              begin: 0.95,
                                              end: 1.0,
                                            ).animate(curvedAnimation),
                                            child: child,
                                          ),
                                        );
                                      },
                                  transitionDuration: const Duration(
                                    milliseconds: 600,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          MenuTile(
                            title: 'PLAYERS',
                            icon: Icons.people_alt_rounded,
                            color: const Color(0xFFFFAB40),
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const PlayersScreen(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        var curve = Curves.easeOutCubic;
                                        var curvedAnimation = CurvedAnimation(
                                          parent: animation,
                                          curve: curve,
                                        );

                                        return FadeTransition(
                                          opacity: curvedAnimation,
                                          child: ScaleTransition(
                                            scale: Tween<double>(
                                              begin: 0.95,
                                              end: 1.0,
                                            ).animate(curvedAnimation),
                                            child: child,
                                          ),
                                        );
                                      },
                                  transitionDuration: const Duration(
                                    milliseconds: 600,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          MenuTile(
                            title: 'RANKING',
                            icon: Icons.leaderboard_rounded,
                            color: const Color(0xFF30E8BF),
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const RankingScreen(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        var curve = Curves.easeOutCubic;
                                        var curvedAnimation = CurvedAnimation(
                                          parent: animation,
                                          curve: curve,
                                        );

                                        return FadeTransition(
                                          opacity: curvedAnimation,
                                          child: ScaleTransition(
                                            scale: Tween<double>(
                                              begin: 0.95,
                                              end: 1.0,
                                            ).animate(curvedAnimation),
                                            child: child,
                                          ),
                                        );
                                      },
                                  transitionDuration: const Duration(
                                    milliseconds: 600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Version Info (Static)
          Positioned(
            right: 16,
            bottom: 16,
            child: GestureDetector(
              onLongPressStart: (_) {
                _easterEggTimer = Timer(const Duration(seconds: 1), () {
                  if (mounted) {
                    _showEasterEgg();
                  }
                });
              },
              onLongPressEnd: (_) {
                _easterEggTimer?.cancel();
              },
              onLongPressCancel: () {
                _easterEggTimer?.cancel();
              },
              child: Text(
                'Rummy Tracker v1.2.5',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.24),
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1,
                  fontFamily: 'serif',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const MenuTile({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.4), width: 1.2),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), Colors.transparent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            children: [
              // Stylized Icon Container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              // Text Content
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    fontFamily: 'serif',
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.3),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
