import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_badge.dart';
import '../widgets/aqua_button.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/glass_card.dart';
import 'dispenser_detail_screen.dart';

class PointDetailScreen extends StatefulWidget {
  final String pointName;

  const PointDetailScreen({
    super.key,
    this.pointName = 'Producción',
  });

  @override
  State<PointDetailScreen> createState() => _PointDetailScreenState();
}

class _PointDetailScreenState extends State<PointDetailScreen> {
  int _currentNavIndex = 1;
  String _selectedFilter = 'Todos'; // 'Todos', 'Faltan', 'Abastecidos'
  bool _showHistory = false;

  final List<Map<String, dynamic>> _recentHistory = const [
    {
      'date': '06/09/2026',
      'user': 'Juan Pérez',
      'bottles': 2,
    },
    {
      'date': '05/09/2026',
      'user': 'Carlos López',
      'bottles': 2,
    },
    {
      'date': '04/09/2026',
      'user': 'Juan Pérez',
      'bottles': 3,
    },
    {
      'date': '03/09/2026',
      'user': 'Pedro García',
      'bottles': 2,
    },
    {
      'date': '02/09/2026',
      'user': 'Carlos López',
      'bottles': 2,
    },
  ];

  ZoneItem get _currentZone {
    return kDefaultZones.firstWhere(
      (z) => z.name.toLowerCase() == widget.pointName.toLowerCase(),
      orElse: () => kDefaultZones.first,
    );
  }

  List<DispenserItem> get _filteredDispensers {
    final zone = _currentZone;
    if (_selectedFilter == 'Faltan') {
      return zone.dispensers.where((d) => !d.isSupplied).toList();
    }
    if (_selectedFilter == 'Abastecidos') {
      return zone.dispensers.where((d) => d.isSupplied).toList();
    }
    return zone.dispensers;
  }

