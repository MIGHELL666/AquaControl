import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/glass_card.dart';
import 'app_shell.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              if (Navigator.of(context).canPop())
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AquaColors.icyBlue),
                  onPressed: () => Navigator.of(context).pop(),
                )
              else
                const SizedBox(height: 16),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  'Selecciona tu perfil',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Option Card 1: Administrador
              _buildRoleCard(
                context: context,
                icon: Icons.person_rounded,
                title: 'Administrador',
                subtitle: 'Consulta, reportes y gestión de puntos y despachadores',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(initialRole: UserRole.admin),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Option Card 2: Trabajador
              _buildRoleCard(
                context: context,
                icon: Icons.badge_outlined,
                title: 'Trabajador',
                subtitle: 'Escanea QR y registra abastecimientos',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(initialRole: UserRole.worker),
                    ),
                  );
                },
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(20),
      backgroundColor: const Color(0x33284080),
      borderColor: AquaColors.glassBorder,
      onTap: onTap,
      child: Row(
        children: [
          // Circular Avatar icon container
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6B87DC).withValues(alpha: 0.35),
              border: Border.all(
                color: AquaColors.icyBlue.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),

          // Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AquaColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          // Chevron Right
          const Icon(
            Icons.chevron_right_rounded,
            color: AquaColors.icyBlue,
            size: 24,
          ),
        ],
      ),
    );
  }
}
