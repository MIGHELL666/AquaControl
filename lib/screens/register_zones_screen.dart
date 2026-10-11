import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../services/supabase_service.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';

class RegisterZonesScreen extends StatefulWidget {
  const RegisterZonesScreen({super.key});

  @override
  State<RegisterZonesScreen> createState() => _RegisterZonesScreenState();
}

class _RegisterZonesScreenState extends State<RegisterZonesScreen> {
  final _nameController = TextEditingController();
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    SupabaseService.syncZonesFromSupabase().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveZone() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Escribe el nombre de la zona.');
      return;
    }
    if (kDefaultZones.any(
      (zone) => zone.name.trim().toLowerCase() == name.toLowerCase(),
    )) {
      setState(() => _error = 'Ya existe una zona con ese nombre.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await SupabaseService.client.from('zones').insert({'name': name});
      addZone(ZoneItem(name: name, subtitle: '', dispensers: []));
      _nameController.clear();
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Zona "$name" registrada.')));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _error =
            'No se pudo guardar la zona. Verifica si ya existe e inténtalo de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final zones = [...kDefaultZones]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      body: AquaBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 12),
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
                    Expanded(
                      child: Text(
                        'Registrar zonas',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AquaColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    GlassCard(
                      borderRadius: 18,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nueva zona de la empresa',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AquaColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Registra áreas, naves o edificios donde se instalarán despachadores. Después podrás elegir estas zonas al configurar cada cliente.',
                            style: GoogleFonts.montserrat(
                              fontSize: 11.5,
                              height: 1.4,
                              color: AquaColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              labelText: 'Nombre de la zona',
                              hintText: 'Ej. Producción, Almacén, Oficinas',
                              prefixIcon: const Icon(
                                Icons.location_on_outlined,
                                color: AquaColors.turquoise,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onSubmitted: (_) => _saveZone(),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          AquaButton(
                            text: 'Registrar zona',
                            icon: Icons.add_location_alt_outlined,
                            isLoading: _isSaving,
                            onPressed: _saveZone,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Zonas registradas (${zones.length})',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AquaColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (zones.isEmpty)
                      const GlassCard(
                        borderRadius: 16,
                        padding: EdgeInsets.all(18),
                        child: Text('Aún no hay zonas registradas.'),
                      )
                    else
                      ...zones.map(
                        (zone) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GlassCard(
                            borderRadius: 14,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: AquaColors.turquoise,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    zone.name,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AquaColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${zone.dispensers.length} despachadores',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    color: AquaColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
