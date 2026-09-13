import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aqua_colors.dart';

enum AquaButtonType { primary, secondary, danger }

class AquaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AquaButtonType type;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isLoading;

  const AquaButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AquaButtonType.primary,
    this.icon,
    this.width = double.infinity,
    this.height = 54,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = type == AquaButtonType.primary;
    final isDanger = type == AquaButtonType.danger;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        gradient: isPrimary
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF869DFF),
                  AquaColors.cornflowerBlue,
                  AquaColors.primaryButtonEnd,
                ],
              )
            : isDanger
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE55353),
                      Color(0xFFD32F2F),
                      Color(0xFF9A1B1B),
                    ],
                  )
                : null,
        color: (isPrimary || isDanger) ? null : const Color(0x283D518C),
        border: Border.all(
          color: isPrimary
              ? Colors.white.withValues(alpha: 0.25)
              : isDanger
                  ? Colors.redAccent.withValues(alpha: 0.4)
                  : AquaColors.glassBorder,
          width: 1,
        ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AquaColors.cornflowerBlue.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : isDanger
                ? [
                    BoxShadow(
                      color: const Color(0xFFD32F2F).withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(27),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 18,
                          color: isPrimary ? Colors.white : AquaColors.icyBlue,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
