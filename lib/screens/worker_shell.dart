import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/zoom_container.dart';
import 'login_screen.dart' show ClientSelectionScreen;
import 'qr_scanner_screen.dart';
import 'role_selection_screen.dart';
import 'worker_dispensers_screen.dart';
import 'worker_history_table_screen.dart';

class WorkerShell extends StatefulWidget {
  final int initialTabIndex;

  const WorkerShell({super.key, this.initialTabIndex = 0});

  @override
  State<WorkerShell> createState() => _WorkerShellState();
}

class _WorkerShellState extends State<WorkerShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _ensureClientIfNeeded(),
    );
  }

  Future<void> _ensureClientIfNeeded() async {
    if (!WorkerSession.hasClient && mounted) {
      final client = await Navigator.of(context).push<ClientItem>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (ctx) => const ClientSelectionScreen(
            title: 'Selecciona la empresa a abastecer',
            isMandatory: true,
          ),
        ),
      );
      if (client != null && mounted) {
        setState(() => WorkerSession.setActiveClient(client));
      }
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AquaColors.turquoise.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AquaColors.turquoise.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(Icons.logout_rounded, color: AquaColors.turquoise, size: 24),
                ),
                const SizedBox(height: 16),
                Text('Cerrar sesión',
                    style: GoogleFonts.montserrat(
                        fontSize: 18, fontWeight: FontWeight.w700, color: AquaColors.textPrimary)),
                const SizedBox(height: 8),
                Text('¿Estás seguro de que deseas salir de tu sesión de trabajador?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                        fontSize: 13, color: AquaColors.textSecondary)),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(child: AquaButton(
                      text: 'Cancelar',
                      type: AquaButtonType.secondary,
                      height: 46,
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: AquaButton(
                      text: 'Salir',
                      type: AquaButtonType.danger,
                      height: 46,
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                          (route) => false,
                        );
                      },
                    )),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openChangeClient() async {
    ClientItem? current;
    if (WorkerSession.activeClientName != null) {
      for (final c in kDefaultClients) {
        if (c.companyName == WorkerSession.activeClientName) {
          current = c;
          break;
        }
      }
    }

    final client = await Navigator.of(context).push<ClientItem>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => ClientSelectionScreen(
          title: 'Cambiar empresa / cliente',
          selectedClient: current,
          allowOmit: false,
          isMandatory: false,
        ),
      ),
    );

    if (client != null && mounted) {
      setState(() => WorkerSession.setActiveClient(client));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AquaColors.turquoise,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Ahora abasteces a ${client.companyName}',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveClient = WorkerSession.hasClient;

    return Scaffold(
      body: AquaBackground(
        child: SafeArea(
          bottom: false,
          child: AquaZoomContainer(
            child: Column(
              children: [
                // ── Cliente activo (header sesión trabajador) ─
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _openChangeClient,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.74),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AquaColors.slateBlue.withValues(alpha: 0.25),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AquaColors.shadowCard,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AquaColors.slateBlue.withValues(
                                        alpha: 0.14,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.business_rounded,
                                      size: 16,
                                      color: AquaColors.slateBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hasActiveClient
                                              ? 'Abasteciendo a'
                                              : 'Sin empresa seleccionada',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AquaColors.textSecondary,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        if (hasActiveClient)
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  WorkerSession.activeClientName!,
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: AquaColors.textPrimary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          Text(
                                            'Toca para seleccionar una empresa',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: AquaColors.statusError,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.swap_horiz_rounded,
                                    size: 16,
                                    color: hasActiveClient
                                        ? AquaColors.slateBlue
                                        : AquaColors.statusError,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // ── Botón Cerrar sesión (persistente) ──
                      Container(
                        decoration: BoxDecoration(
                          color: AquaColors.glacier.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                          border: Border.all(color: AquaColors.platinum),
                          boxShadow: [
                            BoxShadow(
                              color: AquaColors.shadowCard,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.logout_rounded,
                            size: 19,
                            color: AquaColors.turquoise,
                          ),
                          tooltip: 'Cerrar sesión',
                          onPressed: () => _confirmLogout(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Pantallas por pestaña ───────────────────
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: [
                      const QrScannerScreen(),
                      WorkerDispensersScreen(
                        onNavigateToScan: () => _onTabSelected(0),
                      ),
                      const WorkerHistoryTableScreen(showFinancials: false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AquaColors.glassSurfaceLight,
              border: const Border(
                top: BorderSide(color: AquaColors.glassBorder, width: 1),
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
                    _buildNavItem(
                      0,
                      Icons.qr_code_scanner_rounded,
                      'Escanear QR',
                    ),
                    _buildNavItem(1, Icons.checklist_rounded, 'Despachadores'),
                    _buildNavItem(2, Icons.table_chart_rounded, 'Tabla'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AquaColors.turquoise : AquaColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabSelected(index),
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
                  vertical: isSelected ? 3 : 0,
                ),
                decoration: isSelected
                    ? BoxDecoration(
                        color: AquaColors.turquoise.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      )
                    : null,
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
