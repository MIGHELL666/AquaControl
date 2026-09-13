import 'package:flutter/material.dart';
import '../theme/aqua_colors.dart';

class AquaStar extends StatelessWidget {
  final double size;
  final Color? color;
  final bool hasGlow;

  const AquaStar({
    super.key,
    this.size = 48,
    this.color,
    this.hasGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StarPainter(
          color: color ?? AquaColors.icyBlue,
          hasGlow: hasGlow,
        ),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final Color color;
  final bool hasGlow;

  _StarPainter({required this.color, required this.hasGlow});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final w = size.width;
    final h = size.height;

    if (hasGlow) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.25);
      canvas.drawCircle(center, size.width * 0.28, glowPaint);
    }

    // Path for 4-point curved sparkle star
    final path = Path();
    // Top tip
    path.moveTo(center.dx, 0);
    // Curve to right tip
    path.quadraticBezierTo(center.dx + w * 0.12, center.dy - h * 0.12, w, center.dy);
    // Curve to bottom tip
    path.quadraticBezierTo(center.dx + w * 0.12, center.dy + h * 0.12, center.dx, h);
    // Curve to left tip
    path.quadraticBezierTo(center.dx - w * 0.12, center.dy + h * 0.12, 0, center.dy);
    // Curve back to top tip
    path.quadraticBezierTo(center.dx - w * 0.12, center.dy - h * 0.12, center.dx, 0);
    path.close();

    final starPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          color,
          color.withValues(alpha: 0.8),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, starPaint);
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.hasGlow != hasGlow;
}
