/// Todos los textos de la pantalla "Mi Info".
///
/// Las etiquetas de los datos van en español y en maya yucateco
/// (maaya t'aan). Las palabras mayas se tomaron del "Diccionario Básico
/// Español/Maya/Español" de la UADY y de diccionarios maya-español:
///
///  • K'aaba'   → Nombre
///  • Túuntajil → Experiencia (también "pak' tumut")
///  • Ja'abil   → Edad
///  • Náajal    → Logros (lograr / ganar)
///  • Oochel    → Imagen, figura, retrato (el avatar)
///
/// Si alguna palabra se tiene que corregir, se cambia aquí una sola vez.
class TextosMiInfo {
  TextosMiInfo._(); // Clase de solo constantes: no se instancia

  // ---------------- TÍTULOS ----------------
  static const String titulo = 'Mi Info';

  /// OJO: el título de la pantalla de editar ya no se escribe con letras:
  /// ahora es el rótulo de piedra `titulo_editar_mi_info.dart`
  /// (`lib/imagenes/barra de editar perfil.jpeg`). Se deja aquí por si se
  /// regresa al título de letras.
  static const String tituloEditar = 'Editar perfil';

  // ---------------- ETIQUETAS DE LOS DATOS (español / maya) ----------------
  static const String nombre = "Nombre / K'aaba'";
  static const String experiencia = 'Experiencia / Túuntajil';
  static const String edad = "Edad / Ja'abil";
  static const String logros = 'Logros / Náajal';
  static const String avatar = 'Avatar / Oochel';

  // ---------------- BARRA DE NAVEGACIÓN ----------------
  static const String inicio = 'Inicio';
  static const String juegos = 'Juegos';
  static const String miPerfil = 'Mi Perfil';
  static const String configuracion = 'Configuración';

  // ---------------- PANTALLA DE EDICIÓN ----------------
  static const String campoNombre = "Nombre / K'aaba'";
  static const String campoApellido = 'Apellido(s)';
  static const String campoEdad = "Edad / Ja'abil";
  static const String elegirAvatar = 'Elige tu avatar';
  static const String guardar = 'Guardar';
  static const String cancelar = 'Cancelar';
  static const String editarPerfil = 'Editar perfil';

  // ---------------- AVISOS ----------------
  /// Texto que se agrega a los botones que todavía no llevan a otra pantalla.
  static const String proximamente = 'estará disponible en la próxima versión';
  static const String guardadoListo = '¡Listo! Guardamos tu perfil';
  static const String errorGuardado = 'No pudimos guardar. Inténtalo otra vez';
  static const String faltanDatos = 'Revisa los datos marcados';

  /// Aviso para una sección que todavía no existe ("Juegos: ...").
  static String enConstruccion(String seccion) =>
      '$seccion: $proximamente';
  static const String bienvenidaInicio = '¡Bienvenido a Mayitas!';
}
