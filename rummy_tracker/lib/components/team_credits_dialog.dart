import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rummy_tracker/offline_db/language_service.dart';
import 'package:rummy_tracker/components/studio_mark.dart';

class TeamCreditsDialog extends StatefulWidget {
  const TeamCreditsDialog({super.key});

  @override
  State<TeamCreditsDialog> createState() => _TeamCreditsDialogState();
}

class _TeamCreditsDialogState extends State<TeamCreditsDialog> {
  final _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final languageService = context.watch<LanguageService>();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 320, // Explicit width for consistent centering
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.9),
                    blurRadius: 40,
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const StudioMark(forceInvert: true, height: 40),
                  const SizedBox(height: 48),
                  // Credits content
                  _buildCreditItem(
                    languageService.translate('project_lead'),
                    'Vedad Keskin',
                    const Color(0xFFFFAB40),
                  ),
                  const SizedBox(height: 48),
                  // Close Button
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      languageService.translate('close'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                        fontFamily: 'serif',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<PackageInfo>(
                    future: _packageInfo,
                    builder: (context, snapshot) {
                      final info = snapshot.data;
                      if (info == null) return const SizedBox.shrink();
                      return Text(
                        'v ${info.version}',
                        key: const ValueKey('app-version'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Corner Decorative Suits
            Positioned(
              top: -12,
              left: -12,
              child: _buildCornerSuit('♥', const Color(0xFFFF4D4D), -0.2),
            ),
            Positioned(
              top: -12,
              right: -12,
              child: _buildCornerSuit('♦', const Color(0xFFFF4D4D), 0.2),
            ),
            Positioned(
              bottom: -12,
              left: -12,
              child: _buildCornerSuit('♣', Colors.white, -0.2),
            ),
            Positioned(
              bottom: -12,
              right: -12,
              child: _buildCornerSuit('♠', Colors.white, 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditItem(String role, String name, Color accentColor) {
    return Column(
      children: [
        Text(
          role,
          style: TextStyle(
            color: accentColor.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildCornerSuit(String char, Color color, double rotation) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            char,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: color.withValues(alpha: 0.5), blurRadius: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
