/// Datos ya resueltos que se pintan en la pantalla "Mi Info".
///
/// A diferencia de `PerfilFirebase`, aquí no falta nada: los valores
/// siempre tienen un contenido (parámetro, Firebase o ejemplo).
class DatosPerfil {
  const DatosPerfil({
    required this.nombre,
    required this.experiencia,
    required this.edad,
    required this.logros,
    this.avatarUrl,
  });

  /// XP necesarios para subir de nivel (para la barra de progreso).
  static const int xpPorNivel = 100;

  final String nombre;
  final int experiencia;
  final int edad;
  final int logros;
  final String? avatarUrl;

  /// Avance de 0.0 a 1.0 hacia el siguiente nivel.
  double get progresoExperiencia {
    if (experiencia <= 0) return 0;

    final int resto = experiencia % xpPorNivel;
    final double avance = resto == 0 ? 1.0 : resto / xpPorNivel;
    return avance.clamp(0.0, 1.0).toDouble();
  }
}
