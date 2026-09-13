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
            : '${zone.totalDispensers} despachadores • ${zone.suppliedCount} abastecidos, ${zone.pendingCount} falta${zone.pendingCount > 1 ? 'n' : ''}',
        status: isSupplied ? SupplyStatus.supplied : SupplyStatus.pending,
      );
    }).toList();
  }

  List<SupplyPointItem> get _filteredPoints {
    return _allPoints.where((item) {
      // Filter tab
      if (_selectedFilter == 'Abastecidos' && item.status != SupplyStatus.supplied) {
        return false;
      }
      if (_selectedFilter == 'Pendientes' && item.status != SupplyStatus.pending) {
        return false;
      }
      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return item.title.toLowerCase().contains(query) ||
            item.subtitle.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AquaColors.icyBlue),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                'Puntos de abastecimiento',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filter chips: Todos, Abastecidos, Pendientes
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Todos'),
                const SizedBox(width: 10),
                _buildFilterChip('Abastecidos'),
                const SizedBox(width: 10),
                _buildFilterChip('Pendientes'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Search Field
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0x283D518C),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AquaColors.glassBorderSubtle, width: 1),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AquaColors.icyBlue),
                hintText: 'Buscar punto...',
                hintStyle: GoogleFonts.montserrat(color: AquaColors.textMuted, fontSize: 13),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Points List
          Expanded(
            child: _filteredPoints.isEmpty
                ? Center(
                    child: Text(
                      'No se encontraron puntos',
                      style: GoogleFonts.montserrat(color: AquaColors.textMuted),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredPoints.length,
                    separatorBuilder: (_, i) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _filteredPoints[index];
                      return GlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        backgroundColor: const Color(0x221E3368),
                        borderColor: AquaColors.glassBorderSubtle,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PointDetailScreen(pointName: item.title),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            // Pin icon in circle
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0x334468C7),
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: AquaColors.icyBlue,
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Title & Subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.subtitle,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      color: AquaColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Status badge
                            AquaBadge(status: item.status),
                            const SizedBox(width: 8),

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

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AquaColors.cornflowerBlue : const Color(0x243D518C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white.withValues(alpha: 0.3) : AquaColors.glassBorderSubtle,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AquaColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
