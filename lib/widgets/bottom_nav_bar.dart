import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aqua_colors.dart';

class AquaBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AquaBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AquaColors.glassSurfaceLight,
            border: Border(
              top: BorderSide(
                color: AquaColors.glassBorder,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AquaColors.shadowFloat,
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(context, 0, Icons.home_rounded, 'Inicio'),
                  _buildNavItem(context, 1, Icons.location_on_rounded, 'Puntos'),
                  _buildNavItem(context, 2, Icons.access_time_rounded, 'Historial'),
                  _buildNavItem(context, 3, Icons.grid_view_rounded, 'Más'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: AquaColors.turquoise.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 16 : 0,
                  vertical: isSelected ? 4 : 0,
                ),
                decoration: isSelected
                    ? BoxDecoration(
                        color: AquaColors.turquoise.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      )
                    : null,
                child: Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? AquaColors.turquoise
                      : AquaColors.textMuted,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AquaColors.turquoise
                      : AquaColors.textMuted,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
