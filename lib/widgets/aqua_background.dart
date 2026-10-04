import 'package:flutter/material.dart';
import '../theme/aqua_colors.dart';

/// Fondo principal de AquaControl.
/// Gradiente Ice Blue → Glacier limpio.
class AquaBackground extends StatelessWidget {
  final Widget child;
  final bool showLightWaves;
  final bool useSafeArea;

  const AquaBackground({
    super.key,
    required this.child,
    this.showLightWaves = false,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = useSafeArea ? SafeArea(child: child) : child;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AquaColors.iceBlue,
            Color(0xFFCCE5EF),
            AquaColors.glacier,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: content,
    );
  }
}
