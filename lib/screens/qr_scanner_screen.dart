import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';
import 'dispenser_detail_screen.dart';
import 'role_selection_screen.dart';

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

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(22),
            backgroundColor: const Color(0xFF132247),
            borderColor: AquaColors.glassBorderSubtle,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF869DFF).withValues(alpha: 0.15),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AquaColors.icyBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cerrar sesión',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '¿Estás seguro de que deseas salir de tu sesión de trabajador?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: AquaColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: AquaButton(
                        text: 'Cancelar',
                        type: AquaButtonType.secondary,
                        height: 46,
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AquaButton(
                        text: 'Salir',
                        type: AquaButtonType.danger,
                        height: 46,
                        onPressed: () {
                          Navigator.of(dialogCtx).pop();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const RoleSelectionScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
              // Header without back arrow + with Logout Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Escanear QR',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0x283D518C),
                      shape: BoxShape.circle,
                      border: Border.all(color: AquaColors.glassBorderSubtle),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.logout_rounded,
                        size: 19,
                        color: AquaColors.icyBlue,
                      ),
                      tooltip: 'Cerrar sesión',
                      onPressed: () => _confirmLogout(context),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),

              // QR Scanner Viewfinder Frame
              GestureDetector(
                onTap: _onDetectQr,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow backdrop
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          color: const Color(0x1A25428E),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AquaColors.cornflowerBlue.withValues(alpha: 0.25),
                              blurRadius: 36,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),

                      // Corner brackets painter
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: CustomPaint(
                          painter: _ScannerCornersPainter(color: AquaColors.cornflowerBlue),
                        ),
                      ),

                      // Center QR Icon
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 72,
                            color: AquaColors.icyBlue.withValues(alpha: 0.9),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0x401E347A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Toca para escanear',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: AquaColors.icyBlue,
                                fontWeight: FontWeight.w500,
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
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AquaColors.cornflowerBlue.withValues(alpha: 0.9),
                                    Colors.white,
                                    AquaColors.cornflowerBlue.withValues(alpha: 0.9),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AquaColors.cornflowerBlue.withValues(alpha: 0.8),
                                    blurRadius: 10,
                                    spreadRadius: 2,
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
                  fontWeight: FontWeight.w400,
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  decoration: BoxDecoration(
                    color: _flashlightOn ? const Color(0x55486DCF) : const Color(0x283D518C),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _flashlightOn ? AquaColors.icyBlue : AquaColors.glassBorderSubtle,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _flashlightOn ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
                        size: 18,
                        color: _flashlightOn ? Colors.white : AquaColors.icyBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _flashlightOn ? 'Desactivar linterna' : 'Activar linterna',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
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
