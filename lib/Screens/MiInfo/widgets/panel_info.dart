import 'package:flutter/material.dart';

import '../estilo/paleta_mi_info.dart';

/// Panel base sin imagen de fondo.
class PanelInfo extends StatelessWidget {
  const PanelInfo({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radio = BorderRadius.circular(PaletaMiInfo.radioPanel);

    return Padding(
      padding: const EdgeInsets.only(bottom: PaletaMiInfo.separacionPaneles),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.18),
          borderRadius: radio,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: PaletaMiInfo.rellenoPanel,
        child: child,
      ),
    );
  }
}
