import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../services/supabase_service.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_button.dart';
import '../widgets/glass_card.dart';

class WorkersManagementScreen extends StatefulWidget {
  const WorkersManagementScreen({super.key});

  @override
  State<WorkersManagementScreen> createState() => _WorkersManagementScreenState();
}

class _WorkersManagementScreenState extends State<WorkersManagementScreen> {
  String _searchQuery = '';

  List<WorkerItem> get _filteredWorkers {
    if (_searchQuery.trim().isEmpty) return kDefaultWorkers;
    return kDefaultWorkers.where((w) {
      final q = _searchQuery.toLowerCase();
      final matchesClient = w.assignedClients.any((c) => c.toLowerCase().contains(q));
      return w.name.toLowerCase().contains(q) ||
          w.employeeNumber.toLowerCase().contains(q) ||
          w.assignedZone.toLowerCase().contains(q) ||
          matchesClient;
    }).toList();
  }

  void _showAddWorkerDialog() {
    final nameCtrl = TextEditingController();
    final empNumCtrl = TextEditingController(
      text: 'EMP-${1060 + (kDefaultWorkers.length * 3)}',
    );
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController(text: 'AquaPass2026');
    bool obscurePassword = true;
    final List<String> selectedClients = kDefaultClients.map((c) => c.companyName).toList();
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
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 620,
                  maxHeight: MediaQuery.of(modalCtx).size.height * 0.90,
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
                          children: [
                            Expanded(
                              child: Text(
                                'Registrar Nuevo Trabajador',
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
                              icon: const Icon(Icons.close, color: AquaColors.textSecondary, size: 20),
                              onPressed: () => Navigator.of(modalCtx).pop(),
                            ),
                          ],
                        ),
                        Text(
                          'Crea el perfil del trabajador, asigna su contraseña de acceso y las empresas que va a surtir.',
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
                          label: 'Nombre completo *',
                          hint: 'Ej. Juan Manuel Ramos',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: empNumCtrl,
                                label: 'No. Empleado',
                                hint: 'EMP-1065',
                                icon: Icons.badge_outlined,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: phoneCtrl,
                                label: 'Teléfono',
                                hint: '55 9876 5432',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: emailCtrl,
                          label: 'Correo electrónico (Usuario para iniciar sesión) *',
                          hint: 'trabajador@aquacontrol.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),

                        // Password field
                        _buildTextField(
                          controller: passwordCtrl,
                          label: 'Contraseña de acceso *',
                          hint: 'Mínimo 6 caracteres',
                          icon: Icons.lock_outline_rounded,
                          obscureText: obscurePassword,
                          suffix: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: AquaColors.slateBlue,
                            ),
                            onPressed: () {
                              setModalState(() => obscurePassword = !obscurePassword);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Client Assignment Section
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AquaColors.iceBlue.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AquaColors.slateBlue.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.business_center_rounded,
                                    size: 18,
                                    color: AquaColors.turquoise,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Empresas clientes que va a surtir *',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AquaColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(50, 24),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () {
                                      setModalState(() {
                                        if (selectedClients.length == kDefaultClients.length) {
                                          selectedClients.clear();
                                        } else {
                                          selectedClients.clear();
                                          selectedClients.addAll(kDefaultClients.map((c) => c.companyName));
                                        }
                                      });
                                    },
                                    child: Text(
                                      selectedClients.length == kDefaultClients.length
                                          ? 'Deseleccionar'
                                          : 'Todas',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AquaColors.turquoise,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Selecciona a qué clientes tendrá acceso este trabajador para surtir garrafones o despachadores.',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  color: AquaColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: kDefaultClients.map((client) {
                                  final isSelected = selectedClients.contains(client.companyName);
                                  return FilterChip(
                                    selected: isSelected,
                                    label: Text(client.companyName),
                                    labelStyle: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? Colors.white : AquaColors.textPrimary,
                                    ),
                                    selectedColor: AquaColors.turquoise,
                                    backgroundColor: Colors.white,
                                    checkmarkColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: isSelected ? AquaColors.turquoise : AquaColors.platinum,
                                      ),
                                    ),
                                    onSelected: (val) {
                                      setModalState(() {
                                        if (val) {
                                          if (!selectedClients.contains(client.companyName)) {
                                            selectedClients.add(client.companyName);
                                          }
                                        } else {
                                          selectedClients.remove(client.companyName);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        if (formError != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            formError!,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AquaColors.statusError,
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),

                        // Submit button
                        AquaButton(
                          text: 'Crear perfil y registrar trabajador',
                          icon: Icons.person_add_rounded,
                          onPressed: () async {
                            final name = nameCtrl.text.trim();
                            if (name.isEmpty) {
                              setModalState(() => formError = 'Ingresa el nombre del trabajador.');
                              return;
                            }
                            final password = passwordCtrl.text.trim();
                            if (password.length < 4) {
                              setModalState(() => formError = 'La contraseña debe tener al menos 4 caracteres.');
                              return;
                            }
                            if (selectedClients.isEmpty) {
                              setModalState(() => formError = 'Selecciona al menos una empresa que va a surtir.');
                              return;
                            }

                            final email = emailCtrl.text.trim().isEmpty
                                ? '${name.toLowerCase().replaceAll(' ', '.')}@aquacontrol.com'
                                : emailCtrl.text.trim();
                            final empNumber = empNumCtrl.text.trim().isEmpty
                                ? 'EMP-${1060 + kDefaultWorkers.length}'
                                : empNumCtrl.text.trim();

                            final newWorker = WorkerItem(
                              id: 'WRK-${DateTime.now().millisecondsSinceEpoch % 10000}',
                              name: name,
                              employeeNumber: empNumber,
                              phone: phoneCtrl.text.trim().isEmpty ? '55 0000 0000' : phoneCtrl.text.trim(),
                              email: email,
                              password: password,
                              assignedZone: 'General',
                              shift: 'General',
                              assignedClients: List.from(selectedClients),
                            );

                            try {
                              await SupabaseService.client.from('workers').insert({
                                'name': newWorker.name,
                                'employee_number': newWorker.employeeNumber,
                                'phone': newWorker.phone,
                                'email': newWorker.email,
                                'password': newWorker.password,
                                'assigned_zone': newWorker.assignedZone,
                                'shift': newWorker.shift,
                                'status': newWorker.status,
                                'assigned_clients': newWorker.assignedClients,
                              });
                            } catch (e) {
                              debugPrint('Error al guardar trabajador en Supabase: $e');
                            }

                            addWorker(newWorker);

                            if (modalCtx.mounted) {
                              Navigator.of(modalCtx).pop();
                            }
                            if (mounted) {
                              setState(() {});
                              // Mostrar confirmación de perfil generado para inicio de sesión
                              _showWorkerProfileCreatedDialog(newWorker);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showWorkerProfileCreatedDialog(WorkerItem worker) {
    showDialog(
      context: context,
      builder: (dlgCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
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
                  color: AquaColors.turquoise.withValues(alpha: 0.14),
                  border: Border.all(color: AquaColors.turquoise.withValues(alpha: 0.35)),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AquaColors.turquoise,
                  size: 30,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '¡Perfil Generado Exitosamente!',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AquaColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'El trabajador ya puede iniciar sesión en la app con estas credenciales:',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AquaColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Credential Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AquaColors.platinum),
                ),
                child: Column(
                  children: [
                    _buildCredentialRow('Trabajador:', worker.name, Icons.person_rounded),
                    const Divider(height: 16, color: AquaColors.platinum),
                    _buildCredentialRow('Usuario / Correo:', worker.email, Icons.email_rounded),
                    const Divider(height: 16, color: AquaColors.platinum),
                    _buildCredentialRow('No. Empleado:', worker.employeeNumber, Icons.badge_rounded),
                    const Divider(height: 16, color: AquaColors.platinum),
                    _buildCredentialRow('Contraseña:', worker.password, Icons.key_rounded, isSensitive: true),
                    const Divider(height: 16, color: AquaColors.platinum),
                    _buildCredentialRow(
                      'Empresas que surtirá:',
                      worker.assignedClients.length >= kDefaultClients.length
                          ? 'Todas las empresas'
                          : worker.assignedClients.join(', '),
                      Icons.business_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AquaButton(
                text: 'Aceptar y cerrar',
                icon: Icons.done_all_rounded,
                onPressed: () => Navigator.of(dlgCtx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialRow(String label, String value, IconData icon, {bool isSensitive = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AquaColors.turquoise),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AquaColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSensitive ? AquaColors.turquoise : AquaColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleWorkerActiveStatus(WorkerItem worker) async {
    final isCurrentlyActive = worker.status.toLowerCase() == 'activo';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isCurrentlyActive ? '¿Desactivar trabajador?' : '¿Activar trabajador?',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            color: AquaColors.textPrimary,
          ),
        ),
        content: Text(
          isCurrentlyActive
              ? 'El trabajador "${worker.name}" no podrá acceder ni registrar suministros mientras permanezca desactivado.'
              : '¿Deseas volver a activar al trabajador "${worker.name}" para que pueda iniciar sesión y operar?',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: AquaColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: AquaColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentlyActive ? AquaColors.statusError : AquaColors.turquoise,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(dlgCtx).pop(true),
            child: Text(
              isCurrentlyActive ? 'Desactivar' : 'Activar',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final newStatus = isCurrentlyActive ? 'Inactivo' : 'Activo';
    toggleWorkerStatus(worker.id);

    try {
      await SupabaseService.client
          .from('workers')
          .update({'status': newStatus})
          .eq('employee_number', worker.employeeNumber);
    } catch (_) {}

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Trabajador ${isCurrentlyActive ? "desactivado" : "activado"} con éxito.',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
          backgroundColor: isCurrentlyActive ? AquaColors.textSecondary : AquaColors.statusSupplied,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showEditWorkerDialog(WorkerItem worker) {
    final nameCtrl = TextEditingController(text: worker.name);
    final empNumCtrl = TextEditingController(text: worker.employeeNumber);
    final phoneCtrl = TextEditingController(text: worker.phone);
    final emailCtrl = TextEditingController(text: worker.email);
    final passwordCtrl = TextEditingController(text: worker.password);
    bool obscurePassword = true;
    final List<String> selectedClients = List.from(worker.assignedClients);
    String selectedStatus = worker.status;
    String? formError;
    bool isSaving = false;

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
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 620,
                  maxHeight: MediaQuery.of(modalCtx).size.height * 0.90,
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AquaColors.glacier.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: AquaColors.turquoise,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Editar Trabajador',
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
                              icon: const Icon(Icons.close, color: AquaColors.textSecondary, size: 20),
                              onPressed: () => Navigator.of(modalCtx).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        if (formError != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AquaColors.statusError.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AquaColors.statusError.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AquaColors.statusError, size: 16),
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
                          const SizedBox(height: 12),
                        ],

                        // Estado Operativo selector
                        Text(
                          'Estado del Trabajador',
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
                                onTap: () => setModalState(() => selectedStatus = 'Activo'),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                  decoration: BoxDecoration(
                                    color: selectedStatus == 'Activo'
                                        ? AquaColors.statusSuppliedBg
                                        : AquaColors.platinum.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: selectedStatus == 'Activo'
                                          ? AquaColors.statusSuppliedBorder
                                          : AquaColors.platinum,
                                      width: selectedStatus == 'Activo' ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 15,
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
                                              : AquaColors.textSecondary,
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
                                onTap: () => setModalState(() => selectedStatus = 'Inactivo'),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                  decoration: BoxDecoration(
                                    color: selectedStatus == 'Inactivo'
                                        ? Colors.amber.withValues(alpha: 0.12)
                                        : AquaColors.platinum.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: selectedStatus == 'Inactivo'
                                          ? Colors.amber.shade700
                                          : AquaColors.platinum,
                                      width: selectedStatus == 'Inactivo' ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.pause_circle_rounded,
                                        size: 15,
                                        color: selectedStatus == 'Inactivo'
                                            ? Colors.amber.shade900
                                            : AquaColors.textMuted,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Inactivo (Desactivado)',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: selectedStatus == 'Inactivo'
                                              ? Colors.amber.shade900
                                              : AquaColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        _buildTextField(
                          controller: nameCtrl,
                          label: 'Nombre completo *',
                          hint: 'Ej. Juan Pérez García',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: empNumCtrl,
                                label: 'No. de empleado *',
                                hint: 'EMP-001',
                                icon: Icons.badge_outlined,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                controller: phoneCtrl,
                                label: 'Teléfono de contacto',
                                hint: '55 1234 5678',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        _buildTextField(
                          controller: emailCtrl,
                          label: 'Correo electrónico *',
                          hint: 'trabajador@aquacontrol.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),

                        _buildTextField(
                          controller: passwordCtrl,
                          label: 'Contraseña de acceso *',
                          hint: 'Mínimo 4 caracteres',
                          icon: Icons.lock_outline_rounded,
                          obscureText: obscurePassword,
                          suffix: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: AquaColors.slateBlue,
                            ),
                            onPressed: () {
                              setModalState(() => obscurePassword = !obscurePassword);
                            },
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Empresas clientes asignadas
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AquaColors.iceBlue.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AquaColors.slateBlue.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.business_center_rounded,
                                    size: 18,
                                    color: AquaColors.turquoise,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Empresas clientes que va a surtir *',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AquaColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(50, 24),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () {
                                      setModalState(() {
                                        if (selectedClients.length == kDefaultClients.length) {
                                          selectedClients.clear();
                                        } else {
                                          selectedClients.clear();
                                          selectedClients.addAll(kDefaultClients.map((c) => c.companyName));
                                        }
                                      });
                                    },
                                    child: Text(
                                      selectedClients.length == kDefaultClients.length
                                          ? 'Deseleccionar'
                                          : 'Todas',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AquaColors.turquoise,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: kDefaultClients.map((client) {
                                  final isSelected = selectedClients.contains(client.companyName);
                                  return FilterChip(
                                    label: Text(
                                      client.companyName,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected ? AquaColors.turquoise : AquaColors.textSecondary,
                                      ),
                                    ),
                                    selected: isSelected,
                                    onSelected: (val) {
                                      setModalState(() {
                                        if (val) {
                                          selectedClients.add(client.companyName);
                                        } else {
                                          selectedClients.remove(client.companyName);
                                        }
                                      });
                                    },
                                    selectedColor: AquaColors.glacier.withValues(alpha: 0.8),
                                    backgroundColor: Colors.white,
                                    checkmarkColor: AquaColors.turquoise,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: isSelected ? AquaColors.turquoise : AquaColors.platinum,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        AquaButton(
                          text: isSaving ? 'Guardando cambios...' : 'Guardar cambios',
                          icon: Icons.check_circle_rounded,
                          onPressed: isSaving
                              ? null
                              : () async {
                                  final name = nameCtrl.text.trim();
                                  if (name.isEmpty) {
                                    setModalState(() => formError = 'Ingresa el nombre del trabajador.');
                                    return;
                                  }
                                  final password = passwordCtrl.text.trim();
                                  if (password.length < 4) {
                                    setModalState(() => formError = 'La contraseña debe tener al menos 4 caracteres.');
                                    return;
                                  }
                                  if (selectedClients.isEmpty) {
                                    setModalState(() => formError = 'Selecciona al menos una empresa que va a surtir.');
                                    return;
                                  }

                                  setModalState(() => isSaving = true);

                                  final updated = worker.copyWith(
                                    name: name,
                                    employeeNumber: empNumCtrl.text.trim().isEmpty ? worker.employeeNumber : empNumCtrl.text.trim(),
                                    phone: phoneCtrl.text.trim().isEmpty ? worker.phone : phoneCtrl.text.trim(),
                                    email: emailCtrl.text.trim().isEmpty ? worker.email : emailCtrl.text.trim(),
                                    password: password,
                                    status: selectedStatus,
                                    assignedClients: List.from(selectedClients),
                                  );

                                  updateWorker(worker.id, updated);

                                  try {
                                    await SupabaseService.client
                                        .from('workers')
                                        .update({
                                          'name': updated.name,
                                          'employee_number': updated.employeeNumber,
                                          'phone': updated.phone,
                                          'email': updated.email,
                                          'password': updated.password,
                                          'status': updated.status,
                                          'assigned_clients': updated.assignedClients,
                                        })
                                        .eq('employee_number', worker.employeeNumber);
                                  } catch (_) {}

                                  if (modalCtx.mounted) {
                                    Navigator.of(modalCtx).pop();
                                  }
                                  if (mounted) {
                                    setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Trabajador "${updated.name}" actualizado correctamente.',
                                          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                                        ),
                                        backgroundColor: AquaColors.statusSupplied,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    );
                                  }
                                },
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
      ),
    );
  }

  void _showWorkerDetailsModal(WorkerItem worker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {

          return Container(
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

                  // Header with Avatar and Basic Info
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AquaColors.glacier.withValues(alpha: 0.5),
                          border: Border.all(
                            color: AquaColors.turquoise,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          worker.name.split(' ').map((n) => n[0]).take(2).join(),
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AquaColors.turquoise,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              worker.name,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AquaColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AquaColors.glacier.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AquaColors.platinum),
                                  ),
                                  child: Text(
                                    worker.employeeNumber,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AquaColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                 Builder(
                                  builder: (_) {
                                    final isActive = worker.status.toLowerCase() == 'activo';
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? AquaColors.statusSuppliedBg
                                            : Colors.amber.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isActive
                                              ? AquaColors.statusSuppliedBorder
                                              : Colors.amber.shade700.withValues(alpha: 0.5),
                                        ),
                                      ),
                                      child: Text(
                                        worker.status,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: isActive
                                              ? AquaColors.statusSupplied
                                              : Colors.amber.shade900,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AquaColors.textSecondary, size: 20),
                        onPressed: () => Navigator.of(modalCtx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Assignment Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          borderRadius: 14,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Zona Asignada',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AquaColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                worker.assignedZone,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AquaColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GlassCard(
                          borderRadius: 14,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Turno',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AquaColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                worker.shift,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AquaColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Profile & Login Credentials Card
                  GlassCard(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.vpn_key_rounded, size: 16, color: AquaColors.turquoise),
                            const SizedBox(width: 8),
                            Text(
                              'Perfil de Acceso y Credenciales',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AquaColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Usuario / Correo:',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: AquaColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              worker.email,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AquaColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: AquaColors.platinum, height: 16),
                        Row(
                          children: [
                            Text(
                              'Contraseña:',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: AquaColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AquaColors.turquoise.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                worker.password,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AquaColors.turquoise,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Contact Details Card
                  GlassCard(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 16, color: AquaColors.turquoise),
                            const SizedBox(width: 10),
                            Text(
                              'Teléfono:',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: AquaColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              worker.phone,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AquaColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: AquaColors.platinum, height: 18),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.email_outlined, size: 16, color: AquaColors.turquoise),
                                const SizedBox(width: 10),
                                Text(
                                  'Correo:',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: AquaColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 26),
                              child: Text(
                                worker.email,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AquaColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Assigned Clients Card
                  GlassCard(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.business_center_rounded, size: 16, color: AquaColors.turquoise),
                            const SizedBox(width: 8),
                            Text(
                              'Empresas que Surtirá (${worker.assignedClients.length}):',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AquaColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: worker.assignedClients.map((client) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AquaColors.glacier.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AquaColors.slateBlue.withValues(alpha: 0.25)),
                              ),
                              child: Text(
                                client,
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AquaColors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons (Editar y Desactivar/Activar)
                  Row(
                    children: [
                      Expanded(
                        child: AquaButton(
                          text: 'Editar trabajador',
                          icon: Icons.edit_rounded,
                          height: 44,
                          onPressed: () {
                            Navigator.of(modalCtx).pop();
                            _showEditWorkerDialog(worker);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AquaButton(
                          text: worker.status.toLowerCase() == 'activo'
                              ? 'Desactivar'
                              : 'Activar',
                          type: worker.status.toLowerCase() == 'activo'
                              ? AquaButtonType.secondary
                              : AquaButtonType.primary,
                          icon: worker.status.toLowerCase() == 'activo'
                              ? Icons.pause_circle_outline_rounded
                              : Icons.play_circle_outline_rounded,
                          height: 44,
                          onPressed: () {
                            Navigator.of(modalCtx).pop();
                            _toggleWorkerActiveStatus(worker);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  AquaButton(
                    text: 'Cerrar',
                    type: AquaButtonType.secondary,
                    onPressed: () => Navigator.of(modalCtx).pop(),
                  ),
                  const SizedBox(height: 12),
                ],
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
    bool obscureText = false,
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
            obscureText: obscureText,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AquaColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AquaColors.turquoise, size: 18),
              suffixIcon: suffix,
              hintText: hint,
              hintStyle: GoogleFonts.montserrat(fontSize: 12, color: AquaColors.textMuted),
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
    final workers = _filteredWorkers;

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
                            'Gestión de Trabajadores',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AquaColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Personal operativo y de abastecimiento',
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
                        '${kDefaultWorkers.length} Personal',
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
                      hintText: 'Buscar trabajador, empleado o cliente...',
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: AquaColors.textMuted,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 19,
                        color: AquaColors.turquoise,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Register Button (Solo individual, quitado registro en grupo)
                AquaButton(
                  text: 'Registrar nuevo trabajador',
                  icon: Icons.person_add_alt_1_rounded,
                  height: 44,
                  onPressed: _showAddWorkerDialog,
                ),
                const SizedBox(height: 16),

                // Workers List
                Expanded(
                  child: workers.isEmpty
                      ? Center(
                          child: Text(
                            'No se encontraron trabajadores',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AquaColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: workers.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final worker = workers[index];
                            final isActive = worker.status.toLowerCase() == 'activo';
                            return GlassCard(
                              borderRadius: 16,
                              padding: const EdgeInsets.all(14),
                              onTap: () => _showWorkerDetailsModal(worker),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AquaColors.glacier.withValues(alpha: 0.5),
                                      border: Border.all(
                                        color: AquaColors.slateBlue.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.badge_rounded,
                                      color: AquaColors.turquoise,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                worker.name,
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: isActive ? AquaColors.textPrimary : AquaColors.textMuted,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AquaColors.glacier.withValues(alpha: 0.4),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: AquaColors.platinum),
                                              ),
                                              child: Text(
                                                worker.employeeNumber,
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: AquaColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isActive
                                                    ? AquaColors.statusSuppliedBg
                                                    : Colors.amber.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: isActive
                                                      ? AquaColors.statusSuppliedBorder
                                                      : Colors.amber.shade700.withValues(alpha: 0.5),
                                                ),
                                              ),
                                              child: Text(
                                                isActive ? 'Activo' : 'Inactivo',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: isActive
                                                      ? AquaColors.statusSupplied
                                                      : Colors.amber.shade900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Zona: ${worker.assignedZone}',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: AquaColors.textSecondary,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                '• Turno ${worker.shift}',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 11,
                                                  color: AquaColors.textMuted,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),

                                        // Assigned clients chips/summary
                                        if (worker.assignedClients.isNotEmpty) ...[
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.business_outlined,
                                                size: 13,
                                                color: AquaColors.turquoise,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  worker.assignedClients.length >= kDefaultClients.length ? 'Todas las empresas' : worker.assignedClients.join(', '),
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: AquaColors.turquoise,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                        ],

                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.phone_outlined,
                                              size: 11,
                                              color: AquaColors.textMuted,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              worker.phone,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 10,
                                                color: AquaColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Icon(
                                              Icons.email_outlined,
                                              size: 11,
                                              color: AquaColors.textMuted,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                worker.email,
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 10,
                                                  color: AquaColors.textSecondary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),

                                        // Acciones directas (Editar y Activar/Desactivar)
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: () => _showEditWorkerDialog(worker),
                                              borderRadius: BorderRadius.circular(8),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: AquaColors.glacier.withValues(alpha: 0.5),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: AquaColors.platinum),
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
                                              onTap: () => _toggleWorkerActiveStatus(worker),
                                              borderRadius: BorderRadius.circular(8),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: isActive
                                                      ? Colors.amber.withValues(alpha: 0.12)
                                                      : AquaColors.statusSupplied.withValues(alpha: 0.10),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: isActive
                                                        ? Colors.amber.shade700.withValues(alpha: 0.5)
                                                        : AquaColors.statusSupplied.withValues(alpha: 0.5),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      isActive
                                                          ? Icons.pause_circle_outline_rounded
                                                          : Icons.play_circle_outline_rounded,
                                                      size: 13,
                                                      color: isActive
                                                          ? Colors.amber.shade900
                                                          : AquaColors.statusSupplied,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      isActive ? 'Desactivar' : 'Activar',
                                                      style: GoogleFonts.montserrat(
                                                        fontSize: 10.5,
                                                        fontWeight: FontWeight.w700,
                                                        color: isActive
                                                            ? Colors.amber.shade900
                                                            : AquaColors.statusSupplied,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18,
                                    color: AquaColors.slateBlue,
                                  ),
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
