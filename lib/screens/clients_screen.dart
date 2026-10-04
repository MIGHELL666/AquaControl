import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String _searchQuery = '';
  String _statusFilter = 'Todos'; // 'Todos', 'Activos', 'Inactivos'

  List<ClientItem> get _filteredClients {
    return kDefaultClients.where((c) {
      if (_statusFilter == 'Activos' && !c.isActive) return false;
      if (_statusFilter == 'Inactivos' && !c.isInactive) return false;

      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return c.companyName.toLowerCase().contains(q) ||
          c.razonSocial.toLowerCase().contains(q) ||
          c.rfc.toLowerCase().contains(q) ||
          c.contactPerson.toLowerCase().contains(q) ||
          c.address.toLowerCase().contains(q) ||
          c.colonia.toLowerCase().contains(q) ||
          c.ciudad.toLowerCase().contains(q) ||
          c.assignedDispenserIds.any((id) => id.toLowerCase().contains(q));
    }).toList();
  }

  /// Selector modal interactivo para elegir qué despachadores se asignan a este cliente
  Future<List<String>?> _showDispenserPicker({
    required BuildContext context,
    required List<String> currentSelected,
    required String currentClientId,
  }) async {
    final allEntries = getAllDispensersWithZone();
    List<String> tempSelected = List.from(currentSelected);
    String filterZone = 'Todas';
    String search = '';

    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setPickerState) {
          final zones = ['Todas', ...kDefaultZones.map((z) => z.name)];

          final filteredDispensers = allEntries.where((entry) {
            if (filterZone != 'Todas' && entry.zoneName != filterZone) {
              return false;
            }
            if (search.trim().isNotEmpty) {
              final q = search.trim().toLowerCase();
              final matchesId = entry.dispenser.id.toLowerCase().contains(q);
              final matchesBrand =
                  entry.dispenser.brand.toLowerCase().contains(q);
              final matchesModel =
                  entry.dispenser.model.toLowerCase().contains(q);
              final matchesZone = entry.zoneName.toLowerCase().contains(q);
              return matchesId || matchesBrand || matchesModel || matchesZone;
            }
            return true;
          }).toList();

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(modalCtx).size.height * 0.85,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: AquaColors.shadowFloat,
                  blurRadius: 24,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AquaColors.platinum,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seleccionar Despachadores',
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AquaColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Elige cuáles despachadores estarán asignados a esta empresa',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: AquaColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          size: 20, color: AquaColors.textSecondary),
                      onPressed: () => Navigator.of(modalCtx).pop(null),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Buscador de despachadores
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: AquaColors.iceBlue.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AquaColors.platinum),
                  ),
                  child: TextField(
                    onChanged: (val) => setPickerState(() => search = val),
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AquaColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded,
                          size: 18, color: AquaColors.turquoise),
                      hintText: 'Buscar por ID (#023), marca o zona...',
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: AquaColors.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Filtro horizontal por zona
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: zones.map((zone) {
                      final isSel = filterZone == zone;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text(
                            zone,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight:
                                  isSel ? FontWeight.w700 : FontWeight.w500,
                              color:
                                  isSel ? Colors.white : AquaColors.textPrimary,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: AquaColors.turquoise,
                          backgroundColor:
                              AquaColors.glacier.withValues(alpha: 0.3),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          onSelected: (_) =>
                              setPickerState(() => filterZone = zone),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),

                // Acciones rápidas (seleccionar todos / desmarcar)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${tempSelected.length} de ${allEntries.length} asignados',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AquaColors.turquoise,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        setPickerState(() {
                          for (final e in filteredDispensers) {
                            if (!tempSelected.contains(e.dispenser.id)) {
                              tempSelected.add(e.dispenser.id);
                            }
                          }
                        });
                      },
                      child: Text(
                        'Todos visibles',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AquaColors.slateBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        setPickerState(() => tempSelected.clear());
                      },
                      child: Text(
                        'Limpiar',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AquaColors.statusError,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 1, color: AquaColors.platinum),
                const SizedBox(height: 8),

                // Lista de despachadores disponibles
                Expanded(
                  child: filteredDispensers.isEmpty
                      ? Center(
                          child: Text(
                            'No se encontraron despachadores con ese criterio.',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: AquaColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredDispensers.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 6),
                          itemBuilder: (context, idx) {
                            final entry = filteredDispensers[idx];
                            final disp = entry.dispenser;
                            final isChecked = tempSelected.contains(disp.id);

                            // Verificar si está asignado a otro cliente actualmente
                            final currentOwner = getClientForDispenser(disp.id);
                            final isOtherClient = currentOwner != null &&
                                currentOwner.id != currentClientId;

                            return InkWell(
                              onTap: () {
                                setPickerState(() {
                                  if (isChecked) {
                                    tempSelected.remove(disp.id);
                                  } else {
                                    tempSelected.add(disp.id);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 9),
                                decoration: BoxDecoration(
                                  color: isChecked
                                      ? AquaColors.turquoise
                                          .withValues(alpha: 0.08)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isChecked
                                        ? AquaColors.turquoise
                                        : AquaColors.platinum,
                                    width: isChecked ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isChecked
                                          ? Icons.check_box_rounded
                                          : Icons.check_box_outline_blank_rounded,
                                      color: isChecked
                                          ? AquaColors.turquoise
                                          : AquaColors.textMuted,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AquaColors.glacier
                                            .withValues(alpha: 0.5),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        disp.id,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AquaColors.turquoise,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${disp.brand} • ${disp.model}',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AquaColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Text(
                                                'Zona: ${entry.zoneName}',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 10,
                                                  color:
                                                      AquaColors.textSecondary,
                                                ),
                                              ),
                                              if (isOtherClient) ...[
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6,
                                                        vertical: 1),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amber
                                                          .withValues(
                                                              alpha: 0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Text(
                                                      'Asignado a: ${currentOwner.companyName}',
                                                      style:
                                                          GoogleFonts.montserrat(
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors
                                                            .amber.shade900,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: disp.isSupplied
                                            ? AquaColors.statusSupplied
                                                .withValues(alpha: 0.15)
                                            : AquaColors.statusPending
                                                .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        disp.isSupplied
                                            ? '${disp.bottleCount} garr.'
                                            : 'Pendiente',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: disp.isSupplied
                                              ? AquaColors.statusSupplied
                                              : AquaColors.statusPending,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),

                // Botón Guardar selección
                AquaButton(
                  text: 'Confirmar selección (${tempSelected.length} despachadores)',
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: () => Navigator.of(modalCtx).pop(tempSelected),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Formulario de agregar / editar cliente con segmentación completa de dirección y selección de despachadores
  void _showAddClientDialog({ClientItem? existingClient}) {
    final isEdit = existingClient != null;

    // Controladores de campos fiscales y comerciales
    final nameCtrl =
        TextEditingController(text: existingClient?.companyName ?? '');
    final razonSocialCtrl =
        TextEditingController(text: existingClient?.razonSocial ?? '');
    final rfcCtrl = TextEditingController(text: existingClient?.rfc ?? '');

    // Controladores de contacto y precios
    final contactCtrl =
        TextEditingController(text: existingClient?.contactPerson ?? '');
    final phoneCtrl = TextEditingController(text: existingClient?.phone ?? '');
    final emailCtrl = TextEditingController(text: existingClient?.email ?? '');
    final priceCtrl = TextEditingController(
      text: existingClient != null
          ? existingClient.pricePerBottle.toStringAsFixed(2)
          : '35.00',
    );

    // Controladores de dirección segmentada (Requerimiento 1)
    final domicilioCtrl =
        TextEditingController(text: existingClient?.domicilio ?? '');
    final calleCtrl = TextEditingController(text: existingClient?.calle ?? '');
    final numeroCtrl =
        TextEditingController(text: existingClient?.numero ?? '');
    final cpCtrl = TextEditingController(text: existingClient?.cp ?? '');
    final coloniaCtrl =
        TextEditingController(text: existingClient?.colonia ?? '');
    final ciudadCtrl =
        TextEditingController(text: existingClient?.ciudad ?? '');
    final paisCtrl =
        TextEditingController(text: existingClient?.pais ?? 'México');
    final notesCtrl = TextEditingController(text: existingClient?.notes ?? '');

    // Frecuencia, despachadores y estado
    String selectedFrequency = existingClient?.deliveryFrequency ?? 'Semanal';
    String selectedStatus = existingClient?.status ?? 'Activo';
    List<String> assignedDispensers =
        List.from(existingClient?.assignedDispenserIds ?? []);
    String? formError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: AquaColors.shadowFloat,
                    blurRadius: 24,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              constraints: BoxConstraints(
                maxWidth: 680,
                maxHeight: MediaQuery.of(modalCtx).size.height * 0.90,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AquaColors.platinum,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isEdit
                                ? 'Editar Empresa Cliente'
                                : 'Registrar Nueva Empresa Cliente',
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AquaColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: AquaColors.textSecondary, size: 20),
                          onPressed: () => Navigator.of(modalCtx).pop(),
                        ),
                      ],
                    ),
                    Text(
                      isEdit
                          ? 'Actualiza los datos fiscales, domicilio y despachadores'
                          : 'Registra los datos de la empresa, dirección desglosada y sus despachadores',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AquaColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── SECCIÓN 1: Identificación y Datos Fiscales ──
                    _buildSectionHeader(
                      title: 'Identificación y Datos Fiscales',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: nameCtrl,
                      label: 'Nombre comercial / Empresa *',
                      hint: 'Ej. Grupo Bimbo Planta Norte',
                      icon: Icons.business_rounded,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildTextField(
                            controller: razonSocialCtrl,
                            label: 'Razón Social',
                            hint: 'Ej. Grupo Bimbo S.A.B. de C.V.',
                            icon: Icons.domain_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: rfcCtrl,
                            label: 'RFC',
                            hint: 'BIM900101XYZ',
                            icon: Icons.receipt_long_rounded,
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── SECCIÓN 2: Dirección y Domicilio Segmentado (Requerimiento 1) ──
                    _buildSectionHeader(
                      title: 'Dirección y Domicilio',
                      icon: Icons.location_on_outlined,
                      subtitle:
                          'Segmentación: domicilio, calle, número, CP, colonia, ciudad y país',
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: domicilioCtrl,
                      label: 'Domicilio / Referencia de instalación',
                      hint: 'Ej. Planta de producción norte, Nave 4, caseta 2',
                      icon: Icons.apartment_rounded,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildTextField(
                            controller: calleCtrl,
                            label: 'Calle',
                            hint: 'Ej. Parque Industrial Las Américas',
                            icon: Icons.add_road_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: numeroCtrl,
                            label: 'Número (Ext/Int)',
                            hint: 'Ej. #140 Nave B',
                            icon: Icons.tag_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildTextField(
                            controller: coloniaCtrl,
                            label: 'Colonia',
                            hint: 'Ej. Las Américas',
                            icon: Icons.holiday_village_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: cpCtrl,
                            label: 'Código Postal (CP)',
                            hint: 'Ej. 01210',
                            icon: Icons.markunread_mailbox_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: ciudadCtrl,
                            label: 'Ciudad',
                            hint: 'Ej. Ciudad de México',
                            icon: Icons.location_city_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: paisCtrl,
                            label: 'País',
                            hint: 'México',
                            icon: Icons.flag_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── SECCIÓN 3: Contacto y Condiciones Comerciales ──
                    _buildSectionHeader(
                      title: 'Contacto y Operación',
                      icon: Icons.contact_phone_outlined,
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: contactCtrl,
                      label: 'Persona de contacto / Enlace',
                      hint: 'Ej. Lic. Fernando Garza',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: phoneCtrl,
                            label: 'Teléfono',
                            hint: '55 1234 5678',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: priceCtrl,
                            label: 'Precio / garrafón (\$)',
                            hint: '35.00',
                            icon: Icons.attach_money_rounded,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: emailCtrl,
                      label: 'Correo electrónico',
                      hint: 'contacto@empresa.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),

                    // Frecuencia
                    Text(
                      'Frecuencia de abastecimiento',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AquaColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        'Diario',
                        'Cada 2 días',
                        'Semanal',
                        'Quincenal'
                      ].map((freq) {
                        final isSel = selectedFrequency == freq;
                        return ChoiceChip(
                          label: Text(
                            freq,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color:
                                  isSel ? Colors.white : AquaColors.textPrimary,
                              fontWeight:
                                  isSel ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: AquaColors.turquoise,
                          backgroundColor:
                              AquaColors.glacier.withValues(alpha: 0.4),
                          side: BorderSide(
                            color: isSel
                                ? AquaColors.turquoise
                                : AquaColors.platinum,
                          ),
                          onSelected: (_) =>
                              setModalState(() => selectedFrequency = freq),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // ── SECCIÓN 4: Despachadores Asignados (Requerimiento 4) ──
                    _buildSectionHeader(
                      title: 'Despachadores Asignados',
                      icon: Icons.water_drop_rounded,
                      subtitle:
                          'Elige exactamente qué despachador tendrá este cliente',
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AquaColors.iceBlue.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AquaColors.glassBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${assignedDispensers.length} despachador${assignedDispensers.length == 1 ? '' : 'es'} asignado${assignedDispensers.length == 1 ? '' : 's'}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AquaColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      assignedDispensers.isEmpty
                                          ? 'Ningún despachador asignado'
                                          : 'Seleccionados del catálogo',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        color: AquaColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AquaColors.turquoise,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.touch_app_rounded,
                                    size: 15),
                                label: Text(
                                  assignedDispensers.isEmpty
                                      ? 'Elegir despachador'
                                      : 'Modificar lista',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                onPressed: () async {
                                  final result = await _showDispenserPicker(
                                    context: context,
                                    currentSelected: assignedDispensers,
                                    currentClientId: existingClient?.id ?? '',
                                  );
                                  if (result != null) {
                                    setModalState(() {
                                      assignedDispensers = result;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          if (assignedDispensers.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: assignedDispensers.map((dispId) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: AquaColors.platinum),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.water_drop_rounded,
                                          size: 13,
                                          color: AquaColors.turquoise),
                                      const SizedBox(width: 4),
                                      Text(
                                        dispId,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AquaColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap: () {
                                          setModalState(() {
                                            assignedDispensers.remove(dispId);
                                          });
                                        },
                                        child: const Icon(
                                          Icons.close_rounded,
                                          size: 14,
                                          color: AquaColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── SECCIÓN 5: Estado del Cliente (Requerimiento 2) ──
                    _buildSectionHeader(
                      title: 'Estado de la Cuenta',
                      icon: Icons.toggle_on_outlined,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                setModalState(() => selectedStatus = 'Activo'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedStatus == 'Activo'
                                    ? AquaColors.statusSupplied
                                        .withValues(alpha: 0.15)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedStatus == 'Activo'
                                      ? AquaColors.statusSupplied
                                      : AquaColors.platinum,
                                  width: selectedStatus == 'Activo' ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 16,
                                    color: selectedStatus == 'Activo'
                                        ? AquaColors.statusSupplied
                                        : AquaColors.textMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Activo',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: selectedStatus == 'Activo'
                                          ? AquaColors.statusSupplied
                                          : AquaColors.textPrimary,
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
                            onTap: () => setModalState(
                                () => selectedStatus = 'Inactivo'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedStatus == 'Inactivo'
                                    ? Colors.amber.withValues(alpha: 0.18)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedStatus == 'Inactivo'
                                      ? Colors.amber.shade800
                                      : AquaColors.platinum,
                                  width: selectedStatus == 'Inactivo' ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.pause_circle_filled_rounded,
                                    size: 16,
                                    color: selectedStatus == 'Inactivo'
                                        ? Colors.amber.shade900
                                        : AquaColors.textMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Inactivo',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: selectedStatus == 'Inactivo'
                                          ? Colors.amber.shade900
                                          : AquaColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Notas
                    _buildTextField(
                      controller: notesCtrl,
                      label: 'Notas adicionales (opcional)',
                      hint: 'Horarios de acceso, caseta o contacto en almacén...',
                      icon: Icons.notes_rounded,
                      maxLines: 2,
                    ),

                    if (formError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        formError!,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AquaColors.statusError,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    AquaButton(
                      text: isEdit
                          ? 'Guardar cambios'
                          : 'Guardar empresa cliente',
                      icon: isEdit
                          ? Icons.save_rounded
                          : Icons.check_circle_outline_rounded,
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        final razonSocial = razonSocialCtrl.text.trim();
                        final rfc = rfcCtrl.text.trim();
                        final contact = contactCtrl.text.trim();
                        final phone = phoneCtrl.text.trim();
                        final email = emailCtrl.text.trim();
                        final domicilio = domicilioCtrl.text.trim();
                        final calle = calleCtrl.text.trim();
                        final numero = numeroCtrl.text.trim();
                        final cp = cpCtrl.text.trim();
                        final colonia = coloniaCtrl.text.trim();
                        final ciudad = ciudadCtrl.text.trim();
                        final pais = paisCtrl.text.trim().isEmpty
                            ? 'México'
                            : paisCtrl.text.trim();
                        final priceVal = double.tryParse(
                              priceCtrl.text.trim().replaceAll(',', '.'),
                            ) ??
                            35.0;

                        if (name.isEmpty) {
                          setModalState(() =>
                              formError = 'Ingresa el nombre de la empresa.');
                          return;
                        }

                        // Formatear dirección completa compuesta
                        final addressParts = <String>[];
                        if (calle.isNotEmpty || numero.isNotEmpty) {
                          addressParts.add('$calle $numero'.trim());
                        }
                        if (colonia.isNotEmpty) addressParts.add('Col. $colonia');
                        if (cp.isNotEmpty) addressParts.add('C.P. $cp');
                        if (ciudad.isNotEmpty) addressParts.add(ciudad);
                        if (pais.isNotEmpty && pais != 'México') {
                          addressParts.add(pais);
                        }
                        final computedAddress = addressParts.isNotEmpty
                            ? addressParts.join(', ')
                            : (existingClient?.address ??
                                'Dirección no especificada');

                        final targetId = existingClient?.id ??
                            'CLI-${DateTime.now().millisecondsSinceEpoch % 10000}';

                        final clientModel = ClientItem(
                          id: targetId,
                          companyName: name,
                          razonSocial: razonSocial,
                          rfc: rfc,
                          contactPerson:
                              contact.isEmpty ? 'Contacto general' : contact,
                          phone: phone.isEmpty ? 'Sin teléfono' : phone,
                          email: email.isEmpty ? 'Sin correo' : email,
                          domicilio: domicilio,
                          calle: calle,
                          numero: numero,
                          cp: cp,
                          colonia: colonia,
                          ciudad: ciudad,
                          pais: pais,
                          address: computedAddress,
                          activeDispensers: assignedDispensers.length,
                          assignedDispenserIds: assignedDispensers,
                          deliveryFrequency: selectedFrequency,
                          status: selectedStatus,
                          notes: notesCtrl.text.trim(),
                          pricePerBottle: priceVal,
                        );

                        if (isEdit) {
                          updateClient(clientModel);
                          assignDispensersToClient(
                              targetId, assignedDispensers);
                        } else {
                          addClient(clientModel);
                          assignDispensersToClient(
                              targetId, assignedDispensers);
                        }

                        Navigator.of(modalCtx).pop();
                        setState(() {});

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AquaColors.turquoise,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    isEdit
                                        ? 'Empresa "$name" actualizada correctamente'
                                        : 'Empresa "$name" registrada con ${assignedDispensers.length} despachadores',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Alternar estado entre Activo e Inactivo con confirmación (Requerimiento 2)
  void _confirmToggleStatus(ClientItem client) {
    final willDeactivate = client.isActive;

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
                    color: willDeactivate
                        ? Colors.amber.withValues(alpha: 0.15)
                        : AquaColors.turquoise.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    willDeactivate
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    color: willDeactivate
                        ? Colors.amber.shade900
                        : AquaColors.turquoise,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  willDeactivate ? 'Desactivar cliente' : 'Activar cliente',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AquaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  willDeactivate
                      ? '¿Deseas suspender a "${client.companyName}"?\n\nEl cliente pasará a estado Inactivo y no se programarán abastecimientos para sus despachadores hasta que se reactive.'
                      : '¿Deseas reactivar a "${client.companyName}"?\n\nEl cliente pasará a estado Activo y podrá recibir suministros normalmente.',
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
                        text: willDeactivate ? 'Desactivar' : 'Activar',
                        type: willDeactivate
                            ? AquaButtonType.secondary
                            : AquaButtonType.primary,
                        height: 48,
                        onPressed: () {
                          toggleClientStatus(client.id);
                          Navigator.of(dialogCtx).pop();
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: willDeactivate
                                  ? Colors.amber.shade800
                                  : AquaColors.turquoise,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              content: Text(
                                willDeactivate
                                    ? 'Cliente "${client.companyName}" desactivado'
                                    : 'Cliente "${client.companyName}" activado',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
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

  /// Confirmación de eliminación con protección de movimientos (Requerimiento 2)
  void _confirmDeleteClient(ClientItem client) {
    final movementsCount = getClientSupplyRecordsCount(client);
    final hasMovements = movementsCount > 0;

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
                    color: hasMovements
                        ? Colors.amber.withValues(alpha: 0.15)
                        : AquaColors.statusError.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    hasMovements
                        ? Icons.shield_outlined
                        : Icons.delete_forever_rounded,
                    color: hasMovements
                        ? Colors.amber.shade900
                        : AquaColors.statusError,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  hasMovements
                      ? 'No se puede eliminar'
                      : 'Eliminar cliente permanentemente',
                  style: GoogleFonts.montserrat(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AquaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  hasMovements
                      ? 'El cliente "${client.companyName}" tiene $movementsCount abastecimiento${movementsCount == 1 ? '' : 's'} registrado${movementsCount == 1 ? '' : 's'} en el historial.\n\nPara conservar la trazabilidad y reportes de la purificadora, no puede eliminarse.\n\nPuedes desactivarlo para suspender su operación.'
                      : 'El cliente "${client.companyName}" no cuenta con movimientos registrados en el sistema.\n\n¿Estás seguro de que deseas eliminarlo permanentemente? Esta acción no se puede deshacer.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: AquaColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                if (hasMovements) ...[
                  Row(
                    children: [
                      Expanded(
                        child: AquaButton(
                          text: 'Cerrar',
                          type: AquaButtonType.secondary,
                          height: 48,
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                        ),
                      ),
                      if (client.isActive) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: AquaButton(
                            text: 'Desactivar',
                            type: AquaButtonType.secondary,
                            height: 48,
                            onPressed: () {
                              toggleClientStatus(client.id);
                              Navigator.of(dialogCtx).pop();
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.amber.shade800,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  content: Text(
                                    'Cliente "${client.companyName}" marcado como Inactivo',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ] else ...[
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
                            deleteClient(client.id);
                            Navigator.of(dialogCtx).pop();
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AquaColors.turquoise,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        color: Colors.white, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Cliente eliminado correctamente',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AquaColors.turquoise),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AquaColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              color: AquaColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AquaColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AquaColors.platinum, width: 1.2),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            maxLines: maxLines,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AquaColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AquaColors.turquoise, size: 18),
              hintText: hint,
              hintStyle: GoogleFonts.montserrat(
                fontSize: 12,
                color: AquaColors.textMuted,
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final clients = _filteredClients;
    final activeCount = kDefaultClients.where((c) => c.isActive).length;
    final inactiveCount = kDefaultClients.where((c) => c.isInactive).length;

    return Scaffold(
      body: AquaBackground(
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
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
                            'Clientes y Empresas',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AquaColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Empresas abastecidas y despachadores asignados',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AquaColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AquaColors.glacier.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AquaColors.slateBlue.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '${kDefaultClients.length} Empresas',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AquaColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Search Bar
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AquaColors.platinum),
                    boxShadow: [
                      BoxShadow(
                        color: AquaColors.shadowCard,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AquaColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: AquaColors.turquoise,
                      ),
                      hintText:
                          'Buscar por empresa, RFC, razón social o despachador...',
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 11.5,
                        color: AquaColors.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Filtro de Estado: Todos, Activos, Inactivos (Requerimiento 2)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip('Todos (${kDefaultClients.length})', 'Todos'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Activos ($activeCount)', 'Activos'),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          'Inactivos ($inactiveCount)', 'Inactivos'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Botón Registrar Empresa
                AquaButton(
                  text: 'Registrar nueva empresa cliente',
                  icon: Icons.add_business_rounded,
                  height: 44,
                  onPressed: _showAddClientDialog,
                ),
                const SizedBox(height: 14),

                // Lista de Clientes con RepaintBoundary y scroll elástico fluido
                Expanded(
                  child: clients.isEmpty
                      ? Center(
                          child: Text(
                            'No se encontraron empresas con ese filtro',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AquaColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: clients.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final client = clients[index];
                            final hasMovements =
                                clientHasMovements(client);

                            return RepaintBoundary(
                              child: GlassCard(
                                borderRadius: 16,
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Encabezado de la tarjeta con nombre, estado y menú
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: client.isActive
                                                ? AquaColors.glacier
                                                    .withValues(alpha: 0.6)
                                                : Colors.amber
                                                    .withValues(alpha: 0.15),
                                            border: Border.all(
                                              color: client.isActive
                                                  ? AquaColors.slateBlue
                                                      .withValues(alpha: 0.3)
                                                  : Colors.amber.shade700
                                                      .withValues(alpha: 0.4),
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.business_rounded,
                                            color: client.isActive
                                                ? AquaColors.turquoise
                                                : Colors.amber.shade800,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      client.companyName,
                                                      style:
                                                          GoogleFonts.montserrat(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: AquaColors
                                                            .textPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                  // Badge de estado Activo/Inactivo
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: client.isActive
                                                          ? AquaColors
                                                              .statusSupplied
                                                              .withValues(
                                                                  alpha: 0.12)
                                                          : Colors.amber
                                                              .withValues(
                                                                  alpha: 0.20),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                        color: client.isActive
                                                            ? AquaColors
                                                                .statusSupplied
                                                                .withValues(
                                                                    alpha: 0.4)
                                                            : Colors.amber
                                                                .shade700,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      client.status,
                                                      style:
                                                          GoogleFonts.montserrat(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: client.isActive
                                                            ? AquaColors
                                                                .statusSupplied
                                                            : Colors
                                                                .amber.shade900,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (client
                                                  .razonSocial.isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  client.razonSocial,
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AquaColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                              if (client.rfc.isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'RFC: ${client.rfc}',
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: AquaColors.slateBlue,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        PopupMenuButton<String>(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                            Icons.more_vert_rounded,
                                            size: 18,
                                            color: AquaColors.textMuted,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          itemBuilder: (_) => [
                                            PopupMenuItem(
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
                                                    'Editar cliente / despachadores',
                                                    style: GoogleFonts.montserrat(
                                                        fontSize: 12.5),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'toggle_status',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    client.isActive
                                                        ? Icons
                                                            .pause_circle_outline_rounded
                                                        : Icons
                                                            .play_circle_outline_rounded,
                                                    size: 16,
                                                    color: client.isActive
                                                        ? Colors.amber.shade900
                                                        : AquaColors.turquoise,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    client.isActive
                                                        ? 'Desactivar cliente'
                                                        : 'Activar cliente',
                                                    style: GoogleFonts.montserrat(
                                                      fontSize: 12.5,
                                                      color: client.isActive
                                                          ? Colors.amber.shade900
                                                          : AquaColors.turquoise,
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
                                                  const Icon(
                                                    Icons.delete_rounded,
                                                    size: 16,
                                                    color: AquaColors.statusError,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    hasMovements
                                                        ? 'Eliminar cliente (bloqueado)'
                                                        : 'Eliminar cliente',
                                                    style: GoogleFonts.montserrat(
                                                      fontSize: 12.5,
                                                      color:
                                                          AquaColors.statusError,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          onSelected: (val) {
                                            if (val == 'edit') {
                                              _showAddClientDialog(
                                                  existingClient: client);
                                            }
                                            if (val == 'toggle_status') {
                                              _confirmToggleStatus(client);
                                            }
                                            if (val == 'delete') {
                                              _confirmDeleteClient(client);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Datos de contacto y precio
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.person_outline_rounded,
                                          size: 13,
                                          color: AquaColors.textMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            client.contactPerson,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: AquaColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AquaColors.turquoise
                                                .withValues(alpha: 0.08),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: AquaColors.turquoise
                                                  .withValues(alpha: 0.30),
                                            ),
                                          ),
                                          child: Text(
                                            '\$${client.pricePerBottle.toStringAsFixed(2)} / garrafón',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AquaColors.turquoise,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),

                                    // Dirección desglosada
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: AquaColors.turquoise,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            client.fullAddress,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: AquaColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (client.domicilio.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 19),
                                        child: Text(
                                          'Ref: ${client.domicilio}',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                            color: AquaColors.textMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),

                                    // Lista de despachadores asignados a este cliente
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AquaColors.iceBlue
                                            .withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: AquaColors.platinum),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                      Icons.water_drop_rounded,
                                                      size: 13,
                                                      color: AquaColors
                                                          .turquoise),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${client.dispenserCount} despachadores asignados:',
                                                    style: GoogleFonts.montserrat(
                                                      fontSize: 10.5,
                                                      fontWeight: FontWeight.w700,
                                                      color: AquaColors
                                                          .textPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                client.deliveryFrequency,
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: AquaColors.slateBlue,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (client.assignedDispenserIds
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 4,
                                              runSpacing: 4,
                                              children: client
                                                  .assignedDispenserIds
                                                  .map((id) {
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                    border: Border.all(
                                                        color: AquaColors
                                                            .platinum),
                                                  ),
                                                  child: Text(
                                                    id,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w700,
                                                      color:
                                                          AquaColors.turquoise,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : AquaColors.textPrimary,
        ),
      ),
      selected: isSelected,
      selectedColor: AquaColors.turquoise,
      backgroundColor: Colors.white.withValues(alpha: 0.8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      onSelected: (_) => setState(() => _statusFilter = value),
    );
  }
}
