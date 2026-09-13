import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_button.dart';
import '../widgets/aqua_star.dart';
import 'app_shell.dart';
import 'worker_shell.dart';

class LoginScreen extends StatefulWidget {
  final UserRole initialRole;

  const LoginScreen({
    super.key,
    this.initialRole = UserRole.admin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _userController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _userController = TextEditingController(
      text: widget.initialRole == UserRole.admin
          ? 'admin@aquacontrol.com'
          : 'trabajador@aquacontrol.com',
    );
    _passwordController = TextEditingController(
      text: widget.initialRole == UserRole.admin
          ? 'AquaAdmin2026'
          : 'AquaPass2026',
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (widget.initialRole == UserRole.admin) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const AppShell(initialRole: UserRole.admin),
        ),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const WorkerShell(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.initialRole == UserRole.admin;

    return Scaffold(
      body: AquaBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Header with Back button and centered logo
                  Row(
                    children: [
                      if (Navigator.of(context).canPop())
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: AquaColors.icyBlue),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      const Spacer(),
                      const AquaStar(
                        size: 38,
                        color: AquaColors.icyBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AquaControl',
                        style: GoogleFonts.cinzel(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const Spacer(),
                      if (Navigator.of(context).canPop())
                        const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Role Badge (read-only indicator, no switcher)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0x333D518C),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AquaColors.glassBorderSubtle, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAdmin ? Icons.admin_panel_settings_outlined : Icons.badge_outlined,
                          size: 16,
                          color: AquaColors.icyBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isAdmin ? 'Acceso de Administrador' : 'Acceso de Trabajador',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Role subtitle
                  Text(
                    isAdmin
                        ? 'Consulta de métricas, reportes y supervisión'
                        : 'Escaneo de QR y registro de garrafones',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AquaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Input: Usuario
                  TextFormField(
                    controller: _userController,
                    style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        isAdmin ? Icons.person_outline_rounded : Icons.badge_outlined,
                        size: 20,
                        color: AquaColors.icyBlue,
                      ),
                      hintText: 'Usuario',
                      hintStyle: GoogleFonts.montserrat(color: AquaColors.textMuted, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input: Contraseña
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AquaColors.icyBlue),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20,
                          color: AquaColors.icyBlue,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      hintText: 'Contraseña',
                      hintStyle: GoogleFonts.montserrat(color: AquaColors.textMuted, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Primary Login Button
                  AquaButton(
                    text: isAdmin ? 'Iniciar como Administrador' : 'Iniciar como Trabajador',
                    icon: isAdmin ? Icons.dashboard_customize_outlined : Icons.qr_code_scanner_rounded,
                    onPressed: _onLogin,
                  ),

                  const Spacer(),

                  // Caption
                  Text(
                    'Solo personal autorizado',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AquaColors.textMuted,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
