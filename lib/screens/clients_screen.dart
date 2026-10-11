import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../services/supabase_service.dart';
import '../theme/aqua_colors.dart';
import '../utils/postal_code_helper.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';

class ClientsScreen extends StatefulWidget {
  final bool showBackButton;

  const ClientsScreen({super.key, this.showBackButton = true});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String _searchQuery = '';
  String _statusFilter = 'Todos'; // 'Todos', 'Activos', 'Inactivos'

  @override
  void initState() {
    super.initState();
    _refreshDispensers();
  }

  Future<void> _refreshDispensers() async {
    await SupabaseService.syncZonesFromSupabase();
    await SupabaseService.syncDispensersFromSupabase();
    if (mounted) setState(() {});
  }

  Future<void> _syncDispenserAssignments(
    String clientId,
    List<String> dispenserIds,
  ) async {
    if (!clientId.contains('-') || clientId.startsWith('CLI-')) return;

    final selectedIds = dispenserIds.map((id) => id.trim()).toSet();
    final previousRows = await SupabaseService.client
        .from('dispensers')
        .select('id')
        .eq('client_id', clientId);
    for (final row in previousRows) {
      final id = row['id']?.toString() ?? '';
      if (id.isNotEmpty && !selectedIds.contains(id)) {
        await SupabaseService.client
            .from('dispensers')
            .update({'client_id': null})
            .eq('id', id);
      }
    }

    for (final id in selectedIds) {
      await SupabaseService.client
          .from('dispensers')
          .update({'client_id': clientId})
          .eq('id', id);
    }
  }

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

