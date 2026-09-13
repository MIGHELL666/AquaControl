import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/water_dispenser_art.dart';
import 'success_screen.dart';

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

  void _onRegister() {
    markDispenserSupplied(widget.dispenserId, _bottleCount);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SuccessScreen(
          dispenserId: widget.dispenserId,
          pointName: widget.pointName,
          bottleCount: _bottleCount,
          userName: 'Juan Pérez',
        ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AquaColors.icyBlue),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Despachador ${widget.dispenserId}',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border_rounded, size: 20, color: AquaColors.icyBlue),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Dispenser Illustration Artwork
              const Center(
                child: WaterDispenserArt(
                  width: 100,
                  height: 130,
                ),
              ),
              const SizedBox(height: 16),

              // Dispenser Details Card
              GlassCard(
                borderRadius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                backgroundColor: const Color(0x28233C78),
                borderColor: AquaColors.glassBorderSubtle,
                child: Column(
                  children: [
                    _buildDetailRow('Punto / Zona:', widget.pointName),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      'Estado:',
                      widget.isSupplied ? 'Abastecido' : 'Falta abastecer',
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow('Marca:', widget.brand),
                    const SizedBox(height: 10),
                    _buildDetailRow('Modelo:', widget.model),
                    const SizedBox(height: 10),
                    _buildDetailRow('Serie:', widget.serialNumber),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stepper Question: ¿Cuántos garrafones?
              Text(
                '¿Cuántos garrafones?',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),

              // Stepper Pill
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0x283D518C),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AquaColors.glassBorderSubtle, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18, color: AquaColors.icyBlue),
                      onPressed: () {
                        if (_bottleCount > 1) {
                          setState(() => _bottleCount--);
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        '$_bottleCount',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18, color: AquaColors.icyBlue),
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
                text: 'Registrar abastecimiento',
                onPressed: _onRegister,
              ),
              const SizedBox(height: 12),
              AquaButton(
                text: 'Cancelar',
                type: AquaButtonType.secondary,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
            ],
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
            fontWeight: FontWeight.w400,
            color: AquaColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
