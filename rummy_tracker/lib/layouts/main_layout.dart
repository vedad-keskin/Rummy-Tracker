import 'package:flutter/material.dart';
import 'package:rummy_tracker/background.dart';
import 'package:provider/provider.dart';
import 'package:rummy_tracker/players_section/players_screen.dart';
import 'package:rummy_tracker/ranking_section/ranking_screen.dart';
import 'package:rummy_tracker/components/team_credits_dialog.dart';
import 'package:rummy_tracker/components/language_switch.dart';
import 'package:rummy_tracker/components/how_to_play_button.dart';
import 'package:rummy_tracker/components/rules_dialog.dart';
import 'package:rummy_tracker/components/studio_mark.dart';
import 'package:rummy_tracker/game_flow/phase_one_selection.dart';
import 'package:rummy_tracker/game_flow/phase_two_tracking.dart';
import 'package:rummy_tracker/offline_db/game_state_service.dart';
import 'package:rummy_tracker/offline_db/player_service.dart';
import 'package:rummy_tracker/offline_db/language_service.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final GameStateService _gameStateService = GameStateService();
  final PlayerService _playerService = PlayerService();

  void _showEasterEgg() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.read<LanguageService>().translate('about_app'),
      barrierColor: Colors.black87,
      transitionDuration: Duration(
        milliseconds: MediaQuery.disableAnimationsOf(context) ? 150 : 220,
      ),
      pageBuilder: (context, anim1, anim2) => const TeamCreditsDialog(),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageService = context.watch<LanguageService>();
    final backgrounds = context.watch<BackgroundService>();
    final logoSize =
        (MediaQuery.sizeOf(context).height -
                MediaQuery.paddingOf(context).vertical -
                496)
            .clamp(112.0, 240.0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 400),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              layoutBuilder: (current, previous) => Stack(
                fit: StackFit.expand,
                children: [...previous, if (current != null) current],
              ),
              child: Image.asset(
                backgrounds.assetPath,
                key: ValueKey(backgrounds.assetPath),
                fit: BoxFit.cover,
                excludeFromSemantics: true,
              ),
            ),
          ),
          // Gradient Overlay for depth
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 64, 24, 80),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Title / Brand
                    Center(
                      child: HeroMode(
                        enabled: !MediaQuery.disableAnimationsOf(context),
                        child: Hero(
                          tag: 'rummy-logo',
                          child: Image.asset(
                            'assets/images/logo_transparent.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                            semanticLabel: 'Rummy Tracker',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Centered Menu Container
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 40,
                            spreadRadius: -10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MenuTile(
                            title: languageService.translate('play_now'),
                            icon: Icons.play_arrow_rounded,
                            color: const Color.fromARGB(255, 255, 1, 1),
                            onTap: () async {
                              // Check if there's a game in progress
                              final gameState = await _gameStateService
                                  .loadGameState();

                              if (gameState != null &&
                                  gameState.hasGameInProgress) {
                                // Load players and restore game state
                                final allPlayers = await _playerService
                                    .loadPlayers();
                                final selectedPlayers = allPlayers
                                    .where(
                                      (p) => gameState.selectedPlayerIds
                                          .contains(p.id),
                                    )
                                    .toList();

                                if (selectedPlayers.length >= 2) {
                                  // Navigate directly to tracking screen with saved state
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder:
                                          (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                          ) => PhaseTwoTrackingScreen(
                                            selectedPlayers: selectedPlayers,
                                            savedState: gameState,
                                          ),
                                      transitionsBuilder:
                                          (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                            child,
                                          ) {
                                            var curve = Curves.easeOutCubic;
                                            var curvedAnimation =
                                                CurvedAnimation(
                                                  parent: animation,
                                                  curve: curve,
                                                );

                                            return FadeTransition(
                                              opacity: curvedAnimation,
                                              child: ScaleTransition(
                                                scale: Tween<double>(
                                                  begin: 0.95,
                                                  end: 1.0,
                                                ).animate(curvedAnimation),
                                                child: child,
                                              ),
                                            );
                                          },
                                      transitionDuration: const Duration(
                                        milliseconds: 600,
                                      ),
                                    ),
                                  );
                                  return;
                                }
                              }

                              // No game in progress, go to player selection
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const PhaseOneScreen(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        var curve = Curves.easeOutCubic;
                                        var curvedAnimation = CurvedAnimation(
                                          parent: animation,
                                          curve: curve,
                                        );

                                        return FadeTransition(
                                          opacity: curvedAnimation,
                                          child: ScaleTransition(
                                            scale: Tween<double>(
                                              begin: 0.95,
                                              end: 1.0,
                                            ).animate(curvedAnimation),
                                            child: child,
                                          ),
                                        );
                                      },
                                  transitionDuration: const Duration(
                                    milliseconds: 600,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          MenuTile(
                            title: languageService.translate('players'),
                            icon: Icons.people_alt_rounded,
                            color: const Color(0xFFFFAB40),
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const PlayersScreen(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        var curve = Curves.easeOutCubic;
                                        var curvedAnimation = CurvedAnimation(
                                          parent: animation,
                                          curve: curve,
                                        );

                                        return FadeTransition(
                                          opacity: curvedAnimation,
                                          child: ScaleTransition(
                                            scale: Tween<double>(
                                              begin: 0.95,
                                              end: 1.0,
                                            ).animate(curvedAnimation),
                                            child: child,
                                          ),
                                        );
                                      },
                                  transitionDuration: const Duration(
                                    milliseconds: 600,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          MenuTile(
                            title: languageService.translate('ranking'),
                            icon: Icons.leaderboard_rounded,
                            color: const Color(0xFF30E8BF),
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const RankingScreen(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        var curve = Curves.easeOutCubic;
                                        var curvedAnimation = CurvedAnimation(
                                          parent: animation,
                                          curve: curve,
                                        );

                                        return FadeTransition(
                                          opacity: curvedAnimation,
                                          child: ScaleTransition(
                                            scale: Tween<double>(
                                              begin: 0.95,
                                              end: 1.0,
                                            ).animate(curvedAnimation),
                                            child: child,
                                          ),
                                        );
                                      },
                                  transitionDuration: const Duration(
                                    milliseconds: 600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Keep header controls above the scroll view's hit-test area.
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: const LanguageSwitch(),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: HowToPlayButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const RulesDialog(),
                );
              },
            ),
          ),
          Positioned(
            left: 16,
            bottom: MediaQuery.paddingOf(context).bottom + 16,
            child: IconButton.outlined(
              key: const ValueKey('change-background'),
              tooltip:
                  '${languageService.translate('background')}: '
                  '${languageService.translate(backgrounds.nameKey)}. '
                  '${languageService.translate('change_background')}',
              onPressed: backgrounds.next,
              icon: const Icon(Icons.palette_outlined, size: 20),
              style: IconButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                shape: const CircleBorder(),
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
          // Studio branding / credits trigger
          Positioned(
            right: 16,
            bottom: MediaQuery.paddingOf(context).bottom + 16,
            child: GestureDetector(
              key: const ValueKey('app-credits'),
              behavior: HitTestBehavior.opaque,
              onLongPress: _showEasterEgg,
              child: Semantics(
                label: 'Nightfall Studio',
                child: const SizedBox(
                  width: 80,
                  height: 48,
                  child: Center(
                    child: StudioMark(forceInvert: true, height: 22),
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

class MenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const MenuTile({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.4), width: 1.2),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), Colors.transparent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            children: [
              // Stylized Icon Container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              // Text Content
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    fontFamily: 'serif',
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.3),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
