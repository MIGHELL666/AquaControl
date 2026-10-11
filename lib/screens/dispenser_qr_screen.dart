import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';

/// Screen that shows the generated QR code for a dispenser and allows printing.
class DispenserQrScreen extends StatelessWidget {
  final String dispenserId;
  final String brand;
  final String serialNumber;
  final String qrToken;

  const DispenserQrScreen({
    super.key,
    required this.dispenserId,
    required this.brand,
    required this.serialNumber,
    required this.qrToken,
  });

  /// The QR code payload that the worker's scanner will read
  String get qrData => 'AQUA-DISP-ID:$qrToken';

  Future<void> _printQr(BuildContext context) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          7.0 * PdfPageFormat.cm,
          10.0 * PdfPageFormat.cm,
          marginAll: 0.5 * PdfPageFormat.cm,
        ),
        build: (pw.Context ctx) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                // Title
                pw.Text(
                  'AQUA CONTROL',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Divider(thickness: 0.8),
                pw.SizedBox(height: 8),

                // QR Code
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: qrData,
                  width: 4.5 * PdfPageFormat.cm,
                  height: 4.5 * PdfPageFormat.cm,
                ),
                pw.SizedBox(height: 10),

                // Dispenser info
                pw.Text(
                  'Despachador $dispenserId',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Marca: $brand',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Serie: $serialNumber',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 0.5),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Escanea con la app para abastecer',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'QR_Despachador_$dispenserId',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaBackground(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: AquaColors.turquoise,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Código QR del Despachador',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AquaColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 8.0,
                ),
                child: Column(
                  children: [
                    // Success badge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        color: AquaColors.statusSuppliedBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AquaColors.statusSuppliedBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AquaColors.statusSupplied,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '¡Despachador $dispenserId registrado!\nSe generó su código QR exclusivo.',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AquaColors.statusSupplied,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // QR Card
                    GlassCard(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Dispenser icon + id
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AquaColors.turquoise.withValues(
                                alpha: 0.12,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AquaColors.turquoise.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.water_drop_rounded,
                              color: AquaColors.turquoise,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Despachador $dispenserId',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AquaColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$brand · $serialNumber',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AquaColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // QR Code image
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AquaColors.platinum,
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AquaColors.shadowCard,
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: QrImageView(
                              data: qrData,
                              version: QrVersions.auto,
                              size: 200,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: AquaColors.turquoise,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Color(0xFF1A3C5E),
                              ),
                              embeddedImage: null,
                              gapless: true,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // QR payload label
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AquaColors.iceBlue.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AquaColors.turquoise.withValues(
                                  alpha: 0.25,
                                ),
                              ),
                            ),
                            child: Text(
                              qrData,
                              style: GoogleFonts.sourceCodePro(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AquaColors.turquoise,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AquaColors.glacier.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AquaColors.platinum),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: AquaColors.turquoise,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Imprime este código QR y pégalo en el despachador. El trabajador lo escaneará desde la app para registrar el abastecimiento.',
                              style: GoogleFonts.montserrat(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: AquaColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Print button
                    AquaButton(
                      text: 'Imprimir código QR',
                      icon: Icons.print_rounded,
                      onPressed: () => _printQr(context),
                    ),
                    const SizedBox(height: 12),
                    AquaButton(
                      text: 'Finalizar',
                      type: AquaButtonType.secondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
