import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';
import 'clients_screen.dart';
import 'register_dispenser_screen.dart';
import 'role_selection_screen.dart';
import 'workers_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToPoints;
  final VoidCallback? onNavigateToHistory;

  const AdminDashboardScreen({
    super.key,
    this.onNavigateToPoints,
    this.onNavigateToHistory,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String? _selectedClientId; // null representa 'Todos los clientes'

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AquaColors.statusError.withValues(alpha: 0.12),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AquaColors.statusError,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cerrar sesión',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AquaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '¿Estás seguro de que deseas salir de tu sesión de administrador?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: AquaColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AquaButton(
                        text: 'Cancelar',
                        type: AquaButtonType.secondary,
                        height: 46,
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AquaButton(
                        text: 'Salir',
                        type: AquaButtonType.danger,
                        height: 46,
                        onPressed: () {
                          Navigator.of(dialogCtx).pop();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const RoleSelectionScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddZoneDialog() {
    final nameCtrl = TextEditingController();
    final subtitleCtrl = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dCtx, setDState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassCard(
            borderRadius: 22,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AquaColors.turquoise.withValues(alpha: 0.12),
                      ),
                      child: const Icon(
                        Icons.add_location_alt_rounded,
                        size: 18,
                        color: AquaColors.turquoise,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Nueva Zona',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AquaColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: AquaColors.textSecondary,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  nameCtrl,
                  'Nombre de la zona',
                  'Ej. Calidad',
                  Icons.place_rounded,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  subtitleCtrl,
                  'Descripción',
                  'Ej. Laboratorio de análisis',
                  Icons.notes_rounded,
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    error!,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AquaColors.statusError,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                AquaButton(
                  text: 'Agregar Zona',
                  icon: Icons.add_rounded,
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      setDState(() => error = 'El nombre es requerido.');
                      return;
                    }
                    final exists = kDefaultZones.any(
                      (z) => z.name.toLowerCase() == name.toLowerCase(),
                    );
                    if (exists) {
                      setDState(
                        () => error = 'Ya existe una zona con ese nombre.',
                      );
                      return;
                    }
                    addZone(
                      ZoneItem(
                        name: name,
                        subtitle: subtitleCtrl.text.trim().isEmpty
                            ? 'Zona de abastecimiento'
                            : subtitleCtrl.text.trim(),
                        dispensers: [],
                      ),
                    );
                    Navigator.of(ctx).pop();
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AquaColors.glassBorder),
      ),
      child: TextField(
        controller: ctrl,
        style: GoogleFonts.montserrat(
          fontSize: 13,
          color: AquaColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 18, color: AquaColors.slateBlue),
          labelStyle: GoogleFonts.montserrat(
            fontSize: 12,
            color: AquaColors.textSecondary,
          ),
          hintStyle: GoogleFonts.montserrat(
            fontSize: 12,
            color: AquaColors.textMuted,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cliente seleccionado para separar las métricas (Requerimiento 3)
    ClientItem? selectedClient;
    if (_selectedClientId != null) {
      final idx = kDefaultClients.indexWhere((c) => c.id == _selectedClientId);
      if (idx != -1) {
        selectedClient = kDefaultClients[idx];
      } else {
        _selectedClientId = null;
      }
    }

    final kpiMetrics = getKpisForClient(selectedClient);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, Administrador 👋',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AquaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Resumen del día',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AquaColors.textMuted,
                    ),
                  ),
                ],
              ),
              // Avatar / logout
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _confirmLogout(context),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.80),
                      border: Border.all(color: AquaColors.glassBorder),
                      boxShadow: [
                        BoxShadow(
                          color: AquaColors.shadowCard,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: AquaColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Selector de cliente para métricas (Requerimiento 3) ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selectedClient != null
                    ? AquaColors.turquoise.withValues(alpha: 0.6)
                    : AquaColors.platinum,
                width: selectedClient != null ? 1.4 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AquaColors.shadowCard,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selectedClient != null
                            ? AquaColors.turquoise.withValues(alpha: 0.15)
                            : AquaColors.glacier.withValues(alpha: 0.5),
                      ),
                      child: Icon(
                        Icons.business_rounded,
                        size: 17,
                        color: selectedClient != null
                            ? AquaColors.turquoise
                            : AquaColors.slateBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Métricas por cliente:',
                            style: GoogleFonts.montserrat(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AquaColors.textSecondary,
                            ),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: _selectedClientId,
                              isDense: true,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AquaColors.turquoise,
                                size: 22,
                              ),
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AquaColors.textPrimary,
                              ),
                              items: [
                                DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text(
                                    '🌐 Todos los clientes (General)',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: AquaColors.turquoise,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                ...kDefaultClients.map((client) {
                                  return DropdownMenuItem<String?>(
                                    value: client.id,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            client.companyName,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: AquaColors.textPrimary,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: client.isActive
                                                ? AquaColors.statusSupplied
                                                    .withValues(alpha: 0.12)
                                                : Colors.amber
                                                    .withValues(alpha: 0.18),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${client.dispenserCount} desp.',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                              color: client.isActive
                                                  ? AquaColors.statusSupplied
                                                  : Colors.amber.shade900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedClientId = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedClientId != null)
                      IconButton(
                        tooltip: 'Ver general',
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: AquaColors.textMuted),
                        onPressed: () {
                          setState(() {
                            _selectedClientId = null;
                          });
                        },
                      ),
                  ],
                ),
                if (selectedClient != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AquaColors.glacier.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded,
                            size: 13, color: AquaColors.turquoise),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Mostrando despachadores de ${selectedClient.companyName}',
                            style: GoogleFonts.montserrat(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AquaColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${selectedClient.status} \u2022 \$${selectedClient.pricePerBottle.toStringAsFixed(2)}/garr.',
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AquaColors.turquoise,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── KPI Grid 2×2 ───────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  icon: Icons.water_drop_rounded,
                  value: '${kpiMetrics.totalDispensers}',
                  label: selectedClient != null
                      ? 'Despachadores\ndel cliente'
                      : 'Total de\ndespachadores',
                  color: AquaColors.turquoise,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  icon: Icons.check_circle_rounded,
                  value: '${kpiMetrics.suppliedCount}',
                  label: 'Abastecidos',
                  color: AquaColors.statusSupplied,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  icon: Icons.schedule_rounded,
                  value: '${kpiMetrics.pendingCount}',
                  label: 'Pendientes',
                  color: AquaColors.statusPending,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  icon: Icons.inventory_2_rounded,
                  value: '${kpiMetrics.totalBottles}',
                  label: selectedClient != null
                      ? 'Garrafones en\nsus despachadores'
                      : 'Total de\ngarrafones',
                  color: AquaColors.slateBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Acciones rápidas: Clientes & Trabajadores ───────
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.business_rounded,
                  title: 'Clientes',
                  subtitle: '${kDefaultClients.length} empresas',
                  color: AquaColors.turquoise,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ClientsScreen()),
                    );
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.badge_rounded,
                  title: 'Trabajadores',
                  subtitle: '${kDefaultWorkers.length} activos',
                  color: AquaColors.slateBlue,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const WorkersManagementScreen(),
                      ),
                    );
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Botón Registrar Despachador — sutil, debajo de las tarjetas ──
          GlassCard(
            borderRadius: 14,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RegisterDispenserScreen(),
                ),
              );
              setState(() {});
            },
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AquaColors.turquoise.withValues(alpha: 0.10),
                  ),
                  child: const Icon(
                    Icons.add_circle_outline_rounded,
                    size: 17,
                    color: AquaColors.turquoise,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Registrar nuevo despachador',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AquaColors.textSecondary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AquaColors.textMuted,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Nueva Zona (tarjeta sutil estilo Registrar despachador) ──
          GlassCard(
            borderRadius: 14,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onTap: _showAddZoneDialog,
            borderColor: AquaColors.platinum,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AquaColors.glacier.withValues(alpha: 0.55),
                  ),
                  child: const Icon(
                    Icons.add_location_alt_outlined,
                    size: 16,
                    color: AquaColors.slateBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Registrar nueva zona',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AquaColors.textSecondary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AquaColors.textMuted,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AquaColors.textPrimary,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: AquaColors.textMuted,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AquaColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: AquaColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: AquaColors.textMuted,
          ),
        ],
      ),
    );
  }
}
