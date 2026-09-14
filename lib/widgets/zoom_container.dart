import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aqua_colors.dart';

class AquaZoomContainer extends StatefulWidget {
  final Widget child;
  final bool showFloatingToggle;

  const AquaZoomContainer({
    super.key,
    required this.child,
    this.showFloatingToggle = true,
  });

  @override
  State<AquaZoomContainer> createState() => _AquaZoomContainerState();
}

class _AquaZoomContainerState extends State<AquaZoomContainer> {
  bool _isZoomActive = false;
  final TransformationController _controller = TransformationController();

  void _toggleZoom() {
    setState(() {
      _isZoomActive = !_isZoomActive;
      if (!_isZoomActive) {
        _controller.value = Matrix4.identity();
      }
    });
  }

  void _resetZoom() {
    setState(() {
      _controller.value = Matrix4.identity();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content with conditional InteractiveViewer
        Positioned.fill(
          child: InteractiveViewer(
            transformationController: _controller,
            panEnabled: _isZoomActive,
            scaleEnabled: _isZoomActive,
            minScale: 1.0,
            maxScale: 4.0,
            clipBehavior: Clip.none,
            child: widget.child,
          ),
        ),

        // Banner de Zoom Activo — glass claro
        if (_isZoomActive)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 20,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: AquaColors.turquoise.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AquaColors.turquoise.withValues(alpha: 0.35),
                      blurRadius: 18,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.pinch_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Modo Zoom Activo • Pellizca la pantalla',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _resetZoom,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        child: Text(
                          '1x',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: _toggleZoom,
                      borderRadius: BorderRadius.circular(8),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Floating Zoom Toggle Button — glass style
        if (widget.showFloatingToggle)
          Positioned(
            right: 16,
            bottom: 80,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleZoom,
                borderRadius: BorderRadius.circular(24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: _isZoomActive ? 14 : 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _isZoomActive
                        ? AquaColors.turquoise
                        : AquaColors.glassSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isZoomActive
                          ? Colors.white.withValues(alpha: 0.3)
                          : AquaColors.glassBorderSubtle,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isZoomActive
                            ? AquaColors.turquoise.withValues(alpha: 0.40)
                            : AquaColors.shadowCard,
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isZoomActive
                            ? Icons.zoom_out_map_rounded
                            : Icons.zoom_in_rounded,
                        size: 20,
                        color: _isZoomActive
                            ? Colors.white
                            : AquaColors.turquoise,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isZoomActive ? 'Zoom ON' : 'Zoom',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isZoomActive
                              ? Colors.white
                              : AquaColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
