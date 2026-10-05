import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/zone_data.dart';

class TablePdfPrinter {
  static Future<void> printRecordsTable(
    List<SupplyRecord> records, {
    bool includePrices = true,
  }) async {
    final pdf = pw.Document();

    final totalBottles = records.fold<int>(0, (sum, r) => sum + r.bottles);
    final totalAmount = records.fold<double>(
      0.0,
      (sum, r) => sum + r.totalPrice,
    );

    final now = DateTime.now();
    final reportDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          _buildHeader(
            reportDate,
            totalBottles,
            totalAmount,
            includePrices: includePrices,
          ),
          pw.SizedBox(height: 14),
          _buildDataTable(records, includePrices: includePrices),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Reporte_AquaControl_${now.year}_${now.month}_${now.day}.pdf',
    );
  }

  static pw.Widget _buildHeader(
    String reportDate,
    int totalBottles,
    double totalAmount, {
    bool includePrices = true,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFD6EBF3),
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColor.fromInt(0xFF447F98), width: 0.8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 50,
            height: 50,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF447F98),
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                'A',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'AquaControl - Reporte de Abastecimientos',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF132D3B),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Fecha de emisión: $reportDate',
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: PdfColor.fromInt(0xFF355668),
                  ),
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF447F98),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  'Total: $totalBottles garrafones',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              if (includePrices) ...[
                pw.SizedBox(height: 6),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF2A7A5C),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'Monto total: \$${totalAmount.toStringAsFixed(2)} MXN',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDataTable(
    List<SupplyRecord> records, {
    bool includePrices = true,
  }) {
    final headers = [
      'Fecha',
      'Hora',
      'Cliente',
      'Zona',
      'Despachador',
      'Garrafones',
      if (includePrices) 'Precio Unit.',
      if (includePrices) 'Total (\$)',
      'Operación',
      'Recibió',
      'Firma Digital',
    ];

    final headerColor = PdfColor.fromInt(0xFF447F98);
    final borderColor = PdfColor.fromInt(0xFFDADEE1);

    final columnWidths = includePrices
        ? const <int, pw.TableColumnWidth>{
            0: pw.FixedColumnWidth(60),
            1: pw.FixedColumnWidth(50),
            2: pw.FixedColumnWidth(115),
            3: pw.FixedColumnWidth(70),
            4: pw.FixedColumnWidth(65),
            5: pw.FixedColumnWidth(60),
            6: pw.FixedColumnWidth(65),
            7: pw.FixedColumnWidth(65),
            8: pw.FixedColumnWidth(65),
            9: pw.FixedColumnWidth(95),
            10: pw.FixedColumnWidth(120),
          }
        : const <int, pw.TableColumnWidth>{
            0: pw.FixedColumnWidth(65),
            1: pw.FixedColumnWidth(55),
            2: pw.FixedColumnWidth(145),
            3: pw.FixedColumnWidth(80),
            4: pw.FixedColumnWidth(75),
            5: pw.FixedColumnWidth(70),
            6: pw.FixedColumnWidth(75),
            7: pw.FixedColumnWidth(115),
            8: pw.FixedColumnWidth(140),
          };

    return pw.Table(
      border: pw.TableBorder.all(color: borderColor, width: 0.6),
      columnWidths: columnWidths,
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: headerColor),
          children: headers.map((h) {
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 8,
              ),
              child: pw.Text(
                h,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
            );
          }).toList(),
        ),
        ...records.asMap().entries.map((entry) {
          final idx = entry.key;
          final r = entry.value;
          final bgColor = idx % 2 == 0
              ? PdfColors.white
              : PdfColor.fromInt(0xFFEAF4F8);

          return pw.TableRow(
            decoration: pw.BoxDecoration(color: bgColor),
            children: [
              _cell(r.dateFormatted, center: true, size: 8),
              _cell(r.timeFormatted, center: true, size: 8),
              _cell(
                r.clientName.isEmpty ? 'Sin cliente' : r.clientName,
                size: 8,
                bold: false,
              ),
              _cell(r.zoneName, center: true, size: 8),
              _cell(r.dispenserId, center: true, size: 8, bold: true),
              _cell('${r.bottles}', center: true, size: 8, bold: true),
              if (includePrices)
                _cell(
                  '\$${r.pricePerBottle.toStringAsFixed(2)}',
                  center: true,
                  size: 8,
                ),
              if (includePrices)
                _cell(
                  '\$${r.totalPrice.toStringAsFixed(2)}',
                  center: true,
                  size: 8.5,
                  bold: true,
                  color: PdfColor.fromInt(0xFF2A7A5C),
                ),
              _cell(
                r.isResupply ? 'Reabasto' : 'Abasto',
                center: true,
                size: 8,
                bold: true,
                color: r.isResupply
                    ? PdfColor.fromInt(0xFF2563EB)
                    : PdfColor.fromInt(0xFF2A7A5C),
              ),
              _cell(r.recipientName, size: 8),
              _buildSignatureCell(r.signaturePoints),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _cell(
    String text, {
    bool center = false,
    double size = 9,
    bool bold = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: size,
          color: color ?? PdfColor.fromInt(0xFF132D3B),
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
        maxLines: 2,
        overflow: pw.TextOverflow.clip,
      ),
    );
  }

  static pw.Widget _buildSignatureCell(List<Offset>? points) {
    final child = (points == null || points.isEmpty)
        ? pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: pw.Text(
              'Sin firma',
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColor.fromInt(0xFF648494),
                fontStyle: pw.FontStyle.italic,
              ),
              textAlign: pw.TextAlign.center,
            ),
          )
        : pw.Container(
            width: 120,
            height: 48,
            padding: const pw.EdgeInsets.all(4),
            child: _buildSignatureDrawing(points),
          );

    return pw.Padding(
      padding: const pw.EdgeInsets.all(2),
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(
            color: PdfColor.fromInt(0xFFDADEE1),
            width: 0.4,
          ),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: child,
      ),
    );
  }

  static pw.Widget _buildSignatureDrawing(List<Offset> points) {
    if (points.isEmpty) {
      return pw.Container();
    }

    double minX = points.first.dx;
    double maxX = points.first.dx;
    double minY = points.first.dy;
    double maxY = points.first.dy;

    for (final p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    final width = (maxX - minX).abs();
    final height = (maxY - minY).abs();

    return pw.CustomPaint(
      size: PdfPoint(112, 40),
      painter: (PdfGraphics canvas, PdfPoint size) {
        final paint = PdfColor.fromInt(0xFF132D3B);
        canvas.setLineWidth(0.7);
        canvas.setStrokeColor(paint);

        final normalizerX = width <= 0 ? 1.0 : size.x / width;
        final normalizerY = height <= 0 ? 1.0 : size.y / height;
        final normalizer = normalizerX < normalizerY
            ? normalizerX
            : normalizerY;

        for (int i = 1; i < points.length; i++) {
          final dx1 = (points[i - 1].dx - minX) * normalizer;
          final dy1 = size.y - (points[i - 1].dy - minY) * normalizer;
          final dx2 = (points[i].dx - minX) * normalizer;
          final dy2 = size.y - (points[i].dy - minY) * normalizer;
          canvas.drawLine(dx1, dy1, dx2, dy2);
        }
        canvas.strokePath();
      },
    );
  }
}
