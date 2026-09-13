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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mis Despachadores',
                    style: GoogleFonts.montserrat(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$_pendingCount pendientes • $_suppliedCount abastecidos',
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
          const SizedBox(height: 16),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Faltan abastecer ($_pendingCount)', 'Faltan',
                    accentColor: AquaColors.statusPending),
                const SizedBox(width: 8),
                _buildFilterChip('Ya abastecidos ($_suppliedCount)', 'Abastecidos',
                    accentColor: AquaColors.statusSupplied),
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
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
                            horizontal: 16, vertical: 14),
                        backgroundColor: isSupplied
                            ? const Color(0x1F1E3166)
                            : const Color(0x2E4A2828),
                        borderColor: isSupplied
                            ? AquaColors.glassBorderSubtle
                            : AquaColors.statusPending.withValues(alpha: 0.35),
                        onTap: () async {
                          // If worker taps, navigate to DispenserDetailScreen to register supply
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
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSupplied
                                    ? const Color(0x28496EC7)
                                    : AquaColors.statusPending
                                        .withValues(alpha: 0.2),
                              ),
                              child: Icon(
                                isSupplied
                                    ? Icons.water_drop_outlined
                                    : Icons.warning_amber_rounded,
                                color: isSupplied
                                    ? AquaColors.icyBlue
                                    : AquaColors.statusPending,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Despachador ${dispenser.id}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '• Zona ${item.zoneName}',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 11,
                                            color: AquaColors.textSecondary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    isSupplied
                                        ? dispenser.lastSupplyInfo
                                        : (dispenser.alertMessage.isNotEmpty
                                            ? dispenser.alertMessage
                                            : 'Falta abastecer • Toca para registrar'),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      fontWeight: isSupplied
                                          ? FontWeight.w400
                                          : FontWeight.w500,
                                      color: isSupplied
                                          ? AquaColors.textSecondary
                                          : AquaColors.statusPending,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            AquaBadge(
                              status: isSupplied
                                  ? SupplyStatus.supplied
                                  : SupplyStatus.pending,
                              customText:
                                  isSupplied ? 'Abastecido' : 'Falta abastecer',
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: AquaColors.textMuted,
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (accentColor?.withValues(alpha: 0.25) ??
                  AquaColors.cornflowerBlue)
              : const Color(0x243D518C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (accentColor ?? Colors.white.withValues(alpha: 0.4))
                : AquaColors.glassBorderSubtle,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? (accentColor ?? Colors.white)
                : AquaColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
