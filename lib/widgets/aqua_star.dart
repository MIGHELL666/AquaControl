import 'package:flutter/material.dart';
import 'aqua_logo.dart';
export 'aqua_logo.dart';

/// Compatibilidad: AquaStar ahora delega en el isotipo oficial [AquaLogo].
class AquaStar extends StatelessWidget {
  final double size;
  final Color? color;
  final bool hasGlow;

  const AquaStar({
    super.key,
    this.size = 48,
    this.color,
    this.hasGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return AquaLogo(size: size);
  }
}
