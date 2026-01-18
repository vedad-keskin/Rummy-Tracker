import 'package:flutter/material.dart';

class TeamCreditsDialog extends StatelessWidget {
  const TeamCreditsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
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
            // Title section matching main layout style
            Column(
              children: [
                Text(
                  'RUMMY',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 6,
                    fontFamily: 'serif',
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                Text(
                  'TRACKER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            // Credits content
            _buildCreditItem(
              'PROJECT LEAD',
              'Vedad Keskin',
              const Color(0xFFFFAB40), // Matching the Players screen icon color
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
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: const Text(
                'CLOSE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                  fontFamily: 'serif',
                ),
              ),
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
            color: accentColor.withOpacity(0.8),
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
}
