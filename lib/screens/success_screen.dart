import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';
import 'worker_shell.dart';

class SuccessScreen extends StatelessWidget {
  final String dispenserId;
  final String pointName;
  final int bottleCount;
  final String userName;
  final String dateStr;
  final String timeStr;

  const SuccessScreen({
    super.key,
    this.dispenserId = '#023',
    this.pointName = 'Producción',
    this.bottleCount = 2,
    this.userName = 'Juan Pérez',
    this.dateStr = '06/09/2026',
    this.timeStr = '14:37',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Glowing Checkmark Circle
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x334E78E6),
                  border: Border.all(
                    color: AquaColors.cornflowerBlue.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AquaColors.cornflowerBlue.withValues(alpha: 0.35),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 46,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                '¡Abastecimiento\nregistrado!',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 32),

              // Summary Glass Card
              GlassCard(
                borderRadius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                backgroundColor: const Color(0x28233C78),
                borderColor: AquaColors.glassBorderSubtle,
                child: Column(
                  children: [
                    _buildSummaryRow('Despachador:', dispenserId),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Punto:', pointName),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Fecha:', dateStr),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Hora:', timeStr),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Usuario:', userName),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Garrafones:', '$bottleCount'),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Continuar Button
              AquaButton(
                text: 'Continuar',
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const WorkerShell(initialTabIndex: 1),
                    ),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
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
