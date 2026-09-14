import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_star.dart';
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _timer = Timer(const Duration(milliseconds: 2800), _goToNext);
  }

  void _goToNext() {
    if (!mounted) return;
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RoleSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaBackground(
        useSafeArea: false,
        child: GestureDetector(
          onTap: _goToNext,
          behavior: HitTestBehavior.translucent,
          child: SizedBox.expand(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Logo con animación de escala y pulso
                  AnimatedBuilder(
                    animation: Listenable.merge(
                        [_scaleAnimation, _pulseAnimation]),
                    builder: (context, child) => Transform.scale(
                      scale: _scaleAnimation.value * _pulseAnimation.value,
                      child: child,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow ring externo
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AquaColors.turquoise.withValues(alpha: 0.18),
                                AquaColors.glacier.withValues(alpha: 0.10),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // Fondo de logo
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.75),
                            border: Border.all(
                              color: AquaColors.glassBorder,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AquaColors.turquoise
                                    .withValues(alpha: 0.22),
                                blurRadius: 28,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: AquaStar(
                              size: 56,
                              color: AquaColors.turquoise,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Nombre de la marca
                  Text(
                    'AquaControl',
                    style: GoogleFonts.montserrat(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AquaColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtítulo corporativo
                  Text(
                    'Gestión de Despachadores de Agua',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: AquaColors.textSecondary,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Indicadores de carga — puntos pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(active: true),
                      const SizedBox(width: 6),
                      _buildDot(),
                      const SizedBox(width: 6),
                      _buildDot(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Iniciando...',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AquaColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot({bool active = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: active ? 24 : 8,
      height: 6,
      decoration: BoxDecoration(
        color: active
            ? AquaColors.turquoise
            : AquaColors.platinum,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
