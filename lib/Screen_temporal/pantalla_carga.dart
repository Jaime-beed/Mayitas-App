import 'package:flutter/material.dart'; // Importa el catálogo de diseño (botones, textos, colores).
import 'package:firebase_auth/firebase_auth.dart'; // Herramientas de Firebase para leer sesiones.
import 'package:firebase_database/firebase_database.dart'; // CORRECCIÓN: faltaba, se necesita para revisar el perfil
import '../Screens/Pantalla_bienvenida.dart'; // Pantalla a la que vamos si NO hay sesión.
import '../Screens/pantalla_principal.dart'; // CORRECCIÓN: faltaba, pantalla si ya tiene perfil completo
import '../Screens/pantalla_editar_perfil.dart'; // CORRECCIÓN: faltaba, pantalla si el perfil no existe aún

// Pantalla dinámica (StatefulWidget) que puede realizar acciones con el tiempo.
class PantallaCarga extends StatefulWidget {
  const PantallaCarga({super.key});

  @override
  State<PantallaCarga> createState() => _PantallaCargaState();
}

class _PantallaCargaState extends State<PantallaCarga> {
  @override
  void initState() {
    super.initState(); // Configuración base y obligatoria de Flutter.
    _verificarSesion(); // Ejecutamos nuestra función de revisión ANTES de dibujar la pantalla.
  }

  Future<void> _verificarSesion() async {
    // Pausa el código para que el usuario alcance a ver el logo de la app.
    await Future.delayed(const Duration(seconds: 3));

    // Le pregunta a Firebase: "¿Hay algún usuario guardado en la memoria del celular?".
    final usuario = FirebaseAuth.instance.currentUser;

    // Regla de seguridad: verifica si la pantalla sigue existiendo antes de cambiar a otra.
    if (!mounted) return;

    // CORRECCIÓN: ahora sí se usa la variable "usuario" para decidir a dónde ir
    if (usuario == null) {
      // No hay sesión activa: manda al login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PantallaBienvenida()),
        (route) => false,
      );
      return; // Corta aquí para no seguir revisando la base de datos sin usuario
    }

    // Sí hay sesión: revisamos si ya completó su perfil en la base de datos
    final ref = FirebaseDatabase.instance.ref("usuarios/${usuario.uid}"); // Nodo de este usuario
    final snapshot = await ref.get(); 
    final int edadGuardada = snapshot.exists
     ? (snapshot.child('edad').value as int? ?? 0) :0 ;// Consulta si el nodo existe

    // Regla de seguridad: volvemos a verificar que la pantalla siga activa
    // después del segundo await, antes de usar "context".
    if (!mounted) return;

    if (edadGuardada >0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PantallaPrincipal()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => PantallaEditarPerfil(correo: usuario.email ?? '')),
        (route) => false, 
      );
    }

  // Vuelve a chequear tras el segundo await

   
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack( // NUEVO: apila el fondo debajo y el contenido encima
      children: [
        // CAPA 1: imagen de fondo, cubre toda la pantalla
        Positioned.fill(
          child: Image.asset(
            'assets/Fondos/fondo_carga.png', // Cambia esto por tu imagen de fondo
            fit: BoxFit.cover, // Cubre toda la pantalla, recortando si es necesario
          ),
        ),

        // CAPA 2: tu contenido original (logo + spinner), sin cambios
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/Logos/logoprueba.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: Colors.orange),
            ],
          ),
        ),
      ],
    ),
  );
}
}