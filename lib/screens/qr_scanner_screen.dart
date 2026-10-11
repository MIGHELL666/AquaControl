import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/zone_data.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import 'dispenser_detail_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  MobileScannerController? _cameraController;
  bool _flashlightOn = false;
  bool _hasScanned = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _initCamera();
  }

  void _initCamera() {
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue == null || rawValue.isEmpty) continue;

      setState(() => _hasScanned = true);
      _processQrCode(rawValue);
      break;
    }
  }

  void _processQrCode(String rawValue) {
    // Expected QR format: "AQUA-DISP-#001" or just the dispenser id "#001"
    String dispenserId;
    String? qrToken;
    if (rawValue.startsWith('AQUA-DISP-ID:')) {
      qrToken = rawValue.substring('AQUA-DISP-ID:'.length);
      dispenserId = '';
    } else if (rawValue.startsWith('AQUA-DISP-')) {
      dispenserId = rawValue.replaceFirst('AQUA-DISP-', '');
    } else if (rawValue.startsWith('#')) {
      dispenserId = rawValue;
    } else {
      // Try to find any dispenser with matching data
      dispenserId = rawValue;
    }

    // Look up the dispenser in the zones
    DispenserItem? foundDispenser;
    String? foundZoneName;
    for (final zone in kDefaultZones) {
      for (final d in zone.dispensers) {
        if ((qrToken != null &&
                (d.qrToken == qrToken || d.id.trim() == qrToken)) ||
            (qrToken == null && d.id.trim() == dispenserId.trim()) ||
            d.serialNumber.trim() == rawValue.trim()) {
          foundDispenser = d;
          foundZoneName = zone.name;
          break;
        }
      }
      if (foundDispenser != null) break;
    }

    if (foundDispenser != null) {
      final activeClient = WorkerSession.activeClient;
      final assignedClient = getClientForDispenser(foundDispenser.id);
      String? rejectionMessage;
      if (activeClient != null &&
          assignedClient != null &&
          assignedClient.id != activeClient.id) {
        rejectionMessage =
            'Este despachador está asignado a ${assignedClient.companyName}, no a ${activeClient.companyName}.';
      } else if (activeClient != null &&
          activeClient.hasQrScanning &&
          activeClient.zoneNames.isNotEmpty &&
          !activeClient.zoneNames.any(
            (name) =>
                name.trim().toLowerCase() ==
                foundZoneName?.trim().toLowerCase(),
          )) {
        rejectionMessage =
            'La zona ${foundZoneName ?? 'del despachador'} no está habilitada para ${activeClient.companyName}.';
      }

      if (rejectionMessage != null) {
        setState(() {
          _hasScanned = false;
          _errorMessage = rejectionMessage;
        });
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _errorMessage = null);
        });
        return;
      }

      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (_) => DispenserDetailScreen(
                dispenserId: foundDispenser!.id,
                brand: foundDispenser.brand,
                serialNumber: foundDispenser.serialNumber,
                isSupplied: foundDispenser.isSupplied,
                isActive: foundDispenser.isActive,
              ),
            ),
          )
          .then((_) {
            if (mounted) {
              setState(() => _hasScanned = false);
            }
          });
    } else {
      // Show not-found message and allow rescan
      setState(() {
        _errorMessage = qrToken != null
            ? 'Código QR no registrado'
            : 'Despachador "$dispenserId" no encontrado';
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _hasScanned = false;
            _errorMessage = null;
          });
        }
      });
    }
  }

  void _toggleFlashlight() {
    _cameraController?.toggleTorch();
    setState(() {
      _flashlightOn = !_flashlightOn;
    });
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
              const SizedBox(height: 16),

              // Camera Viewfinder with Scanner
              Expanded(
                flex: 5,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Camera preview
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: _cameraController != null
                              ? MobileScanner(
                                  controller: _cameraController!,
                                  onDetect: _onDetect,
                                  errorBuilder: (context, error, child) {
                                    final message =
                                        error.errorCode ==
                                            MobileScannerErrorCode
                                                .permissionDenied
                                        ? 'Permite el acceso a la cámara en los ajustes del dispositivo para escanear QR.'
                                        : error.errorDetails?.message ??
                                              'No se pudo iniciar la cámara.';
                                    return _buildCameraFallback(message);
                                  },
                                )
                              : _buildCameraFallback('Iniciando cámara...'),
                        ),

                        // Viewfinder overlay
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: CustomPaint(
                            painter: _ScannerCornersPainter(
                              color: AquaColors.turquoise,
                            ),
                          ),
                        ),

                        // Scanning line animation
                        AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            return Positioned(
                              top: 20 + (_animController.value * 240),
                              child: Container(
                                width: 240,
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AquaColors.turquoise.withValues(
                                        alpha: 0.9,
                                      ),
                                      Colors.white,
                                      AquaColors.turquoise.withValues(
                                        alpha: 0.9,
                                      ),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AquaColors.turquoise.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // "Scanning..." indicator when active
                        if (_hasScanned && _errorMessage == null)
                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              color: AquaColors.turquoise.withValues(
                                alpha: 0.3,
                              ),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Error or instruction text
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AquaColors.statusPendingBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AquaColors.statusPendingBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: AquaColors.statusPending,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AquaColors.statusPending,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
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

              const Spacer(flex: 2),

              // Flashlight toggle pill button
              InkWell(
                onTap: _toggleFlashlight,
                borderRadius: BorderRadius.circular(24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _flashlightOn
                        ? AquaColors.turquoise
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _flashlightOn
                          ? AquaColors.turquoise
                          : AquaColors.platinum,
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
                        _flashlightOn
                            ? Icons.flashlight_on_rounded
                            : Icons.flashlight_off_rounded,
                        size: 18,
                        color: _flashlightOn
                            ? Colors.white
                            : AquaColors.turquoise,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _flashlightOn
                            ? 'Desactivar linterna'
                            : 'Activar linterna',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _flashlightOn
                              ? Colors.white
                              : AquaColors.textPrimary,
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

  Widget _buildCameraFallback(String message) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_rounded,
            size: 48,
            color: AquaColors.turquoise.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ),
        ],
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
      ..arcToPoint(
        const Offset(radius, 0),
        radius: const Radius.circular(radius),
      )
      ..lineTo(cornerLength, 0);
    canvas.drawPath(tl, paint);

    // Top-Right corner
    final tr = Path()
      ..moveTo(size.width - cornerLength, 0)
      ..lineTo(size.width - radius, 0)
      ..arcToPoint(
        Offset(size.width, radius),
        radius: const Radius.circular(radius),
      )
      ..lineTo(size.width, cornerLength);
    canvas.drawPath(tr, paint);

    // Bottom-Left corner
    final bl = Path()
      ..moveTo(0, size.height - cornerLength)
      ..lineTo(0, size.height - radius)
      ..arcToPoint(
        Offset(radius, size.height),
        radius: const Radius.circular(radius),
      )
      ..lineTo(cornerLength, size.height);
    canvas.drawPath(bl, paint);

    // Bottom-Right corner
    final br = Path()
      ..moveTo(size.width - cornerLength, size.height)
      ..lineTo(size.width - radius, size.height)
      ..arcToPoint(
        Offset(size.width, size.height - radius),
        radius: const Radius.circular(radius),
      )
      ..lineTo(size.width, size.height - cornerLength);
    canvas.drawPath(br, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
