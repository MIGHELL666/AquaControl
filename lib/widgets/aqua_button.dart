import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aqua_colors.dart';

enum AquaButtonType { primary, secondary, danger, ghost }

class AquaButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AquaButtonType type;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isLoading;
  final double borderRadius;

  const AquaButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AquaButtonType.primary,
    this.icon,
    this.width = double.infinity,
    this.height = 54,
    this.isLoading = false,
    this.borderRadius = 26,
  });

  @override
  State<AquaButton> createState() => _AquaButtonState();
}

class _AquaButtonState extends State<AquaButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.type == AquaButtonType.primary;
    final isDanger = widget.type == AquaButtonType.danger;
    final isSecondary = widget.type == AquaButtonType.secondary;

    // Colors per type
    Color bgColor;
    Color textColor;
    Color borderColor;
    List<BoxShadow> shadows;
    Gradient? gradient;

    if (isPrimary) {
      gradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF538EA8), AquaColors.turquoise, Color(0xFF3A6E85)],
      );
      bgColor = AquaColors.turquoise;
      textColor = AquaColors.textOnDark;
      borderColor = Colors.white.withValues(alpha: 0.25);
      shadows = [
        BoxShadow(
          color: AquaColors.shadowButton,
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];
    } else if (isDanger) {
      gradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFD46B60), AquaColors.statusError, Color(0xFFAA4038)],
      );
      bgColor = AquaColors.statusError;
      textColor = AquaColors.textOnDark;
      borderColor = AquaColors.statusError.withValues(alpha: 0.35);
      shadows = [
        BoxShadow(
          color: AquaColors.statusError.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 5),
        ),
      ];
    } else if (isSecondary) {
      gradient = null;
      bgColor = AquaColors.glassSurface;
      textColor = AquaColors.turquoise;
      borderColor = AquaColors.slateBlue.withValues(alpha: 0.55);
      shadows = [
        BoxShadow(
          color: AquaColors.shadowCard,
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ];
    } else {
      // ghost
      gradient = null;
      bgColor = Colors.transparent;
      textColor = AquaColors.turquoise;
      borderColor = AquaColors.glassBorderSubtle;
      shadows = [];
    }

    final isDisabled = widget.onPressed == null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) {
          if (!isDisabled) _controller.forward();
        },
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: isDisabled ? null : gradient,
            color: isDisabled ? AquaColors.platinum : (gradient == null ? bgColor : null),
            border: Border.all(
              color: isDisabled ? AquaColors.glassBorderSubtle : borderColor,
              width: 1,
            ),
            boxShadow: isDisabled ? [] : shadows,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              onTap: widget.isLoading ? null : widget.onPressed,
              splashColor: Colors.white.withValues(alpha: 0.15),
              highlightColor: Colors.white.withValues(alpha: 0.08),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isPrimary ? Colors.white : AquaColors.turquoise,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              size: 18,
                              color: isDisabled
                                  ? AquaColors.textMuted
                                  : textColor,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: GoogleFonts.montserrat(
                              color: isDisabled
                                  ? AquaColors.textMuted
                                  : textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
