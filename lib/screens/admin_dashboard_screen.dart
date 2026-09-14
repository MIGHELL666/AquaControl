import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_badge.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';
import 'clients_screen.dart';
import 'point_detail_screen.dart';
import 'register_dispenser_screen.dart';
import 'role_selection_screen.dart';
import 'workers_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToPoints;

  const AdminDashboardScreen({
    super.key,
    this.onNavigateToPoints,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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

  @override
  Widget build(BuildContext context) {
    final totalDispensers = getTotalDispensersCount();
    final suppliedDispensers = getTotalSuppliedCount();
    final pendingDispensers = getTotalPendingCount();
    final totalBottles = getTotalBottlesCount();

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
          const SizedBox(height: 20),

          // ── KPI Grid 2×2 ───────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  icon: Icons.water_drop_rounded,
                  value: '$totalDispensers',
                  label: 'Total de\ndespachadores',
                  color: AquaColors.turquoise,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  icon: Icons.check_circle_rounded,
                  value: '$suppliedDispensers',
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
                  value: '$pendingDispensers',
                  label: 'Pendientes',
                  color: AquaColors.statusPending,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  icon: Icons.inventory_2_rounded,
                  value: '$totalBottles',
                  label: 'Total de\ngarrafones',
                  color: AquaColors.slateBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Botón Registrar Despachador ─────────────────────
          AquaButton(
            text: 'Registrar nuevo despachador',
            icon: Icons.add_circle_outline_rounded,
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RegisterDispenserScreen(),
                ),
              );
              setState(() {});
            },
          ),
          const SizedBox(height: 16),

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
                      MaterialPageRoute(
                        builder: (_) => const ClientsScreen(),
                      ),
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
          const SizedBox(height: 24),

          // ── Header: Zonas ─────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Zonas de abastecimiento',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AquaColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: widget.onNavigateToPoints,
                child: Row(
                  children: [
                    Text(
                      'Ver todas',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AquaColors.turquoise,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AquaColors.turquoise,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Lista de zonas ────────────────────────────────
          ...kDefaultZones.map((zone) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _buildZoneCard(context, zone),
            );
          }),
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

  Widget _buildZoneCard(BuildContext context, ZoneItem zone) {
    final isFullySupplied = zone.isFullySupplied;
    final progressVal = zone.totalDispensers > 0
        ? zone.suppliedCount / zone.totalDispensers
        : 0.0;

    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderColor: isFullySupplied
          ? AquaColors.glassBorder
          : AquaColors.statusPendingBorder,
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PointDetailScreen(pointName: zone.name),
          ),
        );
        setState(() {});
      },
      child: Column(
        children: [
          Row(
            children: [
              // Icono de zona
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFullySupplied
                      ? AquaColors.statusSuppliedBg
                      : AquaColors.statusPendingBg,
                ),
                child: Icon(
                  isFullySupplied
                      ? Icons.location_on_rounded
                      : Icons.warning_amber_rounded,
                  size: 20,
                  color: isFullySupplied
                      ? AquaColors.statusSupplied
                      : AquaColors.statusPending,
                ),
              ),
              const SizedBox(width: 12),

              // Nombre y descripción
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zona ${zone.name}',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AquaColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isFullySupplied
                          ? '${zone.totalDispensers} despachadores • Todos abastecidos'
                          : '${zone.suppliedCount}/${zone.totalDispensers} abastecidos',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: isFullySupplied
                            ? AquaColors.textMuted
                            : AquaColors.statusPending,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Badge estado
              AquaBadge(
                status: isFullySupplied
                    ? SupplyStatus.supplied
                    : SupplyStatus.pending,
                customText: isFullySupplied
                    ? 'OK'
                    : 'Falta (${zone.pendingCount})',
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AquaColors.textMuted,
              ),
            ],
          ),

          // Barra de progreso
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressVal,
              minHeight: 5,
              backgroundColor: AquaColors.platinum,
              valueColor: AlwaysStoppedAnimation<Color>(
                isFullySupplied
                    ? AquaColors.statusSupplied
                    : AquaColors.turquoise,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
