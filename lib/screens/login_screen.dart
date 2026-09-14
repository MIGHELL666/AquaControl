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
                  const SizedBox(height: 8),

                  // AppBar row
                  Row(
                    children: [
                      if (Navigator.of(context).canPop())
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 16,
                            color: AquaColors.textSecondary,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      const Spacer(),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.80),
                          border: Border.all(
                              color: AquaColors.glassBorder, width: 1),
                        ),
                        child: const Center(
                          child: AquaStar(
                            size: 20,
                            color: AquaColors.turquoise,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AquaControl',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AquaColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const Spacer(),
                      if (Navigator.of(context).canPop())
                        const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Encabezado de rol
                  Column(
                    children: [
                      // Badge de rol
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? AquaColors.turquoise.withValues(alpha: 0.12)
                              : AquaColors.slateBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isAdmin
                                ? AquaColors.turquoise.withValues(alpha: 0.40)
                                : AquaColors.slateBlue.withValues(alpha: 0.40),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAdmin
                                  ? Icons.shield_rounded
                                  : Icons.local_shipping_rounded,
                              size: 15,
                              color: isAdmin
                                  ? AquaColors.turquoise
                                  : AquaColors.slateBlue,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              isAdmin
                                  ? 'Acceso de Administrador'
                                  : 'Acceso de Trabajador',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isAdmin
                                    ? AquaColors.turquoise
                                    : AquaColors.slateBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isAdmin
                            ? 'Gestión operativa y reportes'
                            : 'Escaneo de QR y registro de garrafones',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: AquaColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Campo: Usuario
                  TextFormField(
                    controller: _userController,
                    style: GoogleFonts.montserrat(
                      color: AquaColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        isAdmin
                            ? Icons.person_outline_rounded
                            : Icons.badge_outlined,
                        size: 20,
                        color: AquaColors.slateBlue,
                      ),
                      hintText: 'Usuario',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo: Contraseña
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.montserrat(
                      color: AquaColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: AquaColors.slateBlue,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: AquaColors.slateBlue,
                        ),
                        onPressed: () {
                          setState(
                              () => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      hintText: 'Contraseña',
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Botón de inicio
                  AquaButton(
                    text: isAdmin
                        ? 'Iniciar como Administrador'
                        : 'Iniciar como Trabajador',
                    icon: isAdmin
                        ? Icons.dashboard_rounded
                        : Icons.qr_code_scanner_rounded,
                    onPressed: _onLogin,
                  ),

                  const Spacer(),

                  Text(
                    'Solo personal autorizado',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AquaColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
