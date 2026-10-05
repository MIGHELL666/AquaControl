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

  const SupplyPointsScreen({super.key, this.showBackButton = false});

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
    final supplied = _allPoints
        .where((p) => p.status == SupplyStatus.supplied)
        .length;
    final pending = _allPoints
        .where((p) => p.status == SupplyStatus.pending)
        .length;

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
              _buildMiniStat(
                '${_allPoints.length}',
                'Total',
                AquaColors.slateBlue,
              ),
              const SizedBox(width: 8),
              _buildMiniStat(
                '$supplied',
                'Abastecidos',
                AquaColors.statusSupplied,
              ),
              const SizedBox(width: 8),
              _buildMiniStat(
                '$pending',
                'Pendientes',
                AquaColors.statusPending,
              ),
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
                BoxShadow(color: AquaColors.shadowCard, blurRadius: 8),
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
                      final zone = kDefaultZones.firstWhere(
                        (z) => z.name == item.title,
                        orElse: () => kDefaultZones.first,
                      );
                      final isSupplied = item.status == SupplyStatus.supplied;
                      return GlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
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
                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: AquaColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.subtitle,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11.5,
                                          color: AquaColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                PopupMenuButton<String>(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.more_vert_rounded,
                                    size: 18,
                                    color: AquaColors.textMuted,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  itemBuilder: (_) => [
                                    PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.edit_rounded,
                                            size: 16,
                                            color: AquaColors.slateBlue,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Editar zona',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.delete_rounded,
                                            size: 16,
                                            color: AquaColors.statusError,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Eliminar zona',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 13,
                                              color: AquaColors.statusError,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (val) {
                                    if (val == 'edit') {
                                      _showAddEditZoneDialog(existingZone: zone);
                                    } else if (val == 'delete') {
                                      _confirmDeleteZone(zone);
                                    }
                                  },
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16,
                                  color: AquaColors.textMuted,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: AquaBadge(status: item.status),
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

  void _showAddEditZoneDialog({ZoneItem? existingZone}) {
    final isEdit = existingZone != null;
    final currentZone = existingZone;
    final nameCtrl = TextEditingController(text: existingZone?.name ?? '');
    final subtitleCtrl = TextEditingController(
      text: existingZone?.subtitle ?? '',
    );
    String? error;
    final oldName = existingZone?.name;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dCtx, setDState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AquaColors.shadowFloat,
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
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
                        color: isEdit
                            ? AquaColors.slateBlue.withValues(alpha: 0.12)
                            : AquaColors.turquoise.withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        isEdit
                            ? Icons.edit_location_alt_rounded
                            : Icons.add_location_alt_rounded,
                        size: 18,
                        color: isEdit
                            ? AquaColors.slateBlue
                            : AquaColors.turquoise,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isEdit ? 'Editar Zona' : 'Nueva Zona',
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
                _buildZoneTextField(
                  nameCtrl,
                  'Nombre de la zona',
                  'Ej. Calidad',
                  Icons.place_rounded,
                ),
                const SizedBox(height: 10),
                _buildZoneTextField(
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
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isEdit
                          ? [AquaColors.slateBlue, const Color(0xFF3C5B74)]
                          : [AquaColors.turquoise, AquaColors.slateBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AquaColors.shadowButton,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) {
                          setDState(() => error = 'El nombre es requerido.');
                          return;
                        }
                        final duplicate = kDefaultZones.any(
                          (z) =>
                              z.name.toLowerCase() == name.toLowerCase() &&
                              z.name != oldName,
                        );
                        if (duplicate) {
                          setDState(
                            () => error = 'Ya existe una zona con ese nombre.',
                          );
                          return;
                        }
                        if (isEdit) {
                          final updated = ZoneItem(
                            name: name,
                            subtitle: subtitleCtrl.text.trim().isEmpty
                                ? currentZone!.subtitle
                                : subtitleCtrl.text.trim(),
                            dispensers: currentZone!.dispensers,
                          );
                          updateZone(oldName!, updated);
                        } else {
                          addZone(
                            ZoneItem(
                              name: name,
                              subtitle: subtitleCtrl.text.trim().isEmpty
                                  ? 'Zona de abastecimiento'
                                  : subtitleCtrl.text.trim(),
                              dispensers: [],
                            ),
                          );
                        }
                        Navigator.of(ctx).pop();
                        setState(() {});
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
                                  isEdit
                                      ? 'Zona "$name" actualizada'
                                      : 'Zona "$name" agregada con éxito',
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
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isEdit ? Icons.save_rounded : Icons.add_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEdit ? 'Guardar cambios' : 'Agregar Zona',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteZone(ZoneItem zone) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AquaColors.shadowFloat,
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
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
                  Icons.delete_rounded,
                  color: AquaColors.statusError,
                  size: 24,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Eliminar zona "${zone.name}"',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AquaColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esta acción eliminará la zona y sus ${zone.totalDispensers} despachador(es). No se puede deshacer.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AquaColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.of(ctx).pop(),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AquaColors.glacier.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AquaColors.platinum),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AquaColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        deleteZone(zone.name);
                        Navigator.of(ctx).pop();
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AquaColors.statusError,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.delete_sweep_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Zona "${zone.name}" eliminada',
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
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AquaColors.statusError,
                              const Color(0xFFB91C1C),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AquaColors.statusError.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Eliminar',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoneTextField(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AquaColors.platinum),
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
                    ),
                  ]
                : [BoxShadow(color: AquaColors.shadowCard, blurRadius: 6)],
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
