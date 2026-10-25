/// Avatares que el niño o la niña puede elegir: niño o niña.
///
/// Son los mismos enlaces públicos de Firebase Storage que usa la pantalla
/// de registro. Si el perfil no tiene foto guardada, `AvatarUsuario` dibuja
/// al cachorro de leopardo del diseño maya; ese cachorro es solo un dibujo
/// de respaldo, no una opción que se elija aquí.
class Avatares {
  Avatares._(); // Clase de solo constantes: no se instancia

  /// Retrato de niño (Firebase Storage).
  static const String nino =
      'https://firebasestorage.googleapis.com/v0/b/mayitas-9bde2.firebasestorage.app/o/Logos%2FPerfil%20ninio.png?alt=media&token=565e7c20-8aff-450a-bf8e-ca8f917840e0';

  /// Retrato de niña (Firebase Storage).
  static const String nina =
      'https://firebasestorage.googleapis.com/v0/b/mayitas-9bde2.firebasestorage.app/o/Logos%2FPerfil%20ninia.png?alt=media&token=e6adc1f5-03e2-4119-9d5b-df09851baaf7';

  // Nombres con los que se guarda el campo 'genero' en la base
  static const String generoNino = 'Niño';
  static const String generoNina = 'Niña';

  /// Género (niño o niña) que corresponde a un enlace guardado, o null si
  /// el enlace no es ninguno de los dos retratos.
  static String? generoDeUrl(String? url) {
    if (url == nino) return generoNino;
    if (url == nina) return generoNina;
    return null;
  }

  /// Enlace que se guarda en 'avatar_url' para un género elegido.
  static String urlDeGenero(String genero) {
    return genero == generoNina ? nina : nino;
  }

  /// Género que debe verse elegido al abrir la pantalla de edición.
  ///
  /// Mira primero la foto guardada; si no hay foto (perfil viejo o perfil
  /// sin retrato), usa el campo 'genero' y, si tampoco lo hay, empieza en
  /// "Niño", igual que la pantalla de registro.
  static String generoInicial({String? url, String? genero}) {
    final String? porFoto = generoDeUrl(url);
    if (porFoto != null) return porFoto;
    if (genero == generoNina) return generoNina;
    return generoNino;
  }
}
