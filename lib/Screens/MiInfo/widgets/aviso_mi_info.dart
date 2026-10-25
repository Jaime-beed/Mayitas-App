import 'package:flutter/material.dart';

import '../estilo/paleta_mi_info.dart';

/// Muestra un aviso flotante con el estilo de piedra y jade de "Mi Info".
///
/// Se usa tanto para los botones que todavía no llevan a otra pantalla
/// ("Juegos") como para confirmar que se guardó el perfil.
void mostrarAvisoMiInfo(BuildContext context, String mensaje) {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: PaletaMiInfo.piedraClara,
      duration: const Duration(seconds: 2),
      content: Text(
        mensaje,
        style: const TextStyle(
          color: PaletaMiInfo.tinta,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
