import 'package:flutter/material.dart'; // Importa el catálogo de diseño (botones, textos, colores).
import 'package:firebase_auth/firebase_auth.dart'; // Importa las herramientas de Firebase para leer sesiones.
import 'pantalla_colores.dart'; // Importa la pantalla a la que iremos si ya hay sesión.
import 'pantalla_login.dart'; // Importa la pantalla a la que iremos si NO hay sesión.

// Crea una pantalla dinámica (StatefulWidget) que puede realizar acciones con el tiempo.
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
    // Pausa el código por 2 segundos para que el usuario alcance a ver el logo de la app.
    await Future.delayed(const Duration(seconds: 2));
    
    // Le pregunta a Firebase: "¿Hay algún usuario guardado en la memoria del celular?".
    final usuario = FirebaseAuth.instance.currentUser;
    
    // Regla de seguridad: verifica si la pantalla sigue existiendo antes de cambiar a otra.
    if (!mounted) return; 
    
    if (usuario != null) {
      // Si hay usuario, Navigator (el chofer) destruye esta pantalla de carga y pone la de Colores encima.
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PantallaColores()));
    } else {
      // Si 'usuario' es nulo, manda al usuario a la pantalla de Login para que inicie sesión.
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PantallaLogin()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. QUITAMOS el 'const' antes del Scaffold
    return Scaffold(
      backgroundColor: Colors.orange, // Veo que cambiaste el fondo a azul, ¡se verá genial!
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 2. Aquí pones tu imagen de internet, sin la palabra const
            Image.network(
              'https://firebasestorage.googleapis.com/v0/b/mayitas-9bde2.firebasestorage.app/o/Logos%2Flogo%20prueba.png?alt=media&token=00d2e86a-9e89-4bda-bdbf-7d36ae9fac0d', // Recuerda mantener las comillas simples
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ), 
            // 3. Le ponemos 'const' de forma individual a estos dos porque sí son estáticos
            const SizedBox(height: 20), 
            const CircularProgressIndicator(color: Colors.white), 
          ],
        ),
      ),
    );
  }
  }
