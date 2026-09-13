import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aqua_colors.dart';

enum SupplyStatus { supplied, pending }

class AquaBadge extends StatelessWidget {
  final SupplyStatus status;
  final String? customText;

  const AquaBadge({
    super.key,
    required this.status,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    final isSupplied = status == SupplyStatus.supplied;
    final color = isSupplied ? AquaColors.statusSupplied : AquaColors.statusPending;
    final text = customText ?? (isSupplied ? 'Abastecido' : 'Pendiente');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSupplied ? AquaColors.statusSuppliedBg : AquaColors.statusPendingBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
