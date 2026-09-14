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

  List<ClientItem> get _filteredClients {
    if (_searchQuery.trim().isEmpty) return kDefaultClients;
    return kDefaultClients.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.companyName.toLowerCase().contains(q) ||
          c.contactPerson.toLowerCase().contains(q) ||
          c.address.toLowerCase().contains(q);
    }).toList();
  }

  void _showAddClientDialog() {
    final nameCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String selectedFrequency = 'Semanal';
    int dispensersCount = 4;
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
                maxHeight: MediaQuery.of(modalCtx).size.height * 0.88,
              ),
              child: SingleChildScrollView(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Registrar Nueva Empresa Cliente',
                          style: GoogleFonts.montserrat(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AquaColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AquaColors.textSecondary, size: 20),
                          onPressed: () => Navigator.of(modalCtx).pop(),
                        ),
                      ],
                    ),
                    Text(
                      'Agrega una empresa u organización a la que abastece la purificadora',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AquaColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Inputs
                    _buildTextField(
                      controller: nameCtrl,
                      label: 'Nombre de la empresa / cliente',
                      hint: 'Ej. Grupo Bimbo Planta Norte',
                      icon: Icons.business_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: contactCtrl,
                      label: 'Persona de contacto / Enlace',
                      hint: 'Ej. Lic. Fernando Garza',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 12),
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: emailCtrl,
                            label: 'Correo',
                            hint: 'contacto@empresa.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: addressCtrl,
                      label: 'Dirección / Ubicación de planta',
                      hint: 'Ej. Parque Industrial Norte, Nave 4',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 14),

                    // Frecuencia
                    Text(
                      'Frecuencia de abastecimiento',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AquaColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: ['Diario', 'Cada 2 días', 'Semanal', 'Quincenal']
                          .map((freq) {
                        final isSel = selectedFrequency == freq;
                        return ChoiceChip(
                          label: Text(
                            freq,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: isSel ? Colors.white : AquaColors.textPrimary,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: AquaColors.turquoise,
                          backgroundColor: AquaColors.glacier.withValues(alpha: 0.4),
                          side: BorderSide(
                            color: isSel
                                ? AquaColors.turquoise
                                : AquaColors.platinum,
                          ),
                          onSelected: (_) => setModalState(() => selectedFrequency = freq),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Dispensers count stepper
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Despachadores instalados:',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AquaColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: AquaColors.turquoise, size: 22),
                              onPressed: () {
                                if (dispensersCount > 1) {
                                  setModalState(() => dispensersCount--);
                                }
                              },
                            ),
                            Text(
                              '$dispensersCount',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AquaColors.textPrimary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: AquaColors.turquoise, size: 22),
                              onPressed: () => setModalState(() => dispensersCount++),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

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
                      text: 'Guardar empresa cliente',
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        final contact = contactCtrl.text.trim();
                        final phone = phoneCtrl.text.trim();
                        final email = emailCtrl.text.trim();
                        final address = addressCtrl.text.trim();

                        if (name.isEmpty) {
                          setModalState(() => formError = 'Ingresa el nombre de la empresa.');
                          return;
                        }

                        final newClient = ClientItem(
                          id: 'CLI-${DateTime.now().millisecondsSinceEpoch % 10000}',
                          companyName: name,
                          contactPerson: contact.isEmpty ? 'Contacto general' : contact,
                          phone: phone.isEmpty ? 'Sin teléfono' : phone,
                          email: email.isEmpty ? 'Sin correo' : email,
                          address: address.isEmpty ? 'Dirección no especificada' : address,
                          activeDispensers: dispensersCount,
                          deliveryFrequency: selectedFrequency,
                          notes: notesCtrl.text.trim(),
                        );

                        addClient(newClient);
                        Navigator.of(modalCtx).pop();
                        setState(() {});

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AquaColors.turquoise,
                            content: Text(
                              'Empresa "$name" registrada correctamente',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
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
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AquaColors.platinum, width: 1.2),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final clients = _filteredClients;

    return Scaffold(
      body: AquaBackground(
        child: SafeArea(
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
                            'Clientes y Empresas',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AquaColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Empresas abastecidas por la purificadora',
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AquaColors.glacier.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AquaColors.slateBlue.withValues(alpha: 0.4)),
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
                const SizedBox(height: 14),

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
                      hintText: 'Buscar por empresa, contacto o zona...',
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: AquaColors.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Register Button
                AquaButton(
                  text: 'Registrar nueva empresa cliente',
                  icon: Icons.add_business_rounded,
                  height: 44,
                  onPressed: _showAddClientDialog,
                ),
                const SizedBox(height: 16),

                // Clients List
                Expanded(
                  child: clients.isEmpty
                      ? Center(
                          child: Text(
                            'No se encontraron empresas',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AquaColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: clients.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final client = clients[index];
                            return GlassCard(
                              borderRadius: 16,
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AquaColors.glacier.withValues(alpha: 0.5),
                                          border: Border.all(
                                            color: AquaColors.slateBlue.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.business_rounded,
                                          color: AquaColors.turquoise,
                                          size: 19,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              client.companyName,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AquaColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Contacto: ${client.contactPerson}',
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
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AquaColors.glacier.withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: AquaColors.platinum,
                                          ),
                                        ),
                                        child: Text(
                                          client.deliveryFrequency,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AquaColors.turquoise,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 14,
                                        color: AquaColors.textSecondary,
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          client.address,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: AquaColors.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AquaColors.glacier.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AquaColors.platinum),
                                        ),
                                        child: Text(
                                          '${client.activeDispensers} despachadores',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 10,
                                            color: AquaColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (client.phone.isNotEmpty || client.email.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        if (client.phone.isNotEmpty) ...[
                                          const Icon(
                                            Icons.phone_outlined,
                                            size: 12,
                                            color: AquaColors.textMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            client.phone,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 10,
                                              color: AquaColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        if (client.email.isNotEmpty) ...[
                                          const Icon(
                                            Icons.email_outlined,
                                            size: 12,
                                            color: AquaColors.textMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              client.email,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 10,
                                                color: AquaColors.textSecondary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ],
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
}
