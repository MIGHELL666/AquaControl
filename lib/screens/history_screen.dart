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
    HistoryEntry(
      time: '14:37',
      location: 'Producción',
      user: 'Juan Pérez',
      bottles: 2,
    ),
    HistoryEntry(
      time: '14:25',
      location: 'Almacén',
      user: 'Carlos López',
      bottles: 2,
    ),
    HistoryEntry(
      time: '14:10',
      location: 'Taller',
      user: 'Juan Pérez',
      bottles: 1,
    ),
    HistoryEntry(
      time: '13:52',
      location: 'Oficinas',
      user: 'Carlos López',
      bottles: 2,
    ),
    HistoryEntry(
      time: '13:20',
      location: 'Mantenimiento',
      user: 'Pedro García',
      bottles: 1,
    ),
    HistoryEntry(
      time: '12:48',
      location: 'Calidad',
      user: 'Juan Pérez',
      bottles: 2,
    ),
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AquaColors.cornflowerBlue,
              surface: AquaColors.surfaceNavy,
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
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AquaColors.icyBlue),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                'Historial de abastecimientos',
                style: GoogleFonts.montserrat(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date Filter Selector Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0x283D518C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AquaColors.glassBorderSubtle, width: 1),
                ),
                child: Text(
                  'Hoy',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today_outlined, size: 20, color: AquaColors.icyBlue),
                onPressed: _pickDate,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Entries List
          Expanded(
            child: ListView.separated(
              itemCount: _entries.length,
              separatorBuilder: (_, i) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return GlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  backgroundColor: const Color(0x221F356B),
                  borderColor: AquaColors.glassBorderSubtle,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PointDetailScreen(pointName: entry.location),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      // Time pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0x334468C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          entry.time,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Location & User
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.location,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              entry.user,
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: AquaColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottle count
                      Text(
                        '${entry.bottles} ${entry.bottles == 1 ? 'garrafón' : 'garrafones'}',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AquaColors.textSecondary,
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
}
