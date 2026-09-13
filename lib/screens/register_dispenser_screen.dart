import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';

class RegisterDispenserScreen extends StatefulWidget {
  const RegisterDispenserScreen({super.key});

  @override
  State<RegisterDispenserScreen> createState() => _RegisterDispenserScreenState();
}

class _RegisterDispenserScreenState extends State<RegisterDispenserScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _zonaController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  bool _isLoading = false;
  bool _saved = false;

  final List<String> _zonasDisponibles = [
    'Producción',
    'Almacén',
    'Taller',
    'Oficinas',
    'Mantenimiento',
    'Calidad',
  ];
  String? _zonaSeleccionada;

  @override
  void dispose() {
    _zonaController.dispose();
    _numeroController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final idText = _numeroController.text.trim();
    final newDispenser = DispenserItem(
      id: idText.startsWith('#') ? idText : '#$idText',
      brand: _marcaController.text.trim(),
      model: _modeloController.text.trim(),
      serialNumber: 'SN${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      status: DispenserStatus.supplied,
      lastSupplyInfo: 'Registrado hoy',
    );
    if (_zonaSeleccionada != null) {
      addDispenser(_zonaSeleccionada!, newDispenser);
    }

    // Simulated async save
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _saved = true;
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaBackground(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AquaColors.icyBlue),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Registrar Despachador',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Illustration / icon header
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0x334E78E6),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AquaColors.cornflowerBlue.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AquaColors.cornflowerBlue.withValues(alpha: 0.25),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.water_drop_outlined,
                            color: AquaColors.icyBlue,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Nuevo despachador',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: AquaColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      GlassCard(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(20),
                        backgroundColor: const Color(0x26233C78),
                        borderColor: AquaColors.glassBorderSubtle,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('Información de ubicación'),
                            const SizedBox(height: 14),

                            // Zona - Dropdown
                            _buildLabel('Zona / Punto'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _zonaSeleccionada,
                              dropdownColor: const Color(0xFF0F1D4D),
                              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: AquaColors.icyBlue),
                                hintText: 'Selecciona la zona',
                                hintStyle: GoogleFonts.montserrat(color: AquaColors.textMuted, fontSize: 14),
                              ),
                              items: _zonasDisponibles.map((zona) {
                                return DropdownMenuItem<String>(
                                  value: zona,
                                  child: Text(zona),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _zonaSeleccionada = val),
                              validator: (val) => val == null ? 'Selecciona una zona' : null,
                            ),
                            const SizedBox(height: 16),

                            // Número de despachador
                            _buildLabel('Número de despachador'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _numeroController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.tag_rounded, size: 20, color: AquaColors.icyBlue),
                                hintText: 'Ej. 024',
                                hintStyle: GoogleFonts.montserrat(color: AquaColors.textMuted, fontSize: 14),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Ingresa el número';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      GlassCard(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(20),
                        backgroundColor: const Color(0x26233C78),
                        borderColor: AquaColors.glassBorderSubtle,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('Datos del equipo'),
                            const SizedBox(height: 14),

                            // Marca
                            _buildLabel('Marca'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _marcaController,
                              textCapitalization: TextCapitalization.words,
                              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.business_outlined, size: 20, color: AquaColors.icyBlue),
                                hintText: 'Ej. EcoWater',
                                hintStyle: GoogleFonts.montserrat(color: AquaColors.textMuted, fontSize: 14),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Ingresa la marca';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Modelo
                            _buildLabel('Modelo'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _modeloController,
                              textCapitalization: TextCapitalization.characters,
                              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.settings_outlined, size: 20, color: AquaColors.icyBlue),
                                hintText: 'Ej. E-200',
                                hintStyle: GoogleFonts.montserrat(color: AquaColors.textMuted, fontSize: 14),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Ingresa el modelo';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Success state
                      if (_saved)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AquaColors.statusSuppliedBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AquaColors.statusSupplied.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, color: AquaColors.statusSupplied, size: 22),
                              const SizedBox(width: 12),
                              Text(
                                '¡Despachador registrado exitosamente!',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
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
            color: AquaColors.cornflowerBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AquaColors.textSecondary,
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
        fontWeight: FontWeight.w500,
        color: AquaColors.textSecondary,
      ),
    );
  }
}
