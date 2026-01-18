import 'package:flutter/material.dart';
import 'package:rummy_tracker/offline_db/player_service.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final PlayerService _playerService = PlayerService();
  List<Player> _players = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final players = await _playerService.loadPlayers();
    // Sort by wins descending
    players.sort((a, b) => b.wins.compareTo(a.wins));
    if (mounted) {
      setState(() {
        _players = players;
      });
    }
  }

  Future<void> _showResetConfirmation() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1B263B),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'RESET WINS?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This will clear all player win records. This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'RESET',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      final updatedPlayers = await _playerService.resetPlayersWins(_players);
      if (mounted) {
        setState(() {
          _players = updatedPlayers;
        });
      }
    }
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
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Header
                  _AnimatedEntry(
                    delay: 0,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'RANKING',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              fontFamily: 'serif',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _showResetConfirmation,
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.redAccent,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Ranking List
                  Expanded(
                    child: _players.isEmpty
                        ? Center(
                            child: Text(
                              'NO PLAYERS FOUND',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                letterSpacing: 2,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: _players.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final player = _players[index];
                              final rank = index + 1;

                              Color rankColor = Colors.white70;
                              double scale = 1.0;
                              IconData? trophyIcon;

                              if (rank == 1) {
                                rankColor = const Color(0xFFFFD700); // Gold
                                scale = 1.05;
                                trophyIcon = Icons.emoji_events_rounded;
                              } else if (rank == 2) {
                                rankColor = const Color(0xFFC0C0C0); // Silver
                                trophyIcon = Icons.emoji_events_rounded;
                              } else if (rank == 3) {
                                rankColor = const Color(0xFFCD7F32); // Bronze
                                trophyIcon = Icons.emoji_events_rounded;
                              }

                              return _AnimatedEntry(
                                delay: 200 + (index * 100),
                                child: Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(
                                        rank == 1 ? 0.15 : 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: rankColor.withOpacity(
                                          rank <= 3 ? 0.4 : 0.1,
                                        ),
                                        width: rank <= 3 ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: rankColor.withOpacity(
                                                  0.1,
                                                ),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: rankColor.withOpacity(
                                                    0.2,
                                                  ),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  rank.toString(),
                                                  style: TextStyle(
                                                    color: rankColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (trophyIcon != null)
                                              Positioned(
                                                top: -6,
                                                right: -3,
                                                child: Icon(
                                                  trophyIcon,
                                                  color: rankColor,
                                                  size: 20,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black45,
                                                      blurRadius: 8,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            player.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'serif',
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${player.wins}',
                                              style: TextStyle(
                                                color: rankColor,
                                                fontSize: 24,
                                                fontWeight: FontWeight.w900,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                            Text(
                                              'WINS',
                                              style: TextStyle(
                                                color: rankColor.withOpacity(
                                                  0.5,
                                                ),
                                                fontSize: 10,
                                                letterSpacing: 2,
                                                fontWeight: FontWeight.bold,
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

class _AnimatedEntry extends StatelessWidget {
  final Widget child;
  final int delay;

  const _AnimatedEntry({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
