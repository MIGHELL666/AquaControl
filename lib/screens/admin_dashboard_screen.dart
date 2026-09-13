import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_badge.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';
import 'point_detail_screen.dart';
import 'register_dispenser_screen.dart';
import 'role_selection_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToPoints;

  const AdminDashboardScreen({
    super.key,
    this.onNavigateToPoints,
  });

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
            backgroundColor: const Color(0xFF132247),
            borderColor: AquaColors.glassBorderSubtle,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF869DFF).withValues(alpha: 0.15),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AquaColors.icyBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cerrar sesión',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '¿Estás seguro de que deseas salir de tu sesión de administrador?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: AquaColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 22),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Greeting + Logout button in top-right corner
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, Administrador',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aquí tienes el resumen de hoy',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AquaColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0x283D518C),
                  shape: BoxShape.circle,
                  border: Border.all(color: AquaColors.glassBorderSubtle),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 19,
                    color: AquaColors.icyBlue,
                  ),
                  tooltip: 'Cerrar sesión',
                  onPressed: () => _confirmLogout(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2x2 KPI Grid Cards
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  icon: Icons.local_drink_outlined,
                  value: '50',
                  label: 'Total de despachadores',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildKpiCard(
                  icon: Icons.check_circle_outline_rounded,
                  value: '37',
                  label: 'Abastecidos',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  icon: Icons.access_time_rounded,
                  value: '13',
                  label: 'Pendientes',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildKpiCard(
                  icon: Icons.water_drop_outlined,
                  value: '184',
                  label: 'Total de garrafones',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Section Header: Zonas de abastecimiento
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Zonas de abastecimiento',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              InkWell(
                onTap: onNavigateToPoints,
                child: Row(
                  children: [
                    Text(
                      'Ver todas',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AquaColors.icyBlue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AquaColors.icyBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Zones List: Clickable cards linking to PointDetailScreen
          ...kDefaultZones.map((zone) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _buildZoneCard(context, zone),
            );
          }),
          const SizedBox(height: 14),

          // Register new dispenser quick action
          AquaButton(
            text: 'Registrar nuevo despachador',
            icon: Icons.add_circle_outline_rounded,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RegisterDispenserScreen(),
                ),
              );
            },
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
  }) {
    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      backgroundColor: const Color(0x2820356C),
      borderColor: AquaColors.glassBorderSubtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x28496EC7),
            ),
            child: Icon(
              icon,
              color: AquaColors.icyBlue,
              size: 18,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AquaColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneCard(BuildContext context, ZoneItem zone) {
    final isFullySupplied = zone.isFullySupplied;

    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      backgroundColor: const Color(0x201E3166),
      borderColor: isFullySupplied
          ? AquaColors.glassBorderSubtle
          : AquaColors.statusPending.withValues(alpha: 0.25),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PointDetailScreen(pointName: zone.name),
          ),
        );
      },
      child: Row(
        children: [
          // Zone Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFullySupplied
                  ? const Color(0x28496EC7)
                  : AquaColors.statusPending.withValues(alpha: 0.18),
            ),
            child: Icon(
              isFullySupplied
                  ? Icons.location_on_outlined
                  : Icons.warning_amber_rounded,
              size: 19,
              color: isFullySupplied
                  ? AquaColors.icyBlue
                  : AquaColors.statusPending,
            ),
          ),
          const SizedBox(width: 14),

          // Zone Title & Dispenser Status Count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zona ${zone.name}',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isFullySupplied
                      ? '${zone.totalDispensers} despachadores • Todos abastecidos'
                      : '${zone.totalDispensers} despachadores • ${zone.suppliedCount} abastecidos, ${zone.pendingCount} falta${zone.pendingCount > 1 ? 'n' : ''}',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: isFullySupplied
                        ? AquaColors.textSecondary
                        : AquaColors.statusPending,
                    fontWeight: isFullySupplied ? FontWeight.w400 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Status Badge
          AquaBadge(
            status: isFullySupplied ? SupplyStatus.supplied : SupplyStatus.pending,
            customText: isFullySupplied
                ? 'Abastecida'
                : 'Falta (${zone.pendingCount})',
          ),
          const SizedBox(width: 6),

          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AquaColors.textMuted,
          ),
        ],
      ),
    );
  }
}
