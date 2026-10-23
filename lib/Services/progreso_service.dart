import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

/// Resultado de calcular el nivel a partir de la experiencia total.
class InfoNivel {
  final int nivel; // Nivel actual (empieza en 1)
  final int xpEnNivel; // Experiencia acumulada dentro del nivel actual
  final int xpNecesaria; // Experiencia que cuesta completar el nivel actual
  final double progreso; // De 0.0 a 1.0, para la barra

  const InfoNivel({
    required this.nivel,
    required this.xpEnNivel,
    required this.xpNecesaria,
    required this.progreso,
  });
}

/// Resultado de sumar experiencia (por si quieres celebrar una subida de nivel).
class ResultadoXp {
  final int experienciaTotal;
  final int nivelAnterior;
  final int nivelNuevo;

  const ResultadoXp({
    required this.experienciaTotal,
    required this.nivelAnterior,
    required this.nivelNuevo,
  });

  bool get subioDeNivel => nivelNuevo > nivelAnterior;
}

/// "API" propia de experiencia y niveles.
/// Uso desde cualquier minijuego:
///   final r = await ProgresoService.sumarExperiencia(20);
///   if (r != null && r.subioDeNivel) { ...mostrar celebración... }
class ProgresoService {
  ProgresoService._(); // No se instancia, todo es estático

  // ---------------- AJUSTES (cambia solo aquí) ----------------
  static const int _costoPrimerNivel = 100; // XP para pasar del nivel 1 al 2
  static const int _aumentoPorNivel = 50; // Cuánto más cuesta cada nivel siguiente

  /// XP que cuesta completar [nivel] y pasar al siguiente.
  /// Nivel 1 -> 100, nivel 2 -> 150, nivel 3 -> 200, nivel 4 -> 250...
  static int xpParaSubir(int nivel) {
    return _costoPrimerNivel + (nivel - 1) * _aumentoPorNivel;
  }

  /// Convierte la experiencia total en nivel y progreso.
  static InfoNivel calcular(int experienciaTotal) {
    int restante = experienciaTotal < 0 ? 0 : experienciaTotal;
    int nivel = 1;

    // Va "gastando" la experiencia nivel por nivel
    while (restante >= xpParaSubir(nivel)) {
      restante -= xpParaSubir(nivel);
      nivel++;
    }

    final necesaria = xpParaSubir(nivel);
    return InfoNivel(
      nivel: nivel,
      xpEnNivel: restante,
      xpNecesaria: necesaria,
      progreso: restante / necesaria,
    );
  }

  /// Lee el campo 'experiencia' de lo que devuelve Realtime Database.
  /// Sirve para usarlo dentro del StreamBuilder de la barra.
  static int leerExperiencia(Object? valorDelNodo) {
    if (valorDelNodo is Map) {
      final e = valorDelNodo['experiencia'];
      if (e is num) return e.toInt();
    }
    return 0;
  }

  /// Suma experiencia al usuario actual en Firebase.
  /// Devuelve null si no hay sesión o la cantidad no es válida.
  static Future<ResultadoXp?> sumarExperiencia(int cantidad) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || cantidad <= 0) return null;

    final ref = FirebaseDatabase.instance.ref('usuarios/${user.uid}/experiencia');

    // La transacción lee y escribe de forma segura, aunque dos juegos sumen a la vez
    final resultado = await ref.runTransaction((valorActual) {
      final actual = (valorActual is num) ? valorActual.toInt() : 0;
      return Transaction.success(actual + cantidad);
    });

    if (!resultado.committed) return null;

    final total = (resultado.snapshot.value as num?)?.toInt() ?? 0;
    return ResultadoXp(
      experienciaTotal: total,
      nivelAnterior: calcular(total - cantidad).nivel,
      nivelNuevo: calcular(total).nivel,
    );
  }
}