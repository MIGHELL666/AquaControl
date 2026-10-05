import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zone_data.dart';
import '../theme/aqua_colors.dart';
import '../utils/table_pdf_printer.dart';
import '../widgets/glass_card.dart';
import '../widgets/signature_pad.dart';

class WorkerHistoryTableScreen extends StatefulWidget {
  final bool showFinancials;

  const WorkerHistoryTableScreen({super.key, this.showFinancials = true});

  @override
  State<WorkerHistoryTableScreen> createState() =>
      _WorkerHistoryTableScreenState();
}

class _WorkerHistoryTableScreenState extends State<WorkerHistoryTableScreen> {
  int _selectedView = 0; // 0 = Tabla, 1 = Gráfica de barras
  String? _filterClient; // null o 'all' = Todos los clientes

  List<SupplyRecord> get _filteredRecords {
    return kSupplyRecords.where((r) {
      final matchesClient =
          _filterClient == null ||
          _filterClient == 'all' ||
          r.clientName.trim().toLowerCase() ==
              _filterClient!.trim().toLowerCase();
      return matchesClient;
    }).toList();
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
                    icon: const Icon(
                      Icons.close,
                      color: AquaColors.textSecondary,
                      size: 20,
                    ),
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
              if (record.clientName.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: AquaColors.turquoise.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AquaColors.turquoise.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.business_rounded,
                        size: 14,
                        color: AquaColors.turquoise,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cliente: ${record.clientName}',
                          style: GoogleFonts.montserrat(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AquaColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.showFinancials && record.pricePerBottle > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      Text(
                        'Precio Unit.: \$${record.pricePerBottle.toStringAsFixed(2)}',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: AquaColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AquaColors.statusSupplied.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AquaColors.statusSupplied.withValues(
                              alpha: 0.30,
                            ),
                          ),
                        ),
                        child: Text(
                          'Total: \$${record.totalPrice.toStringAsFixed(2)}',
                          style: GoogleFonts.montserrat(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AquaColors.statusSupplied,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
              SignaturePreviewBox(points: record.signaturePoints, height: 100),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final hPadding = screenWidth < 360
        ? 12.0
        : (screenWidth < 600 ? 16.0 : 20.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historial y Métricas',
                          style: GoogleFonts.montserrat(
                            fontSize: screenWidth < 360 ? 18 : 20,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Spacer(),
                  const SizedBox(width: 8),
                  PopupMenuButton<int>(
                    padding: EdgeInsets.zero,
                    icon: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AquaColors.platinum),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _selectedView == 0
                                ? Icons.table_chart_rounded
                                : Icons.bar_chart_rounded,
                            size: 13,
                            color: AquaColors.turquoise,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _selectedView == 0 ? 'Tabla' : 'Gráfica',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AquaColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 14,
                            color: AquaColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (val) => setState(() => _selectedView = val),
                    itemBuilder: (_) => [
                      PopupMenuItem<int>(
                        value: 0,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.table_chart_rounded,
                              size: 16,
                              color: AquaColors.slateBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ver como Tabla',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: _selectedView == 0
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: _selectedView == 0
                                    ? AquaColors.turquoise
                                    : AquaColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<int>(
                        value: 1,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.bar_chart_rounded,
                              size: 16,
                              color: AquaColors.slateBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ver como Gráfica',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: _selectedView == 1
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: _selectedView == 1
                                    ? AquaColors.turquoise
                                    : AquaColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Imprimir Tabla button
          InkWell(
            onTap: () => TablePdfPrinter.printRecordsTable(
              _filteredRecords,
              includePrices: widget.showFinancials,
            ),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AquaColors.turquoise, AquaColors.slateBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AquaColors.shadowButton,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.print_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Imprimir Tabla',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Selector de Cliente (Requerimiento de Filtrado por Empresa)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _filterClient != null && _filterClient != 'all'
                    ? AquaColors.turquoise.withValues(alpha: 0.6)
                    : AquaColors.platinum,
                width: _filterClient != null && _filterClient != 'all'
                    ? 1.4
                    : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _filterClient != null && _filterClient != 'all'
                      ? AquaColors.turquoise.withValues(alpha: 0.12)
                      : AquaColors.shadowCard,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _filterClient != null && _filterClient != 'all'
                        ? AquaColors.turquoise.withValues(alpha: 0.16)
                        : AquaColors.glacier.withValues(alpha: 0.6),
                  ),
                  child: Icon(
                    Icons.business_rounded,
                    size: 16,
                    color: _filterClient != null && _filterClient != 'all'
                        ? AquaColors.turquoise
                        : AquaColors.slateBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FILTRAR POR CLIENTE',
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AquaColors.textMuted,
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return PopupMenuButton<String>(
                            position: PopupMenuPosition.under,
                            offset: const Offset(0, 6),
                            color: Colors.white,
                            elevation: 12,
                            shadowColor: AquaColors.turquoise.withValues(
                              alpha: 0.18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                color: AquaColors.glassBorder,
                                width: 1,
                              ),
                            ),
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                              maxWidth: constraints.maxWidth,
                              maxHeight: 350,
                            ),
                            tooltip: 'Seleccionar cliente',
                            onSelected: (val) {
                              setState(() {
                                _filterClient = (val == 'all') ? null : val;
                              });
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem<String>(
                                value: 'all',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.public_rounded,
                                      size: 16,
                                      color: AquaColors.turquoise,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Todos los clientes',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12.5,
                                          fontWeight:
                                              _filterClient == null ||
                                                  _filterClient == 'all'
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color:
                                              _filterClient == null ||
                                                  _filterClient == 'all'
                                              ? AquaColors.turquoise
                                              : AquaColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (_filterClient == null ||
                                        _filterClient == 'all')
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 16,
                                        color: AquaColors.turquoise,
                                      ),
                                  ],
                                ),
                              ),
                              ...kDefaultClients.map((client) {
                                final isSel =
                                    _filterClient == client.companyName;
                                return PopupMenuItem<String>(
                                  value: client.companyName,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: isSel
                                              ? AquaColors.turquoise.withValues(
                                                  alpha: 0.16,
                                                )
                                              : AquaColors.iceBlue,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            client.companyName.isNotEmpty
                                                ? client.companyName[0]
                                                      .toUpperCase()
                                                : 'C',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: isSel
                                                  ? AquaColors.turquoise
                                                  : AquaColors.slateBlue,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          client.companyName,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            fontWeight: isSel
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isSel
                                                ? AquaColors.turquoise
                                                : AquaColors.textPrimary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '\$${client.pricePerBottle.toStringAsFixed(0)}/garr.',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AquaColors.textMuted,
                                        ),
                                      ),
                                      if (isSel) ...[
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          size: 16,
                                          color: AquaColors.turquoise,
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }),
                            ],
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _filterClient == null ||
                                              _filterClient == 'all'
                                          ? 'Todos los clientes'
                                          : _filterClient!,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            _filterClient == null ||
                                                _filterClient == 'all'
                                            ? AquaColors.textPrimary
                                            : AquaColors.turquoise,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                    color: AquaColors.turquoise,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
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
          'No hay registros disponibles',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AquaColors.textSecondary,
          ),
        ),
      );
    }

    final showPrices = widget.showFinancials;
    final totalSales = records.fold<double>(
      0.0,
      (sum, r) => sum + r.totalPrice,
    );
    final Map<int, TableColumnWidth> colWidths = showPrices
        ? const {
            0: FixedColumnWidth(95), // Fecha
            1: FixedColumnWidth(70), // Hora
            2: FixedColumnWidth(115), // Punto/Zona
            3: FixedColumnWidth(105), // Despachador
            4: FixedColumnWidth(145), // Cliente
            5: FixedColumnWidth(95), // Garrafones
            6: FixedColumnWidth(120), // Operación
            7: FixedColumnWidth(140), // Recibió
            8: FixedColumnWidth(110), // Precio Unit.
            9: FixedColumnWidth(110), // Total
            10: FixedColumnWidth(96), // Firma
          }
        : const {
            0: FixedColumnWidth(85), // Fecha
            1: FixedColumnWidth(62), // Hora
            2: FixedColumnWidth(105), // Punto/Zona
            3: FixedColumnWidth(95), // Despachador
            4: FixedColumnWidth(115), // Cliente
            5: FixedColumnWidth(85), // Garrafones
            6: FixedColumnWidth(95), // Operación
            7: FixedColumnWidth(110), // Recibió
            8: FixedColumnWidth(92), // Firma
          };
    final double tableWidth = colWidths.values
        .whereType<FixedColumnWidth>()
        .fold(0.0, (sum, w) => sum + w.value);

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
              border: Border.all(color: AquaColors.platinum, width: 1.5),
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
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      // Fixed Grid Header
                      Container(
                        color: AquaColors.glacier.withValues(alpha: 0.65),
                        child: Table(
                          columnWidths: colWidths,
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
                                _buildGridHeaderCell(
                                  'Fecha',
                                  Icons.calendar_today_outlined,
                                ),
                                _buildGridHeaderCell(
                                  'Hora',
                                  Icons.access_time_rounded,
                                ),
                                _buildGridHeaderCell(
                                  'Punto / Zona',
                                  Icons.location_on_outlined,
                                ),
                                _buildGridHeaderCell(
                                  'Despachador',
                                  Icons.local_drink_outlined,
                                ),
                                _buildGridHeaderCell(
                                  'Cliente',
                                  Icons.business_center_outlined,
                                ),
                                _buildGridHeaderCell(
                                  'Garrafones',
                                  Icons.water_drop_outlined,
                                ),
                                _buildGridHeaderCell(
                                  'Operación',
                                  Icons.sync_alt_rounded,
                                ),
                                _buildGridHeaderCell(
                                  'Recibió',
                                  Icons.person_outline_rounded,
                                ),
                                if (showPrices) ...[
                                  _buildGridHeaderCell(
                                    'Precio Unit.',
                                    Icons.attach_money_rounded,
                                  ),
                                  _buildGridHeaderCell(
                                    'Total (\$)',
                                    Icons.payments_rounded,
                                  ),
                                ],
                                _buildGridHeaderCell(
                                  'Firma',
                                  Icons.draw_outlined,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Table(
                            columnWidths: colWidths,
                            border: TableBorder(
                              horizontalInside: BorderSide(
                                color: AquaColors.platinum.withValues(
                                  alpha: 0.5,
                                ),
                                width: 1,
                              ),
                              verticalInside: BorderSide(
                                color: AquaColors.platinum.withValues(
                                  alpha: 0.5,
                                ),
                                width: 1,
                              ),
                            ),
                            children: [
                              ...List.generate(records.length, (index) {
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
                                        color: AquaColors.glacier.withValues(
                                          alpha: 0.5,
                                        ),
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

                                  // Cliente
                                  _buildGridCell(
                                    Text(
                                      item.clientName.isEmpty
                                          ? '—'
                                          : item.clientName,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: item.clientName.isEmpty
                                            ? AquaColors.textSecondary
                                            : AquaColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
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
                                          color: AquaColors.turquoise
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: AquaColors.turquoise
                                                .withValues(alpha: 0.5),
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
                                                ? AquaColors.statusResuppliedBg
                                                : AquaColors.statusSuppliedBg,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: item.isResupply
                                                  ? AquaColors
                                                        .statusResuppliedBorder
                                                  : AquaColors
                                                        .statusSuppliedBorder,
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Text(
                                            item.isResupply
                                                ? 'Reabasto'
                                                : 'Abasto',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: item.isResupply
                                                  ? AquaColors.statusResupplied
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

                                  if (showPrices) ...[
                                    // Precio Unit.
                                    _buildGridCell(
                                      item.pricePerBottle > 0
                                          ? Text(
                                              '\$${item.pricePerBottle.toStringAsFixed(2)}',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 11,
                                                color: AquaColors.textPrimary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )
                                          : Text(
                                              '—',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 11,
                                                color: AquaColors.textSecondary,
                                              ),
                                            ),
                                    ),

                                    // Total ($)
                                    _buildGridCell(
                                      item.pricePerBottle > 0
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AquaColors.statusSupplied
                                                    .withValues(alpha: 0.10),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: AquaColors
                                                      .statusSupplied
                                                      .withValues(alpha: 0.35),
                                                ),
                                              ),
                                              child: Text(
                                                '\$${item.totalPrice.toStringAsFixed(2)}',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color:
                                                      AquaColors.statusSupplied,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              '—',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 11,
                                                color: AquaColors.textSecondary,
                                              ),
                                            ),
                                    ),
                                  ],

                                  // Firma Button
                                  _buildGridCell(
                                    Center(
                                      child: InkWell(
                                        onTap: () => _showSignatureDialog(item),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AquaColors.turquoise
                                                .withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: AquaColors.turquoise
                                                  .withValues(alpha: 0.3),
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
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 10,
                                    ),
                                  ),
                                ],
                              );
                            }),
                            if (showPrices)
                              TableRow(
                                decoration: BoxDecoration(
                                  color: records.length % 2 == 0
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : AquaColors.iceBlue.withValues(alpha: 0.35),
                                ),
                                children: [
                                  // 0: Fecha
                                  _buildGridCell(const SizedBox.shrink()),
                                  // 1: Hora
                                  _buildGridCell(const SizedBox.shrink()),
                                  // 2: Punto / Zona
                                  _buildGridCell(const SizedBox.shrink()),
                                  // 3: Despachador
                                  _buildGridCell(const SizedBox.shrink()),
                                  // 4: Cliente
                                  _buildGridCell(const SizedBox.shrink()),
                                  // 5: Garrafones
                                  _buildGridCell(const SizedBox.shrink()),
                                  // 6: Operación
                                  _buildGridCell(const SizedBox.shrink()),
                                  // 7: Recibió
                                  _buildGridCell(const SizedBox.shrink()),
                                  // 8: Precio Unit.
                                  _buildGridCell(const SizedBox.shrink()),
                                  // 9: Total ($)
                                  _buildGridCell(
                                    Text(
                                      '\$${totalSales.toStringAsFixed(2)}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        color: AquaColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  // 10: Firma
                                  _buildGridCell(const SizedBox.shrink()),
                                ],
                              ),
                          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AquaColors.turquoise),
          const SizedBox(width: 5),
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
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCell(
    Widget child, {
    Alignment alignment = Alignment.centerLeft,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 10,
    ),
  }) {
    return Container(padding: padding, alignment: alignment, child: child);
  }

  Widget _buildBarChartView(List<SupplyRecord> records) {
    // Group bottles by day (last 7 days)
    final Map<String, int> dailyBottles = {};
    final Map<String, String> dayLabels = {};

    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
      dailyBottles[key] = 0;

      final weekdayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      dayLabels[key] = '${weekdayNames[d.weekday - 1]}\n${d.day}';
    }

    for (final r in records) {
      final key =
          '${r.timestamp.day.toString().padLeft(2, '0')}/${r.timestamp.month.toString().padLeft(2, '0')}';
      if (dailyBottles.containsKey(key)) {
        dailyBottles[key] = dailyBottles[key]! + r.bottles;
      }
    }

    final maxVal = dailyBottles.values.fold(
      1,
      (prev, val) => val > prev ? val : prev,
    );

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
                    Expanded(
                      child: Text(
                        'Garrafones entregados (últimos 7 días)',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AquaColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
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
                      final heightFactor = maxVal == 0
                          ? 0.05
                          : (count / maxVal).clamp(0.08, 1.0);
                      final isToday =
                          entry.key ==
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
                              color: count > 0
                                  ? AquaColors.turquoise
                                  : AquaColors.textMuted,
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
                                        AquaColors.slateBlue.withValues(
                                          alpha: 0.85,
                                        ),
                                        AquaColors.turquoise.withValues(
                                          alpha: 0.65,
                                        ),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: count > 0
                                  ? [
                                      BoxShadow(
                                        color: AquaColors.turquoise.withValues(
                                          alpha: 0.3,
                                        ),
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
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isToday
                                  ? AquaColors.turquoise
                                  : AquaColors.textSecondary,
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
  TableBorder toTableBorder() =>
      TableBorder(horizontalInside: this, verticalInside: this);
}
