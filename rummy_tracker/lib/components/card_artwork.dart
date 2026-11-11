import 'dart:math' as math;

import 'package:flutter/material.dart';

class LightTrailPainter extends CustomPainter {
  const LightTrailPainter({
    required this.progress,
    required this.radius,
    required this.opacity,
    this.frame = false,
  });
  final double progress;
  final double radius;
  final double opacity;
  final bool frame;

  @override
  void paint(Canvas canvas, Size size) {
    if (frame) {
      _paintFrame(canvas, size);
      return;
    }
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final angle = progress * math.pi * 1.7 - math.pi / 2;
    for (final (offset, color) in [
      (0.0, const Color(0xFF30E8BF)),
      (math.pi, const Color(0xFFFFC84A)),
    ]) {
      final paint = Paint()
        ..color = color.withValues(alpha: opacity * 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      canvas.drawArc(rect, angle + offset, 1.05, false, paint);
      paint
        ..maskFilter = null
        ..strokeWidth = 1.7
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: opacity * 0.85);
      canvas.drawArc(rect, angle + offset, 1.05, false, paint);
      canvas.drawCircle(
        center +
            Offset(
                  math.cos(angle + offset + 1.05),
                  math.sin(angle + offset + 1.05),
                ) *
                radius,
        2.7,
        paint..style = PaintingStyle.fill,
      );
    }
  }

  void _paintFrame(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: radius * 2,
      height: size.height - 8,
    );
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(32)));
    final metric = path.computeMetrics().first;
    for (final (offset, color) in [
      (0.0, const Color(0xFF30E8BF)),
      (0.5, const Color(0xFFFFC84A)),
    ]) {
      final start = ((progress * 0.85 + offset) % 1) * metric.length;
      final end = start + metric.length * 0.16;
      final trail = metric.extractPath(start, math.min(end, metric.length));
      if (end > metric.length) {
        trail.addPath(metric.extractPath(0, end - metric.length), Offset.zero);
      }
      final paint = Paint()
        ..color = color.withValues(alpha: opacity * 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      canvas.drawPath(trail, paint);
      paint
        ..maskFilter = null
        ..strokeWidth = 1.7
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: opacity * 0.85);
      canvas.drawPath(trail, paint);
      canvas.drawCircle(
        metric.getTangentForOffset(end % metric.length)!.position,
        2.7,
        paint..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(LightTrailPainter oldDelegate) =>
      frame != oldDelegate.frame ||
      progress != oldDelegate.progress ||
      radius != oldDelegate.radius ||
      opacity != oldDelegate.opacity;
}

class AcePainter extends CustomPainter {
  const AcePainter(this.suit);
  final int suit;

  @override
  void paint(Canvas canvas, Size size) {
    final face = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.width * 0.13),
    );
    canvas.drawShadow(
      Path()..addRRect(face),
      Colors.black.withValues(alpha: 0.55),
      8,
      true,
    );
    canvas.drawRRect(face, Paint()..color = const Color(0xFFFFF5DE));
    canvas.drawRRect(
      face.deflate(0.75),
      Paint()
        ..color = const Color(0xFFE3C984)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final color = suit == 0 || suit == 3
        ? const Color(0xFFEC315D)
        : const Color(0xFF142747);
    final rank = TextPainter(
      text: TextSpan(
        text: 'A',
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.25,
          fontFamily: 'serif',
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    rank.paint(canvas, Offset(size.width * 0.13, size.height * 0.055));
    canvas.save();
    canvas.translate(size.width, size.height);
    canvas.rotate(math.pi);
    rank.paint(canvas, Offset(size.width * 0.13, size.height * 0.055));
    canvas.restore();
    _paintSuit(
      canvas,
      Offset(size.width / 2, size.height / 2),
      size.width * 0.56,
      color,
    );
  }

  void _paintSuit(Canvas canvas, Offset center, double size, Color color) {
    canvas.save();
    canvas.translate(center.dx - size / 2, center.dy - size / 2);
    canvas.scale(size);
    final paint = Paint()..color = color;
    final path = Path();
    if (suit == 0) {
      path.moveTo(0.5, 0.95);
      path.cubicTo(0.42, 0.82, 0.05, 0.60, 0.05, 0.33);
      path.cubicTo(0.05, 0.05, 0.38, 0, 0.5, 0.25);
      path.cubicTo(0.62, 0, 0.95, 0.05, 0.95, 0.33);
      path.cubicTo(0.95, 0.60, 0.58, 0.82, 0.5, 0.95);
      path.close();
    } else if (suit == 3) {
      path.moveTo(0.5, 0.02);
      path.lineTo(0.95, 0.5);
      path.lineTo(0.5, 0.98);
      path.lineTo(0.05, 0.5);
      path.close();
    } else {
      if (suit == 1) {
        path.moveTo(0.5, 0.02);
        path.cubicTo(0.4, 0.2, 0.05, 0.43, 0.05, 0.65);
        path.cubicTo(0.05, 0.91, 0.38, 0.97, 0.5, 0.75);
        path.cubicTo(0.62, 0.97, 0.95, 0.91, 0.95, 0.65);
        path.cubicTo(0.95, 0.43, 0.6, 0.2, 0.5, 0.02);
        path.close();
      } else {
        for (final point in [
          const Offset(0.5, 0.26),
          const Offset(0.26, 0.57),
          const Offset(0.74, 0.57),
        ]) {
          path.addOval(Rect.fromCircle(center: point, radius: 0.24));
        }
      }
      canvas.drawPath(
        Path()
          ..moveTo(0.46, 0.6)
          ..quadraticBezierTo(0.45, 0.9, 0.3, 0.98)
          ..lineTo(0.7, 0.98)
          ..quadraticBezierTo(0.55, 0.9, 0.54, 0.6)
          ..close(),
        paint,
      );
    }
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(AcePainter oldDelegate) => suit != oldDelegate.suit;
}
