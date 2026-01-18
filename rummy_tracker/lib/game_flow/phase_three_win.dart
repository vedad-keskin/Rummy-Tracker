import 'package:flutter/material.dart';
import 'package:rummy_tracker/offline_db/player_service.dart';

class PhaseThreeWinScreen extends StatefulWidget {
  final Player winner;

  const PhaseThreeWinScreen({super.key, required this.winner});

  @override
  State<PhaseThreeWinScreen> createState() => _PhaseThreeWinScreenState();
}

class _PhaseThreeWinScreenState extends State<PhaseThreeWinScreen> {
  final PlayerService _playerService = PlayerService();

  @override
  void initState() {
    super.initState();
    _recordWin();
  }

  Future<void> _recordWin() async {
    await _playerService.incrementWin(widget.winner.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    const Color(0xFF30E8BF).withValues(alpha: 0.15),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _GloriousEntrance(
                    delay: 200,
                    child: Text(
                      'CONGRATULATIONS',
                      style: TextStyle(
                        color: Color(0xFF30E8BF),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                        fontFamily: 'serif',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _GloriousEntrance(
                    delay: 400,
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF30E8BF).withValues(alpha: 0.1),
                        border: Border.all(
                          color: const Color(0xFF30E8BF).withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF30E8BF,
                            ).withValues(alpha: 0.2),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFF30E8BF),
                        size: 80,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  _GloriousEntrance(
                    delay: 600,
                    child: Text(
                      widget.winner.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'serif',
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const _GloriousEntrance(
                    delay: 800,
                    child: Text(
                      'IS THE WINNER',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                  _GloriousEntrance(
                    delay: 1000,
                    child: TextButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(
                            color: const Color(
                              0xFF30E8BF,
                            ).withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      child: const Text(
                        'RETURN HOME',
                        style: TextStyle(
                          color: Color(0xFF30E8BF),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GloriousEntrance extends StatelessWidget {
  final Widget child;
  final int delay;

  const _GloriousEntrance({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(
          top: delay.toDouble() / 1000,
        ), // Minor trick to pass delay
        child: child,
      ),
    );
  }
}
