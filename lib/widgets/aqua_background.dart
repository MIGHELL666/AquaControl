import 'package:flutter/material.dart';
import '../theme/aqua_colors.dart';

class AquaBackground extends StatelessWidget {
  final Widget child;
  final bool showLightWaves;

  const AquaBackground({
    super.key,
    required this.child,
    this.showLightWaves = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark navy gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0C1748),
                AquaColors.deepNavy,
                AquaColors.backgroundDark,
              ],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
        ),

        // Glowing luminous orbs and ethereal rays
        if (showLightWaves)
          Positioned.fill(
            child: CustomPaint(
              painter: _BackgroundLightPainter(),
            ),
          ),

        // Content
        SafeArea(
          child: child,
        ),
      ],
    );
  }
}

class _BackgroundLightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Upper blue glow orb
    final glowPaint1 = Paint()
      ..color = const Color(0xFF2243A6).withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.22), size.width * 0.5, glowPaint1);

    // Cyan / icy light beam in center
    final glowPaint2 = Paint()
      ..color = const Color(0xFF7692FF).withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.65), size.width * 0.4, glowPaint2);

    // Flowing water wave accent lines
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          AquaColors.icyBlue.withValues(alpha: 0.18),
          AquaColors.cornflowerBlue.withValues(alpha: 0.35),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final wavePath = Path();
    wavePath.moveTo(-size.width * 0.2, size.height * 0.68);
    wavePath.cubicTo(
      size.width * 0.3,
      size.height * 0.55,
      size.width * 0.6,
      size.height * 0.80,
      size.width * 1.2,
      size.height * 0.62,
    );
    canvas.drawPath(wavePath, wavePaint);

    final wavePath2 = Path();
    wavePath2.moveTo(-size.width * 0.1, size.height * 0.75);
    wavePath2.cubicTo(
      size.width * 0.35,
      size.height * 0.62,
      size.width * 0.7,
      size.height * 0.88,
      size.width * 1.15,
      size.height * 0.70,
    );
    canvas.drawPath(wavePath2, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
