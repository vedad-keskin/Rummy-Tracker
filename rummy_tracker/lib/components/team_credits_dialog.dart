import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:rummy_tracker/components/card_artwork.dart';
import 'package:rummy_tracker/components/studio_mark.dart';
import 'package:rummy_tracker/offline_db/language_service.dart';

class TeamCreditsDialog extends StatefulWidget {
  const TeamCreditsDialog({super.key});

  @override
  State<TeamCreditsDialog> createState() => _TeamCreditsDialogState();
}

class _TeamCreditsDialogState extends State<TeamCreditsDialog>
    with SingleTickerProviderStateMixin {
  final _packageInfo = PackageInfo.fromPlatform();
  late final AnimationController _controller;
  bool _started = false;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _controller.value = 1;
    } else if (!_started) {
      _controller.forward();
    }
    _started = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _phase(double start, double end) => Curves.easeOutCubic.transform(
    Interval(start, end).transform(_controller.value),
  );

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageService>();

    return Dialog.fullscreen(
      backgroundColor: const Color(0xFF101B2D),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.15),
            radius: 0.85,
            colors: [Color(0xFF173A48), Color(0xFF101B2D)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 460;
              final width = math.min(
                320.0,
                constraints.maxWidth - (compact ? 64 : 48),
              );
              final aceHeight = width * (compact ? 0.27 : 0.48);
              final fanHeight = compact ? 0.0 : aceHeight * 0.80 + 12;

              return Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        key: const ValueKey('credits-content'),
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 32 : 24,
                          vertical: compact ? 8 : 24,
                        ),
                        child: SizedBox(
                          width: width,
                          child: AnimatedBuilder(
                            animation: _controller,
                            child: _creatorCard(language, compact),
                            builder: (context, card) {
                              final reveal = _reduceMotion
                                  ? 1.0
                                  : _phase(0, 0.6);
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  if (!_reduceMotion)
                                    Positioned(
                                      left: -16,
                                      right: -16,
                                      top: -16,
                                      bottom: -16,
                                      child: IgnorePointer(
                                        child: ExcludeSemantics(
                                          child: CustomPaint(
                                            key: const ValueKey(
                                              'credits-light-trails',
                                            ),
                                            painter: LightTrailPainter(
                                              progress: _controller.value,
                                              radius: width / 2 + 12,
                                              opacity:
                                                  _phase(0.02, 0.2) *
                                                  (1 - _phase(0.76, 1)),
                                              frame: true,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  for (var index = 0; index < 4; index++)
                                    _ace(index, width, aceHeight, compact),
                                  Padding(
                                    padding: EdgeInsets.only(top: fanHeight),
                                    child: Opacity(
                                      opacity: 0.35 + 0.65 * reveal,
                                      child: Transform.translate(
                                        offset: Offset(0, 20 * (1 - reveal)),
                                        child: Transform.scale(
                                          scale: 0.94 + 0.06 * reveal,
                                          child: card,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF30E8BF),
                            backgroundColor: const Color(
                              0xFF30E8BF,
                            ).withValues(alpha: 0.08),
                            minimumSize: const Size(176, 48),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: const Color(
                                  0xFF30E8BF,
                                ).withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          child: Text(
                            language.translate('close'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              fontFamily: 'serif',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FutureBuilder<PackageInfo>(
                          future: _packageInfo,
                          builder: (context, snapshot) => Text(
                            snapshot.hasData
                                ? 'v ${snapshot.data!.version}'
                                : '',
                            key: const ValueKey('app-version'),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _creatorCard(LanguageService language, bool compact) {
    return Container(
      key: const ValueKey('creator-card'),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: compact ? 12 : 28,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5DE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE3C984), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: compact ? 48 : 68,
            child: Image.asset(
              StudioMark.asset,
              width: 224,
              fit: BoxFit.contain,
              semanticLabel: 'Nightfall Studio',
            ),
          ),
          SizedBox(height: compact ? 16 : 24),
          Container(width: 32, height: 2, color: const Color(0xFFE3C984)),
          const SizedBox(height: 20),
          Text(
            language.translate('project_lead'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF536075),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Vedad Keskin',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF142747),
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontFamily: 'serif',
            ),
          ),
        ],
      ),
    );
  }

  Widget _ace(int index, double width, double height, bool compact) {
    final arrival = _reduceMotion
        ? 1.0
        : _phase(0.04 + index * 0.08, 0.50 + index * 0.10);
    final cardWidth = height * 0.69;
    final spread = index - 1.5;
    final side = index < 2 ? -1.0 : 1.0;
    final end = compact
        ? Offset(
            side < 0 ? -cardWidth * 0.45 : width - cardWidth * 0.55,
            index.isEven ? 10 : height * 0.9,
          )
        : Offset(
            width / 2 + spread * cardWidth * 0.58 - cardWidth / 2,
            16 + spread.abs() * 7,
          );
    final start = Offset(side < 0 ? -width : width * 1.5, width * 1.2);
    final control = Offset(width / 2 + side * width * 0.8, -height * 0.6);
    final position =
        start * ((1 - arrival) * (1 - arrival)) +
        control * (2 * (1 - arrival) * arrival) +
        end * (arrival * arrival);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: Opacity(
            opacity: arrival,
            child: Transform.rotate(
              angle:
                  (compact
                      ? side * (index.isEven ? -0.18 : 0.18)
                      : spread * 0.24) +
                  side * 0.55 * (1 - arrival),
              child: SizedBox(
                key: ValueKey('credits-card-$index'),
                width: cardWidth,
                height: height,
                child: CustomPaint(painter: AcePainter(index)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
