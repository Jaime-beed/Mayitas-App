import 'package:flutter/material.dart';

import '../estilo/estilos_mi_info.dart';
import '../estilo/paleta_mi_info.dart';
import '../modelo/avatares.dart';

/// Diámetro del retrato de cada opción.
const double _diametroAvatar = 72;

/// Fila con los dos avatares que puede elegir el niño o la niña:
/// Niño y Niña.
///
/// El elegido se marca con un aro dorado.
class SelectorAvatarMiInfo extends StatelessWidget {
  const SelectorAvatarMiInfo({
    super.key,
    required this.seleccionado,
    required this.onCambio,
  });

  /// Género/avatar que está elegido ahora.
  final String seleccionado;

  /// Avisa cuando eligen otro avatar.
  final ValueChanged<String> onCambio;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _OpcionAvatar(
            etiqueta: Avatares.generoNino,
            url: Avatares.nino,
            iconoRespaldo: Icons.face,
            seleccionado: seleccionado == Avatares.generoNino,
            onTap: () => onCambio(Avatares.generoNino),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _OpcionAvatar(
            etiqueta: Avatares.generoNina,
            url: Avatares.nina,
            iconoRespaldo: Icons.face_3,
            seleccionado: seleccionado == Avatares.generoNina,
            onTap: () => onCambio(Avatares.generoNina),
          ),
        ),
      ],
    );
  }
}

/// Una de las dos opciones: el retrato dentro de un aro y su nombre debajo.
class _OpcionAvatar extends StatelessWidget {
  const _OpcionAvatar({
    required this.etiqueta,
    required this.url,
    required this.iconoRespaldo,
    required this.seleccionado,
    required this.onTap,
  });

  final String etiqueta;
  final String url;
  final IconData iconoRespaldo;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: seleccionado,
      label: etiqueta,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: seleccionado
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [PaletaMiInfo.oroClaro, PaletaMiInfo.oroOscuro],
                      )
                    : null,
                color: seleccionado ? null : PaletaMiInfo.piedraOscura,
                boxShadow: seleccionado
                    ? [
                        BoxShadow(
                          color: PaletaMiInfo.oro.withValues(alpha: 0.55),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
              child: SizedBox.square(
                dimension: _diametroAvatar,
                child: ClipOval(child: _retrato()),
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                etiqueta,
                maxLines: 1,
                style: EstilosMiInfo.opcionAvatar,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// La foto del avatar o, si el enlace viene vacío o falla, un icono.
  Widget _retrato() {
    if (url.isEmpty) return _icono();

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: _diametroAvatar,
      height: _diametroAvatar,
      errorBuilder: (_, _, _) => _icono(),
    );
  }

  Widget _icono() {
    return ColoredBox(
      color: PaletaMiInfo.jadeNoche,
      child: Icon(iconoRespaldo, color: PaletaMiInfo.piedraClara, size: 34),
    );
  }
}
