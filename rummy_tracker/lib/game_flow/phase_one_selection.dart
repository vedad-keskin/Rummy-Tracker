import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:rummy_tracker/offline_db/player_service.dart';

class PhaseOneScreen extends StatefulWidget {
  const PhaseOneScreen({super.key});

  @override
  State<PhaseOneScreen> createState() => _PhaseOneScreenState();
}

class _PhaseOneScreenState extends State<PhaseOneScreen> {
  final PlayerService _playerService = PlayerService();
  List<Player> _allPlayers = [];
  final Set<String> _selectedPlayerIds = {};

  // Store random suit index and random rotation for each player to maintain consistency
  final Map<String, int> _playerSuits = {};
  final Map<String, double> _playerRotations = {};
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final players = await _playerService.loadPlayers();
    final savedIds = await _playerService.loadSelectedPlayerIds();

    setState(() {
      _allPlayers = players;

      // Assign random suits and rotations for each player
      for (var player in players) {
        if (!_playerSuits.containsKey(player.id)) {
          _playerSuits[player.id] = _random.nextInt(4);
          // Rotation strictly between 0.3 and 0.8 radians (bottom-left tilt)
          _playerRotations[player.id] = 0.3 + (_random.nextDouble() * 0.5);
        }
      }

      if (savedIds.isEmpty && players.length >= 2) {
        // Default to first two if nothing saved
        _selectedPlayerIds.addAll(players.take(2).map((p) => p.id));
        _saveSelection();
      } else {
        _selectedPlayerIds.addAll(savedIds);
      }
    });
  }

  Future<void> _saveSelection() async {
    await _playerService.saveSelectedPlayerIds(_selectedPlayerIds);
  }

  void _togglePlayer(String id) {
    setState(() {
      if (_selectedPlayerIds.contains(id)) {
        _selectedPlayerIds.remove(id);
      } else {
        _selectedPlayerIds.add(id);
      }
    });
    _saveSelection();
  }

  void _startGame() {
    if (_selectedPlayerIds.length < 2) return;

    // For now, just show a success message or navigate to a placeholder
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.style_rounded, color: Colors.black, size: 20),
              SizedBox(width: 12),
              Text(
                'GAME STARTED! GOOD LUCK!',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF30E8BF),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _getSuitIcon(String playerId, {double size = 20}) {
    final suitIndex = _playerSuits[playerId] ?? 0;
    final rotation = _playerRotations[playerId] ?? 0.0;

    final suits = [
      {'char': '♥', 'color': const Color(0xFFFF4D4D)},
      {'char': '♦', 'color': const Color(0xFFFF4D4D)},
      {'char': '♣', 'color': Colors.white},
      {'char': '♠', 'color': Colors.white},
    ];
    final suit = suits[suitIndex];

    return Transform.rotate(
      angle: rotation,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          border: Border.all(
            color: (suit['color'] as Color).withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (suit['color'] as Color).withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          suit['char'] as String,
          style: TextStyle(
            color: (suit['color'] as Color),
            fontSize: size,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canStart = _selectedPlayerIds.length >= 2;

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
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.9),
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
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.1,
                            ),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                        const Expanded(
                          child: Column(
                            children: [
                              Text(
                                'SELECT PLAYERS',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  fontFamily: 'serif',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 2), // Balancing spacer
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AnimatedEntry(
                    delay: 100,
                    child: Text(
                      '${_selectedPlayerIds.length} SELECTED (MIN. 2)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: canStart
                            ? const Color(0xFF30E8BF)
                            : Colors.white24,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Players List
                  Expanded(
                    child: _allPlayers.isEmpty
                        ? Center(
                            child: Text(
                              'NO PLAYERS FOUND',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                letterSpacing: 2,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.separated(
                            clipBehavior: Clip.none,
                            padding: const EdgeInsets.only(bottom: 120),
                            itemCount: _allPlayers.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 20),
                            itemBuilder: (context, index) {
                              final player = _allPlayers[index];
                              final isSelected = _selectedPlayerIds.contains(
                                player.id,
                              );

                              return _AnimatedEntry(
                                delay: 300 + (index * 100),
                                child: GestureDetector(
                                  onTap: () => _togglePlayer(player.id),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 20,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(
                                                  0xFF30E8BF,
                                                ).withValues(alpha: 0.15)
                                              : Colors.white.withValues(
                                                  alpha: 0.08,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(
                                                    0xFF30E8BF,
                                                  ).withValues(alpha: 0.5)
                                                : Colors.white.withValues(
                                                    alpha: 0.1,
                                                  ),
                                            width: isSelected ? 2 : 1,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFF30E8BF,
                                                    ).withValues(alpha: 0.2),
                                                    blurRadius: 15,
                                                    spreadRadius: -5,
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Row(
                                          children: [
                                            // Wins Badge
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 10,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Colors.black.withValues(
                                                        alpha: 0.3,
                                                      )
                                                    : Colors.white.withValues(
                                                        alpha: 0.05,
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? Colors.white.withValues(
                                                          alpha: 0.2,
                                                        )
                                                      : Colors.white.withValues(
                                                          alpha: 0.05,
                                                        ),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '${player.wins}',
                                                    style: TextStyle(
                                                      color: isSelected
                                                          ? const Color(
                                                              0xFF30E8BF,
                                                            )
                                                          : Colors.white54,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontFamily: 'serif',
                                                    ),
                                                  ),
                                                  Text(
                                                    'WINS',
                                                    style: TextStyle(
                                                      color: isSelected
                                                          ? Colors.white54
                                                          : Colors.white12,
                                                      fontSize: 8,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: Text(
                                                player.name,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.white70,
                                                  fontSize: 22,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w900
                                                      : FontWeight.bold,
                                                  fontFamily: 'serif',
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ),
                                            AnimatedScale(
                                              scale: isSelected ? 1.0 : 0.0,
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeOutBack,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF30E8BF),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.check_rounded,
                                                  color: Colors.black,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Decorative Overlapping Suit (Top-Right Border) - Only visible when selected
                                      Positioned(
                                        top: -12,
                                        right: -5,
                                        child: AnimatedScale(
                                          scale: isSelected ? 1.0 : 0.0,
                                          duration: const Duration(
                                            milliseconds: 500,
                                          ),
                                          curve: Curves.elasticOut,
                                          child: AnimatedOpacity(
                                            opacity: isSelected ? 1.0 : 0.0,
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            child: isSelected
                                                ? _getSuitIcon(player.id)
                                                : const SizedBox.shrink(),
                                          ),
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
            ),
          ),
          // Start Button pinned at bottom
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: _AnimatedEntry(
              delay: 800,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canStart ? _startGame : null,
                  borderRadius: BorderRadius.circular(24),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: canStart
                          ? const LinearGradient(
                              colors: [Color(0xFF30E8BF), Color(0xFF2BCCDF)],
                            )
                          : null,
                      color: canStart
                          ? null
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: canStart
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF30E8BF,
                                ).withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        'START GAME',
                        style: TextStyle(
                          color: canStart ? Colors.black : Colors.white24,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          fontFamily: 'serif',
                        ),
                      ),
                    ),
                  ),
                ),
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
