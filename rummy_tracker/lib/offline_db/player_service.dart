import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Player {
  final String id;
  final String name;
  final int wins;

  Player({required this.id, required this.name, this.wins = 0});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'wins': wins};

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      wins: (json['wins'] as int?) ?? (json['points'] as int?) ?? 0,
    );
  }
}

class PlayerService {
  static const String _storageKey = 'rummy_players';
  static const String _selectionKey = 'rummy_selected_ids';

  Future<List<Player>> loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? playersJson = prefs.getString(_storageKey);

    if (playersJson == null) {
      // Initialize default
      return _saveDefaultPlayer();
    }

    try {
      final List<dynamic> decoded = jsonDecode(playersJson);
      final List<Player> players = decoded
          .map((json) => Player.fromJson(json))
          .toList();

      if (players.isEmpty) {
        return _saveDefaultPlayer();
      }

      return players;
    } catch (e) {
      return _saveDefaultPlayer();
    }
  }

  Future<List<Player>> _saveDefaultPlayer() async {
    final defaultPlayer = Player(id: '1', name: 'Vedo', wins: 0);
    await savePlayers([defaultPlayer]);
    return [defaultPlayer];
  }

  Future<void> savePlayers(List<Player> players) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(players.map((p) => p.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<List<Player>> addPlayer(
    List<Player> currentPlayers,
    String name,
  ) async {
    final newPlayer = Player(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      wins: 0,
    );
    final updatedList = [...currentPlayers, newPlayer];
    await savePlayers(updatedList);
    return updatedList;
  }

  Future<List<Player>> removePlayer(
    List<Player> currentPlayers,
    String id,
  ) async {
    if (currentPlayers.length <= 1) {
      throw Exception('Cannot remove the last player');
    }
    final updatedList = currentPlayers.where((p) => p.id != id).toList();
    await savePlayers(updatedList);
    return updatedList;
  }

  Future<List<Player>> updatePlayer(
    List<Player> currentPlayers,
    String id,
    String newName,
  ) async {
    final updatedList = currentPlayers.map((p) {
      if (p.id == id) {
        return Player(id: id, name: newName, wins: p.wins);
      }
      return p;
    }).toList();
    await savePlayers(updatedList);
    return updatedList;
  }

  Future<List<Player>> resetPlayersWins(List<Player> currentPlayers) async {
    final updatedList = currentPlayers
        .map((p) => Player(id: p.id, name: p.name, wins: 0))
        .toList();
    await savePlayers(updatedList);
    return updatedList;
  }

  Future<void> saveSelectedPlayerIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_selectionKey, ids.toList());
  }

  Future<Set<String>> loadSelectedPlayerIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? ids = prefs.getStringList(_selectionKey);
    return ids?.toSet() ?? {};
  }
}
