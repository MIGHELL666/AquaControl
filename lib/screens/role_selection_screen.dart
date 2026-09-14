import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_star.dart';
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
              const SizedBox(height: 8),
              if (Navigator.of(context).canPop())
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: AquaColors.textSecondary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                )
              else
                const SizedBox(height: 16),
              const SizedBox(height: 16),

              // Header con logo
              Center(
                child: Column(
                  children: [
                    // Logo pequeño
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.80),
                        border: Border.all(
                          color: AquaColors.glassBorder,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AquaColors.turquoise.withValues(alpha: 0.20),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: AquaStar(
                          size: 34,
                          color: AquaColors.turquoise,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'AquaControl',
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AquaColors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Selecciona tu perfil para continuar',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: AquaColors.textMuted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Tarjeta: Administrador
              _buildRoleCard(
                context: context,
                icon: Icons.shield_rounded,
                title: 'Administrador',
                subtitle: 'Gestión de zonas, clientes y reportes operativos',
                color: AquaColors.turquoise,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(
                        initialRole: UserRole.admin,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),

              // Tarjeta: Trabajador
              _buildRoleCard(
                context: context,
                icon: Icons.local_shipping_rounded,
                title: 'Trabajador',
                subtitle: 'Escanea QR y registra abastecimientos de garrafones',
                color: AquaColors.slateBlue,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(
                        initialRole: UserRole.worker,
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),

              // Footer
              Center(
                child: Text(
                  'Purificadora de Agua © 2026',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: AquaColors.textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(20),
      onTap: onTap,
      child: Row(
        children: [
          // Avatar con icono de rol
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.18),
                  color.withValues(alpha: 0.08),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),

          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AquaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AquaColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          // Flecha
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AquaColors.textMuted,
            size: 16,
          ),
        ],
      ),
    );
  }
}
