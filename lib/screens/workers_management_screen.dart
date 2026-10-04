import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
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
                  maxHeight: MediaQuery.of(modalCtx).size.height * 0.88,
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
                          'Ingresa los datos del trabajador para darle acceso al sistema con todas las empresas',
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
                          label: 'Correo electrónico',
                          hint: 'trabajador@aquacontrol.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),

                        // Info banner confirming all companies access
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AquaColors.glacier.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AquaColors.slateBlue.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.business_rounded,
                                size: 18,
                                color: AquaColors.turquoise,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'El trabajador tendrá acceso a todas las empresas clientes registradas en el sistema.',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AquaColors.textPrimary,
                                  ),
                                ),
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
                          text: 'Registrar trabajador',
                          icon: Icons.person_add_rounded,
                          onPressed: () {
                            final name = nameCtrl.text.trim();
                            if (name.isEmpty) {
                              setModalState(() => formError = 'Ingresa el nombre del trabajador.');
                              return;
                            }

                            final newWorker = WorkerItem(
                              id: 'WRK-${DateTime.now().millisecondsSinceEpoch % 10000}',
                              name: name,
                              employeeNumber: empNumCtrl.text.trim().isEmpty
                                  ? 'EMP-${1060 + kDefaultWorkers.length}'
                                  : empNumCtrl.text.trim(),
                              phone: phoneCtrl.text.trim().isEmpty ? '55 0000 0000' : phoneCtrl.text.trim(),
                              email: emailCtrl.text.trim().isEmpty
                                  ? '${name.toLowerCase().replaceAll(' ', '.')}@aquacontrol.com'
                                  : emailCtrl.text.trim(),
                              assignedZone: 'Todas',
                              shift: 'General',
                              assignedClients: kDefaultClients.map((c) => c.companyName).toList(),
                            );

                            addWorker(newWorker);
                            Navigator.of(modalCtx).pop();
                            setState(() {});

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AquaColors.turquoise,
                                content: Text(
                                  'Trabajador "$name" registrado con acceso a todas las empresas',
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
          final workerDeliveries = kSupplyRecords.where(
            (r) => r.workerName.toLowerCase() == worker.name.toLowerCase(),
          ).toList();

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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AquaColors.statusSuppliedBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AquaColors.statusSuppliedBorder),
                                  ),
                                  child: Text(
                                    worker.status,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AquaColors.statusSupplied,
                                    ),
                                  ),
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
                            const Spacer(),
                            Flexible(
                              child: Text(
                                worker.email,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AquaColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Assigned Clients / Companies Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Empresas Clientes Asignadas (${worker.assignedClients.length}):',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AquaColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _showEditClientsDialog(worker, (updatedClients) {
                            setModalState(() {});
                            setState(() {});
                          });
                        },
                        child: Text(
                          'Editar asignación',
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

                  if (worker.assignedClients.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AquaColors.glacier.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AquaColors.platinum),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 18, color: AquaColors.textMuted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Este trabajador no tiene empresas asignadas todavía.',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: AquaColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ...worker.assignedClients.map((clientName) {
                      final clientObj = kDefaultClients.firstWhere(
                        (c) => c.companyName.toLowerCase() == clientName.toLowerCase(),
                        orElse: () => ClientItem(
                          id: '',
                          companyName: clientName,
                          contactPerson: 'Contacto comercial',
                          phone: '',
                          email: '',
                          address: 'Ubicación registrada',
                        ),
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AquaColors.glacier.withValues(alpha: 0.5),
                                  border: Border.all(color: AquaColors.slateBlue.withValues(alpha: 0.3)),
                                ),
                                child: const Icon(
                                  Icons.business_rounded,
                                  size: 16,
                                  color: AquaColors.turquoise,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      clientObj.companyName,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AquaColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Frecuencia: ${clientObj.deliveryFrequency} • ${clientObj.address}',
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
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 16),

                  // History Summary
                  Text(
                    'Entregas registradas por este trabajador:',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AquaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AquaColors.glacier.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AquaColors.platinum),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${workerDeliveries.length} servicios de abasto/reabasto',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AquaColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${workerDeliveries.fold(0, (s, r) => s + r.bottles)} garrafones',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AquaColors.turquoise,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

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

  void _showEditClientsDialog(WorkerItem worker, ValueChanged<List<String>> onUpdated) {
    final List<String> tempClients = List.from(worker.assignedClients);

    showDialog(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (dialogCtx, setDlgState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: GlassCard(
              borderRadius: 20,
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Asignar Empresas',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AquaColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AquaColors.textSecondary, size: 18),
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                      ),
                    ],
                  ),
                  Text(
                    'Selecciona las empresas que atenderá ${worker.name}:',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AquaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: kDefaultClients.map((client) {
                      final isSel = tempClients.contains(client.companyName);
                      return FilterChip(
                        avatar: Icon(
                          isSel ? Icons.check : Icons.add,
                          size: 14,
                          color: isSel ? Colors.white : AquaColors.turquoise,
                        ),
                        label: Text(
                          client.companyName,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? Colors.white : AquaColors.textPrimary,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: AquaColors.turquoise,
                        backgroundColor: AquaColors.glacier.withValues(alpha: 0.4),
                        side: BorderSide(
                          color: isSel ? AquaColors.turquoise : AquaColors.platinum,
                        ),
                        onSelected: (selected) {
                          setDlgState(() {
                            if (selected) {
                              tempClients.add(client.companyName);
                            } else {
                              tempClients.remove(client.companyName);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: AquaButton(
                          text: 'Cancelar',
                          type: AquaButtonType.secondary,
                          height: 42,
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AquaButton(
                          text: 'Guardar',
                          height: 42,
                          onPressed: () {
                            final idx = kDefaultWorkers.indexWhere((w) => w.id == worker.id);
                            if (idx != -1) {
                              kDefaultWorkers[idx] = worker.copyWith(
                                assignedClients: List.from(tempClients),
                              );
                            }
                            onUpdated(tempClients);
                            Navigator.of(dialogCtx).pop();
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
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
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AquaColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AquaColors.turquoise, size: 18),
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
                                                  color: AquaColors.textPrimary,
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
                                                overflow: TextOverflow.ellipsis,
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
