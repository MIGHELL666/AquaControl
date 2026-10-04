import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import 'dispenser_detail_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _flashlightOn = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onDetectQr() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const DispenserDetailScreen(dispenserId: '#023'),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            children: [
              // Header
              Text(
                'Escanear QR',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AquaColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(flex: 2),

              // QR Scanner Viewfinder Frame
              GestureDetector(
                onTap: _onDetectQr,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Viewfinder translucent card
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AquaColors.platinum, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AquaColors.shadowCard,
                              blurRadius: 32,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),

                      // Corner brackets painter
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: CustomPaint(
                          painter: _ScannerCornersPainter(color: AquaColors.turquoise),
                        ),
                      ),

                      // Center QR Icon
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 72,
                            color: AquaColors.turquoise.withValues(alpha: 0.8),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AquaColors.turquoise.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AquaColors.turquoise.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'Toca para escanear',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: AquaColors.turquoise,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Scanning line animation
                      AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          return Positioned(
                            top: 20 + (_animController.value * 210),
                            child: Container(
                              width: 210,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AquaColors.turquoise.withValues(alpha: 0.9),
                                    Colors.white,
                                    AquaColors.turquoise.withValues(alpha: 0.9),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AquaColors.turquoise.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Instruction caption
              Text(
                'Coloca el código QR del despachador\ndentro del marco',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AquaColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const Spacer(flex: 3),

              // Flashlight toggle pill button
              InkWell(
                onTap: () {
                  setState(() {
                    _flashlightOn = !_flashlightOn;
                  });
                },
                borderRadius: BorderRadius.circular(24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  decoration: BoxDecoration(
                    color: _flashlightOn ? AquaColors.turquoise : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _flashlightOn ? AquaColors.turquoise : AquaColors.platinum,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _flashlightOn
                            ? AquaColors.turquoise.withValues(alpha: 0.3)
                            : AquaColors.shadowCard,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _flashlightOn ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
                        size: 18,
                        color: _flashlightOn ? Colors.white : AquaColors.turquoise,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _flashlightOn ? 'Desactivar linterna' : 'Activar linterna',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _flashlightOn ? Colors.white : AquaColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerCornersPainter extends CustomPainter {
  final Color color;

  _ScannerCornersPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 36.0;
    const radius = 20.0;

    // Top-Left corner
    final tl = Path()
      ..moveTo(0, cornerLength)
      ..lineTo(0, radius)
      ..arcToPoint(const Offset(radius, 0), radius: const Radius.circular(radius))
      ..lineTo(cornerLength, 0);
    canvas.drawPath(tl, paint);

    // Top-Right corner
    final tr = Path()
      ..moveTo(size.width - cornerLength, 0)
      ..lineTo(size.width - radius, 0)
      ..arcToPoint(Offset(size.width, radius), radius: const Radius.circular(radius))
      ..lineTo(size.width, cornerLength);
    canvas.drawPath(tr, paint);

    // Bottom-Left corner
    final bl = Path()
      ..moveTo(0, size.height - cornerLength)
      ..lineTo(0, size.height - radius)
      ..arcToPoint(Offset(radius, size.height), radius: const Radius.circular(radius))
      ..lineTo(cornerLength, size.height);
    canvas.drawPath(bl, paint);

    // Bottom-Right corner
    final br = Path()
      ..moveTo(size.width - cornerLength, size.height)
      ..lineTo(size.width - radius, size.height)
      ..arcToPoint(Offset(size.width, size.height - radius), radius: const Radius.circular(radius))
      ..lineTo(size.width, size.height - cornerLength);
    canvas.drawPath(br, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
