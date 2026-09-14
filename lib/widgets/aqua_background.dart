import 'package:flutter/material.dart';
import '../theme/aqua_colors.dart';

/// Fondo principal de AquaControl.
/// Gradiente Ice Blue → Glacier con capas orgánicas de agua translúcidas.
class AquaBackground extends StatelessWidget {
  final Widget child;
  final bool showLightWaves;
  final bool useSafeArea;

  const AquaBackground({
    super.key,
    required this.child,
    this.showLightWaves = true,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = useSafeArea ? SafeArea(child: child) : child;

    return Stack(
      children: [
        // Base gradient: Ice Blue → Glacier
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AquaColors.iceBlue,
                Color(0xFFCCE5EF),
                AquaColors.glacier,
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),

        // Organic water blobs / atmospheric overlays
        if (showLightWaves)
          Positioned.fill(
            child: CustomPaint(
              painter: _WaterAtmospherePainter(),
            ),
          ),

        // Content layer
        content,
      ],
    );
  }
}

class _WaterAtmospherePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Large top-left Turquoise orb — provides depth
    final orb1 = Paint()
      ..color = const Color(0xFF447F98).withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.10),
      size.width * 0.65,
      orb1,
    );

    // Center-right Glacier orb — water feel
    final orb2 = Paint()
      ..color = const Color(0xFF629BB5).withValues(alpha: 0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 65);
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.42),
      size.width * 0.55,
      orb2,
    );

    // Bottom-left soft Ice Blue orb
    final orb3 = Paint()
      ..color = const Color(0xFFB9D8E1).withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 55);
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.82),
      size.width * 0.45,
      orb3,
    );

    // Subtle wave line 1 — organic water accent
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          const Color(0xFF629BB5).withValues(alpha: 0.16),
          const Color(0xFF447F98).withValues(alpha: 0.22),
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.72, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final wave1 = Path();
    wave1.moveTo(-size.width * 0.1, size.height * 0.60);
    wave1.cubicTo(
      size.width * 0.28, size.height * 0.47,
      size.width * 0.65, size.height * 0.73,
      size.width * 1.1, size.height * 0.58,
    );
    canvas.drawPath(wave1, wavePaint);

    // Subtle wave line 2
    final wave2 = Path();
    wave2.moveTo(-size.width * 0.05, size.height * 0.70);
    wave2.cubicTo(
      size.width * 0.30, size.height * 0.57,
      size.width * 0.68, size.height * 0.83,
      size.width * 1.05, size.height * 0.67,
    );

    final wavePaint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          const Color(0xFF447F98).withValues(alpha: 0.10),
          const Color(0xFF629BB5).withValues(alpha: 0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.30, 0.70, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(wave2, wavePaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
