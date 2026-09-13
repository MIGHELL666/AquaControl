import 'package:flutter/material.dart';
import '../theme/aqua_colors.dart';

class WaterDispenserArt extends StatelessWidget {
  final double width;
  final double height;

  const WaterDispenserArt({
    super.key,
    this.width = 110,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _DispenserPainter(),
      ),
    );
  }
}

class _DispenserPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Glowing aura behind dispenser
    final auraPaint = Paint()
      ..color = AquaColors.cornflowerBlue.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h / 2),
        width: w * 0.9,
        height: h * 0.9,
      ),
      auraPaint,
    );

    // Dispenser main body
    final bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.08, w * 0.56, h * 0.84),
      const Radius.circular(16),
    );

    final bodyGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFD3E0F8),
        const Color(0xFF9AB2E8),
        const Color(0xFF5E7DC9),
        const Color(0xFF38529B),
      ],
      stops: const [0.0, 0.35, 0.7, 1.0],
    ).createShader(bodyRRect.outerRect);

    final bodyPaint = Paint()..shader = bodyGradient;
    canvas.drawRRect(bodyRRect, bodyPaint);

    // Body border highlight
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.4);
    canvas.drawRRect(bodyRRect, borderPaint);

    // Top bottle collar / crown
    final topRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.32, h * 0.02, w * 0.36, h * 0.08),
      const Radius.circular(6),
    );
    final topPaint = Paint()..color = const Color(0xFFE2ECFF);
    canvas.drawRRect(topRRect, topPaint);

    // Dispenser dispensing alcove (darker inset)
    final alcoveRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.30, h * 0.32, w * 0.40, h * 0.36),
      const Radius.circular(10),
    );
    final alcovePaint = Paint()..color = const Color(0xFF091438);
    canvas.drawRRect(alcoveRRect, alcovePaint);

    // Spouts (cold and hot water)
    final spoutPaintBlue = Paint()..color = const Color(0xFF4FA0FF);
    final spoutPaintRed = Paint()..color = const Color(0xFFFF5277);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.38, h * 0.36, w * 0.08, h * 0.12),
        const Radius.circular(3),
      ),
      spoutPaintBlue,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.54, h * 0.36, w * 0.08, h * 0.12),
        const Radius.circular(3),
      ),
      spoutPaintRed,
    );

    // Water drops / drip tray
    final trayPaint = Paint()..color = const Color(0xFF2A3D73);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.32, h * 0.63, w * 0.36, h * 0.04),
        const Radius.circular(2),
      ),
      trayPaint,
    );

    // Sleek logo icon on upper front
    final starPaint = Paint()..color = const Color(0xFF0C1945).withValues(alpha: 0.6);
    canvas.drawCircle(Offset(w * 0.5, h * 0.20), w * 0.045, starPaint);

    // Glass sheen / reflection highlight
    final sheenPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.26, h * 0.14),
      Offset(w * 0.26, h * 0.82),
      sheenPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
