import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/signature_pad.dart';
import 'success_screen.dart';

class DigitalSignatureScreen extends StatefulWidget {
  final String dispenserId;
  final String pointName;
  final int bottleCount;
  final bool isResupply;
  final String workerName;

  const DigitalSignatureScreen({
    super.key,
    required this.dispenserId,
    required this.pointName,
    required this.bottleCount,
    this.isResupply = false,
    this.workerName = 'Juan Pérez',
  });

  @override
  State<DigitalSignatureScreen> createState() => _DigitalSignatureScreenState();
}

class _DigitalSignatureScreenState extends State<DigitalSignatureScreen> {
  final TextEditingController _recipientController = TextEditingController();
  List<Offset> _signaturePoints = [];
  String? _errorMessage;

  @override
  void dispose() {
    _recipientController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final recipient = _recipientController.text.trim();
    if (recipient.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa el nombre de la persona que recibe.';
      });
      return;
    }

    if (_signaturePoints.isEmpty) {
      setState(() {
        _errorMessage = 'Se requiere la firma en pantalla de quien recibe.';
      });
      return;
    }

    // Process supply or resupply in memory store
    if (widget.isResupply) {
      resupplyDispenser(
        widget.dispenserId,
        widget.bottleCount,
        recipientName: recipient,
        signaturePoints: _signaturePoints,
        workerName: widget.workerName,
      );
    } else {
      markDispenserSupplied(
        widget.dispenserId,
        widget.bottleCount,
        recipientName: recipient,
        signaturePoints: _signaturePoints,
        workerName: widget.workerName,
      );
    }

    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SuccessScreen(
          dispenserId: widget.dispenserId,
          pointName: widget.pointName,
          bottleCount: widget.bottleCount,
          userName: widget.workerName,
          dateStr: dateStr,
          timeStr: timeStr,
          recipientName: recipient,
          isResupply: widget.isResupply,
          signaturePoints: _signaturePoints,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isResupply
                                ? 'Firma de Reabastecimiento'
                                : 'Firma de Conformidad',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AquaColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Recepción de garrafones en el punto',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AquaColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: widget.isResupply
                            ? AquaColors.statusPendingBg
                            : AquaColors.statusSuppliedBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.isResupply
                              ? AquaColors.statusPendingBorder
                              : AquaColors.statusSuppliedBorder,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.isResupply ? 'Reabasto' : 'Abasto',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: widget.isResupply
                              ? AquaColors.statusPending
                              : AquaColors.statusSupplied,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Transaction Summary Card
                GlassCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSummaryRow('Despachador:', widget.dispenserId),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Punto / Zona:', widget.pointName),
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        widget.isResupply ? 'Garrafones a reabastecer:' : 'Garrafones entregados:',
                        '${widget.bottleCount} garrafones',
                        isHighlight: true,
                      ),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Entregado por:', widget.workerName),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Recipient Name Field
                Text(
                  'Nombre de quien recibe:',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AquaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AquaColors.platinum),
                    boxShadow: [
                      BoxShadow(
                        color: AquaColors.shadowCard,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _recipientController,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AquaColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ej. Ing. Roberto Méndez / Sup. Almacén',
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: AquaColors.textMuted,
                      ),
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        color: AquaColors.turquoise,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Digital Signature Pad
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Firma digital en pantalla:',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AquaColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Firme con el dedo',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AquaColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                SignaturePad(
                  height: 200,
                  onSignatureChanged: (points) {
                    setState(() {
                      _signaturePoints = points;
                      if (_errorMessage != null) {
                        _errorMessage = null;
                      }
                    });
                  },
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AquaColors.statusErrorBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AquaColors.statusErrorBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AquaColors.statusError,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AquaColors.statusError,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Confirm button
                AquaButton(
                  text: widget.isResupply
                      ? 'Confirmar reabastecimiento y firma'
                      : 'Confirmar abastecimiento y firma',
                  icon: Icons.verified_rounded,
                  onPressed: _onConfirm,
                ),
                const SizedBox(height: 12),
                AquaButton(
                  text: 'Cancelar',
                  type: AquaButtonType.secondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AquaColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w700,
            color: isHighlight ? AquaColors.turquoise : AquaColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
