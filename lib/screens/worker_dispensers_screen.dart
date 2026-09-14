import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_badge.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';
import 'dispenser_detail_screen.dart';
import 'role_selection_screen.dart';

class WorkerDispensersScreen extends StatefulWidget {
  final VoidCallback? onNavigateToScan;

  const WorkerDispensersScreen({
    super.key,
    this.onNavigateToScan,
  });

  @override
  State<WorkerDispensersScreen> createState() => _WorkerDispensersScreenState();
}

class _WorkerDispensersScreenState extends State<WorkerDispensersScreen> {
  String _selectedFilter = 'Faltan'; // 'Faltan', 'Abastecidos', 'Todos'

  List<ZoneDispenserEntry> get _allEntries => getAllDispensersWithZone();

  List<ZoneDispenserEntry> get _filteredEntries {
    final all = _allEntries;
    if (_selectedFilter == 'Faltan') {
      return all.where((e) => !e.dispenser.isSupplied).toList();
    }
    if (_selectedFilter == 'Abastecidos') {
      return all.where((e) => e.dispenser.isSupplied).toList();
    }
    return all;
  }

  int get _pendingCount => _allEntries.where((e) => !e.dispenser.isSupplied).length;
  int get _suppliedCount => _allEntries.where((e) => e.dispenser.isSupplied).length;

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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AquaColors.turquoise.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AquaColors.turquoise.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AquaColors.turquoise,
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
                  '¿Estás seguro de que deseas salir de tu sesión de trabajador?',
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
    final list = _filteredEntries;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Logout Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mis Despachadores',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AquaColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$_pendingCount pendientes • $_suppliedCount abastecidos',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AquaColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
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
          const SizedBox(height: 16),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'Faltan abastecer ($_pendingCount)',
                  'Faltan',
                  accentColor: AquaColors.statusPending,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Ya abastecidos ($_suppliedCount)',
                  'Abastecidos',
                  accentColor: AquaColors.statusSupplied,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Todos (${_allEntries.length})',
                  'Todos',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Dispensers List
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 48,
                          color: AquaColors.statusSupplied,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '¡Excelente trabajo!',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AquaColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No hay despachadores pendientes en esta sección.',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: AquaColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final dispenser = item.dispenser;
                      final isSupplied = dispenser.isSupplied;

                      return GlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        backgroundColor: isSupplied
                            ? Colors.white.withValues(alpha: 0.85)
                            : AquaColors.statusPendingBg.withValues(alpha: 0.12),
                        borderColor: isSupplied
                            ? AquaColors.platinum
                            : AquaColors.statusPending.withValues(alpha: 0.4),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DispenserDetailScreen(
                                dispenserId: dispenser.id,
                                pointName: item.zoneName,
                                brand: dispenser.brand,
                                model: dispenser.model,
                                serialNumber: dispenser.serialNumber,
                                isSupplied: dispenser.isSupplied,
                                alertMessage: dispenser.alertMessage,
                              ),
                            ),
                          );
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            // State icon
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSupplied
                                    ? AquaColors.statusSuppliedBg
                                    : AquaColors.statusPendingBg,
                                border: Border.all(
                                  color: isSupplied
                                      ? AquaColors.statusSuppliedBorder
                                      : AquaColors.statusPendingBorder,
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                isSupplied
                                    ? Icons.water_drop_rounded
                                    : Icons.warning_amber_rounded,
                                color: isSupplied
                                    ? AquaColors.statusSupplied
                                    : AquaColors.statusPending,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Middle info (Takes flexible available space without overflowing)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Despachador ${dispenser.id}',
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
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Zona ${item.zoneName}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AquaColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isSupplied
                                        ? dispenser.lastSupplyInfo
                                        : (dispenser.alertMessage.isNotEmpty
                                            ? dispenser.alertMessage
                                            : 'Falta abastecer'),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      fontWeight: isSupplied
                                          ? FontWeight.w500
                                          : FontWeight.w600,
                                      color: isSupplied
                                          ? AquaColors.textMuted
                                          : AquaColors.statusPending,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Status badge (compact, prevents overflow on small screens)
                            AquaBadge(
                              status: isSupplied
                                  ? SupplyStatus.supplied
                                  : SupplyStatus.pending,
                              customText: isSupplied ? 'Listo' : 'Pendiente',
                            ),
                            const SizedBox(width: 4),

                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: AquaColors.slateBlue,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String text,
    String filterValue, {
    Color? accentColor,
  }) {
    final isSelected = _selectedFilter == filterValue;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = filterValue),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (accentColor ?? AquaColors.turquoise)
              : AquaColors.glacier.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (accentColor ?? AquaColors.turquoise)
                : AquaColors.platinum,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (accentColor ?? AquaColors.turquoise)
                        .withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AquaColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