  @override
  Widget build(BuildContext context) {
    final zone = _currentZone;
    final filteredList = _filteredDispensers;

    return Scaffold(
      bottomNavigationBar: AquaBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          Navigator.of(context).pop();
        },
      ),
      body: AquaBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: AquaColors.turquoise,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zona: ${zone.name}',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AquaColors.textPrimary,
                          ),
                        ),
                        Text(
                          zone.subtitle,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AquaColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  AquaBadge(
                    status: zone.isFullySupplied
                        ? SupplyStatus.supplied
                        : SupplyStatus.pending,
                    customText: zone.isFullySupplied
                        ? 'Abastecida'
                        : 'Faltan ${zone.pendingCount}',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter Tabs & History Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _showHistory
                        ? 'Historial reciente'
                        : 'Despachadores (${zone.totalDispensers})',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AquaColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _showHistory = !_showHistory),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _showHistory
                                ? Icons.view_list_rounded
                                : Icons.history_rounded,
                            size: 16,
                            color: AquaColors.turquoise,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showHistory ? 'Ver despachadores' : 'Ver historial',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AquaColors.turquoise,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (!_showHistory) ...[
                // Filter chips: Todos, Faltan abastecer, Abastecidos
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Todos (${zone.totalDispensers})', 'Todos'),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Faltan abastecer (${zone.pendingCount})',
                        'Faltan',
                        accentColor: AquaColors.statusPending,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Abastecidos (${zone.suppliedCount})',
                        'Abastecidos',
                        accentColor: AquaColors.statusSupplied,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Content Area: List of Dispensers OR History
              Expanded(
                child: _showHistory
                    ? _buildHistoryList()
                    : filteredList.isEmpty
                        ? Center(
                            child: Text(
                              'No hay despachadores en esta categoría',
                              style: GoogleFonts.montserrat(
                                color: AquaColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredList.length,
                            separatorBuilder: (_, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = filteredList[index];
                              return _buildDispenserCard(context, item, zone.name);
                            },
                          ),
              ),
            ],
          ),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
                    color: (accentColor ?? AquaColors.turquoise).withValues(alpha: 0.25),
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
            color: isSelected
                ? Colors.white
                : AquaColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildDispenserCard(
    BuildContext context,
    DispenserItem dispenser,
    String zoneName,
  ) {
    final isSupplied = dispenser.isSupplied;

    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      backgroundColor: isSupplied
          ? Colors.white.withValues(alpha: 0.85)
          : AquaColors.statusPendingBg.withValues(alpha: 0.12),
      borderColor: isSupplied
          ? AquaColors.platinum
          : AquaColors.statusPending.withValues(alpha: 0.4),
      onTap: () {
        _showDispenserDetailsModal(context, dispenser, zoneName);
      },
      child: Row(
        children: [
          // Dispenser Icon / Circle
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

          // Details: ID, Model, Last Info / Alert
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
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '• ${dispenser.brand} ${dispenser.model}',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
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
                      : dispenser.alertMessage.isNotEmpty
                          ? dispenser.alertMessage
                          : 'Falta abastecer',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: isSupplied ? FontWeight.w500 : FontWeight.w600,
                    color: isSupplied
                        ? AquaColors.textMuted
                        : AquaColors.statusPending,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Status Badge
          AquaBadge(
            status: isSupplied ? SupplyStatus.supplied : SupplyStatus.pending,
            customText: isSupplied ? 'Abastecido' : 'Falta',
          ),
          const SizedBox(width: 2),

          // Options menu (Editar / Eliminar)
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.more_vert_rounded,
              size: 18,
              color: AquaColors.slateBlue,
            ),
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AquaColors.platinum),
            ),
            onSelected: (value) async {
              if (value == 'supply') {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DispenserDetailScreen(
                      dispenserId: dispenser.id,
                      pointName: zoneName,
                      brand: dispenser.brand,
                      model: dispenser.model,
                      serialNumber: dispenser.serialNumber,
                      isSupplied: dispenser.isSupplied,
                      alertMessage: dispenser.alertMessage,
                    ),
                  ),
                );
                setState(() {});
              } else if (value == 'edit') {
                _showEditDispenserModal(context, dispenser, zoneName);
              } else if (value == 'delete') {
                _confirmDeleteDispenser(context, dispenser, zoneName);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'supply',
                child: Row(
                  children: [
                    Icon(
                      dispenser.isSupplied ? Icons.sync_rounded : Icons.water_drop_rounded,
                      size: 16,
                      color: AquaColors.turquoise,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      dispenser.isSupplied ? 'Reabastecer' : 'Abastecer',
                      style: GoogleFonts.montserrat(
                        color: AquaColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 16, color: AquaColors.turquoise),
                    const SizedBox(width: 10),
                    Text(
                      'Editar',
                      style: GoogleFonts.montserrat(
                        color: AquaColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded, size: 16, color: AquaColors.statusError),
                    const SizedBox(width: 10),
                    Text(
                      'Eliminar',
                      style: GoogleFonts.montserrat(
                        color: AquaColors.statusError,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDispenserDetailsModal(
    BuildContext context,
    DispenserItem dispenser,
    String zoneName,
  ) {
    final isSupplied = dispenser.isSupplied;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            boxShadow: [
              BoxShadow(
                color: AquaColors.shadowFloat,
                blurRadius: 24,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top drag indicator
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AquaColors.platinum,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Header with Dispenser ID, Zone, and Badge
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSupplied
                            ? AquaColors.statusSuppliedBg
                            : AquaColors.statusPendingBg,
                        border: Border.all(
                          color: isSupplied
                              ? AquaColors.statusSuppliedBorder
                              : AquaColors.statusPendingBorder,
                        ),
                      ),
                      child: Icon(
                        isSupplied
                            ? Icons.water_drop_rounded
                            : Icons.warning_amber_rounded,
                        color: isSupplied
                            ? AquaColors.statusSupplied
                            : AquaColors.statusPending,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Despachador ${dispenser.id}',
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AquaColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Zona $zoneName',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AquaColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AquaBadge(
                      status: isSupplied ? SupplyStatus.supplied : SupplyStatus.pending,
                      customText: isSupplied ? 'Abastecido' : 'Falta abastecer',
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Technical details
                GlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    children: [
                      _buildModalRow('Área / Zona:', zoneName),
                      const Divider(color: AquaColors.platinum, height: 16),
                      _buildModalRow('Marca:', dispenser.brand),
                      const Divider(color: AquaColors.platinum, height: 16),
                      _buildModalRow('Modelo:', dispenser.model),
                      const Divider(color: AquaColors.platinum, height: 16),
                      _buildModalRow('Número de Serie:', dispenser.serialNumber),
                      const Divider(color: AquaColors.platinum, height: 16),
                      _buildModalRow(
                        'Estado del equipo:',
                        isSupplied ? 'Abastecido' : 'Falta abastecer',
                        valueColor: isSupplied
                            ? AquaColors.statusSupplied
                            : AquaColors.statusPending,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Supply status card
                GlassCard(
                  borderRadius: 14,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  backgroundColor: isSupplied
                      ? Colors.white
                      : AquaColors.statusPendingBg.withValues(alpha: 0.12),
                  borderColor: isSupplied
                      ? AquaColors.platinum
                      : AquaColors.statusPending.withValues(alpha: 0.35),
                  child: Row(
                    children: [
                      Icon(
                        isSupplied
                            ? Icons.schedule_rounded
                            : Icons.error_outline_rounded,
                        color: isSupplied
                            ? AquaColors.turquoise
                            : AquaColors.statusPending,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSupplied
                                  ? 'Último abastecimiento'
                                  : 'Alerta operativa',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSupplied
                                    ? AquaColors.turquoise
                                    : AquaColors.statusPending,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isSupplied
                                  ? dispenser.lastSupplyInfo
                                  : (dispenser.alertMessage.isNotEmpty
                                      ? dispenser.alertMessage
                                      : 'Requiere abastecimiento'),
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AquaColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Primary Action: Abastecer / Reabastecer con firma
                AquaButton(
                  text: isSupplied ? 'Reabastecer en ronda' : 'Abastecer despachador',
                  icon: isSupplied ? Icons.sync_rounded : Icons.water_drop_rounded,
                  height: 48,
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DispenserDetailScreen(
                          dispenserId: dispenser.id,
                          pointName: zoneName,
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
                ),
                const SizedBox(height: 12),

                // Action Buttons: Editar & Eliminar
                Row(
                  children: [
                    Expanded(
                      child: AquaButton(
                        text: 'Editar',
                        icon: Icons.edit_outlined,
                        type: AquaButtonType.secondary,
                        height: 48,
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _showEditDispenserModal(context, dispenser, zoneName);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AquaButton(
                        text: 'Eliminar',
                        icon: Icons.delete_outline_rounded,
                        type: AquaButtonType.danger,
                        height: 48,
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _confirmDeleteDispenser(context, dispenser, zoneName);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Close action button
                AquaButton(
                  text: 'Cerrar',
                  type: AquaButtonType.secondary,
                  height: 48,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteDispenser(
    BuildContext context,
    DispenserItem dispenser,
    String zoneName,
  ) {
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
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AquaColors.statusErrorBg,
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: AquaColors.statusError,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Eliminar Despachador',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AquaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '¿Estás seguro de que deseas eliminar el despachador ${dispenser.id} (${dispenser.brand} ${dispenser.model}) de la zona $zoneName?\n\nEsta acción no se puede deshacer.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: AquaColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: AquaButton(
                        text: 'Cancelar',
                        type: AquaButtonType.secondary,
                        height: 48,
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AquaButton(
                        text: 'Eliminar',
                        type: AquaButtonType.danger,
                        height: 48,
                        onPressed: () {
                          Navigator.of(dialogCtx).pop();
                          final success = deleteDispenser(zoneName, dispenser.id);
                          if (success) {
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
                                      'Despachador ${dispenser.id} eliminado',
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

  void _showEditDispenserModal(
    BuildContext context,
    DispenserItem dispenser,
    String currentZoneName,
  ) {
    final formKey = GlobalKey<FormState>();
    final idController = TextEditingController(text: dispenser.id);
    final brandController = TextEditingController(text: dispenser.brand);
    final modelController = TextEditingController(text: dispenser.model);
    final serialController = TextEditingController(text: dispenser.serialNumber);
    final alertController = TextEditingController(text: dispenser.alertMessage);

    String selectedZone = currentZoneName;
    bool isSupplied = dispenser.isSupplied;

    final List<String> availableZones = [
      'Producción',
      'Almacén',
      'Taller',
      'Oficinas',
      'Mantenimiento',
      'Calidad',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (editCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(editCtx).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.88,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                  boxShadow: [
                    BoxShadow(
                      color: AquaColors.shadowFloat,
                      blurRadius: 24,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 38,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AquaColors.platinum,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Editar Despachador',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AquaColors.textPrimary,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: AquaColors.textSecondary, size: 20),
                                onPressed: () => Navigator.of(editCtx).pop(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // ID / Número
                          _buildInputLabel('Número / Código:'),
                          TextFormField(
                            controller: idController,
                            style: GoogleFonts.montserrat(
                              color: AquaColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDecoration('Ej. #023'),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el código' : null,
                          ),
                          const SizedBox(height: 12),

                          // Zona
                          _buildInputLabel('Zona / Área:'),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AquaColors.platinum),
                            ),
                            child: DropdownButtonFormField<String>(
                              initialValue: availableZones.contains(selectedZone) ? selectedZone : availableZones.first,
                              dropdownColor: Colors.white,
                              style: GoogleFonts.montserrat(
                                color: AquaColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              items: availableZones.map((z) {
                                return DropdownMenuItem(value: z, child: Text(z));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setModalState(() => selectedZone = val);
                              },
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Marca
                          _buildInputLabel('Marca:'),
                          TextFormField(
                            controller: brandController,
                            style: GoogleFonts.montserrat(
                              color: AquaColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDecoration('Ej. EcoWater, Oasis'),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa la marca' : null,
                          ),
                          const SizedBox(height: 12),

                          // Modelo
                          _buildInputLabel('Modelo:'),
                          TextFormField(
                            controller: modelController,
                            style: GoogleFonts.montserrat(
                              color: AquaColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDecoration('Ej. E-200, Titan 50'),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el modelo' : null,
                          ),
                          const SizedBox(height: 12),

                          // Serie
                          _buildInputLabel('Número de Serie:'),
                          TextFormField(
                            controller: serialController,
                            style: GoogleFonts.montserrat(
                              color: AquaColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDecoration('Ej. SN123456'),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa la serie' : null,
                          ),
                          const SizedBox(height: 14),

                          // Estado selector
                          _buildInputLabel('Estado de abastecimiento:'),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setModalState(() => isSupplied = true),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSupplied
                                          ? AquaColors.statusSuppliedBg
                                          : AquaColors.glacier.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSupplied
                                            ? AquaColors.statusSupplied
                                            : AquaColors.platinum,
                                        width: 1.2,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          size: 16,
                                          color: isSupplied ? AquaColors.statusSupplied : AquaColors.textMuted,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Abastecido',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            fontWeight: isSupplied ? FontWeight.w700 : FontWeight.w500,
                                            color: isSupplied ? AquaColors.statusSupplied : AquaColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: InkWell(
                                  onTap: () => setModalState(() => isSupplied = false),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: !isSupplied
                                          ? AquaColors.statusPendingBg
                                          : AquaColors.glacier.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: !isSupplied
                                            ? AquaColors.statusPending
                                            : AquaColors.platinum,
                                        width: 1.2,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          size: 16,
                                          color: !isSupplied ? AquaColors.statusPending : AquaColors.textMuted,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Falta abastecer',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            fontWeight: !isSupplied ? FontWeight.w700 : FontWeight.w500,
                                            color: !isSupplied ? AquaColors.statusPending : AquaColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (!isSupplied) ...[
                            _buildInputLabel('Alerta / Motivo de falta:'),
                            TextFormField(
                              controller: alertController,
                              style: GoogleFonts.montserrat(
                                color: AquaColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: _inputDecoration('Ej. Nivel bajo, Garrafón vacío'),
                            ),
                            const SizedBox(height: 12),
                          ],

                          const SizedBox(height: 16),
                          AquaButton(
                            text: 'Guardar cambios',
                            icon: Icons.save_outlined,
                            onPressed: () {
                              if (formKey.currentState?.validate() ?? false) {
                                final updated = dispenser.copyWith(
                                  id: idController.text.trim(),
                                  brand: brandController.text.trim(),
                                  model: modelController.text.trim(),
                                  serialNumber: serialController.text.trim(),
                                  status: isSupplied ? DispenserStatus.supplied : DispenserStatus.pending,
                                  alertMessage: isSupplied ? '' : alertController.text.trim(),
                                  lastSupplyInfo: isSupplied ? 'Actualizado hoy' : dispenser.lastSupplyInfo,
                                );

                                updateDispenser(
                                  currentZoneName: currentZoneName,
                                  currentDispenserId: dispenser.id,
                                  updatedItem: updated,
                                  targetZoneName: selectedZone,
                                );

                                Navigator.of(editCtx).pop();
                                setState(() {});

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AquaColors.turquoise,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Despachador ${updated.id} guardado con éxito',
                                          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          AquaButton(
                            text: 'Cancelar',
                            type: AquaButtonType.secondary,
                            onPressed: () => Navigator.of(editCtx).pop(),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AquaColors.textSecondary,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.montserrat(color: AquaColors.textMuted, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AquaColors.platinum),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AquaColors.platinum),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AquaColors.turquoise, width: 1.5),
      ),
    );
  }

  Widget _buildModalRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AquaColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AquaColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return ListView.separated(
      itemCount: _recentHistory.length,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _recentHistory[index];
        return GlassCard(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AquaColors.glacier.withValues(alpha: 0.5),
                  border: Border.all(color: AquaColors.slateBlue.withValues(alpha: 0.3)),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: AquaColors.turquoise,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['date'] as String,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AquaColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['user'] as String,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AquaColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${item['bottles']} garrafones',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AquaColors.turquoise,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
