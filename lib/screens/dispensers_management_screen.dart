import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../services/supabase_service.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';
import 'register_dispenser_screen.dart';
import 'dispenser_qr_screen.dart';

class DispensersManagementScreen extends StatefulWidget {
  const DispensersManagementScreen({super.key});

  @override
  State<DispensersManagementScreen> createState() =>
      _DispensersManagementScreenState();
}

class _DispensersManagementScreenState
    extends State<DispensersManagementScreen> {
  String _searchQuery = '';
  String _statusFilter = 'Todos'; // 'Todos', 'Activos', 'Inactivos'

  @override
  void initState() {
    super.initState();
    _refreshDispensers();
  }

  Future<void> _refreshDispensers() async {
    await SupabaseService.syncDispensersFromSupabase();
    if (mounted) setState(() {});
  }

  Future<void> _openDispenserQr(ZoneDispenserEntry entry) async {
    var dispenser = entry.dispenser;
    if (dispenser.qrToken.isEmpty) {
      final random = Random.secure();
      final token = List<int>.generate(
        16,
        (_) => random.nextInt(256),
      ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
      dispenser = dispenser.copyWith(qrToken: token);
      final updated = updateDispenser(
        currentZoneName: entry.zoneName,
        currentDispenserId: entry.dispenser.id,
        updatedItem: dispenser,
        targetZoneName: entry.zoneName,
      );
      if (updated) setState(() {});

      try {
        await Supabase.instance.client
            .from('dispensers')
            .update({'qr_token': token})
            .eq('id', dispenser.id);
      } catch (_) {
        // El QR sigue disponible localmente; la migración habilita sincronización.
      }
    }

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DispenserQrScreen(
          dispenserId: dispenser.id,
          brand: dispenser.brand,
          serialNumber: dispenser.serialNumber,
          qrToken: dispenser.qrToken,
        ),
      ),
    );
  }

  List<ZoneDispenserEntry> get _allEntries => getAllDispensersWithZone();

  List<ZoneDispenserEntry> get _filteredEntries {
    final list = _allEntries;
    return list.where((entry) {
      final d = entry.dispenser;

      // Filtro por estado activo/inactivo (se ignora abastecido/pendiente)
      if (_statusFilter == 'Activos' && !d.isActive) return false;
      if (_statusFilter == 'Inactivos' && d.isActive) return false;

      // Filtro por texto de búsqueda
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.trim().toLowerCase();
      final client = getClientForDispenser(d.id);

      final matchesId = d.id.toLowerCase().contains(q);
      final matchesBrand = d.brand.toLowerCase().contains(q);
      final matchesModel = d.model.toLowerCase().contains(q);
      final matchesZone = entry.zoneName.toLowerCase().contains(q);
      final matchesSerial = d.serialNumber.toLowerCase().contains(q);
      final matchesClient =
          client != null &&
          (client.companyName.toLowerCase().contains(q) ||
              client.razonSocial.toLowerCase().contains(q));

      return matchesId ||
          matchesBrand ||
          matchesModel ||
          matchesZone ||
          matchesSerial ||
          matchesClient;
    }).toList();
  }

  /// Modal para editar un despachador existente (número, marca, modelo, serie, zona y cliente)
  void _showEditDispenserDialog(ZoneDispenserEntry entry) {
    final dispenser = entry.dispenser;
    final currentClient = getClientForDispenser(dispenser.id);

    final idCtrl = TextEditingController(text: dispenser.id);
    final brandCtrl = TextEditingController(text: dispenser.brand);
    final modelCtrl = TextEditingController(text: dispenser.model);
    final serialCtrl = TextEditingController(text: dispenser.serialNumber);

    String selectedZone = entry.zoneName;
    String? selectedClientId = currentClient?.id;
    bool isActive = dispenser.isActive;
    String? error;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          ClientItem? selectedClient;
          for (final client in kDefaultClients) {
            if (client.id == selectedClientId) {
              selectedClient = client;
              break;
            }
          }
          final zones = selectedClient?.hasQrScanning == true
              ? selectedClient!.zoneNames
              : kDefaultZones.map((zone) => zone.name).toList();

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(modalCtx).size.height * 0.88,
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

                  // Título
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AquaColors.turquoise.withValues(alpha: 0.12),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: AquaColors.turquoise,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Editar Despachador ${dispenser.id}',
                              style: GoogleFonts.montserrat(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                                color: AquaColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Modifica características, zona asignada y empresa',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: AquaColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: AquaColors.textSecondary,
                        ),
                        onPressed: () => Navigator.of(modalCtx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormField(
                            controller: idCtrl,
                            label: 'Número / Identificador del despachador',
                            hint: 'Ej. #023',
                            icon: Icons.tag_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildFormField(
                            controller: brandCtrl,
                            label: 'Marca del equipo',
                            hint: 'Ej. EcoWater, AquaPro, Oasis',
                            icon: Icons.water_drop_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildFormField(
                            controller: modelCtrl,
                            label: 'Modelo',
                            hint: 'Ej. E-200, Slim 20',
                            icon: Icons.devices_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildFormField(
                            controller: serialCtrl,
                            label: 'Número de Serie (S/N)',
                            hint: 'Ej. EW-88219',
                            icon: Icons.qr_code_rounded,
                          ),
                          const SizedBox(height: 14),

                          // Selector de Empresa Cliente Asignada
                          Text(
                            'Empresa Cliente asignada',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AquaColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AquaColors.platinum,
                                width: 1.2,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String?>(
                                value: selectedClientId,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AquaColors.slateBlue,
                                ),
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AquaColors.textPrimary,
                                ),
                                items: [
                                  DropdownMenuItem<String?>(
                                    value: null,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.block_rounded,
                                          size: 16,
                                          color: AquaColors.textMuted,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Sin empresa asignada (Inventario)',
                                          style: GoogleFonts.montserrat(
                                            color: AquaColors.textMuted,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ...kDefaultClients.map((c) {
                                    return DropdownMenuItem<String?>(
                                      value: c.id,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.business_rounded,
                                            size: 16,
                                            color: AquaColors.turquoise,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              c.companyName,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (val) {
                                  setModalState(() {
                                    selectedClientId = val;
                                    ClientItem? client;
                                    for (final item in kDefaultClients) {
                                      if (item.id == val) {
                                        client = item;
                                        break;
                                      }
                                    }
                                    final allowedZones =
                                        client?.hasQrScanning == true
                                        ? client!.zoneNames
                                        : kDefaultZones
                                              .map((zone) => zone.name)
                                              .toList();
                                    if (!allowedZones.contains(selectedZone)) {
                                      selectedZone = allowedZones.isEmpty
                                          ? ''
                                          : allowedZones.first;
                                    }
                                    error = null;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Selector de Zona Asignada
                          Text(
                            'Zona de ubicación',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AquaColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AquaColors.platinum,
                                width: 1.2,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: zones.contains(selectedZone)
                                    ? selectedZone
                                    : null,
                                isExpanded: true,
                                hint: Text(
                                  selectedClient?.hasQrScanning == true
                                      ? 'Cliente sin zonas QR habilitadas'
                                      : 'Selecciona una zona',
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AquaColors.slateBlue,
                                ),
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AquaColors.textPrimary,
                                ),
                                items: zones.map((z) {
                                  return DropdownMenuItem(
                                    value: z,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 16,
                                          color: AquaColors.turquoise,
                                        ),
                                        const SizedBox(width: 8),
                                        Text('Zona $z'),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: zones.isEmpty
                                    ? null
                                    : (val) {
                                        if (val != null) {
                                          setModalState(
                                            () => selectedZone = val,
                                          );
                                        }
                                      },
                              ),
                            ),
                          ),
                          if (selectedClient?.hasQrScanning == true &&
                              zones.isEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Configura las zonas QR del cliente en Clientes antes de asignar este despachador.',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: AquaColors.statusError,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),

                          // Estado Activo / Inactivo
                          Text(
                            'Estado operativo del despachador',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AquaColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () =>
                                      setModalState(() => isActive = true),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? AquaColors.statusSupplied
                                                .withValues(alpha: 0.12)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isActive
                                            ? AquaColors.statusSupplied
                                            : AquaColors.platinum,
                                        width: isActive ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          size: 16,
                                          color: isActive
                                              ? AquaColors.statusSupplied
                                              : AquaColors.textMuted,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Activo',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: isActive
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
                                  onTap: () =>
                                      setModalState(() => isActive = false),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !isActive
                                          ? Colors.amber.withValues(alpha: 0.18)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: !isActive
                                            ? Colors.amber.shade800
                                            : AquaColors.platinum,
                                        width: !isActive ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.pause_circle_filled_rounded,
                                          size: 16,
                                          color: !isActive
                                              ? Colors.amber.shade900
                                              : AquaColors.textMuted,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Inactivo',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: !isActive
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

                          if (error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              error!,
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AquaColors.statusError,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),

                          AquaButton(
                            text: 'Guardar cambios',
                            icon: Icons.check_circle_outline_rounded,
                            height: 46,
                            onPressed: () {
                              final rawId = idCtrl.text.trim();
                              final cleanId = rawId.startsWith('#')
                                  ? rawId
                                  : '#$rawId';
                              if (rawId.isEmpty) {
                                setModalState(
                                  () => error =
                                      'Ingresa el número o identificador.',
                                );
                                return;
                              }
                              if (zones.isEmpty ||
                                  !zones.contains(selectedZone)) {
                                setModalState(
                                  () => error =
                                      'Selecciona una zona permitida para esta empresa.',
                                );
                                return;
                              }

                              final updatedDispenser = dispenser.copyWith(
                                id: cleanId,
                                clientId: selectedClientId ?? '',
                                brand: brandCtrl.text.trim().isEmpty
                                    ? dispenser.brand
                                    : brandCtrl.text.trim(),
                                model: modelCtrl.text.trim().isEmpty
                                    ? dispenser.model
                                    : modelCtrl.text.trim(),
                                serialNumber: serialCtrl.text.trim(),
                                isActive: isActive,
                              );

                              // Actualizar despachador en su zona
                              updateDispenser(
                                currentZoneName: entry.zoneName,
                                currentDispenserId: dispenser.id,
                                updatedItem: updatedDispenser,
                                targetZoneName: selectedZone,
                              );

                              // Reasignar empresa cliente si cambió
                              if (selectedClientId != null) {
                                final clientIndex = kDefaultClients.indexWhere(
                                  (c) => c.id == selectedClientId,
                                );
                                if (clientIndex != -1) {
                                  final client = kDefaultClients[clientIndex];
                                  final newIds = List<String>.from(
                                    client.assignedDispenserIds,
                                  );
                                  if (!newIds.contains(cleanId)) {
                                    newIds.add(cleanId);
                                    assignDispensersToClient(client.id, newIds);
                                  }
                                }
                              } else {
                                // Quitar de cualquier cliente si se dejó sin asignar
                                for (final c in kDefaultClients) {
                                  if (c.assignedDispenserIds.contains(
                                        dispenser.id,
                                      ) ||
                                      c.assignedDispenserIds.contains(
                                        cleanId,
                                      )) {
                                    final updatedList = c.assignedDispenserIds
                                        .where(
                                          (id) =>
                                              id != dispenser.id &&
                                              id != cleanId,
                                        )
                                        .toList();
                                    assignDispensersToClient(c.id, updatedList);
                                  }
                                }
                              }

                              Navigator.of(modalCtx).pop();
                              setState(() {});

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AquaColors.turquoise,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Despachador $cleanId guardado exitosamente',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Modal de detalle completo con opciones de edición y activación/desactivación
  void _showDispenserDetailModal(ZoneDispenserEntry entry) {
    final dispenser = entry.dispenser;
    final client = getClientForDispenser(dispenser.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final isCurrentlyActive = dispenser.isActive;
          final isZoneAssignedToClient =
              client?.zoneNames.any(
                (zoneName) =>
                    zoneName.trim().toLowerCase() ==
                    entry.zoneName.trim().toLowerCase(),
              ) ??
              false;

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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrentlyActive
                            ? AquaColors.statusSupplied.withValues(alpha: 0.14)
                            : Colors.amber.withValues(alpha: 0.16),
                      ),
                      child: Icon(
                        Icons.water_drop_rounded,
                        color: isCurrentlyActive
                            ? AquaColors.statusSupplied
                            : Colors.amber.shade900,
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
                              Text(
                                'Despachador ${dispenser.id}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AquaColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildActiveStatusBadge(isCurrentlyActive),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${dispenser.brand} ${dispenser.model}',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AquaColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AquaColors.textSecondary,
                      ),
                      onPressed: () => Navigator.of(modalCtx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Botones rápidos: Editar y Activar/Desactivar
                Row(
                  children: [
                    Expanded(
                      child: AquaButton(
                        text: 'Editar Equipo',
                        icon: Icons.edit_rounded,
                        type: AquaButtonType.secondary,
                        height: 40,
                        onPressed: () {
                          Navigator.of(modalCtx).pop();
                          _showEditDispenserDialog(entry);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AquaButton(
                        text: isCurrentlyActive ? 'Desactivar' : 'Activar',
                        icon: isCurrentlyActive
                            ? Icons.pause_circle_outline_rounded
                            : Icons.play_circle_outline_rounded,
                        type: AquaButtonType.secondary,
                        height: 40,
                        onPressed: () {
                          toggleDispenserStatus(dispenser.id);
                          Navigator.of(modalCtx).pop();
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: isCurrentlyActive
                                  ? Colors.amber.shade900
                                  : AquaColors.turquoise,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              content: Text(
                                isCurrentlyActive
                                    ? 'Despachador ${dispenser.id} desactivado'
                                    : 'Despachador ${dispenser.id} reactivado',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Botón Ver QR
                AquaButton(
                  text: 'Ver código QR',
                  icon: Icons.qr_code_rounded,
                  type: AquaButtonType.secondary,
                  height: 40,
                  onPressed: () {
                    Navigator.of(modalCtx).pop();
                    _openDispenserQr(entry);
                  },
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Información del Despachador
                        _buildDetailSectionTitle('Información del Despachador'),
                        const SizedBox(height: 8),
                        _buildDetailCard(
                          children: [
                            _buildDetailRow('Identificador', dispenser.id),
                            _buildDetailRow('Marca', dispenser.brand),
                            _buildDetailRow(
                              'Número de Serie',
                              dispenser.serialNumber.isNotEmpty
                                  ? dispenser.serialNumber
                                  : 'No registrado',
                            ),
                            _buildDetailRow(
                              'Estado',
                              isCurrentlyActive ? 'Activo' : 'Inactivo',
                              highlight: isCurrentlyActive,
                            ),
                            _buildDetailRow(
                              'Empresa cliente asignada',
                              client != null
                                  ? client.companyName
                                  : 'Sin cliente asignado',
                              icon: Icons.business_outlined,
                              highlight: client != null,
                            ),
                            if (isZoneAssignedToClient)
                              _buildDetailRow(
                                'Zona',
                                entry.zoneName,
                                icon: Icons.location_on_outlined,
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Botón Eliminar
                        AquaButton(
                          text: 'Eliminar Despachador',
                          type: AquaButtonType.danger,
                          icon: Icons.delete_outline_rounded,
                          height: 44,
                          onPressed: () {
                            Navigator.of(modalCtx).pop();
                            _confirmDeleteDispenser(entry);
                          },
                        ),
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

  void _confirmDeleteDispenser(ZoneDispenserEntry entry) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassCard(
          borderRadius: 22,
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AquaColors.statusError.withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: AquaColors.statusError,
                  size: 26,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Eliminar Despachador',
                style: GoogleFonts.montserrat(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AquaColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¿Estás seguro de que deseas eliminar el despachador ${entry.dispenser.id} (${entry.dispenser.brand} ${entry.dispenser.model}) de la zona ${entry.zoneName}?\n\nEsta acción no se puede deshacer.',
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
                    child: AquaButton(
                      text: 'Cancelar',
                      type: AquaButtonType.secondary,
                      height: 44,
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AquaButton(
                      text: 'Eliminar',
                      type: AquaButtonType.danger,
                      height: 44,
                      onPressed: () {
                        deleteDispenser(entry.zoneName, entry.dispenser.id);
                        Navigator.of(dialogCtx).pop();
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AquaColors.statusError,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            content: Text(
                              'Despachador ${entry.dispenser.id} eliminado',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
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
      ),
    );
  }

  Widget _buildActiveStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? AquaColors.statusSupplied.withValues(alpha: 0.12)
            : Colors.amber.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? AquaColors.statusSupplied : Colors.amber.shade700,
        ),
      ),
      child: Text(
        isActive ? 'Activo' : 'Inactivo',
        style: GoogleFonts.montserrat(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: isActive ? AquaColors.statusSupplied : Colors.amber.shade900,
        ),
      ),
    );
  }

  Widget _buildDetailSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AquaColors.textPrimary,
      ),
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
            Icon(icon, size: 14, color: AquaColors.textMuted),
            const SizedBox(width: 4),
          ],
          SizedBox(
            width: 130,
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

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
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
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AquaColors.platinum, width: 1.2),
          ),
          child: TextField(
            controller: controller,
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
    final all = _allEntries;
    final filtered = _filteredEntries;

    final activeCount = all.where((e) => e.dispenser.isActive).length;
    final inactiveCount = all.where((e) => !e.dispenser.isActive).length;
    final assignedCount = all
        .where((e) => getClientForDispenser(e.dispenser.id) != null)
        .length;

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
                            'Despachadores',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AquaColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Catálogo y registro de equipos',
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
                        '${all.length} Equipos',
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

                // Resumen de equipos (sin métricas de abastecimiento)
                Row(
                  children: [
                    _buildMiniKpi(
                      label: 'Total',
                      value: '${all.length}',
                      color: AquaColors.slateBlue,
                    ),
                    const SizedBox(width: 8),
                    _buildMiniKpi(
                      label: 'Activos',
                      value: '$activeCount',
                      color: AquaColors.statusSupplied,
                    ),
                    const SizedBox(width: 8),
                    _buildMiniKpi(
                      label: 'Inactivos',
                      value: '$inactiveCount',
                      color: Colors.amber.shade900,
                    ),
                    const SizedBox(width: 8),
                    _buildMiniKpi(
                      label: 'Asignados',
                      value: '$assignedCount',
                      color: AquaColors.turquoise,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Buscador
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
                          'Buscar por #ID, marca, modelo, zona o empresa...',
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

                // Filtro de Estado Operativo (Activos / Inactivos)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip('Todos (${all.length})', 'Todos'),
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

                // ── Botón para registrar nuevos despachadores (encima de las cards) ──
                AquaButton(
                  text: 'Registrar nuevo despachador',
                  icon: Icons.add_circle_outline_rounded,
                  height: 46,
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RegisterDispenserScreen(),
                      ),
                    );
                    setState(() {});
                  },
                ),
                const SizedBox(height: 14),

                // ── Lista de cards de todos los despachadores ──
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No se encontraron despachadores con ese filtro',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AquaColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final entry = filtered[index];
                            final dispenser = entry.dispenser;
                            final client = getClientForDispenser(dispenser.id);
                            final isActive = dispenser.isActive;

                            return RepaintBoundary(
                              child: GlassCard(
                                borderRadius: 16,
                                padding: const EdgeInsets.all(14),
                                onTap: () => _showDispenserDetailModal(entry),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isActive
                                                ? AquaColors.statusSupplied
                                                      .withValues(alpha: 0.12)
                                                : Colors.amber.withValues(
                                                    alpha: 0.16,
                                                  ),
                                          ),
                                          child: Icon(
                                            Icons.water_drop_rounded,
                                            size: 22,
                                            color: isActive
                                                ? AquaColors.statusSupplied
                                                : Colors.amber.shade900,
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
                                                    style:
                                                        GoogleFonts.montserrat(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: AquaColors
                                                              .textPrimary,
                                                        ),
                                                  ),
                                                  const Spacer(),
                                                  _buildActiveStatusBadge(
                                                    isActive,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                dispenser.brand,
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      AquaColors.textSecondary,
                                                ),
                                              ),
                                              if (dispenser
                                                  .serialNumber
                                                  .isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'S/N: ${dispenser.serialNumber}',
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 10,
                                                    color: AquaColors.textMuted,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Chips con Zona y Empresa
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AquaColors.slateBlue
                                                .withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: AquaColors.slateBlue
                                                  .withValues(alpha: 0.25),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.location_on_outlined,
                                                size: 11,
                                                color: AquaColors.slateBlue,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                'Zona ${entry.zoneName}',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: AquaColors.slateBlue,
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
                                            color: client != null
                                                ? AquaColors.turquoise
                                                      .withValues(alpha: 0.08)
                                                : AquaColors.platinum
                                                      .withValues(alpha: 0.4),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: client != null
                                                  ? AquaColors.turquoise
                                                        .withValues(alpha: 0.25)
                                                  : AquaColors.platinum,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.business_outlined,
                                                size: 11,
                                                color: client != null
                                                    ? AquaColors.turquoise
                                                    : AquaColors.textMuted,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                client != null
                                                    ? client.companyName
                                                    : 'Sin empresa asignada',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: client != null
                                                      ? AquaColors.turquoise
                                                      : AquaColors.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Barra inferior de acciones rápidas (Editar y Activar/Desactivar)
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () =>
                                              _showEditDispenserDialog(entry),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AquaColors.glacier
                                                  .withValues(alpha: 0.4),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: AquaColors.platinum,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.edit_rounded,
                                                  size: 13,
                                                  color: AquaColors.slateBlue,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Editar',
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: AquaColors.slateBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () {
                                            toggleDispenserStatus(dispenser.id);
                                            setState(() {});
                                          },
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isActive
                                                  ? Colors.amber.withValues(
                                                      alpha: 0.12,
                                                    )
                                                  : AquaColors.statusSupplied
                                                        .withValues(
                                                          alpha: 0.10,
                                                        ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isActive
                                                    ? Colors.amber.shade700
                                                          .withValues(
                                                            alpha: 0.5,
                                                          )
                                                    : AquaColors.statusSupplied
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isActive
                                                      ? Icons
                                                            .pause_circle_outline_rounded
                                                      : Icons
                                                            .play_circle_outline_rounded,
                                                  size: 13,
                                                  color: isActive
                                                      ? Colors.amber.shade900
                                                      : AquaColors
                                                            .statusSupplied,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  isActive
                                                      ? 'Desactivar'
                                                      : 'Activar',
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: isActive
                                                        ? Colors.amber.shade900
                                                        : AquaColors
                                                              .statusSupplied,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            Text(
                                              'Detalle',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: AquaColors.turquoise,
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 9,
                                              color: AquaColors.turquoise,
                                            ),
                                          ],
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

  Widget _buildMiniKpi({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AquaColors.platinum),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: AquaColors.textMuted,
              ),
            ),
          ],
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
