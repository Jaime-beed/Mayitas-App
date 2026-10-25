import 'package:flutter/material.dart';

import '../estilo/imagenes_mi_info.dart';
import '../estilo/textos_mi_info.dart';
import 'avatar_usuario.dart';
import 'boton_maya.dart';

/// Panel del avatar con cuadro_de_editar_perfil.jpg solo en esta parte.
class PanelAvatar extends StatelessWidget {
  const PanelAvatar({super.key, this.url, this.onEditar});

  final String? url;
  final VoidCallback? onEditar;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? editar = onEditar;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: 16 / 7,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                ImagenesMiInfo.cuadroEditarPerfil,
                fit: BoxFit.fill,
                gaplessPlayback: true,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              AvatarUsuario(tamano: 90, url: url, conLazo: true),
              const SizedBox(height: 6),
              const Text(
                TextosMiInfo.avatar,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
              ),
              if (editar != null) ...[
                const SizedBox(height: 10),
                BotonMaya(
                  texto: TextosMiInfo.editarPerfil,
                  icono: Icons.edit_rounded,
                  onTap: editar,
                ),
              ],
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }
}
