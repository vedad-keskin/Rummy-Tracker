import 'package:flutter/material.dart';
import 'package:rummy_tracker/offline_db/player_service.dart';
import 'package:rummy_tracker/game_flow/phase_three_win.dart';
import 'package:rummy_tracker/offline_db/game_state_service.dart';

class PhaseTwoTrackingScreen extends StatefulWidget {
  final List<Player> selectedPlayers;
  final GameState? savedState;

  const PhaseTwoTrackingScreen({
    super.key,
    required this.selectedPlayers,
    this.savedState,
  });

  @override
  State<PhaseTwoTrackingScreen> createState() => _PhaseTwoTrackingScreenState();
}

class _PhaseTwoTrackingScreenState extends State<PhaseTwoTrackingScreen> {
  final List<Map<String, int>> _rounds = [];
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  final Map<String, TextEditingController> _scoreControllers = {};
  int _currentPlayerIndex = 0;
  bool _isInputExpanded = false;
  int? _highlightedPreset;
  Map<String, int>? _currentRound;
  final GameStateService _gameStateService = GameStateService();

  @override
  void initState() {
    super.initState();
    
    // Load saved state if available
    if (widget.savedState != null) {
      final savedState = widget.savedState!;
      _rounds.addAll(savedState.rounds);
      _currentRound = savedState.currentRound;
      _currentPlayerIndex = savedState.currentPlayerIndex;
      _isInputExpanded = savedState.isInputExpanded;
      
      // Initialize controllers with saved scores or defaults
      for (var player in widget.selectedPlayers) {
        final savedScore = savedState.scoreControllers[player.id] ?? '0';
        final controller = TextEditingController(text: savedScore);
        _scoreControllers[player.id] = controller;
        controller.addListener(() {
          _updateCurrentRound();
        });
      }
    } else {
      // Initialize fresh controllers
      for (var player in widget.selectedPlayers) {
        final controller = TextEditingController(text: '0');
        _scoreControllers[player.id] = controller;
        controller.addListener(() {
          _updateCurrentRound();
        });
      }
    }
    
    // Save initial state
    _saveGameState();
  }

  void _updateCurrentRound() {
    if (!_isInputExpanded) return;
    
    final Map<String, int> roundScores = {};
    bool hasAnyScore = false;

    for (var player in widget.selectedPlayers) {
      final value = int.tryParse(_scoreControllers[player.id]!.text) ?? 0;
      roundScores[player.id] = value;
      if (value != 0) {
        hasAnyScore = true;
      }
    }

    // Only create/update current round if at least one score is entered
    if (hasAnyScore) {
      setState(() {
        _currentRound = roundScores;
      });
    } else {
      setState(() {
        _currentRound = null;
      });
    }
    
    // Save state whenever round is updated
    _saveGameState();
  }

  void _saveGameState() {
    final scoreControllersMap = <String, String>{};
    for (var entry in _scoreControllers.entries) {
      scoreControllersMap[entry.key] = entry.value.text;
    }
    
    final gameState = GameState(
      selectedPlayerIds: widget.selectedPlayers.map((p) => p.id).toList(),
      rounds: _rounds,
      currentRound: _currentRound,
      currentPlayerIndex: _currentPlayerIndex,
      isInputExpanded: _isInputExpanded,
      scoreControllers: scoreControllersMap,
    );
    
    _gameStateService.saveGameState(gameState);
  }

  bool _isOnLastPlayer() {
    return _currentPlayerIndex == widget.selectedPlayers.length - 1;
  }

  String? _getWinningPlayerId(Map<String, int> totals) {
    if (totals.isEmpty || _rounds.isEmpty) return null;
    
    String? winnerId;
    int lowestScore = 0;
    
    totals.forEach((playerId, score) {
      if (winnerId == null || score < lowestScore) {
        lowestScore = score;
        winnerId = playerId;
      }
    });
    
    return winnerId;
  }

  Map<String, int> _getTotals() {
    final Map<String, int> totals = {};
    for (var player in widget.selectedPlayers) {
      totals[player.id] = 0;
    }
    // Add completed rounds
    for (var round in _rounds) {
      round.forEach((playerId, score) {
        totals[playerId] = (totals[playerId] ?? 0) + score;
      });
    }
    // Add current round being built (if exists)
    if (_currentRound != null) {
      _currentRound!.forEach((playerId, score) {
        totals[playerId] = (totals[playerId] ?? 0) + score;
      });
    }
    return totals;
  }

