import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../theme/aqua_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/signature_pad.dart';

class WorkerHistoryTableScreen extends StatefulWidget {
  const WorkerHistoryTableScreen({super.key});

  @override
  State<WorkerHistoryTableScreen> createState() => _WorkerHistoryTableScreenState();
}

class _WorkerHistoryTableScreenState extends State<WorkerHistoryTableScreen> {
  int _selectedView = 0; // 0 = Tabla, 1 = Gráfica de barras
  String _filterZone = 'Todas';

  List<SupplyRecord> get _filteredRecords {
    if (_filterZone == 'Todas') return kSupplyRecords;
    return kSupplyRecords.where((r) => r.zoneName == _filterZone).toList();
  }

  int get _totalBottles {
    return _filteredRecords.fold(0, (sum, r) => sum + r.bottles);
  }

  void _showSignatureDialog(SupplyRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassCard(
          borderRadius: 22,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Comprobante de Entrega',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AquaColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AquaColors.textSecondary, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Despachador ${record.dispenserId} • Zona ${record.zoneName}',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AquaColors.turquoise,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Fecha: ${record.dateFormatted} a las ${record.timeFormatted}',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: AquaColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Cantidad: ${record.bottles} garrafones (${record.isResupply ? "Reabastecimiento" : "Abastecimiento"})',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AquaColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Recibió: ${record.recipientName}',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AquaColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Firma registrada:',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: AquaColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              SignaturePreviewBox(
                points: record.signaturePoints,
                height: 100,
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'Cerrar',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: AquaColors.turquoise,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historial y Métricas',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AquaColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Registro de garrafones por fecha y punto',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AquaColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AquaColors.glacier.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AquaColors.slateBlue.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: AquaColors.shadowCard,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$_totalBottles Garrafones',
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

          // View Selector: Tabla vs Gráfica de barras
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AquaColors.glacier.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AquaColors.platinum),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedView = 0),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _selectedView == 0
                            ? AquaColors.turquoise
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _selectedView == 0
                            ? [
                                BoxShadow(
                                  color: AquaColors.turquoise.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.table_chart_rounded,
                            size: 16,
                            color: _selectedView == 0
                                ? Colors.white
                                : AquaColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tabla',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _selectedView == 0
                                  ? Colors.white
                                  : AquaColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedView = 1),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _selectedView == 1
                            ? AquaColors.turquoise
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _selectedView == 1
                            ? [
                                BoxShadow(
                                  color: AquaColors.turquoise.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart_rounded,
                            size: 16,
                            color: _selectedView == 1
                                ? Colors.white
                                : AquaColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Gráfica de barras',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _selectedView == 1
                                  ? Colors.white
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
          ),
          const SizedBox(height: 12),

          // Quick Zone Filter Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Todas', 'Producción', 'Almacén', 'Calidad', 'Taller', 'Oficinas']
                  .map((zone) {
                final isSel = _filterZone == zone;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(
                      zone,
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
                      width: 1.2,
                    ),
                    onSelected: (_) => setState(() => _filterZone = zone),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Body: Table View or Bar Chart View
          Expanded(
            child: _selectedView == 0
                ? _buildTableView(records)
                : _buildBarChartView(records),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(List<SupplyRecord> records) {
    if (records.isEmpty) {
      return Center(
        child: Text(
          'No hay registros para la zona seleccionada',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AquaColors.textSecondary,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Grid hint and info bar
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              const Icon(
                Icons.grid_on_rounded,
                size: 15,
                color: AquaColors.turquoise,
              ),
              const SizedBox(width: 6),
              Text(
                'Cuadrícula de Registros (${records.length})',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AquaColors.textPrimary,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.swap_horiz_rounded,
                    size: 16,
                    color: AquaColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Desliza ↔ para más columnas',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AquaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Grid Table Container with full borders
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AquaColors.platinum,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AquaColors.shadowCard,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 905,
                  child: Column(
                    children: [
                      // Fixed Grid Header
                      Container(
                        color: AquaColors.glacier.withValues(alpha: 0.65),
                        child: Table(
                          columnWidths: const {
                            0: FixedColumnWidth(100), // Fecha
                            1: FixedColumnWidth(75),  // Hora
                            2: FixedColumnWidth(125), // Punto/Zona
                            3: FixedColumnWidth(115), // Despachador
                            4: FixedColumnWidth(105), // Garrafones
                            5: FixedColumnWidth(130), // Operación
                            6: FixedColumnWidth(145), // Recibió
                            7: FixedColumnWidth(110), // Firma
                          },
                          border: const TableBorder(
                            bottom: BorderSide(
                              color: AquaColors.platinum,
                              width: 1.5,
                            ),
                            verticalInside: BorderSide(
                              color: AquaColors.platinum,
                              width: 1,
                            ),
                          ),
                          children: [
                            TableRow(
                              children: [
                                _buildGridHeaderCell('Fecha', Icons.calendar_today_outlined),
                                _buildGridHeaderCell('Hora', Icons.access_time_rounded),
                                _buildGridHeaderCell('Punto / Zona', Icons.location_on_outlined),
                                _buildGridHeaderCell('Despachador', Icons.local_drink_outlined),
                                _buildGridHeaderCell('Garrafones', Icons.water_drop_outlined),
                                _buildGridHeaderCell('Operación', Icons.sync_alt_rounded),
                                _buildGridHeaderCell('Recibió', Icons.person_outline_rounded),
                                _buildGridHeaderCell('Firma', Icons.draw_outlined),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Scrollable Grid Rows
                      Expanded(
                        child: SingleChildScrollView(
                          child: Table(
                            columnWidths: const {
                              0: FixedColumnWidth(100),
                              1: FixedColumnWidth(75),
                              2: FixedColumnWidth(125),
                              3: FixedColumnWidth(115),
                              4: FixedColumnWidth(105),
                              5: FixedColumnWidth(130),
                              6: FixedColumnWidth(145),
                              7: FixedColumnWidth(110),
                            },
                            border: BorderSide(
                              color: AquaColors.platinum.withValues(alpha: 0.5),
                              width: 1,
                            ).toTableBorder(),
                            children: List.generate(records.length, (index) {
                              final item = records[index];
                              final isEven = index % 2 == 0;
                              final rowBg = isEven
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : AquaColors.iceBlue.withValues(alpha: 0.35);

                              return TableRow(
                                decoration: BoxDecoration(color: rowBg),
                                children: [
                                  // Fecha
                                  _buildGridCell(
                                    Text(
                                      item.dateFormatted,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AquaColors.textPrimary,
                                      ),
                                    ),
                                  ),

                                  // Hora
                                  _buildGridCell(
                                    Text(
                                      item.timeFormatted,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AquaColors.textSecondary,
                                      ),
                                    ),
                                  ),

                                  // Punto / Zona
                                  _buildGridCell(
                                    Text(
                                      item.zoneName,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AquaColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  // Despachador
                                  _buildGridCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AquaColors.glacier.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AquaColors.platinum,
                                        ),
                                      ),
                                      child: Text(
                                        item.dispenserId,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AquaColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Garrafones
                                  _buildGridCell(
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AquaColors.turquoise.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: AquaColors.turquoise.withValues(alpha: 0.5),
                                          ),
                                        ),
                                        child: Text(
                                          '${item.bottles} gar.',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AquaColors.turquoise,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Operación
                                  _buildGridCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: item.isResupply
                                                ? AquaColors.statusPendingBg
                                                : AquaColors.statusSuppliedBg,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: item.isResupply
                                                  ? AquaColors.statusPendingBorder
                                                  : AquaColors.statusSuppliedBorder,
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Text(
                                            item.isResupply ? 'Reabasto' : 'Abasto',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: item.isResupply
                                                  ? AquaColors.statusPending
                                                  : AquaColors.statusSupplied,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Recibió
                                  _buildGridCell(
                                    Text(
                                      item.recipientName,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        color: AquaColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),

                                  // Firma Button
                                  _buildGridCell(
                                    InkWell(
                                      onTap: () => _showSignatureDialog(item),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AquaColors.turquoise.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: AquaColors.turquoise.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.draw_rounded,
                                              size: 13,
                                              color: AquaColors.turquoise,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Ver',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: AquaColors.turquoise,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridHeaderCell(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AquaColors.turquoise),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AquaColors.textPrimary,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCell(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  Widget _buildBarChartView(List<SupplyRecord> records) {
    // Group bottles by day (last 7 days)
    final Map<String, int> dailyBottles = {};
    final Map<String, String> dayLabels = {};

    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
      dailyBottles[key] = 0;

      final weekdayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      dayLabels[key] = '${weekdayNames[d.weekday - 1]}\n${d.day}';
    }

    for (final r in records) {
      final key = '${r.timestamp.day.toString().padLeft(2, '0')}/${r.timestamp.month.toString().padLeft(2, '0')}';
      if (dailyBottles.containsKey(key)) {
        dailyBottles[key] = dailyBottles[key]! + r.bottles;
      }
    }

    final maxVal = dailyBottles.values.fold(1, (prev, val) => val > prev ? val : prev);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bar Chart Card
          GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Garrafones entregados (últimos 7 días)',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AquaColors.textPrimary,
                      ),
                    ),
                    const Icon(
                      Icons.insights_rounded,
                      size: 20,
                      color: AquaColors.turquoise,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Bars Graphic (Height increased to 210 to ensure zero overflow on all devices)
                SizedBox(
                  height: 210,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: dailyBottles.entries.map((entry) {
                      final count = entry.value;
                      final heightFactor = maxVal == 0 ? 0.05 : (count / maxVal).clamp(0.08, 1.0);
                      final isToday = entry.key ==
                          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}';

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Number label
                          Text(
                            '$count',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: count > 0 ? AquaColors.turquoise : AquaColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Bar
                          Container(
                            width: 24,
                            height: 115 * heightFactor,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: isToday
                                    ? [
                                        AquaColors.turquoise,
                                        AquaColors.slateBlue,
                                      ]
                                    : [
                                        AquaColors.slateBlue.withValues(alpha: 0.85),
                                        AquaColors.turquoise.withValues(alpha: 0.65),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: count > 0
                                  ? [
                                      BoxShadow(
                                        color: AquaColors.turquoise.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Day Label
                          Text(
                            dayLabels[entry.key] ?? entry.key,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                              color: isToday ? AquaColors.turquoise : AquaColors.textSecondary,
                              height: 1.2,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats Summary Grid
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total de entregas',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AquaColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${records.length}',
                        style: GoogleFonts.montserrat(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AquaColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'servicios registrados',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AquaColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reabastecimientos',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AquaColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${records.where((r) => r.isResupply).length}',
                        style: GoogleFonts.montserrat(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AquaColors.turquoise,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'vueltas / rondas',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AquaColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

extension TableBorderExtension on BorderSide {
  TableBorder toTableBorder() => TableBorder(
        horizontalInside: this,
        verticalInside: this,
      );
}