  void _showAddClientDialog({ClientItem? existingClient}) {
    final isEdit = existingClient != null;

    // Controladores de campos fiscales y comerciales
    final nameCtrl = TextEditingController(
      text: existingClient?.companyName ?? '',
    );
    final razonSocialCtrl = TextEditingController(
      text: existingClient?.razonSocial ?? '',
    );
    final rfcCtrl = TextEditingController(text: existingClient?.rfc ?? '');

    // Controladores de contacto y precios
    final contactCtrl = TextEditingController(
      text: existingClient?.contactPerson ?? '',
    );
    final phoneCtrl = TextEditingController(text: existingClient?.phone ?? '');
    final emailCtrl = TextEditingController(text: existingClient?.email ?? '');
    final priceCtrl = TextEditingController(
      text: existingClient != null
          ? existingClient.pricePerBottle.toStringAsFixed(2)
          : '35.00',
    );

    // Controladores de dirección segmentada y fiscal
    final domicilioCtrl = TextEditingController(
      text: existingClient?.domicilio ?? '',
    );
    final calleCtrl = TextEditingController(text: existingClient?.calle ?? '');
    final numeroCtrl = TextEditingController(
      text: existingClient?.numero ?? '',
    );
    final cpCtrl = TextEditingController(text: existingClient?.cp ?? '');
    final coloniaCtrl = TextEditingController(
      text: existingClient?.colonia ?? '',
    );
    final ciudadCtrl = TextEditingController(
      text: existingClient?.ciudad ?? '',
    );
    final paisCtrl = TextEditingController(
      text: existingClient?.pais ?? 'México',
    );
    final notesCtrl = TextEditingController(text: existingClient?.notes ?? '');

    // Controladores de equipamiento inicial
    final initialBottlesCtrl = TextEditingController(
      text: existingClient != null
          ? existingClient.initialBottles.toString()
          : '20',
    );
    final racksCountCtrl = TextEditingController(
      text: existingClient != null ? existingClient.racksCount.toString() : '2',
    );
    final rackCapacityCtrl = TextEditingController(
      text: existingClient != null
          ? existingClient.rackCapacity.toString()
          : '8',
    );

    // Frecuencia, despachadores, QR y estado
    String selectedFrequency = existingClient?.deliveryFrequency ?? 'Semanal';
    String selectedStatus = existingClient?.status ?? 'Activo';
    bool selectedQrScanning = existingClient?.hasQrScanning ?? false;
    List<String> assignedDispensers = List.from(
      existingClient?.assignedDispenserIds ?? [],
    );
    List<String> clientZoneNames = List.from(existingClient?.zoneNames ?? []);
    String? zoneToAdd;
    String? formError;
    String? cpFeedbackMessage;

    void handleCpLookup(String raw, StateSetter setModalState) {
      final clean = raw.replaceAll(RegExp(r'\D'), '').trim();
      if (clean.length == 5) {
        final info = lookupMexicanPostalCode(clean);
        if (info != null) {
          setModalState(() {
            if (coloniaCtrl.text.trim().isEmpty ||
                coloniaCtrl.text.startsWith('Sector C.P.')) {
              coloniaCtrl.text = info.colonia;
            }
            if (ciudadCtrl.text.trim().isEmpty) {
              ciudadCtrl.text = info.fullCityState;
            }
            paisCtrl.text = info.pais;
            cpFeedbackMessage =
                '✓ C.P. detectado: ${info.ciudad}, ${info.estado} • Ubicación completada';
          });
        }
      } else {
        if (cpFeedbackMessage != null) {
          setModalState(() => cpFeedbackMessage = null);
        }
      }
    }

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
                          icon: const Icon(
                            Icons.close,
                            color: AquaColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => Navigator.of(modalCtx).pop(),
                        ),
                      ],
                    ),
                    Text(
                      isEdit
                          ? 'Actualiza los datos fiscales obligatorios, equipamiento y despachadores'
                          : 'Registra los datos fiscales obligatorios, dirección desglosada y equipamiento inicial',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AquaColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── SECCIÓN 1: Identificación y Datos Fiscales Obligatorios ──
                    _buildSectionHeader(
                      title: 'Identificación y Datos Fiscales (Obligatorios)',
                      icon: Icons.receipt_long_rounded,
                      subtitle:
                          'El nombre, razón social y RFC son requeridos para facturación',
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
                            label: 'Razón Social *',
                            hint: 'Ej. Grupo Bimbo S.A.B. de C.V.',
                            icon: Icons.domain_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: rfcCtrl,
                            label: 'RFC *',
                            hint: 'BIM900101XYZ',
                            icon: Icons.receipt_long_rounded,
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── SECCIÓN 2: Domicilio Fiscal Segmentado ──
                    _buildSectionHeader(
                      title: 'Dirección y Domicilio Fiscal (Obligatorio)',
                      icon: Icons.location_on_outlined,
                      subtitle:
                          'Ingresa el C.P. para autocompletar automáticamente colonia y ciudad',
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: domicilioCtrl,
                      label: 'Domicilio / Referencia de instalación *',
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
                            label: 'Calle *',
                            hint: 'Ej. Parque Industrial Las Américas',
                            icon: Icons.add_road_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: numeroCtrl,
                            label: 'Número (Ext/Int) *',
                            hint: 'Ej. #140 Nave B',
                            icon: Icons.tag_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                controller: cpCtrl,
                                label: 'Código Postal (CP) *',
                                hint: 'Ej. 01210',
                                icon: Icons.markunread_mailbox_outlined,
                                keyboardType: TextInputType.number,
                                onChanged: (val) =>
                                    handleCpLookup(val, setModalState),
                              ),
                              if (cpFeedbackMessage != null) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AquaColors.turquoise.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AquaColors.turquoise.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 13,
                                        color: AquaColors.turquoise,
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          cpFeedbackMessage!,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AquaColors.slateBlue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: _buildTextField(
                            controller: coloniaCtrl,
                            label: 'Colonia *',
                            hint: 'Ej. Las Américas',
                            icon: Icons.holiday_village_outlined,
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
                            label: 'Ciudad / Municipio *',
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

                    // ── SECCIÓN 3: Equipamiento Inicial Entregado ──
                    _buildSectionHeader(
                      title: 'Equipamiento Inicial Entregado',
                      icon: Icons.inventory_2_outlined,
                      subtitle:
                          'Garrafones dados para iniciar operaciones y racks asignados',
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: initialBottlesCtrl,
                            label: 'Garrafones dados (inicio) *',
                            hint: 'Ej. 20',
                            icon: Icons.water_drop_rounded,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: racksCountCtrl,
                            label: 'No. de Racks *',
                            hint: 'Ej. 2',
                            icon: Icons.grid_view_rounded,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: rackCapacityCtrl,
                            label: 'Espacios por rack *',
                            hint: 'Ej. 8',
                            icon: Icons.layers_outlined,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (_) {
                        final rCount =
                            int.tryParse(racksCountCtrl.text.trim()) ?? 0;
                        final rCap =
                            int.tryParse(rackCapacityCtrl.text.trim()) ?? 0;
                        final bGiven =
                            int.tryParse(initialBottlesCtrl.text.trim()) ?? 0;
                        final totalCap = rCount * rCap;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AquaColors.iceBlue.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AquaColors.glassBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                size: 15,
                                color: AquaColors.slateBlue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Capacidad total en racks: $totalCap garrafones ($rCount racks × $rCap espacios) • $bGiven garrafones iniciales dados',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AquaColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── SECCIÓN 4: Modalidad de Abastecimiento (Código QR) ──
                    _buildSectionHeader(
                      title: 'Modalidad de Abastecimiento (Código QR)',
                      icon: Icons.qr_code_scanner_rounded,
                      subtitle:
                          'Activa si se abastecen despachadores individualmente con QR',
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selectedQrScanning
                            ? AquaColors.turquoise.withValues(alpha: 0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selectedQrScanning
                              ? AquaColors.turquoise
                              : AquaColors.platinum,
                          width: selectedQrScanning ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selectedQrScanning
                                ? Icons.qr_code_scanner_rounded
                                : Icons.local_shipping_outlined,
                            color: selectedQrScanning
                                ? AquaColors.turquoise
                                : AquaColors.slateBlue,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedQrScanning
                                      ? 'Escaneo QR Habilitado en Despachadores'
                                      : 'Solo Entrega de Garrafones (Sin QR)',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: selectedQrScanning
                                        ? AquaColors.slateBlue
                                        : AquaColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  selectedQrScanning
                                      ? 'El trabajador abastece despachadores personalmente y escanea el QR de cada uno.'
                                      : 'Solo se entregan los garrafones generales. No se requiere escanear cada despachador por QR.',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    color: AquaColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: selectedQrScanning,
                            activeTrackColor: AquaColors.turquoise,
                            onChanged: (val) {
                              setModalState(() => selectedQrScanning = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    if (selectedQrScanning) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AquaColors.iceBlue.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AquaColors.glassBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Zonas habilitadas para este cliente',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AquaColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'El trabajador solo verá y podrá escanear despachadores asignados que estén dentro de estas zonas.',
                              style: GoogleFonts.montserrat(
                                fontSize: 10.5,
                                height: 1.35,
                                color: AquaColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (kDefaultZones.isEmpty)
                              Text(
                                'Primero registra las zonas desde la tarjeta “Registrar zonas” del administrador.',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade900,
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue:
                                          kDefaultZones.any(
                                            (zone) => zone.name == zoneToAdd,
                                          )
                                          ? zoneToAdd
                                          : null,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        labelText: 'Selecciona una zona',
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      items: kDefaultZones
                                          .map(
                                            (zone) => DropdownMenuItem(
                                              value: zone.name,
                                              child: Text(
                                                zone.name,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) => setModalState(
                                        () => zoneToAdd = value,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton.filled(
                                    tooltip: 'Agregar zona',
                                    onPressed:
                                        zoneToAdd == null ||
                                            clientZoneNames.contains(zoneToAdd)
                                        ? null
                                        : () {
                                            setModalState(() {
                                              clientZoneNames = [
                                                ...clientZoneNames,
                                                zoneToAdd!,
                                              ];
                                              zoneToAdd = null;
                                            });
                                          },
                                    icon: const Icon(Icons.add_rounded),
                                  ),
                                ],
                              ),
                            if (clientZoneNames.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: clientZoneNames
                                    .map(
                                      (zoneName) => InputChip(
                                        label: Text(zoneName),
                                        onDeleted: () => setModalState(
                                          () =>
                                              clientZoneNames.remove(zoneName),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ] else if (kDefaultZones.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Selecciona al menos una zona para limitar los despachadores de este cliente.',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // ── SECCIÓN 5: Contacto y Condiciones Comerciales ──
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
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
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
                    const SizedBox(height: 16),

                    // ── SECCIÓN 6: Despachadores Asignados ──
                    _buildSectionHeader(
                      title: 'Despachadores asignados',
                      icon: Icons.water_drop_rounded,
                      subtitle: 'Consulta las asignaciones de este cliente',
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AquaColors.iceBlue.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AquaColors.glassBorder),
                      ),
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
                          ),
                          if (assignedDispensers.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Las asignaciones se administran desde Despachadores.',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  color: AquaColors.textSecondary,
                                ),
                              ),
                            )
                          else ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: assignedDispensers.map((id) {
                                return Chip(
                                  avatar: const Icon(
                                    Icons.water_drop_rounded,
                                    size: 14,
                                    color: AquaColors.turquoise,
                                  ),
                                  label: Text(id),
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: AquaColors.platinum,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── SECCIÓN 7: Estado del Cliente ──
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
                                    ? AquaColors.statusSupplied.withValues(
                                        alpha: 0.15,
                                      )
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
                              () => selectedStatus = 'Inactivo',
                            ),
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
                      hint:
                          'Horarios de acceso, caseta o contacto en almacén...',
                      icon: Icons.notes_rounded,
                      maxLines: 2,
                    ),

                    if (formError != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AquaColors.statusErrorBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AquaColors.statusErrorBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 16,
                              color: AquaColors.statusError,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                formError!,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AquaColors.statusError,
                                ),
                              ),
                            ),
                          ],
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
                      onPressed: () async {
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
                        final priceVal =
                            double.tryParse(
                              priceCtrl.text.trim().replaceAll(',', '.'),
                            ) ??
                            35.0;

                        final initialBottles =
                            int.tryParse(initialBottlesCtrl.text.trim()) ?? 0;
                        final racksCount =
                            int.tryParse(racksCountCtrl.text.trim()) ?? 0;
                        final rackCapacity =
                            int.tryParse(rackCapacityCtrl.text.trim()) ?? 0;

                        // Validación de datos fiscales obligatorios
                        if (name.isEmpty) {
                          setModalState(
                            () => formError =
                                'Ingresa el nombre comercial de la empresa.',
                          );
                          return;
                        }
                        if (razonSocial.isEmpty) {
                          setModalState(
                            () => formError =
                                'La Razón Social es obligatoria (datos fiscales).',
                          );
                          return;
                        }
                        if (rfc.isEmpty) {
                          setModalState(
                            () => formError =
                                'El RFC es obligatorio para facturación y datos fiscales.',
                          );
                          return;
                        }
                        if (domicilio.isEmpty) {
                          setModalState(
                            () => formError =
                                'El domicilio o referencia de instalación es obligatorio.',
                          );
                          return;
                        }
                        if (calle.isEmpty || numero.isEmpty) {
                          setModalState(
                            () => formError =
                                'La calle y número exterior/interior son obligatorios.',
                          );
                          return;
                        }
                        if (cp.isEmpty) {
                          setModalState(
                            () => formError =
                                'El Código Postal (CP) es obligatorio.',
                          );
                          return;
                        }
                        if (colonia.isEmpty) {
                          setModalState(
                            () =>
                                formError = 'La colonia fiscal es obligatoria.',
                          );
                          return;
                        }
                        if (ciudad.isEmpty) {
                          setModalState(
                            () => formError =
                                'La ciudad o municipio fiscal es obligatorio.',
                          );
                          return;
                        }

                        if (selectedQrScanning && clientZoneNames.isEmpty) {
                          setModalState(
                            () => formError =
                                'Agrega al menos una zona habilitada para el escaneo QR.',
                          );
                          return;
                        }

                        // Validación de equipamiento inicial
                        if (initialBottles < 0) {
                          setModalState(
                            () => formError =
                                'Ingresa una cantidad válida de garrafones iniciales.',
                          );
                          return;
                        }
                        if (racksCount < 0) {
                          setModalState(
                            () => formError =
                                'Ingresa una cantidad válida de racks.',
                          );
                          return;
                        }
                        if (rackCapacity <= 0) {
                          setModalState(
                            () => formError =
                                'Ingresa los espacios por rack (mayor a 0).',
                          );
                          return;
                        }

                        // Formatear dirección completa compuesta
                        final addressParts = <String>[];
                        if (calle.isNotEmpty || numero.isNotEmpty) {
                          addressParts.add('$calle $numero'.trim());
                        }
                        if (colonia.isNotEmpty) {
                          addressParts.add('Col. $colonia');
                        }
                        if (cp.isNotEmpty) {
                          addressParts.add('C.P. $cp');
                        }
                        if (ciudad.isNotEmpty) {
                          addressParts.add(ciudad);
                        }
                        if (pais.isNotEmpty && pais != 'México') {
                          addressParts.add(pais);
                        }
                        final computedAddress = addressParts.isNotEmpty
                            ? addressParts.join(', ')
                            : (existingClient?.address ??
                                  'Dirección no especificada');

                        final targetId =
                            existingClient?.id ??
                            'CLI-${DateTime.now().millisecondsSinceEpoch % 10000}';

                        final clientModel = ClientItem(
                          id: targetId,
                          companyName: name,
                          razonSocial: razonSocial,
                          rfc: rfc,
                          contactPerson: contact.isEmpty
                              ? 'Contacto general'
                              : contact,
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
                          initialBottles: initialBottles,
                          racksCount: racksCount,
                          rackCapacity: rackCapacity,
                          hasQrScanning: selectedQrScanning,
                          zoneNames: clientZoneNames,
                        );

                        String? persistedClientId;
                        if (isEdit) {
                          try {
                            final updatedRow = await SupabaseService.client
                                .from('clients')
                                .update({
                                  'company_name': clientModel.companyName,
                                  'razon_social': clientModel.razonSocial,
                                  'rfc': clientModel.rfc,
                                  'contact_person': clientModel.contactPerson,
                                  'phone': clientModel.phone,
                                  'email': clientModel.email,
                                  'domicilio': clientModel.domicilio,
                                  'calle': clientModel.calle,
                                  'numero': clientModel.numero,
                                  'cp': clientModel.cp,
                                  'colonia': clientModel.colonia,
                                  'ciudad': clientModel.ciudad,
                                  'pais': clientModel.pais,
                                  'address': clientModel.address,
                                  'delivery_frequency':
                                      clientModel.deliveryFrequency,
                                  'status': clientModel.status,
                                  'notes': clientModel.notes,
                                  'price_per_bottle':
                                      clientModel.pricePerBottle,
                                  'initial_bottles': clientModel.initialBottles,
                                  'racks_count': clientModel.racksCount,
                                  'rack_capacity': clientModel.rackCapacity,
                                  'has_qr_scanning': clientModel.hasQrScanning,
                                  'client_zones': clientModel.zoneNames,
                                })
                                .eq('company_name', clientModel.companyName)
                                .select('id')
                                .maybeSingle();
                            persistedClientId =
                                updatedRow?['id']?.toString() ?? targetId;
                          } catch (e) {
                            debugPrint(
                              'Error actualizando cliente en Supabase: $e',
                            );
                          }
                          final savedClient = clientModel.copyWith(
                            id: persistedClientId ?? clientModel.id,
                          );
                          updateClient(savedClient);
                          assignDispensersToClient(
                            savedClient.id,
                            assignedDispensers,
                          );
                          if (persistedClientId != null) {
                            try {
                              await _syncDispenserAssignments(
                                persistedClientId,
                                assignedDispensers,
                              );
                            } catch (e) {
                              debugPrint(
                                'Error guardando despachadores del cliente: $e',
                              );
                            }
                          }
                        } else {
                          try {
                            final insertedRow = await SupabaseService.client
                                .from('clients')
                                .insert({
                                  'company_name': clientModel.companyName,
                                  'razon_social': clientModel.razonSocial,
                                  'rfc': clientModel.rfc,
                                  'contact_person': clientModel.contactPerson,
                                  'phone': clientModel.phone,
                                  'email': clientModel.email,
                                  'domicilio': clientModel.domicilio,
                                  'calle': clientModel.calle,
                                  'numero': clientModel.numero,
                                  'cp': clientModel.cp,
                                  'colonia': clientModel.colonia,
                                  'ciudad': clientModel.ciudad,
                                  'pais': clientModel.pais,
                                  'address': clientModel.address,
                                  'delivery_frequency':
                                      clientModel.deliveryFrequency,
                                  'status': clientModel.status,
                                  'notes': clientModel.notes,
                                  'price_per_bottle':
                                      clientModel.pricePerBottle,
                                  'initial_bottles': clientModel.initialBottles,
                                  'racks_count': clientModel.racksCount,
                                  'rack_capacity': clientModel.rackCapacity,
                                  'has_qr_scanning': clientModel.hasQrScanning,
                                  'client_zones': clientModel.zoneNames,
                                })
                                .select('id')
                                .single();
                            persistedClientId = insertedRow['id']?.toString();
                          } catch (e) {
                            debugPrint(
                              'Error insertando cliente en Supabase: $e',
                            );
                          }
                          final savedClient = clientModel.copyWith(
                            id: persistedClientId ?? clientModel.id,
                          );
                          addClient(savedClient);
                          assignDispensersToClient(
                            savedClient.id,
                            assignedDispensers,
                          );
                          if (persistedClientId != null) {
                            try {
                              await _syncDispenserAssignments(
                                persistedClientId,
                                assignedDispensers,
                              );
                            } catch (e) {
                              debugPrint(
                                'Error guardando despachadores del cliente: $e',
                              );
                            }
                          }

                          // Actualizar también los despachadores asignados a 'pending' en Supabase
                          for (final dispId in assignedDispensers) {
                            try {
                              await SupabaseService.client
                                  .from('dispensers')
                                  .update({
                                    'status': 'pending',
                                    'last_supply_info':
                                        'Pendiente de abastecer',
                                  })
                                  .eq('id', dispId.trim());
                            } catch (_) {}
                          }
                        }

                        if (modalCtx.mounted) {
                          Navigator.of(modalCtx).pop();
                        }
                        if (mounted) {
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
                        }
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
                                borderRadius: BorderRadius.circular(14),
                              ),
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
                                    borderRadius: BorderRadius.circular(14),
                                  ),
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

  /// Muestra una vista modal completa y detallada del cliente con métricas,
  /// datos comerciales, fiscales, contacto, domicilio, despachadores e historial.
  void _showClientDetailSheet(ClientItem client) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final currentClient = kDefaultClients.firstWhere(
            (c) => c.id == client.id,
            orElse: () => client,
          );
          final currentMetrics = getKpisForClient(currentClient);
          final currentDispensers = getDispensersForClient(currentClient);
          final supplyRecords = kSupplyRecords.where((r) {
            final recordClient = r.clientName.trim().toLowerCase();
            final cName = currentClient.companyName.trim().toLowerCase();
            final rName = currentClient.razonSocial.trim().toLowerCase();
            return recordClient == cName ||
                (rName.isNotEmpty && recordClient == rName);
          }).toList();
          final movementsCount = supplyRecords.length;

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.90,
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra indicadora de arrastre
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AquaColors.platinum,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Encabezado con identidad de la empresa
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: currentClient.isActive
                              ? [AquaColors.turquoise, AquaColors.slateBlue]
                              : [Colors.amber.shade700, Colors.amber.shade900],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (currentClient.isActive
                                        ? AquaColors.turquoise
                                        : Colors.amber)
                                    .withValues(alpha: 0.28),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.business_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  currentClient.companyName,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w700,
                                    color: AquaColors.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: currentClient.isActive
                                      ? AquaColors.statusSupplied.withValues(
                                          alpha: 0.12,
                                        )
                                      : Colors.amber.withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: currentClient.isActive
                                        ? AquaColors.statusSupplied.withValues(
                                            alpha: 0.4,
                                          )
                                        : Colors.amber.shade700,
                                  ),
                                ),
                                child: Text(
                                  currentClient.status,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: currentClient.isActive
                                        ? AquaColors.statusSupplied
                                        : Colors.amber.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (currentClient.razonSocial.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              currentClient.razonSocial,
                              style: GoogleFonts.montserrat(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AquaColors.textSecondary,
                              ),
                            ),
                          ],
                          if (currentClient.rfc.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'RFC: ${currentClient.rfc}',
                              style: GoogleFonts.montserrat(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AquaColors.slateBlue,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AquaColors.textSecondary,
                      ),
                      onPressed: () => Navigator.of(sheetCtx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Botones rápidos de gestión
                Row(
                  children: [
                    Expanded(
                      child: AquaButton(
                        text: 'Editar Cliente',
                        icon: Icons.edit_rounded,
                        type: AquaButtonType.secondary,
                        height: 38,
                        onPressed: () {
                          Navigator.of(sheetCtx).pop();
                          _showAddClientDialog(existingClient: currentClient);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AquaButton(
                        text: currentClient.isActive ? 'Pausar' : 'Activar',
                        icon: currentClient.isActive
                            ? Icons.pause_circle_outline_rounded
                            : Icons.play_circle_outline_rounded,
                        type: AquaButtonType.secondary,
                        height: 38,
                        onPressed: () {
                          toggleClientStatus(currentClient.id);
                          setSheetState(() {});
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Contenido desplazable con toda la información
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cuadrícula de KPIs operativos
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AquaColors.glacier.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AquaColors.glassBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RESUMEN OPERATIVO',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AquaColors.slateBlue,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _buildDetailKpi(
                                    label: 'Despachadores',
                                    value: '${currentMetrics.totalDispensers}',
                                    icon: Icons.water_drop_rounded,
                                    color: AquaColors.turquoise,
                                  ),
                                  const SizedBox(width: 6),
                                  _buildDetailKpi(
                                    label: 'Abastecidos',
                                    value: '${currentMetrics.suppliedCount}',
                                    icon: Icons.check_circle_rounded,
                                    color: AquaColors.statusSupplied,
                                  ),
                                  const SizedBox(width: 6),
                                  _buildDetailKpi(
                                    label: 'Pendientes',
                                    value: '${currentMetrics.pendingCount}',
                                    icon: Icons.pending_actions_rounded,
                                    color: AquaColors.statusPending,
                                  ),
                                  const SizedBox(width: 6),
                                  _buildDetailKpi(
                                    label: 'Garrafones',
                                    value: '${currentMetrics.totalBottles}',
                                    icon: Icons.inventory_2_rounded,
                                    color: AquaColors.slateBlue,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Sección: Datos Comerciales y Fiscales
                        _buildDetailSectionTitle(
                          icon: Icons.receipt_long_rounded,
                          title: 'Datos Comerciales y Fiscales',
                        ),
                        const SizedBox(height: 8),
                        _buildDetailCard(
                          children: [
                            _buildDetailRow('ID Cliente', currentClient.id),
                            _buildDetailRow(
                              'Razón Social',
                              currentClient.razonSocial.isNotEmpty
                                  ? currentClient.razonSocial
                                  : 'No registrada',
                            ),
                            _buildDetailRow(
                              'RFC',
                              currentClient.rfc.isNotEmpty
                                  ? currentClient.rfc
                                  : 'Sin RFC registrado',
                            ),
                            _buildDetailRow(
                              'Tarifa por garrafón',
                              '\$${currentClient.pricePerBottle.toStringAsFixed(2)} MXN',
                              highlight: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Sección: Contacto
                        _buildDetailSectionTitle(
                          icon: Icons.person_rounded,
                          title: 'Contacto de la Empresa',
                        ),
                        const SizedBox(height: 8),
                        _buildDetailCard(
                          children: [
                            _buildDetailRow(
                              'Persona de Contacto',
                              currentClient.contactPerson,
                            ),
                            _buildDetailRow(
                              'Teléfono',
                              currentClient.phone,
                              icon: Icons.phone_outlined,
                            ),
                            _buildDetailRow(
                              'Correo Electrónico',
                              currentClient.email,
                              icon: Icons.email_outlined,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Sección: Domicilio y Ubicación
                        _buildDetailSectionTitle(
                          icon: Icons.location_on_rounded,
                          title: 'Ubicación y Domicilio',
                        ),
                        const SizedBox(height: 8),
                        _buildDetailCard(
                          children: [
                            _buildDetailRow(
                              'Dirección Completa',
                              currentClient.fullAddress,
                            ),
                            if (currentClient.calle.isNotEmpty ||
                                currentClient.numero.isNotEmpty)
                              _buildDetailRow(
                                'Calle y Número',
                                '${currentClient.calle} ${currentClient.numero}'
                                    .trim(),
                              ),
                            if (currentClient.colonia.isNotEmpty)
                              _buildDetailRow('Colonia', currentClient.colonia),
                            if (currentClient.cp.isNotEmpty)
                              _buildDetailRow(
                                'Código Postal',
                                currentClient.cp,
                              ),
                            if (currentClient.ciudad.isNotEmpty)
                              _buildDetailRow(
                                'Ciudad / País',
                                '${currentClient.ciudad}, ${currentClient.pais}',
                              ),
                            if (currentClient.domicilio.isNotEmpty)
                              _buildDetailRow(
                                'Referencias',
                                currentClient.domicilio,
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Sección: Equipamiento Inicial y Racks
                        _buildDetailSectionTitle(
                          icon: Icons.inventory_2_outlined,
                          title: 'Equipamiento Inicial Entregado',
                        ),
                        const SizedBox(height: 8),
                        _buildDetailCard(
                          children: [
                            _buildDetailRow(
                              'Garrafones iniciales dados',
                              '${currentClient.initialBottles} garrafones',
                              highlight: true,
                            ),
                            _buildDetailRow(
                              'Racks entregados',
                              '${currentClient.racksCount} racks',
                            ),
                            _buildDetailRow(
                              'Capacidad por rack',
                              '${currentClient.rackCapacity} espacios por rack',
                            ),
                            _buildDetailRow(
                              'Capacidad total en racks',
                              '${currentClient.totalRackCapacity} garrafones',
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Sección: Modalidad de Abastecimiento (QR)
                        _buildDetailSectionTitle(
                          icon: Icons.qr_code_scanner_rounded,
                          title: 'Modalidad de Abastecimiento',
                        ),
                        const SizedBox(height: 8),
                        _buildDetailCard(
                          children: [
                            _buildDetailRow(
                              'Escaneo de código QR',
                              currentClient.hasQrScanning
                                  ? 'Activado (Abastecimiento individual por QR)'
                                  : 'Desactivado (Solo entrega directa de garrafones)',
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Sección: Despachadores Asignados
                        _buildDetailSectionTitle(
                          icon: Icons.water_drop_outlined,
                          title:
                              'Despachadores Asignados (${currentDispensers.length})',
                        ),
                        const SizedBox(height: 8),
                        if (currentDispensers.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AquaColors.glacier.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AquaColors.platinum),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 18,
                                  color: AquaColors.slateBlue,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Esta empresa aún no tiene despachadores asignados. Puedes asignarlos editando el cliente.',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11.5,
                                      color: AquaColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: currentDispensers.map((dispenser) {
                              final isSupplied = dispenser.isSupplied;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AquaColors.platinum,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AquaColors.shadowCard,
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            (isSupplied
                                                    ? AquaColors.statusSupplied
                                                    : AquaColors.statusPending)
                                                .withValues(alpha: 0.12),
                                      ),
                                      child: Icon(
                                        Icons.water_drop_rounded,
                                        size: 18,
                                        color: isSupplied
                                            ? AquaColors.statusSupplied
                                            : AquaColors.statusPending,
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
                                              Text(
                                                'Despachador ${dispenser.id}',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: AquaColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  '• ${dispenser.brand} ${dispenser.model}',
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 11,
                                                    color: AquaColors
                                                        .textSecondary,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${dispenser.bottleCount} garrafones • ${dispenser.lastSupplyInfo}',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 10,
                                              color: AquaColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            (isSupplied
                                                    ? AquaColors.statusSupplied
                                                    : AquaColors.statusPending)
                                                .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isSupplied ? 'Abastecido' : 'Pendiente',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: isSupplied
                                              ? AquaColors.statusSupplied
                                              : AquaColors.statusPending,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 14),

                        // Sección: Historial de Abastecimientos
                        _buildDetailSectionTitle(
                          icon: Icons.history_rounded,
                          title:
                              'Historial de Abastecimientos ($movementsCount)',
                        ),
                        const SizedBox(height: 8),
                        if (supplyRecords.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AquaColors.glacier.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AquaColors.platinum),
                            ),
                            child: Text(
                              'Sin movimientos de abastecimiento registrados para este cliente.',
                              style: GoogleFonts.montserrat(
                                fontSize: 11.5,
                                color: AquaColors.textSecondary,
                              ),
                            ),
                          )
                        else
                          Column(
                            children: supplyRecords.take(5).map((rec) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AquaColors.platinum,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      rec.isResupply
                                          ? Icons.autorenew_rounded
                                          : Icons.check_circle_outline_rounded,
                                      size: 16,
                                      color: rec.isResupply
                                          ? AquaColors.slateBlue
                                          : AquaColors.statusSupplied,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${rec.isResupply ? 'Reabastecimiento' : 'Abastecimiento'} • Desp. ${rec.dispenserId}',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: AquaColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            '${rec.workerName} • ${rec.bottles} garrafones • \$${(rec.bottles * rec.pricePerBottle).toStringAsFixed(2)}',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 10,
                                              color: AquaColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${rec.timestamp.day}/${rec.timestamp.month} ${rec.timestamp.hour.toString().padLeft(2, '0')}:${rec.timestamp.minute.toString().padLeft(2, '0')}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                        color: AquaColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 14),

                        // Notas si existen
                        if (currentClient.notes.isNotEmpty) ...[
                          _buildDetailSectionTitle(
                            icon: Icons.notes_rounded,
                            title: 'Notas Operativas',
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AquaColors.glacier.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AquaColors.platinum),
                            ),
                            child: Text(
                              currentClient.notes,
                              style: GoogleFonts.montserrat(
                                fontSize: 11.5,
                                color: AquaColors.textPrimary,
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailKpi({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AquaColors.platinum),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 3),
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AquaColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                color: AquaColors.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AquaColors.turquoise),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AquaColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AquaColors.platinum),
        boxShadow: [
          BoxShadow(
            color: AquaColors.shadowCard,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool highlight = false,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: AquaColors.textMuted),
            const SizedBox(width: 4),
          ],
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: AquaColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 11.5,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
                color: highlight
                    ? AquaColors.turquoise
                    : AquaColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
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
    ValueChanged<String>? onChanged,
    Widget? suffix,
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
            onChanged: onChanged,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AquaColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AquaColors.turquoise, size: 18),
              suffixIcon: suffix,
              hintText: hint,
              hintStyle: GoogleFonts.montserrat(
                fontSize: 12,
                color: AquaColors.textMuted,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    if (widget.showBackButton &&
                        Navigator.of(context).canPop()) ...[
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: AquaColors.turquoise,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clientes',
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
                    IconButton(
                      tooltip: 'Actualizar despachadores',
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: AquaColors.turquoise,
                      ),
                      onPressed: _refreshDispensers,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AquaColors.glacier.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AquaColors.slateBlue.withValues(alpha: 0.4),
                        ),
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

                // Card para registrar nuevos clientes
                GlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  onTap: _showAddClientDialog,
                  borderColor: AquaColors.turquoise.withValues(alpha: 0.35),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              AquaColors.turquoise,
                              AquaColors.slateBlue,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AquaColors.turquoise.withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Registrar nuevo cliente',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AquaColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Alta de empresa, datos fiscales y despachadores',
                              style: GoogleFonts.montserrat(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: AquaColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AquaColors.turquoise.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AquaColors.turquoise.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              size: 15,
                              color: AquaColors.turquoise,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Registrar',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AquaColors.turquoise,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
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
                      _buildFilterChip(
                        'Todos (${kDefaultClients.length})',
                        'Todos',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip('Activos ($activeCount)', 'Activos'),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Inactivos ($inactiveCount)',
                        'Inactivos',
                      ),
                    ],
                  ),
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
                            final hasMovements = clientHasMovements(client);

                            return RepaintBoundary(
                              child: GlassCard(
                                borderRadius: 16,
                                padding: const EdgeInsets.all(14),
                                onTap: () => _showClientDetailSheet(client),
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
                                                ? AquaColors.glacier.withValues(
                                                    alpha: 0.6,
                                                  )
                                                : Colors.amber.withValues(
                                                    alpha: 0.15,
                                                  ),
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
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: client.isActive
                                                          ? AquaColors
                                                                .statusSupplied
                                                                .withValues(
                                                                  alpha: 0.12,
                                                                )
                                                          : Colors.amber
                                                                .withValues(
                                                                  alpha: 0.20,
                                                                ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      border: Border.all(
                                                        color: client.isActive
                                                            ? AquaColors
                                                                  .statusSupplied
                                                                  .withValues(
                                                                    alpha: 0.4,
                                                                  )
                                                            : Colors
                                                                  .amber
                                                                  .shade700,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      client.status,
                                                      style: GoogleFonts.montserrat(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: client.isActive
                                                            ? AquaColors
                                                                  .statusSupplied
                                                            : Colors
                                                                  .amber
                                                                  .shade900,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (client
                                                  .razonSocial
                                                  .isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  client.razonSocial,
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: AquaColors
                                                        .textSecondary,
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                                    style:
                                                        GoogleFonts.montserrat(
                                                          fontSize: 12.5,
                                                        ),
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
                                                    style:
                                                        GoogleFonts.montserrat(
                                                          fontSize: 12.5,
                                                          color: client.isActive
                                                              ? Colors
                                                                    .amber
                                                                    .shade900
                                                              : AquaColors
                                                                    .turquoise,
                                                          fontWeight:
                                                              FontWeight.w600,
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
                                                    color:
                                                        AquaColors.statusError,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    hasMovements
                                                        ? 'Eliminar cliente (bloqueado)'
                                                        : 'Eliminar cliente',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                          fontSize: 12.5,
                                                          color: AquaColors
                                                              .statusError,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          onSelected: (val) {
                                            if (val == 'edit') {
                                              _showAddClientDialog(
                                                existingClient: client,
                                              );
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
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
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
                                        padding: const EdgeInsets.only(
                                          left: 19,
                                        ),
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

                                    // Equipamiento inicial y modalidad QR
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AquaColors.glacier
                                                .withValues(alpha: 0.5),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: AquaColors.platinum,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.inventory_2_outlined,
                                                size: 11,
                                                color: AquaColors.slateBlue,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${client.initialBottles} garrafones • ${client.racksCount} racks (${client.rackCapacity} c/u)',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      AquaColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: client.hasQrScanning
                                                ? AquaColors.turquoise
                                                      .withValues(alpha: 0.1)
                                                : Colors.grey.withValues(
                                                    alpha: 0.1,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: client.hasQrScanning
                                                  ? AquaColors.turquoise
                                                        .withValues(alpha: 0.35)
                                                  : AquaColors.platinum,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                client.hasQrScanning
                                                    ? Icons
                                                          .qr_code_scanner_rounded
                                                    : Icons
                                                          .local_shipping_outlined,
                                                size: 11,
                                                color: client.hasQrScanning
                                                    ? AquaColors.turquoise
                                                    : AquaColors.textSecondary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                client.hasQrScanning
                                                    ? 'QR Habilitado'
                                                    : 'Entrega directa',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: client.hasQrScanning
                                                      ? AquaColors.turquoise
                                                      : AquaColors
                                                            .textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Lista de despachadores asignados a este cliente
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AquaColors.iceBlue.withValues(
                                          alpha: 0.4,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AquaColors.platinum,
                                        ),
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
                                                    color: AquaColors.turquoise,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${client.dispenserCount} despachadores asignados:',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                          fontSize: 10.5,
                                                          fontWeight:
                                                              FontWeight.w700,
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
                                          if (client
                                              .assignedDispenserIds
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 4,
                                              runSpacing: 4,
                                              children: client.assignedDispenserIds.map((
                                                id,
                                              ) {
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          AquaColors.platinum,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    id,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: AquaColors
                                                              .turquoise,
                                                        ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Toca para ver información detallada',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AquaColors.turquoise,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 10,
                                          color: AquaColors.turquoise,
                                        ),
                                      ],
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
