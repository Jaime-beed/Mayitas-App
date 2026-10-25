import 'package:firebase_database/firebase_database.dart';

import 'lectura_firebase.dart';

/// Valores crudos leídos de Firebase para el perfil del usuario.
///
/// Todos los campos son opcionales porque en la base pueden no existir
/// todavía (por ejemplo, el campo 'logros' aún no se guarda al registrar).
class PerfilFirebase {
  const PerfilFirebase({
    this.nombre,
    this.experiencia,
    this.edad,
    this.logros,
    this.avatarUrl,
  });

  /// Convierte el nodo `usuarios/<uid>` en un [PerfilFirebase].
  factory PerfilFirebase.desdeSnapshot(DataSnapshot snapshot) {
    // El nombre completo se forma uniendo 'nombre' + 'apellido'
    final String? nombre = LecturaFirebase.texto(snapshot.child('nombre'));
    final String? apellido = LecturaFirebase.texto(snapshot.child('apellido'));
    final String completo = <String>[?nombre, ?apellido].join(' ');

    return PerfilFirebase(
      nombre: completo.isEmpty ? null : completo,
      experiencia: LecturaFirebase.entero(snapshot.child('experiencia')),
      edad: LecturaFirebase.entero(snapshot.child('edad')),
      // Acepta 'logros' o, si no existe, 'logros_desbloqueados'
      logros: LecturaFirebase.entero(snapshot.child('logros')) ??
          LecturaFirebase.entero(snapshot.child('logros_desbloqueados')),
      avatarUrl: LecturaFirebase.texto(snapshot.child('avatar_url')),
    );
  }

  final String? nombre;
  final int? experiencia;
  final int? edad;
  final int? logros;
  final String? avatarUrl;
}
