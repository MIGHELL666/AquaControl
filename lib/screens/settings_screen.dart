import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';
import 'app_shell.dart';
import 'login_screen.dart';
import 'qr_scanner_screen.dart';
import 'dispenser_detail_screen.dart';
import 'success_screen.dart';
import 'role_selection_screen.dart';
import 'point_detail_screen.dart';
import 'splash_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _switchValue = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Más opciones y Estilos',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // User info Card
          GlassCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(16),
            backgroundColor: const Color(0x25233C78),
            borderColor: AquaColors.glassBorderSubtle,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x334468C7),
                  ),
                  child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Administrador General',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'admin@aquacontrol.com',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: AquaColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Direct Screen Launcher (To easily explore any screen from the reference)
          Text(
            'Explorar todas las pantallas del diseño',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AquaColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildNavChip(context, '1. Splash (Auto-carga)', () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                );
              }),
              _buildNavChip(context, '2. Login Admin', () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen(initialRole: UserRole.admin)),
                );
              }),
              _buildNavChip(context, '3. Login Trabajador', () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen(initialRole: UserRole.worker)),
                );
              }),
              _buildNavChip(context, '4. Selección Perfil', () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RoleSelectionScreen()));
              }),
              _buildNavChip(context, '5. Escanear QR', () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QrScannerScreen()));
              }),
              _buildNavChip(context, '6. Despachador #023', () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DispenserDetailScreen()));
              }),
              _buildNavChip(context, '7. Confirmación', () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SuccessScreen()));
              }),
              _buildNavChip(context, '8. Punto Producción', () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PointDetailScreen()));
              }),
            ],
          ),
          const SizedBox(height: 24),

          // Guía de Estilos & UI Kit Showcase
          Text(
            'UI Kit & Guía de diseño',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AquaColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Palette swatch row
          GlassCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(16),
            backgroundColor: const Color(0x221E3368),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paleta de colores',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildColorSwatch(AquaColors.icyBlue, '#7B8FF2', 'Icy Blue'),
                    _buildColorSwatch(AquaColors.cornflowerBlue, '#7692FF', 'Cornflower'),
                    _buildColorSwatch(AquaColors.persianBlue, '#1B2C7C', 'Persian'),
                    _buildColorSwatch(AquaColors.deepNavy, '#091540', 'Deep Navy'),
                    _buildColorSwatch(AquaColors.duskBlue, '#3D518C', 'Dusk Blue'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // UI Components Showcase Card
          GlassCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(16),
            backgroundColor: const Color(0x221E3368),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Elementos de UI',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                AquaButton(
                  text: 'Botón principal',
                  height: 42,
                  onPressed: () {},
                ),
                const SizedBox(height: 10),
                AquaButton(
                  text: 'Botón secundario',
                  type: AquaButtonType.secondary,
                  height: 42,
                  onPressed: () {},
                ),
                const SizedBox(height: 14),

                // Switch and Information Card
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Switch de notificaciones',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: AquaColors.textSecondary,
                      ),
                    ),
                    Switch(
                      value: _switchValue,
                      thumbColor: const WidgetStatePropertyAll(Colors.white),
                      activeTrackColor: AquaColors.cornflowerBlue,
                      inactiveTrackColor: AquaColors.persianBlue,
                      onChanged: (val) => setState(() => _switchValue = val),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Tarjeta de información preview
                GlassCard(
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  backgroundColor: const Color(0x203D518C),
                  borderColor: AquaColors.glassBorderSubtle,
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 18, color: AquaColors.icyBlue),
                      const SizedBox(width: 10),
                      Text(
                        'Tarjeta de información',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Estilo visual details
          GlassCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(16),
            backgroundColor: const Color(0x221E3368),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estilo visual',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                _buildBullet('Glasmorfismo (BackdropFilter & Blur)'),
                _buildBullet('Transparencias y desenfoque fluido'),
                _buildBullet('Esquinas redondeadas'),
                _buildBullet('Sombras suaves con glow azul'),
                _buildBullet('Iconografía minimalista'),
                _buildBullet('Gradientes sutiles'),
                _buildBullet('Sensación de limpieza, agua y tecnología'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout Button
          AquaButton(
            text: 'Cerrar sesión',
            type: AquaButtonType.secondary,
            icon: Icons.logout_rounded,
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNavChip(BuildContext context, String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(
        label,
        style: GoogleFonts.montserrat(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
      ),
      backgroundColor: const Color(0x333D518C),
      side: const BorderSide(color: AquaColors.glassBorderSubtle, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onPressed: onTap,
    );
  }

  Widget _buildColorSwatch(Color color, String hex, String name) {
    return Column(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          hex,
          style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        Text(
          name,
          style: GoogleFonts.montserrat(fontSize: 8, color: AquaColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AquaColors.icyBlue, fontSize: 13)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: AquaColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
