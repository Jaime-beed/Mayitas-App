import 'package:flutter/material.dart';

import '../estilo/estilos_mi_info.dart';
import '../estilo/paleta_mi_info.dart';

/// Botón de metal dorado con marco de piedra tallada.
///
/// Se usa para "Editar perfil", "Guardar" y "Cancelar". Mientras está
/// [cargando] muestra una vueltita y no responde a los toques.
class BotonMaya extends StatelessWidget {
  const BotonMaya({
    super.key,
    required this.texto,
    this.icono,
    this.onTap,
    this.cargando = false,
  });

  /// Texto que se lee en el botón.
  final String texto;

  /// Icono opcional a la izquierda del texto.
  final IconData? icono;

  /// Qué hacer al tocar. Si es null el botón se ve apagado.
  final VoidCallback? onTap;

  /// Muestra el indicador de "guardando...".
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    final bool activo = onTap != null && !cargando;
    final IconData? iconoActual = icono;

    return Semantics(
      button: true,
      enabled: activo,
      label: texto,
      child: GestureDetector(
        onTap: activo ? onTap : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: activo ? 1 : 0.55,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  PaletaMiInfo.oroClaro,
                  PaletaMiInfo.oro,
                  PaletaMiInfo.oroOscuro,
                ],
                stops: [0.0, 0.45, 1.0],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: PaletaMiInfo.piedraBrillo, width: 2),
              boxShadow: [
                BoxShadow(
                  color: PaletaMiInfo.jadeNoche.withValues(alpha: 0.6),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (cargando)
                  const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: PaletaMiInfo.tinta,
                    ),
                  )
                else if (iconoActual != null) ...[
                  Icon(iconoActual, color: PaletaMiInfo.tinta, size: 20),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      texto,
                      maxLines: 1,
                      style: EstilosMiInfo.boton,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
