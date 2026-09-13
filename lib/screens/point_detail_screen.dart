import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_badge.dart';
import '../widgets/aqua_button.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/glass_card.dart';

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
                      color: AquaColors.icyBlue,
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
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          zone.subtitle,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
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
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
                            color: AquaColors.icyBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showHistory ? 'Ver despachadores' : 'Ver historial',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AquaColors.icyBlue,
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (accentColor?.withValues(alpha: 0.25) ?? AquaColors.cornflowerBlue)
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
          ? const Color(0x1F1E3166)
          : const Color(0x2E4A2828), // Subtle alert hue if pending
      borderColor: isSupplied
          ? AquaColors.glassBorderSubtle
          : AquaColors.statusPending.withValues(alpha: 0.35),
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
                  ? const Color(0x28496EC7)
                  : AquaColors.statusPending.withValues(alpha: 0.2),
            ),
            child: Icon(
              isSupplied
                  ? Icons.water_drop_outlined
                  : Icons.warning_amber_rounded,
              color: isSupplied
                  ? AquaColors.icyBlue
                  : AquaColors.statusPending,
              size: 19,
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
                    Text(
                      'Despachador ${dispenser.id}',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '• ${dispenser.brand} ${dispenser.model}',
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
                      : dispenser.alertMessage.isNotEmpty
                          ? dispenser.alertMessage
                          : 'Falta abastecer',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: isSupplied ? FontWeight.w400 : FontWeight.w500,
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
              color: AquaColors.textMuted,
            ),
            color: const Color(0xFF16254A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AquaColors.glassBorderSubtle),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditDispenserModal(context, dispenser, zoneName);
              } else if (value == 'delete') {
                _confirmDeleteDispenser(context, dispenser, zoneName);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 16, color: AquaColors.icyBlue),
                    const SizedBox(width: 10),
                    Text(
                      'Editar',
                      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFE55353)),
                    const SizedBox(width: 10),
                    Text(
                      'Eliminar',
                      style: GoogleFonts.montserrat(color: const Color(0xFFE55353), fontSize: 13),
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
            color: Color(0xFF132247),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            border: Border(
              top: BorderSide(color: Color(0x334468C7), width: 1),
              left: BorderSide(color: Color(0x334468C7), width: 1),
              right: BorderSide(color: Color(0x334468C7), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: Offset(0, -4),
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
                      color: Colors.white.withValues(alpha: 0.3),
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
                            ? const Color(0x28496EC7)
                            : AquaColors.statusPending.withValues(alpha: 0.2),
                      ),
                      child: Icon(
                        isSupplied
                            ? Icons.water_drop_outlined
                            : Icons.warning_amber_rounded,
                        color: isSupplied
                            ? AquaColors.icyBlue
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
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Zona $zoneName',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
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
                  backgroundColor: const Color(0x2820356C),
                  borderColor: AquaColors.glassBorderSubtle,
                  child: Column(
                    children: [
                      _buildModalRow('Área / Zona:', zoneName),
                      const Divider(color: Color(0x1AFFFFFF), height: 16),
                      _buildModalRow('Marca:', dispenser.brand),
                      const Divider(color: Color(0x1AFFFFFF), height: 16),
                      _buildModalRow('Modelo:', dispenser.model),
                      const Divider(color: Color(0x1AFFFFFF), height: 16),
                      _buildModalRow('Número de Serie:', dispenser.serialNumber),
                      const Divider(color: Color(0x1AFFFFFF), height: 16),
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
                      ? const Color(0x1F1E3166)
                      : const Color(0x2E4A2828),
                  borderColor: isSupplied
                      ? AquaColors.glassBorderSubtle
                      : AquaColors.statusPending.withValues(alpha: 0.35),
                  child: Row(
                    children: [
                      Icon(
                        isSupplied
                            ? Icons.schedule_rounded
                            : Icons.error_outline_rounded,
                        color: isSupplied
                            ? AquaColors.icyBlue
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
                                fontWeight: FontWeight.w600,
                                color: isSupplied
                                    ? AquaColors.icyBlue
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
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

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
            backgroundColor: const Color(0xFF132247),
            borderColor: const Color(0xFFE55353).withValues(alpha: 0.35),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE55353).withValues(alpha: 0.15),
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: Color(0xFFE55353),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Eliminar Despachador',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
                                backgroundColor: const Color(0xFF1E3166),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: AquaColors.statusSupplied,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Despachador ${dispenser.id} eliminado',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 13,
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
                  color: Color(0xFF132247),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                  border: Border(
                    top: BorderSide(color: Color(0x334468C7), width: 1),
                    left: BorderSide(color: Color(0x334468C7), width: 1),
                    right: BorderSide(color: Color(0x334468C7), width: 1),
                  ),
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
                                color: Colors.white.withValues(alpha: 0.3),
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
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: AquaColors.icyBlue, size: 20),
                                onPressed: () => Navigator.of(editCtx).pop(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // ID / Número
                          _buildInputLabel('Número / Código:'),
                          TextFormField(
                            controller: idController,
                            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13),
                            decoration: _inputDecoration('Ej. #023'),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el código' : null,
                          ),
                          const SizedBox(height: 12),

                          // Zona
                          _buildInputLabel('Zona / Área:'),
                          DropdownButtonFormField<String>(
                            initialValue: availableZones.contains(selectedZone) ? selectedZone : availableZones.first,
                            dropdownColor: const Color(0xFF192C59),
                            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13),
                            decoration: _inputDecoration(''),
                            items: availableZones.map((z) {
                              return DropdownMenuItem(value: z, child: Text(z));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setModalState(() => selectedZone = val);
                            },
                          ),
                          const SizedBox(height: 12),

                          // Marca
                          _buildInputLabel('Marca:'),
                          TextFormField(
                            controller: brandController,
                            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13),
                            decoration: _inputDecoration('Ej. EcoWater, Oasis'),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa la marca' : null,
                          ),
                          const SizedBox(height: 12),

                          // Modelo
                          _buildInputLabel('Modelo:'),
                          TextFormField(
                            controller: modelController,
                            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13),
                            decoration: _inputDecoration('Ej. E-200, Titan 50'),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el modelo' : null,
                          ),
                          const SizedBox(height: 12),

                          // Serie
                          _buildInputLabel('Número de Serie:'),
                          TextFormField(
                            controller: serialController,
                            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13),
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
                                          : const Color(0x1F20356C),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSupplied
                                            ? AquaColors.statusSupplied
                                            : AquaColors.glassBorderSubtle,
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
                                            fontWeight: isSupplied ? FontWeight.w600 : FontWeight.w400,
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
                                          : const Color(0x1F20356C),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: !isSupplied
                                            ? AquaColors.statusPending
                                            : AquaColors.glassBorderSubtle,
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
                                            fontWeight: !isSupplied ? FontWeight.w600 : FontWeight.w400,
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
                              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13),
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
                                    backgroundColor: const Color(0xFF1E3166),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: AquaColors.statusSupplied, size: 20),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Despachador ${updated.id} guardado con éxito',
                                          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13),
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
          fontWeight: FontWeight.w500,
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
      fillColor: const Color(0x2820356C),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AquaColors.glassBorderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AquaColors.glassBorderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AquaColors.cornflowerBlue, width: 1.5),
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
            color: AquaColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.white,
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
          backgroundColor: const Color(0x201F356B),
          borderColor: AquaColors.glassBorderSubtle,
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x284468C7),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: AquaColors.icyBlue,
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
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['user'] as String,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
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
                  color: AquaColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
