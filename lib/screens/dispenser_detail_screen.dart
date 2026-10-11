import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/water_dispenser_art.dart';
import 'digital_signature_screen.dart';

class DispenserDetailScreen extends StatefulWidget {
  final String dispenserId;
  final String brand;
  final String serialNumber;
  final bool isSupplied;
  final bool isActive;

  const DispenserDetailScreen({
    super.key,
    this.dispenserId = '#023',
    this.brand = 'EcoWater',
    this.serialNumber = 'SN345678',
    this.isSupplied = true,
    this.isActive = true,
  });

  @override
  State<DispenserDetailScreen> createState() => _DispenserDetailScreenState();
}

class _DispenserDetailScreenState extends State<DispenserDetailScreen> {
  int _bottleCount = 2;
  late bool _isResupplyMode;
  ClientItem? _selectedClient;

  bool get _hasAssignedClient =>
      getClientForDispenser(widget.dispenserId) != null;

  @override
  void initState() {
    super.initState();
    _isResupplyMode = widget.isSupplied;
    _selectedClient = getClientForDispenser(widget.dispenserId);
  }

  void _onProceedToSignature() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DigitalSignatureScreen(
          dispenserId: widget.dispenserId,
          pointName: '',
          bottleCount: _bottleCount,
          isResupply: _isResupplyMode,
          workerName: 'Juan Pérez',
          clientName: _selectedClient?.companyName ?? '',
          pricePerBottle: _selectedClient?.pricePerBottle ?? 0.0,
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
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
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
                          Flexible(
                            child: Text(
                              'Despachador ${widget.dispenserId}',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AquaColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
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
                        widget.isSupplied
                            ? 'Abastecido'
                            : 'Pendiente de abastecer',
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
                const Center(child: WaterDispenserArt(width: 90, height: 115)),
                const SizedBox(height: 14),

                // Dispenser Details Card
                GlassCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Identificador:', widget.dispenserId),
                      const SizedBox(height: 8),
                      _buildDetailRow('Marca:', widget.brand),
                      const SizedBox(height: 8),
                      _buildDetailRow('Serie:', widget.serialNumber),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Estado:',
                        widget.isActive ? 'Activo' : 'Inactivo',
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Empresa:',
                        _selectedClient?.companyName ?? 'Sin asignar',
                      ),
                    ],
                  ),
                ),
                if (!_hasAssignedClient) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.amber.shade700),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 21,
                          color: Colors.amber.shade900,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Este despachador no está asociado a ningún cliente. Puedes continuar con el abastecimiento, pero el movimiento quedará sin cliente asignado.',
                            style: GoogleFonts.montserrat(
                              fontSize: 11.5,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              color: Colors.brown.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Selector: Abastecimiento vs Reabastecimiento
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
                                        color: AquaColors.turquoise.withValues(
                                          alpha: 0.25,
                                        ),
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
                                        color: AquaColors.turquoise.withValues(
                                          alpha: 0.25,
                                        ),
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
                const SizedBox(height: 14),

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
                const SizedBox(height: 8),

                // Stepper Pill + total
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AquaColors.platinum,
                            width: 1.2,
                          ),
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
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: AquaColors.turquoise,
                              ),
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
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: AquaColors.turquoise,
                              ),
                              onPressed: () => setState(() => _bottleCount++),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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

  Widget _buildDetailRow(String label, String value) {
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
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AquaColors.textPrimary,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
