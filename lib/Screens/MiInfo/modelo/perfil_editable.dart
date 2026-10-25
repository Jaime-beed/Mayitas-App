import 'package:firebase_database/firebase_database.dart';

import 'lectura_firebase.dart';

/// Datos del perfil tal como se pueden cambiar desde la pantalla de edición.
///
/// A diferencia de `PerfilFirebase`, aquí el nombre y el apellido vienen
/// separados, porque el formulario los pide en campos distintos.
class PerfilEditable {
  const PerfilEditable({
    this.nombre,
    this.apellido,
    this.edad,
    this.genero,
    this.avatarUrl,
  });

  /// Convierte el nodo `usuarios/<uid>` en un [PerfilEditable].
  factory PerfilEditable.desdeSnapshot(DataSnapshot snapshot) {
    return PerfilEditable(
      nombre: LecturaFirebase.texto(snapshot.child('nombre')),
      apellido: LecturaFirebase.texto(snapshot.child('apellido')),
      edad: LecturaFirebase.entero(snapshot.child('edad')),
      genero: LecturaFirebase.texto(snapshot.child('genero')),
      avatarUrl: LecturaFirebase.texto(snapshot.child('avatar_url')),
    );
  }

  final String? nombre;
  final String? apellido;
  final int? edad;
  final String? genero;
  final String? avatarUrl;
}
