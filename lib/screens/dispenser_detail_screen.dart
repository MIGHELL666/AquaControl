import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/water_dispenser_art.dart';
import 'digital_signature_screen.dart';

class DispenserDetailScreen extends StatefulWidget {
  final String dispenserId;
  final String pointName;
  final String brand;
  final String model;
  final String serialNumber;
  final bool isSupplied;
  final String alertMessage;

  const DispenserDetailScreen({
    super.key,
    this.dispenserId = '#023',
    this.pointName = 'Producción',
    this.brand = 'EcoWater',
    this.model = 'E-200',
    this.serialNumber = 'SN345678',
    this.isSupplied = true,
    this.alertMessage = '',
  });

  @override
  State<DispenserDetailScreen> createState() => _DispenserDetailScreenState();
}

class _DispenserDetailScreenState extends State<DispenserDetailScreen> {
  int _bottleCount = 2;
  late bool _isResupplyMode;

  @override
  void initState() {
    super.initState();
    _isResupplyMode = widget.isSupplied;
  }

  void _onProceedToSignature() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DigitalSignatureScreen(
          dispenserId: widget.dispenserId,
          pointName: widget.pointName,
          bottleCount: _bottleCount,
          isResupply: _isResupplyMode,
          workerName: 'Juan Pérez',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                        Text(
                          'Despachador ${widget.dispenserId}',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AquaColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: widget.isSupplied
                            ? AquaColors.statusSuppliedBg
                            : AquaColors.statusPendingBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.isSupplied
                              ? AquaColors.statusSuppliedBorder
                              : AquaColors.statusPendingBorder,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.isSupplied ? 'Abastecido' : 'Pendiente',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: widget.isSupplied
                              ? AquaColors.statusSupplied
                              : AquaColors.statusPending,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Dispenser Illustration Artwork
                const Center(
                  child: WaterDispenserArt(
                    width: 90,
                    height: 115,
                  ),
                ),
                const SizedBox(height: 14),

                // Dispenser Details Card
                GlassCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Column(
                    children: [
                      _buildDetailRow('Punto / Zona:', widget.pointName),
                      const SizedBox(height: 8),
                      _buildDetailRow('Marca y Modelo:', '${widget.brand} ${widget.model}'),
                      const SizedBox(height: 8),
                      _buildDetailRow('Serie:', widget.serialNumber),
                      if (widget.alertMessage.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow('Alerta:', widget.alertMessage, isAlert: true),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Selector: Abastecimiento inicial vs Reabastecimiento de ronda
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AquaColors.glacier.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AquaColors.platinum),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isResupplyMode = false),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: !_isResupplyMode
                                  ? AquaColors.turquoise
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: !_isResupplyMode
                                  ? [
                                      BoxShadow(
                                        color: AquaColors.turquoise.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Abastecer',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: !_isResupplyMode
                                    ? Colors.white
                                    : AquaColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isResupplyMode = true),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: _isResupplyMode
                                  ? AquaColors.turquoise
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _isResupplyMode
                                  ? [
                                      BoxShadow(
                                        color: AquaColors.turquoise.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sync_rounded,
                                  size: 15,
                                  color: _isResupplyMode
                                      ? Colors.white
                                      : AquaColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Reabastecer ronda',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _isResupplyMode
                                        ? Colors.white
                                        : AquaColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stepper Question: ¿Cuántos garrafones?
                Text(
                  _isResupplyMode
                      ? '¿Cuántos garrafones adicionales a recargar?'
                      : '¿Cuántos garrafones a entregar?',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AquaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                // Stepper Pill
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AquaColors.platinum, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: AquaColors.shadowCard,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AquaColors.turquoise),
                        onPressed: () {
                          if (_bottleCount > 1) {
                            setState(() => _bottleCount--);
                          }
                        },
                      ),
                      Text(
                        '$_bottleCount',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AquaColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AquaColors.turquoise),
                        onPressed: () {
                          setState(() => _bottleCount++);
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Action Buttons
                AquaButton(
                  text: _isResupplyMode
                      ? 'Registrar reabasto y firmar'
                      : 'Registrar abasto y firmar',
                  icon: Icons.draw_rounded,
                  onPressed: _onProceedToSignature,
                ),
                const SizedBox(height: 10),
                AquaButton(
                  text: 'Cancelar',
                  type: AquaButtonType.secondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isAlert = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AquaColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isAlert ? AquaColors.statusPending : AquaColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
