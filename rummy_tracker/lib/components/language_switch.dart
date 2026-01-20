import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rummy_tracker/offline_db/language_service.dart';

class LanguageSwitch extends StatefulWidget {
  const LanguageSwitch({super.key});

  @override
  State<LanguageSwitch> createState() => _LanguageSwitchState();
}

class _LanguageSwitchState extends State<LanguageSwitch> {
  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final isEn = languageService.currentLanguage == 'en';

    return GestureDetector(
      onTap: () {
        languageService.setLanguage(isEn ? 'bs' : 'en');
      },
      child: Container(
        width: 90,
        height: 44,
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
        padding: const EdgeInsets.all(4),
        child: Stack(
          children: [
            // Sliding Highlight
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: isEn ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: 40,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF30E8BF).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF30E8BF).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
            ),
            // Flags
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isEn ? 1.0 : 0.4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          'assets/images/uk.png',
                          width: 26,
                          height: 18,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: !isEn ? 1.0 : 0.4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          'assets/images/bih.png',
                          width: 26,
                          height: 18,
                          fit: BoxFit.cover,
                        ),
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
}
