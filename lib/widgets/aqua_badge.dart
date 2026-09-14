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

    final bgColor = isSupplied
        ? AquaColors.statusSuppliedBg
        : AquaColors.statusPendingBg;
    final borderColor = isSupplied
        ? AquaColors.statusSuppliedBorder
        : AquaColors.statusPendingBorder;
    final textColor = isSupplied
        ? AquaColors.statusSupplied
        : AquaColors.statusPending;
    final icon = isSupplied
        ? Icons.check_circle_rounded
        : Icons.schedule_rounded;
    final text = customText ?? (isSupplied ? 'Abastecido' : 'Pendiente');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge genérico de estado con icono
class AquaStatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final IconData? icon;

  const AquaStatusBadge({
    super.key,
    required this.text,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
    this.icon,
  });

  factory AquaStatusBadge.info(String text) => AquaStatusBadge(
        text: text,
        color: AquaColors.turquoise,
        backgroundColor: AquaColors.statusInfoBg,
        borderColor: AquaColors.turquoise.withValues(alpha: 0.4),
        icon: Icons.info_outline_rounded,
      );

  factory AquaStatusBadge.success(String text) => AquaStatusBadge(
        text: text,
        color: AquaColors.statusSupplied,
        backgroundColor: AquaColors.statusSuppliedBg,
        borderColor: AquaColors.statusSuppliedBorder,
        icon: Icons.check_circle_outline_rounded,
      );

  factory AquaStatusBadge.warning(String text) => AquaStatusBadge(
        text: text,
        color: AquaColors.statusPending,
        backgroundColor: AquaColors.statusPendingBg,
        borderColor: AquaColors.statusPendingBorder,
        icon: Icons.warning_amber_rounded,
      );

  factory AquaStatusBadge.error(String text) => AquaStatusBadge(
        text: text,
        color: AquaColors.statusError,
        backgroundColor: AquaColors.statusErrorBg,
        borderColor: AquaColors.statusErrorBorder,
        icon: Icons.error_outline_rounded,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
