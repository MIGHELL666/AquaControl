import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aqua_colors.dart';
import '../widgets/glass_card.dart';
import 'point_detail_screen.dart';

class HistoryEntry {
  final String time;
  final String location;
  final String user;
  final int bottles;

  const HistoryEntry({
    required this.time,
    required this.location,
    required this.user,
    required this.bottles,
  });
}

class HistoryScreen extends StatefulWidget {
  final bool showBackButton;

  const HistoryScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();

  final List<HistoryEntry> _entries = const [
    HistoryEntry(time: '14:37', location: 'Producción', user: 'Juan Pérez', bottles: 2),
    HistoryEntry(time: '14:25', location: 'Almacén', user: 'Carlos López', bottles: 2),
    HistoryEntry(time: '14:10', location: 'Taller', user: 'Juan Pérez', bottles: 1),
    HistoryEntry(time: '13:52', location: 'Oficinas', user: 'Carlos López', bottles: 2),
    HistoryEntry(time: '13:20', location: 'Mantenimiento', user: 'Pedro García', bottles: 1),
    HistoryEntry(time: '12:48', location: 'Calidad', user: 'Juan Pérez', bottles: 2),
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AquaColors.turquoise,
              surface: AquaColors.iceBlue,
              onSurface: AquaColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalBottles = _entries.fold<int>(0, (sum, e) => sum + e.bottles);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              if (widget.showBackButton) ...[
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: AquaColors.textSecondary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  'Historial',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AquaColors.textPrimary,
                  ),
                ),
              ),
              // Selector de fecha
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.80),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AquaColors.glassBorder),
                      boxShadow: [
                        BoxShadow(
                          color: AquaColors.shadowCard,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: AquaColors.turquoise,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Hoy',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AquaColors.turquoise,
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

          // Tarjeta resumen del día
          GlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                _buildSummaryChip(
                  icon: Icons.water_drop_rounded,
                  value: '$totalBottles',
                  label: 'Garrafones',
                  color: AquaColors.turquoise,
                ),
                _buildDivider(),
                _buildSummaryChip(
                  icon: Icons.check_circle_rounded,
                  value: '${_entries.length}',
                  label: 'Entregas',
                  color: AquaColors.statusSupplied,
                ),
                _buildDivider(),
                _buildSummaryChip(
                  icon: Icons.group_rounded,
                  value: '${_entries.map((e) => e.user).toSet().length}',
                  label: 'Trabajadores',
                  color: AquaColors.slateBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Etiqueta de sección
          Text(
            'Actividad del día',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AquaColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),

          // Lista de entradas
          Expanded(
            child: ListView.separated(
              itemCount: _entries.length,
              separatorBuilder: (_, i) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return GlassCard(
                  borderRadius: 14,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            PointDetailScreen(pointName: entry.location),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      // Pill de hora
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AquaColors.turquoise.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          entry.time,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AquaColors.turquoise,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Localización y usuario
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.location,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AquaColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              entry.user,
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: AquaColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Contador de garrafones
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AquaColors.statusSuppliedBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AquaColors.statusSuppliedBorder),
                        ),
                        child: Text(
                          '${entry.bottles} ${entry.bottles == 1 ? 'garrafón' : 'garrafones'}',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AquaColors.statusSupplied,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AquaColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              color: AquaColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      color: AquaColors.platinum,
    );
  }
}
