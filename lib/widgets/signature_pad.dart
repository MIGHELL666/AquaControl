import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aqua_colors.dart';

class SignatureStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  const SignatureStroke({
    required this.points,
    this.color = AquaColors.turquoise,
    this.strokeWidth = 3.0,
  });
}

class SignaturePad extends StatefulWidget {
  final ValueChanged<List<Offset>> onSignatureChanged;
  final VoidCallback? onCleared;
  final double height;

  const SignaturePad({
    super.key,
    required this.onSignatureChanged,
    this.onCleared,
    this.height = 200,
  });

  @override
  State<SignaturePad> createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  bool get hasSignature => _strokes.isNotEmpty || _currentStroke.isNotEmpty;

  List<Offset> getAllPoints() {
    final List<Offset> all = [];
    for (final stroke in _strokes) {
      all.addAll(stroke);
      // Sentinel offset (-1, -1) para separar trazos
      all.add(const Offset(-1, -1));
    }
    return all;
  }

  void clear() {
    setState(() {
      _strokes.clear();
      _currentStroke.clear();
    });
    widget.onSignatureChanged([]);
    widget.onCleared?.call();
  }

  void _notifyChange() {
    widget.onSignatureChanged(getAllPoints());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            // Fondo Glacier translúcido — superficie de firma
            color: AquaColors.glacier.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasSignature
                  ? AquaColors.turquoise.withValues(alpha: 0.55)
                  : AquaColors.glassBorderSubtle,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AquaColors.shadowCard,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Fondo de la canvas blanco semitransparente
                Container(
                  color: Colors.white.withValues(alpha: 0.55),
                ),

                // Canvas de firma con detector de gestos
                GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _currentStroke = [details.localPosition];
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _currentStroke.add(details.localPosition);
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      if (_currentStroke.isNotEmpty) {
                        _strokes.add(List.from(_currentStroke));
                        _currentStroke = [];
                      }
                    });
                    _notifyChange();
                  },
                  child: CustomPaint(
                    painter: _SignaturePainter(
                      strokes: _strokes,
                      currentStroke: _currentStroke,
                      color: AquaColors.turquoise,
                    ),
                    size: Size.infinite,
                  ),
                ),

                // Línea base de firma
                Positioned(
                  bottom: 40,
                  left: 24,
                  right: 24,
                  child: IgnorePointer(
                    child: Container(
                      height: 1,
                      color: AquaColors.platinum.withValues(alpha: 0.6),
                    ),
                  ),
                ),

                // Texto de etiqueta de firma
                Positioned(
                  bottom: 22,
                  left: 28,
                  child: IgnorePointer(
                    child: Text(
                      'Firma',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        color: AquaColors.textMuted,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                // Placeholder si está vacío
                if (!hasSignature)
                  Center(
                    child: IgnorePointer(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.draw_rounded,
                            size: 30,
                            color: AquaColors.slateBlue.withValues(alpha: 0.35),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Firme aquí con el dedo',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: AquaColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Botón de borrar — esquina superior derecha
                if (hasSignature)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: clear,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AquaColors.glassSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AquaColors.glassBorderSubtle,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                size: 13,
                                color: AquaColors.turquoise,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Borrar',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  color: AquaColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Color color;

  _SignaturePainter({
    required this.strokes,
    required this.currentStroke,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      _paintStroke(canvas, stroke, paint);
    }
    if (currentStroke.isNotEmpty) {
      _paintStroke(canvas, currentStroke, paint);
    }
  }

  void _paintStroke(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) {
      if (points.length == 1) {
        canvas.drawCircle(points.first, 1.5, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
      }
      return;
    }
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}

/// Vista previa compacta de la firma capturada
class SignaturePreviewBox extends StatelessWidget {
  final List<Offset>? points;
  final double width;
  final double height;

  const SignaturePreviewBox({
    super.key,
    this.points,
    this.width = double.infinity,
    this.height = 70,
  });

  @override
  Widget build(BuildContext context) {
    if (points == null || points!.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AquaColors.glacier.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AquaColors.glassBorderSubtle),
        ),
        alignment: Alignment.center,
        child: Text(
          'Firma registrada',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: AquaColors.textMuted,
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AquaColors.turquoise.withValues(alpha: 0.35),
        ),
      ),
      child: ClipRect(
        child: CustomPaint(
          painter: _PointsThumbnailPainter(points!),
          size: Size(width, height),
        ),
      ),
    );
  }
}

class _PointsThumbnailPainter extends CustomPainter {
  final List<Offset> points;

  _PointsThumbnailPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final validPoints = points.where((p) => p.dx >= 0 && p.dy >= 0).toList();
    if (validPoints.isEmpty) return;

    double minX = validPoints.first.dx;
    double maxX = validPoints.first.dx;
    double minY = validPoints.first.dy;
    double maxY = validPoints.first.dy;

    for (final p in validPoints) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    final origWidth = (maxX - minX).clamp(1.0, 1000.0);
    final origHeight = (maxY - minY).clamp(1.0, 1000.0);

    final scaleX = (size.width - 12) / origWidth;
    final scaleY = (size.height - 12) / origHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final paint = Paint()
      ..color = AquaColors.turquoise
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool inStroke = false;

    for (final p in points) {
      if (p.dx < 0 || p.dy < 0) {
        inStroke = false;
        continue;
      }
      final mappedX = 6 + (p.dx - minX) * scale;
      final mappedY = 6 + (p.dy - minY) * scale;
      if (!inStroke) {
        path.moveTo(mappedX, mappedY);
        inStroke = true;
      } else {
        path.lineTo(mappedX, mappedY);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PointsThumbnailPainter oldDelegate) => false;
}
