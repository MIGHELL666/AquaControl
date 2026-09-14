import 'package:flutter/material.dart';
import '../theme/aqua_colors.dart';

/// Estrella AquaControl — Logo corporativo en paleta turquoise/slateBlue.
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
          color: color ?? AquaColors.turquoise,
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

    // Glow suave
    if (hasGlow) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.25)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.28);
      canvas.drawCircle(center, size.width * 0.30, glowPaint);
    }

    // Forma de estrella de 4 puntas con curvas suaves
    final path = Path();
    path.moveTo(center.dx, 0);
    path.quadraticBezierTo(
        center.dx + w * 0.12, center.dy - h * 0.12, w, center.dy);
    path.quadraticBezierTo(
        center.dx + w * 0.12, center.dy + h * 0.12, center.dx, h);
    path.quadraticBezierTo(
        center.dx - w * 0.12, center.dy + h * 0.12, 0, center.dy);
    path.quadraticBezierTo(
        center.dx - w * 0.12, center.dy - h * 0.12, center.dx, 0);
    path.close();

    final starPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AquaColors.glacier,
          color,
          AquaColors.slateBlue,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, starPaint);
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.hasGlow != hasGlow;
}
