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

    // Aura suave turquoise detrás del despachador
    final auraPaint = Paint()
      ..color = AquaColors.turquoise.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h / 2),
        width: w * 0.9,
        height: h * 0.9,
      ),
      auraPaint,
    );

    // Cuerpo principal del despachador — gradiente turquoise/glacier
    final bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.08, w * 0.56, h * 0.84),
      const Radius.circular(16),
    );

    final bodyGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AquaColors.iceBlue,
        AquaColors.glacier,
        AquaColors.slateBlue,
        AquaColors.turquoise,
      ],
      stops: const [0.0, 0.35, 0.7, 1.0],
    ).createShader(bodyRRect.outerRect);

    final bodyPaint = Paint()..shader = bodyGradient;
    canvas.drawRRect(bodyRRect, bodyPaint);

    // Borde glass del cuerpo
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.55);
    canvas.drawRRect(bodyRRect, borderPaint);

    // Corona / collarín superior del garrafón
    final topRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.32, h * 0.02, w * 0.36, h * 0.08),
      const Radius.circular(6),
    );
    final topPaint = Paint()
      ..color = AquaColors.iceBlue;
    canvas.drawRRect(topRRect, topPaint);
    canvas.drawRRect(
      topRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = AquaColors.platinum.withValues(alpha: 0.7),
    );

    // Hueco interior / nicho de despacho
    final alcoveRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.30, h * 0.32, w * 0.40, h * 0.36),
      const Radius.circular(10),
    );
    final alcovePaint = Paint()
      ..color = AquaColors.textPrimary.withValues(alpha: 0.75);
    canvas.drawRRect(alcoveRRect, alcovePaint);

    // Grifo frío — turquoise
    final spoutPaintBlue = Paint()..color = AquaColors.slateBlue;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.38, h * 0.36, w * 0.08, h * 0.12),
        const Radius.circular(3),
      ),
      spoutPaintBlue,
    );

    // Grifo caliente — coral suave
    final spoutPaintRed = Paint()..color = AquaColors.statusError;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.54, h * 0.36, w * 0.08, h * 0.12),
        const Radius.circular(3),
      ),
      spoutPaintRed,
    );

    // Bandeja de goteo — platinum
    final trayPaint = Paint()..color = AquaColors.platinum;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.32, h * 0.63, w * 0.36, h * 0.04),
        const Radius.circular(2),
      ),
      trayPaint,
    );

    // Punto de logo/detalle en la parte superior frontal
    final dotPaint = Paint()
      ..color = AquaColors.turquoise.withValues(alpha: 0.55);
    canvas.drawCircle(Offset(w * 0.5, h * 0.20), w * 0.045, dotPaint);

    // Reflejo/sheen vidrio — destello lateral
    final sheenPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
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
