import 'package:flutter/material.dart';

/// Logo oficial de AquaControl — Muestra el isotipo oficial de la gota turquesa.
class AquaLogo extends StatelessWidget {
  final double size;
  final BoxFit fit;

  const AquaLogo({
    super.key,
    this.size = 48,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icon/app_icon.png',
      width: size,
      height: size,
      fit: fit,
      semanticLabel: 'AquaControl Logo',
    );
  }
}
