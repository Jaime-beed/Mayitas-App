import 'package:flutter/material.dart';

import '../estilo/estilos_mi_info.dart';

/// Barra de progreso simplificada.
class BarraProgresoPiramide extends StatelessWidget {
  const BarraProgresoPiramide({super.key, required this.valor});

  final double valor;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: valor.clamp(0.0, 1.0),
      minHeight: 8,
      backgroundColor: Colors.black26,
      color: EstilosMiInfo.valor.color,
    );
  }
}
