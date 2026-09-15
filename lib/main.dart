import 'package:flutter/material.dart'; // Importa el catálogo visual de Flutter.
import 'package:firebase_core/firebase_core.dart'; // Importa el núcleo de Firebase.
import 'firebase_options.dart'; // Importa las llaves de tu base de datos generadas previamente.
import 'pantalla_carga.dart'; // ¡NUEVO! Importamos el archivo de la pantalla de carga.

void main() async {
  // Asegura que los motores de Flutter estén listos antes de ejecutar comandos externos.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Conecta la aplicación a tu proyecto de Firebase en la nube usando tus llaves.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Arranca la aplicación completa.
  runApp(const MayitasApp());
}

class MayitasApp extends StatelessWidget {
  const MayitasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mayitas',
      debugShowCheckedModeBanner: false, // Oculta la etiqueta roja de "DEBUG" en la esquina.
      theme: ThemeData(
        primarySwatch: Colors.blue, // Define el azul como color principal de la app.
        fontFamily: 'ComicNeue', // Fuente amigable para niños (requiere agregarla luego).
      ),
      // EL CAMBIO ESTÁ AQUÍ:
      // En lugar del Scaffold con el texto, ahora arrancamos mostrando la Pantalla de Carga.
      home: const PantallaCarga(), 
    );
  }
}