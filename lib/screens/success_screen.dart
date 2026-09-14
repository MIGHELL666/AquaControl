import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/signature_pad.dart';
import 'worker_shell.dart';

class SuccessScreen extends StatelessWidget {
  final String dispenserId;
  final String pointName;
  final int bottleCount;
  final String userName;
  final String dateStr;
  final String timeStr;
  final String? recipientName;
  final bool isResupply;
  final List<Offset>? signaturePoints;

  const SuccessScreen({
    super.key,
    this.dispenserId = '#023',
    this.pointName = 'Producción',
    this.bottleCount = 2,
    this.userName = 'Juan Pérez',
    this.dateStr = '06/09/2026',
    this.timeStr = '14:37',
    this.recipientName,
    this.isResupply = false,
    this.signaturePoints,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // ── Círculo de éxito ─────────────────────────
              Stack(
                alignment: Alignment.center,
                children: [
                  // Glow exterior
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AquaColors.statusSupplied.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Círculo principal
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AquaColors.statusSupplied,
                          Color(0xFF2A9070),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AquaColors.statusSupplied.withValues(alpha: 0.35),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 46,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Título
              Text(
                isResupply
                    ? '¡Reabastecimiento\nregistrado!'
                    : '¡Abastecimiento\nregistrado!',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AquaColors.textPrimary,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'El comprobante ha sido guardado',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: AquaColors.textMuted,
                ),
              ),
              const SizedBox(height: 28),

              // ── Tarjeta comprobante ───────────────────────
              GlassCard(
                borderRadius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  children: [
                    // Header del comprobante
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AquaColors.turquoise.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AquaColors.turquoise.withValues(alpha: 0.30),
                            ),
                          ),
                          child: Text(
                            isResupply ? 'REABASTECIMIENTO' : 'ABASTECIMIENTO',
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AquaColors.turquoise,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$timeStr · $dateStr',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: AquaColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(height: 1, color: AquaColors.platinum),
                    const SizedBox(height: 14),

                    // Filas de datos
                    _buildRow('Despachador', dispenserId),
                    _buildRow('Punto / Zona', pointName),
                    _buildRow('Entregó', userName),
                    _buildRow(
                      isResupply ? 'Garrafones reabastecidos' : 'Garrafones',
                      '$bottleCount',
                    ),
                    if (recipientName != null && recipientName!.isNotEmpty)
                      _buildRow('Recibido por', recipientName!),

                    // Firma capturada
                    if (signaturePoints != null && signaturePoints!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(height: 1, color: AquaColors.platinum),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'Firma capturada',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: AquaColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 120,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AquaColors.turquoise.withValues(alpha: 0.40),
                              ),
                            ),
                            child: SignaturePreviewBox(
                              points: signaturePoints,
                              height: 48,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Botón continuar
              AquaButton(
                text: 'Continuar',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const WorkerShell(initialTabIndex: 1),
                    ),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: AquaColors.textMuted,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AquaColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
