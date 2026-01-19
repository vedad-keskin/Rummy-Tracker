import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GameState {
  final List<String> selectedPlayerIds;
  final List<Map<String, int>> rounds;
  final Map<String, int>? currentRound;
  final int currentPlayerIndex;
  final bool isInputExpanded;
  final Map<String, String> scoreControllers; // playerId -> score text

  GameState({
    required this.selectedPlayerIds,
    required this.rounds,
    this.currentRound,
    this.currentPlayerIndex = 0,
    this.isInputExpanded = false,
    this.scoreControllers = const {},
  });

  Map<String, dynamic> toJson() => {
        'selectedPlayerIds': selectedPlayerIds,
        'rounds': rounds.map((round) => round).toList(),
        'currentRound': currentRound,
        'currentPlayerIndex': currentPlayerIndex,
        'isInputExpanded': isInputExpanded,
        'scoreControllers': scoreControllers,
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      selectedPlayerIds: List<String>.from(json['selectedPlayerIds'] ?? []),
      rounds: (json['rounds'] as List<dynamic>?)
              ?.map((round) => Map<String, int>.from(round))
              .toList() ??
          [],
      currentRound: json['currentRound'] != null
          ? Map<String, int>.from(json['currentRound'])
          : null,
      currentPlayerIndex: json['currentPlayerIndex'] ?? 0,
      isInputExpanded: json['isInputExpanded'] ?? false,
      scoreControllers: json['scoreControllers'] != null
          ? Map<String, String>.from(json['scoreControllers'])
          : {},
    );
  }

  bool get hasGameInProgress => rounds.isNotEmpty || currentRound != null || isInputExpanded;
}

class GameStateService {
  static const String _storageKey = 'rummy_game_state';

  Future<void> saveGameState(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(state.toJson());
    await prefs.setString(_storageKey, encoded);
  }

  Future<GameState?> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final String? stateJson = prefs.getString(_storageKey);

    if (stateJson == null) {
      return null;
    }

    try {
      final Map<String, dynamic> decoded = jsonDecode(stateJson);
      return GameState.fromJson(decoded);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<bool> hasGameInProgress() async {
    final state = await loadGameState();
    return state?.hasGameInProgress ?? false;
  }
}
