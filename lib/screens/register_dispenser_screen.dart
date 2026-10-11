import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../services/supabase_service.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';
import 'dispenser_qr_screen.dart';

class RegisterDispenserScreen extends StatefulWidget {
  const RegisterDispenserScreen({super.key});

  @override
  State<RegisterDispenserScreen> createState() =>
      _RegisterDispenserScreenState();
}

class _RegisterDispenserScreenState extends State<RegisterDispenserScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _serieController = TextEditingController();
  late String _autoNumeroDespachador;
  bool _isLoading = false;
  bool _saved = false;
  String? _selectedClientId;
  String? _selectedZone;

  @override
  void initState() {
    super.initState();
    _autoNumeroDespachador = _generarSiguienteNumeroDespachador();
    _loadRegistrationOptions();
  }

  Future<void> _loadRegistrationOptions() async {
    await SupabaseService.syncClientsFromSupabase();
    await SupabaseService.syncZonesFromSupabase();
    await SupabaseService.syncDispensersFromSupabase();
    if (!mounted) return;
    setState(() {
      _autoNumeroDespachador = _generarSiguienteNumeroDespachador();
      _selectedZone = _availableZones.isEmpty ? null : _availableZones.first;
    });
  }

  ClientItem? get _selectedClient {
    for (final client in kDefaultClients) {
      if (client.id == _selectedClientId) return client;
    }
    return null;
  }

  List<String> get _availableZones {
    final client = _selectedClient;
    final zoneNames = client?.hasQrScanning == true
        ? client!.zoneNames
        : kDefaultZones.map((zone) => zone.name).toList();
    return zoneNames.where((name) => name.trim().isNotEmpty).toList();
  }

  /// Calcula el siguiente número de despachador automáticamente (ej. #001, #002...)
  String _generarSiguienteNumeroDespachador() {
    int maxNum = 0;
    for (final zone in kDefaultZones) {
      for (final d in zone.dispensers) {
        final digits = d.id.replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.isNotEmpty) {
          final parsed = int.tryParse(digits) ?? 0;
          if (parsed > maxNum) maxNum = parsed;
        }
      }
    }
    final next = maxNum + 1;
    return '#${next.toString().padLeft(3, '0')}';
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _serieController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_availableZones.isEmpty || !_availableZones.contains(_selectedZone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedClient?.hasQrScanning == true
                ? 'Este cliente no tiene zonas QR habilitadas. Configúralas en Clientes antes de registrar el despachador.'
                : 'Selecciona una zona para el despachador.',
          ),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    final qrToken = _generateQrToken();
    final selectedClient = _selectedClient;
    final targetZone = _selectedZone!;
    final newDispenser = DispenserItem(
      id: _autoNumeroDespachador,
      brand: _marcaController.text.trim(),
      model: 'Estándar',
      serialNumber: _serieController.text.trim(),
      qrToken: qrToken,
      clientId: selectedClient?.id ?? '',
      status: DispenserStatus.pending,
      lastSupplyInfo: 'Pendiente de abastecer',
    );

    addDispenser(targetZone, newDispenser);
    if (selectedClient != null) {
      assignDispensersToClient(selectedClient.id, [
        ...selectedClient.assignedDispenserIds,
        _autoNumeroDespachador,
      ]);
    }

    // Guardar también en la base de datos Supabase si la tabla existe
    try {
      await SupabaseService.client.from('dispensers').insert({
        'id': _autoNumeroDespachador,
        'brand': _marcaController.text.trim(),
        'model': 'Estándar',
        'serial_number': _serieController.text.trim(),
        'qr_token': qrToken,
        'zone_name': targetZone,
        'client_id': selectedClient?.id,
        'status': 'pending',
        'last_supply_info': 'Pendiente de abastecer',
      });
    } catch (_) {
      // El registro local se conserva si Supabase no está disponible.
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _saved = true;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    // Navigate to QR screen to show the generated code
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DispenserQrScreen(
          dispenserId: _autoNumeroDespachador,
          brand: _marcaController.text.trim(),
          serialNumber: _serieController.text.trim(),
          qrToken: qrToken,
        ),
      ),
    );
  }

  String _generateQrToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaBackground(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Row(
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
                  Text(
                    'Registrar Despachador',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AquaColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 8.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Illustration / icon header
                      Center(
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AquaColors.platinum,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AquaColors.shadowCard,
                                blurRadius: 18,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.water_drop_rounded,
                            color: AquaColors.turquoise,
                            size: 38,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Nuevo despachador',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AquaColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      GlassCard(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('Datos del despachador'),
                            const SizedBox(height: 16),

                            _buildLabel('Empresa cliente asignada'),
                            const SizedBox(height: 8),
                            _buildDropdown<String?>(
                              value: _selectedClientId,
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Sin cliente asignado'),
                                ),
                                ...kDefaultClients.map(
                                  (client) => DropdownMenuItem<String?>(
                                    value: client.id,
                                    child: Text(
                                      client.companyName,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedClientId = value;
                                  final zones = _availableZones;
                                  _selectedZone = zones.isEmpty
                                      ? null
                                      : zones.first;
                                });
                              },
                            ),
                            const SizedBox(height: 18),

                            _buildLabel('Zona'),
                            const SizedBox(height: 8),
                            _buildDropdown<String>(
                              value: _availableZones.contains(_selectedZone)
                                  ? _selectedZone
                                  : null,
                              items: _availableZones
                                  .map(
                                    (zone) => DropdownMenuItem<String>(
                                      value: zone,
                                      child: Text('Zona $zone'),
                                    ),
                                  )
                                  .toList(),
                              hint: _selectedClient?.hasQrScanning == true
                                  ? 'Sin zonas habilitadas'
                                  : 'Selecciona una zona',
                              onChanged: _availableZones.isEmpty
                                  ? null
                                  : (value) =>
                                        setState(() => _selectedZone = value),
                            ),
                            if (_selectedClient?.hasQrScanning == true &&
                                _availableZones.isEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Agrega zonas QR a este cliente desde Clientes para poder asignarle despachadores.',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  color: AquaColors.statusError,
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),

                            // Número de despachador automático (Informativo / no editable)
                            _buildLabel('Número de despachador (Automático)'),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: AquaColors.iceBlue.withValues(
                                  alpha: 0.35,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AquaColors.turquoise.withValues(
                                    alpha: 0.35,
                                  ),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AquaColors.turquoise.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.tag_rounded,
                                      size: 18,
                                      color: AquaColors.turquoise,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Despachador $_autoNumeroDespachador',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AquaColors.turquoise,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AquaColors.turquoise,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Auto',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Campo: Marca
                            _buildLabel('Marca'),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AquaColors.platinum),
                              ),
                              child: TextFormField(
                                controller: _marcaController,
                                textCapitalization: TextCapitalization.words,
                                style: GoogleFonts.montserrat(
                                  color: AquaColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.business_outlined,
                                    size: 20,
                                    color: AquaColors.turquoise,
                                  ),
                                  hintText: 'Ej. EcoWater, Mabe, Oasis...',
                                  hintStyle: GoogleFonts.montserrat(
                                    color: AquaColors.textMuted,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Por favor ingresa la marca';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Campo: Número de serie
                            _buildLabel('Número de serie'),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AquaColors.platinum),
                              ),
                              child: TextFormField(
                                controller: _serieController,
                                textCapitalization:
                                    TextCapitalization.characters,
                                style: GoogleFonts.montserrat(
                                  color: AquaColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.qr_code_rounded,
                                    size: 20,
                                    color: AquaColors.turquoise,
                                  ),
                                  hintText: 'Ej. SN892344, 482019...',
                                  hintStyle: GoogleFonts.montserrat(
                                    color: AquaColors.textMuted,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Por favor ingresa el número de serie';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Success state
                      if (_saved)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 18,
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AquaColors.statusSuppliedBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AquaColors.statusSuppliedBorder,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                color: AquaColors.statusSupplied,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '¡Despachador registrado exitosamente!',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AquaColors.statusSupplied,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Save button
                      AquaButton(
                        text: 'Registrar despachador',
                        icon: Icons.add_circle_outline_rounded,
                        isLoading: _isLoading,
                        onPressed: _onSave,
                      ),
                      const SizedBox(height: 12),
                      AquaButton(
                        text: 'Cancelar',
                        type: AquaButtonType.secondary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AquaColors.turquoise,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AquaColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AquaColors.textSecondary,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    String? hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AquaColors.platinum),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: hint == null ? null : Text(hint),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
