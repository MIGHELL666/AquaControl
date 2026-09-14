import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_badge.dart';
import '../widgets/glass_card.dart';
import 'point_detail_screen.dart';

class SupplyPointItem {
  final String title;
  final String subtitle;
  final SupplyStatus status;

  const SupplyPointItem({
    required this.title,
    required this.subtitle,
    required this.status,
  });
}

class SupplyPointsScreen extends StatefulWidget {
  final bool showBackButton;

  const SupplyPointsScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<SupplyPointsScreen> createState() => _SupplyPointsScreenState();
}

class _SupplyPointsScreenState extends State<SupplyPointsScreen> {
  String _selectedFilter = 'Todos';
  String _searchQuery = '';

  List<SupplyPointItem> get _allPoints {
    return kDefaultZones.map((zone) {
      final isSupplied = zone.isFullySupplied;
      return SupplyPointItem(
        title: zone.name,
        subtitle: isSupplied
            ? '${zone.totalDispensers} despachadores • Todos abastecidos'
            : '${zone.totalDispensers} despachadores • ${zone.suppliedCount} abastecidos, ${zone.pendingCount} pendiente${zone.pendingCount > 1 ? 's' : ''}',
        status: isSupplied ? SupplyStatus.supplied : SupplyStatus.pending,
      );
    }).toList();
  }

  List<SupplyPointItem> get _filteredPoints {
    return _allPoints.where((item) {
      if (_selectedFilter == 'Abastecidos' &&
          item.status != SupplyStatus.supplied) {
        return false;
      }
      if (_selectedFilter == 'Pendientes' &&
          item.status != SupplyStatus.pending) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return item.title.toLowerCase().contains(q) ||
            item.subtitle.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final supplied = _allPoints.where((p) => p.status == SupplyStatus.supplied).length;
    final pending = _allPoints.where((p) => p.status == SupplyStatus.pending).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              if (widget.showBackButton) ...[
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: AquaColors.textSecondary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                'Puntos de abastecimiento',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AquaColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Mini resumen
          Row(
            children: [
              _buildMiniStat('${_allPoints.length}', 'Total', AquaColors.slateBlue),
              const SizedBox(width: 8),
              _buildMiniStat('$supplied', 'Abastecidos', AquaColors.statusSupplied),
              const SizedBox(width: 8),
              _buildMiniStat('$pending', 'Pendientes', AquaColors.statusPending),
            ],
          ),
          const SizedBox(height: 14),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Todos'),
                const SizedBox(width: 8),
                _buildFilterChip('Abastecidos'),
                const SizedBox(width: 8),
                _buildFilterChip('Pendientes'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Buscador
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AquaColors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: AquaColors.shadowCard,
                  blurRadius: 8,
                ),
              ],
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: GoogleFonts.montserrat(
                color: AquaColors.textPrimary,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: AquaColors.slateBlue,
                ),
                hintText: 'Buscar punto...',
                hintStyle: GoogleFonts.montserrat(
                  color: AquaColors.textMuted,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Lista de puntos
          Expanded(
            child: _filteredPoints.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 40,
                          color: AquaColors.textMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No se encontraron puntos',
                          style: GoogleFonts.montserrat(
                            color: AquaColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredPoints.length,
                    separatorBuilder: (_, i) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _filteredPoints[index];
                      final isSupplied = item.status == SupplyStatus.supplied;
                      return GlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        borderColor: isSupplied
                            ? AquaColors.glassBorder
                            : AquaColors.statusPendingBorder,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  PointDetailScreen(pointName: item.title),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSupplied
                                    ? AquaColors.statusSuppliedBg
                                    : AquaColors.statusPendingBg,
                              ),
                              child: Icon(
                                isSupplied
                                    ? Icons.location_on_rounded
                                    : Icons.warning_amber_rounded,
                                color: isSupplied
                                    ? AquaColors.statusSupplied
                                    : AquaColors.statusPending,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AquaColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.subtitle,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      color: AquaColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            AquaBadge(status: item.status),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
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

  Widget _buildMiniStat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 9,
                color: AquaColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = label),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AquaColors.turquoise
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.3)
                  : AquaColors.glassBorder,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AquaColors.shadowButton,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [
                    BoxShadow(
                      color: AquaColors.shadowCard,
                      blurRadius: 6,
                    )
                  ],
          ),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AquaColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
