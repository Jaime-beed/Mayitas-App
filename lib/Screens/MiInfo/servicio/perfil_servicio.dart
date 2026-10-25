import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../modelo/perfil_editable.dart';
import '../modelo/perfil_firebase.dart';

/// Acceso a los datos del perfil en Realtime Database.
class PerfilServicio {
  PerfilServicio._(); // Clase de solo métodos estáticos

  /// Lee el nodo `usuarios/<uid>` del usuario con sesión iniciada.
  ///
  /// Devuelve null si no hay sesión, si el nodo no existe o si la
  /// lectura falla (sin conexión, reglas sin permiso, etc.). En esos
  /// casos la pantalla conserva los datos que ya tenía.
  static Future<PerfilFirebase?> leerPerfilActual() async {
    final DataSnapshot? snapshot = await _leerNodoUsuario();
    if (snapshot == null) return null;

    return PerfilFirebase.desdeSnapshot(snapshot);
  }

  /// Igual que [leerPerfilActual], pero con el nombre y el apellido
  /// separados para poder llenar el formulario de edición.
  static Future<PerfilEditable?> leerPerfilEditable() async {
    final DataSnapshot? snapshot = await _leerNodoUsuario();
    if (snapshot == null) return null;

    return PerfilEditable.desdeSnapshot(snapshot);
  }

  /// Guarda los datos que el niño o la niña cambió en su perfil.
  ///
  /// Usa update() a propósito: reemplaza solo estos campos y deja intactos
  /// la experiencia, las monedas, el nivel y las skins que ya tenía.
  ///
  /// Devuelve true si se guardó; false si no hay sesión o si falló la red.
  static Future<bool> guardarCambios({
    required String nombre,
    required String apellido,
    required int edad,
    required String genero,
    required String avatarUrl,
  }) async {
    try {
      final User? usuario = FirebaseAuth.instance.currentUser;
      if (usuario == null) return false;

      await FirebaseDatabase.instance.ref('usuarios/${usuario.uid}').update({
        'nombre': nombre,
        'apellido': apellido,
        'edad': edad,
        'genero': genero,
        'avatar_url': avatarUrl,
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Nodo `usuarios/<uid>` del usuario con sesión, o null si no se pudo leer.
  static Future<DataSnapshot?> _leerNodoUsuario() async {
    try {
      final User? usuario = FirebaseAuth.instance.currentUser;
      if (usuario == null) return null;

      final DataSnapshot snapshot =
          await FirebaseDatabase.instance.ref('usuarios/${usuario.uid}').get();

      if (!snapshot.exists) return null;
      return snapshot;
    } catch (_) {
      return null;
    }
  }
}
