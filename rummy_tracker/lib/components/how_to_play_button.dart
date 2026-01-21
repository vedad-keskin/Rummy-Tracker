import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rummy_tracker/offline_db/language_service.dart';

class HowToPlayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const HowToPlayButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final languageService = context.watch<LanguageService>();
    
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.help_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              languageService.translate('how_to_play'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'serif',
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
