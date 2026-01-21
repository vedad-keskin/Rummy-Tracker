import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rummy_tracker/offline_db/language_service.dart';
import 'dart:ui';

class RulesDialog extends StatelessWidget {
  const RulesDialog({super.key});

  List<String> _getPages(String content) {
    // Split by numbered sections: "1. ", "2. ", etc.
    final sections = content.trim().split(RegExp(r'\n\n(?=\d+\.)'));
    return sections.where((s) => s.trim().isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final languageService = context.watch<LanguageService>();
    final title = languageService.translate('rules_title');
    final rawContent = languageService.translate('rules_content');
    final pages = _getPages(rawContent);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: _RulesDialogContent(
        title: title,
        pages: pages,
        languageService: languageService,
      ),
    );
  }
}

class _RulesDialogContent extends StatefulWidget {
  final String title;
  final List<String> pages;
  final LanguageService languageService;

  const _RulesDialogContent({
    required this.title,
    required this.pages,
    required this.languageService,
  });

  @override
  State<_RulesDialogContent> createState() => _RulesDialogContentState();
}

class _RulesDialogContentState extends State<_RulesDialogContent> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Glass Background with Blur
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1B263B).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Main Content
        LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = constraints.maxHeight - 16; // Account for padding
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: maxHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.book_outlined,
                            color: Color(0xFF30E8BF),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.title.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                fontFamily: 'serif',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content Area
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: 450,
                          minHeight: 250,
                        ),
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() => _currentPage = index);
                            },
                            itemCount: widget.pages.length,
                            itemBuilder: (context, index) {
                              return _buildPageContent(widget.pages[index]);
                            },
                          ),
                        ),
                      ),
                    ),

                    // Page Indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '${_currentPage + 1} / ${widget.pages.length}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Navigation Footer
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      child: Row(
                        children: [
                          if (_currentPage > 0)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutCubic,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.2),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  widget.languageService.translate('back'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    fontFamily: 'serif',
                                  ),
                                ),
                              ),
                            )
                          else
                            const Spacer(),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _currentPage < widget.pages.length - 1
                                  ? () {
                                      _pageController.nextPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeOutCubic,
                                      );
                                    }
                                  : () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF30E8BF),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                              child: Text(
                                _currentPage < widget.pages.length - 1
                                    ? widget.languageService.translate('next')
                                    : widget.languageService.translate('close'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  fontFamily: 'serif',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Close Button (X) - Top Right
        Positioned(
          top: 20,
          right: 20,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white70,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageContent(String content) {
    final lines = content.trim().split('\n');
    if (lines.isEmpty) return const SizedBox();

    final header = lines[0];
    final bodyLines = lines.length > 1 ? lines.sublist(1) : <String>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Text(
            header,
            style: const TextStyle(
              color: Color(0xFF30E8BF),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 20),

          // Section Body
          for (var line in bodyLines)
            if (line.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (line.trim().startsWith('-'))
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 12.0),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF30E8BF),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        line.trim().startsWith('-')
                            ? line.trim().substring(1).trim()
                            : line.trim(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 15,
                          height: 1.6,
                          fontFamily: 'serif',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
