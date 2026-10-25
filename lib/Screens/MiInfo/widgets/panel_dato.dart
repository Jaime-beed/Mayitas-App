import 'package:flutter/material.dart';

import '../estilo/estilos_mi_info.dart';
import 'panel_info.dart';

/// Panel de un dato: medallón de piedra + etiqueta bilingüe + valor,
/// con relieves mayas opcionales a los lados.
class PanelDato extends StatelessWidget {
  const PanelDato({
    super.key,
    required this.medallon,
    required this.titulo,
    required this.valor,
    this.relieveDerecha,
    this.relieveIzquierda,
  });

  /// Medallón tallado que abre el panel (icono o glifo).
  final Widget medallon;

  /// Etiqueta bilingüe, por ejemplo 'Nombre / Name:'.
  final String titulo;

  /// Valor del dato (texto, fila o columna con la barra de progreso).
  final Widget valor;

  /// Relieve tallado a la derecha (árbol de la vida, loro...).
  final Widget? relieveDerecha;

  /// Relieve que se asoma por la izquierda (monito de peluche).
  final Widget? relieveIzquierda;

  @override
  Widget build(BuildContext context) {
    final Widget? derecha = relieveDerecha;
    final Widget? izquierda = relieveIzquierda;

    return PanelInfo(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: derecha == null ? 0 : 44,
              left: izquierda == null ? 0 : 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                medallon,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: EstilosMiInfo.etiqueta),
                      const SizedBox(height: 4),
                      valor,
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Relieve tallado a la derecha, centrado verticalmente.
          if (derecha != null)
            Positioned(
              right: -6,
              top: 0,
              bottom: 0,
              child: Center(child: derecha),
            ),

          // Relieve que se asoma desde la izquierda (abajo).
          if (izquierda != null)
            Positioned(left: -18, bottom: -16, child: izquierda),
        ],
      ),
    );
  }
}
