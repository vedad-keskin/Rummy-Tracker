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

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final players = await _playerService.loadPlayers();
    setState(() {
      _allPlayers = players;
    });
  }

  void _togglePlayer(String id) {
    setState(() {
      if (_selectedPlayerIds.contains(id)) {
        _selectedPlayerIds.remove(id);
      } else {
        _selectedPlayerIds.add(id);
      }
    });
  }

  void _startGame() {
    if (_selectedPlayerIds.length < 2) return;

    // For now, just show a success message or navigate to a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Game Started with Selected Players!',
          style: TextStyle(fontFamily: 'serif'),
        ),
        backgroundColor: Color(0xFF30E8BF),
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
                        const SizedBox(
                          width: 5,
                        ), // Spacer to balance back button
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
                                color: Colors.white.withOpacity(0.3),
                                letterSpacing: 2,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: _allPlayers.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final player = _allPlayers[index];
                              final isSelected = _selectedPlayerIds.contains(
                                player.id,
                              );

                              return _AnimatedEntry(
                                delay: 300 + (index * 100),
                                child: GestureDetector(
                                  onTap: () => _togglePlayer(player.id),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(
                                              0xFF30E8BF,
                                            ).withOpacity(0.15)
                                          : Colors.white.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(
                                                0xFF30E8BF,
                                              ).withOpacity(0.5)
                                            : Colors.white.withOpacity(0.1),
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF30E8BF,
                                                ).withOpacity(0.2),
                                                blurRadius: 15,
                                                spreadRadius: -5,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Row(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFF30E8BF)
                                                : Colors.white.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isSelected
                                                ? Icons.check_rounded
                                                : Icons.person_outline_rounded,
                                            color: isSelected
                                                ? Colors.black
                                                : Colors.white54,
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
                                        if (isSelected)
                                          const Icon(
                                            Icons.star_rounded,
                                            color: Color(0xFF30E8BF),
                                            size: 20,
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
                      color: canStart ? null : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: canStart
                          ? [
                              BoxShadow(
                                color: const Color(0xFF30E8BF).withOpacity(0.3),
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
