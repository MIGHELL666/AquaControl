import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/aqua_button.dart';
import '../widgets/aqua_logo.dart';
import 'app_shell.dart';
import 'worker_shell.dart';

class LoginScreen extends StatefulWidget {
  final UserRole initialRole;

  const LoginScreen({super.key, this.initialRole = UserRole.admin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _userController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _userController = TextEditingController(
      text: widget.initialRole == UserRole.admin
          ? 'admin@aquacontrol.com'
          : 'trabajador@aquacontrol.com',
    );
    _passwordController = TextEditingController(
      text: widget.initialRole == UserRole.admin
          ? 'AquaAdmin2026'
          : 'AquaPass2026',
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (widget.initialRole == UserRole.admin) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const AppShell(initialRole: UserRole.admin),
        ),
        (route) => false,
      );
    } else {
      // Seleccionar cliente/empresa antes de navegar a la app del trabajador
      final selected = await Navigator.of(context).push<ClientItem>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (ctx) => const ClientSelectionScreen(
            title: 'Selecciona la empresa a abastecer',
            isMandatory: true,
          ),
        ),
      );

      if (selected != null) {
        WorkerSession.setActiveClient(selected);
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const WorkerShell()),
            (route) => false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.initialRole == UserRole.admin;

    return Scaffold(
      body: AquaBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // AppBar row
                  Row(
                    children: [
                      if (Navigator.of(context).canPop())
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 16,
                            color: AquaColors.textSecondary,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      const Spacer(),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.80),
                          border: Border.all(
                            color: AquaColors.glassBorder,
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: AquaLogo(
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AquaControl',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AquaColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const Spacer(),
                      if (Navigator.of(context).canPop())
                        const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Encabezado de rol
                  Column(
                    children: [
                      // Badge de rol
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? AquaColors.turquoise.withValues(alpha: 0.12)
                              : AquaColors.slateBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isAdmin
                                ? AquaColors.turquoise.withValues(alpha: 0.40)
                                : AquaColors.slateBlue.withValues(alpha: 0.40),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAdmin
                                  ? Icons.shield_rounded
                                  : Icons.local_shipping_rounded,
                              size: 15,
                              color: isAdmin
                                  ? AquaColors.turquoise
                                  : AquaColors.slateBlue,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              isAdmin
                                  ? 'Acceso de Administrador'
                                  : 'Acceso de Trabajador',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isAdmin
                                    ? AquaColors.turquoise
                                    : AquaColors.slateBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isAdmin
                            ? 'Gestión operativa y reportes'
                            : 'Escaneo de QR y registro de garrafones',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: AquaColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Campo: Usuario
                  TextFormField(
                    controller: _userController,
                    style: GoogleFonts.montserrat(
                      color: AquaColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        isAdmin
                            ? Icons.person_outline_rounded
                            : Icons.badge_outlined,
                        size: 20,
                        color: AquaColors.slateBlue,
                      ),
                      hintText: 'Usuario',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo: Contraseña
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.montserrat(
                      color: AquaColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: AquaColors.slateBlue,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: AquaColors.slateBlue,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      hintText: 'Contraseña',
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Botón de inicio
                  AquaButton(
                    text: isAdmin
                        ? 'Iniciar como Administrador'
                        : 'Iniciar como Trabajador',
                    icon: isAdmin
                        ? Icons.dashboard_rounded
                        : Icons.qr_code_scanner_rounded,
                    onPressed: _onLogin,
                  ),

                  const Spacer(),

                  Text(
                    'Solo personal autorizado',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AquaColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pantalla completa pública para seleccionar cliente/empresa.
///
/// Devuelve como resultado el [ClientItem] elegido, o null si el usuario
/// retrocedió/canceló (sólo permitido si [isMandatory] == false y
/// [allowOmit] == true).
class ClientSelectionScreen extends StatefulWidget {
  final String title;
  final ClientItem? selectedClient;
  final bool allowOmit;
  final bool isMandatory;

  const ClientSelectionScreen({
    super.key,
    this.title = 'Seleccionar cliente',
    this.selectedClient,
    this.allowOmit = false,
    this.isMandatory = false,
  });

  @override
  State<ClientSelectionScreen> createState() => _ClientSelectionScreenState();
}

class _ClientSelectionScreenState extends State<ClientSelectionScreen> {
  late TextEditingController _searchCtrl;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ClientItem> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return kDefaultClients;
    return kDefaultClients
        .where(
          (c) =>
              c.companyName.toLowerCase().contains(q) ||
              c.address.toLowerCase().contains(q) ||
              c.phone.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final canPop = !widget.isMandatory;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AquaBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 16, 10),
                child: Row(
                  children: [
                    if (canPop)
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: AquaColors.textSecondary,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    else
                      const SizedBox(width: 48, height: 48),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AquaColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.isMandatory
                                ? 'Debes elegir una empresa para continuar'
                                : 'Elige una empresa para esta sesión',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: AquaColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AquaColors.turquoise.withValues(alpha: 0.12),
                      ),
                      child: const Icon(
                        Icons.business_center_rounded,
                        size: 20,
                        color: AquaColors.turquoise,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(14),
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
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: AquaColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: AquaColors.slateBlue,
                      ),
                      hintText: 'Buscar empresa, dirección o teléfono',
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: AquaColors.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Lista clientes
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 36),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.search_off_rounded,
                                  size: 42,
                                  color: AquaColors.textMuted,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No se encontraron empresas',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    color: AquaColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (ctx, index) {
                            final client = _filtered[index];
                            final isSelected =
                                widget.selectedClient?.id == client.id;
                            final bgColor = isSelected
                                ? AquaColors.turquoise.withValues(alpha: 0.10)
                                : Colors.white.withValues(alpha: 0.9);
                            final borderColor = isSelected
                                ? AquaColors.turquoise
                                : AquaColors.platinum;

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (client.isInactive) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.amber.shade800,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        content: Text(
                                          'La empresa "${client.companyName}" está inactiva y no puede seleccionarse.',
                                          style: GoogleFonts.montserrat(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  Navigator.of(ctx).pop<ClientItem>(client);
                                },
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: borderColor),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AquaColors.shadowCard,
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: client.isActive
                                              ? AquaColors.slateBlue
                                                  .withValues(alpha: 0.10)
                                              : Colors.amber
                                                  .withValues(alpha: 0.15),
                                        ),
                                        child: Icon(
                                          Icons.apartment_rounded,
                                          size: 22,
                                          color: client.isActive
                                              ? AquaColors.slateBlue
                                              : Colors.amber.shade800,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
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
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 1.5),
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
                                                            6),
                                                  ),
                                                  child: Text(
                                                    client.status,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      fontSize: 9.5,
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
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.pin_drop_outlined,
                                                  size: 13,
                                                  color:
                                                      AquaColors.textSecondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    client.fullAddress,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                          fontSize: 11.5,
                                                          color: AquaColors
                                                              .textSecondary,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Icon(
                                                  Icons.phone_rounded,
                                                  size: 13,
                                                  color:
                                                      AquaColors.textSecondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  client.phone,
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 11.5,
                                                    color: AquaColors
                                                        .textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          size: 20,
                                          color: AquaColors.turquoise,
                                        )
                                      else
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 15,
                                          color: AquaColors.textMuted,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              if (widget.allowOmit) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Omitir (sin cliente)',
                    style: GoogleFonts.montserrat(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AquaColors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ] else
                const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
