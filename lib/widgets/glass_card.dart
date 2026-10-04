import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/aqua_colors.dart';

/// Tarjeta con efecto glassmorphism — superficies translúcidas AquaControl.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double blurSigma;
  final List<BoxShadow>? customShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.blurSigma = 0.0,
    this.customShadow,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveShadow = customShadow ??
        [
          BoxShadow(
            color: AquaColors.shadowCard,
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AquaColors.shadowCard.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Blanco translúcido premium — efecto glass auténtico
        color: backgroundColor ?? AquaColors.glassSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AquaColors.glassBorder,
          width: borderWidth,
        ),
        boxShadow: effectiveShadow,
      ),
      child: child,
    );

    if (blurSigma > 0) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: content,
        ),
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          splashColor: AquaColors.turquoise.withValues(alpha: 0.08),
          highlightColor: AquaColors.glacier.withValues(alpha: 0.12),
          child: content,
        ),
      );
    }

    return content;
  }
}
