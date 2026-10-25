import 'package:flutter/material.dart';

import 'paleta_mi_info.dart';

/// Estilos de texto del estilo maya de la pantalla "Mi Info".
///
/// El texto parece tallado: color piedra clara con sombra jade debajo
/// y, en el título, un brillo dorado alrededor.
class EstilosMiInfo {
  EstilosMiInfo._(); // Clase de solo constantes: no se instancia

  /// Título central "Mi Info": ahora es el dibujo `barrainfo.svg`, así que
  /// este estilo queda solo por si algún día se vuelve a escribir con letra.
  static const TextStyle titulo = TextStyle(
    fontSize: 44,
    fontWeight: FontWeight.w900,
    letterSpacing: 4,
    color: PaletaMiInfo.piedraBrillo,
    shadows: [
      Shadow(color: PaletaMiInfo.jadeNoche, blurRadius: 4, offset: Offset(0, 3)),
      Shadow(color: PaletaMiInfo.oro, blurRadius: 20),
    ],
  );

  /// Título de una sección (por ejemplo "Editar perfil").
  static const TextStyle tituloSeccion = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    letterSpacing: 2,
    color: PaletaMiInfo.piedraBrillo,
    shadows: [
      Shadow(color: PaletaMiInfo.jadeNoche, blurRadius: 4, offset: Offset(0, 3)),
      Shadow(color: PaletaMiInfo.oro, blurRadius: 16),
    ],
  );

  /// Etiqueta bilingüe que va encima del valor ("Nombre / K'aaba'").
  ///
  /// Va en tinta oscura porque ahora las tarjetas son de piedra verde
  /// (el dibujo `cuadro.jpeg`), igual que el texto del rótulo "Mi Info".
  static const TextStyle etiqueta = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
    color: PaletaMiInfo.tinta,
  );

  /// Valor de cada panel (nombre, XP, edad, logros), grabado en la piedra:
  /// tinta oscura con un brillo claro debajo, como si estuviera tallado.
  static const TextStyle valor = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: PaletaMiInfo.tinta,
    shadows: [
      Shadow(
        color: PaletaMiInfo.piedraBrillo,
        blurRadius: 1.6,
        offset: Offset(0, 1.6),
      ),
    ],
  );

  /// Texto bajo el avatar ("Avatar / Oochel"), grabado en la piedra.
  static const TextStyle etiquetaAvatar = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: PaletaMiInfo.tinta,
  );

  /// Hora "9:00" del panel superior.
  static const TextStyle hora = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w900,
    letterSpacing: 1,
    color: PaletaMiInfo.piedraBrillo,
  );

  /// Pestaña normal de la barra inferior (sobre metal).
  static const TextStyle pestana = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    color: PaletaMiInfo.tinta,
  );

  /// Pestaña seleccionada ("Inicio" o "Mi Perfil") sobre metal.
  static const TextStyle pestanaSeleccionada = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w900,
    color: PaletaMiInfo.tinta,
  );

  /// Texto de los botones dorados ("Guardar", "Editar perfil").
  static const TextStyle boton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.6,
    color: PaletaMiInfo.tinta,
  );

  /// Lo que el niño escribe en los campos de la pantalla de edición.
  static const TextStyle campo = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w900,
    color: PaletaMiInfo.piedraBrillo,
  );

  /// Nombre del campo (etiqueta) dentro de la pantalla de edición.
  static const TextStyle etiquetaCampo = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: PaletaMiInfo.piedraClara,
  );

  /// Mensaje de error de un campo ("Escribe tu nombre").
  static const TextStyle errorCampo = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: PaletaMiInfo.rosa,
  );

  /// Nombre que acompaña a cada opción del selector de avatar.
  /// Va grabado en la piedra verde de la tarjeta, por eso es tinta oscura.
  static const TextStyle opcionAvatar = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: PaletaMiInfo.tinta,
  );
}
