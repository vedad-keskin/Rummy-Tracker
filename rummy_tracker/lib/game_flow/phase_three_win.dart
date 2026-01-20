import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rummy_tracker/offline_db/player_service.dart';
import 'package:rummy_tracker/offline_db/language_service.dart';
import 'package:rummy_tracker/layouts/main_layout.dart';

class PhaseThreeWinScreen extends StatefulWidget {
  final Player winner;
  final List<MapEntry<Player, int>> rankings;

  const PhaseThreeWinScreen({
    super.key,
    required this.winner,
    required this.rankings,
  });

  @override
  State<PhaseThreeWinScreen> createState() => _PhaseThreeWinScreenState();
}

class _PhaseThreeWinScreenState extends State<PhaseThreeWinScreen>
    with TickerProviderStateMixin {
  final PlayerService _playerService = PlayerService();
  late AnimationController _celebrationController;
  late AnimationController _rankingsController;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _rankingsAnimation;

  @override
  void initState() {
    super.initState();
    _recordWin();
    
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _rankingsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _celebrationAnimation = CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    );
    
    _rankingsAnimation = CurvedAnimation(
      parent: _rankingsController,
      curve: Curves.easeOutCubic,
    );
    
    _celebrationController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _rankingsController.forward();
      }
    });
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _rankingsController.dispose();
    super.dispose();
  }

  Future<void> _recordWin() async {
    await _playerService.incrementWin(widget.winner.id);
  }

  @override
  Widget build(BuildContext context) {
    final languageService = context.watch<LanguageService>();
    
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
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),
          // Golden Glow Effect
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _celebrationAnimation,
              builder: (context, child) {
                final animValue = _celebrationAnimation.value.clamp(0.0, 1.0);
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.5 * animValue,
                      colors: [
                        const Color(0xFFFFD700).withValues(
                          alpha: (0.2 * animValue).clamp(0.0, 1.0),
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Winner Announcement Section - Minimalistic
                  AnimatedBuilder(
                    animation: _celebrationAnimation,
                    builder: (context, child) {
                      final animValue = _celebrationAnimation.value.clamp(0.0, 1.0);
                      return Transform.scale(
                        scale: 0.7 + (0.3 * animValue),
                        child: Opacity(
                          opacity: animValue.clamp(0.0, 1.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 32,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.emoji_events_rounded,
                                  color: Color(0xFFFFD700),
                                  size: 48,
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      languageService.translate('winner'),
                                      style: TextStyle(
                                        color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 4,
                                        fontFamily: 'serif',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.winner.name.toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFFFFD700),
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'serif',
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  // Rankings Section
                  AnimatedBuilder(
                    animation: _rankingsAnimation,
                    builder: (context, child) {
                      final animValue = _rankingsAnimation.value.clamp(0.0, 1.0);
                      return Opacity(
                        opacity: animValue,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - animValue)),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.leaderboard_rounded,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      languageService.translate('session_rankings'),
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 4,
                                        fontFamily: 'serif',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ...widget.rankings.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final playerEntry = entry.value;
                                  final player = playerEntry.key;
                                  final score = playerEntry.value;
                                  final isWinner = player.id == widget.winner.id;
                                  final rank = index + 1;
                                  
                                  return _buildRankingItem(
                                    rank: rank,
                                    player: player,
                                    score: score,
                                    isWinner: isWinner,
                                    delay: index * 100,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  // Return Home Button
                  AnimatedBuilder(
                    animation: _rankingsAnimation,
                    builder: (context, child) {
                      final animValue = _rankingsAnimation.value.clamp(0.0, 1.0);
                      return Opacity(
                        opacity: animValue,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const MainMenuScreen(),
                                transitionDuration: const Duration(milliseconds: 600),
                                reverseTransitionDuration: const Duration(milliseconds: 400),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOut,
                                    ),
                                    child: child,
                                  );
                                },
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF30E8BF),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                            shadowColor: const Color(0xFF30E8BF).withValues(alpha: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.home_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                languageService.translate('return_home'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingItem({
    required int rank,
    required Player player,
    required int score,
    required bool isWinner,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: clampedValue,
          child: Transform.translate(
            offset: Offset(20 * (1 - clampedValue), 0),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isWinner
                    ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isWinner
                      ? const Color(0xFFFFD700).withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.05),
                  width: isWinner ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Rank Badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isWinner
                          ? const Color(0xFFFFD700)
                          : Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isWinner
                            ? const Color(0xFFFFD700)
                            : Colors.white.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '#$rank',
                        style: TextStyle(
                          color: isWinner ? Colors.black : Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Player Name
                  Expanded(
                    child: Row(
                      children: [
                        if (isWinner) ...[
                          const Icon(
                            Icons.emoji_events_rounded,
                            color: Color(0xFFFFD700),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            player.name.toUpperCase(),
                            style: TextStyle(
                              color: isWinner
                                  ? const Color(0xFFFFD700)
                                  : Colors.white,
                              fontSize: 16,
                              fontWeight: isWinner
                                  ? FontWeight.w900
                                  : FontWeight.bold,
                              fontFamily: 'serif',
                              letterSpacing: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Score
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: score < 0
                          ? const Color(0xFF30E8BF).withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: score < 0
                            ? const Color(0xFF30E8BF).withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      '$score',
                      style: TextStyle(
                        color: score < 0
                            ? const Color(0xFF30E8BF)
                            : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
