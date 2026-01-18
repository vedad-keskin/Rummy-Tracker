import 'package:flutter/material.dart';
import 'package:rummy_tracker/offline_db/player_service.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final PlayerService _playerService = PlayerService();
  List<Player> _players = [];
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final players = await _playerService.loadPlayers();
    setState(() {
      _players = players;
    });
  }

  Future<void> _addPlayer() async {
    if (_nameController.text.trim().isEmpty) return;

    final newName = _nameController.text.trim().toLowerCase();
    final isDuplicate = _players.any(
      (player) => player.name.toLowerCase() == newName,
    );

    if (isDuplicate) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Player "${_nameController.text.trim()}" already exists!',
              style: const TextStyle(fontFamily: 'serif'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    try {
      final updated = await _playerService.addPlayer(
        _players,
        _nameController.text.trim(),
      );
      setState(() {
        _players = updated;
        _nameController.clear();
      });
    } catch (e) {
      debugPrint('Error adding player: $e');
    }
  }

  Future<void> _removePlayer(String id) async {
    try {
      final updated = await _playerService.removePlayer(_players, id);
      setState(() {
        _players = updated;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(fontFamily: 'serif'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
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
                  Row(
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
                          'PLAYERS',
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
                      const SizedBox(width: 48), // Balancing the back button
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Input Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'serif',
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              hintText: 'ENTER NAME',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                letterSpacing: 2,
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _addPlayer(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: _addPlayer,
                          icon: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF30E8BF,
                            ).withOpacity(0.8),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Players List
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: _players.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final player = _players[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    (index + 1).toString(),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
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
                              IconButton(
                                icon: Icon(
                                  Icons.edit_rounded,
                                  color: Colors.blue.withOpacity(0.7),
                                  size: 20,
                                ),
                                onPressed: () => _editPlayer(player),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red.withOpacity(0.7),
                                  size: 20,
                                ),
                                onPressed: () => _removePlayer(player.id),
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
          ),
        ],
      ),
    );
  }

  Future<void> _editPlayer(Player player) async {
    final editController = TextEditingController(text: player.name);
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
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
                  'EDIT NAME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextField(
                    controller: editController,
                    autofocus: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'serif',
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'ENTER NEW NAME',
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
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
                        onPressed: () async {
                          if (editController.text.trim().isNotEmpty) {
                            try {
                              final updated = await _playerService.updatePlayer(
                                _players,
                                player.id,
                                editController.text.trim(),
                              );
                              setState(() {
                                _players = updated;
                              });
                              if (mounted) Navigator.pop(context);
                            } catch (e) {
                              debugPrint('Error updating player: $e');
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF30E8BF),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'SAVE',
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
        );
      },
    );
  }
}