  void _applyPreset(int value) {
    final currentPlayer = widget.selectedPlayers[_currentPlayerIndex];
    setState(() {
      _scoreControllers[currentPlayer.id]!.text = value.toString();
      _highlightedPreset = value;
    });
    // Clear highlight after a short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _highlightedPreset = null;
        });
      }
    });
  }

  void _addPoint() {
    // Move to next player if available
    if (_currentPlayerIndex < widget.selectedPlayers.length - 1) {
      setState(() {
        _currentPlayerIndex++;
      });
      _saveGameState();
    }
  }

  void _finishRound() {
    final Map<String, int> roundScores = {};

    for (var player in widget.selectedPlayers) {
      final value = int.tryParse(_scoreControllers[player.id]!.text) ?? 0;
      roundScores[player.id] = value;
    }

    setState(() {
      _rounds.add(roundScores);
      // Reset all scores to 0
      for (var player in widget.selectedPlayers) {
        _scoreControllers[player.id]!.text = '0';
      }
      _currentPlayerIndex = 0;
      _isInputExpanded = false;
      _currentRound = null;
    });
    
    // Save state after round is finished
    _saveGameState();
    
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

  void _expandInput() {
    setState(() {
      _isInputExpanded = true;
      _currentPlayerIndex = 0;
    });
    _saveGameState();
  }

  Future<bool> _onWillPop() async {
    // Check if there are any rounds or a round in progress
    if (_rounds.isNotEmpty || _currentRound != null || _isInputExpanded) {
      final shouldPop = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1B263B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          title: Text(
            'EXIT GAME?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              fontFamily: 'serif',
            ),
          ),
          content: Text(
            'You have rounds in progress. Are you sure you want to exit? All progress will be lost.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              fontFamily: 'serif',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Clear game state when user confirms exit
                _gameStateService.clearGameState();
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF30E8BF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'EXIT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }
    return true;
  }

  void _declareWinner() {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        title: Text(
          'FINISH GAME?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontFamily: 'serif',
          ),
        ),
        content: Text(
          'Are you sure you want to finish the game and declare the winner?',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
            fontFamily: 'serif',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'FINISH',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
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
          // Clear game state when game is finished
          _gameStateService.clearGameState();
          
          final winner = widget.selectedPlayers.firstWhere((p) => p.id == winnerId);
          // Create rankings list with all players and their scores
          final rankings = widget.selectedPlayers.map((player) {
            return MapEntry(player, totals[player.id] ?? 0);
          }).toList()
            ..sort((a, b) => a.value.compareTo(b.value)); // Sort by score (lowest first)
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhaseThreeWinScreen(
                winner: winner,
                rankings: rankings,
              ),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    for (var controller in _scoreControllers.values) {
      controller.dispose();
    }
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

  Widget _buildPlayerRowCell(Player player, int total, {double height = 52.0, bool isHighlighted = false, bool isWinner = false}) {
    final isNegative = total < 0;
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isWinner
            ? const Color(0xFFFFD700).withValues(alpha: 0.2)
            : (isHighlighted
                ? const Color(0xFF30E8BF).withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.03)),
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
        border: Border.all(
          color: isWinner
              ? const Color(0xFFFFD700).withValues(alpha: 0.8)
              : (isHighlighted
                  ? const Color(0xFF30E8BF).withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.05)),
          width: (isWinner || isHighlighted) ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (isWinner) ...[
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFFFD700),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    player.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isWinner
                          ? const Color(0xFFFFD700)
                          : (isHighlighted ? Colors.white : Colors.white70),
                      fontSize: 12,
                      fontWeight: isWinner ? FontWeight.w900 : FontWeight.bold,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$total',
            style: TextStyle(
              color: isWinner
                  ? const Color(0xFFFFD700)
                  : (isNegative ? const Color(0xFF30E8BF) : Colors.white),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton(int value, {String? label, bool isSpecial = false}) {
    final displayLabel = label ?? (value >= 0 ? '+$value' : '$value');
    final isHighlighted = _highlightedPreset == value;
    return GestureDetector(
      onTap: () => _applyPreset(value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isHighlighted
              ? const Color(0xFF30E8BF).withValues(alpha: 0.3)
              : (isSpecial
                  ? const Color(0xFF30E8BF).withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFF30E8BF)
                : (isSpecial
                    ? const Color(0xFF30E8BF).withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.1)),
            width: isHighlighted ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            displayLabel,
            style: TextStyle(
              color: isHighlighted || isSpecial ? const Color(0xFF30E8BF) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totals = _getTotals();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          // Clear game state when explicitly exiting via back gesture
          _gameStateService.clearGameState();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
                        onPressed: () async {
                          final shouldPop = await _onWillPop();
                          if (shouldPop && context.mounted) {
                            // Clear game state when explicitly exiting
                            _gameStateService.clearGameState();
                            Navigator.pop(context);
                          }
                        },
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
                      const double nameWidth = 140.0;
                      const double roundWidth = 70.0;
                      const double headerHeight = 60.0;
                      const double rowHeight = 52.0;
                      final double sidePadding = 12.0;

                      final int playerCount = widget.selectedPlayers.length;
                      final int roundCount = _rounds.length + (_currentRound != null ? 1 : 0);
                      final double scrollableWidth = roundCount * roundWidth;

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: sidePadding),
                        child: Row(
                          children: [
                            // 1. Fixed Left: Player Names with Totals
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
                                      itemBuilder: (context, i) {
                                        final player = widget.selectedPlayers[i];
                                        final total = totals[player.id] ?? 0;
                                        final isHighlighted = _isInputExpanded && i == _currentPlayerIndex;
                                        final winningPlayerId = _getWinningPlayerId(totals);
                                        final isWinner = !_isInputExpanded && 
                                                         _rounds.isNotEmpty && 
                                                         winningPlayerId == player.id;
                                        return GestureDetector(
                                          onTap: () {
                                            if (_isInputExpanded) {
                                              setState(() {
                                                _currentPlayerIndex = i;
                                              });
                                              _saveGameState();
                                            }
                                          },
                                          child: _buildPlayerRowCell(
                                            player,
                                            total,
                                            height: rowHeight,
                                            isHighlighted: isHighlighted,
                                            isWinner: isWinner,
                                          ),
                                        );
                                      },
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
                                    constraints.maxWidth - nameWidth - 10,
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
                                            final isCurrentRound = index == _rounds.length && _currentRound != null;
                                            return SizedBox(
                                              width: roundWidth,
                                              child: Center(
                                                child: Text(
                                                  'R${index + 1}',
                                                  style: TextStyle(
                                                    color: isCurrentRound
                                                        ? const Color(0xFF30E8BF)
                                                        : Colors.white.withValues(alpha: 0.3),
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
                                        child: (_rounds.isEmpty && _currentRound == null)
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
                                                  bottom: 240,
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
                                                          final score = rIndex < _rounds.length
                                                              ? (_rounds[rIndex][player.id] ?? 0)
                                                              : (_currentRound?[player.id] ?? 0);
                                                          final isCurrentRound = rIndex == _rounds.length && _currentRound != null;
                                                          return SizedBox(
                                                            width: roundWidth,
                                                            child: Container(
                                                              decoration: isCurrentRound
                                                                  ? BoxDecoration(
                                                                      color: const Color(0xFF30E8BF).withValues(alpha: 0.1),
                                                                      border: Border.all(
                                                                        color: const Color(0xFF30E8BF).withValues(alpha: 0.3),
                                                                        width: 1,
                                                                      ),
                                                                    )
                                                                  : null,
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
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Score Input Section
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: _isInputExpanded
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Preset Buttons - Row 1
                      Row(
                        children: [
                          Expanded(child: _buildPresetButton(0)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildPresetButton(-40, label: '-40')),
                          const SizedBox(width: 8),
                          Expanded(child: _buildPresetButton(-140, label: '-140')),
                          const SizedBox(width: 8),
                          Expanded(child: _buildPresetButton(-500, label: 'RUMMY', isSpecial: true)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Preset Buttons - Row 2
                      Row(
                        children: [
                          Expanded(child: _buildPresetButton(5, label: '+5')),
                          const SizedBox(width: 8),
                          Expanded(child: _buildPresetButton(10, label: '+10')),
                          const SizedBox(width: 8),
                          Expanded(child: _buildPresetButton(100, label: '+100')),
                          const SizedBox(width: 8),
                          Expanded(child: _buildPresetButton(200, label: '+200')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Input Field and Action Button
                      Row(
                        children: [
                          // Score Input Field
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF30E8BF).withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: TextField(
                                controller: _scoreControllers[widget.selectedPlayers[_currentPlayerIndex].id],
                                keyboardType: const TextInputType.numberWithOptions(signed: true),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF30E8BF),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0',
                                  hintStyle: TextStyle(
                                    color: Colors.white24,
                                    fontSize: 24,
                                  ),
                                ),
                                onTap: () {
                                  final controller = _scoreControllers[widget.selectedPlayers[_currentPlayerIndex].id]!;
                                  // Select all text when tapped
                                  controller.selection = TextSelection(
                                    baseOffset: 0,
                                    extentOffset: controller.text.length,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // ADD POINT or COMPLETE ROUND Button
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isOnLastPlayer() ? _finishRound : _addPoint,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isOnLastPlayer()
                                    ? const Color(0xFFFFD700) // Gold
                                    : const Color(0xFF30E8BF),
                                foregroundColor: _isOnLastPlayer() ? Colors.black : Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 8,
                                shadowColor: _isOnLastPlayer()
                                    ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                                    : const Color(0xFF30E8BF).withValues(alpha: 0.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isOnLastPlayer() ? Icons.check_circle_rounded : Icons.add_rounded,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isOnLastPlayer() ? 'COMPLETE' : 'ADD POINT',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _expandInput,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF30E8BF),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                            shadowColor: const Color(0xFF30E8BF).withValues(alpha: 0.5),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_rounded, size: 24),
                              SizedBox(width: 4),
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _declareWinner,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700), // Gold
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 8,
                              shadowColor: const Color(0xFFFFD700).withValues(alpha: 0.5),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.emoji_events_rounded, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'FINISH',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
      ),
    );
  }
}
