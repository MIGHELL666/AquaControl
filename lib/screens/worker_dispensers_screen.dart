import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../theme/aqua_colors.dart';
import '../widgets/glass_card.dart';
import 'dispenser_detail_screen.dart';

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
  String _selectedFilter = 'Faltan'; // 'Faltan', 'Abastecidos', 'Reabastecidos', 'Todos'

  List<ZoneDispenserEntry> get _allEntries => getAllDispensersWithZone();

  List<ZoneDispenserEntry> get _filteredEntries {
    final all = _allEntries;
    if (_selectedFilter == 'Faltan') {
      return all.where((e) => e.dispenser.isPending).toList();
    }
    if (_selectedFilter == 'Abastecidos') {
      return all.where((e) => e.dispenser.status == DispenserStatus.supplied).toList();
    }
    if (_selectedFilter == 'Reabastecidos') {
      return all.where((e) => e.dispenser.status == DispenserStatus.resupplied).toList();
    }
    return all;
  }

  int get _pendingCount => _allEntries.where((e) => e.dispenser.isPending).length;
  int get _suppliedCount => _allEntries.where((e) => e.dispenser.status == DispenserStatus.supplied).length;
  int get _resuppliedCount => _allEntries.where((e) => e.dispenser.status == DispenserStatus.resupplied).length;



  @override
  Widget build(BuildContext context) {
    final list = _filteredEntries;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mis Despachadores',
                style: GoogleFonts.montserrat(
                  fontSize: 20, fontWeight: FontWeight.w700,
                  color: AquaColors.textPrimary, letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$_pendingCount pendientes \u2022 $_suppliedCount abastecidos \u2022 $_resuppliedCount reabastecidos',
                style: GoogleFonts.montserrat(
                  fontSize: 12, fontWeight: FontWeight.w500,
                  color: AquaColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
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
                  'Pendiente de abastecer ($_pendingCount)',
                  'Faltan',
                  accentColor: AquaColors.statusPending,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Abastecido ($_suppliedCount)',
                  'Abastecidos',
                  accentColor: AquaColors.statusSupplied,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Reabastecido ($_resuppliedCount)',
                  'Reabastecidos',
                  accentColor: AquaColors.statusResupplied,
                ),
                const SizedBox(width: 8),
                _buildFilterChip('Todos (${_allEntries.length})', 'Todos'),
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
                        const Icon(Icons.check_circle_outline_rounded,
                            size: 48, color: AquaColors.statusSupplied),
                        const SizedBox(height: 12),
                        Text('¡Excelente trabajo!',
                            style: GoogleFonts.montserrat(
                                fontSize: 16, fontWeight: FontWeight.w700,
                                color: AquaColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('No hay despachadores en esta sección.',
                            style: GoogleFonts.montserrat(
                                fontSize: 12, color: AquaColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final dispenser = item.dispenser;
                      final status = dispenser.status;
                      final isPending = status == DispenserStatus.pending;
                      final isResupplied = status == DispenserStatus.resupplied;

                      // Color scheme based on status
                      final Color cardBg = isPending
                          ? AquaColors.statusPendingBg.withValues(alpha: 0.14)
                          : isResupplied
                              ? AquaColors.statusResuppliedBg.withValues(alpha: 0.14)
                              : Colors.white.withValues(alpha: 0.85);
                      final Color borderCol = isPending
                          ? AquaColors.statusPendingBorder
                          : isResupplied
                              ? AquaColors.statusResuppliedBorder
                              : AquaColors.platinum;
                      final Color iconBg = isPending
                          ? AquaColors.statusPendingBg
                          : isResupplied
                              ? AquaColors.statusResuppliedBg
                              : AquaColors.statusSuppliedBg;
                      final Color iconColor = isPending
                          ? AquaColors.statusPending
                          : isResupplied
                              ? AquaColors.statusResupplied
                              : AquaColors.statusSupplied;
                      final IconData iconData = isPending
                          ? Icons.hourglass_empty_rounded
                          : isResupplied
                              ? Icons.sync_rounded
                              : Icons.water_drop_rounded;

                      final String statusLabel = isPending
                          ? 'Pendiente de abastecer'
                          : isResupplied
                              ? 'Reabastecido'
                              : 'Abastecido';

                      return GlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        backgroundColor: cardBg,
                        borderColor: borderCol,
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
                              ),
                            ),
                          );
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            // Status icon circle
                            Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: iconBg,
                                border: Border.all(color: borderCol, width: 1),
                              ),
                              child: Icon(iconData, color: iconColor, size: 20),
                            ),
                            const SizedBox(width: 12),

                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Despachador ${dispenser.id}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13, fontWeight: FontWeight.w700,
                                      color: AquaColors.textPrimary,
                                    ),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Zona ${item.zoneName}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11, fontWeight: FontWeight.w500,
                                      color: AquaColors.textSecondary,
                                    ),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isPending ? dispenser.lastSupplyInfo : dispenser.lastSupplyInfo,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      fontWeight: isPending ? FontWeight.w600 : FontWeight.w500,
                                      color: iconColor,
                                    ),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: iconBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: borderCol, width: 1),
                              ),
                              child: Text(
                                statusLabel,
                                style: GoogleFonts.montserrat(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: iconColor,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right_rounded,
                                size: 18, color: AquaColors.slateBlue),
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

  Widget _buildFilterChip(String text, String filterValue, {Color? accentColor}) {
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
            color: isSelected ? (accentColor ?? AquaColors.turquoise) : AquaColors.platinum,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(
                  color: (accentColor ?? AquaColors.turquoise).withValues(alpha: 0.25),
                  blurRadius: 6, offset: const Offset(0, 2))]
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
