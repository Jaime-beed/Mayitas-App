import 'package:firebase_database/firebase_database.dart';

/// Lecturas seguras de Realtime Database.
///
/// En la base los datos pueden venir como texto, como número o no existir,
/// así que aquí se convierten a un valor de Dart o a null.
class LecturaFirebase {
  LecturaFirebase._(); // Clase de solo métodos estáticos

  /// Texto del nodo, o null si no existe o está vacío.
  static String? texto(DataSnapshot nodo) {
    final dynamic valor = nodo.value;
    if (valor == null) return null;

    final String contenido = valor.toString().trim();
    return contenido.isEmpty ? null : contenido;
  }

  /// Número del nodo como entero, o null si no es numérico.
  static int? entero(DataSnapshot nodo) {
    final dynamic valor = nodo.value;
    if (valor is int) return valor;
    if (valor is num) return valor.toInt();
    if (valor is String) return int.tryParse(valor.trim());
    return null;
  }
}
