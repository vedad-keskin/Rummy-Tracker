import 'package:flutter/material.dart';
import 'package:rummy_tracker/offline_db/player_service.dart';
import 'package:rummy_tracker/game_flow/phase_three_win.dart';

class PhaseTwoTrackingScreen extends StatefulWidget {
  final List<Player> selectedPlayers;

  const PhaseTwoTrackingScreen({super.key, required this.selectedPlayers});

  @override
  State<PhaseTwoTrackingScreen> createState() => _PhaseTwoTrackingScreenState();
}

class _PhaseTwoTrackingScreenState extends State<PhaseTwoTrackingScreen> {
  final List<Map<String, int>> _rounds = [];
  final ScrollController _scrollController = ScrollController();

  Map<String, int> _getTotals() {
    final Map<String, int> totals = {};
    for (var player in widget.selectedPlayers) {
      totals[player.id] = 0;
    }
    for (var round in _rounds) {
      round.forEach((playerId, score) {
        totals[playerId] = (totals[playerId] ?? 0) + score;
      });
    }
    return totals;
  }

  void _addRound() async {
    final roundScores = await showDialog<Map<String, int>>(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: false,
      builder: (context) => PointInputDialog(players: widget.selectedPlayers),
    );

    if (roundScores != null) {
      setState(() {
        _rounds.add(roundScores);
      });
      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _declareWinner() {
    final totals = _getTotals();
    String? winnerId;
    int maxNegative = 1; // Start with something higher than any possible win

    totals.forEach((playerId, score) {
      if (winnerId == null || score < maxNegative) {
        maxNegative = score;
        winnerId = playerId;
      }
    });

    if (winnerId != null) {
      final winner = widget.selectedPlayers.firstWhere((p) => p.id == winnerId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhaseThreeWinScreen(winner: winner),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totals = _getTotals();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'POINTS TRACKER',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            fontFamily: 'serif',
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance
                    ],
                  ),
                ),

                // Player Totals Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: widget.selectedPlayers.map((player) {
                      final score = totals[player.id] ?? 0;
                      return Expanded(
                        child: Column(
                          children: [
                            Text(
                              player.name.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$score',
                              style: TextStyle(
                                color: score < 0
                                    ? const Color(0xFF30E8BF)
                                    : Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // Rounds List/Grid
                Expanded(
                  child: _rounds.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.style_outlined,
                                color: Colors.white.withValues(alpha: 0.1),
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'NO ROUNDS YET',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          itemCount: _rounds.length,
                          itemBuilder: (context, index) {
                            final round = _rounds[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Text(
                                      'R${index + 1}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ...widget.selectedPlayers.map((player) {
                                    final score = round[player.id] ?? 0;
                                    return Expanded(
                                      child: Center(
                                        child: Text(
                                          score > 0 ? '+$score' : '$score',
                                          style: TextStyle(
                                            color: score < 0
                                                ? const Color(0xFF30E8BF)
                                                : Colors.white.withValues(
                                                    alpha: 0.7,
                                                  ),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _addRound,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF30E8BF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 8,
                      shadowColor: const Color(
                        0xFF30E8BF,
                      ).withValues(alpha: 0.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'ADD ROUND',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_rounds.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: _declareWinner,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      child: const Icon(Icons.emoji_events_rounded),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PointInputDialog extends StatefulWidget {
  final List<Player> players;

  const PointInputDialog({super.key, required this.players});

  @override
  State<PointInputDialog> createState() => _PointInputDialogState();
}

class _PointInputDialogState extends State<PointInputDialog> {
  final Map<String, TextEditingController> _controllers = {};
  int _currentPlayerIndex = 0;

  @override
  void initState() {
    super.initState();
    for (var player in widget.players) {
      _controllers[player.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final Map<String, int> results = {};
    for (var player in widget.players) {
      final value = int.tryParse(_controllers[player.id]!.text) ?? 0;
      results[player.id] = value;
    }
    Navigator.pop(context, results);
  }

  void _applyPreset(int value) {
    setState(() {
      _controllers[widget.players[_currentPlayerIndex].id]!.text = value
          .toString();
      if (_currentPlayerIndex < widget.players.length - 1) {
        _currentPlayerIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = widget.players[_currentPlayerIndex];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ROUND SCORES',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 24),

            // Current Player Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...widget.players.asMap().entries.map((entry) {
                  final index = entry.key;
                  final isCurrent = index == _currentPlayerIndex;
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFF30E8BF)
                          : Colors.white10,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 24),
            Text(
              currentPlayer.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _controllers[currentPlayer.id],
              keyboardType: TextInputType.numberWithOptions(signed: true),
              textAlign: TextAlign.center,
              autofocus: true,
              style: const TextStyle(
                color: Color(0xFF30E8BF),
                fontSize: 32,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
              ),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                border: InputBorder.none,
              ),
            ),

            const SizedBox(height: 32),

            // Presets Row 1: -40, -140, -500
            Row(
              children: [
                _buildPresetButton(-40, label: '-40'),
                const SizedBox(width: 8),
                _buildPresetButton(-140, label: '-140'),
                const SizedBox(width: 8),
                _buildPresetButton(-500, label: 'RUMMY', isSpecial: true),
              ],
            ),
            const SizedBox(height: 8),
            // Presets Row 2: +0, +5, +100, +200
            Row(
              children: [
                _buildPresetButton(0),
                const SizedBox(width: 8),
                _buildPresetButton(5),
                const SizedBox(width: 8),
                _buildPresetButton(100),
                const SizedBox(width: 8),
                _buildPresetButton(200),
              ],
            ),

            const SizedBox(height: 40),

            Row(
              children: [
                if (_currentPlayerIndex > 0)
                  Expanded(
                    child: TextButton(
                      onPressed: () => setState(() => _currentPlayerIndex--),
                      child: Text(
                        'BACK',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _currentPlayerIndex < widget.players.length - 1
                        ? () => setState(() => _currentPlayerIndex++)
                        : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _currentPlayerIndex < widget.players.length - 1
                          ? 'NEXT PLAYER'
                          : 'SAVE ROUND',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton(
    int value, {
    String? label,
    bool isSpecial = false,
  }) {
    final displayLabel = label ?? (value >= 0 ? '+$value' : '$value');

    return Expanded(
      child: InkWell(
        onTap: () => _applyPreset(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSpecial
                ? const Color(0xFF30E8BF).withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSpecial
                  ? const Color(0xFF30E8BF).withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Center(
            child: Text(
              displayLabel,
              style: TextStyle(
                color: isSpecial ? const Color(0xFF30E8BF) : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
