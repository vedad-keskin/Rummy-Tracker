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
  final ScrollController _verticalController = ScrollController();
  final ScrollController _totalVerticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

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
        if (_verticalController.hasClients) {
          _verticalController.animateTo(
            _verticalController.position.maxScrollExtent,
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
    int maxNegative = 1;

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
  void dispose() {
    _verticalController.dispose();
    _totalVerticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  Widget _buildHeaderCell(
    String text, {
    bool isLeft = false,
    bool isRight = false,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? const Radius.circular(20) : Radius.zero,
          right: isRight ? const Radius.circular(20) : Radius.zero,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            fontFamily: 'serif',
          ),
        ),
      ),
    );
  }

  Widget _buildRowCell(
    String text, {
    double height = 52.0,
    bool isName = false,
    bool isTotal = false,
    bool isNegative = false,
  }) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isTotal
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: isName
            ? const BorderRadius.horizontal(left: Radius.circular(16))
            : (isTotal
                  ? const BorderRadius.horizontal(right: Radius.circular(16))
                  : BorderRadius.zero),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Center(
        child: Text(
          text.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isNegative
                ? const Color(0xFF30E8BF)
                : (isName ? Colors.white70 : Colors.white),
            fontSize: isTotal ? 16 : 12,
            fontWeight: isTotal || isName ? FontWeight.bold : FontWeight.normal,
            fontFamily: isTotal ? 'monospace' : 'serif',
          ),
        ),
      ),
    );
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
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Master Grid (Inverted: Players as Rows, Rounds as Columns)
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const double nameWidth = 100.0;
                      const double totalWidth = 80.0;
                      const double roundWidth = 70.0;
                      const double headerHeight = 60.0;
                      const double rowHeight = 52.0;
                      final double sidePadding = 12.0;

                      final int playerCount = widget.selectedPlayers.length;
                      final int roundCount = _rounds.length;
                      final double scrollableWidth = roundCount * roundWidth;

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: sidePadding),
                        child: Row(
                          children: [
                            // 1. Fixed Left: Player Names
                            SizedBox(
                              width: nameWidth,
                              child: Column(
                                children: [
                                  _buildHeaderCell('PLAYERS', isLeft: true),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: ListView.builder(
                                      controller: _verticalController,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: playerCount,
                                      itemBuilder: (context, i) =>
                                          _buildRowCell(
                                            widget.selectedPlayers[i].name,
                                            isName: true,
                                            height: rowHeight,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 2. Scrollable Middle: Round Scores
                            Expanded(
                              child: SingleChildScrollView(
                                controller: _horizontalController,
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: scrollableWidth.clamp(
                                    constraints.maxWidth -
                                        nameWidth -
                                        totalWidth -
                                        10,
                                    2000,
                                  ),
                                  child: Column(
                                    children: [
                                      // Rounds Header Row
                                      SizedBox(
                                        height: headerHeight,
                                        child: Row(
                                          children: List.generate(roundCount, (
                                            index,
                                          ) {
                                            return SizedBox(
                                              width: roundWidth,
                                              child: Center(
                                                child: Text(
                                                  'R${index + 1}',
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.3),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Scores Body
                                      Expanded(
                                        child: _rounds.isEmpty
                                            ? Center(
                                                child: Text(
                                                  'NO ROUNDS',
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.1),
                                                    letterSpacing: 2,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                            : ListView.builder(
                                                itemCount: playerCount,
                                                padding: const EdgeInsets.only(
                                                  bottom: 120,
                                                ),
                                                itemBuilder: (context, pIndex) {
                                                  // Master Synchronizer
                                                  return NotificationListener<
                                                    ScrollNotification
                                                  >(
                                                    onNotification: (notification) {
                                                      if (notification
                                                          is ScrollUpdateNotification) {
                                                        _verticalController
                                                            .jumpTo(
                                                              notification
                                                                  .metrics
                                                                  .pixels,
                                                            );
                                                        _totalVerticalController
                                                            .jumpTo(
                                                              notification
                                                                  .metrics
                                                                  .pixels,
                                                            );
                                                      }
                                                      return false;
                                                    },
                                                    child: Container(
                                                      height: rowHeight,
                                                      margin:
                                                          const EdgeInsets.only(
                                                            bottom: 8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha: 0.03,
                                                            ),
                                                        border: Border(
                                                          top: BorderSide(
                                                            color: Colors.white
                                                                .withValues(
                                                                  alpha: 0.05,
                                                                ),
                                                          ),
                                                          bottom: BorderSide(
                                                            color: Colors.white
                                                                .withValues(
                                                                  alpha: 0.05,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: List.generate(roundCount, (
                                                          rIndex,
                                                        ) {
                                                          final player = widget
                                                              .selectedPlayers[pIndex];
                                                          final score =
                                                              _rounds[rIndex][player
                                                                  .id] ??
                                                              0;
                                                          return SizedBox(
                                                            width: roundWidth,
                                                            child: Center(
                                                              child: Text(
                                                                score == 0
                                                                    ? '0'
                                                                    : (score > 0
                                                                          ? '+$score'
                                                                          : '$score'),
                                                                style: TextStyle(
                                                                  color:
                                                                      score < 0
                                                                      ? const Color(
                                                                          0xFF30E8BF,
                                                                        )
                                                                      : Colors.white.withValues(
                                                                          alpha:
                                                                              0.7,
                                                                        ),
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'monospace',
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }),
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
                            ),

                            // 3. Fixed Right: Totals
                            SizedBox(
                              width: totalWidth,
                              child: Column(
                                children: [
                                  _buildHeaderCell('TOTAL', isRight: true),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: ListView.builder(
                                      controller: _totalVerticalController,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: playerCount,
                                      itemBuilder: (context, i) {
                                        final player =
                                            widget.selectedPlayers[i];
                                        final score = totals[player.id] ?? 0;
                                        return _buildRowCell(
                                          '$score',
                                          height: rowHeight,
                                          isTotal: true,
                                          isNegative: score < 0,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
        child: SingleChildScrollView(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.players.asMap().entries.map((entry) {
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
                }).toList(),
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
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                ),
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
